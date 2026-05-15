[CmdletBinding()]
param(
  [string]$ProjectId,
  [string]$ServiceName,
  [string]$Region,
  [string]$Source = "."
)

$ErrorActionPreference = "Stop"

$configPath = Join-Path (Join-Path $HOME ".robot-future-stack") "config.json"
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

$project = Select-Value $ProjectId $config.projectId
$service = Select-Value $ServiceName $config.serviceName
$deployRegion = Select-Value $Region $config.region

if (-not $project -or -not $service -or -not $deployRegion) {
  throw "Missing project, service, or region. Run save-config.ps1 first or pass explicit values."
}

gcloud services enable `
  run.googleapis.com `
  cloudbuild.googleapis.com `
  artifactregistry.googleapis.com `
  --project $project `
  --quiet

gcloud run deploy $service `
  --source $Source `
  --region $deployRegion `
  --project $project `
  --allow-unauthenticated `
  --max 1 `
  --quiet

gcloud run services describe $service `
  --region $deployRegion `
  --project $project `
  --format="value(status.url)"
