function Start-ARIProcessOrchestration {
    Param($Subscriptions, $Resources, $Retirements, $File, $InTag, $Automation, $DataActive, $Debug)
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

        Clear-Variable -Name Resources
        Clear-ARIMemory

        $JobNames = (Get-Job | Where-Object {$_.name -like 'ResourceJob_*'}).Name

        Wait-ARIJob -JobNames $JobNames -DataActive $DataActive -JobType 'Resource' -LoopTime 5 -Debug $Debug

        Build-ARICacheFiles -ReportCache $ReportCache -DataActive $DataActive -JobNames $JobNames -Debug $Debug

}