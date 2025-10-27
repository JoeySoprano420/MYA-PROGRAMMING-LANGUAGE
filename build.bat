@echo off
REM MYA Compiler Build Script
REM Automates the build process for the MYA language compiler

echo ========================================
echo MYA Compiler Build Script
echo ========================================
echo.

REM Check for Visual Studio
where MSBuild >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Error: MSBuild not found. Please run from Visual Studio Developer Command Prompt.
    pause
    exit /b 1
)

REM Configuration
set CONFIG=Release
set PLATFORM=x64
set PROJECT="MYA PROGRAMMING.vcxproj"

echo Configuration: %CONFIG%
echo Platform: %PLATFORM%
echo.

REM Parse command line arguments
:parse_args
if "%1"=="" goto build
if /i "%1"=="debug" set CONFIG=Debug
if /i "%1"=="release" set CONFIG=Release
if /i "%1"=="x86" set PLATFORM=Win32
if /i "%1"=="x64" set PLATFORM=x64
if /i "%1"=="clean" goto clean
if /i "%1"=="rebuild" goto rebuild
if /i "%1"=="help" goto help
shift
goto parse_args

:help
echo Usage: build.bat [options]
echo.
echo Options:
echo   debug        Build in Debug configuration
echo   release      Build in Release configuration (default)
echo   x86   Build for x86 platform
echo   x64       Build for x64 platform (default)
echo   clean        Clean build artifacts
echo   rebuild      Clean and rebuild
echo   help     Show this help message
echo.
echo Examples:
echo   build.bat    Build Release x64
echo   build.bat debug           Build Debug x64
echo   build.bat release x86     Build Release x86
echo   build.bat rebuild    Clean and rebuild
echo.
pause
exit /b 0

:clean
echo Cleaning build artifacts...
MSBuild %PROJECT% /t:Clean /p:Configuration=%CONFIG% /p:Platform=%PLATFORM% /v:minimal
if %ERRORLEVEL% NEQ 0 (
    echo Clean failed!
    pause
    exit /b 1
)
echo Clean completed successfully.
echo.
goto end

:rebuild
echo Rebuilding project...
MSBuild %PROJECT% /t:Rebuild /p:Configuration=%CONFIG% /p:Platform=%PLATFORM% /v:minimal
if %ERRORLEVEL% NEQ 0 (
    echo Rebuild failed!
 pause
exit /b 1
)
echo Rebuild completed successfully.
echo.
goto show_output

:build
echo Building project...
echo Command: MSBuild %PROJECT% /p:Configuration=%CONFIG% /p:Platform=%PLATFORM%
echo.

MSBuild %PROJECT% /p:Configuration=%CONFIG% /p:Platform=%PLATFORM% /v:minimal /consoleloggerparameters:Summary

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ========================================
    echo Build FAILED!
    echo ========================================
    pause
    exit /b 1
)

echo.
echo ========================================
echo Build SUCCESS!
echo ========================================
echo.

:show_output
REM Show output location
set OUTPUT_DIR=%PLATFORM%\%CONFIG%
echo Output directory: %OUTPUT_DIR%
echo Executable: %OUTPUT_DIR%\MYACompiler.exe
echo.

REM Check if executable exists
if exist "%OUTPUT_DIR%\MYACompiler.exe" (
    echo Binary size:
    dir "%OUTPUT_DIR%\MYACompiler.exe" | find "MYACompiler.exe"
    echo.
    
    echo To run the compiler:
    echo   cd "%OUTPUT_DIR%"
    echo   MYACompiler.exe --test --tokens --scope-ledger
    echo   MYACompiler.exe example.mya --tokens
    echo.
) else (
    echo Warning: Executable not found at expected location.
    echo Check build output for errors.
    echo.
)

:end
echo Build script completed.
pause
