<#
    .SYNOPSIS

    .DESCRIPTION

    .NOTES

    .LINK
        https://github.com/UsefulScripts01/HpModule
#>


function Get-HpModule {
    $HpModule = (Get-Module -ListAvailable -Name "HPCMSL").Name
    if ($HpModule -notmatch "HPCMSL") {
        Install-Module -Name PowerShellGet -AllowPrerelease -Force
        Install-Module -Name HPCMSL -Force -AcceptLicense
        Import-Module -Name HPCMSL -Force
    }
    
    Write-Host "`n"
    Write-Host " HP CMSL has been installed.. "
    Write-Host "`n"
    Start-Sleep -Seconds 5
}

function Update-Bios {
    $VolumeStatus = (Get-BitLockerVolume).VolumeStatus
    if ($VolumeStatus -ne "FullyDecrypted") {
        Suspend-BitLocker -MountPoint "C:" -RebootCount 1
    }
    Get-HPBIOSUpdates
    Get-HPBIOSUpdates -Flash -Offline -Force
}

function Get-OsUpdate {
    Install-PackageProvider -Name NuGet -Force
    Install-Module -Name PSWindowsUpdate -Force
    Import-Module -Name PSWindowsUpdate -Force

    Start-Process -FilePath "powershell" -Wait -WindowStyle Normal {
        Write-Host "`n"
        Write-Host " Checking for updates.. " -ForegroundColor White -BackgroundColor DarkGreen
        Write-Host "`n"
        Install-WindowsUpdate -AcceptAll -IgnoreReboot
    }
}

function Get-SelectedDriver {
    $HpDrivers = Test-Path -Path "C:\Windows\Temp\HpDrivers"
    if ($HpDrivers -match "False") {
        New-Item -ItemType "directory" -Path "C:\Windows\Temp\HpDrivers" -Force
    }
    Set-Location -Path "C:\Windows\Temp\HpDrivers"

    $DriverList = Get-SoftpaqList -Category BIOS, Driver | Select-Object -Property id, name, version, Size, ReleaseDate | Out-GridView -Title "Select driver(s):" -OutputMode Multiple
    foreach ($Number in $DriverList.id) {
        Get-Softpaq -Number $Number -Overwrite no -Action silentinstall -KeepInvalidSigned
    }

    Write-Host "`n"
    Write-Host "the following drivers have been installed:" -ForegroundColor White -BackgroundColor DarkGreen
    $DriverList | Format-Table -AutoSize
    Remove-Item -Path "C:\Windows\Temp\HpDrivers\*" -Recurse -Force
}

# Disable SED Encryption
function Disable-Encryption {
    if (!(Get-BitLockerVolume).VolumeStatus[0].ToString().Equals("FullyDecrypted")) {
        Clear-BitLockerAutoUnlock
        Get-BitLockerVolume | Disable-BitLocker

        While (!(Get-BitLockerVolume).VolumeStatus[0].ToString().Equals("FullyDecrypted")) {
            Clear-Host
            Get-BitLockerVolume
            Start-Sleep -second 10
        }
    }
}

