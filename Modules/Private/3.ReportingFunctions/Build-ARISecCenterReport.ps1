function Build-ARISecCenterReport {
    param($File, $Sec, $TableStyle)
    $condtxtsec = $(New-ConditionalText High -Range G:G
    New-ConditionalText High -Range L:L)

    $Sec |
    ForEach-Object { [PSCustomObject]$_ } |
    Select-Object 'Subscription',
    'Resource Group',
    'Resource Type',
    'Resource Name',
    'Categories',
    'Control',
    'Severity',
    'Status',
    'Remediation',
    'Remediation Effort',
    'User Impact',
    'Threats' |
    Export-Excel -Path $File -WorksheetName 'SecurityCenter' -AutoSize -MaxAutoSizeRows 100 -MoveToStart -TableName 'SecurityCenter' -TableStyle $tableStyle -ConditionalText $condtxtsec
}