@echo off
echo ===================================================
echo Inkflow Project: Finalize Physical Directory Rename
echo ===================================================
echo This script swaps the physical directory so that:
echo   Physical: c:\Users\Dibya\StudioProjects\inkflow
echo   Junction: c:\Users\Dibya\StudioProjects\flutter_project_app
echo.
echo Please ensure Android Studio, VS Code, and any Dart/Flutter
echo processes are COMPLETELY CLOSED before proceeding.
echo.
pause

set "OLD_DIR=c:\Users\Dibya\StudioProjects\flutter_project_app"
set "NEW_DIR=c:\Users\Dibya\StudioProjects\inkflow"
set "TEMP_DIR=c:\Users\Dibya\StudioProjects\flutter_project_app_temp"

:: 1. Remove the inkflow junction if it currently exists as a junction
if exist "%NEW_DIR%" (
    echo Removing existing junction at %NEW_DIR%...
    rmdir "%NEW_DIR%"
    if errorlevel 1 (
        echo [ERROR] Failed to remove junction. Ensure %NEW_DIR% is not open in another program.
        pause
        exit /b 1
    )
)

:: 2. Rename physical directory flutter_project_app to inkflow
echo Renaming physical directory to %NEW_DIR%...
move "%OLD_DIR%" "%NEW_DIR%"
if errorlevel 1 (
    echo [ERROR] Failed to rename directory. Ensure no files are locked.
    pause
    exit /b 1
)

:: 3. Create backward-compatibility junction from flutter_project_app to inkflow
echo Creating backward-compatibility junction: %OLD_DIR% -> %NEW_DIR%...
mklink /J "%OLD_DIR%" "%NEW_DIR%"
if errorlevel 1 (
    echo [WARNING] Failed to create backward-compatibility junction.
)

echo.
echo Migration successfully completed!
echo Primary project folder is now: %NEW_DIR%
pause
