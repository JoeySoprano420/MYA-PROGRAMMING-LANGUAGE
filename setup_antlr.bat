@echo off
REM ANTLR4 Setup Script for MYA Compiler
REM This script downloads and sets up ANTLR4 for the project

echo ========================================
echo MYA Compiler - ANTLR4 Setup
echo ========================================
echo.

REM Configuration
set ANTLR_VERSION=4.13.1
set ANTLR_JAR=antlr-%ANTLR_VERSION%-complete.jar
set ANTLR_URL=https://www.antlr.org/download/%ANTLR_JAR%
set ANTLR_DIR=%CD%\antlr4
set ANTLR_RUNTIME_DIR=%ANTLR_DIR%\runtime
set ANTLR_CPP_DIR=%ANTLR_RUNTIME_DIR%\Cpp

echo ANTLR Version: %ANTLR_VERSION%
echo Installation Directory: %ANTLR_DIR%
echo.

REM Create directories
if not exist "%ANTLR_DIR%" mkdir "%ANTLR_DIR%"
if not exist "%ANTLR_RUNTIME_DIR%" mkdir "%ANTLR_RUNTIME_DIR%"

REM Step 1: Download ANTLR4 JAR
echo [1/5] Downloading ANTLR4 JAR...
if exist "%ANTLR_DIR%\%ANTLR_JAR%" (
    echo ANTLR JAR already exists, skipping download.
) else (
    echo Downloading from %ANTLR_URL%...
    powershell -Command "Invoke-WebRequest -Uri '%ANTLR_URL%' -OutFile '%ANTLR_DIR%\%ANTLR_JAR%'"
    
if %ERRORLEVEL% NEQ 0 (
        echo Error: Failed to download ANTLR JAR.
        echo Please download manually from https://www.antlr.org/download.html
        pause
        exit /b 1
    )
    echo ANTLR JAR downloaded successfully.
)
echo.

REM Step 2: Download ANTLR4 C++ Runtime
echo [2/5] Downloading ANTLR4 C++ Runtime...
if exist "%ANTLR_CPP_DIR%" (
    echo C++ Runtime already exists, skipping download.
) else (
    echo Cloning ANTLR4 repository...
    git clone --depth 1 --branch %ANTLR_VERSION% https://github.com/antlr/antlr4.git "%ANTLR_RUNTIME_DIR%\temp"
    
    if %ERRORLEVEL% NEQ 0 (
        echo Error: Failed to clone ANTLR repository.
     echo Please ensure Git is installed and try again.
      pause
        exit /b 1
  )
    
    REM Move C++ runtime to correct location
    move "%ANTLR_RUNTIME_DIR%\temp\runtime\Cpp" "%ANTLR_CPP_DIR%"
    rmdir /s /q "%ANTLR_RUNTIME_DIR%\temp"
    echo C++ Runtime downloaded successfully.
)
echo.

REM Step 3: Build ANTLR4 C++ Runtime
echo [3/5] Building ANTLR4 C++ Runtime...
if exist "%ANTLR_CPP_DIR%\build\Release\antlr4-runtime.lib" (
    echo Runtime library already built, skipping.
) else (
    cd "%ANTLR_CPP_DIR%"
    
    REM Create build directory
    if not exist "build" mkdir build
    cd build
    
    echo Running CMake...
    cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_STANDARD=14
    
    if %ERRORLEVEL% NEQ 0 (
 echo Error: CMake configuration failed.
     echo Please ensure CMake is installed and in PATH.
        cd "%CD%"
    pause
     exit /b 1
    )
  
    echo Building runtime (this may take a few minutes)...
    cmake --build . --config Release
    
    if %ERRORLEVEL% NEQ 0 (
        echo Error: Build failed.
        cd "%CD%"
     pause
        exit /b 1
    )
    
    cd "%CD%"
    echo Runtime built successfully.
)
echo.

REM Step 4: Generate MYA Lexer and Parser
echo [4/5] Generating MYA Lexer and Parser...
if not exist "generated" mkdir generated

echo Generating C++ files from MYA.g4...
java -jar "%ANTLR_DIR%\%ANTLR_JAR%" -Dlanguage=Cpp -visitor -no-listener -o generated MYA.g4

if %ERRORLEVEL% NEQ 0 (
    echo Error: Failed to generate lexer/parser.
  echo Please ensure Java is installed and in PATH.
pause
    exit /b 1
)

echo Lexer and Parser generated successfully.
echo Generated files in: %CD%\generated
echo.

REM Step 5: Create configuration file
echo [5/5] Creating configuration file...
echo # ANTLR4 Configuration for MYA Compiler > antlr4_config.txt
echo ANTLR_VERSION=%ANTLR_VERSION% >> antlr4_config.txt
echo ANTLR_JAR=%ANTLR_DIR%\%ANTLR_JAR% >> antlr4_config.txt
echo ANTLR_CPP_INCLUDE=%ANTLR_CPP_DIR%\runtime\src >> antlr4_config.txt
echo ANTLR_CPP_LIB=%ANTLR_CPP_DIR%\build\Release >> antlr4_config.txt
echo GENERATED_DIR=%CD%\generated >> antlr4_config.txt
echo.

echo ========================================
echo ANTLR4 Setup Complete!
echo ========================================
echo.
echo Next Steps:
echo 1. Add generated files to Visual Studio project
echo 2. Configure include directories:
echo    - %ANTLR_CPP_DIR%\runtime\src
echo    - %CD%\generated
echo.
echo 3. Configure library directories:
echo    - %ANTLR_CPP_DIR%\build\Release
echo.
echo 4. Link against: antlr4-runtime.lib
echo.
echo Run 'configure_vs_project.bat' to automatically configure Visual Studio.
echo.

pause
