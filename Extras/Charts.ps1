<#
.Synopsis
Module for Main Dashboard

.DESCRIPTION
This script process and creates the Overview sheet. 

.Link
https://github.com/azureinventory/ARI/Extras/Charts.ps1

.COMPONENT
   This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 2.1.1
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

#>
param($File, $TableStyle, $PlatOS, $Subscriptions, $Resources, $ExtractionRunTime, $ReportingRunTime)

$Excel = New-Object -TypeName OfficeOpenXml.ExcelPackage $File
$Worksheets = $Excel.Workbook.Worksheets

$Order = $Worksheets | Where-Object { $_.Name -notin 'Advisory', 'Security Center', 'Subscriptions', 'Quota Usage' } | Select-Object -Property Index, name, @{N = "Dimension"; E = { $_.dimension.Rows - 1 } } | Sort-Object -Property Dimension -Descending

$Order0 = $Order | Where-Object { $_.Name -ne $Order[0].name -and $_.Name -ne ($Order | select-object -Last 1).Name }

$Worksheets.MoveAfter($Order[0].Name, 'Advisory')
$Worksheets.MoveBefore(($Order | select-object -Last 1).Name, 'Subscriptions')

$Loop = 0

Foreach ($Ord in $Order0) {
    if ($Ord.Index -and $Loop -ne 0) {
        $Worksheets.MoveAfter($Ord.Name, $Order0[$Loop - 1].Name)
    }
    if ($Loop -eq 0) {
        $Worksheets.MoveAfter($Ord.Name, $Order[0].Name)
    }
    $Loop++    
}

$Excel.Save()
$Excel.Dispose()


"" | Export-Excel -Path $File -WorksheetName 'Overview' -MoveToStart

$Excel = New-Object -TypeName OfficeOpenXml.ExcelPackage $File
$Worksheets = $Excel.Workbook.Worksheets
$WS = $Excel.Workbook.Worksheets | Where-Object { $_.Name -eq 'Overview' }

$WS.SetValue(75,70,'')
$WS.SetValue(76,70,'')
$WS.View.ShowGridLines = $false

$Excel.Save()
$Excel.Dispose()

$TableStyleEx = if($PlatOS -eq 'PowerShell Desktop'){'Medium1'}else{$TableStyle}
$TableStyle = if($PlatOS -eq 'PowerShell Desktop'){'Medium15'}else{$TableStyle}
#$TableStyle = 'Medium22'
$Font = 'Segoe UI'

$Excel = New-Object -TypeName OfficeOpenXml.ExcelPackage $File
$Worksheets = $Excel.Workbook.Worksheets | Where-Object { $_.name -notin 'Overview', 'Subscriptions', 'Advisory', 'Security Center' }
$WS = $Excel.Workbook.Worksheets | Where-Object { $_.Name -eq 'Overview' }


$TabDraw = $WS.Drawings.AddShape('TP00', 'RoundRect')
$TabDraw.SetSize(130 , 78)
$TabDraw.SetPosition(1, 0, 0, 0)
$TabDraw.TextAlignment = 'Center'

$Table = @()
Foreach ($WorkS in $Worksheets) {
    $tmp = @{
        'Name' = $WorkS.name;
        'Size' = ($WorkS.Dimension.Rows - 1)
    }
    $Table += $tmp
}

$Excel.Save()
$Excel.Dispose()

$Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0

$Table | 
ForEach-Object { [PSCustomObject]$_ } | 
Select-Object -Unique 'Name',
'Size' | Export-Excel -Path $File -WorksheetName 'Overview' -AutoSize -MaxAutoSizeRows 100 -TableName 'AzureTabs' -TableStyle $TableStyleEx -Style $Style -StartRow 6 -StartColumn 1


$Date = (get-date -Format "MM/dd/yyyy")

$ExtractTime = ($ExtractionRunTime.Totalminutes.ToString('#######.##')+' Minutes')
$ReportTime = ($ReportingRunTime.Totalminutes.ToString('#######.##')+' Minutes')

