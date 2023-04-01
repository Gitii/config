function Get-ScriptFolder() {
    $fp = $PSScriptRoot

    if ($fp) {
        return $fp
    }

    return $(split-path -parent $MyInvocation.MyCommand.Definition)
}

$rootFolder = Get-ScriptFolder

# import root ca cert
$rootCA = Join-Path $rootFolder "Gitii_Root_CA.crt"
Import-Certificate -FilePath $rootCA -CertStoreLocation Cert:\LocalMachine\Root

# import intermediate ca cert
$imCA = Join-Path $rootFolder "Gitii_Intermediate_CA.crt"
Import-Certificate -FilePath $imCA -CertStoreLocation Cert:\LocalMachine\Root

# import code singing cert
$cs = Join-Path $rootFolder "Gitii_Code_Signing.crt"
Import-Certificate -FilePath $cs -CertStoreLocation Cert:\LocalMachine\My
Import-Certificate -FilePath $cs -CertStoreLocation Cert:\CurrentUser\My
