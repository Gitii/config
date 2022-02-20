function Get-ScriptFolder() {
    $fp = $PSScriptRoot

    if ($fp) {
        return $fp
    }

    return $(split-path -parent $MyInvocation.MyCommand.Definition)
}

function New-TemporaryDirectory {
    $parent = [System.IO.Path]::GetTempPath()
    [string] $name = [System.Guid]::NewGuid()
    $path = Join-Path $parent $name
    New-Item -ItemType Directory -Path $path

    return $path
}

function Extract-Config($TargetDirectory) {
    $tempFile = New-TemporaryFile
    $tempFolder = New-TemporaryDirectory

    try {
        $url = 'https://github.com/Gitii/config/archive/refs/heads/main.zip' 

        Write-Host "Downloading..."
        Invoke-WebRequest -Uri $url -OutFile $tempFile.FullName
        
        Write-Host "Extracting to $tempFolder..."
        Expand-Archive $tempFile.FullName -DestinationPath $tempFolder -Force

        $templateFolder = Join-Path $tempFolder "templates"

        Write-Host "Copying templates to $TargetDirectory"
        Copy-Item -Path $templateFolder -Recurse -Destination $TargetDirectory

    } finally {
        $tempFile.Delete()

        Remove-Item $tempFolder -Recurse -Force -WhatIf
    }
}

$targetDir = Get-Location

Extract-Config -TargetDirectory $targetDir