$User = $Subscriptions[0].user.name
$TotalRes = $Resources

$Excel = New-Object -TypeName OfficeOpenXml.ExcelPackage $File
$Worksheets = $Excel.Workbook.Worksheets 
$WS = $Excel.Workbook.Worksheets | Where-Object { $_.Name -eq 'Overview' }


$cell = $WS.Cells | Where-Object {$_.Address -like 'A*' -and $_.Address -notin 'A1','A2','A3','A4','A5','A6'}
foreach ($item in $cell) {
    $Works = $Item.Text
    $Link = New-Object -TypeName OfficeOpenXml.ExcelHyperLink ("'"+$Works+"'"+'!A1'),$Works
    $Item.Hyperlink = $Link
}


$Egg = $WS.Cells | Where-Object {$_.Address -eq 'BR75'}
$Egg.AddComment('Created with alot of effort and hard work, we hope you enjoy it.','.') | Out-Null
$Egg = $WS.Cells | Where-Object {$_.Address -eq 'BR76'}
$Egg.AddComment('By: Claudio Merola and Renato Gregio','.') | Out-Null


$TabDraw = $WS.Drawings.AddShape('TP0', 'RoundRect')
$TabDraw.SetSize(125, 25)
$TabDraw.SetPosition(0, 10, 52, 0)
$TabDraw.TextAlignment = 'Center'

$TabDraw = $WS.Drawings.AddShape('TP1', 'RoundRect')
$TabDraw.SetSize(125, 25)
$TabDraw.SetPosition(0, 10, 55, 0)
$TabDraw.TextAlignment = 'Center'

$TabDraw = $WS.Drawings.AddShape('TP2', 'RoundRect')
$TabDraw.SetSize(125, 25)
$TabDraw.SetPosition(0, 10, 58, 0)
$TabDraw.TextAlignment = 'Center'

$TabDraw = $WS.Drawings.AddShape('TP3', 'RoundRect')
$TabDraw.SetSize(125, 25)
$TabDraw.SetPosition(0, 10, 61, 0)
$TabDraw.TextAlignment = 'Center'

$TabDraw = $WS.Drawings.AddShape('TP4', 'RoundRect')
$TabDraw.SetSize(125, 25)
$TabDraw.SetPosition(0, 10, 64, 0)
$TabDraw.TextAlignment = 'Center'

$TabDraw = $WS.Drawings.AddShape('TP5', 'RoundRect')
$TabDraw.SetSize(125, 25)
$TabDraw.SetPosition(0, 10, 67, 0)
$TabDraw.TextAlignment = 'Center'

$TabDraw = $WS.Drawings.AddShape('TP6', 'RoundRect')
$TabDraw.SetSize(125, 25)
$TabDraw.SetPosition(0, 10, 70, 0)
$TabDraw.TextAlignment = 'Center'

$TabDraw = $WS.Drawings.AddShape('TP7', 'RoundRect')
$TabDraw.SetSize(125, 25)
$TabDraw.SetPosition(0, 10, 73, 0)
$TabDraw.TextAlignment = 'Center'

$TabDraw = $WS.Drawings.AddShape('TP8', 'RoundRect')
$TabDraw.SetSize(125, 25)
$TabDraw.SetPosition(0, 10, 76, 0)
$TabDraw.TextAlignment = 'Center'

$TabDraw = $WS.Drawings.AddShape('TP9', 'RoundRect')
$TabDraw.SetSize(125, 25)
$TabDraw.SetPosition(0, 10, 79, 0)
$TabDraw.TextAlignment = 'Center'


$Draw = $WS.Drawings.AddShape('ARI', 'RoundRect')
$Draw.SetSize(445, 240)
$Draw.SetPosition(1, 0, 2, 5)


