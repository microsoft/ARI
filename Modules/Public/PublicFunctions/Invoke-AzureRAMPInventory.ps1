#Requires -Version 7
function Invoke-AzureRAMPInventory {
    [CmdletBinding(PositionalBinding=$false)]
    param (  
        [ValidateSet('AzureCloud', 'AzureUSGovernment', 'AzureChinaCloud', 'AzureGermanCloud')]
        [string]$AzureEnvironment = 'AzureCloud',
        [string]$TenantID,
        [string]$AppId,
        [string]$Secret,
        [string]$CertificatePath,
        [string]$ReportName = 'AzureResourceInventory',
        [string]$ReportDir,
        [string]$StorageAccount,
        [string]$StorageContainer,
        [String[]]$SubscriptionID,
        [string[]]$ManagementGroup,
        [string[]]$ResourceGroup,
        [string[]]$TagKey,
        [string[]]$TagValue,
        [switch]$Automation,
        [switch]$DeviceLogin,
        [switch]$StateRAMP
        )

    $TotalRunTime = [System.Diagnostics.Stopwatch]::StartNew()


    $PlatOS = Test-ARIPS

    if ($PlatOS -ne 'Azure CloudShell' -and !$Automation.IsPresent)
        {
            $TenantID = Connect-ARILoginSession -AzureEnvironment $AzureEnvironment -TenantID $TenantID -SubscriptionID $SubscriptionID -DeviceLogin $DeviceLogin -AppId $AppId -Secret $Secret -CertificatePath $CertificatePath
        }
    elseif ($Automation.IsPresent)
        {
            try {
                $AzureConnection = (Connect-AzAccount -Identity).context

                Set-AzContext -SubscriptionName $AzureConnection.Subscription -DefaultProfile $AzureConnection
            }
            catch {
                Write-Output "Failed to set Automation Account requirements. Aborting." 
                exit
            }
        }

    if ($StorageAccount)
        {
            $StorageContext = New-AzStorageContext -StorageAccountName $StorageAccount -UseConnectedAccount
        }

    $Subscriptions = Get-ARISubscriptions -TenantID $TenantID -SubscriptionID $SubscriptionID -PlatOS $PlatOS

    $ReportingPath = Set-ARIReportPath -ReportDir $ReportDir

    $DefaultPath = $ReportingPath.DefaultPath
    $DiagramCache = $ReportingPath.DiagramCache
    $ReportCache = $ReportingPath.ReportCache

    if ($Automation.IsPresent)
        {
            $ReportName = 'ARI_Automation'
        }

    Set-ARIFolder -DefaultPath $DefaultPath -DiagramCache $DiagramCache -ReportCache $ReportCache

    [switch]$SKipAdvisory = $true
    [switch]$SkipPolicy = $true
    [switch]$SkipAPIs = $true
    [switch]$SkipVMDetails = $true
    [switch]$IncludeCosts = $false
    [switch]$IncludeTags = $false

    $ExtractionRuntime = [System.Diagnostics.Stopwatch]::StartNew()

        $ExtractionData = Start-ARIExtractionOrchestration -ManagementGroup $ManagementGroup -Subscriptions $Subscriptions -SubscriptionID $SubscriptionID -ResourceGroup $ResourceGroup -SecurityCenter $SecurityCenter -SkipAdvisory $SkipAdvisory -SkipPolicy $SkipPolicy -IncludeTags $IncludeTags -TagKey $TagKey -TagValue $TagValue -SkipAPIs $SkipAPIs -SkipVMDetails $SkipVMDetails -IncludeCosts $IncludeCosts -Automation $Automation

    $ExtractionRuntime.Stop()

    $Resources = $ExtractionData.Resources

    $ExtractionTotalTime = $ExtractionRuntime.Elapsed.ToString("dd\:hh\:mm\:ss\:fff")

    if ($Automation.IsPresent)
        {
            Write-Output "Extraction Phase Finished"
            Write-Output ('Total Extraction Time: ' + $ExtractionTotalTime)
        }
    else
        {
            Write-Host "Extraction Phase Finished: " -ForegroundColor Green -NoNewline
            Write-Host $ExtractionTotalTime -ForegroundColor Cyan
        }

    $FedFileName = ('FedRAMP-Inventory-' + (Get-Date -Format 'yyyy-MM-dd_HH_mm') + '.xlsx')
    $FedRAMPFile = Join-Path $DefaultPath $FedFileName

    $StateFileName = ('StateRAMP-Inventory-' + (Get-Date -Format 'yyyy-MM-dd_HH_mm') + '.xlsx')
    $StateRAMPFile = Join-Path $DefaultPath $StateFileName

    $ProcessingRunTime = [System.Diagnostics.Stopwatch]::StartNew()

        $RAMPResources = Start-ARIProcessGovRamp -Resources $Resources

        $FedRampResources = Start-ARIMappingFedRAMP -FedResources $RAMPResources

        if ($StateRAMP.IsPresent)
            {
                $StateRampResources = Start-ARIMappingStateRAMP -StateResources $RAMPResources
            }

    $ProcessingRunTime.Stop()

    $ProcessingTotalTime = $ProcessingRunTime.Elapsed.ToString("dd\:hh\:mm\:ss\:fff")

    if ($Automation.IsPresent)
        {
            Write-Output "Processing Phase Finished"
            Write-Output ('Total Processing Time: ' + $ProcessingTotalTime)
        }
    else
        {
            Write-Host "Processing Phase Finished: " -ForegroundColor Green -NoNewline
            Write-Host $ProcessingTotalTime -ForegroundColor Cyan
        }

    $ExportRunTime = [System.Diagnostics.Stopwatch]::StartNew()

        Export-ARIFedRamp -FedRampResources $FedRampResources -DefaultPath $DefaultPath -RAMPFile $FedRAMPFile

        if($StateRAMP.IsPresent)
            {
                Export-ARIStateRamp -StateRampResources $StateRampResources -DefaultPath $DefaultPath -RAMPFile $StateRAMPFile
            }

        if ($StorageAccount)
            {
                Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Uploading file to Azure Storage: ' + $FedRAMPFile)

                Set-AzStorageBlobContent -Container $StorageContainer -File $FedRAMPFile -Context $StorageContext -Force

                if ($StateRAMP.IsPresent)
                    {
                        Set-AzStorageBlobContent -Container $StorageContainer -File $StateRAMPFile -Context $StorageContext -Force
                    }
            }
        else
            {
                Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'FedRAMP Inventory file: ' + $FedRAMPFile)
            }

    $ExportRunTime.Stop()

    $ExportTotalTime = $ExportRunTime.Elapsed.ToString("dd\:hh\:mm\:ss\:fff")

    if ($Automation.IsPresent)
        {
            Write-Output "Export Phase Finished"
            Write-Output ('Total Export Time: ' + $ExportTotalTime)
        }
    else
        {
            Write-Host "Export Phase Finished: " -ForegroundColor Green -NoNewline
            Write-Host $ExportTotalTime -ForegroundColor Cyan
        }
    $TotalRunTime.Stop()

    $TotalRunTime = $TotalRunTime.Elapsed.ToString("dd\:hh\:mm\:ss\:fff")

    if ($Automation.IsPresent)
        {
            Write-Output "Total Run Time: " + $TotalRunTime
        }
    else
        {
            Write-Host "Total Run Time: " -ForegroundColor Green -NoNewline
            Write-Host $TotalRunTime -ForegroundColor Cyan
        }

    Write-Host "Azure RAMP Inventory Finished"
    Write-Host ''
    Write-Host ('FedRAMP Inventory file saved at: ') -NoNewline
    write-host $FedRAMPFile -ForegroundColor Cyan
    Write-Host ''
    if ($StateRAMP.IsPresent)
        {
            Write-Host ('StateRAMP Inventory file saved at: ') -NoNewline
            write-host $StateRAMPFile -ForegroundColor Cyan
        }
    Write-Host ''


}