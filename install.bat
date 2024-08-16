@echo off
echo Copying built files to liquidlauncher installation.
xcopy /E /Y dist %appdata%\CCBlueX\LiquidLauncher\data\gameDir\nextgen\LiquidBounce\themes\femboy > nul
if %errorlevel% neq 0 (
    echo An error occured while copying the files: %errorlevel%
) else (
    echo Copied the files successfully.
)
@echo on