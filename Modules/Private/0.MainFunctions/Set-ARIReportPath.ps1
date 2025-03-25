function Set-ARIReportPath {
    Param($ReportDir)

    if ($ReportDir)
        {
            $DefaultPath = $ReportDir
            $DiagramCache = Join-Path $ReportDir "DiagramCache"
            $ReportCache = Join-Path $ReportDir 'ReportCache'
        }
    elseif (Resolve-Path -Path 'C:\')
        {
            $DefaultPath = Join-Path "C:\" "AzureResourceInventory"
            $DiagramCache = Join-Path "C:\" "AzureResourceInventory" "DiagramCache"
            $ReportCache = Join-Path "C:\" "AzureResourceInventory"'ReportCache'
        }
    else
        {
            $DefaultPath = Join-Path "$HOME" "AzureResourceInventory"
            $DiagramCache = Join-Path "$HOME" "AzureResourceInventory" "DiagramCache"
            $ReportCache = Join-Path "$HOME" "AzureResourceInventory" 'ReportCache'
        }

    $ReportPath = @{
        'DefaultPath' = $DefaultPath;
        'DiagramCache' = $DiagramCache;;
        'ReportCache' = $ReportCache
    }
    
    return $ReportPath
}