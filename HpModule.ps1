<#
    .SYNOPSIS

    .DESCRIPTION

    .NOTES

    .LINK
        https://github.com/UsefulScripts01/HpModule
#>

function Get-HpModule {
    $ModuleList = (Get-Module).Name
    if ($ModuleList -notcontains "HPCMSL") {

        Install-PackageProvider -Name NuGet -Force
        Install-Module PowerShellGet -AllowClobber -Force
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

        Start-Process -FilePath "powershell" -Wait -WindowStyle Hidden {
            Install-Module -Name "HPCMSL" -AcceptLicense -Force
        }

        Get-Module -ListAvailable -Name "HP*" | Import-Module -Global -Force

        Write-Host "`n"
        Write-Host "HPCMSL was installed.."
        Write-Host "REF: https://developers.hp.com/hp-client-management/doc/client-management-script-library"
        Write-Host "`n"
    }
    else {
        Write-Host "`n"
        Write-Host "HPCMSL was installed.."
        Write-Host "`n"
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
    $Path = Test-Path -Path "C:\Temp\Drivers"
    if ($Path -match "False") {
        New-Item -ItemType "directory" -Path "C:\Temp\Drivers"
    }
    Set-Location -Path "C:\Temp\Drivers"
    Get-SoftpaqList -Category Driver | Format-Table

    $DriverList = (Get-SoftpaqList -Category Driver).Id
    foreach ($Number in $DriverList) {
        Get-Softpaq -Number $Number -Overwrite no -Action silentinstall -ErrorAction SilentlyContinue
    }
    Remove-Item -Path "C:\Temp\Drivers" -Recurse -Force
}

function Get-SelectedDriver {
    $Path = Test-Path -Path "C:\Temp\Drivers"
    if ($Path -match "False") {
        New-Item -ItemType "directory" -Path "C:\Temp\Drivers"
    }
    Set-Location -Path "C:\Temp\Drivers"
    Get-SoftpaqList -Category Driver | Format-Table

    $Number = Read-Host -Prompt "Enter the SoftPaq number"
    Get-Softpaq -Number $Number -Overwrite no -Action silentinstall -ErrorAction SilentlyContinue
    Remove-Item -Path "C:\Temp\Drivers" -Recurse -Force
}

# Windows Updates
function Get-OsUpdate {
    $ModuleList = (Get-Module -ListAvailable).Name
    if ($ModuleList -notcontains "PSWindowsUpdate") {
        Install-PackageProvider -Name NuGet -Force
        Install-Module -Name PSWindowsUpdate -Force
        Import-Module -Name PSWindowsUpdate -Force
    }

    Write-Host "`n"
    Write-Host "Checking for updates.." -ForegroundColor White -BackgroundColor DarkGreen
    Write-Host "`n"
    Install-WindowsUpdate -AcceptAll -IgnoreReboot -MicrosoftUpdate
}

function Disable-Encryption {
    Clear-BitLockerAutoUnlock
    Get-BitLockerVolume | Disable-BitLocker

    While ((Get-BitLockerVolume).VolumeStatus -ne "FullyDecrypted") {
        Clear-Host
        Get-BitLockerVolume
        Start-Sleep -second 10
    }
}

function Enable-Encryption {
    gpupdate /force

    # Add protectors - Recovery and PIN
    Add-BitLockerKeyProtector -MountPoint c: -RecoveryPasswordProtector
    $SecureString = ConvertTo-SecureString "112233" -AsPlainText -Force
    
    # Enable BitLocker on C:
    Enable-BitLocker -MountPoint "C:" -EncryptionMethod Aes256 -SkipHardwareTest -TpmAndPinProtector -Pin $SecureString
    
    # Backup recovery in file
    #(Get-BitLockerVolume -MountPoint C:).KeyProtector.KeyProtectorId | Out-File -FilePath "~\Desktop\RecoveryKey.txt" -Append
    (Get-BitLockerVolume -MountPoint C:).KeyProtector.RecoveryPassword | Where-Object {$_} | Out-File -FilePath "~\Desktop\RecoveryKey.txt" -Force
    
    # Backup recovery in AD
    #$BLV = Get-BitLockerVolume -MountPoint "C:"
    #Backup-BitLockerKeyProtector -MountPoint "C:" -KeyProtectorId $BLV.KeyProtector[1].KeyProtectorId
    
    # Other Drives
    $RecoveryPass = (Get-BitLockerVolume -MountPoint C:).KeyProtector.RecoveryPassword
    $RecoveryPass = $RecoveryPass | Where-Object {$_}
    Get-BitLockerVolume | Where-Object -Property MountPoint -ne "C:" | Enable-BitLocker -EncryptionMethod Aes256 -SkipHardwareTest -RecoveryPasswordProtector -RecoveryPassword $RecoveryPass
    Get-BitLockerVolume | Where-Object -Property MountPoint -ne "C:" | Enable-BitLockerAutoUnlock

    While ((Get-BitLockerVolume).VolumeStatus -ne "FullyEncrypted") {
        Clear-Host
        Get-BitLockerVolume
        Start-Sleep -second 10
    }
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
        Write-Host "Q - Exit"
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
                $Date = Get-Date -Format "dd.MM.yyyy"
                Get-SoftpaqList -Category Driver | Format-Table | Out-File -FilePath "~\Desktop\$Date - Available Drivers.txt"
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
            "Q" {
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
