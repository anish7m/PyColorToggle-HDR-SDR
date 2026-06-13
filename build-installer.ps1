[CmdletBinding()]
param(
    [switch]$SkipDependencyInstall,
    [switch]$SkipInstaller
)

$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ProjectRoot

function Get-InnoCompiler {
    $iscc = Get-Command iscc.exe -ErrorAction SilentlyContinue
    if ($iscc) {
        return $iscc.Source
    }

    $knownPaths = @(
        "$env:LOCALAPPDATA\Programs\Inno Setup 6\ISCC.exe",
        "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
        "$env:ProgramFiles\Inno Setup 6\ISCC.exe"
    )

    foreach ($path in $knownPaths) {
        if ($path -and (Test-Path -LiteralPath $path)) {
            return $path
        }
    }

    return $null
}

if (-not $SkipDependencyInstall) {
    python -m pip install --upgrade pip
    python -m pip install --upgrade -r Requirements.txt pyinstaller
}

Remove-Item -LiteralPath "$ProjectRoot\build" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -LiteralPath "$ProjectRoot\dist" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -LiteralPath "$ProjectRoot\installer-dist" -Recurse -Force -ErrorAction SilentlyContinue

python -m PyInstaller --noconfirm .\PyColorToggle-HDR-SDR.spec

if ($SkipInstaller) {
    Write-Host "Portable app built at: $ProjectRoot\dist\PyColorToggle-HDR-SDR"
    return
}

$isccPath = Get-InnoCompiler
if (-not $isccPath) {
    throw "Inno Setup 6 was not found. Install it with: winget install JRSoftware.InnoSetup"
}

& $isccPath .\installer.iss

Write-Host "Installer built in: $ProjectRoot\installer-dist"
