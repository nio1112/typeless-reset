param(
    [string]$Version = "0.0.1"
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$python = Join-Path $repoRoot ".venv\Scripts\python.exe"
$distDir = Join-Path $repoRoot "dist"
$buildDir = Join-Path $repoRoot "build"
$releaseDir = Join-Path $repoRoot "release"
$stagingDir = Join-Path $releaseDir "TypelessReset"
$exeName = "TypelessReset.exe"
$assetName = "typeless-reset-$Version-windows-x64.zip"
$assetPath = Join-Path $releaseDir $assetName

if (-not (Test-Path $python)) {
    throw "Python virtual environment not found at $python"
}

foreach ($dir in @($distDir, $buildDir, $releaseDir)) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir | Out-Null
    }
}

& $python -m ensurepip --upgrade | Out-Host
& $python -m pip install --upgrade pip pyinstaller | Out-Host

if (Test-Path $stagingDir) {
    Remove-Item -LiteralPath $stagingDir -Recurse -Force
}

if (Test-Path $assetPath) {
    Remove-Item -LiteralPath $assetPath -Force
}

& $python -m PyInstaller `
    --noconfirm `
    --clean `
    --windowed `
    --onefile `
    --name "TypelessReset" `
    "gui.py" | Out-Host

New-Item -ItemType Directory -Path $stagingDir | Out-Null
Copy-Item -LiteralPath (Join-Path $distDir $exeName) -Destination (Join-Path $stagingDir $exeName)
Copy-Item -LiteralPath (Join-Path $repoRoot "README.md") -Destination (Join-Path $stagingDir "README.md")
Copy-Item -LiteralPath (Join-Path $repoRoot "README.en.md") -Destination (Join-Path $stagingDir "README.en.md")
Copy-Item -LiteralPath (Join-Path $repoRoot "LICENSE") -Destination (Join-Path $stagingDir "LICENSE")

Compress-Archive -Path (Join-Path $stagingDir "*") -DestinationPath $assetPath -Force

Write-Host ""
Write-Host "Built asset: $assetPath" -ForegroundColor Green
