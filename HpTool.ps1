<#
    .SYNOPSIS
    A set of simple HP device management tools.

    .DESCRIPTION
    Scripts contain a few simple functions (options) that help IT professionals perform common tasks.

    .NOTES

    .LINK
        https://github.com/UsefulScripts01/HpTool
#>

# Install HP CMSL module
function Get-HpModule {
    if (!(Get-CimInstance -ClassName Win32_InstalledWin32Program).Name.Contains('HP Client Management Script Library')) {
        Invoke-WebRequest -Uri "https://hpia.hpcloud.hp.com/downloads/cmsl/hp-cmsl-1.6.8.exe" -OutFile "C:\Windows\Temp\hpcmsl.exe"
        Start-Process -FilePath "C:\Windows\Temp\hpcmsl.exe" -Wait -ArgumentList "/VERYSILENT"
        Start-Sleep -Seconds 5
        Write-Host "`n"
        Write-Host " HP CMSL has been installed.. " -BackgroundColor DarkGreen
        Write-Host "`n"
    }
    else {
        Write-Host "`n"
        Write-Host " HP CMSL is already installed.. " -BackgroundColor DarkGreen
        Write-Host "`n"
    }
}

# Update Bios
function Update-Bios {
    if (!(Get-BitLockerVolume).VolumeStatus[0].ToString().Equals('FullyDecrypted')) {
        Suspend-BitLocker -MountPoint "C:" -RebootCount 1
    }
    Get-HPBIOSUpdates
    Get-HPBIOSUpdates -Flash -Offline -Force
}

# Install selected drivers
function Get-SelectedDriver {
    # make location for downloaded drivers
    $HpDrivers = Test-Path -Path "C:\Windows\Temp\HpDrivers"
    if ($HpDrivers -match "False") {
        New-Item -ItemType "directory" -Path "C:\Windows\Temp\HpDrivers" -Force
    }
    Set-Location -Path "C:\Windows\Temp\HpDrivers"

    # check available drivers
    $DriverList = Get-SoftpaqList -Category BIOS, Driver | Select-Object -Property id, name, version, Size, ReleaseDate | Out-GridView -Title "Select driver(s):" -OutputMode Multiple
    Write-Host "`n"
    Write-Host " Tool will install the selected drivers. This may take 10-15 minutes. Please wait.. " -BackgroundColor DarkGreen
    Write-Host "`n"

    # download and install selected drivers
    foreach ($Number in $DriverList.id) {
        Get-Softpaq -Number $Number -Overwrite no -Action silentinstall -KeepInvalidSigned
    }

    Write-Host "`n"
    Write-Host " The following drivers have been installed: " -ForegroundColor White -BackgroundColor DarkGreen
    $DriverList | Format-Table -AutoSize

    # remove installation files
    Remove-Item -Path "C:\Windows\Temp\HpDrivers\*" -Recurse -Force

    # disable BitLocker pin for one restart
    if (!(Get-BitLockerVolume).VolumeStatus[0].ToString().Equals('FullyDecrypted')) {
        Suspend-BitLocker -MountPoint "C:" -RebootCount 1
    }
}

# Install applications
function Get-Applications {
    # Install Winget if needed (AppInstaller)
    $WingetVersion = (Get-AppxPackage -AllUsers -Name "Microsoft.DesktopAppInstaller").Version
    if ($WingetVersion -le "1.18") {
        Write-Host "`n"
        Write-Host " Getting Microsoft Winget. Please wait.. " -BackgroundColor DarkGreen
        Write-Host "`n"

        Invoke-WebRequest -Uri "https://github.com/UsefulScripts01/HpTool/raw/main/Res/Winget/Winget.zip" -OutFile "C:\Windows\Temp\Winget.zip"
        Expand-Archive -Path "C:\Windows\Temp\Winget.zip" -DestinationPath "C:\Windows\Temp\" -Force
        Get-ChildItem -Path "C:\Windows\Temp" -Recurse | Unblock-File
        Add-AppxPackage -Path "C:\Windows\Temp\Microsoft.UI.Xaml.2.7.Appx"
        Add-AppxPackage -Path "C:\Windows\Temp\Microsoft.VCLibs.x64.14.00.Desktop.appx"
        Add-AppxPackage -Path "C:\Windows\Temp\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
        Start-Sleep -Seconds 5
        Get-ChildItem -Path C:\Windows\Temp -Include ("*.appx", "*.msixbundle", "*.zip") -Recurse | Remove-Item -Force
    }

    # Install Apps with Winget
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/UsefulScripts01/HpTool/main/Res/Winget/AppList.csv" -OutFile "C:\Windows\Temp\AppList.csv"
    $AppList = Import-Csv -Path "C:\Windows\Temp\AppList.csv" -Header Id, Name | Out-GridView -Title "Select app(s):" -OutputMode Multiple
    $AppList = $AppList.Id
    Write-Host "`n"
    Write-Host " Selected applications wil be installed. Please wait.. " -BackgroundColor DarkGreen
    Write-Host "`n"
    foreach ($App in $AppList) {
        winget install --id $App --silent --accept-package-agreements --accept-source-agreements
        Write-Host "`n"
    } 
    Get-Process -Name "GoogleDriveFS*" | Stop-Process
    Get-Process -Name "ShareX*" | Stop-Process
}

# Windows Updates
function Get-OsUpdate {
    # install PSWindowsUpdate module
    Install-PackageProvider -Name NuGet -Force
    Install-Module -Name PSWindowsUpdate -Force
    Import-Module -Name PSWindowsUpdate -Force

    # windows updates
    Start-Process -FilePath "powershell" -Wait -WindowStyle Normal {
        Write-Host "`n"
        Write-Host " Checking for updates.. " -BackgroundColor DarkGreen
        Write-Host "`n"
        Install-WindowsUpdate -AcceptAll -IgnoreReboot
    }
}

