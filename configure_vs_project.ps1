# PowerShell Script to Configure Visual Studio Project for ANTLR4
# Adds include directories, library directories, and generated files

$projectFile = "MYA PROGRAMMING.vcxproj"
$backupFile = "$projectFile.antlr.backup"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Configuring Visual Studio Project for ANTLR4" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Read ANTLR configuration
$config = @{}
if (Test-Path "antlr4_config.txt") {
    Get-Content "antlr4_config.txt" | ForEach-Object {
if ($_ -match '^(.+?)=(.+)$') {
            $config[$matches[1]] = $matches[2]
        }
    }
} else {
    Write-Host "Error: antlr4_config.txt not found." -ForegroundColor Red
    Write-Host "Please run setup_antlr.bat first." -ForegroundColor Yellow
    exit 1
}

# Extract paths
$antlrInclude = $config['ANTLR_CPP_INCLUDE']
$antlrLib = $config['ANTLR_CPP_LIB']
$generatedDir = $config['GENERATED_DIR']

Write-Host "ANTLR Include: $antlrInclude" -ForegroundColor White
Write-Host "ANTLR Library: $antlrLib" -ForegroundColor White
Write-Host "Generated Dir: $generatedDir" -ForegroundColor White
Write-Host ""

# Create backup
Copy-Item -Path $projectFile -Destination $backupFile -Force
Write-Host "Backup created: $backupFile" -ForegroundColor Yellow
Write-Host ""

# Load XML
[xml]$xml = Get-Content $projectFile
$ns = New-Object System.Xml.XmlNamespaceManager($xml.NameTable)
$ns.AddNamespace("ms", "http://schemas.microsoft.com/developer/msbuild/2003")

# Function to add or update element
function Set-PropertyGroupValue {
    param($propertyGroup, $elementName, $value)
    
    $element = $propertyGroup.SelectSingleNode("ms:$elementName", $ns)
    if ($element) {
        if ($element.InnerText -notlike "*$value*") {
            $element.InnerText = $element.InnerText + ";$value"
        }
    } else {
        $newElement = $xml.CreateElement($elementName, "http://schemas.microsoft.com/developer/msbuild/2003")
        $newElement.InnerText = $value
    $propertyGroup.AppendChild($newElement) | Out-Null
    }
}

# Add include directories
Write-Host "Adding include directories..." -ForegroundColor Cyan
$itemDefGroups = $xml.Project.ItemDefinitionGroup

foreach ($group in $itemDefGroups) {
    if ($group.ClCompile) {
        # Add ANTLR include
 Set-PropertyGroupValue $group.ClCompile "AdditionalIncludeDirectories" $antlrInclude
        
        # Add generated files include
     Set-PropertyGroupValue $group.ClCompile "AdditionalIncludeDirectories" $generatedDir
        
        # Set C++ standard
        if (-not $group.ClCompile.LanguageStandard) {
 $langStd = $xml.CreateElement("LanguageStandard", "http://schemas.microsoft.com/developer/msbuild/2003")
         $langStd.InnerText = "stdcpp14"
     $group.ClCompile.AppendChild($langStd) | Out-Null
        }
    }
  
    if ($group.Link) {
 # Add library directory
 Set-PropertyGroupValue $group.Link "AdditionalLibraryDirectories" $antlrLib
        
    # Add library dependency
        Set-PropertyGroupValue $group.Link "AdditionalDependencies" "antlr4-runtime.lib"
    }
}

Write-Host "Include/Library directories configured." -ForegroundColor Green
Write-Host ""

# Add generated source files
Write-Host "Adding generated source files..." -ForegroundColor Cyan

$generatedFiles = @(
    "MYALexer.cpp",
    "MYAParser.cpp"
)

$generatedHeaders = @(
    "MYALexer.h",
    "MYAParser.h",
    "MYABaseVisitor.h",
    "MYAVisitor.h"
)

# Find or create ItemGroups
$compileItemGroup = $xml.Project.ItemGroup | Where-Object { $_.ClCompile } | Select-Object -First 1
$includeItemGroup = $xml.Project.ItemGroup | Where-Object { $_.ClInclude } | Select-Object -First 1

if (-not $compileItemGroup) {
    $compileItemGroup = $xml.CreateElement("ItemGroup", "http://schemas.microsoft.com/developer/msbuild/2003")
    $xml.Project.InsertBefore($compileItemGroup, $xml.Project.Import[-1]) | Out-Null
}

if (-not $includeItemGroup) {
    $includeItemGroup = $xml.CreateElement("ItemGroup", "http://schemas.microsoft.com/developer/msbuild/2003")
    $xml.Project.InsertBefore($includeItemGroup, $xml.Project.Import[-1]) | Out-Null
}

# Add source files
foreach ($file in $generatedFiles) {
 $path = "generated\$file"
    $exists = $compileItemGroup.ClCompile | Where-Object { $_.Include -eq $path }
    
    if (-not $exists) {
   $clCompile = $xml.CreateElement("ClCompile", "http://schemas.microsoft.com/developer/msbuild/2003")
        $clCompile.SetAttribute("Include", $path)
        $compileItemGroup.AppendChild($clCompile) | Out-Null
        Write-Host "  Added: $path" -ForegroundColor White
    }
}

# Add header files
foreach ($file in $generatedHeaders) {
    $path = "generated\$file"
    $exists = $includeItemGroup.ClInclude | Where-Object { $_.Include -eq $path }
    
    if (-not $exists) {
        $clInclude = $xml.CreateElement("ClInclude", "http://schemas.microsoft.com/developer/msbuild/2003")
     $clInclude.SetAttribute("Include", $path)
        $includeItemGroup.AppendChild($clInclude) | Out-Null
        Write-Host "  Added: $path" -ForegroundColor White
    }
}

Write-Host "Generated files added to project." -ForegroundColor Green
Write-Host ""

# Save XML
$xml.Save((Resolve-Path $projectFile).Path)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Configuration Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Reload the project in Visual Studio" -ForegroundColor White
Write-Host "2. Build the project to verify ANTLR integration" -ForegroundColor White
Write-Host "3. Run 'build.bat' to test compilation" -ForegroundColor White
Write-Host ""
Write-Host "If you encounter issues, restore backup: $backupFile" -ForegroundColor Yellow
