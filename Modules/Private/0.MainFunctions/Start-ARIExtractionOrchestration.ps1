function Start-ARIExtractionOrchestration {
    Param($ManagementGroup, $Subscriptions, $SubscriptionID, $ResourceGroup, $SecurityCenter, $SkipAdvisory, $IncludeTags, $TagKey, $TagValue, $SkipAPIs, $SkipVMDetails, $Automation, $Debug)
    if ($Debug.IsPresent)
        {
            $DebugPreference = 'Continue'
            $ErrorActionPreference = 'Continue'
        }
    else
        {
            $ErrorActionPreference = "silentlycontinue"
        }

    $GraphData = Start-ARIGraphExtraction -ManagementGroup $ManagementGroup -Subscriptions $Subscriptions -SubscriptionID $SubscriptionID -ResourceGroup $ResourceGroup -SecurityCenter $SecurityCenter -SkipAdvisory $SkipAdvisory -IncludeTags $IncludeTags -TagKey $TagKey -TagValue $TagValue -Debug $Debug

    $Resources = $GraphData.Resources
    $ResourceContainers = $GraphData.ResourceContainers
    $Advisories = $GraphData.Advisories
    $Security = $GraphData.Security
    $Retirements = $GraphData.Retirements

    Clear-Variable -Name GraphData

    $ResourcesCount = [string]$Resources.Count
    $AdvisoryCount = [string]$Advisories.Count
    $SecCenterCount = [string]$Security.Count

    if(!$SkipAPIs.IsPresent)
        {
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Getting API Resources.')
            $APIResults = Get-ARIAPIResources -Subscriptions $Subscriptions -AzureEnvironment $AzureEnvironment -SkipPolicy $SkipPolicy -Debug $Debug
            $Resources += $APIResults.ResourceHealth
            $Resources += $APIResults.ManagedIdentities
            $Resources += $APIResults.AdvisorScore
            $Resources += $APIResults.ReservationRecomen
            $PolicyAssign = $APIResults.PolicyAssign
            $PolicyDef = $APIResults.PolicyDef
            $PolicySetDef = $APIResults.PolicySetDef
        }

    $PolicyCount = [string]$PolicyAssign.policyAssignments.Count

    if (!$SkipVMDetails.IsPresent)
        {
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Getting VM Quota Details.')

            $VMQuotas = Get-AriVMQuotas -Subscriptions $Subscriptions -Resources $Resources -Debug $Debug

            $Resources += $VMQuotas

            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Getting VM SKU Details.')

            $VMSkuDetails = Get-ARIVMSkuDetails -Resources $Resources -Debug $Debug

            $Resources += $VMSkuDetails

        }

    $ReturnData = [PSCustomObject]@{
        Resources = $Resources
        Quotas = $VMQuotas
        ResourceContainers = $ResourceContainers
        Advisories = $Advisories
        ResourcesCount = $ResourcesCount
        AdvisoryCount = $AdvisoryCount
        SecCenterCount = $SecCenterCount
        Security = $Security
        Retirements = $Retirements
        PolicyAssign = $PolicyAssign
        PolicyDef = $PolicyDef
        PolicySetDef = $PolicySetDef
    }

    return $ReturnData
}