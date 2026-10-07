@echo off
REM Builds ONLY the full (universal) release APK - no debug, no profile, no
REM per-ABI splits, no AAB - and copies it out as SuikaMovie-<version>.apk.
setlocal enabledelayedexpansion
cd /d "%~dp0"

set VERSION=
for /f "tokens=2 delims=: " %%a in ('findstr /b /c:"version:" pubspec.yaml') do (
  if not defined VERSION set VERSION=%%a
)
for /f "tokens=1 delims=+" %%a in ("%VERSION%") do set VERSION=%%a

call flutter pub get || exit /b 1
call flutter build apk --release || exit /b 1

if not exist dist mkdir dist
copy /y "build\app\outputs\flutter-apk\app-release.apk" "dist\SuikaMovie-%VERSION%.apk" >nul || exit /b 1
echo.
echo Done: dist\SuikaMovie-%VERSION%.apk
endlocal
