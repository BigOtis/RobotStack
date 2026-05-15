[CmdletBinding()]
param(
  [switch]$CheckOnly
)

$ErrorActionPreference = "Stop"

function Test-Command {
  param([string]$Name)
  return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

$tools = @(
  @{ Name = "git"; Install = "winget install --id Git.Git -e" },
  @{ Name = "gh"; Install = "winget install --id GitHub.cli -e" },
  @{ Name = "gcloud"; Install = "winget install --id Google.CloudSDK -e" },
  @{ Name = "node"; Install = "winget install --id OpenJS.NodeJS.LTS -e" },
  @{ Name = "npm"; Install = "Install Node.js LTS; npm ships with Node.js" }
)

$results = foreach ($tool in $tools) {
  [pscustomobject]@{
    Tool = $tool.Name
    Installed = Test-Command $tool.Name
    InstallHint = $tool.Install
  }
}

$results | Format-Table -AutoSize

if ($CheckOnly) {
  return
}

$missing = $results | Where-Object { -not $_.Installed }
if (-not $missing) {
  Write-Host "All baseline tools are installed."
  return
}

if (-not (Test-Command "winget")) {
  Write-Host "Missing tools detected, but winget is not available. Install them manually using the hints above."
  return
}

foreach ($tool in $missing) {
  if ($tool.Tool -eq "npm") {
    continue
  }

  Write-Host "Installing $($tool.Tool)..."
  Invoke-Expression $tool.InstallHint
}

Write-Host "Re-run this script with -CheckOnly to verify the final state."

