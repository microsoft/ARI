<#
.Synopsis
Module responsible for creating the local cache files for the report.

.DESCRIPTION
This module receives the job names for the Azure Resources that were processed previously and creates the local cache files that will be used to build the Excel report.

.Link
https://github.com/microsoft/ARI/Modules/Private/2.ProcessingFunctions/Build-ARICacheFiles.ps1

.COMPONENT
This PowerShell Module is part of Azure Resource Inventory (ARI).

.NOTES
Version: 3.6.0
First Release Date: 15th Oct, 2024
Authors: Claudio Merola
#>

function Build-ARICacheFiles {
    Param($DefaultPath, $ReportCache, $JobNames)

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Checking Cache Folder.')

    $Lops = $JobNames.count
    $Counter = 0

    Foreach ($Job in $JobNames)
        {
            $c = (($ReportCounter / $Lops) * 100)
            $c = [math]::Round($c)
            Write-Progress -Id 1 -activity "Building Cache Files" -Status "$c% Complete." -PercentComplete $c

            $NewJobName = ($Job -replace 'ResourceJob_','')
            $TempJob = Receive-Job -Name $Job
            if (![string]::IsNullOrEmpty($TempJob.values))
                {
                    $JobJSONName = ($NewJobName+'.json')
                    $JobFileName = Join-Path $DefaultPath 'ReportCache' $JobJSONName
                    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Creating Cache File: '+ $JobFileName)
                    $TempJob | ConvertTo-Json -Depth 40 | Out-File $JobFileName
                }
            Remove-Job -Name $Job
            Remove-Variable -Name TempJob

            $Counter++

        }
    Clear-ARIMemory
    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Cache Files Created.')
}