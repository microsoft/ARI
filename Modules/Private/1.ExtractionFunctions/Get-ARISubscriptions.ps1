function Get-ARISubscriptions {
    Param ($TenantID,$SubscriptionID)
    Write-Host "Extracting Subscriptions from Tenant $TenantID"
    $Subscriptions = Get-AzSubscription -TenantId $TenantID -WarningAction SilentlyContinue -InformationAction SilentlyContinue
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
    return $Subscriptions
}