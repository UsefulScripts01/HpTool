## Description
More info: https://developers.hp.com/hp-client-management/doc/client-management-script-library

## Usage

1. Copy the code from the area below and paste it into PowerShell Admin (or Windows Terminal).
![PasteCode](images/PasteCode.png)

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/UsefulScripts01/HpModule/main/HpModule.ps1'))
```
