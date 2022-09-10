function Get-LaptopSoftpaq {
    <#
    .SYNOPSIS
        Get HP Softpaq.

    .DESCRIPTION
        This script downloads all HP Softpaq that match your machine.

    .NOTES
        
    .LINK
        https://github.com/UsefulScripts01/HpModule
    #>
    
    $progressPreference = "SilentlyContinue"

    $Bios = (Get-ComputerInfo).BiosManufacturer
    if ($Bios -eq "HP" -and $CmslPath -notmatch "True") {

        $CmslPath = Test-Path -Path "C:\Program Files\WindowsPowerShell\HP.CMSL.UninstallerData"
        if ($CmslPath -notmatch "True") {
            Invoke-WebRequest -Uri "https://hpia.hpcloud.hp.com/downloads/cmsl/hp-cmsl-1.6.7.exe" -OutFile "C:\Windows\Temp\HpModule.exe"
            Start-Process -FilePath "C:\Windows\Temp\HpModule.exe" -Wait -ArgumentList "/verysilent /norestart"
            Remove-Item -Path "C:\Windows\Temp\HpModule.exe" -Force
            #Start-Process -FilePath "https://developers.hp.com/hp-client-management/doc/client-management-script-library"
        }
    
        $TestPath = Test-Path -Path "C:\SOFTPAQ"
        if ($TestPath -match "False") {
            New-Item -Name "SOFTPAQ" -ItemType Directory -Path "C:\" -Force
        }
        $OsVer = (Get-ComputerInfo).OSDisplayVersion
        $CsModel = (Get-ComputerInfo).CsModel
        New-Item -Name $CsModel -ItemType Directory -Path "C:\SOFTPAQ\" -Force
        $Path = "C:\SOFTPAQ\$CsModel\"
        Invoke-Item -Path $Path
        New-HPDriverPack -OSVer $OsVer -Path $Path -RemoveOlder -Overwrite    
    }

}

Get-LaptopSoftpaq

Exit