
function Get-HpModule {
    Install-PackageProvider -Name NuGet -Force
    Install-Module PowerShellGet -AllowClobber -Force
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

    Start-Process -FilePath "powershell" -Wait -WindowStyle Hidden {
        Install-Module -Name HPCMSL -Force -AcceptLicense
    }
}
Get-HpModule
Start-Process -FilePath "https://developers.hp.com/hp-client-management/doc/client-management-script-library"
