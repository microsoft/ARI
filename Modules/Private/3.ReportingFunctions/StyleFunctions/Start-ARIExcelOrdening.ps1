<#
.Synopsis
Module for Excel Sheet Ordering

.DESCRIPTION
This script organizes the order of sheets in the Excel report.

.Link
https://github.com/microsoft/ARI/Modules/Private/3.ReportingFunctions/StyleFunctions/Start-ARIExcelOrdening.ps1

.COMPONENT
This PowerShell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.6.0
First Release Date: 15th Oct, 2024
Authors: Claudio Merola
#>

function Start-ARIExcelOrdening {
    Param($File)

    $Excel = Open-ExcelPackage -Path $File
    $Worksheets = $Excel.Workbook.Worksheets

    $Order = $Worksheets | Where-Object { $_.Name -notin 'Overview','Policy', 'Advisor', 'Security Center', 'Subscriptions', 'Quota Usage', 'AdvisorScore', 'Outages', 'Support Tickets', 'Reservation Advisor' } | Select-Object -Property Index, name, @{N = "Dimension"; E = { $_.dimension.Rows - 1 } } | Sort-Object -Property Dimension -Descending

    $Order0 = $Order | Where-Object { $_.Name -ne $Order[0].name -and $_.Name -ne ($Order | select-object -Last 1).Name }

    #$Worksheets.MoveAfter(($Order | select-object -Last 1).Name, 'Subscriptions')

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

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Validating if Advisor and Policies are included.')
    if (($Worksheets | Where-Object { $_.Name -eq 'Advisor'}))
        {
            $Worksheets.MoveAfter('Advisor', 'Overview')
        }
    if (($Worksheets | Where-Object { $_.Name -eq 'Policy'}))
        {
            $Worksheets.MoveAfter('Policy', 'Overview')
        }
    if (($Worksheets | Where-Object { $_.Name -eq 'Security Center'}))
        {
            $Worksheets.MoveAfter('Security Center', 'Overview')
        }
    if (($Worksheets | Where-Object {$_.Name -eq 'Quota Usage'}))
        {
            $Worksheets.MoveAfter('Quota Usage', 'Overview')
        }
    if (($Worksheets | Where-Object {$_.Name -eq 'AdvisorScore'}))
        {
            $Worksheets.MoveAfter('AdvisorScore', 'Overview')
        }
    if (($Worksheets | Where-Object {$_.Name -eq 'Support Tickets'}))
        {
            $Worksheets.MoveAfter('Support Tickets', 'Overview')
        }
    if (($Worksheets | Where-Object {$_.Name -eq 'Reservation Advisor'}))
        {
            $Worksheets.MoveAfter('Reservation Advisor', 'Overview')
        }
    $Worksheets.MoveAfter('Subscriptions','Overview')

    $WS = $Excel.Workbook.Worksheets | Where-Object { $_.Name -eq 'Overview' }

    $WS.SetValue(75,70,'')
    $WS.SetValue(76,70,'')
    $WS.View.ShowGridLines = $false

    $TabDraw = $WS.Drawings.AddShape('TP00', 'RoundRect')
    $TabDraw.SetSize(130 , 78)
    $TabDraw.SetPosition(1, 0, 0, 0)
    $TabDraw.TextAlignment = 'Center'

    Close-ExcelPackage $Excel

}