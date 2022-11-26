<#
    .SYNOPSIS
        
    .DESCRIPTION
        
    .NOTES

    .LINK
        https://github.com/UsefulScripts01/HpModule
#>

function Get-HpModule {
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Force -Scope Process
    $HpModule = (Get-Module -All).Name
    if ($HpModule -notcontains "HPCMSL") {
        Install-PackageProvider -Name NuGet -Force
        Install-Module PowerShellGet -AllowClobber -Force
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
        
        Start-Process -FilePath "powershell" -Wait -WindowStyle Hidden {
            Install-Module -Name "HPCMSL" -AcceptLicense -Force
        }
        
        Import-Module -Name "HPCMSL" -Scope Global
        Get-Module -All -Name "HP*" | Format-Table
        
        Write-Host "`n"
        Write-Host "REF: https://developers.hp.com/hp-client-management/doc/client-management-script-library (Ctrl + Link to open website)"
        Write-Host "`n"
    }
}

function Update-Bios {
    $VolumeStatus = (Get-BitLockerVolume).VolumeStatus
    if ($VolumeStatus -ne "FullyDecrypted") {
        Suspend-BitLocker -MountPoint "C:" -RebootCount 1
    }
    Get-HPBIOSUpdates
    Get-HPBIOSUpdates -Flash -Overwrite -Offline -Force
}

$progressPreference = "SilentlyContinue"

$Bios = (Get-CimInstance -ClassName win32_computersystem).Manufacturer
if (($Bios -match "HP") -or ($Bios -match "Microsoft")) {
    $Exit = "N"
    while ($Exit -ne "Y") {
        Write-Host "Chose Option:" -ForegroundColor White -BackgroundColor DarkGreen
        Write-Host "`n"
        Write-Host "1 - Install HP CMSL only"
        Write-Host "2 - Update BIOS"
        Write-Host "R - Restart computer"
        Write-Host "9 - Exit"
        Write-Host "`n"

        $SelectOption = Read-Host -Prompt "Select Option"
        Switch ($SelectOption) {
            "1" {
                Get-HpModule
            }
            "2" {
                Get-HpModule
                Update-Bios
            }
            "R" {
                Restart-Computer -Force
            }
            "9" {
                $Exit = "Y"
            }
        }
    }
    
}
else {
    Clear-Host
    Write-Host "`n"
    Write-Host "INFO: This is not an HP machine.." -ForegroundColor White -BackgroundColor DarkGreen
    Write-Host "`n"
}
