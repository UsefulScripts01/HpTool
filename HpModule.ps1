<#
    .SYNOPSIS
        Client Management Script Library

    .DESCRIPTION
        This script downloads and installs the "HP Client Management Script Library".

    .NOTES
        
    .LINK
        https://github.com/UsefulScripts01/HpModule
#>

# script options
$progressPreference = "SilentlyContinue"

function Get-HpModule {
    Invoke-WebRequest -Uri "https://hpia.hpcloud.hp.com/downloads/cmsl/hp-cmsl-1.6.7.exe" -OutFile "C:\Windows\Temp\HpModule.exe"
    Start-Process -FilePath "C:\Windows\Temp\HpModule.exe" -Wait -ArgumentList "/silent /norestart"
    Get-Command -Module "*HP*" | Out-GridView
    Start-Process -FilePath "https://developers.hp.com/hp-client-management/doc/client-management-script-library"
    Remove-Item -Path "C:\Windows\Temp\HpModule.exe" -Force
}
Get-HpModule

# Set-HPBIOSSettingValue -Name "LAN / WLAN Auto Switching" -Value "Enable"

Exit
