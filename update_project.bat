@echo off
REM Update the Visual Studio project file to include MYA compiler files

echo Updating MYA PROGRAMMING.vcxproj...

REM Read the existing project file
set PROJ_FILE="MYA PROGRAMMING.vcxproj"

REM Create a backup
copy /Y %PROJ_FILE% "%PROJ_FILE%.backup" >nul

REM Use PowerShell to update the XML
powershell -Command ^
"$xml = [xml](Get-Content '%PROJ_FILE%'); ^
$ns = New-Object System.Xml.XmlNamespaceManager($xml.NameTable); ^
$ns.AddNamespace('ms', 'http://schemas.microsoft.com/developer/msbuild/2003'); ^
$itemGroup = $xml.CreateElement('ItemGroup', 'http://schemas.microsoft.com/developer/msbuild/2003'); ^
$clCompile = $xml.CreateElement('ClCompile', 'http://schemas.microsoft.com/developer/msbuild/2003'); ^
$clCompile.SetAttribute('Include', 'MYACompiler.cpp'); ^
$itemGroup.AppendChild($clCompile) | Out-Null; ^
$xml.Project.AppendChild($itemGroup) | Out-Null; ^
$itemGroup2 = $xml.CreateElement('ItemGroup', 'http://schemas.microsoft.com/developer/msbuild/2003'); ^
$clInclude = $xml.CreateElement('ClInclude', 'http://schemas.microsoft.com/developer/msbuild/2003'); ^
$clInclude.SetAttribute('Include', 'MYAIndentationPreprocessor.h'); ^
$itemGroup2.AppendChild($clInclude) | Out-Null; ^
$xml.Project.AppendChild($itemGroup2) | Out-Null; ^
$itemGroup3 = $xml.CreateElement('ItemGroup', 'http://schemas.microsoft.com/developer/msbuild/2003'); ^
$none1 = $xml.CreateElement('None', 'http://schemas.microsoft.com/developer/msbuild/2003'); ^
$none1.SetAttribute('Include', 'MYA.g4'); ^
$itemGroup3.AppendChild($none1) | Out-Null; ^
$none2 = $xml.CreateElement('None', 'http://schemas.microsoft.com/developer/msbuild/2003'); ^
$none2.SetAttribute('Include', 'README.md'); ^
$itemGroup3.AppendChild($none2) | Out-Null; ^
$xml.Project.AppendChild($itemGroup3) | Out-Null; ^
$xml.Save((Resolve-Path '%PROJ_FILE%'))"

if %ERRORLEVEL% EQU 0 (
    echo Project file updated successfully!
 echo Added:
    echo   - MYACompiler.cpp
    echo   - MYAIndentationPreprocessor.h
    echo   - MYA.g4
    echo   - README.md
) else (
    echo Error updating project file.
    copy /Y "%PROJ_FILE%.backup" %PROJ_FILE% >nul
    echo Restored backup.
)

pause
