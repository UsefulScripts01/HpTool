Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/UsefulScripts01/HpModule/main/HpModule.ps1'))

function Get-LaptopSoftpaq {
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
    Get-LaptopSoftpaq
}
else {
    Clear-Host
    Write-Host "`n"
    Write-Host "INFO: This is not an HP machine.." -ForegroundColor White -BackgroundColor DarkGreen
    Write-Host "`n"
}