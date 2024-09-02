function Start-ARIResourceJobs {
    Param ($Resources, $Subscriptions, $InTag, $Unsupported, $Debug)
    if ($Debug.IsPresent)
        {
            $DebugPreference = 'Continue'
            $ErrorActionPreference = 'Continue'
        }
    else
        {
            $ErrorActionPreference = "silentlycontinue"
        }
    switch ($Resources.count)
        {
            {$_ -le 1000}
                {
                    $EnvSizeLooper = 1000
                    $DebugEnvSize = 'Small'
                }
            {$_ -gt 1000 -and $_ -le 30000}
                {
                    $EnvSizeLooper = 5000
                    $DebugEnvSize = 'Medium'
                }
            {$_ -gt 30000 -and $_ -le 60000}
                {
                    $EnvSizeLooper = 10000
                    $DebugEnvSize = 'Large'
                    Write-Host $DebugEnvSize -NoNewline -ForegroundColor Green
                    Write-Host (' Size Environment Identified.')
                    Write-Host ('Jobs will be run in batches to avoid CPU Overload.')
                }
            {$_ -gt 60000}
                {
                    $EnvSizeLooper = 5000
                    $DebugEnvSize = 'Enormous'
                    Write-Host $DebugEnvSize -NoNewline -ForegroundColor Green
                    Write-Host (' Size Environment Identified.')
                    Write-Host ('Jobs will be run in batches to prevent CPU Overload.')
                }
        }
        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Starting Processing Jobs in '+ $DebugEnvSize +' Mode.')

        $Loop = $Resources.count / $EnvSizeLooper
        $Loop = [math]::ceiling($Loop)
        $Looper = 0
        $Limit = 0
        $JobLoop = 1

        $ResourcesCount = [string]$Resources.count
        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Total Resources Being Processed: '+ $ResourcesCount)

        while ($Looper -lt $Loop) {
            $Looper ++

            $Resource = $Resources | Select-Object -First $EnvSizeLooper -Skip $Limit

            $ResourceCount = [string]$Resource.count
            $LoopCountStr = [string]$Looper
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Resources Being Processed in ResourceJob_'+ $LoopCountStr + ': ' + $ResourceCount)

            Start-Job -Name ('ResourceJob_'+$Looper) -ScriptBlock {

                $Job = @()

                $Subscriptions = $($args[2])
                $InTag = $($args[3])
                $Resource = $($args[4])
                $Task = $($args[5])
                $Unsupported = $($args[9])

                if($($args[1]) -like '*\*')
                    {
                        $Modules = Get-ChildItem -Path ($($args[1]) + '\Scripts\*.ps1') -Recurse
                    }
                else
                    {
                        $Modules = Get-ChildItem -Path ($($args[1]) + '/Scripts/*.ps1') -Recurse
                    }

                $job = @()

                $Modules | ForEach-Object {
                    $ModName = $_.Name.replace(".ps1","")
                    $ModuSeq0 = New-Object System.IO.StreamReader($_.FullName)
                    $ModuSeq = $ModuSeq0.ReadToEnd()
                    $ModuSeq0.Dispose()
                    Start-Sleep -Milliseconds 250

                    New-Variable -Name ('ModRun' + $ModName)
                    New-Variable -Name ('ModJob' + $ModName)

                    Set-Variable -Name ('ModRun' + $ModName) -Value ([PowerShell]::Create()).AddScript($ModuSeq).AddArgument($PSScriptRoot).AddArgument($Subscriptions).AddArgument($InTag).AddArgument($Resource).AddArgument($Task).AddArgument($null).AddArgument($null).AddArgument($null).AddArgument($Unsupported)

                    Set-Variable -Name ('ModJob' + $ModName) -Value ((get-variable -name ('ModRun' + $ModName)).Value).BeginInvoke()

                    $job += (get-variable -name ('ModJob' + $ModName)).Value
                    Start-Sleep -Milliseconds 250
                    Clear-Variable -Name ModName
                }

                while ($Job.Runspace.IsCompleted -contains $false) { Start-Sleep -Milliseconds 1000 }

                $Modules | ForEach-Object {
                    $ModName = $_.Name.replace(".ps1","")
                    Start-Sleep -Milliseconds 250

                    New-Variable -Name ('ModValue' + $ModName)
                    Set-Variable -Name ('ModValue' + $ModName) -Value (((get-variable -name ('ModRun' + $ModName)).Value).EndInvoke((get-variable -name ('ModJob' + $ModName)).Value))

                    Clear-Variable -Name ('ModRun' + $ModName)
                    Clear-Variable -Name ('ModJob' + $ModName)
                    Start-Sleep -Milliseconds 250
                    Clear-Variable -Name ModName
                }

                [System.GC]::GetTotalMemory($true) | out-null

                $Hashtable = New-Object System.Collections.Hashtable

                $Modules | ForEach-Object {
                    $ModName = $_.Name.replace(".ps1","")
                    Start-Sleep -Milliseconds 250

                    $Hashtable["$ModName"] = (get-variable -name ('ModValue' + $ModName)).Value

                    Clear-Variable -Name ('ModValue' + $ModName)
                    Start-Sleep -Milliseconds 100

                    Clear-Variable -Name ModName
                }

                [System.GC]::GetTotalMemory($true) | out-null

            $Hashtable
            } -ArgumentList $null, $PSScriptRoot, $Subscriptions, $InTag, $Resource, 'Processing', $null, $null, $null, $Unsupported | Out-Null
            $Limit = $Limit + $EnvSizeLooper
            Start-Sleep -Milliseconds 250
            if($DebugEnvSize -in ('Large','Enormous') -and $JobLoop -eq 5)
                {
                    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Waiting Batch of Jobs to Complete.')

                    $coun = 0

                    $InterJobNames = (Get-Job | Where-Object {$_.name -like 'ResourceJob_*' -and $_.State -eq 'Running'}).Name

                    while (get-job -Name $InterJobNames | Where-Object { $_.State -eq 'Running' }) {
                        $jb = get-job -Name $InterJobNames
                        $c = (((($jb.count - ($jb | Where-Object { $_.State -eq 'Running' }).Count)) / $jb.Count) * 100)
                        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'initial Jobs Running: '+[string]($jb | Where-Object { $_.State -eq 'Running' }).count)
                        $c = [math]::Round($coun)
                        Write-Progress -Id 1 -activity "Processing Initial Resource Jobs" -Status "$coun% Complete." -PercentComplete $coun
                        Start-Sleep -Seconds 15
                    }
                    $JobLoop = 0
                }
            $JobLoop ++
            [System.GC]::GetTotalMemory($true) | out-null
        }
    return $DebugEnvSize
}


