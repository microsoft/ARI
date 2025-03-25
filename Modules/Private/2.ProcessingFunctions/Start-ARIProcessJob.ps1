function Start-ARIProcessJob {
    Param($Resources, $Retirements, $Subscriptions, $InTag, $Unsupported, $Debug)
    if ($Debug.IsPresent)
        {
            $DebugPreference = 'Continue'
            $ErrorActionPreference = 'Continue'
        }
    else
        {
            $ErrorActionPreference = "silentlycontinue"
        }


    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Starting to Create Jobs to Process the Resources.')

    switch ($Resources.count)
    {
        {$_ -le 12500}
            {
                $EnvSizeLooper = 20
            }
        {$_ -gt 12500 -and $_ -le 50000}
            {
                $EnvSizeLooper = 8
            }
        {$_ -gt 50000}
            {
                Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Large Environment Detected.')
                $EnvSizeLooper = 5
                Write-Host ('Jobs will be run in batches to avoid CPU Overload.')
            }
    }

    $ParentPath = (get-item $PSScriptRoot).parent.parent
    $InventoryModulesPath = Join-Path $ParentPath 'Public' 'InventoryModules'
    $ModuleFolders = Get-ChildItem -Path $InventoryModulesPath -Directory

    $JobLoop = 1

    Foreach ($ModuleFolder in $ModuleFolders)
        {
            $ModulePath = Join-Path $ModuleFolder.FullName '*.ps1'
            $ModuleName = $ModuleFolder.Name
            $ModuleFiles = Get-ChildItem -Path $ModulePath

            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Creating Job: '+$ModuleName)

            Start-Job -Name ('ResourceJob_'+$ModuleName) -ScriptBlock {

                $ModuleFiles = $($args[0])
                $Subscriptions = $($args[2])
                $InTag = $($args[3])
                $Resources = $($args[4]) | ConvertFrom-Json
                $Retirements = $($args[5])
                $Task = $($args[6])
                $Unsupported = $($args[10])

                $job = @()

                Foreach ($Module in $ModuleFiles)
                    {
                        $ModuleFileContent = New-Object System.IO.StreamReader($Module.FullName)
                        $ModuleData = $ModuleFileContent.ReadToEnd()
                        $ModuleFileContent.Dispose()
                        $ModName = $Module.Name.replace(".ps1","")

                        New-Variable -Name ('ModRun' + $ModName)
                        New-Variable -Name ('ModJob' + $ModName)

                        Set-Variable -Name ('ModRun' + $ModName) -Value ([PowerShell]::Create()).AddScript($ModuleData).AddArgument($PSScriptRoot).AddArgument($Subscriptions).AddArgument($InTag).AddArgument($Resources).AddArgument($Retirements).AddArgument($Task).AddArgument($null).AddArgument($null).AddArgument($null).AddArgument($Unsupported)

                        Set-Variable -Name ('ModJob' + $ModName) -Value ((get-variable -name ('ModRun' + $ModName)).Value).BeginInvoke()

                        $job += (get-variable -name ('ModJob' + $ModName)).Value
                        Start-Sleep -Milliseconds 100
                        Remove-Variable -Name ModName
                    }

                While ($Job.Runspace.IsCompleted -contains $false) { Start-Sleep -Milliseconds 500 }

                Foreach ($Module in $ModuleFiles)
                    {
                        $ModName = $Module.Name.replace(".ps1","")
                        New-Variable -Name ('ModValue' + $ModName)
                        Set-Variable -Name ('ModValue' + $ModName) -Value (((get-variable -name ('ModRun' + $ModName)).Value).EndInvoke((get-variable -name ('ModJob' + $ModName)).Value))

                        Remove-Variable -Name ('ModRun' + $ModName)
                        Remove-Variable -Name ('ModJob' + $ModName)
                        Start-Sleep -Milliseconds 100
                        Remove-Variable -Name ModName
                    }

                $Hashtable = New-Object System.Collections.Hashtable

                Foreach ($Module in $ModuleFiles)
                    {
                        $ModName = $Module.Name.replace(".ps1","")

                        $Hashtable["$ModName"] = (get-variable -name ('ModValue' + $ModName)).Value

                        Remove-Variable -Name ('ModValue' + $ModName)
                        Start-Sleep -Milliseconds 100

                        Remove-Variable -Name ModName
                    }

                [System.GC]::Collect() | out-null
                Start-Sleep -Milliseconds 50

                $Hashtable

            } -ArgumentList $ModuleFiles, $PSScriptRoot, $Subscriptions, $InTag, ($Resources | ConvertTo-Json -Depth 100), $Retirements, 'Processing', $null, $null, $null, $Unsupported | Out-Null

        if($JobLoop -eq $EnvSizeLooper)
            {
                Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Waiting Batch of Jobs to Complete.')

                $InterJobNames = (Get-Job | Where-Object {$_.name -like 'ResourceJob_*' -and $_.State -eq 'Running'}).Name

                Wait-ARIJob -JobNames $InterJobNames -JobType 'Initial Resource' -LoopTime 5 -Debug $Debug

                $JobNames = (Get-Job | Where-Object {$_.name -like 'ResourceJob_*'}).Name

                Build-ARICacheFiles -ReportCache $ReportCache -DataActive $DataActive -JobNames $JobNames -Debug $Debug

                $JobLoop = 0
            }
        $JobLoop ++

        }
}