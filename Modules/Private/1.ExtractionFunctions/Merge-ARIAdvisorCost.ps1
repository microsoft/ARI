<#
.Synopsis
Replaces Resource Graph Advisor cost recommendations with the ones read from the Advisor REST API.

.DESCRIPTION
Resource Graph (advisorresources) keeps Advisor recommendations that Advisor has already retired.
For every subscription whose Advisor REST read succeeded (AdvisorCostRead), the Resource Graph
Cost recommendations of that subscription are removed and the REST ones are added. Subscriptions
whose REST read failed keep their Resource Graph rows. When ResourceGroup is used, only REST rows
of those resource groups are kept.

.Link
https://github.com/microsoft/ARI/Modules/Private/1.ExtractionFunctions/Merge-ARIAdvisorCost.ps1

.COMPONENT
This PowerShell Module is part of Azure Resource Inventory (ARI).

.NOTES
Version: 3.6.16
First Release Date: 17th Nov, 2026
Authors: Robin Pieterse
#>
function Merge-ARIAdvisorCost {
    Param($Advisories, $APIResults, $ResourceGroup)

    $Result = @($Advisories)
    $Swapped = 0

    foreach ($API in $APIResults)
        {
            if (!$API.AdvisorCostRead) { continue }

            $Sub = $API.Subscription
            $Result = @($Result | Where-Object { !($_.subscriptionId -eq $Sub -and $_.properties.category -eq 'Cost') })

            $Rows = @($API.AdvisorCost)
            if (![string]::IsNullOrEmpty($ResourceGroup))
                {
                    $Rows = @($Rows | Where-Object {
                        $RG = ([string]$_.properties.resourceMetadata.resourceId).Split('/')[4]
                        $RG -and $RG -in $ResourceGroup
                    })
                }

            $Result += $Rows
            $Swapped += $Rows.Count
        }

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Advisor cost recommendations swapped to REST: ' + $Swapped)

    return $Result
}
