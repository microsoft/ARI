function Build-ARIInitialBlock {
    Param($Excel, $ExtractionRunTime, $ProcessingRunTime, $ReportingRunTime, $PlatOS, $ScriptVersion, $TotalRes, $Debug)
    if ($Debug.IsPresent)
        {
            $DebugPreference = 'Continue'
            $ErrorActionPreference = 'Continue'
        }
    else
        {
            $ErrorActionPreference = "silentlycontinue"
        }

    $Date = (get-date -Format "MM/dd/yyyy")
    $Font = 'Segoe UI'

    $ExtractTime = if($ExtractionRunTime.Elapsed.Totalminutes -lt 1){($ExtractionRunTime.Elapsed.Seconds.ToString()+' Seconds')}else{($ExtractionRunTime.Elapsed.Totalminutes.ToString('#######.##')+' Minutes')}
    $ProcessingTime = if($ProcessingRunTime.Elapsed.Totalminutes -lt 1){($ProcessingRunTime.Elapsed.Seconds.ToString()+' Seconds')}else{($ProcessingRunTime.Elapsed.Totalminutes.ToString('#######.##')+' Minutes')}
    $ReportTime = if($ReportingRunTime.Elapsed.Totalminutes -lt 1){($ReportingRunTime.Elapsed.Seconds.ToString()+' Seconds')}else{($ReportingRunTime.Elapsed.Totalminutes.ToString('#######.##')+' Minutes')}

    $User = (get-azcontext -WarningAction SilentlyContinue -InformationAction SilentlyContinue | Select-Object -Property Account -Unique).Account.Id

    $WS = $Excel.Workbook.Worksheets | Where-Object { $_.Name -eq 'Overview' }

    $cell = $WS.Cells | Where-Object {$_.Address -like 'A*' -and $_.Address -notin 'A1','A2','A3','A4','A5','A6'}
    foreach ($item in $cell) {
        $Works = $Item.Text
        $Link = New-Object -TypeName OfficeOpenXml.ExcelHyperLink ("'"+$Works+"'"+'!A1'),$Works
        $Item.Hyperlink = $Link
    }

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Creating Overall Panel.')
    $Egg = $WS.Cells | Where-Object {$_.Address -eq 'BR75'}
    $Egg.AddComment('Created with a lot of effort and hard work, we hope you enjoy it.','.') | Out-Null
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

    $txt = $Draw.RichText.Add('Azure Resource Inventory ' + $ScriptVersion + "`n")
    $txt.Size = 14
    $txt.ComplexFont = $Font
    $txt.LatinFont = $Font

    $txt = $Draw.RichText.Add('https://github.com/microsoft/ARI' + "`n" + "`n")
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

    $txt = $Draw.RichText.Add('Data Gathering Time: ')
    $txt.Size = 11
    $txt.ComplexFont = $Font
    $txt.LatinFont = $Font

    $txt = $Draw.RichText.Add($ExtractTime + "`n")
    $txt.Size = 12
    $txt.ComplexFont = $Font
    $txt.LatinFont = $Font

    $txt = $Draw.RichText.Add('Data Processing Time: ')
    $txt.Size = 11
    $txt.ComplexFont = $Font
    $txt.LatinFont = $Font

    $txt = $Draw.RichText.Add($ProcessingTime + "`n")
    $txt.Size = 12
    $txt.ComplexFont = $Font
    $txt.LatinFont = $Font

    $txt = $Draw.RichText.Add('Data Reporting Time: ')
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

}