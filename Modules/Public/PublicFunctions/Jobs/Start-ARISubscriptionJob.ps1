<#
.Synopsis
Module for Subscriptions

.DESCRIPTION
This script process and creates the Subscriptions sheet based on resources and subscriptions the resources belong.

.Link
https://github.com/azureinventory/ARI/Extras/ARISubInv.psm1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 4.0.1
First Release Date: 15th Oct, 2024
Authors: Claudio Merola

#>
function Start-ARISubscriptionJob {
    param($Subscriptions,$Resources)

    $ResTable = $Resources | Where-Object { $_.type -notin ('microsoft.advisor/recommendations','ARI/VM/Quotas','ARI/VM/Size','ARI/VM/SKU' )}
    $resTable2 = $ResTable | Select-Object id, Type, location, resourcegroup, subscriptionid
    $ResTable3 = $ResTable2 | Group-Object -Property type, location, resourcegroup, subscriptionid

    $tmp = foreach ($ResourcesSUB in $ResTable3) {
        $ResourceDetails = $ResourcesSUB.name -split ","
        $SubName = $Subscriptions | Where-Object { $_.Id -eq ($ResourceDetails[3] -replace (" ", "")) }

        $obj = @{
            'Subscription'   = $SubName.Name;
            'Resource Group' = $ResourceDetails[2];
            'Location'       = $ResourceDetails[1];
            'Resource Type'  = $ResourceDetails[0];
            'Resources'      = $ResourcesSUB.Count
        }
        $obj
    }
    $tmp
}
