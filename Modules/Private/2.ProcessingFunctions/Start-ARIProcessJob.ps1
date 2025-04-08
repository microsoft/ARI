<#
.Synopsis
Module responsible for starting the processing jobs for Azure Resources.

.DESCRIPTION
This module creates and manages jobs to process Azure Resources in batches based on the environment size. It ensures efficient resource processing and avoids CPU overload.

.Link
https://github.com/microsoft/ARI/Modules/Private/2.ProcessingFunctions/Start-ARIProcessJob.ps1

.COMPONENT
This PowerShell Module is part of Azure Resource Inventory (ARI).

.NOTES
Version: 3.6.0
First Release Date: 15th Oct, 2024
Authors: Claudio Merola
#>

function Start-ARIProcessJob {
    Param($Resources, $Retirements, $Subscriptions, $DefaultPath, $Heavy, $InTag, $Unsupported)

    Write-Progress -activity 'Azure Inventory' -Status "22% Complete." -PercentComplete 22 -CurrentOperation "Creating Jobs to Process Data.."

    switch ($Resources.count)
    {
        {$_ -le 12500}
            {
                Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Regular Size Environment. Jobs will be run in parallel.')
                $EnvSizeLooper = 20
            }
        {$_ -gt 12500 -and $_ -le 50000}
            {
                Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Medium Size Environment. Jobs will be run in batches of 8.')
                $EnvSizeLooper = 8
            }
        {$_ -gt 50000}
            {
                Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Large Environment Detected.')
                $EnvSizeLooper = 5
                Write-Host ('Jobs will be run in small batches to avoid CPU and Memory Overload.') -ForegroundColor Red
            }
    }

    if ($Heavy.IsPresent -or $InTag.IsPresent)
        {
            Write-Host ('Heavy Mode or InTag Mode Detected. Jobs will be run in small batches to avoid CPU and Memory Overload.') -ForegroundColor Red
            $EnvSizeLooper = 5
        }

    $ParentPath = (get-item $PSScriptRoot).parent.parent
    $InventoryModulesPath = Join-Path $ParentPath 'Public' 'InventoryModules'
    $ModuleFolders = Get-ChildItem -Path $InventoryModulesPath -Directory

    $JobLoop = 1
    $TotalFolders = $ModuleFolders.count

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Converting Resource data to JSON for Jobs')
    $NewResources = ($Resources | ConvertTo-Json -Depth 40 -Compress)

    Remove-Variable -Name Resources
    Clear-ARIMemory

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Starting to Create Jobs to Process the Resources.')

    #Foreach ($ModuleFolder in $ModuleFolders)
    $ModuleFolders | ForEach-Object -Process {
            $ModuleFolder = $_
            $ModulePath = Join-Path $ModuleFolder.FullName '*.ps1'
            $ModuleName = $ModuleFolder.Name
            $ModuleFiles = Get-ChildItem -Path $ModulePath

            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Creating Job: '+$ModuleName)

            $c = (($JobLoop / $TotalFolders) * 100)
            $c = [math]::Round($c)
            Write-Progress -Id 1 -activity "Creating Jobs" -Status "$c% Complete." -PercentComplete $c

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

                $Hashtable

            } -ArgumentList $ModuleFiles, $PSScriptRoot, $Subscriptions, $InTag, $NewResources , $Retirements, 'Processing', $null, $null, $null, $Unsupported | Out-Null

        if($JobLoop -eq $EnvSizeLooper)
            {
                Write-Host 'Waiting Batch Jobs' -ForegroundColor Cyan -NoNewline
                Write-Host '. This step may take several minutes to finish' -ForegroundColor Cyan

                $InterJobNames = (Get-Job | Where-Object {$_.name -like 'ResourceJob_*' -and $_.State -eq 'Running'}).Name

                Wait-ARIJob -JobNames $InterJobNames -JobType 'Resource Batch' -LoopTime 5

                $JobNames = (Get-Job | Where-Object {$_.name -like 'ResourceJob_*'}).Name

                Build-ARICacheFiles -DefaultPath $DefaultPath -ReportCache $ReportCache -JobNames $JobNames

                $JobLoop = 0
            }
        $JobLoop ++

        }

        Remove-Variable -Name NewResources
        Clear-ARIMemory
}