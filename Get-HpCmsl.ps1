<#
    .SYNOPSIS
        Client Management Script Library

    .DESCRIPTION
        This script downloads and installs the "HP Client Management Script Library".

    .NOTES
        
    .LINK
        https://github.com/UsefulScripts01/HpModule
#>

function Get-HpCmsl {
    # script options
    $progressPreference = "SilentlyContinue"

    $Bios = (Get-ComputerInfo).BiosManufacturer
    if ($Bios -eq "HP") {
        Invoke-WebRequest -Uri "https://hpia.hpcloud.hp.com/downloads/cmsl/hp-cmsl-1.6.7.exe" -OutFile "C:\Windows\Temp\HpModule.exe"
        Start-Process -FilePath "C:\Windows\Temp\HpModule.exe" -Wait -ArgumentList "/verysilent /norestart"
        Remove-Item -Path "C:\Windows\Temp\HpModule.exe" -Force
        Start-Process -FilePath "https://developers.hp.com/hp-client-management/doc/client-management-script-library"
    }
}
Get-HpCmsl

Exit