# Disable SED Encryption
function Disable-Encryption {
    # dosable BitLocker
    if (!(Get-BitLockerVolume).VolumeStatus[0].ToString().Equals('FullyDecrypted')) {
        Clear-BitLockerAutoUnlock
        Get-BitLockerVolume | Disable-BitLocker

        # wait for end of the process
        While (!(Get-BitLockerVolume).VolumeStatus[0].ToString().Equals('FullyDecrypted')) {
            Clear-Host
            Get-BitLockerVolume
            Start-Sleep -second 5
        }
    }
}

# Enable BitLocker
function Enable-Encryption {
    if ((Get-BitLockerVolume).VolumeStatus[0].ToString().Equals('FullyDecrypted')) {

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

# Enable BitLocker on selected drive
function Enable-SelectEncryption {
    Clear-Host

    # check if drive C is encrypted
    if (!(Get-BitLockerVolume -MountPoint "C:").VolumeStatus.ToString().Equals('FullyEncrypted')) {
        Write-Host "`n"
        Write-Host " Drive C: is not encrypted! " -BackgroundColor DarkRed
        Write-Host "`n"
    }

    # selct drive
    Write-Host "`n"
    Write-Host " This option will encrypt an additional drive(s) " -BackgroundColor DarkGreen
    $Letter = Read-Host -Prompt " Enter a drive letter"

    # check if the selected drive is decrypted. Disable BitLocker if necessary
    if ((Get-BitLockerVolume -MountPoint $Letter).VolumeStatus.ToString().Equals('FullyDecrypted')) {
        $RecoveryPass = (Get-BitLockerVolume -MountPoint "C:").KeyProtector.RecoveryPassword | Where-Object { $_ }
        Get-BitLockerVolume -MountPoint $Letter | Enable-BitLocker -EncryptionMethod Aes256 -SkipHardwareTest -RecoveryPasswordProtector -RecoveryPassword $RecoveryPass
        Get-BitLockerVolume -MountPoint $Letter | Enable-BitLockerAutoUnlock

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

        # wait for end of the process
        While (!(Get-BitLockerVolume -MountPoint $Letter).VolumeStatus.ToString().Equals('FullyDecrypted')) {
            Get-BitLockerVolume
            Start-Sleep -second 5
        }

        # Get BitLocker recovery pin and store it in the domain
        $RecoveryPass = (Get-BitLockerVolume -MountPoint "C:").KeyProtector.RecoveryPassword | Where-Object { $_ }
        Get-BitLockerVolume -MountPoint $Letter | Enable-BitLocker -EncryptionMethod Aes256 -SkipHardwareTest -RecoveryPasswordProtector -RecoveryPassword $RecoveryPass
        Get-BitLockerVolume -MountPoint $Letter | Enable-BitLockerAutoUnlock

        Get-BitLockerVolume
        Write-Host "`n"
        Write-Host " Encryption in progress on disk $Letter.. " -BackgroundColor DarkGreen
        Write-Host "`n"

    }
}

# Enable LAN / WLAN Auto Switching
function Enable-AutoSwitching {
    if ((Get-ComputerInfo).BiosManufacturer.Equals("HP")) {
        Set-HPBIOSSettingValue -Name "LAN / WLAN Auto Switching" -Value "Enable"
    }
}

# Save error log
function Save-ErrorLog {
    if (!$Error.Count.Equals(0)) {
        $DateTime = Get-Date -Format "dd.MM.yyyy HH:mm"
        foreach ($Entry in $Error) {
            Add-Content -Value "$DateTime - $env:computername - $Entry" -Path "~\Desktop\ErrorLog.log" -Force
        }
        $Error.Clear()
    }
}

<# SNIPPETS
    $HpModule = (Get-Module -ListAvailable -Name "HPCMSL").Name
    if ($HpModule -notmatch "HPCMSL") {
        Install-Module -Name PowerShellGet -Force
        Install-Module -Name HPCMSL -Force -AcceptLicense
        Import-Module -Name HPCMSL -Force
    }

    $Spin = "/-\|"
    while ($true) {
        Write-Host "`b$($spin.Substring($i++%$spin.Length)[0])" -nonewline
        Start-Sleep -Seconds 0.5
    }

    #test
#>




$ProgressPreference = "SilentlyContinue"
Clear-Host

# Check PowerShell version
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
if (($Bios -match "HP") -or ($Bios -match "Hewlett-Packard") -or ($Bios -match "Microsoft")) {

    while ($Exit -ne "Y") {
        Write-Host "`n"
        Write-Host " SELECT AN OPTION: " -BackgroundColor DarkGreen
        Write-Host "`n"
        Write-Host "1 - Install HP CMSL only"
        Write-Host "`n"
        Write-Host "2 - Update BIOS (OVERWRITE)"
        Write-Host "3 - Download and install HP drivers"
        Write-Host "`n"
        Write-Host "4 - Install Applications"
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
                Save-ErrorLog
            }
            "2" {
                Get-HpModule
                Update-Bios
                Save-ErrorLog
            }
            "3" {
                Get-HpModule
                Get-SelectedDriver
                Save-ErrorLog
            }
            "4" {
                Get-Applications
                Save-ErrorLog
            }
            "6" {
                Get-OsUpdate
                Save-ErrorLog
            }
            "7" {
                Disable-Encryption
                Save-ErrorLog
            }
            "8" {
                Enable-Encryption
                Save-ErrorLog
            }
            "9" {
                Enable-SelectEncryption
                Save-ErrorLog
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
