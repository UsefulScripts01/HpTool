## HpTool

A set of simple HP device management tools.

</hr>

## Description
More info: https://developers.hp.com/hp-client-management/doc/client-management-script-library

</hr>

## Usage

Copy the code from the area below and paste it into PowerShell Admin (or Windows Terminal)

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/UsefulScripts01/HpTool/main/HpTool.ps1'))
```

<img src="Res/Img/PasteCode.png" width="50%" height="50%"></img>

</hr>

## Bios and drivers

2. Update the BIOS to the latest version. This option always overwrites the current BIOS.

3. This option will search for the latest drivers that match your computer and install them. Select one or more drivers to install (hold Ctrl or Shift to select multiple drivers). Wait for the selected drivers to be installed.

<p align="center"><img src="Res/Img/SelectDrivers.png" width="50%" height="50%"></img></p>

More info: https://developers.hp.com/hp-client-management/doc/client-management-script-library

</br>

## Install Applications

4. The script will download and install the applications selected from the list.

More info: https://github.com/microsoft/winget-cli

</br>

## Windows Updates

6. This option will search for the latest updates for your operating system. The script will install and use the PSWindowsUpdate module.

More info: https://www.powershellgallery.com/packages/PSWindowsUpdate

</br>

## BitLocker

7. Remove encryption from all available drives.

8. Enable BitLocker encryption for all drives.

9. Enable BitLocker on the selected drive.

</br>

BitLocker encryption parameters:

* AES-256

* Startup PIN - 112233

* Recovery PIN stored in Active Directory and on the desktop