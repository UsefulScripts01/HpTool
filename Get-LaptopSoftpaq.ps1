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

function Get-LaptopSoftpaq {
    $progressPreference = "SilentlyContinue"

    Start-Job -Name "Get-LaptopSoftpaq" -ScriptBlock {
        $TestPath = Test-Path -Path "C:\SOFTPAQ"
        if ($TestPath -match "False") {
            New-Item -Name "SOFTPAQ" -ItemType Directory -Path "C:\" -Force
        }
        $OsVer = (Get-ComputerInfo).OSDisplayVersion
        $CsModel = (Get-ComputerInfo).CsModel
        New-Item -Name $CsModel -ItemType Directory -Path "C:\SOFTPAQ\" -Force
        $Path = "C:\SOFTPAQ\$CsModel\"
        New-HPDriverPack -OSVer $OsVer -Path $Path -RemoveOlder -Overwrite    
    }
    Get-Job | Wait-Job -Timeout 300
}
Get-LaptopSoftpaq

Exit