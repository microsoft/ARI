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

    $SubDetailsTable = foreach ($ResourcesSUB in $ResTable3) 
        {
            $ResourceDetails = $ResourcesSUB.name -split ", "
            $SubName = $Subscriptions | Where-Object { $_.Id -eq $ResourceDetails[3] }
            $obj = [PSCustomObject]@{
                'Subscription'   = $SubName.Name
                'SubscriptionId'   = $ResourceDetails[3]
                'ResourceGroup' = $ResourceDetails[2]
                'Location'       = $ResourceDetails[1]
                'ResourceType'  = $ResourceDetails[0]
                'ResourcesCount'= $ResourcesSUB.Count
            }
            $obj
        }

    $CostDetailsTable = foreach ($Cost in $CostData)
        {
            Foreach ($CostDetail in $Cost.CostData.Row)
                {
                    Foreach ($Currency in $CostDetail[5])
                        {
                            $Date0 = [datetime]$CostDetail[1]
                            $DateMonth = ((Get-Culture).DateTimeFormat.GetMonthName(([datetime]$Date0).ToString("MM"))).ToString()
                            $DateYear = (([datetime]$Date0).ToString("yyyy")).ToString()

                            $obj = [PSCustomObject]@{
                                'Subscription'   = $Cost.SubscriptionName
                                'SubscriptionId' = $Cost.SubscriptionId
                                'ResourceGroup'  = $CostDetail[3]
                                'ResourceType'   = $CostDetail[2]
                                #'Location'       = $CostDetail[4]
                                'Currency'       = $Currency
                                'Cost'           = $CostDetail[0]
                                'DetailedCost'   = $CostDetail[0]
                                'Year'           = $DateYear
                                'Month'          = $DateMonth
                            }
                            $obj
                        }
                }
        }

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
                'Location' = $SubTable.Location
                'Resource Type' = $SubTable.ResourceType
                'Resources Count' = $SubTable.ResourcesCount
                'Currency' = $CostTable.Currency
                'Cost' = $CostTable.Cost
                'Detailed Cost' = $CostTable.DetailedCost
                'Year' = $CostTable.Year
                'Month' = $CostTable.Month
            }  
        }

        <#
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
        #>

        $InnerJoinResult = [System.Linq.Enumerable]::ToArray([System.Linq.Enumerable]::Join($SubDetailsTable, $CostDetailsTable, $outerKeyGeneral, $innerKeyGeneral, $resultDelegate))

        $InnerJoinResult
}
