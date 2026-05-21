[CmdletBinding()]
param(
  [string]$ProjectId,
  [string]$Region,
  [string]$ServiceName,
  [string]$BucketName,
  [string]$GitHubRepo,
  [string]$MongoUrl,
  [string]$Domain
)

$ErrorActionPreference = "Stop"

$configDir = Join-Path $HOME ".robot-future-stack"
$configPath = Join-Path $configDir "config.json"
$secretsPath = Join-Path $configDir "secrets.json"

if (-not (Test-Path $configDir)) {
  New-Item -ItemType Directory -Path $configDir | Out-Null
}

$existing = [pscustomobject]@{}
if (Test-Path $configPath) {
  $existing = Get-Content $configPath -Raw | ConvertFrom-Json
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

function Read-Value {
  param(
    [string]$Current,
    [string]$Prompt,
    [switch]$Secret
  )

  if ($Current) {
    return $Current
  }

  if ($Secret) {
    $secure = Read-Host $Prompt -AsSecureString
    return [System.Net.NetworkCredential]::new("", $secure).Password
  }

  return Read-Host $Prompt
}

$config = [ordered]@{
  projectId = Read-Value (Select-Value $ProjectId $existing.projectId) "Google Cloud project ID"
  region = Read-Value (Select-Value $Region $existing.region) "Default Google Cloud region"
  serviceName = Read-Value (Select-Value $ServiceName $existing.serviceName) "Cloud Run service name"
  bucketName = Read-Value (Select-Value $BucketName $existing.bucketName) "Cloud Storage bucket name"
  githubRepo = Read-Value (Select-Value $GitHubRepo $existing.githubRepo) "GitHub repo (owner/name)"
  domain = Read-Value (Select-Value $Domain $existing.domain) "Primary domain"
}

$mongoValue = Read-Value $MongoUrl "MongoDB connection string" -Secret
$mongoSecure = ConvertTo-SecureString $mongoValue -AsPlainText -Force
$secrets = [ordered]@{
  mongoUrl = ConvertFrom-SecureString $mongoSecure
}

$config | ConvertTo-Json | Set-Content $configPath
$secrets | ConvertTo-Json | Set-Content $secretsPath
Write-Host "Saved config to $configPath"
Write-Host "Saved encrypted secrets to $secretsPath"
