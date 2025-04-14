function Export-ARIStateRamp {
    Param($StateRampResources, $DefaultPath, $RAMPFile)

    $StateRampTemplateFile = Join-Path $PSScriptRoot 'StateRAMP-Inventory-Template.xlsx'

    $TableStyle = 'Light19'

    $Style = @()
    $Style += New-ExcelStyle -HorizontalAlignment Center -WrapText -Range B:X
    $Style += New-ExcelStyle -VerticalAlignment Center -Range A:X
    $Style += New-ExcelStyle -HorizontalAlignment Center -Range A2:X2

    $StateRampTemplate = Open-ExcelPackage -Path $StateRampTemplateFile

    $null = $StateRampResources | ForEach-Object { $_ } |
    Export-Excel -ExcelPackage $StateRampTemplate -WorksheetName 'Inventory' -TableName 'SSPInventory' -TableStyle $TableStyle -Style $Style -StartRow 2 -PassThru

	Close-ExcelPackage -ExcelPackage $StateRampTemplate -SaveAs $RAMPFile
}