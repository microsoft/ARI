function Get-AriVMQuotas {
    Param ($Subscriptions, $Resources, $Debug)
    if ($Debug.IsPresent)
        {
            $DebugPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'Continue'
        }

    $Quotas = @{}
    Foreach($Sub in $Subscriptions)
        {
            $Locs = ($Resources | Where-Object {$_.subscriptionId -eq $Sub.id -and $_.Type -in 'microsoft.compute/virtualmachines','microsoft.compute/virtualmachinescalesets'} | Group-Object -Property Location).name
            if (![string]::IsNullOrEmpty($Locs))
                {
                    Foreach($Loc in $Locs)
                        {
                            if($Loc.count -eq 1)
                                {
                                    Set-AzContext -Subscription $Sub.Id -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
                                    $Quota = get-azvmusage -location $Loc -InformationAction SilentlyContinue -ProgressAction SilentlyContinue
                                    $Quota = $Quota | Where-Object {$_.CurrentValue -ge 1}
                                    $Quotas[$Sub.id] = @{
                                        Location = $Loc
                                        Subscription = $Sub.name
                                        Data = $Quota
                                    }
                                }
                            else {
                                    Set-AzContext -Subscription $Sub.Id -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
                                    foreach($Loc1 in $Loc)
                                        {
                                            $Quota = get-azvmusage -location $Loc1 -InformationAction SilentlyContinue -ProgressAction SilentlyContinue
                                            $Quota = $Quota | Where-Object {$_.CurrentValue -ge 1}
                                            $Quotas[$Sub.id] = @{
                                                Location = $Loc1
                                                Subscription = $Sub.name
                                                Data = $Quota
                                            }
                                        }
                            }
                        }
                }
        }

    $VMQuotas = @{
        'type' = 'ARI/VM/Quotas';
        'Sizes' = $Quotas;
    }
    
    return $VMQuotas
}