$txt = $Draw.RichText.Add('Azure Resource Inventory v2' + "`n")
$txt.Size = 14
$txt.ComplexFont = $Font
$txt.LatinFont = $Font

$txt = $Draw.RichText.Add('https://github.com/azureinventory/ARI' + "`n" + "`n")
$txt.Size = 11
$txt.ComplexFont = $Font
$txt.LatinFont = $Font

$txt = $Draw.RichText.Add('Report Date: ')
$txt.Size = 11
$txt.ComplexFont = $Font
$txt.LatinFont = $Font

$txt = $Draw.RichText.Add($Date + "`n")
$txt.Size = 12
$txt.ComplexFont = $Font
$txt.LatinFont = $Font

$txt = $Draw.RichText.Add('Extraction Time: ')
$txt.Size = 11
$txt.ComplexFont = $Font
$txt.LatinFont = $Font

$txt = $Draw.RichText.Add($ExtractTime + "`n")
$txt.Size = 12
$txt.ComplexFont = $Font
$txt.LatinFont = $Font

$txt = $Draw.RichText.Add('Reporting Time: ')
$txt.Size = 11
$txt.ComplexFont = $Font
$txt.LatinFont = $Font

$txt = $Draw.RichText.Add($ReportTime + "`n")
$txt.Size = 12
$txt.ComplexFont = $Font
$txt.LatinFont = $Font

$txt = $Draw.RichText.Add('User Session: ')
$txt.Size = 11
$txt.ComplexFont = $Font
$txt.LatinFont = $Font

$txt = $Draw.RichText.Add($User + "`n")
$txt.Size = 12
$txt.ComplexFont = $Font
$txt.LatinFont = $Font

$txt = $Draw.RichText.Add('Environment: ')
$txt.Size = 11
$txt.ComplexFont = $Font
$txt.LatinFont = $Font

$txt = $Draw.RichText.Add($PlatOS)
$txt.Size = 12
$txt.ComplexFont = $Font
$txt.LatinFont = $Font

$Draw.TextAlignment = 'Center'

$RGD = $WS.Drawings.AddShape('RGs', 'RoundRect')
$RGD.SetSize(124, 115)
$RGD.SetPosition(21, 5, 9, 5)
$RGD.TextAlignment = 'Center'
$RGD.RichText.Add('Total Resources' + "`n").Size = 12
$RGD.RichText.Add($TotalRes).Size = 22



$DrawP00 = $WS.Drawings | Where-Object { $_.Name -eq 'TP00' }
$P00Name = 'Reported Resources'
$DrawP00.RichText.Add($P00Name).Size = 16

$DrawP0 = $WS.Drawings | Where-Object { $_.Name -eq 'TP0' }
if ($Excel.Workbook.Worksheets | Where-Object { $_.Name -eq 'Advisory' }) {
    $P0Name = 'Advisories'        
}
else {
    $P0Name = 'Public IPs'
}
$DrawP0.RichText.Add($P0Name) | Out-Null


$P1Name = 'Subscriptions'
$DrawP1 = $WS.Drawings | Where-Object { $_.Name -eq 'TP1' }
$DrawP1.RichText.Add($P1Name) | Out-Null



$DrawP2 = $WS.Drawings | Where-Object { $_.Name -eq 'TP2' }
if ($Excel.Workbook.Worksheets | Where-Object { $_.Name -eq 'SecurityCenter' }) {
    $P2Name = 'Security Center'
}
elseif ($Excel.Workbook.Worksheets | Where-Object { $_.Name -eq 'Advisory' }) {
    $P2Name = 'Annual Savings'
}
else {
    $P2Name = 'Virtual Networks'
}   

$DrawP2.RichText.Add($P2Name) | Out-Null

$DrawP3 = $WS.Drawings | Where-Object { $_.Name -eq 'TP3' }
if ($Excel.Workbook.Worksheets | Where-Object { $_.Name -eq 'AKS' }) {
    $P3Name = 'Azure Kubernetes'       
}
else {
    $P3Name = 'Storage Accounts' 
}
$DrawP3.RichText.Add($P3Name) | Out-Null

