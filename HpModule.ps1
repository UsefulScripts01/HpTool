$progressPreference = "SilentlyContinue"

function Get-HpModule {
    Invoke-WebRequest -Uri "https://hpia.hpcloud.hp.com/downloads/cmsl/hp-cmsl-1.6.7.exe" -OutFile "C:\Windows\Temp\HpModule.exe"
    Start-Process -FilePath "C:\Windows\Temp\HpModule.exe" -Wait -ArgumentList "/silent /norestart"
    Get-Command -Module "*HP*"
    Start-Process -FilePath "https://developers.hp.com/hp-client-management/doc/client-management-script-library"
    Remove-Item -Path "C:\Windows\Temp\HpModule.exe" -Force
}
Get-HpModule

Exit
