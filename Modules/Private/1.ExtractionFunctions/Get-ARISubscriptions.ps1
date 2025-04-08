<#
.Synopsis
Module responsible for retrieving Azure subscriptions.

.DESCRIPTION
This module retrieves Azure subscriptions for a given tenant or specific subscription IDs.

.Link
https://github.com/microsoft/ARI/Modules/Private/1.ExtractionFunctions/Get-ARISubscriptions.ps1

.COMPONENT
This PowerShell Module is part of Azure Resource Inventory (ARI).

.NOTES
Version: 3.6.0
First Release Date: 15th Oct, 2024
Authors: Claudio Merola
#>
function Get-ARISubscriptions {
    Param ($TenantID,$SubscriptionID,$PlatOS)
    if($PlatOS -eq 'Azure CloudShell')
        {
            $Subscriptions = Get-AzSubscription -WarningAction SilentlyContinue -Debug:$false
            
            if ($SubscriptionID)
                {
                    if($SubscriptionID.count -gt 1)
                        {
                            $Subscriptions = $Subscriptions | Where-Object { $_.ID -in $SubscriptionID }
                        }
                    else
                        {
                            $Subscriptions = $Subscriptions | Where-Object { $_.ID -eq $SubscriptionID }
                        }
                }
        }
    else
        {
            Write-Host "Extracting Subscriptions from Tenant $TenantID"
            try
                {
                    $Subscriptions = Get-AzSubscription -TenantId $TenantID -WarningAction SilentlyContinue -Debug:$false
                }
            catch
                {
                    Write-Host ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+ " Error: $_")
                    return
                }
            
            if ($SubscriptionID)
                {
                    if($SubscriptionID.count -gt 1)
                        {
                            $Subscriptions = $Subscriptions | Where-Object { $_.ID -in $SubscriptionID }
                        }
                    else
                        {
                            $Subscriptions = $Subscriptions | Where-Object { $_.ID -eq $SubscriptionID }
                        }
                }
        }
    
    return $Subscriptions
}