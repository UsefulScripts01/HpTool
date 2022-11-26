Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/UsefulScripts01/HpModule/main/HpModule.ps1'))

function Get-LaptopSoftpaq {
    $CmslPath = Test-Path -Path "C:\Program Files\WindowsPowerShell\HP.CMSL.UninstallerData"
    if ($CmslPath -notmatch "True") {
        Invoke-WebRequest -Uri "https://hpia.hpcloud.hp.com/downloads/cmsl/hp-cmsl-1.6.7.exe" -OutFile "C:\Windows\Temp\HpModule.exe"
        Start-Process -FilePath "C:\Windows\Temp\HpModule.exe" -Wait -ArgumentList "/verysilent /norestart"
        Remove-Item -Path "C:\Windows\Temp\HpModule.exe" -Force
        #Start-Process -FilePath "https://developers.hp.com/hp-client-management/doc/client-management-script-library"
    }
    
    $TestPath = Test-Path -Path "C:\SOFTPAQ"
    if ($TestPath -match "False") {
        New-Item -Name "SOFTPAQ" -ItemType Directory -Path "C:\" -Force
    }
    $OsVer = (Get-ComputerInfo).OSDisplayVersion
    $CsModel = (Get-ComputerInfo).CsModel
    New-Item -Name $CsModel -ItemType Directory -Path "C:\SOFTPAQ\" -Force
    $Path = "C:\SOFTPAQ\$CsModel\"
    Invoke-Item -Path $Path
    New-HPDriverPack -OSVer $OsVer -Path $Path -RemoveOlder -Overwrite    
}

$progressPreference = "SilentlyContinue"

$Bios = (Get-CimInstance -ClassName win32_computersystem).Manufacturer
if (($Bios -match "HP") -or ($Bios -match "Microsoft")) {
    Get-HpModule
    Get-LaptopSoftpaq
}
else {
    Clear-Host
    Write-Host "`n"
    Write-Host "INFO: This is not an HP machine.." -ForegroundColor White -BackgroundColor DarkGreen
    Write-Host "`n"
}