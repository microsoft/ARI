<#
.Synopsis
Advisory Module

.DESCRIPTION
This script process and creates the Advisory sheet based on advisorresources. 

.Link
https://github.com/azureinventory/ARI/Extras/Advisory.ps1

.COMPONENT
   This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 2.0.0
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

#>
param($Advisories, $Task ,$File, $Adv, $TableStyle)
 
If ($Task -eq 'Processing')
{
    $obj = ''
    $tmp = @()

    foreach ($1 in $Advisories) 
        {
            if($1)
                {
                    $data = $1.PROPERTIES

                    if($null -eq $data.extendedProperties.annualSavingsAmount){$Savings = 0}Else{$Savings = $data.extendedProperties.annualSavingsAmount}
                    if($null -eq $data.extendedProperties.savingsCurrency){$SavingsCurrency = 'USD'}Else{$SavingsCurrency = $data.extendedProperties.savingsCurrency}
                    $obj = @{
                        'ResourceGroup'          = $1.RESOURCEGROUP;
                        'Affected Resource Type' = $data.impactedField;
                        'Name'                   = $data.impactedValue;
                        'Category'               = $data.category;
                        'Impact'                 = $data.impact;
                        #'Score'                  = $data.extendedproperties.score;
                        'Problem'                = $data.shortDescription.problem;
                        'Savings Currency'       = $SavingsCurrency;
                        'Annual Savings'         = $Savings;
                        'Savings Region'         = $data.extendedProperties.location;   
                        'Current SKU'            = $data.extendedProperties.currentSku;
                        'Target SKU'             = $data.extendedProperties.targetSku
                    }    
                    $tmp += $obj
                }
        }
    $tmp
}
Else
{
    $condtxtadv = $(New-ConditionalText High -Range E:E
                New-ConditionalText Security -Range D:D -BackgroundColor Wheat)

    $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '#,##0.00' -Range H:H 

            $Adv |
            ForEach-Object { [PSCustomObject]$_ } | 
            Select-Object 'ResourceGroup',
            'Affected Resource Type',
            'Name', 
            'Category',
            'Impact',
            #'Score',
            'Problem',
            'Savings Currency',
            'Annual Savings',
            'Savings Region',
            'Current SKU',
            'Target SKU' |
            Export-Excel -Path $File -WorksheetName 'Advisory' -AutoSize -MaxAutoSizeRows 100 -TableName 'AzureAdvisory' -MoveToStart -TableStyle $tableStyle -Style $Style -ConditionalText $condtxtadv -KillExcel 

}