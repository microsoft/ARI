<#
.Synopsis
Process orchestration for Azure Resource Inventory

.DESCRIPTION
This module orchestrates the processing of resources for Azure Resource Inventory.

.Link
https://github.com/microsoft/ARI/Modules/Private/0.MainFunctions/Start-ARIProcessOrchestration.ps1

.COMPONENT
This PowerShell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.6.0
First Release Date: 15th Oct, 2024
Authors: Claudio Merola

#>

function Start-ARIProcessOrchestration {
    Param($Subscriptions, $Resources, $Retirements, $File, $InTag, $Automation, $Debug)
    if ($Debug.IsPresent)
        {
            $DebugPreference = 'Continue'
            $ErrorActionPreference = 'Continue'
        }
    else
        {
            $ErrorActionPreference = "silentlycontinue"
        }

        Write-Progress -activity 'Azure Inventory' -Status "21% Complete." -PercentComplete 21 -CurrentOperation "Starting to process extracted data.."

        <######################################################### IMPORT UNSUPPORTED VERSION LIST ######################################################################>

        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Importing List of Unsupported Versions.')

        $Unsupported = Get-ARIUnsupportedData -Debug $Debug

        <######################################################### RESOURCE GROUP JOB ######################################################################>

        if ($Automation.IsPresent)
            {
                Write-Output ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Processing Resources in Automation Mode')

                Start-ARIAutProcessJob -Resources $Resources -Retirements $Retirements -Subscriptions $Subscriptions -InTag $InTag -Unsupported $Unsupported -Debug $Debug
            }
        else
            {
                Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Processing Resources in Regular Mode')

                Start-ARIProcessJob -Resources $Resources -Retirements $Retirements -Subscriptions $Subscriptions -InTag $InTag -Unsupported $Unsupported -Debug $Debug
            }

        <############################################################## RESOURCES PROCESSING #############################################################>

        $JobNames = (Get-Job | Where-Object {$_.name -like 'ResourceJob_*'}).Name

        if(![string]::IsNullOrEmpty($JobNames))
            {
                Wait-ARIJob -JobNames $JobNames -JobType 'Resource' -LoopTime 5 -Debug $Debug

                Build-ARICacheFiles -ReportCache $ReportCache -JobNames $JobNames -Debug $Debug
            }

        Write-Progress -activity 'Azure Inventory' -Status "60% Complete." -PercentComplete 60 -CurrentOperation "Completed Data Processing Phase.."

}