$DrawP4 = $WS.Drawings | Where-Object { $_.Name -eq 'TP4' }
if ($Excel.Workbook.Worksheets | Where-Object { $_.Name -eq 'Quota Usage' }) {
    $P4Name = 'Quota Usage'
}
else {
    $P4Name = 'VM Disks'
}
$DrawP4.RichText.Add($P4Name) | Out-Null

$DrawP5 = $WS.Drawings | Where-Object { $_.Name -eq 'TP5' }
if ($Excel.Workbook.Worksheets | Where-Object { $_.Name -eq 'Virtual Machines' }) {
    $P5Name = 'Virtual Machines'
}
$DrawP5.RichText.Add($P5Name) | Out-Null

$DrawP6 = $WS.Drawings | Where-Object { $_.Name -eq 'TP6' }
$P6Name = 'Resources by Location'
$DrawP6.RichText.Add($P6Name) | Out-Null

$DrawP7 = $WS.Drawings | Where-Object { $_.Name -eq 'TP7' }
if ($Excel.Workbook.Worksheets | Where-Object { $_.Name -eq 'Virtual Machines' }) {
    $P7Name = 'Virtual Machines'
}
$DrawP7.RichText.Add($P7Name) | Out-Null

$DrawP8 = $WS.Drawings | Where-Object { $_.Name -eq 'TP8' }
if ($Excel.Workbook.Worksheets | Where-Object { $_.Name -eq 'Advisory' }) {
    $P8Name = 'Advisories'
}
$DrawP8.RichText.Add($P8Name) | Out-Null

$DrawP9 = $WS.Drawings | Where-Object { $_.Name -eq 'TP9' }
if ($Excel.Workbook.Worksheets | Where-Object { $_.Name -eq 'Virtual Machines' }) {
    $P9Name = 'Virtual Machines'
}
$DrawP9.RichText.Add($P9Name) | Out-Null

$Excel.Save()
$Excel.Dispose()





$excel = Open-ExcelPackage -Path $file -KillExcel

Add-ExcelChart -Worksheet $excel.Overview -ChartType Area3D -XRange "AzureTabs[Name]" -YRange "AzureTabs[Size]" -SeriesHeader 'Resources', 'Count' -Column 9 -Row 1 -Height 400 -Width 950 -RowOffSetPixels 0 -ColumnOffSetPixels 5 -NoLegend    


if ($P0Name -eq 'Advisories') {
    $PTParams = @{
        PivotTableName          = "P0"
        Address                 = $excel.Overview.cells["BA5"] # top-left corner of the table
        SourceWorkSheet         = $excel.Advisory
        PivotRows               = @("Category")
        PivotData               = @{"Category" = "Count" }
        PivotTableStyle         = $tableStyle
        IncludePivotChart       = $true
        ChartType               = "BarStacked3D"
        ChartRow                = 13 # place the chart below row 22nd
        ChartColumn             = 2
        Activate                = $true
        PivotFilter             = 'Impact'
        ChartTitle              = 'Advisories'
        ShowPercent             = $true
        ChartHeight             = 275
        ChartWidth              = 445
        ChartRowOffSetPixels    = 5
        ChartColumnOffSetPixels = 5
    }
    Add-PivotTable @PTParams -NoLegend
}
else {
    $PTParams = @{
        PivotTableName          = "P0"
        Address                 = $excel.Overview.cells["BA5"] # top-left corner of the table
        SourceWorkSheet         = $excel.'Public IPs'
        PivotRows               = @("Use")
        PivotData               = @{"Use" = "Count" }
        PivotTableStyle         = $tableStyle
        IncludePivotChart       = $true
        ChartType               = "BarStacked3D"
        ChartRow                = 13 # place the chart below row 22nd
        ChartColumn             = 2
        Activate                = $true
        PivotFilter             = 'location'
        ChartTitle              = 'Public IPs'
        ShowPercent             = $true
        ChartHeight             = 275
        ChartWidth              = 445
        ChartRowOffSetPixels    = 5
        ChartColumnOffSetPixels = 5
    }

    Add-PivotTable @PTParams -NoLegend
}

