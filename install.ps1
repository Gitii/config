$targetDirectory = Join-Path $(Get-Location) ".config"
$bootStrapFilePath = Join-Path $targetDirectory "bootstrap.ps1"
$sourceUrl = if ($env:SOURCE_URL) { $env:SOURCE_URL } else { "https://raw.githubusercontent.com/Gitii/config/main/bootstrap.ps1" }

New-Item -ItemType Directory -Path $targetDirectory -Force | Out-Null

Invoke-WebRequest -Uri $sourceUrl -OutFile $bootStrapFilePath  

Get-Help $bootStrapFilePath
Write-Host "Downloaded, please execute .config/bootstrap.ps1 to complete the installation."
Write-Host "See above documentation for some examples."