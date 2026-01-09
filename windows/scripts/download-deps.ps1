# Download Dependencies Script
# Downloads Node.js and Git for Windows to bundle with the installer

param(
    [string]$OutputDir = "..\..\..\deps",
    [string]$NodeVersion = "20.18.1",
    [string]$GitVersion = "2.47.1"
)

$ErrorActionPreference = "Stop"

# Create output directories
$nodeDir = Join-Path $OutputDir "nodejs"
$gitDir = Join-Path $OutputDir "git"

New-Item -ItemType Directory -Force -Path $nodeDir | Out-Null
New-Item -ItemType Directory -Force -Path $gitDir | Out-Null

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Claude Code Dependency Downloader" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Download Node.js
Write-Host "[1/3] Downloading Node.js v$NodeVersion..." -ForegroundColor Yellow
$nodeUrl = "https://nodejs.org/dist/v$NodeVersion/node-v$NodeVersion-win-x64.zip"
$nodeZip = Join-Path $env:TEMP "node.zip"

try {
    Invoke-WebRequest -Uri $nodeUrl -OutFile $nodeZip -UseBasicParsing
    Write-Host "      Extracting Node.js..." -ForegroundColor Gray
    Expand-Archive -Path $nodeZip -DestinationPath $env:TEMP -Force

    # Move contents to nodejs directory
    $extractedDir = Join-Path $env:TEMP "node-v$NodeVersion-win-x64"
    Get-ChildItem -Path $extractedDir | Copy-Item -Destination $nodeDir -Recurse -Force
    Remove-Item -Path $extractedDir -Recurse -Force
    Remove-Item -Path $nodeZip -Force

    Write-Host "      Node.js downloaded successfully!" -ForegroundColor Green
} catch {
    Write-Host "      ERROR: Failed to download Node.js: $_" -ForegroundColor Red
    exit 1
}

# Download Git for Windows (Portable)
Write-Host "[2/3] Downloading Git for Windows v$GitVersion..." -ForegroundColor Yellow
$gitUrl = "https://github.com/git-for-windows/git/releases/download/v$GitVersion.windows.1/PortableGit-$GitVersion-64-bit.7z.exe"
$gitExe = Join-Path $env:TEMP "PortableGit.7z.exe"

try {
    Invoke-WebRequest -Uri $gitUrl -OutFile $gitExe -UseBasicParsing
    Write-Host "      Extracting Git (this may take a while)..." -ForegroundColor Gray

    # Extract using 7z self-extracting archive
    Start-Process -FilePath $gitExe -ArgumentList "-o`"$gitDir`" -y" -Wait -NoNewWindow

    Remove-Item -Path $gitExe -Force

    Write-Host "      Git downloaded successfully!" -ForegroundColor Green
} catch {
    Write-Host "      ERROR: Failed to download Git: $_" -ForegroundColor Red
    exit 1
}

# Install Claude Code to a local directory for bundling
Write-Host "[3/3] Setting up Claude Code..." -ForegroundColor Yellow
$npmPath = Join-Path $nodeDir "npm.cmd"
$env:PATH = "$nodeDir;$env:PATH"

try {
    # We don't pre-install Claude Code; it will be installed during NSIS setup
    # or we can include it in node_modules
    Write-Host "      Claude Code will be installed during setup." -ForegroundColor Gray
    Write-Host "      Setup complete!" -ForegroundColor Green
} catch {
    Write-Host "      WARNING: Could not setup Claude Code: $_" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Dependencies downloaded successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Contents:" -ForegroundColor White
Write-Host "  - Node.js v$NodeVersion -> $nodeDir" -ForegroundColor Gray
Write-Host "  - Git v$GitVersion -> $gitDir" -ForegroundColor Gray
Write-Host ""
Write-Host "Next step: Run the NSIS compiler to create the installer." -ForegroundColor Yellow