function Enable-Encryption {
    if ((Get-BitLockerVolume).VolumeStatus[0].ToString().Equals("FullyDecrypted")) {

        # FVE
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\" -Name FVE -Force
        $FVE = "HKLM:\SOFTWARE\Policies\Microsoft\FVE\"
        New-ItemProperty -Path "$FVE" -Name ActiveDirectoryBackup -Value 1
        New-ItemProperty -Path "$FVE" -Name RequireActiveDirectoryBackup -Value 1
        New-ItemProperty -Path "$FVE" -Name ActiveDirectoryInfoToStore -Value 1
        New-ItemProperty -Path "$FVE" -Name UseRecoveryPassword -Value 1
        New-ItemProperty -Path "$FVE" -Name UseRecoveryDrive -Value 0
        New-ItemProperty -Path "$FVE" -Name EncryptionMethod -Value 4
        New-ItemProperty -Path "$FVE" -Name UseAdvancedStartup -Value 1
        New-ItemProperty -Path "$FVE" -Name EnableBDEWithNoTPM -Value 1
        New-ItemProperty -Path "$FVE" -Name UseTPM -Value 0
        New-ItemProperty -Path "$FVE" -Name UseTPMPIN -Value 1
        New-ItemProperty -Path "$FVE" -Name UseTPMKey -Value 0
        New-ItemProperty -Path "$FVE" -Name UseTPMKeyPIN -Value 0
        New-ItemProperty -Path "$FVE" -Name UseEnhancedPin -Value 1
        New-ItemProperty -Path "$FVE" -Name MinimumPIN -Value 6
        New-ItemProperty -Path "$FVE" -Name OSRecovery -Value 1
        New-ItemProperty -Path "$FVE" -Name OSManageDRA -Value 1
        New-ItemProperty -Path "$FVE" -Name OSRecoveryPassword -Value 1
        New-ItemProperty -Path "$FVE" -Name OSRecoveryKey -Value 0
        New-ItemProperty -Path "$FVE" -Name OSHideRecoveryPage -Value 1
        New-ItemProperty -Path "$FVE" -Name OSActiveDirectoryBackup -Value 1
        New-ItemProperty -Path "$FVE" -Name OSActiveDirectoryInfoToStore -Value 1
        New-ItemProperty -Path "$FVE" -Name OSRequireActiveDirectoryBackup -Value 1
        New-ItemProperty -Path "$FVE" -Name FDVRecovery -Value 1
        New-ItemProperty -Path "$FVE" -Name FDVManageDRA -Value 1
        New-ItemProperty -Path "$FVE" -Name FDVRecoveryPassword -Value 1
        New-ItemProperty -Path "$FVE" -Name FDVRecoveryKey -Value 2
        New-ItemProperty -Path "$FVE" -Name FDVHideRecoveryPage -Value 1
        New-ItemProperty -Path "$FVE" -Name FDVActiveDirectoryBackup -Value 1
        New-ItemProperty -Path "$FVE" -Name FDVActiveDirectoryInfoToStore -Value 1
        New-ItemProperty -Path "$FVE" -Name FDVRequireActiveDirectoryBackup -Value 1
        New-ItemProperty -Path "$FVE" -Name OSHardwareEncryption -Value 0
        New-ItemProperty -Path "$FVE" -Name OSAllowSoftwareEncryptionFailover -Value 0
        New-ItemProperty -Path "$FVE" -Name OSRestrictHardwareEncryptionAlgorithms -Value 0

        # TPM
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\" -Name TPM -Force
        $TPM = "HKLM:\SOFTWARE\Policies\Microsoft\TPM\"
        New-ItemProperty -Path "$TPM" -Name ActiveDirectoryBackup -Value 1
        New-ItemProperty -Path "$TPM" -Name RequireActiveDirectoryBackup -Value 0
        
        # TPM \ BlockedCommands
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\TPM\" -Name BlockedCommands -Force
        $BlockedCommands = "HKLM:\SOFTWARE\Policies\Microsoft\TPM\BlockedCommands\"
        New-ItemProperty -Path "$BlockedCommands" -Name IgnoreDefaultList -Value 1
        New-ItemProperty -Path "$BlockedCommands" -Name IgnoreLocalList -Value 1

        # Add protectors and enable BitLocker
        Add-BitLockerKeyProtector -MountPoint "C:" -RecoveryPasswordProtector
        $SecureString = ConvertTo-SecureString "112233" -AsPlainText -Force
        Enable-BitLocker -MountPoint "C:" -EncryptionMethod Aes256 -SkipHardwareTest -TpmAndPinProtector -Pin $SecureString

        # Backup recovery in file
        #(Get-BitLockerVolume -MountPoint "C:").KeyProtector.KeyProtectorId | Out-File -FilePath "~\Desktop\RecoveryKey.txt" -Append
        (Get-BitLockerVolume -MountPoint "C:").KeyProtector.RecoveryPassword | Where-Object { $_ } | Out-File -FilePath "~\Desktop\RecoveryKey.txt" -Force

        # Backup recovery in AD
        #$BLV = Get-BitLockerVolume -MountPoint "C:"
        #Backup-BitLockerKeyProtector -MountPoint "C:" -KeyProtectorId $BLV.KeyProtector[1].KeyProtectorId

        # Other Drives
        $RecoveryPass = (Get-BitLockerVolume -MountPoint "C:").KeyProtector.RecoveryPassword | Where-Object { $_ }
        Get-BitLockerVolume | Where-Object -Property MountPoint -ne "C:" | Enable-BitLocker -EncryptionMethod Aes256 -SkipHardwareTest -RecoveryPasswordProtector -RecoveryPassword $RecoveryPass
        Get-BitLockerVolume | Where-Object -Property MountPoint -ne "C:" | Enable-BitLockerAutoUnlock

        Get-BitLockerVolume
        Write-Host "`n"
        Write-Host " Encryption in progress.. " -BackgroundColor DarkGreen
        Write-Host "`n"
        Write-Host "BitLocker PIN: 112233 " -BackgroundColor DarkGreen
        Write-Host "`n"
        
    }
    else {
        Write-Host "`n"
        Write-Host " This machine is not connected to the domain or all drives are not decrypted.. " -BackgroundColor DarkRed
        Write-Host "`n"
    }
}

