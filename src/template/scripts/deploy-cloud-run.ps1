[CmdletBinding()]
param(
  [string]$ProjectId,
  [string]$ServiceName,
  [string]$Region,
  [string]$Source = ".",
  [string]$ManifestPath = "deploy/cloud-run.json",
  [string]$ServiceAccount
)

$ErrorActionPreference = "Stop"

$stateDir = Join-Path $HOME ".robot-future-stack"
$configPath = Join-Path $stateDir "config.json"
$secretsPath = Join-Path $stateDir "secrets.json"

$config = [pscustomobject]@{}
if (Test-Path $configPath) {
  $config = Get-Content $configPath -Raw | ConvertFrom-Json
}

function Select-Value {
  param(
    [string]$Preferred,
    [string]$Fallback
  )

  if ($Preferred) {
    return $Preferred
  }

  return $Fallback
}

function Get-LocalSecretValue {
  param([string]$Key)

  if (-not (Test-Path $secretsPath)) {
    throw "Missing local secrets file at $secretsPath"
  }

  $localSecrets = Get-Content $secretsPath -Raw | ConvertFrom-Json
  $encrypted = $localSecrets.$Key
  if (-not $encrypted) {
    throw "Missing local secret key '$Key' in $secretsPath"
  }

  $secure = ConvertTo-SecureString $encrypted
  return [System.Net.NetworkCredential]::new("", $secure).Password
}

$project = Select-Value $ProjectId $config.projectId
$service = Select-Value $ServiceName $config.serviceName
$deployRegion = Select-Value $Region $config.region

if (-not $project -or -not $service -or -not $deployRegion) {
  throw "Missing project, service, or region. Run save-config.ps1 first or pass explicit values."
}

$manifest = [pscustomobject]@{
  envVars = [pscustomobject]@{}
  secrets = @()
  healthPath = "/"
}

if (Test-Path $ManifestPath) {
  $manifest = Get-Content $ManifestPath -Raw | ConvertFrom-Json
}

gcloud services enable `
  run.googleapis.com `
  cloudbuild.googleapis.com `
  artifactregistry.googleapis.com `
  secretmanager.googleapis.com `
  --project $project `
  --quiet

$projectNumber = gcloud projects describe $project --format="value(projectNumber)"
$runtimeServiceAccount = $ServiceAccount
if (-not $runtimeServiceAccount) {
  $runtimeServiceAccount = "$projectNumber-compute@developer.gserviceaccount.com"
}

function Ensure-Secret {
  param(
    [string]$SecretName,
    [string]$SecretValue
  )

  gcloud secrets describe $SecretName --project $project --quiet 2>$null | Out-Null
  if ($LASTEXITCODE -ne 0) {
    gcloud secrets create $SecretName --replication-policy="automatic" --project $project --quiet | Out-Null
  }

  $tempSecretFile = New-TemporaryFile
  try {
    Set-Content -Path $tempSecretFile -Value $SecretValue -NoNewline
    gcloud secrets versions add $SecretName --data-file=$tempSecretFile --project $project --quiet | Out-Null
  }
  finally {
    Remove-Item -LiteralPath $tempSecretFile -Force
  }

  gcloud secrets add-iam-policy-binding $SecretName `
    --member="serviceAccount:$runtimeServiceAccount" `
    --role="roles/secretmanager.secretAccessor" `
    --project $project `
    --quiet | Out-Null
}

$envVarsFile = New-TemporaryFile
$secretBindings = @()

try {
  foreach ($property in $manifest.envVars.PSObject.Properties) {
    Add-Content -Path $envVarsFile -Value "$($property.Name)=$($property.Value)"
  }

  foreach ($secret in $manifest.secrets) {
    $secretValue = Get-LocalSecretValue $secret.localSecretKey
    Ensure-Secret $secret.secretName $secretValue
    $version = if ($secret.version) { $secret.version } else { "latest" }
    $secretBindings += "$($secret.envVar)=$($secret.secretName):$version"
  }

  $deployArgs = @(
    "run", "deploy", $service,
    "--source", $Source,
    "--region", $deployRegion,
    "--project", $project,
    "--allow-unauthenticated",
    "--max", "1",
    "--quiet"
  )

  if ($manifest.envVars.PSObject.Properties.Count -gt 0) {
    $deployArgs += @("--env-vars-file", $envVarsFile)
  }

  if ($secretBindings.Count -gt 0) {
    $deployArgs += @("--update-secrets", ($secretBindings -join ","))
  }

  if ($ServiceAccount) {
    $deployArgs += @("--service-account", $ServiceAccount)
  }

  gcloud @deployArgs
}
finally {
  Remove-Item -LiteralPath $envVarsFile -Force
}

$serviceJson = gcloud run services describe $service `
  --region $deployRegion `
  --project $project `
  --format=json | ConvertFrom-Json

$readyCondition = $serviceJson.status.conditions | Where-Object { $_.type -eq "Ready" } | Select-Object -First 1
if (-not $readyCondition -or $readyCondition.status -ne "True") {
  throw "Cloud Run service is not ready after deploy. Inspect logs before treating the deploy as complete."
}

$url = $serviceJson.status.url
if (-not $url) {
  throw "Cloud Run did not return a service URL."
}

$healthPath = if ($manifest.healthPath) { $manifest.healthPath } else { "/" }
$healthUrl = "$($url.TrimEnd('/'))$healthPath"
$response = Invoke-WebRequest -Uri $healthUrl -UseBasicParsing -TimeoutSec 30
if ($response.StatusCode -lt 200 -or $response.StatusCode -ge 400) {
  throw "Health check failed at $healthUrl with status code $($response.StatusCode)."
}

Write-Host "Cloud Run service is ready."
Write-Host "Service URL: $url"
Write-Host "Health check passed: $healthUrl"
