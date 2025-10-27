@echo off
REM Complete ANTLR Integration - One-Click Setup
echo ========================================
echo MYA Compiler - Complete ANTLR Setup
echo ========================================
echo.

REM Check prerequisites
echo Checking prerequisites...
echo.

REM Check Java
java -version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Java not found!
    echo Please install Java JDK 8+ from: https://www.oracle.com/java/technologies/downloads/
    pause
 exit /b 1
)
echo [OK] Java found

REM Check Git
git --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Git not found!
    echo Please install Git from: https://git-scm.com/
    pause
    exit /b 1
)
echo [OK] Git found

REM Check CMake
cmake --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] CMake not found!
    echo Please install CMake from: https://cmake.org/download/
    pause
    exit /b 1
)
echo [OK] CMake found

REM Check MSBuild
where MSBuild >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] MSBuild not found!
    echo Please run from Visual Studio Developer Command Prompt
    pause
    exit /b 1
)
echo [OK] MSBuild found

echo.
echo All prerequisites satisfied!
echo.
echo Starting ANTLR integration...
echo.

REM Step 1: Setup ANTLR
echo ========================================
echo Step 1: Setting up ANTLR4
echo ========================================
call setup_antlr.bat
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] ANTLR setup failed!
    pause
    exit /b 1
)

echo.
echo ========================================
echo Step 2: Configuring Visual Studio
echo ========================================
powershell -ExecutionPolicy Bypass -File configure_vs_project.ps1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] VS configuration failed!
    pause
    exit /b 1
)

echo.
echo ========================================
echo Step 3: Building Project
echo ========================================
call build.bat release x64
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Build failed!
    pause
    exit /b 1
)

echo.
echo ========================================
echo Step 4: Running Tests
echo ========================================
x64\Release\MYACompiler.exe --test --ast
if %ERRORLEVEL% NEQ 0 (
    echo [WARNING] Tests failed, but integration may be successful
)

echo.
echo ========================================
echo ANTLR Integration Complete!
echo ========================================
echo.
echo You can now:
echo   1. Run: x64\Release\MYACompiler.exe --test --ast
echo   2. Compile: x64\Release\MYACompiler.exe example.mya --parse-tree
echo   3. Open project in Visual Studio and start developing
echo.
echo See ANTLR_INTEGRATION.md for detailed documentation.
echo.
pause