$PTParams = @{
    PivotTableName          = "P1"
    Address                 = $excel.Overview.cells["BD6"] # top-left corner of the table
    SourceWorkSheet         = $excel.Subscriptions
    PivotRows               = @("Subscription")
    PivotData               = @{"Resources" = "sum" }
    PivotTableStyle         = $tableStyle
    IncludePivotChart       = $true
    ChartType               = "BarClustered"
    ChartRow                = 27 # place the chart below row 22nd
    ChartColumn             = 2
    Activate                = $true
    PivotFilter             = 'Resource Group', 'Resource Type'
    ChartTitle              = 'Resources by Subscription'
    NoLegend                = $true
    ShowPercent             = $true
    ChartHeight             = 655
    ChartWidth              = 570
    ChartRowOffSetPixels    = 5
    ChartColumnOffSetPixels = 5
}
Add-PivotTable @PTParams


if ($P2Name -eq 'Security Center') {
    $PTParams = @{
        PivotTableName          = "P2"
        Address                 = $excel.Overview.cells["BG5"] # top-left corner of the table
        SourceWorkSheet         = $excel.SecurityCenter
        PivotRows               = @("Severity")
        PivotData               = @{"Resource Name" = "Count" }
        PivotTableStyle         = $tableStyle
        IncludePivotChart       = $true
        ChartType               = "ColumnStacked3D"
        ChartRow                = 21 # place the chart below row 22nd
        ChartColumn             = 11
        Activate                = $true
        ChartTitle              = 'Security Center'
        PivotFilter             = 'Categories'
        ShowPercent             = $true
        ChartHeight             = 255
        ChartWidth              = 315
        ChartRowOffSetPixels    = 5
        ChartColumnOffSetPixels = 5
    }

    Add-PivotTable @PTParams -NoLegend
}
elseif ($P2Name -eq 'Annual Savings') {
    $PTParams = @{
        PivotTableName          = "P2"
        Address                 = $excel.Overview.cells["BG5"] # top-left corner of the table
        SourceWorkSheet         = $excel.Advisory
        PivotRows               = @("Savings Currency")
        PivotData               = @{"Annual Savings" = "Sum" }
        PivotTableStyle         = $tableStyle
        IncludePivotChart       = $true
        ChartType               = "ColumnStacked3D"
        ChartRow                = 21 # place the chart below row 22nd
        ChartColumn             = 11
        Activate                = $true
        ChartTitle              = 'Potencial Savings'
        PivotFilter             = 'Savings Region'
        ShowPercent             = $true
        ChartHeight             = 255
        ChartWidth              = 315
        ChartRowOffSetPixels    = 5
        ChartColumnOffSetPixels = 5
        PivotNumberFormat       = '#,##0.00'
    }

    Add-PivotTable @PTParams -NoLegend
}
else {
    $PTParams = @{
        PivotTableName          = "P2"
        Address                 = $excel.Overview.cells["BG5"] # top-left corner of the table
        SourceWorkSheet         = $excel.'Virtual Networks'
        PivotRows               = @("Location")
        PivotData               = @{"Location" = "Count" }
        PivotTableStyle         = $tableStyle
        IncludePivotChart       = $true
        ChartType               = "ColumnStacked3D"
        ChartRow                = 21 # place the chart below row 22nd
        ChartColumn             = 11
        Activate                = $true
        ChartTitle              = 'Virtual Networks'
        PivotFilter             = 'Subscription'
        ShowPercent             = $true
        ChartHeight             = 255
        ChartWidth              = 315
        ChartRowOffSetPixels    = 5
        ChartColumnOffSetPixels = 5
    }
    
    Add-PivotTable @PTParams -NoLegend
}


