$ErrorActionPreference = "Stop"

Write-Host "=========================================="
Write-Host "       USEYI Monitor Setup"
Write-Host "=========================================="
Write-Host ""

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Flutter was not found in PATH." -ForegroundColor Red
    Write-Host "Install Flutter, add Flutter\bin to PATH, then reopen VS Code."
    exit 1
}

flutter --version
Write-Host ""
Write-Host "Creating Android and iOS project folders..."
flutter create --platforms=android,ios .

Write-Host ""
Write-Host "Installing USEYI Monitor packages..."
flutter pub get

Write-Host ""
Write-Host "=========================================="
Write-Host "Setup completed successfully!"
Write-Host "=========================================="
Write-Host ""
Write-Host "Android test:"
Write-Host "  flutter devices"
Write-Host "  flutter run"
Write-Host ""
Write-Host "iOS builds require macOS + Xcode."
