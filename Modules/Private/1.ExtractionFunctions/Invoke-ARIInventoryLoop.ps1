<#
.Synopsis
Module responsible for looping through Azure Resource Graph queries.

.DESCRIPTION
This module is used to loop through Azure Resource Graph queries and retrieve resources in batches.

.Link
https://github.com/microsoft/ARI/Modules/Private/1.ExtractionFunctions/Invoke-ARIInventoryLoop.ps1

.COMPONENT
This PowerShell Module is part of Azure Resource Inventory (ARI).

.NOTES
Version: 3.6.0
First Release Date: 15th Oct, 2024
Authors: Claudio Merola
#>
function Invoke-ARIInventoryLoop {
    param($GraphQuery, $FSubscri, $LoopName)

    Write-Progress -Id 1 -activity 'Azure Inventory' -Status "1% Complete." -PercentComplete 1 -CurrentOperation ('Extracting: ' + $LoopName)
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
                            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Extracting First 1000 '+ $LoopName)
                            $QueryResult = Search-AzGraph -Query $GraphQuery -first 1000 -Subscription $Sub -Debug:$false
                        }
                    catch
                        {
                            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Extracting First 200 ' + $LoopName)
                            $QueryResult = Search-AzGraph -Query $GraphQuery -first 200 -Subscription $Sub -Debug:$false
                        }
                    $LocalResults += $QueryResult
                    while ($QueryResult.SkipToken) {
                        $ReportCounterVar = [string]$ReportCounter
                        try
                            {
                                Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Extracting Next 1000 ' + $LoopName + '. Loop Number: ' + $ReportCounterVar)
                                Write-Progress -Id 1 -activity ('Extracting: ' + $LoopName) -Status "$ReportCounter% Complete." -PercentComplete $ReportCounter
                                $QueryResult = Search-AzGraph -Query $GraphQuery -SkipToken $QueryResult.SkipToken -Subscription $Sub -first 1000 -Debug:$false
                            }
                        catch
                            {
                                Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Extracting Next 200 ' + $LoopName + '. Loop Number: ' + $ReportCounterVar)
                                Write-Progress -Id 1 -activity ('Extracting: ' + $LoopName) -Status "$ReportCounter% Complete." -PercentComplete $ReportCounter
                                $QueryResult = Search-AzGraph -Query $GraphQuery -SkipToken $QueryResult.SkipToken -Subscription $Sub -first 200 -Debug:$false
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
                    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Extracting First 1000 ' + $LoopName)
                    $QueryResult = Search-AzGraph -Query $GraphQuery -first 1000 -Subscription $FSubscri -Debug:$false
                }
            catch
                {
                    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Extracting First 200 ' + $LoopName)
                    $QueryResult = Search-AzGraph -Query $GraphQuery -first 200 -Subscription $FSubscri -Debug:$false
                }

            $LocalResults += $QueryResult
            while ($QueryResult.SkipToken) {
                $ReportCounterVar = [string]$ReportCounter
                try
                    {
                        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Extracting Next 1000 ' + $LoopName + '. Loop Number: ' + $ReportCounterVar)
                        Write-Progress -Id 1 -activity ('Extracting: ' + $LoopName) -Status "$ReportCounter% Complete." -PercentComplete $ReportCounter
                        $QueryResult = Search-AzGraph -Query $GraphQuery -SkipToken $QueryResult.SkipToken -Subscription $FSubscri -first 1000 -Debug:$false
                    }
                catch
                    {
                        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Extracting Next 200 ' + $LoopName + '. Loop Number: ' + $ReportCounterVar)
                        Write-Progress -Id 1 -activity ('Extracting: ' + $LoopName) -Status "$ReportCounter% Complete." -PercentComplete $ReportCounter
                        $QueryResult = Search-AzGraph -Query $GraphQuery -SkipToken $QueryResult.SkipToken -Subscription $FSubscri -first 200 -Debug:$false
                    }
                $LocalResults += $QueryResult
                $ReportCounter ++
            }
        }
        Write-Progress -Id 1 -activity ('Extracting: ' + $LoopName) -Status "100% Complete." -Completed
    return $LocalResults
}