if ($P3Name -eq 'Azure Kubernetes') {
    $PTParams = @{
        PivotTableName          = "P3"
        Address                 = $excel.Overview.cells["BJ5"] # top-left corner of the table
        SourceWorkSheet         = $excel.AKS
        PivotRows               = @("Kubernetes Version")
        PivotData               = @{"Clusters" = "Count" }
        PivotTableStyle         = $tableStyle
        IncludePivotChart       = $true
        ChartType               = "Pie3D"
        ChartRow                = 34 # place the chart below row 22nd
        ChartColumn             = 11
        Activate                = $true
        ChartTitle              = 'AKS Versions'
        PivotFilter             = 'Node Size'
        ShowPercent             = $true
        ChartHeight             = 255
        ChartWidth              = 315
        ChartRowOffSetPixels    = 5
        ChartColumnOffSetPixels = 5
    }
    
    Add-PivotTable @PTParams
}
else {
    $PTParams = @{
        PivotTableName          = "P3"
        Address                 = $excel.Overview.cells["BJ5"] # top-left corner of the table
        SourceWorkSheet         = $excel.'Storage Acc'
        PivotRows               = @("Tier")
        PivotData               = @{"Tier" = "Count" }
        PivotTableStyle         = $tableStyle
        IncludePivotChart       = $true
        ChartType               = "Pie3D"
        ChartRow                = 34 # place the chart below row 22nd
        ChartColumn             = 11
        Activate                = $true
        PivotFilter             = 'SKU'
        ChartTitle              = 'Storage Accounts'
        ShowPercent             = $true
        ChartHeight             = 255
        ChartWidth              = 315
        ChartRowOffSetPixels    = 5
        ChartColumnOffSetPixels = 5
    }
    
    Add-PivotTable @PTParams
}



if ($P4Name -eq 'Quota Usage') {
    $PTParams = @{
        PivotTableName          = "P4"
        Address                 = $excel.Overview.cells["BM5"] # top-left corner of the table
        SourceWorkSheet         = $excel.'Quota Usage'
        PivotRows               = @("Region")
        PivotData               = @{"vCPUs Available" = "Sum" }
        PivotTableStyle         = $tableStyle
        IncludePivotChart       = $true
        ChartType               = "ColumnStacked3D"
        ChartRow                = 47 # place the chart below row 22nd
        ChartColumn             = 11
        Activate                = $true
        PivotFilter             = 'Limit'
        ChartTitle              = 'Available Quota (vCPUs)'
        ShowPercent             = $true
        ChartHeight             = 255
        ChartWidth              = 315
        ChartRowOffSetPixels    = 5
        ChartColumnOffSetPixels = 5
    }
    
    Add-PivotTable @PTParams -NoLegend
}
else {
    $PTParams = @{
        PivotTableName          = "P4"
        Address                 = $excel.Overview.cells["BM5"] # top-left corner of the table
        SourceWorkSheet         = $excel.Disks
        PivotRows               = @("Disk State")
        PivotData               = @{"Disk State" = "Count" }
        PivotTableStyle         = $tableStyle
        IncludePivotChart       = $true
        ChartType               = "ColumnStacked3D"
        ChartRow                = 47 # place the chart below row 22nd
        ChartColumn             = 11
        Activate                = $true
        PivotFilter             = 'SKU'
        ChartTitle              = 'VM Disks'
        ShowPercent             = $true
        ChartHeight             = 255
        ChartWidth              = 315
        ChartRowOffSetPixels    = 5
        ChartColumnOffSetPixels = 5
    }
    
    Add-PivotTable @PTParams -NoLegend
}



