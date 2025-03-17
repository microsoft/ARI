function Build-ARISubsReport {
    param($File, $Sub, $TableStyle)
    $TableName = ('SubsTable_'+($Sub.Subscription | Select-Object -Unique).count)
    $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

    $Sub |
        ForEach-Object { [PSCustomObject]$_ } |
        Select-Object 'Subscription',
        'Resource Group',
        'Location',
        'Resource Type',
        'Resources' | Export-Excel -Path $File -WorksheetName 'Subscriptions' -TableName $TableName -AutoSize -MaxAutoSizeRows 100 -TableStyle $tableStyle -Style $Style -Numberformat '0' -MoveToEnd
}