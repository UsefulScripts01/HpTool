<#
    .SYNOPSIS
        
    .DESCRIPTION
        
    .NOTES

    .LINK
        https://github.com/UsefulScripts01/HpModule
#>

function Get-HpModule {
    $HpModule = (Get-Module -ListAvailable).Name
    if ($HpModule -notcontains "HPCMSL") {
        Install-PackageProvider -Name NuGet -Force
        Install-Module PowerShellGet -AllowClobber -Force
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
        
        Start-Process -FilePath "powershell" -Wait -WindowStyle Hidden {
            Install-Module -Name "HPCMSL" -AcceptLicense -Force
        }
        
        (Get-Module -ListAvailable -Name "HP*").Name | Import-Module -Force
        Get-Module -All -Name "HP*" | Format-Table
        
        Write-Host "`n"
        Write-Host "REF: https://developers.hp.com/hp-client-management/doc/client-management-script-library (Ctrl + Link to open website)"
        Write-Host "`n"
    }
    else {
        (Get-Module -ListAvailable -Name "HP*").Name | Import-Module -Force
    }
}

function Update-Bios {
    $VolumeStatus = (Get-BitLockerVolume).VolumeStatus
    if ($VolumeStatus -ne "FullyDecrypted") {
        Suspend-BitLocker -MountPoint "C:" -RebootCount 1
    }
    Get-HPBIOSUpdates
    Get-HPBIOSUpdates -Flash -Offline -Force
}

function Get-AllDriver {
    Set-Location -Path "C:\Windows\Temp"
    Get-SoftpaqList -Category Driver | Format-Table
    $Driver = (Get-SoftpaqList -Category Driver).Id
    foreach ($Id in $Driver) {
        Get-Softpaq -Number $Id -Overwrite no -Action silentinstall -ErrorAction SilentlyContinue
    }
    Clear-SoftpaqCache
    Get-ChildItem -Path C:\Windows\Temp -Include ("*.msi", "*.exe") -Recurse | Remove-Item -Force
    $Date = Get-Date -Format "dd.MM.yyyy"
    Get-SoftpaqList -Category Driver | Format-Table | Out-File -FilePath "~\Desktop\$Date - InstalledDrivers.txt"
}

function Get-SelectedDriver {
    Set-Location -Path "C:\Windows\Temp"
    Get-SoftpaqList -Category Driver | Format-Table
    $Driver = Read-Host -Prompt "Enter the SoftPaq number"
    Get-Softpaq -Number $Driver -Overwrite no -Action silentinstall -ErrorAction SilentlyContinue
    Clear-SoftpaqCache
    Get-ChildItem -Path C:\Windows\Temp -Include ("*.msi", "*.exe") -Recurse | Remove-Item -Force
    $Date = Get-Date -Format "dd.MM.yyyy"
    Get-SoftpaqList -Category Driver | Format-Table | Out-File -FilePath "~\Desktop\$Date - InstalledDrivers.txt"
}

# Windows Updates
function Get-OsUpdate {
    Install-PackageProvider -Name NuGet -Force
    Install-Module -Name PSWindowsUpdate -Force
    Import-Module -Name PSWindowsUpdate -Force

    Write-Host "`n"
    Write-Host "Checking for updates.." -ForegroundColor White -BackgroundColor DarkGreen
    Write-Host "`n"
    Install-WindowsUpdate -AcceptAll -IgnoreReboot -MicrosoftUpdate
}


Set-ExecutionPolicy -ExecutionPolicy Bypass -Force -Scope Process
$progressPreference = "SilentlyContinue"

$Bios = (Get-CimInstance -ClassName win32_computersystem).Manufacturer
if (($Bios -match "HP") -or ($Bios -match "Microsoft")) {
    $Exit = "N"
    while ($Exit -ne "Y") {
        Write-Host "Chose Option:" -ForegroundColor White -BackgroundColor DarkGreen
        Write-Host "`n"
        Write-Host "1 - Install HP CMSL only"
        Write-Host "2 - Update BIOS"
        Write-Host "3 - Check available drivers"
        Write-Host "4 - Install ALL available drivers"
        Write-Host "5 - Install SELECTED driver"
        Write-Host "6 - Windows Updates"
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
            "3" {
                Get-HpModule
                Get-SoftpaqList -Category Driver | Format-Table
            }
            "4" {
                Get-HpModule
                Get-AllDriver
            }
            "5" {
                Get-HpModule
                Get-SelectedDriver
            }
            "6" {
                Get-OsUpdate
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
