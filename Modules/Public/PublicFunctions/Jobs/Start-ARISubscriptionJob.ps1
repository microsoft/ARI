<#
.Synopsis
Start Subscription Job Module

.DESCRIPTION
This script processes and creates the Subscriptions sheet based on resources and their subscriptions.

.Link
https://github.com/microsoft/ARI/Modules/Public/PublicFunctions/Jobs/Start-ARISubscriptionJob.ps1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.6.0
First Release Date: 15th Oct, 2024
Authors: Claudio Merola

#>
function Start-ARISubscriptionJob {
    param($Subscriptions, $Resources, $CostData)

    $ResTable = $Resources | Where-Object { $_.type -notin ('microsoft.advisor/recommendations',
                                                            'ARI/VM/Quotas',
                                                            'ARI/VM/SKU',
                                                            'Microsoft.Advisor/advisorScore',
                                                            'Microsoft.ResourceHealth/events',
                                                            'microsoft.support/supporttickets' )}
    $resTable2 = $ResTable | Select-Object id, Type, location, resourcegroup, subscriptionid
    $ResTable3 = $ResTable2 | Group-Object -Property type, location, resourcegroup, subscriptionid

    if (![string]::IsNullOrEmpty($CostData.ActualCost.Row)) {
        $tmp = foreach ($ResourcesSUB in $ResTable3) 
            {
                $ResourceDetails = $ResourcesSUB.name -split ", "
                foreach ($Cost in $CostData)
                    {
                        if($Cost.SubscriptionId -eq $ResourceDetails[3])
                            {
                                Foreach ($Row in $Cost.ActualCost.Row)
                                    {
                                        if ($Row[2] -eq $ResourceDetails[0] -and $Row[3] -eq $ResourceDetails[2])
                                            {
                                                Foreach ($Currency in $Row[4])
                                                    {
                                                        $Date0 = [datetime]$Row[1]
                                                        $DateMonth = ((Get-Culture).DateTimeFormat.GetMonthName(([datetime]$Date0).ToString("MM"))).ToString()
                                                        $DateYear = (([datetime]$Date0).ToString("yyyy")).ToString()

                                                        $obj = @{
                                                            'Subscription'   = $Cost.Subscription;
                                                            'Resource Group' = $ResourceDetails[2];
                                                            'Location'       = $ResourceDetails[1];
                                                            'Resource Type'  = $ResourceDetails[0];
                                                            'Resources Count'= $ResourcesSUB.Count;
                                                            'Currency'       = $Currency;
                                                            'Cost'           = $Row[0];
                                                            'Year'           = $DateYear;
                                                            'Month'          = $DateMonth
                                                        }
                                                        $obj
                                                    }
                                            }
                                    }
                            }
                    }
            }
    } else {
        $tmp = foreach ($ResourcesSUB in $ResTable3) {
            $ResourceDetails = $ResourcesSUB.name -split ","
            $SubName = $Subscriptions | Where-Object { $_.Id -eq ($ResourceDetails[3] -replace (" ", "")) }
            $obj = @{
                'Subscription'   = $SubName.Name;
                'Resource Group' = $ResourceDetails[2];
                'Location'       = $ResourceDetails[1];
                'Resource Type'  = $ResourceDetails[0];
                'Resources Count'= $ResourcesSUB.Count
            }
            $obj
        }
    }

    $tmp
}
