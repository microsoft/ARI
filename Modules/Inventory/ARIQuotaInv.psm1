<#
.Synopsis
vCPU Quotas Module

.DESCRIPTION
This script process and creates the Quota sheet based on Quotas Used.

.Link
https://github.com/microsoft/ARI/Modules/Inventory/ARIQuotaInv.psm1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 4.0.1
First Release Date: 15th Oct, 2024
Authors: Claudio Merola

#>

function Start-ARIQuotaJob {
    Param($Resources,$Subscriptions)

    Start-Job -Name 'Quota Usage' -ScriptBlock {

        $Quotas = @()
        $Quotas = Foreach($Sub in $($args[1]))
            {
                $Locs = ($($args[0]) | Where-Object {$_.subscriptionId -eq $Sub.id -and $_.Type -in 'microsoft.compute/virtualmachines','microsoft.compute/virtualmachinescalesets'} | Group-Object -Property Location).name
                if (![string]::IsNullOrEmpty($Locs))
                    {
                        Foreach($Loc in $Locs)
                            {
                                if($Loc.Loc.count -eq 1)
                                    {
                                        Set-AzContext -Subscription $Sub.Id
                                        $Quota = get-azvmusage -location $Loc.Loc 
                                        $Quota = $Quota | Where-Object {$_.CurrentValue -ge 1}
                                        $Q = @{
                                            'Location' = $Loc.Loc;
                                            'Subscription' = $Sub.name;
                                            'Data' = $Quota
                                        }
                                        $Q
                                    }
                                else {
                                        Set-AzContext -Subscription $Sub.Id
                                        foreach($Loc1 in $Loc.loc)
                                            {
                                                $Quota = get-azvmusage -location $Loc1
                                                $Quota = $Quota | Where-Object {$_.CurrentValue -ge 1}
                                                $Q = @{
                                                    'Location' = $Loc1;
                                                    'Subscription' = $Sub.name;
                                                    'Data' = $Quota
                                                }
                                                $Q
                                            }
                                }
                            }
                    }
            }
            $Quotas
        } -ArgumentList $Resources, $Subscriptions
}

function Build-ARIQuotaReport {
    param($File, $AzQuota, $TableStyle)

    $tmp = @()
    $Total = ($AzQuota.Data).count
    foreach($Quota in $AzQuota)
    {
        foreach($Data in $Quota.Data)
            {
                $FreevCPU = ''
                if($Data.Name.LocalizedValue -like '*vCPUs'){$FreevCPU = $Data.limit - $Data.CurrentValue}
                $obj = @{
                    'Subscription' = $Quota.Subscription;
                    'Region' = $Quota.Location;
                    'Current Usage' = $Data.currentValue;
                    'Limit' = $Data.limit;
                    'Quota' = $Data.Name.LocalizedValue;
                    'vCPUs Available' = $FreevCPU;
                    'Total' = $Total
                }
                $tmp += $obj
            }
    }

    $ExcelVar = $tmp

    $TableName = ('QuotaTable_'+$ExcelVar[0].Total)
    $ExcelVar |
    ForEach-Object { [PSCustomObject]$_ } |
    Select-Object -Unique 'Subscription',
    'Region',
    'Current Usage',
    'Limit',
    'Quota',
    'vCPUs Available' |
    Export-Excel -Path $File -WorksheetName 'Quota Usage' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -Numberformat '0' -MoveToEnd
}