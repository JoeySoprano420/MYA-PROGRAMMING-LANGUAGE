# PowerShell script to update MYA PROGRAMMING.vcxproj with new files

$projFile = "MYA PROGRAMMING.vcxproj"
$backupFile = "$projFile.backup"

Write-Host "Updating $projFile..." -ForegroundColor Cyan

# Create backup
Copy-Item -Path $projFile -Destination $backupFile -Force
Write-Host "Backup created: $backupFile" -ForegroundColor Yellow

# Read and parse XML
try {
  [xml]$xml = Get-Content $projFile

    # Find the last ItemGroup or create one before the final Import
    $lastItemGroup = $xml.Project.ItemGroup | Select-Object -Last 1
    
    if ($lastItemGroup -eq $null) {
    Write-Host "No ItemGroup found, creating new ones..." -ForegroundColor Yellow
    } else {
   Write-Host "Found existing ItemGroup elements" -ForegroundColor Green
    }

# Create namespace manager
    $ns = New-Object System.Xml.XmlNamespaceManager($xml.NameTable)
    $ns.AddNamespace("ms", "http://schemas.microsoft.com/developer/msbuild/2003")

    # Add ClCompile item (source files)
    $itemGroupCompile = $xml.CreateElement("ItemGroup", "http://schemas.microsoft.com/developer/msbuild/2003")
    $clCompile = $xml.CreateElement("ClCompile", "http://schemas.microsoft.com/developer/msbuild/2003")
    $clCompile.SetAttribute("Include", "MYACompiler.cpp")
    $itemGroupCompile.AppendChild($clCompile) | Out-Null

    # Add ClInclude item (header files)
    $itemGroupInclude = $xml.CreateElement("ItemGroup", "http://schemas.microsoft.com/developer/msbuild/2003")
 $clInclude = $xml.CreateElement("ClInclude", "http://schemas.microsoft.com/developer/msbuild/2003")
  $clInclude.SetAttribute("Include", "MYAIndentationPreprocessor.h")
    $itemGroupInclude.AppendChild($clInclude) | Out-Null

  # Add None items (other files)
    $itemGroupNone = $xml.CreateElement("ItemGroup", "http://schemas.microsoft.com/developer/msbuild/2003")
    
$none1 = $xml.CreateElement("None", "http://schemas.microsoft.com/developer/msbuild/2003")
    $none1.SetAttribute("Include", "MYA.g4")
    $itemGroupNone.AppendChild($none1) | Out-Null
    
    $none2 = $xml.CreateElement("None", "http://schemas.microsoft.com/developer/msbuild/2003")
    $none2.SetAttribute("Include", "README.md")
    $itemGroupNone.AppendChild($none2) | Out-Null

    # Find the last Import element and insert before it
    $imports = $xml.Project.Import
    $lastImport = $imports | Select-Object -Last 1

    if ($lastImport -ne $null) {
        $xml.Project.InsertBefore($itemGroupCompile, $lastImport) | Out-Null
     $xml.Project.InsertBefore($itemGroupInclude, $lastImport) | Out-Null
        $xml.Project.InsertBefore($itemGroupNone, $lastImport) | Out-Null
 Write-Host "Added new ItemGroup elements before final Import" -ForegroundColor Green
    }

    # Save the updated XML
    $xml.Save((Resolve-Path $projFile).Path)

    Write-Host "`nProject file updated successfully!" -ForegroundColor Green
    Write-Host "`nAdded files:" -ForegroundColor Cyan
    Write-Host "  [Source] MYACompiler.cpp" -ForegroundColor White
    Write-Host "  [Header] MYAIndentationPreprocessor.h" -ForegroundColor White
    Write-Host "  [Grammar] MYA.g4" -ForegroundColor White
    Write-Host "  [Documentation] README.md" -ForegroundColor White
    
    Write-Host "`nPlease reload the project in Visual Studio." -ForegroundColor Yellow

} catch {
    Write-Host "Error updating project file: $_" -ForegroundColor Red
    Copy-Item -Path $backupFile -Destination $projFile -Force
    Write-Host "Restored backup file." -ForegroundColor Yellow
}
