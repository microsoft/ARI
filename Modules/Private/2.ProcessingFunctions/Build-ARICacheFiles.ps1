function Build-ARICacheFiles {
    Param($ReportCache, $DataActive, $JobNames,$Debug)
    if ($Debug.IsPresent)
        {
            $DebugPreference = 'Continue'
            $ErrorActionPreference = 'Continue'
        }
    else
        {
            $ErrorActionPreference = "silentlycontinue"
        }
    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Checking Cache Folder.')

    Write-Progress -activity $DataActive -Status "Processing Jobs" -PercentComplete 50

    $Lops = $JobNames.count
    $Counter = 0

    Foreach ($Job in $JobNames)
        {
            $c = (($ReportCounter / $Lops) * 100)
            $c = [math]::Round($c)
            Write-Progress -Id 1 -activity "Building Cache Files" -Status "$c% Complete." -PercentComplete $c

            $NewJobName = ($Job -replace 'ResourceJob_','')
            $TempJob = Receive-Job -Name $Job
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Resource Job '+ $NewJobName +' Returned: ' + ($TempJob.values | Where-Object {$_ -ne $null}).Count + ' Resources')
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