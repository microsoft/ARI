function Get-AriVMQuotas {
    Param ($Subscriptions, $Resources, $Debug)
    if ($Debug.IsPresent)
        {
            $DebugPreference = 'SilentlyContinue'
            $ErrorActionPreference = 'Continue'
        }

    $Quotas = Foreach($Sub in $Subscriptions)
        {
            $Locs = ($Resources | Where-Object {$_.subscriptionId -eq $Sub.id -and $_.Type -in 'microsoft.compute/virtualmachines','microsoft.compute/virtualmachinescalesets'} | Group-Object -Property Location).name
            if (![string]::IsNullOrEmpty($Locs))
                {
                    Foreach($Loc in $Locs)
                        {
                            if($Loc.count -eq 1)
                                {
                                    Set-AzContext -Subscription $Sub.Id -ErrorAction SilentlyContinue -WarningAction SilentlyContinue -InformationAction SilentlyContinue | Out-Null
                                    $Quota = get-azvmusage -location $Loc -InformationAction SilentlyContinue -ProgressAction SilentlyContinue
                                    $Quota = $Quota | Where-Object {$_.CurrentValue -ge 1}
                                    $tmp = [PSCustomObject]@{
                                        Location = $Loc
                                        SubId = $Sub.id
                                        Subscription = $Sub.name
                                        Data = $Quota
                                    }
                                    $tmp
                                }
                            else {
                                    Set-AzContext -Subscription $Sub.Id -ErrorAction SilentlyContinue -WarningAction SilentlyContinue -InformationAction SilentlyContinue | Out-Null
                                    foreach($Loc1 in $Loc)
                                        {
                                            $Quota = get-azvmusage -location $Loc1 -InformationAction SilentlyContinue -ProgressAction SilentlyContinue
                                            $Quota = $Quota | Where-Object {$_.CurrentValue -ge 1}
                                            $tmp = [PSCustomObject]@{
                                                Location = $Loc1
                                                SubId = $Sub.id
                                                Subscription = $Sub.name
                                                Data = $Quota
                                            }
                                            $tmp
                                        }
                            }
                        }
                }
        }

    $VMQuotas = [PSCustomObject]@{
        'type'          = 'ARI/VM/Quotas'
        'properties'    = $Quotas
    }

    return $VMQuotas
}