function Enable-SelectEncryption {

    Write-Host "`n"
    Write-Host " This option will encrypt an additional drive(s) " -BackgroundColor DarkGreen
    $Letter = Read-Host -Prompt " Enter a drive letter"

    if ((Get-BitLockerVolume -MountPoint $Letter).VolumeStatus.ToString().Equals("FullyDecrypted")) {
        $RecoveryPass = (Get-BitLockerVolume -MountPoint "C:").KeyProtector.RecoveryPassword | Where-Object { $_ }
        Get-BitLockerVolume | Where-Object -Property MountPoint $Letter.Split(':')[0] | Enable-BitLocker -EncryptionMethod Aes256 -SkipHardwareTest -RecoveryPasswordProtector -RecoveryPassword $RecoveryPass
        Get-BitLockerVolume | Where-Object -Property MountPoint $Letter.Split(':')[0] | Enable-BitLockerAutoUnlock
    
        Get-BitLockerVolume
        Write-Host "`n"
        Write-Host " Encryption in progress on disk $Letter.. " -BackgroundColor DarkGreen
        Write-Host "`n"
    }
    else {
        Write-Host "`n"
        Write-Host " Selected drive is not decrypted " -BackgroundColor DarkRed
        Write-Host " Decryption in progress.. " -BackgroundColor DarkRed
        Write-Host "`n"
        Get-BitLockerVolume -MountPoint $Letter | Disable-BitLocker
        
        While (!(Get-BitLockerVolume).VolumeStatus[0].ToString().Equals("FullyDecrypted")) {
            Clear-Host
            Get-BitLockerVolume
            Start-Sleep -second 10
        }
        
        $RecoveryPass = (Get-BitLockerVolume -MountPoint "C:").KeyProtector.RecoveryPassword | Where-Object { $_ }
        Get-BitLockerVolume | Where-Object -Property MountPoint $Letter.Split(':')[0] | Enable-BitLocker -EncryptionMethod Aes256 -SkipHardwareTest -RecoveryPasswordProtector -RecoveryPassword $RecoveryPass
        Get-BitLockerVolume | Where-Object -Property MountPoint $Letter.Split(':')[0] | Enable-BitLockerAutoUnlock
    
        Get-BitLockerVolume
        Write-Host "`n"
        Write-Host " Encryption in progress on disk $Letter.. " -BackgroundColor DarkGreen
        Write-Host "`n"

    }
}






$ProgressPreference = "SilentlyContinue"

# PS Version check
if ($PSVersionTable.PSEdition.Equals('Core')) {
    Write-Host "`n"
    Write-Host " INFO: Please use Windows PowerShell.. " -BackgroundColor DarkRed
    Write-Host "`n"
    $Exit = "Y"
}
else {
    $Exit = "N"
}

# MENU
$Bios = (Get-CimInstance -ClassName win32_computersystem).Manufacturer
if (($Bios -match "HP") -or ($Bios -match "Hewlett-Packard")) {
    
    while ($Exit -ne "Y") {
        Write-Host "`n"
        Write-Host " SELECT AN OPTION: " -BackgroundColor DarkGreen
        Write-Host "`n"
        Write-Host "1 - Install HP CMSL only"
        Write-Host "`n"
        Write-Host "2 - Update BIOS (OVERWRITE)"
        Write-Host "3 - Download amd install HP drivers"
        Write-Host "`n"
        Write-Host "6 - Windows Updates"
        Write-Host "`n"
        Write-Host "7 - Disable BitLocker - ALL DRIVES"
        Write-Host "8 - Enable BitLocker - ALL DRIVES / NO RESTART"
        Write-Host "9 - Enable BitLocker - SELECTED DRIVE / NO RESTART"
        Write-Host "`n"
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
                Get-SelectedDriver
            }
            "6" {
                Get-OsUpdate
            }
            "7" {
                Disable-Encryption
            }
            "8" {
                Enable-Encryption
            }
            "9" {
                Enable-SelectEncryption
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
    Write-Host " INFO: This is not an HP machine.. " -BackgroundColor DarkRed
    Write-Host "`n"
}