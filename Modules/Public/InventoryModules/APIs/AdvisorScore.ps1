<#
.Synopsis
Inventory for Azure Advisor Score

.DESCRIPTION
Excel Sheet Name: AdvisorScore

.Link
https://github.com/microsoft/ARI/Modules/public/InventoryModules/APIs/AdvisorScore.ps1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.6.1
First Release Date: 25th Aug, 2024
Authors: Claudio Merola 

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Retirements, $Task, $File, $SmaResources, $TableStyle, $Unsupported)

If ($Task -eq 'Processing') {

    $AdvisorScore = $Resources | Where-Object { $_.TYPE -eq 'Microsoft.Advisor/advisorScore' }

    if($AdvisorScore)
        {
            $tmp = foreach ($1 in $AdvisorScore) {
                if ($1.name -in ('Cost','OperationalExcellence','Performance','Security','HighAvailability','Advisor'))
                    {
                        $ResUCount = 1
                        $SubId = $1.id.split('/')[2]
                        $sub1 = $SUB | Where-Object { $_.id -eq $SubId }
                        $data = $1.PROPERTIES
                        $Series = $data.timeSeries | Where-Object {$_.aggregationLevel -eq 'Monthly'}

                        $RefreshDate = $data.lastRefreshedScore.date
                        $RefreshDate = [datetime]$RefreshDate
                        $RefreshDate = $RefreshDate.ToString("yyyy-MM-dd")

                        foreach ($Serie in $Series.scoreHistory)
                            {
                                $Date = $Serie.date
                                $Date = [datetime]$Date
                                $Date = $Date.ToString("yyyy-MM-dd")

                                $obj = @{
                                    'ID'                        = $1.id;
                                    'Subscription'              = $sub1.Name;
                                    'Category'                  = $1.Name;
                                    'Latest Score (%)'          = $data.lastRefreshedScore.score;
                                    'Latest Refresh Score'      = $RefreshDate;
                                    'Score Date'                = $Date;
                                    'Score'                     = $Serie.score;
                                    'Impacted Resources'        = $Serie.impactedResourceCount;
                                    'Consumption Units'         = $Serie.consumptionUnits;
                                    'Potential Score Increase'  = $Serie.potentialScoreIncrease;
                                    'Resource U'                = $ResUCount
                                }
                                if ($ResUCount -eq 1) { $ResUCount = 0 } 
                                $obj
                            }
                    }
            }
            $tmp
        }
}

<######## Resource Excel Reporting Begins Here ########>

Else {

    if ($SmaResources) {

        $TableName = ('AdvScTab_'+($SmaResources.'Resource U').count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

        $condtxt = @()

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Category')
        $Exc.Add('Latest Score (%)')
        $Exc.Add('Latest Refresh Score')
        $Exc.Add('Score Date')
        $Exc.Add('Score')
        $Exc.Add('Impacted Resources')
        $Exc.Add('Consumption Units')
        $Exc.Add('Potential Score Increase')

        [PSCustomObject]$SmaResources | 
        ForEach-Object { $_ } | Select-Object $Exc | 
        Export-Excel -Path $File -WorksheetName 'AdvisorScore' -AutoSize -TableName $TableName -MaxAutoSizeRows 100 -TableStyle $tableStyle -ConditionalText $condtxt -Numberformat '0' -Style $Style

    }
}