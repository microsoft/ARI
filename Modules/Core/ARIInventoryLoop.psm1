<#
.Synopsis
Azure Resource Graph loop module

.DESCRIPTION
This module is use to loop trough the Azure Resource Graph.

.Link
https://github.com/microsoft/ARI/Modules/Core/ARIInventoryLoop.psm1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 4.0.1
First Release Date: 15th Oct, 2024
Authors: Claudio Merola

#>
function Invoke-ResourceInventoryLoop {
    param($GraphQuery,$FSubscri,$LoopName)

    Write-Progress -activity 'Azure Inventory' -Status "10% Complete." -PercentComplete 10 -CurrentOperation ('Extracting: ' + $LoopName)
    $ReportCounter = 1
    $LocalResults = @()
    if($FSubscri.count -gt 200)
        {
            $SubLoop = $FSubscri.count / 200
            $SubLooper = 0
            $NStart = 0
            $NEnd = 200
            while ($SubLooper -lt $SubLoop)
                {
                    $Sub = $FSubscri[$NStart..$NEnd]
                    try
                        {
                            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Extracting First 1000 Resources')
                            $QueryResult = Search-AzGraph -Query $GraphQuery -first 1000 -Subscription $Sub
                        }
                    catch
                        {
                            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Extracting First 200 Resources')
                            $QueryResult = Search-AzGraph -Query $GraphQuery -first 200 -Subscription $Sub
                        }
                    $LocalResults += $QueryResult
                    while ($QueryResult.SkipToken) {
                        $ReportCounterVar = [string]$ReportCounter
                        try
                            {
                                Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Extracting Next 1000 Resources. Loop Number: ' + $ReportCounterVar)
                                $QueryResult = Search-AzGraph -Query $GraphQuery -SkipToken $QueryResult.SkipToken -Subscription $Sub -first 1000
                            }
                        catch
                            {
                                Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Extracting Next 200 Resources. Loop Number: ' + $ReportCounterVar)
                                $QueryResult = Search-AzGraph -Query $GraphQuery -SkipToken $QueryResult.SkipToken -Subscription $Sub -first 200
                            }
                        $LocalResults += $QueryResult
                    }
                    $NStart = $NStart + 200
                    $NEnd = $NEnd + 200
                    $SubLooper ++
                    $ReportCounter ++
                }
        }
    else
        {
            try
                {
                    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Extracting First 1000 Resources')
                    $QueryResult = Search-AzGraph -Query $GraphQuery -first 1000 -Subscription $FSubscri
                }
            catch
                {
                    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Extracting First 200 Resources')
                    $QueryResult = Search-AzGraph -Query $GraphQuery -first 200 -Subscription $FSubscri
                }

            $LocalResults += $QueryResult
            while ($QueryResult.SkipToken) {
                $ReportCounterVar = [string]$ReportCounter
                try
                    {
                        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Extracting Next 1000 Resources. Loop Number: ' + $ReportCounterVar)
                        $QueryResult = Search-AzGraph -Query $GraphQuery -SkipToken $QueryResult.SkipToken -Subscription $FSubscri -first 1000
                    }
                catch
                    {
                        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Extracting Next 200 Resources. Loop Number: ' + $ReportCounterVar)
                        $QueryResult = Search-AzGraph -Query $GraphQuery -SkipToken $QueryResult.SkipToken -Subscription $FSubscri -first 200
                    }
                $LocalResults += $QueryResult
                $ReportCounter ++
            }
        }
    return $LocalResults
}