if ($P5Name -eq 'Virtual Machines') {
    $PTParams = @{
        PivotTableName          = "P5"
        Address                 = $excel.Overview.cells["BP7"] # top-left corner of the table
        SourceWorkSheet         = $excel.'Virtual Machines'
        PivotRows               = @("VM Size")
        PivotData               = @{"Resource U" = "Sum" }
        PivotTableStyle         = $tableStyle
        IncludePivotChart       = $true
        ChartType               = "BarClustered"
        ChartRow                = 21 # place the chart below row 22nd
        ChartColumn             = 16
        Activate                = $true
        NoLegend                = $true
        ChartTitle              = 'Virtual Machines by Serie'
        PivotFilter             = 'OS Type', 'Location', 'Power State'
        ShowPercent             = $true
        ChartHeight             = 775
        ChartWidth              = 502
        ChartRowOffSetPixels    = 5
        ChartColumnOffSetPixels = 5
    }
    
    Add-PivotTable @PTParams
}

$PTParams = @{
    PivotTableName          = "P6"
    Address                 = $excel.Overview.cells["BS5"] # top-left corner of the table
    SourceWorkSheet         = $excel.Subscriptions
    PivotRows               = @("Location")
    PivotData               = @{"Resources" = "sum" }
    PivotTableStyle         = $tableStyle
    IncludePivotChart       = $true
    ChartType               = "ColumnStacked3D"
    ChartRow                = 1 # place the chart below row 22nd
    ChartColumn             = 24
    Activate                = $true
    PivotFilter             = 'Resource Type'
    ChartTitle              = 'Resources by Location'
    NoLegend                = $true
    ShowPercent             = $true
    ChartHeight             = 400
    ChartWidth              = 315
    ChartRowOffSetPixels    = 0
    ChartColumnOffSetPixels = 0
}

Add-PivotTable @PTParams


if ($P7Name -eq 'Virtual Machines') {
    $PTParams = @{
        PivotTableName          = "P7"
        Address                 = $excel.Overview.cells["BV5"] # top-left corner of the table
        SourceWorkSheet         = $excel.'Virtual Machines'
        PivotRows               = @("OS Type")
        PivotData               = @{"Resource U" = "Sum" }
        PivotTableStyle         = $tableStyle
        IncludePivotChart       = $true
        ChartType               = "Pie3D"
        ChartRow                = 21 # place the chart below row 22nd
        ChartColumn             = 24
        Activate                = $true
        NoLegend                = $true
        ChartTitle              = 'VMs by OS'
        PivotFilter             = 'Location'
        ShowPercent             = $true
        ChartHeight             = 255
        ChartWidth              = 315
        ChartRowOffSetPixels    = 5
        ChartColumnOffSetPixels = 0
    }
    
    Add-PivotTable @PTParams
}

if ($P8Name -eq 'Advisories') {
    $PTParams = @{
        PivotTableName          = "P8"
        Address                 = $excel.Overview.cells["BY5"] # top-left corner of the table
        SourceWorkSheet         = $excel.Advisory
        PivotRows               = @("Impact")
        PivotData               = @{"Impact" = "Count" }
        PivotTableStyle         = $tableStyle
        IncludePivotChart       = $true
        ChartType               = "BarStacked3D"
        ChartRow                = 34
        ChartColumn             = 24
        Activate                = $true
        PivotFilter             = 'Category'
        ChartTitle              = 'Advisories'
        ShowPercent             = $true
        ChartHeight             = 255
        ChartWidth              = 315
        ChartRowOffSetPixels    = 5
        ChartColumnOffSetPixels = 0
    }
    Add-PivotTable @PTParams -NoLegend
}

