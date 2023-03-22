<#
.SYNOPSIS
Bootstrap script for downloading and applying personal config files for programming.

.EXAMPLE
.config/bootstrap.ps1 # download and apply *all* templates
.config/bootstrap.ps1 -Selection git,vs # download and apply *only* "vs" and "git" templates

Known templates are:
- `git`
  Contains default git ignore files
- `prettier`
  Contains prettier config and ignore files
- `vs`
  Contains project defaults and dotnet tool config

The selected template options will be stored in `.config/.bootstrap.config.json`

#> 
param (
    [string] $OutputDirectory,
    [string[]] $Selection = $null,
    [string] $SourceUrl = 'https://github.com/Gitii/config/archive/refs/heads/main.zip' 
)

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
    [string] $path = Join-Path $parent $name
    New-Item -ItemType Directory -Path $path | Out-Null

    return $path
}

function Extract-Zip($ArchivePath, $TargetDirectory) {
    Add-Type -Assembly "System.IO.Compression.Filesystem"
    $ar = [System.IO.Compression.ZipFile]::OpenRead($tempFile.FullName)

    $ar.Entries | ? { $_.Name -ne "" } | % {
        $entry = $_

        $directory = Split-Path $entry.FullName
        $fullTargetDirectory = Join-Path $TargetDirectory $directory

        New-Item -ItemType Directory $fullTargetDirectory -Force | Out-Null

        $fullTargetFilePath = Join-Path $fullTargetDirectory $entry.Name

        Write-Debug "Extracting $($entry.Name) to $fullTargetFilePath"

        $stream = New-Object -TypeName System.IO.FileStream -ArgumentList @($fullTargetFilePath, [System.IO.FileMode]::OpenOrCreate)

        $entryStream = $entry.Open()

        $entryStream.CopyTo($stream)

        $stream.Close()
        $entryStream.Close()
    }

    $ar.Dispose()

}

function Extract-Config($TargetDirectory, $Url, $Selection) {
    $tempFile = New-TemporaryFile
    $tempFolder = New-TemporaryDirectory

    try {
        $url = $Url

        Write-Host "Downloading..."
        Invoke-WebRequest -Uri $url -OutFile $tempFile.FullName
        
        Write-Host "Extracting to $tempFolder..."
        Extract-Zip -ArchivePath $tempFile.FullName -TargetDirectory $tempFolder

        $templateFolder = Join-Path $(Join-Path $tempFolder "config-main") "templates"

        
        if ($Selection -eq null -or $Selection.Length -eq 0 -or $Selection[0] -ieq "all") {
            # nothing selected, copy everything
            Write-Host "Copying all templates to $TargetDirectory"
            Get-ChildItem -Path $templateFolder -Force | Copy-Item -Recurse -Destination $TargetDirectory -Force
        } else {
            
            $Selection | { 
                $SelectedFolder = Join-Path $templateFolder $_
                if (-! Test-Path $SelectedFolder) {
                    Write-Error "Template $_ doesn't exist"
                    continue
                }

                Write-Host "Copying template $_ to $TargetDirectory"
                Get-Item $SelectedFolder | Copy-Item -Recurse -Destination $TargetDirectory -Force 
            
            }
        }
    } finally {
        $tempFile.Delete()

        Remove-Item $tempFolder -Recurse -Force
    }
}

function Get-Defaults() {
    $defaultsFile = Join-Path $(Join-Path $(Get-ScriptFolder) ".config") ".bootstrap.config.json"

    if (Test-Path $defaultsFile) {
        return $(ConvertFrom-Json ($Get-Content $defaultsFile))
    } else {
        return @{
            Selection = @()
        }
    }
}

function Set-Defaults($Selection) {
    $defaultsFolder = Join-Path $(Get-ScriptFolder) ".config"

    New-Item -ItemType Directory $fullTargetDirectory -Force | Out-Null

    $defaultsFile = Join-Path $defaultsFolder ".bootstrap.config.json"

    @{ Selection = $Selection } | ConvertTo-Json | Output-File $defaultsFile -Encoding Ascii
}

$targetDir = if ($OutputDirectory) { $OutputDirectory } else { Get-Location }

if ($Selection -eq null) {
    $defaults = Get-Defaults()

    $Selection = $defaults.Selection
}

Extract-Config -TargetDirectory $targetDir -Url $SourceUrl -Selection $Selection

Set-Defaults -Selection $Selection

# Automatically restore dotnet tools when

try {
    Push-Location $targetDir

    Write-Host "Restoring dotnet tools..."
    dotnet tool restore

} finally {
    Pop-Location
}




