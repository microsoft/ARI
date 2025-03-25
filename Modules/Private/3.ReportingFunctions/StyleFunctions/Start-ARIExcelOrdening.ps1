function Start-ARIExcelOrdening {
    Param($File, $Debug)
    if ($Debug.IsPresent)
        {
            $DebugPreference = 'Continue'
            $ErrorActionPreference = 'Continue'
        }
    else
        {
            $ErrorActionPreference = "silentlycontinue"
        }

    $Excel = Open-ExcelPackage -Path $File
    $Worksheets = $Excel.Workbook.Worksheets

    $Order = $Worksheets | Where-Object { $_.Name -notin 'Overview','Policy', 'Advisor', 'Security Center', 'Subscriptions', 'Quota Usage', 'AdvisorScore', 'Outages', 'SupportTickets', 'Reservation Advisor' } | Select-Object -Property Index, name, @{N = "Dimension"; E = { $_.dimension.Rows - 1 } } | Sort-Object -Property Dimension -Descending

    $Order0 = $Order | Where-Object { $_.Name -ne $Order[0].name -and $_.Name -ne ($Order | select-object -Last 1).Name }

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Validating if Advisor and Policies are included.')
    if (($Worksheets | Where-Object { $_.Name -eq 'Advisor'}))
        {
            $Worksheets.MoveAfter($Order[0].Name, 'Advisor')
        }
    if (($Worksheets | Where-Object { $_.Name -eq 'Policy'}))
        {
            $Worksheets.MoveAfter($Order[0].Name, 'Policy')
        }
    $Worksheets.MoveAfter(($Order | select-object -Last 1).Name, 'Subscriptions')

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

    $Worksheets = $Excel.Workbook.Worksheets
    $WS = $Excel.Workbook.Worksheets | Where-Object { $_.Name -eq 'Overview' }

    $WS.SetValue(75,70,'')
    $WS.SetValue(76,70,'')
    $WS.View.ShowGridLines = $false

    $Worksheets = $Excel.Workbook.Worksheets | Where-Object { $_.name -notin 'Overview', 'Advisor', 'Policy', 'SecurityCenter'}
    $WS = $Excel.Workbook.Worksheets | Where-Object { $_.Name -eq 'Overview' }

    $TabDraw = $WS.Drawings.AddShape('TP00', 'RoundRect')
    $TabDraw.SetSize(130 , 78)
    $TabDraw.SetPosition(1, 0, 0, 0)
    $TabDraw.TextAlignment = 'Center'

    Close-ExcelPackage $Excel

}