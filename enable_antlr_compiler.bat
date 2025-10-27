@echo off
REM Re-enable ANTLR compiler in build (after ANTLR integration)
echo Re-enabling MYACompilerANTLR.cpp in build...

powershell -ExecutionPolicy Bypass -Command ^
"$project = 'MYA PROGRAMMING.vcxproj'; ^
[xml]$xml = Get-Content $project; ^
$ns = New-Object System.Xml.XmlNamespaceManager($xml.NameTable); ^
$ns.AddNamespace('ms', 'http://schemas.microsoft.com/developer/msbuild/2003'); ^
$compileItems = $xml.Project.ItemGroup.ClCompile | Where-Object { $_.Include -eq 'MYACompilerANTLR.cpp' }; ^
foreach ($item in $compileItems) { ^
    if ($item.ExcludedFromBuild) { ^
$item.RemoveChild($item.ExcludedFromBuild) | Out-Null; ^
    } ^
}; ^
$antlrCompiler = $xml.Project.ItemGroup.ClCompile | Where-Object { $_.Include -eq 'MYACompiler.cpp' }; ^
foreach ($item in $antlrCompiler) { ^
    if (-not $item.ExcludedFromBuild) { ^
        $excluded = $xml.CreateElement('ExcludedFromBuild', 'http://schemas.microsoft.com/developer/msbuild/2003'); ^
        $excluded.InnerText = 'true'; ^
        $item.AppendChild($excluded) | Out-Null; ^
  } else { ^
        $item.ExcludedFromBuild = 'true'; ^
    } ^
}; ^
$xml.Save((Resolve-Path $project).Path); ^
Write-Host 'MYACompilerANTLR.cpp enabled, MYACompiler.cpp excluded.' -ForegroundColor Green"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo Success! ANTLR compiler is now active.
    echo The original MYACompiler.cpp has been excluded.
    echo.
    echo Build the project to use the ANTLR-integrated compiler.
) else (
    echo.
  echo Error: Failed to switch compilers. Please do it manually in Visual Studio.
)

pause
