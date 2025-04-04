<#
.Synopsis
Inventory for Azure Reservation Recommendations

.DESCRIPTION
Excel Sheet Name: Reservation Advisor

.Link
https://github.com/microsoft/ARI/Modules/APIs/ReservationRecom.ps1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 4.0.1
First Release Date: 25th Aug, 2024
Authors: Claudio Merola 

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Retirements, $Task, $File, $SmaResources, $TableStyle, $Unsupported)

If ($Task -eq 'Processing') {

    <######### Insert the resource extraction here ########>

    $Reserv = $Resources | Where-Object { $_.TYPE -eq 'Microsoft.Consumption/reservationRecommendations' }

    <######### Insert the resource Process here ########>

    if($Reserv)
        {
            $tmp = foreach ($1 in $Reserv) {
                $ResUCount = 1
                $SubId = $1.id.split('/')[2]
                $sub1 = $SUB | Where-Object { $_.id -eq $SubId }
                $data = $1.PROPERTIES
                $obj = @{
                    'ID'                                = $1.id;
                    'Subscription'                      = $sub1.Name;
                    'Current SKU'                       = $1.SKU;
                    'Location'                          = $1.location;
                    'Resource Type'                     = $data.resourceType;
                    'Instance Flexibility Group'        = $data.instanceFlexibilityGroup;
                    'Recommended Size'                  = $data.normalizedSize;
                    'Recommended Number of Reservations'= $data.recommendedQuantity;
                    'Instance Flexibility Ratio'        = $data.instanceFlexibilityRatio;
                    'Quantity Normalized'               = $data.recommendedQuantityNormalized;
                    'Cost With No Reserved Instance'    = $data.costWithNoReservedInstances;
                    'Cost With Reserved Instance'       = $data.totalCostWithReservedInstances;
                    'Net Savings'                       = $data.netSavings;
                    'Reservation Term'                  = $data.term;
                    'Scope'                             = $data.scope;
                    'Resource U'                        = $ResUCount
                }
                $obj
                if ($ResUCount -eq 1) { $ResUCount = 0 }
            }
            $tmp
        }
}

<######## Resource Excel Reporting Begins Here ########>

Else {
    <######## $SmaResources.(RESOURCE FILE NAME) ##########>

    if ($SmaResources) {

        $TableName = ('ReservRecTable_'+($SmaResources.'Resource U').count)

        $Style = @()
        $Style += New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0' -Range A:I
        $Style += New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '#,##0.00' -Range J:L
        $Style += New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0' -Range M:N

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Current SKU')
        $Exc.Add('Location')
        $Exc.Add('Resource Type')
        $Exc.Add('Instance Flexibility Group')
        $Exc.Add('Recommended Size')
        $Exc.Add('Recommended Number of Reservations')
        $Exc.Add('Instance Flexibility Ratio')
        $Exc.Add('Quantity Normalized')
        $Exc.Add('Cost With No Reserved Instance')
        $Exc.Add('Cost With Reserved Instance')
        $Exc.Add('Net Savings')
        $Exc.Add('Reservation Term')
        $Exc.Add('Scope')

        [PSCustomObject]$SmaResources | 
        ForEach-Object { $_ } | Select-Object $Exc | 
        Export-Excel -Path $File -WorksheetName 'Reservation Advisor' -AutoSize -TableName $TableName -MaxAutoSizeRows 100 -TableStyle $tableStyle -Style $Style

    }
}