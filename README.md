# HP Client Management Script Library (CMSL)

### Description

This script install HP Client Management Script Library (CMSL)

### Usage

Copy the code from the area below and paste it into PowerShell Admin (or Windows Terminal).

### Get-HpCmsl

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/UsefulScripts01/HpModule/main/Get-HpCmsl.ps1'))
```

### Get-LaptopSoftpaq (for current machine)

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/UsefulScripts01/HpModule/main/Get-LaptopSoftpaq.ps1'))
```

### Enable LAN / WLAN Auto Switching

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/UsefulScripts01/HpModule/main/Enable-AutoSwitching.ps1'))
```


### More Information

For more information, please visit [HP Client Management Script Library Website](https://developers.hp.com/hp-client-management/doc/client-management-script-library).
