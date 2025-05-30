<#
.Synopsis
Module responsible for starting automated processing jobs for Azure Resources.

.DESCRIPTION
This module creates and manages automated thread jobs to process Azure Resources using PowerShell script blocks for efficient execution.

.Link
https://github.com/microsoft/ARI/Modules/Private/2.ProcessingFunctions/Start-ARIAutProcessJob.ps1

.COMPONENT
This PowerShell Module is part of Azure Resource Inventory (ARI).

.NOTES
Version: 3.6.9
First Release Date: 15th Oct, 2024
Authors: Claudio Merola
#>

function Start-ARIAutProcessJob {
    Param($Resources, $Retirements, $Subscriptions, $Heavy, $InTag, $Unsupported)

    $ParentPath = (get-item $PSScriptRoot).parent.parent
    $InventoryModulesPath = Join-Path $ParentPath 'Public' 'InventoryModules'
    $Modules = Get-ChildItem -Path $InventoryModulesPath -Directory
    $NewResources = ($Resources | ConvertTo-Json -Depth 40 -Compress)
    $JobLoop = 1
    Write-Output ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+"Starting ARI Automation Processing Jobs...")

    if ($Heavy.IsPresent -or $InTag.IsPresent)
        {
            Write-Output ('Heavy Mode Detected. Jobs will be run in small batches to avoid CPU and Memory Overload.')
            $EnvSizeLooper = 2
        }
    else
        {
            $EnvSizeLooper = 4
        }

    Foreach ($ModuleFolder in $Modules)
        {
            $ModulePath = Join-Path $ModuleFolder.FullName '*.ps1'
            $ModuleName = $ModuleFolder.Name
            $ModuleFiles = Get-ChildItem -Path $ModulePath
            Write-Output ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+"Starting Job: $ModuleName")

            Start-ThreadJob -Name ('ResourceJob_'+$ModuleName) -ScriptBlock {

                $ModuleFiles = $($args[0])
                $Subscriptions = $($args[2])
                $InTag = $($args[3])
                $Resources = $($args[4]) | ConvertFrom-Json
                $Retirements = $($args[5])
                $Unsupported = $($args[10])
                $SmaResources = @{} # Initialize the hashtable to store results

                Foreach ($Module in $ModuleFiles)
                    {
                        $ModuleFileContent = New-Object System.IO.StreamReader($Module.FullName)
                        $ModuleData = $ModuleFileContent.ReadToEnd()
                        $ModuleFileContent.Dispose()
                        $ModName = $Module.Name.replace(".ps1","")

                        $ScriptBlock = [Scriptblock]::Create($ModuleData)

                        $SmaResources[$ModName] = Invoke-Command -ScriptBlock $ScriptBlock -ArgumentList $PSScriptRoot, $Subscriptions, $InTag, $Resources, $Retirements,'Processing', $null, $null, $null, $Unsupported

                        Start-Sleep -Milliseconds 100

                    }

                $SmaResources

            } -ArgumentList $ModuleFiles, $PSScriptRoot, $Subscriptions, $InTag, $NewResources, $Retirements, 'Processing', $null, $null, $null, $Unsupported | Out-Null

            if($JobLoop -eq $EnvSizeLooper)
                {
                    Write-Output ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Waiting Batch Jobs')

                    Get-Job | Where-Object {$_.name -like 'ResourceJob_*'} | Wait-Job

                    $JobNames = (Get-Job | Where-Object {$_.name -like 'ResourceJob_*'}).Name

                    Start-Sleep -Seconds 5

                    Build-ARICacheFiles -DefaultPath $DefaultPath -JobNames $JobNames

                    $JobLoop = 0
                }
        $JobLoop ++
        }
}