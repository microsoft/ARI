<#
.SYNOPSIS
    This script creates Excel file to Analyze Azure Resources inside a Tenant

.DESCRIPTION
    Do you want to analyze your Azure Advisories in a table format? Document it in xlsx format.

.PARAMETER TenantID
    Specify the tenant ID you want to create a Resource Inventory.

    >>> IMPORTANT: YOU NEED TO USE THIS PARAMETER FOR TENANTS WITH MULTI-FACTOR AUTHENTICATION. <<<

.PARAMETER SubscriptionID
    Use this parameter to collect a specific Subscription in a Tenant

.PARAMETER ManagementGroup
    Use this parameter to collect all Subscriptions in a Specific Management Group in a Tenant

.PARAMETER Lite
    Use this parameter to use only the Import-Excel module and don't create the charts (using Excel's API)

.PARAMETER SecurityCenter
    Use this parameter to collect Security Center Advisories

.PARAMETER SkipAdvisory
    Use this parameter to skip the capture of Azure Advisories

.PARAMETER SkipPolicy
    Use this parameter to skip the capture of Azure Policies

.PARAMETER QuotaUsage
    Use this parameter to include Quota information

.PARAMETER IncludeTags
    Use this parameter to include Tags of every Azure Resources. Each tag is written as its own row, and Heavy mode batching is enabled automatically to limit memory use.

.PARAMETER Debug
    Output detailed debug information.

.PARAMETER AzureEnvironment
    Specifies the Azure Cloud Environment to use. Default is 'AzureCloud'.

.PARAMETER Overview
    Specifies the Excel overview sheet design. Each value will change the main charts in the Overview sheet. Valid values are 1, 2, or 3. Default is 1.

.PARAMETER AppId
    Specifies the Application ID used to connect to Azure as a service principal. Requires TenantID and Secret.

.PARAMETER Secret
    Specifies the Secret used with the Application ID to connect to Azure as a service principal. Requires TenantID and AppId.

.PARAMETER CertificatePath
    Specifies the Certificate path used with the Application ID to connect to Azure as a service principal. Requires TenantID, AppId, and Secret.

.PARAMETER ResourceGroup
    Specifies one or more unique Resource Groups to be inventoried. Requires SubscriptionID.

.PARAMETER TagKey
    Specifies the tag key to be inventoried. Requires SubscriptionID.

.PARAMETER TagValue
    Specifies the tag value to be inventoried. Requires SubscriptionID.

.PARAMETER Heavy
    Use this parameter to enable heavy mode. This will force the job's load to be split into smaller batches. Avoiding CPU overload.

.PARAMETER NoAutoUpdate
    Use this parameter to skip automatic module updates.

.PARAMETER SkipAPIs
    Use this parameter to skip the capture of resources trough REST API.

.PARAMETER Automation
    Use this parameter to run in automation mode.

.PARAMETER StorageAccount
    Specifies the Storage Account name for storing the report.

.PARAMETER StorageContainer
    Specifies the Storage Container name for storing the report.

.PARAMETER Help
    Use this parameter to display the help information.

.PARAMETER DeviceLogin
    Use this parameter to enable device login.

.PARAMETER DiagramFullEnvironment
    Use this parameter to include the full environment in the diagram. By default the Network Topology Diagram will only include VNETs that are peered with other VNETs, this parameter will force the diagram to include all VNETs.

.PARAMETER ReportName
    Specifies the name of the report. Default is 'AzureResourceInventory'.

.PARAMETER ReportDir
    Specifies the directory where the report will be saved.

.EXAMPLE
    Default utilization. Read all tenants you have privileges, select a tenant in menu and collect from all subscriptions:
    PS C:\> Invoke-ARI

    Define the Tenant ID:
    PS C:\> Invoke-ARI -TenantID <your-Tenant-Id>

    Define the Tenant ID and for a specific Subscription:
    PS C:\> Invoke-ARI -TenantID <your-Tenant-Id> -SubscriptionID <your-Subscription-Id>

.NOTES
    AUTHORS: Claudio Merola and Renato Gregio | Azure Infrastucture/Automation/Devops/Governance

    Copyright (c) 2018 Microsoft Corporation. All rights reserved.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.

.LINK
    Official Repository: https://github.com/microsoft/ARI
