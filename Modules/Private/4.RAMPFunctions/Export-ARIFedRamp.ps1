function Export-ARIFedRamp {
    Param($FedRampResources, $DefaultPath, $RAMPFile)

    $FedRampTemplateFile = Join-Path $PSScriptRoot 'FedRAMP-Inventory-Template.xlsx'

    $TableStyle = 'Light19'

    $Style = @()
    $Style += New-ExcelStyle -HorizontalAlignment Center -WrapText -Range B:Y
    $Style += New-ExcelStyle -VerticalAlignment Center -Range A:Y
    $Style += New-ExcelStyle -HorizontalAlignment Center -Range A2:Y2

    $FedRampTemplate = Open-ExcelPackage -Path $FedRampTemplateFile

    $null = $FedRampResources | ForEach-Object { $_ } |
    Export-Excel -ExcelPackage $FedRampTemplate -WorksheetName 'Inventory' -TableName 'SSPInventory' -TableStyle $TableStyle -Style $Style -StartRow 2 -PassThru

	Close-ExcelPackage -ExcelPackage $FedRampTemplate -SaveAs $RAMPFile
}