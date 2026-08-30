@echo off
echo Building Rukmini Khata for Windows...
call flutter build windows --release
echo Creating MSIX Installer...
call flutter pub run msix:create
echo Done! You can find the installer in build/windows/x64/runner/Release/
pause
