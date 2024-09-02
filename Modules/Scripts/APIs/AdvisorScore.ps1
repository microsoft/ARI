<#
.Synopsis
Inventory for Azure Advisor Score

.DESCRIPTION
Excel Sheet Name: AdvisorScore

.Link
https://github.com/microsoft/ARI/Modules/APIs/AdvisorScore.ps1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 4.0.1
First Release Date: 25th Aug, 2024
Authors: Claudio Merola 

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Task , $File, $SmaResources, $TableStyle, $Unsupported)

If ($Task -eq 'Processing') {

    <######### Insert the resource extraction here ########>

    $AdvisorScore = $Resources | Where-Object { $_.TYPE -eq 'Microsoft.Advisor/advisorScore' }

    <######### Insert the resource Process here ########>

    if($AdvisorScore)
        {
            $tmp = @()
            foreach ($1 in $AdvisorScore) {
                if ($1.name -in ('Cost','OperationalExcellence','Performance','Security','HighAvailability','Advisor'))
                    {
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
                                    'Potential Score Increase'  = $Serie.potentialScoreIncrease
                                }
                                $tmp += $obj
                            }
                    }
            }
            $tmp
        }
}

<######## Resource Excel Reporting Begins Here ########>

Else {
    <######## $SmaResources.(RESOURCE FILE NAME) ##########>

    if ($SmaResources.AdvisorScore) {

        $TableName = ('AdvScoreTable_'+($SmaResources.AdvisorScore.id | Select-Object -Unique).count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

        $condtxt = @()
        $condtxt += New-ConditionalText -Range C:C -ConditionalType LessThan 80
        $condtxt += New-ConditionalText -Range F:F -ConditionalType LessThan 70

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

        $ExcelVar = $SmaResources.AdvisorScore

        $ExcelVar | 
        ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        Export-Excel -Path $File -WorksheetName 'AdvisorScore' -AutoSize -TableName $TableName -MaxAutoSizeRows 100 -TableStyle $tableStyle -ConditionalText $condtxt -Numberformat '0' -Style $Style

    }
}