#>
Function Invoke-ARI {
    [CmdletBinding(PositionalBinding=$false)]
    param (
        [ValidateSet(1, 2, 3)]
        [int]$Overview = 1,
        [ValidateSet('AzureCloud', 'AzureUSGovernment', 'AzureChinaCloud')]
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
        [switch]$SecurityCenter,
        [switch]$Heavy,
        [Alias("SkipAdvisories","NoAdvisory","SkipAdvisor")]
        [switch]$SkipAdvisory,
        [Alias("DisableAutoUpdate","SkipAutoUpdate")]
        [switch]$NoAutoUpdate,
        [Alias("NoPolicy","SkipPolicies")]
        [switch]$SkipPolicy,
        [Alias("NoAPI","SkipAPI")]
        [switch]$SkipAPIs,
        [Alias("IncludeTag","AddTags")]
        [switch]$IncludeTags,
        [Alias("SkipVMDetail","NoVMDetails")]
        [switch]$SkipVMDetails,
        [Alias("Costs","IncludeCost")]
        [switch]$IncludeCosts,
        [switch]$QuotaUsage,
        [switch]$SkipDiagram,
        [switch]$Automation,
        [Alias("Low","Light")]
        [switch]$Lite,
        [switch]$Help,
        [switch]$DeviceLogin,
        [switch]$DiagramFullEnvironment
        )

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Debugging Mode: On. ErrorActionPreference was set to "Continue", every error will be presented.')

    if ($DebugPreference -eq 'SilentlyContinue')
        {
            Write-Host 'Debugging Mode: ' -nonewline
            Write-Host 'Off' -ForegroundColor Yellow
            Write-Host 'Use the parameter ' -nonewline
            Write-Host '-Debug' -nonewline -ForegroundColor Yellow
            Write-Host ' to see debugging information during the inventory execution.'
            Write-Host 'For large environments, it is recommended to use the -Debug parameter to monitor the progress.' -ForegroundColor Yellow
        }

    if ($IncludeTags.IsPresent) { $InTag = $true } else { $InTag = $false }

    if ($Lite.IsPresent) { $RunLite = $true }else { $RunLite = $false }
    if ($DiagramFullEnvironment.IsPresent) {$FullEnv = $true}else{$FullEnv = $false}
    if ($Automation.IsPresent)
        {
            $SkipAPIs = $true
            $RunLite = $true
            if (!$StorageAccount -or !$StorageContainer)
                {
                    throw "Storage Account and Container are required for Automation mode. Aborting."
                }
        }
    if ($Overview -eq 1 -and $SkipAPIs)
        {
            $Overview = 2
        }
    $TableStyle = "Light19"

    $TotalRunTime = [System.Diagnostics.Stopwatch]::StartNew()

    if ($Help.IsPresent) {
        Get-Help Invoke-ARI -Full
        return
    }

    $PlatOS = Test-ARIPS

    if ($PlatOS -ne 'Azure CloudShell' -and !$Automation.IsPresent)
        {
            $TenantID = Connect-ARILoginSession -AzureEnvironment $AzureEnvironment -TenantID $TenantID -SubscriptionID $SubscriptionID -DeviceLogin $DeviceLogin -AppId $AppId -Secret $Secret -CertificatePath $CertificatePath

            if (!$NoAutoUpdate.IsPresent) {
                Write-Host ('Checking for Powershell Module Updates..')
                if (Get-InstalledModule -Name AzureResourceInventory -ErrorAction SilentlyContinue) {
                    Update-Module -Name AzureResourceInventory -AcceptLicense
                }
                elseif (Get-InstalledPSResource -Name AzureResourceInventory -Scope CurrentUser -ErrorAction SilentlyContinue) {
                    Update-PSResource -Name AzureResourceInventory -Scope CurrentUser -AcceptLicense
                }
                elseif (Get-InstalledPSResource -Name AzureResourceInventory -Scope AllUsers -ErrorAction SilentlyContinue) {
                    Update-PSResource -Name AzureResourceInventory -Scope AllUsers -AcceptLicense
                }
                else {
                    Write-Warning 'Unable to update AzureResourceInventory module. It is not installed from the PowerShell Gallery. Skipping update.'
                }
            }
        }
    elseif ($Automation.IsPresent)
        {
            try {
                $AzureConnection = (Connect-AzAccount -Identity).context

                Set-AzContext -SubscriptionName $AzureConnection.Subscription -DefaultProfile $AzureConnection
            }
            catch {
                throw "Failed to set Automation Account requirements. Aborting. $_"
            }
        }

    if ($PlatOS -eq 'Azure CloudShell')
        {
            $Heavy = $true
            $SkipAPIs = $true
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

    Clear-ARICacheFolder -ReportCache $ReportCache

    Get-Job | Where-Object {$_.name -like 'ResourceJob_*'} | Remove-Job -Force | Out-Null

    $ExtractionRuntime = [System.Diagnostics.Stopwatch]::StartNew()

        $ExtractionData = Start-ARIExtractionOrchestration -ManagementGroup $ManagementGroup -Subscriptions $Subscriptions -SubscriptionID $SubscriptionID -ResourceGroup $ResourceGroup -SecurityCenter $SecurityCenter -SkipAdvisory $SkipAdvisory -SkipPolicy $SkipPolicy -IncludeTags $IncludeTags -TagKey $TagKey -TagValue $TagValue -SkipAPIs $SkipAPIs -SkipVMDetails $SkipVMDetails -IncludeCosts $IncludeCosts -Automation $Automation -AzureEnvironment $AzureEnvironment

    $ExtractionRuntime.Stop()

    $Resources = $ExtractionData.Resources
    $Quotas = $ExtractionData.Quotas
    $CostData = $ExtractionData.Costs
    $ResourceContainers = $ExtractionData.ResourceContainers
    $Advisories = $ExtractionData.Advisories
    $ResourcesCount = $ExtractionData.ResourcesCount
    $AdvisoryCount = $ExtractionData.AdvisoryCount
    $SecCenterCount = $ExtractionData.SecCenterCount
    $Security = $ExtractionData.Security
    $Retirements = $ExtractionData.Retirements
    $PolicyCount = $ExtractionData.PolicyCount
    $PolicyAssign = $ExtractionData.PolicyAssign
    $PolicyDef = $ExtractionData.PolicyDef
    $PolicySetDef = $ExtractionData.PolicySetDef

    Remove-Variable -Name ExtractionData -ErrorAction SilentlyContinue

    $ExtractionTotalTime = $ExtractionRuntime.Elapsed.ToString("dd\:hh\:mm\:ss\:fff")

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Extraction phase memory: current '+[math]::Round([System.Diagnostics.Process]::GetCurrentProcess().WorkingSet64/1MB)+' MB, peak '+[math]::Round([System.Diagnostics.Process]::GetCurrentProcess().PeakWorkingSet64/1MB)+' MB')

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

    #### Creating Excel file variable:
    $FileName = ($ReportName + "_Report_" + (get-date -Format "yyyy-MM-dd_HH_mm") + ".xlsx")
    $File = Join-Path $DefaultPath $FileName
    #$DFile = ($DefaultPath + $Global:ReportName + "_Diagram_" + (get-date -Format "yyyy-MM-dd_HH_mm") + ".vsdx")
    $DDName = ($ReportName + "_Diagram_" + (get-date -Format "yyyy-MM-dd_HH_mm") + ".xml")
    $DDFile = Join-Path $DefaultPath $DDName

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Excel file: ' + $File)

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Starting Default Jobs.')

    $ProcessingRunTime = [System.Diagnostics.Stopwatch]::StartNew()

        Start-ARIExtraJobs -SkipDiagram $SkipDiagram -SkipAdvisory $SkipAdvisory -SkipPolicy $SkipPolicy -SecurityCenter $Security -Subscriptions $Subscriptions -Resources $Resources -Advisories $Advisories -DDFile $DDFile -DiagramCache $DiagramCache -FullEnv $FullEnv -ResourceContainers $ResourceContainers -Security $Security -PolicyAssign $PolicyAssign -PolicySetDef $PolicySetDef -PolicyDef $PolicyDef -IncludeCosts $IncludeCosts -CostData $CostData -Automation $Automation

        Start-ARIProcessOrchestration -Subscriptions $Subscriptions -Resources $Resources -Retirements $Retirements -DefaultPath $DefaultPath -Heavy $Heavy -File $File -InTag $InTag -Automation $Automation

    $ProcessingRunTime.Stop()

    $ProcessingTotalTime = $ProcessingRunTime.Elapsed.ToString("dd\:hh\:mm\:ss\:fff")

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Processing phase memory: current '+[math]::Round([System.Diagnostics.Process]::GetCurrentProcess().WorkingSet64/1MB)+' MB, peak '+[math]::Round([System.Diagnostics.Process]::GetCurrentProcess().PeakWorkingSet64/1MB)+' MB')

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

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Starting Resources Report Function.')
    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Excel Table Style used: ' + $TableStyle)

    $ReportingRunTime = [System.Diagnostics.Stopwatch]::StartNew()

        Start-ARIReporOrchestration -ReportCache $ReportCache -SecurityCenter $SecurityCenter -File $File -Quotas $Quotas -SkipPolicy $SkipPolicy -SkipAdvisory $SkipAdvisory -IncludeCosts $IncludeCosts -Automation $Automation -TableStyle $TableStyle

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Generating Overview sheet (Charts).')

        $TotalRes = Start-ARIExcelCustomization -File $File -TableStyle $TableStyle -PlatOS $PlatOS -Subscriptions $Subscriptions -ExtractionRunTime $ExtractionRuntime -ProcessingRunTime $ProcessingRunTime -ReportingRunTime $ReportingRunTime -IncludeCosts $IncludeCosts -RunLite $RunLite -Overview $Overview

        Write-Progress -activity 'Azure Inventory' -Status "95% Complete." -PercentComplete 95 -CurrentOperation "Excel Customization Completed.."

    $ReportingRunTime.Stop()

    $ReportingTotalTime = $ReportingRunTime.Elapsed.ToString("dd\:hh\:mm\:ss\:fff")

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Reporting phase memory: current '+[math]::Round([System.Diagnostics.Process]::GetCurrentProcess().WorkingSet64/1MB)+' MB, peak '+[math]::Round([System.Diagnostics.Process]::GetCurrentProcess().PeakWorkingSet64/1MB)+' MB')

    if ($Automation.IsPresent)
        {
            Write-Output "Report Building Finished"
            Write-Output ('Total Processing Time: ' + $ReportingTotalTime)
        }
    else
        {
            Write-Host "Report Building Finished: " -ForegroundColor Green -NoNewline
            Write-Host $ReportingTotalTime -ForegroundColor Cyan
        }

        # Clear memory to remove as many memory footprint as possible
        Clear-ARIMemory

        # Clear Cache Folder for future runs
        Clear-ARICacheFolder -ReportCache $ReportCache

        # Kills any automated Excel process that might be running
        Remove-ARIExcelProcess

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Finished Charts Phase.')

    if(!$SkipDiagram.IsPresent -and !$Automation.IsPresent)
    {
        Write-Progress -activity 'Diagrams' -Status "Completing Diagram" -PercentComplete 70 -CurrentOperation "Consolidating Diagram"

        $JobNames = (Get-Job | Where-Object {$_.name -eq 'DrawDiagram'}).Name

        Wait-ARIJob -JobNames $JobNames -JobType 'Diagram' -LoopTime 5

        Remove-Job -Name 'DrawDiagram' | Out-Null

        Write-Progress -activity 'Diagrams' -Status "Closing Diagram File" -Completed
    }


    if ($StorageAccount)
        {
            Write-Output "Sending Excel file to Storage Account:"
            Write-Output $File
            Set-AzStorageBlobContent -File $File -Container $StorageContainer -Context $StorageContext | Out-Null
            if(!$SkipDiagram.IsPresent)
                {
                    Write-Output "Sending Diagram file to Storage Account:"
                    Write-Output $DDFile
                    Set-AzStorageBlobContent -File $DDFile -Container $StorageContainer -Context $StorageContext | Out-Null
                    if($PSBoundParameters.ContainsKey('Debug'))
                        {
                            $LogFilePath = Join-Path $DefaultPath 'DiagramLogFile.log'
                            Set-AzStorageBlobContent -File $LogFilePath -Container $StorageContainer -Context $StorageContext -Force | Out-Null
                        }
                }
        }

    $TotalRunTime.Stop()

    $Measure = $TotalRunTime.Elapsed.ToString("dd\:hh\:mm\:ss\:fff")

Write-Progress -activity 'Azure Inventory' -Status "100% Complete." -Completed

Out-ARIReportResults -Measure $Measure -ResourcesCount $ResourcesCount -TotalRes $TotalRes -SkipAdvisory $SkipAdvisory -AdvisoryData $AdvisoryCount -SkipPolicy $SkipPolicy -SkipAPIs $SkipAPIs -PolicyData $PolicyCount -SecurityCenter $SecurityCenter -SecurityCenterData $SecCenterCount -File $File -SkipDiagram $SkipDiagram -DDFile $DDFile

}