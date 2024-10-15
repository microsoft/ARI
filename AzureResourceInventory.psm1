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
    Use this parameter to collect a all Subscriptions in a Specific Management Group in a Tenant

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
    Use this parameter to include Tags of every Azure Resources

.PARAMETER Debug
    Output detailed debug information.

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
param ([ValidateSet('AzureCloud', 'AzureUSGovernment','AzureChinaCloud')]
        $AzureEnvironment = 'AzureCloud',
        [ValidateSet(1, 2, 3)]
        $Overview = 1,
        $TenantID,
        $AppId,
        $Secret,
        [String[]]$SubscriptionID,
        $ManagementGroup,
        [string[]]$ResourceGroup,
        $TagKey,
        $TagValue,
        [switch]$SecurityCenter,
        [switch]$Heavy,
        [switch]$SkipAdvisory,
        [switch]$SkipPolicy,
        [switch]$SkipAPIs,
        [switch]$IncludeTags,
        [switch]$QuotaUsage,
        [switch]$SkipDiagram,
        [switch]$Automation,
        $StorageAccount,
        $StorageContainer,
        [switch]$Lite,
        [switch]$Debug,
        [switch]$Help,
        [switch]$DeviceLogin,
        [switch]$DiagramFullEnvironment,
        $ReportName = 'AzureResourceInventory',
        $ReportDir)

    if ($Debug.IsPresent)
        {
            $DebugPreference = 'Continue'
            $ErrorActionPreference = 'Continue'
        }
    else
        {
            $ErrorActionPreference = "silentlycontinue"
        }

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Debbuging Mode: On. ErrorActionPreference was set to "Continue", every error will be presented.')

    if ($IncludeTags.IsPresent) { $InTag = $true } else { $InTag = $false }

    if ($Lite.IsPresent -or $Automation.IsPresent) { $RunLite = $true }else { $RunLite = $false }
    if ($DiagramFullEnvironment.IsPresent) {$FullEnv = $true}else{$FullEnv = $false}

    <#########################################################          Help          ######################################################################>

    Function Get-UsageMode() {
        Write-Host ""
        Write-Host "Parameters"
        Write-Host ""
        Write-Host " -TenantID <ID>        :  Specifies the Tenant to be inventoried. "
        Write-Host " -SubscriptionID <ID>  :  Specifies Subscription(s) to be inventoried. "
        Write-Host " -ResourceGroup  <NAME>:  Specifies one (or more) unique Resource Group to be inventoried, This parameter requires the -SubscriptionID to work. "
        Write-Host " -TagKey <NAME>        :  Specifies the tag key to be inventoried, This parameter requires the -SubscriptionID to work. "
        Write-Host " -TagValue <NAME>      :  Specifies the tag value be inventoried, This parameter requires the -SubscriptionID to work. "
        Write-Host " -SkipAdvisory         :  Do not collect Azure Advisory. "
        Write-Host " -SkipPolicy           :  Do not collect Azure Policies. "
        Write-Host " -SecurityCenter       :  Include Security Center Data. "
        Write-Host " -IncludeTags          :  Include Resource Tags. "
        Write-Host " -Online               :  Use Online Modules. "
        Write-Host " -Debug                :  Run in a Debug mode. "
        Write-Host " -AzureEnvironment     :  Change the Azure Cloud Environment. "
        Write-Host " -ReportName           :  Change the Default Name of the report. "
        Write-Host " -ReportDir            :  Change the Default Path of the report. "
        Write-Host ""
        Write-Host ""
        Write-Host ""
        Write-Host "Usage Mode and Examples: "
        Write-Host "If you do not specify Resource Inventory will be performed on all subscriptions for the selected tenant. "
        Write-Host "e.g. /> Invoke-ARI"
        Write-Host ""
        Write-Host "To perform the inventory in a specific Tenant and subscription use <-TenantID> and <-SubscriptionID> parameter "
        Write-Host "e.g. /> Invoke-ARI -TenantID <Azure Tenant ID> -SubscriptionID <Subscription ID>"
        Write-Host ""
        Write-Host "Including Tags:"
        Write-Host " By Default Azure Resource inventory do not include Resource Tags."
        Write-Host " To include Tags at the inventory use <-IncludeTags> parameter. "
        Write-Host "e.g. /> Invoke-ARI -TenantID <Azure Tenant ID> -IncludeTags"
        Write-Host ""
        Write-Host "Skipping Azure Advisor:"
        Write-Host " By Default Azure Resource inventory collects Azure Advisor Data."
        Write-Host " To ignore this  use <-SkipAdvisory> parameter. "
        Write-Host "e.g. /> Invoke-ARI -TenantID <Azure Tenant ID> -SubscriptionID <Subscription ID> -SkipAdvisory"
        Write-Host ""
        Write-Host "Using the latest modules :"
        Write-Host " You can use the latest modules. For this use <-Online> parameter."
        Write-Host " It's a pre-requisite to have internet access for ARI GitHub repo"
        Write-Host "e.g. /> Invoke-ARI -TenantID <Azure Tenant ID> -Online"
        Write-Host ""
        Write-Host "Running in Debug Mode :"
        Write-Host " To run in a Debug Mode use <-Debug> parameter."
        Write-Host ".e.g. /> Invoke-ARI -TenantID <Azure Tenant ID> -Debug"
        Write-Host ""
    }

    $TotalRunTime = Measure-Command -Expression {

    if ($Help.IsPresent) {
        Get-UsageMode
        Break
    }
    else {

        if ($PlatOS -ne 'Azure CloudShell' -and !$Automation.IsPresent)
            {
                Write-Host ('Checking for Powershell Module Updates..')
                Update-Module -Name AzureResourceInventory -AcceptLicense
            }

        $PlatOS = Test-ARIPS -Debug $Debug

        if ($PlatOS -ne 'Azure CloudShell' -and !$Automation.IsPresent)
            {
                $TenantID = Connect-ARILoginSession -AzureEnvironment $AzureEnvironment -TenantID $TenantID -SubscriptionID $SubscriptionID -DeviceLogin $DeviceLogin -AppId $AppId -Secret $Secret -Debug $Debug
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

        $Subscriptions = Get-ARISubscriptions -TenantID $TenantID -SubscriptionID $SubscriptionID

        if ($PlatOS -eq 'Azure CloudShell')
            {
                $DefaultPath = if($ReportDir) {$ReportDir} else {"$HOME/AzureResourceInventory/"}
                $DiagramCache = if($ReportDir) {$ReportDir} else {"$HOME/AzureResourceInventory/DiagramCache/"}
                if($ReportDir)
                {
                    try
                        {
                            Resolve-Path $ReportDir -ErrorAction STOP
                            if ($ReportDir -notmatch '/$')
                                {
                                    $ReportDir = $ReportDir + '/'
                                }
                        }
                    catch
                        {
                            Write-Output "ReportDir Parameter must contain the full path."
                            Exit
                        }
                }
            }
        elseif ($PlatOS -eq 'PowerShell Unix')
            {
                $DefaultPath = if($ReportDir) {$ReportDir} else {"$HOME/AzureResourceInventory/"}
                $DiagramCache = if($ReportDir) {$ReportDir} else {"$HOME/AzureResourceInventory/DiagramCache/"}
                if($ReportDir)
                {
                    try
                        {
                            Resolve-Path $ReportDir -ErrorAction STOP
                            if ($ReportDir -notmatch '/$')
                                {
                                    $ReportDir = $ReportDir + '/'
                                }
                        }
                    catch
                        {
                            Write-Output "ReportDir Parameter must contain the full path."
                            Exit
                        }
                }
            }
        elseif ($PlatOS -eq 'PowerShell Desktop')
            {
                $DefaultPath = if($ReportDir) {$ReportDir} else {"C:\AzureResourceInventory\"}
                $DiagramCache = if($ReportDir) {($ReportDir+'DiagramCache\')} else {"C:\AzureResourceInventory\DiagramCache\"}
                if($ReportDir)
                {
                    try
                        {
                            Resolve-Path $ReportDir -ErrorAction STOP
                            if ($ReportDir -notlike '*\')
                                {
                                    $ReportDir = $ReportDir + '\'
                                }
                        }
                    catch
                        {
                            Write-Output "ReportDir Parameter must contain the full path."
                            Exit
                        }
                }
            }

        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Checking report folder: ' + $DefaultPath )
        if ((Test-Path -Path $DefaultPath -PathType Container) -eq $false) {
            New-Item -Type Directory -Force -Path $DefaultPath | Out-Null
        }
        if ((Test-Path -Path $DiagramCache -PathType Container) -eq $false) {
            New-Item -Type Directory -Force -Path $DiagramCache | Out-Null
        }

        Write-Host "Starting Resource Extraction.."

        $ExtractionData = Start-AzureResourceDataPull -ManagementGroup $ManagementGroup -Subscriptions $Subscriptions -SubscriptionID $SubscriptionID -ResourceGroup $ResourceGroup -SecurityCenter $SecurityCenter -SkipAdvisory $SkipAdvisory -IncludeTags $IncludeTags -QuotaUsage $QuotaUsage -TagKey $TagKey -TagValue $TagValue -Debug $Debug

        $ExtractionRuntime = $ExtractionData.ExtractionRunTime
        $Resources = $ExtractionData.Resources
        $ResourceContainers = $ExtractionData.ResourceContainers
        $Advisories = $ExtractionData.Advisories
        $Security = $ExtractionData.Security

        Clear-Variable -Name ExtractionData

        $ResourcesCount = [string]$Resources.Count
        $advco = [string]$Advisories.Count
        $Secadvco = [string]$Security.Count

        if(!$SkipAPIs.IsPresent)
            {
                $APIResults = Get-ARIAPIResources -Subscriptions $Subscriptions -AzureEnvironment $AzureEnvironment -SkipPolicy $SkipPolicy -Debug $Debug
                $Resources += $APIResults.ResourceHealth
                $Resources += $APIResults.SupportTickets
                $Resources += $APIResults.ManagedIdentities
                $Resources += $APIResults.AdvisorScore
                $Resources += $APIResults.ReservationRecomen
                $PolicyAssign = $APIResults.PolicyAssign
                $PolicyDef = $APIResults.PolicyDef
                $PolicySetDef = $APIResults.PolicySetDef
            }

        $polco = [string]$PolicyAssign.policyAssignments.Count

        #### Creating Excel file variable:
        if ($StorageAccount)
            {
                $Date = get-date -Format "yyyy-MM-dd_HH_mm"

                if($ReportName -eq 'AzureResourceInventory')
                    {
                        $File = ("ARI_Automation_Report_"+$Date+".xlsx")
                    }
                else
                    {
                        $File = ($ReportName+'_'+$Date+'.xlsx')
                    }
            }
        else
            {
                $File = ($DefaultPath + $ReportName + "_Report_" + (get-date -Format "yyyy-MM-dd_HH_mm") + ".xlsx")
                #$Global:DFile = ($DefaultPath + $Global:ReportName + "_Diagram_" + (get-date -Format "yyyy-MM-dd_HH_mm") + ".vsdx")
                $DDFile = ($DefaultPath + $ReportName + "_Diagram_" + (get-date -Format "yyyy-MM-dd_HH_mm") + ".xml")
            }
        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Excel file: ' + $File)

        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Starting Default Jobs.')

            Start-ARIExtraJobs -SkipDiagram $SkipDiagram -SkipAdvisory $SkipAdvisory -SkipPolicy $SkipPolicy -SecurityCenter $SecurityCenter -Subscriptions $Subscriptions -Resources $Resources -Advisories $Advisories -DDFile $DDFile -DiagramCache $DiagramCache -FullEnv $FullEnv -ResourceContainers $ResourceContainers -Security $Security -PolicyAssign $PolicyAssign -PolicySetDef $PolicySetDef -PolicyDef $PolicyDef -Automation $Automation -Debug $Debug

        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Starting Resources Report Function.')

            Build-AzureResourceReport -Subscriptions $Subscriptions -DefaultPath $DefaultPath -ExtractionRunTime $ExtractionRuntime -Resources $Resources -SecurityCenter $SecurityCenter -File $File -DDFile $DDFile -Heavy $Heavy -SkipDiagram $SkipDiagram -RunLite $RunLite -PlatOS $PlatOS -InTag $InTag -SkipPolicy $SkipPolicy -SkipAdvisory $SkipAdvisory -Automation $Automation -SkipAPIs $SkipAPIs, -Overview $Overview -Debug $Debug

        if ($StorageAccount)
            {
                Set-AzStorageBlobContent -File $File -Container $StorageContainer -Context $StorageContext | Out-Null
            }
    }
}

$Measure = $TotalRunTime.Totalminutes.ToString('#######.##')

Write-Host ('Report Complete. Total Runtime was: ') -NoNewline
Write-Host $Measure -NoNewline -ForegroundColor Cyan
Write-Host (' Minutes')
Write-Host ('Total Resources: ') -NoNewline
Write-Host $ResourcesCount -ForegroundColor Cyan
if (!$SkipAdvisory.IsPresent)
    {
        Write-Host ('Total Advisories: ') -NoNewline
        write-host $advco -ForegroundColor Cyan
    }
if (!$SkipPolicy.IsPresent -and !$SkipAPIs.IsPresent)
    {
        Write-Host ('Total Policies: ') -NoNewline
        write-host $polco -ForegroundColor Cyan
    }
if ($SecurityCenter.IsPresent)
    {
        Write-Host ('Total Security Advisories: ' + $Secadvco)
    }

Write-Host ''
Write-Host ('Excel file saved at: ') -NoNewline
write-host $File -ForegroundColor Cyan
Write-Host ''

if(!$SkipDiagram.IsPresent)
    {
        Write-Host ('Draw.io Diagram file saved at: ') -NoNewline
        write-host $DDFile -ForegroundColor Cyan
        Write-Host ''
    }
}