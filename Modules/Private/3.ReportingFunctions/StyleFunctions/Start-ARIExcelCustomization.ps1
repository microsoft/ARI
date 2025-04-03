<#
.Synopsis
Module for Main Dashboard

.DESCRIPTION
This script process and creates the Overview sheet.

.Link
https://github.com/microsoft/ARI/Modules/Private/3.ReportingFunctions/StyleFunctions/Start-ARIExcelCustomization.ps1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.6.0
First Release Date: 15th Oct, 2024
Authors: Claudio Merola

#>
function Start-ARIExcelCustomization {
    param($File, $TableStyle, $PlatOS, $Subscriptions, $ExtractionRunTime, $ProcessingRunTime, $ReportingRunTime, $IncludeCosts, $RunLite, $Overview)

    Write-Progress -activity 'Azure Inventory' -Status "85% Complete." -PercentComplete 85 -CurrentOperation "Starting Excel Customization.."

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Starting Excel Charts Customization.')

    if ($RunLite)
        {
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Running in Lite Mode.')

            $ScriptVersion = "3.6"
        }
    else
        {
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Running in Full Mode.')
            $ARIMod = Get-InstalledModule -Name AzureResourceInventory

            $ScriptVersion = [string]$ARIMod.Version
        }


    "" | Export-Excel -Path $File -WorksheetName 'Overview' -MoveToStart

    Start-ARIExcelOrdening -File $File

    $Excel = Open-ExcelPackage -Path $File
    $Worksheets = $Excel.Workbook.Worksheets

    $TotalRes = 0
    $Table = Foreach ($WorkS in $Worksheets) {
        if(![string]::IsNullOrEmpty($WorkS.Tables.Name))
            {
                $Number = $WorkS.Tables.Name.split('_')
                $tmp = @{
                    'Name' = $WorkS.name;
                    'Size' = [int]$Number[1];
                    'Size2' = if ($WorkS.name -in ('Subscriptions', 'Quota Usage', 'AdvisorScore', 'Outages', 'SupportTickets', 'Reservation Advisor')) {0}else{[int]$Number[1]}
                }
                if ($WorkS.name -notin ('Subscriptions', 'Quota Usage', 'AdvisorScore', 'Outages', 'SupportTickets', 'Reservation Advisor', 'Managed Identity', 'Backup'))
                    {
                        $TotalRes = $TotalRes + ([int]$Number[1])
                    }
                $tmp
            }
    }

    Close-ExcelPackage $Excel

    $TableStyleEx = if($PlatOS -eq 'PowerShell Desktop'){'Medium1'}else{$TableStyle}
    $TableStyle = if($PlatOS -eq 'PowerShell Desktop'){'Medium15'}else{$TableStyle}
    #$TableStyle = 'Medium22'

    $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0

    $Table |
    ForEach-Object { [PSCustomObject]$_ } | Sort-Object -Property 'Size2' -Descending |
    Select-Object -Unique 'Name',
    'Size' | Export-Excel -Path $File -WorksheetName 'Overview' -AutoSize -MaxAutoSizeRows 100 -TableName 'AzureTabs' -TableStyle $TableStyleEx -Style $Style -StartRow 6 -StartColumn 1

    $Excel = Open-ExcelPackage -Path $File

    Build-ARIInitialBlock -Excel $Excel -ExtractionRunTime $ExtractionRunTime -ProcessingRunTime $ProcessingRunTime -ReportingRunTime $ReportingRunTime -PlatOS $PlatOS -TotalRes $TotalRes -ScriptVersion $ScriptVersion

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Creating Charts.')

    Build-ARIExcelChart -Excel $Excel -Overview $Overview -IncludeCosts $IncludeCosts

    Close-ExcelPackage $Excel

    if(!$RunLite)
        {
            Build-ARIExcelComObject -File $File
        }

    return $TotalRes
}