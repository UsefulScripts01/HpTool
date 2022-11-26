
function Get-HpModule {
    #Set-ExecutionPolicy Bypass -Force
    Install-PackageProvider -Name NuGet -Force
    Install-Module PowerShellGet -AllowClobber -Force
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    Install-Module -Name HPCMSL -AcceptLicense -Force
}
Get-HpModule
Start-Process -FilePath "https://developers.hp.com/hp-client-management/doc/client-management-script-library"
