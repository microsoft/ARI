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

    if ([string]::IsNullOrEmpty($CostData))
        {
            $ResTable = $Resources | Where-Object { $_.type -notin ('microsoft.advisor/recommendations',
                                                            'ARI/VM/Quotas',
                                                            'ARI/VM/SKU',
                                                            'Microsoft.Advisor/advisorScore',
                                                            'Microsoft.ResourceHealth/events',
                                                            'microsoft.support/supporttickets' )}
            $resTable2 = $ResTable | Select-Object id, Type, location, resourcegroup, subscriptionid
            $ResTable3 = $ResTable2 | Group-Object -Property type, location, resourcegroup, subscriptionid

            $FormattedTable = foreach ($ResourcesSUB in $ResTable3) 
                {
                    $ResourceDetails = $ResourcesSUB.name -split ", "
                    $SubName = $Subscriptions | Where-Object { $_.Id -eq $ResourceDetails[3] }
                    $obj = [PSCustomObject]@{
                        'Subscription'      = $SubName.Name
                        'SubscriptionId'    = $ResourceDetails[3]
                        'Resource Group'    = $ResourceDetails[2]
                        'Location'          = $ResourceDetails[1]
                        'Resource Type'     = $ResourceDetails[0]
                        'Resources Count'   = $ResourcesSUB.Count
                    }
                    $obj
                }
        }
    else
        {
            $FormattedTable = foreach ($Cost in $CostData)
                {
                    Foreach ($CostDetail in $Cost.CostData.Row)
                        {
                            Foreach ($Currency in $CostDetail[6])
                                {
                                    $Date0 = [datetime]$CostDetail[1]
                                    $DateMonth = ((Get-Culture).DateTimeFormat.GetMonthName(([datetime]$Date0).ToString("MM"))).ToString()
                                    $DateYear = (([datetime]$Date0).ToString("yyyy")).ToString()

                                    $obj = [PSCustomObject]@{
                                        'Subscription'      = $Cost.SubscriptionName
                                        'SubscriptionId'    = $Cost.SubscriptionId
                                        'Resource Group'    = $CostDetail[3]
                                        'Resource Type'     = $CostDetail[2]
                                        'Location'          = $CostDetail[4]
                                        'Service Name'      = $CostDetail[5]
                                        'Currency'          = $Currency
                                        'Cost'              = $CostDetail[0]
                                        'Detailed Cost'     = $CostDetail[0]
                                        'Year'              = $DateYear
                                        'Month'             = $DateMonth
                                    }
                                    $obj
                                }
                        }
                }
        }

        <#
        $outerKeyGeneral = [Func[Object,string]] { $args[0].SubscriptionID, $args[0].ResourceGroup, $args[0].ResourceType }
        $innerKeyGeneral = [Func[Object,string]] { $args[0].SubscriptionID, $args[0].ResourceGroup, $args[0].ResourceType }

        $ResultDelegate = [Func[Object, Object, PSCustomObject]] {
            param
            (
                $SubTable,
                $CostTable
            )
            [PSCustomObject]@{
                'Subscription' = $SubTable.Subscription
                'Resource Group' = $SubTable.ResourceGroup
                'Location' = $CostTable.Location
                'Resource Type' = $SubTable.ResourceType
                'Resources Count' = $SubTable.ResourcesCount
                'Currency' = $CostTable.Currency
                'Cost' = $CostTable.Cost
                'Detailed Cost' = $CostTable.DetailedCost
                'Year' = $CostTable.Year
                'Month' = $CostTable.Month
            }  
        }

        [System.Func[System.Object, [Collections.Generic.IEnumerable[System.Object]], System.Object]]$query = {
            param(
                $SubTable,
                $CostTable
            )
            $RightJoin = [System.Linq.Enumerable]::SingleOrDefault($CostTable)

            [PSCustomObject]@{
                'Subscription' = $SubTable.Subscription
                'Resource Group' = $SubTable.ResourceGroup
                'Location' = $SubTable.Location
                'Resource Type' = $SubTable.ResourceType
                'Resources Count' = $SubTable.ResourcesCount
                'Currency' = $RightJoin.Currency
                'Cost' = $RightJoin.Cost
                'Year' = $RightJoin.Year
                'Month' = $RightJoin.Month
            }
        }

        $LeftJoin = [System.Linq.Enumerable]::ToArray([System.Linq.Enumerable]::GroupJoin($SubDetailsTable, $CostDetailsTable, $outerKeyGroup, $innerKeyGeneraltest, $query))


        $InnerJoinResult = [System.Linq.Enumerable]::ToArray([System.Linq.Enumerable]::Join($SubDetailsTable, $CostDetailsTable, $outerKeyGeneral, $innerKeyGeneral, $resultDelegate))

        $InnerJoinResult
        #>

        $FormattedTable
}
