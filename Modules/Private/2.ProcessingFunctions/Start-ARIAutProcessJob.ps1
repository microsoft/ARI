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
Version: 3.6.0
First Release Date: 15th Oct, 2024
Authors: Claudio Merola
#>

function Start-ARIAutProcessJob {
    Param($Resources, $Retirements, $Subscriptions, $InTag, $Unsupported)

    $ParentPath = (get-item $PSScriptRoot).parent.parent
    $InventoryModulesPath = Join-Path $ParentPath 'Public' 'InventoryModules'
    $Modules = Get-ChildItem -Path $InventoryModulesPath -Directory
    $NewResources = ($Resources | ConvertTo-Json -Depth 40 -Compress)
    $SmaResources = @{} # Initialize the hashtable to store results

    Foreach ($ModuleFolder in $Modules)
        {
            $ModulePath = Join-Path $ModuleFolder.FullName '*.ps1'
            $ModuleName = $ModuleFolder.Name
            $ModuleFiles = Get-ChildItem -Path $ModulePath

            Start-ThreadJob -Name ('ResourceJob_'+$ModuleName) -ScriptBlock {

                $ModuleFiles = $($args[0])
                $Subscriptions = $($args[2])
                $InTag = $($args[3])
                $Resources = $($args[4]) | ConvertFrom-Json
                $Retirements = $($args[5])
                $Unsupported = $($args[10])

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

            } -ArgumentList $ModuleFiles, $PSScriptRoot, $Subscriptions, $InTag, $NewResources, $Retirements, 'Processing', $null, $null, $null, $Unsupported -ThrottleLimit 8 | Out-Null
        }
}