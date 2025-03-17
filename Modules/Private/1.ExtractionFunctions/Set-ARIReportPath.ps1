function Set-ARIReportPath {
    Param($PlatOS, $ReportDir, $Automation)

    if ($PlatOS -eq 'Azure CloudShell')
        {
            $DefaultPath = if($ReportDir) {$ReportDir} else {"$HOME/AzureResourceInventory/"}
            $DiagramCache = if($ReportDir) {$ReportDir} else {"$HOME/AzureResourceInventory/DiagramCache/"}
            if($ReportDir)
            {
                try
                    {
                        Resolve-Path $ReportDir -ErrorAction STOP
                        if ($ReportDir -notmatch '/$')
                            {
                                $ReportDir = $ReportDir + '/'
                            }
                    }
                catch
                    {
                        Write-Output "ReportDir Parameter must contain the full path."
                        Exit
                    }
            }
        }
    elseif ($PlatOS -eq 'PowerShell Unix')
        {
            $DefaultPath = if($ReportDir) {$ReportDir} else {"$HOME/AzureResourceInventory/"}
            $DiagramCache = if($ReportDir) {$ReportDir} else {"$HOME/AzureResourceInventory/DiagramCache/"}
            if($ReportDir)
            {
                try
                    {
                        Resolve-Path $ReportDir -ErrorAction STOP
                        if ($ReportDir -notmatch '/$')
                            {
                                $ReportDir = $ReportDir + '/'
                            }
                    }
                catch
                    {
                        Write-Output "ReportDir Parameter must contain the full path."
                        Exit
                    }
            }
        }
    elseif ($PlatOS -eq 'PowerShell Desktop')
        {
            $DefaultPath = if($ReportDir) {$ReportDir} else {"C:\AzureResourceInventory\"}
            $DiagramCache = if($ReportDir) {($ReportDir+'DiagramCache\')} else {"C:\AzureResourceInventory\DiagramCache\"}
            if($ReportDir)
            {
                try
                    {
                        Resolve-Path $ReportDir -ErrorAction STOP
                        if ($ReportDir -notlike '*\')
                            {
                                $ReportDir = $ReportDir + '\'
                            }
                    }
                catch
                    {
                        Write-Output "ReportDir Parameter must contain the full path."
                        Exit
                    }
            }
        }
    
    if ($Automation.IsPresent)
        {
            $DefaultPath = "$HOME/AzureResourceInventory/"
            $DiagramCache = "$HOME/AzureResourceInventory/DiagramCache/"
        }

    $ReportPath = @{
        'DefaultPath' = $DefaultPath;
        'DiagramCache' = $DiagramCache;
    }
    
    return $ReportPath
}