function Enable-AutoSwitching {
    <#
    .SYNOPSIS
        Enable LAN / WLAN Auto Switching

    .DESCRIPTION
        This script Enable LAN / WLAN Auto Switching in bios.

    .NOTES
        
    .LINK
        https://github.com/UsefulScripts01/HpModule
    #>
    
    $progressPreference = "SilentlyContinue"

    $Bios = (Get-ComputerInfo).BiosManufacturer
        if ($Bios -eq "HP") {
            Invoke-WebRequest -Uri "https://hpia.hpcloud.hp.com/downloads/cmsl/hp-cmsl-1.6.7.exe" -OutFile "C:\Windows\Temp\HpModule.exe"
            Start-Process -FilePath "C:\Windows\Temp\HpModule.exe" -Wait -ArgumentList "/verysilent /norestart"
            Set-HPBIOSSettingValue -Name "LAN / WLAN Auto Switching" -Value "Enable"
            Start-Process -FilePath "C:\Program Files\WindowsPowerShell\HP.CMSL.UninstallerData\unins000.exe" -Wait -ArgumentList "/verysilent /norestart"
            Remove-Item -Path "C:\Windows\Temp\HpModule.exe" -Force
        }
    }

Enable-AutoSwitching

Exit