function Start-ARIAutResourceJob {
    Param($Resources,$Subscriptions,$InTag,$Unsupported)
    Write-Output ('Starting Resources Processes')
    Write-Output ('Total Resources Being Analyzed: '+$Resources.count)

    $Modules = Get-ChildItem -Path ($PSScriptRoot + '/Scripts/*.ps1') -Recurse

    $SmaResources = @{}

    foreach ($Module in $Modules) 
        {

            if($RunDebug)
                {
                    Write-Output ''
                    Write-Output ('DEBUG - Running Module: '+$Module)
                }

            $ModName = $Module.Name.replace(".ps1","")
            $ModuSeq0 = New-Object System.IO.StreamReader($Module.FullName)
            $ModuSeq = $ModuSeq0.ReadToEnd()
            $ModuSeq0.Dispose()

            $ScriptBlock = [Scriptblock]::Create($ModuSeq)

            $SmaResources[$ModName] = Invoke-Command -ScriptBlock $ScriptBlock -ArgumentList $PSScriptRoot, $Subscriptions, $InTag, $Resources, 'Processing', $null, $null, $null, $Unsupported

            Start-Sleep -Milliseconds 100

        }
    return $SmaResources
}


function Get-ARIUnsupportedData {
    Param($Debug)
    if ($Debug.IsPresent)
        {
            $DebugPreference = 'Continue'
            $ErrorActionPreference = 'Continue'
        }
    else
        {
            $ErrorActionPreference = "silentlycontinue"
        }
    if($PSScriptRoot -like '*\*')
        {
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Validating file: '+$PSScriptRoot + '\Extras\Support.json')
            $ModuSeq0 = New-Object System.IO.StreamReader($PSScriptRoot + '\Extras\Support.json')
        }
    else
        {
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Validating file: '+$PSScriptRoot + '/Extras/Support.json')
            $ModuSeq0 = New-Object System.IO.StreamReader($PSScriptRoot + '/Extras/Support.json')
        }
    $ModuSeq = $ModuSeq0.ReadToEnd()
    $ModuSeq0.Dispose()

    $Unsupported = $ModuSeq | ConvertFrom-Json

    return $Unsupported
}