if ($P9Name -eq 'Virtual Machines') {
    $PTParams = @{
        PivotTableName          = "P9"
        Address                 = $excel.Overview.cells["CB5"] # top-left corner of the table
        SourceWorkSheet         = $excel.'Virtual Machines'
        PivotRows               = @("Boot Diagnostics")
        PivotData               = @{"Resource U" = "Sum" }
        PivotTableStyle         = $tableStyle
        IncludePivotChart       = $true
        ChartType               = "Pie3D"
        ChartRow                = 47 
        ChartColumn             = 24
        Activate                = $true
        NoLegend                = $true
        ChartTitle              = 'Boot Diagnostics'
        PivotFilter             = 'Location'
        ShowPercent             = $true
        ChartHeight             = 255
        ChartWidth              = 315
        ChartRowOffSetPixels    = 5
        ChartColumnOffSetPixels = 0
    }
    
    Add-PivotTable @PTParams
}





Close-ExcelPackage $excel



$application = New-Object -ComObject Excel.Application
if ($application) {
    $Ex = $application.Workbooks.Open($File)
    Start-Sleep -Seconds 2    
    $WS = $ex.Worksheets | Where-Object { $_.Name -eq 'Overview' }

    $NoChangeChart = ('ChartP0', 'ChartP1', 'ChartP2', 'ChartP3', 'ChartP4', 'ChartP5', 'ChartP6', 'ChartP7', 'ChartP8', 'ChartP9', 'ARI', 'RGs', 'TP00', 'TP0', 'TP1', 'TP2', 'TP3', 'TP4', 'TP5','TP6','TP7','TP8','TP9')
    $ChangeChart = ('ARI', 'RGs', 'TP00', 'TP0', 'TP1', 'TP2', 'TP3', 'TP4', 'TP5', 'TP6', 'TP7','TP8','TP9')

    ($WS.Shapes | Where-Object { $_.name -eq 'ChartP0' }).DrawingObject.Chart.ChartStyle = 294  
    ($WS.Shapes | Where-Object { $_.name -eq 'ChartP1' }).DrawingObject.Chart.ChartStyle = 222
    ($WS.Shapes | Where-Object { $_.name -eq 'ChartP2' }).DrawingObject.Chart.ChartStyle = 294
    ($WS.Shapes | Where-Object { $_.name -eq 'ChartP3' }).DrawingObject.Chart.ChartStyle = 268
    ($WS.Shapes | Where-Object { $_.name -eq 'ChartP4' }).DrawingObject.Chart.ChartStyle = 294
    ($WS.Shapes | Where-Object { $_.name -eq 'ChartP5' }).DrawingObject.Chart.ChartStyle = 222
    ($WS.Shapes | Where-Object { $_.name -eq 'ChartP6' }).DrawingObject.Chart.ChartStyle = 294
    ($WS.Shapes | Where-Object { $_.name -eq 'ChartP7' }).DrawingObject.Chart.ChartStyle = 268
    ($WS.Shapes | Where-Object { $_.name -eq 'ChartP8' }).DrawingObject.Chart.ChartStyle = 294
    ($WS.Shapes | Where-Object { $_.name -eq 'ChartP9' }).DrawingObject.Chart.ChartStyle = 268
    ($WS.Shapes | Where-Object { $_.name -notin $NoChangeChart -and $_.name -like 'Chart*' }).DrawingObject.Chart.ChartStyle = 315

    Foreach ($Changer in $ChangeChart) {
        ($WS.Shapes | Where-Object { $_.name -eq $Changer }).DrawingObject.interior.color = 2500134
        ($WS.Shapes | Where-Object { $_.name -eq $Changer }).DrawingObject.border.color = 16777215
        ($WS.Shapes | Where-Object { $_.name -eq $Changer }).DrawingObject.border.ColorIndex = -4142
        ($WS.Shapes | Where-Object { $_.name -eq $Changer }).DrawingObject.border.LineStyle = -4142
    }

    #$WS.Cells.Interior.Color = 0

    $Draw = ($WS.Shapes | Where-Object {$_.name -eq 'ARI'})
    $Draw.Adjustments(1) = 0.07

    $Ex.Save()
    $Ex.Close()
    $application.Quit()
    Get-Process -Name "excel" -ErrorAction Ignore | Stop-Process
}


