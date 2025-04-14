<#
.Synopsis
Module for Excel Chart Creation

.DESCRIPTION
This script creates charts in the Overview sheet of the Excel report.

.Link
https://github.com/microsoft/ARI/Modules/Private/3.ReportingFunctions/StyleFunctions/Build-ARIExcelChart.ps1

.COMPONENT
This PowerShell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.6.0
First Release Date: 15th Oct, 2024
Authors: Claudio Merola
#>
function Build-ARIExcelChart {
    Param($Excel, $Overview, $IncludeCosts)

    $WS = $Excel.Workbook.Worksheets | Where-Object { $_.Name -eq 'Overview' }

    $DrawP00 = $WS.Drawings | Where-Object { $_.Name -eq 'TP00' }
    $P00Name = 'Reported Resources'
    $DrawP00.RichText.Add($P00Name).Size = 16

    if($IncludeCosts.IsPresent)
        {
            $PTParams = @{
                PivotTableName          = "P00"
                Address                 = $excel.Overview.cells["BA5"] # top-left corner of the table
                SourceWorkSheet         = $excel.'Subscriptions'
                PivotRows               = @("Subscription")
                PivotData               = @{"Cost" = "Sum" }
                PivotColumns            = @("Month")
                PivotTableStyle         = $TableStyle
                IncludePivotChart       = $true
                ChartType               = "ColumnStacked3D"
                ChartRow                = 1 # place the chart below row 22nd
                ChartColumn             = 9
                Activate                = $true
                PivotNumberFormat       = 'Currency'
                PivotFilter             = 'Resource Type'
                PivotTotals             = 'Rows'
                ShowCategory            = $false
                NoLegend                = $true
                ChartTitle              = 'Azure Cost per Subscription'
                ShowPercent             = $true
                ChartHeight             = 400
                ChartWidth              = 950
                ChartRowOffSetPixels    = 0
                ChartColumnOffSetPixels = 5
            }
            Add-PivotTable @PTParams
        }
    elseif ($Excel.Workbook.Worksheets | Where-Object { $_.Name -eq 'Reservation Advisor' }) {
        $PTParams = @{
            PivotTableName          = "P00"
            Address                 = $excel.Overview.cells["BA5"] # top-left corner of the table
            SourceWorkSheet         = $excel.'Reservation Advisor'
            PivotRows               = @("Subscription")
            PivotData               = @{"Net Savings" = "Sum" }
            PivotTableStyle         = $TableStyle
            IncludePivotChart       = $true
            ChartType               = "ColumnStacked3D"
            ChartRow                = 1 # place the chart below row 22nd
            ChartColumn             = 9
            Activate                = $true
            PivotNumberFormat       = '$#'
            PivotFilter             = 'Recommended Size'
            PivotTotals             = 'Both'
            ShowCategory            = $false
            NoLegend                = $true
            ChartTitle              = 'Potential Net Savings (VM Reservation)'
            ShowPercent             = $true
            ChartHeight             = 400
            ChartWidth              = 950
            ChartRowOffSetPixels    = 0
            ChartColumnOffSetPixels = 5
        }
        Add-PivotTable @PTParams
    }
    else
        {
            Add-ExcelChart -Worksheet $excel.Overview -ChartType Area3D -XRange "AzureTabs[Name]" -YRange "AzureTabs[Size]" -SeriesHeader 'Resources', 'Count' -Column 9 -Row 1 -Height 400 -Width 950 -RowOffSetPixels 0 -ColumnOffSetPixels 5 -NoLegend
        }

    if($IncludeCosts.IsPresent)
        {
            $P0Name = 'CostPerRegion'
            $PTParams = @{
                PivotTableName          = "P0"
                Address                 = $excel.Overview.cells["BG5"] # top-left corner of the table
                SourceWorkSheet         = $excel.'Subscriptions'
                PivotRows               = @("Location")
                PivotData               = @{"Cost" = "Sum" }
                PivotColumns            = @("Month")
                PivotTableStyle         = $tableStyle
                IncludePivotChart       = $true
                ChartType               = "BarStacked3D"
                ChartRow                = 13 # place the chart below row 22nd
                ChartColumn             = 2
                Activate                = $true
                PivotNumberFormat       = 'Currency'
                PivotFilter             = 'Subscription'
                ChartTitle              = 'Cost by Azure Region'
                ShowPercent             = $true
                ChartHeight             = 275
                ChartWidth              = 445
                ChartRowOffSetPixels    = 5
                ChartColumnOffSetPixels = 5
            }
            Add-PivotTable @PTParams -NoLegend
    }
    elseif (($Excel.Workbook.Worksheets | Where-Object { $_.Name -eq 'Outages' }) -and $Overview -eq 1) {
        $P0Name = 'Outages'
        $PTParams = @{
            PivotTableName          = "P0"
            Address                 = $excel.Overview.cells["BG5"] # top-left corner of the table
            SourceWorkSheet         = $excel.'Outages'
            PivotRows               = @("Impacted Services")
            PivotData               = @{"Impacted Services" = "Count" }
            PivotTableStyle         = $tableStyle
            IncludePivotChart       = $true
            ChartType               = "BarStacked3D"
            ChartRow                = 13 # place the chart below row 22nd
            ChartColumn             = 2
            Activate                = $true
            PivotFilter             = 'Subscription'
            ChartTitle              = 'Outages (Last 6 Months)'
            ShowPercent             = $true
            ChartHeight             = 275
            ChartWidth              = 445
            ChartRowOffSetPixels    = 5
            ChartColumnOffSetPixels = 5
        }
        Add-PivotTable @PTParams -NoLegend
    }
    elseif (($Excel.Workbook.Worksheets | Where-Object { $_.Name -eq 'Advisor' }) -and $Overview -eq 2) {
        $P0Name = 'Advisories'
        $PTParams = @{
            PivotTableName          = "P0"
            Address                 = $excel.Overview.cells["BG5"] # top-left corner of the table
            SourceWorkSheet         = $excel.Advisor
            PivotRows               = @("Category")
            PivotData               = @{"Category" = "Count" }
            PivotTableStyle         = $tableStyle
            IncludePivotChart       = $true
            ChartType               = "BarStacked3D"
            ChartRow                = 13 # place the chart below row 22nd
            ChartColumn             = 2
            Activate                = $true
            PivotFilter             = 'Impact'
            ChartTitle              = 'Advisor'
            ShowPercent             = $true
            ChartHeight             = 275
            ChartWidth              = 445
            ChartRowOffSetPixels    = 5
            ChartColumnOffSetPixels = 5
        }
        Add-PivotTable @PTParams -NoLegend
    }
    else {
        $P0Name = 'Public IPs'
        $PTParams = @{
            PivotTableName          = "P0"
            Address                 = $excel.Overview.cells["BG5"] # top-left corner of the table
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

    $DrawP0 = $WS.Drawings | Where-Object { $_.Name -eq 'TP0' }
    $DrawP0.RichText.Add($P0Name) | Out-Null

    if($IncludeCosts.IsPresent)
        {
            $P1Name = 'TotalCostsPerSubscription'
            $PTParams = @{
                PivotTableName          = "P1"
                Address                 = $excel.Overview.cells["DK6"] # top-left corner of the table
                SourceWorkSheet         = $excel.'Subscriptions'
                PivotRows               = @('Month')
                PivotColumns            = @("Resource Type")
                PivotData               = @{"Cost" = "Sum" }
                PivotTableStyle         = $tableStyle
                IncludePivotChart       = $true
                ChartType               = "BarClustered"
                ChartRow                = 27 # place the chart below row 22nd
                ChartColumn             = 2
                Activate                = $true
                PivotNumberFormat       = 'Currency'
                ShowCategory            = $false
                ChartTitle              = 'Cost by Resource Type'
                NoLegend                = $true
                ShowPercent             = $true
                ChartHeight             = 655
                ChartWidth              = 570
                ChartRowOffSetPixels    = 5
                ChartColumnOffSetPixels = 5
            }
            Add-PivotTable @PTParams
        }
    elseif (($Excel.Workbook.Worksheets | Where-Object { $_.Name -eq 'AdvisorScore' }) -and $Overview -eq 1) {
        $P1Name = 'AdvisorScore'
        $PTParams = @{
            PivotTableName          = "P1"
            Address                 = $excel.Overview.cells["DK6"] # top-left corner of the table
            SourceWorkSheet         = $excel.AdvisorScore
            PivotRows               = @("Category")
            PivotData               = @{"Latest Score (%)" = "average" }
            PivotTableStyle         = $tableStyle
            IncludePivotChart       = $true
            ChartType               = "BarClustered"
            ChartRow                = 27 # place the chart below row 22nd
            ChartColumn             = 2
            Activate                = $true
            #PivotNumberFormat       = '0'
            ShowCategory            = $false
            PivotFilter             = 'Subscription'
            ChartTitle              = 'Advisor Score (%)'
            NoLegend                = $true
            ShowPercent             = $true
            ChartHeight             = 655
            ChartWidth              = 570
            ChartRowOffSetPixels    = 5
            ChartColumnOffSetPixels = 5
        }
        Add-PivotTable @PTParams
    }
    elseif (($Excel.Workbook.Worksheets | Where-Object { $_.Name -eq 'Subscriptions' }) -and $Overview -eq 2) {
        $P1Name = 'Subscriptions'
        $PTParams = @{
            PivotTableName          = "P1"
            Address                 = $excel.Overview.cells["DK6"] # top-left corner of the table
            SourceWorkSheet         = $excel.Subscriptions
            PivotRows               = @("Subscription")
            PivotData               = @{"Resources Count" = "sum" }
            PivotTableStyle         = $tableStyle
            IncludePivotChart       = $true
            ChartType               = "BarClustered"
            ChartRow                = 27 # place the chart below row 22nd
            ChartColumn             = 2
            Activate                = $true
            PivotFilter             = 'Resource Group'
            ChartTitle              = 'Resources by Subscription'
            NoLegend                = $true
            ShowPercent             = $true
            ChartHeight             = 655
            ChartWidth              = 570
            ChartRowOffSetPixels    = 5
            ChartColumnOffSetPixels = 5
        }
        Add-PivotTable @PTParams
    }
    elseif (($Excel.Workbook.Worksheets | Where-Object { $_.Name -eq 'Quota Usage' }) -and $Overview -eq 1) {
        $P1Name = 'Quota Usage'
        $PTParams = @{
            PivotTableName          = "P1"
            Address                 = $excel.Overview.cells["DK6"] # top-left corner of the table
            SourceWorkSheet         = $excel.'Quota Usage'
            PivotRows               = @("Region")
            PivotData               = @{"vCPUs Available" = "Sum" }
            PivotTableStyle         = $tableStyle
            IncludePivotChart       = $true
            ChartType               = "BarClustered"
            ChartRow                = 27 # place the chart below row 22nd
            ChartColumn             = 2
            Activate                = $true
            PivotFilter             = 'Limit'
            ChartTitle              = 'Available Quota (vCPUs)'
            NoLegend                = $true
            ShowPercent             = $true
            ChartHeight             = 655
            ChartWidth              = 570
            ChartRowOffSetPixels    = 5
            ChartColumnOffSetPixels = 5
        }
        Add-PivotTable @PTParams
    }
    else {
        $P1Name = 'Virtual Networks'
        $PTParams = @{
            PivotTableName          = "P1"
            Address                 = $excel.Overview.cells["DK6"] # top-left corner of the table
            SourceWorkSheet         = $excel.'Virtual Networks'
            PivotRows               = @("Name")
            PivotData               = @{"Available IPs" = "Sum" }
            PivotTableStyle         = $tableStyle
            IncludePivotChart       = $true
            ChartType               = "BarClustered"
            ChartRow                = 27 # place the chart below row 22nd
            ChartColumn             = 2
            Activate                = $true
            PivotFilter             = 'Location'
            ChartTitle              = 'Available IPs (Per Virtual Network)'
            NoLegend                = $true
            ShowPercent             = $true
            ChartHeight             = 655
            ChartWidth              = 570
            ChartRowOffSetPixels    = 5
            ChartColumnOffSetPixels = 5
        }
        Add-PivotTable @PTParams
    }
    $DrawP1 = $WS.Drawings | Where-Object { $_.Name -eq 'TP1' }
    $DrawP1.RichText.Add($P1Name) | Out-Null

    if (($Excel.Workbook.Worksheets | Where-Object { $_.Name -eq 'Policy' }) -and $Overview -eq 1) {
        $P2Name = 'Policy'
        $PTParams = @{
            PivotTableName          = "P2"
            Address                 = $excel.Overview.cells["BT5"] # top-left corner of the table
            SourceWorkSheet         = $excel.Policy
            PivotRows               = @("Policy Category")
            PivotData               = @{"Policy" = "Count" }
            PivotTableStyle         = $tableStyle
            IncludePivotChart       = $true
            ChartType               = "ColumnStacked3D"
            ChartRow                = 21 # place the chart below row 22nd
            ChartColumn             = 11
            Activate                = $true
            PivotFilter             = 'Policy Type'
            ChartTitle              = 'Policies by Category'
            ShowPercent             = $true
            ChartHeight             = 255
            ChartWidth              = 315
            ChartRowOffSetPixels    = 5
            ChartColumnOffSetPixels = 5
        }
        Add-PivotTable @PTParams -NoLegend
    }
    elseif (($Excel.Workbook.Worksheets | Where-Object { $_.Name -eq 'Advisor' }) -and $Overview -eq 2) {
        $P2Name = 'Annual Savings'
        $PTParams = @{
            PivotTableName          = "P2"
            Address                 = $excel.Overview.cells["BT5"] # top-left corner of the table
            SourceWorkSheet         = $excel.Advisor
            PivotRows               = @("Savings Currency")
            PivotData               = @{"Annual Savings" = "Sum" }
            PivotTableStyle         = $tableStyle
            IncludePivotChart       = $true
            ChartType               = "ColumnStacked3D"
            ChartRow                = 21 # place the chart below row 22nd
            ChartColumn             = 11
            Activate                = $true
            ChartTitle              = 'Potential Savings'
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
        $P2Name = 'Virtual Networks'
        $PTParams = @{
            PivotTableName          = "P2"
            Address                 = $excel.Overview.cells["BT5"] # top-left corner of the table
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

    $DrawP2 = $WS.Drawings | Where-Object { $_.Name -eq 'TP2' }
    $DrawP2.RichText.Add($P2Name) | Out-Null

    if (($Excel.Workbook.Worksheets | Where-Object { $_.Name -eq 'Support Tickets' }) -and $Overview -eq 1) {
        $P3Name = 'Support Tickets'
        $PTParams = @{
            PivotTableName          = "P3"
            Address                 = $excel.Overview.cells["BZ5"] # top-left corner of the table
            SourceWorkSheet         = $excel.'Support Tickets'
            PivotRows               = @("Status")
            PivotData               = @{"Status" = "Count" }
            PivotTableStyle         = $tableStyle
            IncludePivotChart       = $true
            ChartType               = "Pie3D"
            ChartRow                = 34 # place the chart below row 22nd
            ChartColumn             = 11
            Activate                = $true
            PivotFilter             = 'Current Severity'
            ChartTitle              = 'Support Tickets'
            ShowPercent             = $true
            ChartHeight             = 255
            ChartWidth              = 315
            ChartRowOffSetPixels    = 5
            ChartColumnOffSetPixels = 5
        }
        Add-PivotTable @PTParams
    }
    elseif (($Excel.Workbook.Worksheets | Where-Object { $_.Name -eq 'AKS' }) -and $Overview -eq 2) {
        $P3Name = 'Azure Kubernetes'
        $PTParams = @{
            PivotTableName          = "P3"
            Address                 = $excel.Overview.cells["BZ5"] # top-left corner of the table
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
            PivotFilter             = 'Node Pool Size'
            ShowPercent             = $true
            ChartHeight             = 255
            ChartWidth              = 315
            ChartRowOffSetPixels    = 5
            ChartColumnOffSetPixels = 5
        }
        Add-PivotTable @PTParams
    }
    else {
        $P3Name = 'Storage Accounts'
        $PTParams = @{
            PivotTableName          = "P3"
            Address                 = $excel.Overview.cells["BZ5"] # top-left corner of the table
            SourceWorkSheet         = $excel.'Storage Accounts'
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
    $DrawP3 = $WS.Drawings | Where-Object { $_.Name -eq 'TP3' }
    $DrawP3.RichText.Add($P3Name) | Out-Null

    if (($Excel.Workbook.Worksheets | Where-Object { $_.Name -eq 'Outages' }) -and $Overview -eq 1) {
        $P4Name = 'Outages'
        $PTParams = @{
            PivotTableName          = "P4"
            Address                 = $excel.Overview.cells["CF5"] # top-left corner of the table
            SourceWorkSheet         = $excel.'Outages'
            PivotRows               = @("Subscription")
            PivotData               = @{"Outage ID" = "Count" }
            PivotTableStyle         = $tableStyle
            IncludePivotChart       = $true
            ChartType               = "ColumnStacked3D"
            ChartRow                = 47 # place the chart below row 22nd
            ChartColumn             = 11
            Activate                = $true
            PivotFilter             = 'Event Level'
            ChartTitle              = 'Outages per Subscription'
            ShowPercent             = $true
            ChartHeight             = 255
            ChartWidth              = 315
            ChartRowOffSetPixels    = 5
            ChartColumnOffSetPixels = 5
        }
        Add-PivotTable @PTParams -NoLegend
    }
    elseif (($Excel.Workbook.Worksheets | Where-Object { $_.Name -eq 'Quota Usage' }) -and $Overview -eq 2) {
        $P4Name = 'Quota Usage'
        $PTParams = @{
            PivotTableName          = "P4"
            Address                 = $excel.Overview.cells["CF5"] # top-left corner of the table
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
        $P4Name = 'VM Disks'
        $PTParams = @{
            PivotTableName          = "P4"
            Address                 = $excel.Overview.cells["CF5"] # top-left corner of the table
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

    $DrawP4 = $WS.Drawings | Where-Object { $_.Name -eq 'TP4' }
    $DrawP4.RichText.Add($P4Name) | Out-Null

    if ($Excel.Workbook.Worksheets | Where-Object { $_.Name -eq 'Virtual Machines' }) {
        $P5Name = 'Virtual Machines'
        $PTParams = @{
            PivotTableName          = "P5"
            Address                 = $excel.Overview.cells["CL7"] # top-left corner of the table
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
    } else {
        $P5Name = 'Virtual Networks'
        $PTParams = @{
            PivotTableName          = "P5"
            Address                 = $excel.Overview.cells["CL7"] # top-left corner of the table
            SourceWorkSheet         = $excel.'Virtual Networks'
            PivotRows               = @("Name")
            PivotData               = @{"Available IPs" = "Sum" }
            PivotTableStyle         = $tableStyle
            IncludePivotChart       = $true
            ChartType               = "BarClustered"
            ChartRow                = 21 # place the chart below row 22nd
            ChartColumn             = 16
            Activate                = $true
            NoLegend                = $true
            ChartTitle              = 'Available IPs (Per Virtual Network)'
            PivotFilter             = 'Location'
            ShowPercent             = $true
            ChartHeight             = 775
            ChartWidth              = 502
            ChartRowOffSetPixels    = 5
            ChartColumnOffSetPixels = 5
        }
        Add-PivotTable @PTParams
    }

    $DrawP5 = $WS.Drawings | Where-Object { $_.Name -eq 'TP5' }
    $DrawP5.RichText.Add($P5Name) | Out-Null

    if($IncludeCosts.IsPresent)
        {
            $P6Name = 'Cost per Month'
            $PTParams = @{
                PivotTableName          = "P6"
                Address                 = $excel.Overview.cells["CR5"] # top-left corner of the table
                SourceWorkSheet         = $excel.Subscriptions
                PivotRows               = @("Month")
                PivotData               = @{"Cost" = "sum" }
                PivotTableStyle         = $tableStyle
                IncludePivotChart       = $true
                ChartType               = "ColumnStacked3D"
                ChartRow                = 1 # place the chart below row 22nd
                ChartColumn             = 24
                Activate                = $true
                PivotNumberFormat       = 'Currency'
                PivotFilter             = 'Subscription'
                ChartTitle              = 'Cost per Month'
                NoLegend                = $true
                ShowPercent             = $true
                ChartHeight             = 400
                ChartWidth              = 315
                ChartRowOffSetPixels    = 0
                ChartColumnOffSetPixels = 0
            }
            Add-PivotTable @PTParams
        }
    else
        {
    $P6Name = 'Resources by Location'
    $PTParams = @{
        PivotTableName          = "P6"
        Address                 = $excel.Overview.cells["CR5"] # top-left corner of the table
        SourceWorkSheet         = $excel.Subscriptions
        PivotRows               = @("Location")
        PivotData               = @{"Resources Count" = "sum" }
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
    }

    $DrawP6 = $WS.Drawings | Where-Object { $_.Name -eq 'TP6' }
    $DrawP6.RichText.Add($P6Name) | Out-Null

    if ($Excel.Workbook.Worksheets | Where-Object { $_.Name -eq 'Virtual Machines' }) {
        $P7Name = 'Virtual Machines'
        $PTParams = @{
            PivotTableName          = "P7"
            Address                 = $excel.Overview.cells["CY5"] # top-left corner of the table
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

    $DrawP7 = $WS.Drawings | Where-Object { $_.Name -eq 'TP7' }
    $DrawP7.RichText.Add($P7Name) | Out-Null

    if ($Excel.Workbook.Worksheets | Where-Object { $_.Name -eq 'Advisor' }) {
        $P8Name = 'Advisories'
        $PTParams = @{
            PivotTableName          = "P8"
            Address                 = $excel.Overview.cells["DE5"] # top-left corner of the table
            SourceWorkSheet         = $excel.Advisor
            PivotRows               = @("Impact")
            PivotData               = @{"Impact" = "Count" }
            PivotTableStyle         = $tableStyle
            IncludePivotChart       = $true
            ChartType               = "BarStacked3D"
            ChartRow                = 34
            ChartColumn             = 24
            Activate                = $true
            PivotFilter             = 'Category'
            ChartTitle              = 'Advisor'
            ShowPercent             = $true
            ChartHeight             = 255
            ChartWidth              = 315
            ChartRowOffSetPixels    = 5
            ChartColumnOffSetPixels = 0
        }
        Add-PivotTable @PTParams -NoLegend
    }
    elseif ($Excel.Workbook.Worksheets | Where-Object { $_.Name -eq 'Load Balancers' }) {
        $P8Name = 'Load Balancers'
        $PTParams = @{
            PivotTableName          = "P8"
            Address                 = $excel.Overview.cells["DE5"] # top-left corner of the table
            SourceWorkSheet         = $excel.'Load Balancers'
            PivotRows               = @("Usage")
            PivotData               = @{"Usage" = "Count" }
            PivotTableStyle         = $tableStyle
            IncludePivotChart       = $true
            ChartType               = "BarStacked3D"
            ChartRow                = 34
            ChartColumn             = 24
            Activate                = $true
            PivotFilter             = 'Location'
            ChartTitle              = 'Load Balancers'
            ShowPercent             = $true
            ChartHeight             = 255
            ChartWidth              = 315
            ChartRowOffSetPixels    = 5
            ChartColumnOffSetPixels = 0
        }
        Add-PivotTable @PTParams -NoLegend
    }
    else {
        $P8Name = 'VMs per Region'
        $PTParams = @{
            PivotTableName          = "P8"
            Address                 = $excel.Overview.cells["DE5"] # top-left corner of the table
            SourceWorkSheet         = $excel.'Virtual Machines'
            PivotRows               = @("Location")
            PivotData               = @{"Resource U" = "Sum" }
            PivotTableStyle         = $tableStyle
            IncludePivotChart       = $true
            ChartType               = "BarStacked3D"
            ChartRow                = 34
            ChartColumn             = 24
            Activate                = $true
            PivotFilter             = 'Subscription'
            ChartTitle              = 'VMs by Region'
            ShowPercent             = $true
            ChartHeight             = 255
            ChartWidth              = 315
            ChartRowOffSetPixels    = 5
            ChartColumnOffSetPixels = 0
        }
        Add-PivotTable @PTParams -NoLegend
    }

    $DrawP8 = $WS.Drawings | Where-Object { $_.Name -eq 'TP8' }
    $DrawP8.RichText.Add($P8Name) | Out-Null

    if ($Excel.Workbook.Worksheets | Where-Object { $_.Name -eq 'Virtual Machines' }) {
        $P9Name = 'Virtual Machines'
        $PTParams = @{
            PivotTableName          = "P9"
            Address                 = $excel.Overview.cells["BM5"] # top-left corner of the table
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

    $DrawP9 = $WS.Drawings | Where-Object { $_.Name -eq 'TP9' }
    $DrawP9.RichText.Add($P9Name) | Out-Null

}