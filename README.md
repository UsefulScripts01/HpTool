# RemoveBloatware

## Description

This script removes all useless APPX applications from the operating system.

List of deleted applications

```
BingWeather
GetHelp
Getstarted
Microsoft3DViewer
MicrosoftOfficeHub
MicrosoftSolitaireCollection
MixedReality.Portal
MSPaint
Office.OneNote
People
SkypeApp
StorePurchaseApp
Wallet
WindowsAlarms
WindowsCamera
windowscommunicationsapps
WindowsFeedbackHub
WindowsMaps
WindowsSoundRecorder
Xbox.TCUI
XboxApp
XboxGameOverlay
XboxGamingOverlay
XboxIdentityProvider
XboxSpeechToTextOverlay
YourPhone
ZuneMusic
ZuneVideo
Todos
ParentalControl
```

## Usage

- Download RemoveBloatware.ps1 and StartScript.bat to the same location.
- Run the StartScript.bat file as Administrator (context menu)

Or

- Copy the code from the area below and paste it into PowerShell Admin (or Windows Terminal).

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/UsefulScripts01/RemoveBloatware/main/RemoveBloatware.ps1'))
```

## Restore APPX

All APPX applications can be restored with the command below:

```powershell
Get-AppxPackage -AllUsers "GetHelp*" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
```
