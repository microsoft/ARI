function Build-ARIExcelComObject {
    param($File, $Debug)
    if($Debug.IsPresent)
        {
            $DebugPreference = 'Continue'
            $ErrorActionPreference = 'Continue'
        }
    else
        {
            $ErrorActionPreference = "silentlycontinue"
        }

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Validating if Excel is installed (Extra Customizations).')
    try
        {
            $application = New-Object -ComObject Excel.Application
            if ($application) {
                try
                    {
                        $Ex = $application.Workbooks.Open($File)
                        While ([string]::IsNullOrEmpty($Ex))
                            {
                                Start-Sleep -Seconds 1
                            }
                        $WS = $Ex.Worksheets | Where-Object { $_.Name -eq 'Overview' }
                    }
                catch
                    {
                        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Error Opening Excel File.')
                        Write-Error $_
                        $application.Quit()
                        if (Get-Process -Name "excel" -ErrorAction Ignore | Where-Object { $_.CommandLine -like '*/automation*' } )
                            {
                                Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss') + ' - Stopping Excel process.')
                                Get-Process -Name "excel" -ErrorAction Ignore | Where-Object { $_.CommandLine -like '*/automation*' } | Stop-Process -Force
                            }
                        return
                    }


                $NoChangeChart = ('ChartP0', 'ChartP1', 'ChartP2', 'ChartP3', 'ChartP4', 'ChartP5', 'ChartP6', 'ChartP7', 'ChartP8', 'ChartP9', 'ARI', 'RGs', 'TP00', 'TP0', 'TP1', 'TP2', 'TP3', 'TP4', 'TP5','TP6','TP7','TP8','TP9')
                $ChangeChart = ('ARI', 'RGs', 'TP00', 'TP0', 'TP1', 'TP2', 'TP3', 'TP4', 'TP5', 'TP6', 'TP7','TP8','TP9')

                ($WS.Shapes | Where-Object { $_.name -eq 'ChartP0' }).DrawingObject.Chart.ChartStyle = 294
                Start-Sleep -Milliseconds 50
                ($WS.Shapes | Where-Object { $_.name -eq 'ChartP1' }).DrawingObject.Chart.ChartStyle = 222
                Start-Sleep -Milliseconds 50
                ($WS.Shapes | Where-Object { $_.name -eq 'ChartP2' }).DrawingObject.Chart.ChartStyle = 294
                Start-Sleep -Milliseconds 50
                ($WS.Shapes | Where-Object { $_.name -eq 'ChartP3' }).DrawingObject.Chart.ChartStyle = 268
                Start-Sleep -Milliseconds 50
                ($WS.Shapes | Where-Object { $_.name -eq 'ChartP4' }).DrawingObject.Chart.ChartStyle = 294
                Start-Sleep -Milliseconds 50
                ($WS.Shapes | Where-Object { $_.name -eq 'ChartP5' }).DrawingObject.Chart.ChartStyle = 222
                Start-Sleep -Milliseconds 50
                ($WS.Shapes | Where-Object { $_.name -eq 'ChartP6' }).DrawingObject.Chart.ChartStyle = 294
                Start-Sleep -Milliseconds 50
                ($WS.Shapes | Where-Object { $_.name -eq 'ChartP7' }).DrawingObject.Chart.ChartStyle = 268
                Start-Sleep -Milliseconds 50
                ($WS.Shapes | Where-Object { $_.name -eq 'ChartP8' }).DrawingObject.Chart.ChartStyle = 294
                Start-Sleep -Milliseconds 50
                ($WS.Shapes | Where-Object { $_.name -eq 'ChartP9' }).DrawingObject.Chart.ChartStyle = 268
                Start-Sleep -Milliseconds 50
                ($WS.Shapes | Where-Object { $_.name -notin $NoChangeChart -and $_.name -like 'Chart*' }).DrawingObject.Chart.ChartStyle = 315
                Start-Sleep -Milliseconds 50

                Foreach ($Changer in $ChangeChart) {
                    ($WS.Shapes | Where-Object { $_.name -eq $Changer }).DrawingObject.interior.color = 2500134
                    ($WS.Shapes | Where-Object { $_.name -eq $Changer }).DrawingObject.border.color = 16777215
                    ($WS.Shapes | Where-Object { $_.name -eq $Changer }).DrawingObject.border.ColorIndex = -4142
                    ($WS.Shapes | Where-Object { $_.name -eq $Changer }).DrawingObject.border.LineStyle = -4142
                    Start-Sleep -Milliseconds 50
                }

                $Draw = ($WS.Shapes | Where-Object {$_.name -eq 'ARI'})
                $Draw.Adjustments(1) = 0.07
                Start-Sleep -Milliseconds 50

                $Ex.Save()
                $Ex.Close()
                $application.Quit()
                if (Get-Process -Name "excel" -ErrorAction Ignore | Where-Object { $_.CommandLine -like '*/automation*' } )
                    {
                        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss') + ' - Stopping Excel process.')
                        Get-Process -Name "excel" -ErrorAction Ignore | Where-Object { $_.CommandLine -like '*/automation*' } | Stop-Process -Force
                    }

                $Excel = New-Object OfficeOpenXml.ExcelPackage $File

                foreach ($Sheet in $excel.Workbook.Worksheets)
                {
                    try{
                        if ($Sheet.name -in ('Overview','Policy', 'Advisor', 'Security Center', 'Subscriptions', 'Quota Usage', 'AdvisorScore', 'Outages', 'SupportTickets', 'Reservation Advisor'))
                            {
                                $Sheet.TabColor = [System.Drawing.Color]::FromName('DarkBlue')
                            }
                        else
                            {
                                $Sheet.TabColor = [System.Drawing.Color]::FromName('LightGray')
                            }
                    }
                    catch
                    {
                        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Error Setting Tab Colors.')
                        Write-Error $_
                    }
                }

                $Excel.save()
                $Excel.Dispose()
            }
        }
    catch
        {
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Error Interacting with Excel COM Object.')
            Write-Error $_
            $Ex.Close()
            $application.Quit()
            if (Get-Process -Name "excel" -ErrorAction Ignore | Where-Object { $_.CommandLine -like '*/automation*' } )
                {
                    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss') + ' - Stopping Excel process.')
                    Get-Process -Name "excel" -ErrorAction Ignore | Where-Object { $_.CommandLine -like '*/automation*' } | Stop-Process -Force
                }
        }
}