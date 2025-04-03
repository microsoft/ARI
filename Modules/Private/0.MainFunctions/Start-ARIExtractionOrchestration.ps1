<#
.Synopsis
Extraction orchestration for Azure Resource Inventory

.DESCRIPTION
This module orchestrates the extraction of resources for Azure Resource Inventory.

.Link
https://github.com/microsoft/ARI/Modules/Private/0.MainFunctions/Start-ARIExtractionOrchestration.ps1

.COMPONENT
This PowerShell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.6.0
First Release Date: 15th Oct, 2024
Authors: Claudio Merola

#>
function Start-ARIExtractionOrchestration {
    Param($ManagementGroup, $Subscriptions, $SubscriptionID, $SkipPolicy, $ResourceGroup, $SecurityCenter, $SkipAdvisory, $IncludeTags, $TagKey, $TagValue, $SkipAPIs, $SkipVMDetails, $IncludeCosts, $Automation)

    $GraphData = Start-ARIGraphExtraction -ManagementGroup $ManagementGroup -Subscriptions $Subscriptions -SubscriptionID $SubscriptionID -ResourceGroup $ResourceGroup -SecurityCenter $SecurityCenter -SkipAdvisory $SkipAdvisory -IncludeTags $IncludeTags -TagKey $TagKey -TagValue $TagValue

    $Resources = $GraphData.Resources
    $ResourceContainers = $GraphData.ResourceContainers
    $Advisories = $GraphData.Advisories
    $Security = $GraphData.Security
    $Retirements = $GraphData.Retirements

    Remove-Variable -Name GraphData -ErrorAction SilentlyContinue

    $ResourcesCount = [string]$Resources.Count
    $AdvisoryCount = [string]$Advisories.Count
    $SecCenterCount = [string]$Security.Count

    if(!$SkipAPIs.IsPresent)
        {
            Write-Progress -activity 'Azure Inventory' -Status "12% Complete." -PercentComplete 12 -CurrentOperation "Starting API Extraction.."
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Getting API Resources.')
            $APIResults = Get-ARIAPIResources -Subscriptions $Subscriptions -AzureEnvironment $AzureEnvironment -SkipPolicy $SkipPolicy
            $Resources += $APIResults.ResourceHealth
            $Resources += $APIResults.ManagedIdentities
            $Resources += $APIResults.AdvisorScore
            $Resources += $APIResults.ReservationRecomen
            $PolicyAssign = $APIResults.PolicyAssign
            $PolicyDef = $APIResults.PolicyDef
            $PolicySetDef = $APIResults.PolicySetDef
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'API Resource Inventory Finished.')
            Remove-Variable APIResults -ErrorAction SilentlyContinue
        }

    $PolicyCount = [string]$PolicyAssign.policyAssignments.Count

    if ($IncludeCosts.IsPresent) {
        $Costs = Get-ARICostInventory -Subscriptions $Subscriptions -Days 60 -Granularity 'Monthly'
    }

    if (!$SkipVMDetails.IsPresent)
        {
            Write-Host 'Gathering VM Extra Details: ' -NoNewline
            Write-Host 'Quotas' -ForegroundColor Cyan
            Write-Progress -activity 'Azure Inventory' -Status "13% Complete." -PercentComplete 13 -CurrentOperation "Starting VM Details Extraction.."

            $VMQuotas = Get-AriVMQuotas -Subscriptions $Subscriptions -Resources $Resources

            $Resources += $VMQuotas

            Remove-Variable -Name VMQuotas -ErrorAction SilentlyContinue

            Write-Host 'Gathering VM Extra Details: ' -NoNewline
            Write-Host 'Size SKU' -ForegroundColor Cyan

            $VMSkuDetails = Get-ARIVMSkuDetails -Resources $Resources

            $Resources += $VMSkuDetails

            Remove-Variable -Name VMSkuDetails -ErrorAction SilentlyContinue

        }

    $ReturnData = [PSCustomObject]@{
        Resources = $Resources
        Quotas = $VMQuotas
        Costs = $Costs
        ResourceContainers = $ResourceContainers
        Advisories = $Advisories
        ResourcesCount = $ResourcesCount
        AdvisoryCount = $AdvisoryCount
        SecCenterCount = $SecCenterCount
        Security = $Security
        Retirements = $Retirements
        PolicyCount = $PolicyCount
        PolicyAssign = $PolicyAssign
        PolicyDef = $PolicyDef
        PolicySetDef = $PolicySetDef
    }

    return $ReturnData
}