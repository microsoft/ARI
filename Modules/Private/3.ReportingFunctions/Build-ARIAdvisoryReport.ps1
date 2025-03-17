function Build-ARIAdvisoryReport {
    param($File, $Adv, $TableStyle)
    $condtxtadv = @()
    $condtxtadv += New-ConditionalText High -Range E:E
    $condtxtadv += New-ConditionalText Security -Range D:D -BackgroundColor Wheat

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
    Export-Excel -Path $File -WorksheetName 'Advisor' -AutoSize -MaxAutoSizeRows 100 -TableName 'AzureAdvisory' -MoveToStart -TableStyle $tableStyle -Style $Style -ConditionalText $condtxtadv
}