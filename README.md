# Gitii's config files

A template repository that contains settings, config files and scripts that I use in my personal projects.

## Getting started

Execute the boostrap script in the project root folder:
```powershell
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Gitii/config/main/install.ps1'))
```

This command will download the bootstrap powershell script and store it in `.config/bootstrap.ps1`.
Installation then continues by executing `bootstrap.ps1`.
That script will download this repository (as zip archive) and put the contents of the `templates` folder in the working directory of the shell (that executed the command above).

## Update 

To update to the latest `templates` version, execute the script (from the root folder of the project):
```powershell
pwsh ./.my-config/update.ps1
```

This script will do the same thing as `bootstrap.ps1` (from the Getting Started step)  
and download the latest files and overwrite any local changes.