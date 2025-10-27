@echo off
REM Quick fix for build error - Exclude ANTLR compiler from build
echo Excluding MYACompilerANTLR.cpp from build...

powershell -ExecutionPolicy Bypass -Command ^
"$project = 'MYA PROGRAMMING.vcxproj'; ^
[xml]$xml = Get-Content $project; ^
$ns = New-Object System.Xml.XmlNamespaceManager($xml.NameTable); ^
$ns.AddNamespace('ms', 'http://schemas.microsoft.com/developer/msbuild/2003'); ^
$compileItems = $xml.Project.ItemGroup.ClCompile | Where-Object { $_.Include -eq 'MYACompilerANTLR.cpp' }; ^
foreach ($item in $compileItems) { ^
  if (-not $item.ExcludedFromBuild) { ^
        $excluded = $xml.CreateElement('ExcludedFromBuild', 'http://schemas.microsoft.com/developer/msbuild/2003'); ^
$excluded.InnerText = 'true'; ^
    $item.AppendChild($excluded) | Out-Null; ^
    } else { ^
        $item.ExcludedFromBuild = 'true'; ^
    } ^
}; ^
$xml.Save((Resolve-Path $project).Path); ^
Write-Host 'MYACompilerANTLR.cpp excluded from build.' -ForegroundColor Green"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo Success! MYACompilerANTLR.cpp is now excluded from build.
    echo You can now build the project successfully.
    echo.
    echo To re-enable it after ANTLR integration, run:
    echo   enable_antlr_compiler.bat
) else (
    echo.
    echo Error: Failed to exclude file. Please exclude manually:
    echo   1. Right-click MYACompilerANTLR.cpp in Visual Studio
    echo   2. Properties -^> Configuration Properties -^> General
    echo   3. Set "Excluded From Build" to "Yes"
)

pause
