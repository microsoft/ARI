function Get-ARISubscriptions {
    Param ($TenantID,$SubscriptionID)
    $DebugPreference = 'SilentlyContinue'
    Write-Host "Extracting Subscriptions from Tenant $TenantID"
    try
        {
            $Subscriptions = Get-AzSubscription -TenantId $TenantID -WarningAction SilentlyContinue -InformationAction SilentlyContinue
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
    return $Subscriptions
}