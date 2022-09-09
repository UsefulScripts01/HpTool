# HP Client Management Script Library (CMSL)

## Description

This script install HP Client Management Script Library (CMSL)

## Usage

Copy the code from the area below and paste it into PowerShell Admin (or Windows Terminal).

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/UsefulScripts01/HpModule/main/HpModule.ps1'))
```

## More Information

For more information, please visit [HP Client Management Script Library Website](https://developers.hp.com/hp-client-management/doc/client-management-script-library).
