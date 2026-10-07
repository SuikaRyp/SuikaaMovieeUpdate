@echo off
REM Builds a full (universal) APK - release by default, debug with: build_apk.bat debug
REM No profile, no per-ABI splits, no AAB. Output: dist\SuikaMovie-<version>[-debug].apk
setlocal enabledelayedexpansion
cd /d "%~dp0"

set MODE=%1
if "%MODE%"=="" set MODE=release
set SUFFIX=
if /i "%MODE%"=="debug" set SUFFIX=-debug
if /i not "%MODE%"=="debug" if /i not "%MODE%"=="release" (
  echo Usage: build_apk.bat [release^|debug]
  exit /b 1
)

set VERSION=
for /f "tokens=2 delims=: " %%a in ('findstr /b /c:"version:" pubspec.yaml') do (
  if not defined VERSION set VERSION=%%a
)
for /f "tokens=1 delims=+" %%a in ("%VERSION%") do set VERSION=%%a

call flutter pub get || exit /b 1
call flutter build apk --%MODE% || exit /b 1

if not exist dist mkdir dist
copy /y "build\app\outputs\flutter-apk\app-%MODE%.apk" "dist\SuikaMovie-%VERSION%%SUFFIX%.apk" >nul || exit /b 1
echo.
echo Done: dist\SuikaMovie-%VERSION%%SUFFIX%.apk
endlocal
