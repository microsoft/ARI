##########################################################################################
#                                                                                        #
#                * Azure Resource Inventory ( ARI ) Report Generator *                   #
#                                                                                        #
#       Version: 3.1.33                                                                  #
#                                                                                        #
#       Date: 07/08/2024                                                                 #
#                                                                                        #
##########################################################################################
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

.PARAMETER IncludeTags
    Use this parameter to include Tags of every Azure Resources

.PARAMETER Debug
    Execute ASCI in debug mode.

.EXAMPLE
    Default utilization. Read all tenants you have privileges, select a tenant in menu and collect from all subscriptions:
    PS C:\> .\AzureResourceInventory.ps1

    Define the Tenant ID:
    PS C:\> .\AzureResourceInventory.ps1 -TenantID <your-Tenant-Id>

    Define the Tenant ID and for a specific Subscription:
    PS C:\>.\AzureResourceInventory.ps1 -TenantID <your-Tenant-Id> -SubscriptionID <your-Subscription-Id>

.NOTES
    AUTHORS: Claudio Merola and Renato Gregio | Azure Infrastucture/Automation/Devops/Governance

.LINK
    Copyright (c) 2018 Microsoft Corporation. All rights reserved.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
#>

param ($TenantID,
        [switch]$SecurityCenter,
        $SubscriptionID,
        $ManagementGroup,
        $Appid,
        $Secret,
        [string[]]$ResourceGroup,
        $TagKey,
        $TagValue,
        [switch]$SkipAdvisory,
        [switch]$SkipPolicy,
        [switch]$IncludeTags,
        [switch]$QuotaUsage,
        [switch]$Online,
        [switch]$Diagram,
        [switch]$SkipDiagram,
        [switch]$Lite,
        [switch]$Debug,
        [switch]$Help,
        [switch]$DeviceLogin,
        $AzureEnvironment,
        [switch]$DiagramFullEnvironment,
        $ReportName = 'AzureResourceInventory',
        $ReportDir)

    if ($Debug.IsPresent) {$DebugPreference = 'Continue'}

    if ($Debug.IsPresent) {$ErrorActionPreference = "Continue" }Else {$ErrorActionPreference = "silentlycontinue" }

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Debbuging Mode: On. ErrorActionPreference was set to "Continue", every error will be presented.')

    if ($IncludeTags.IsPresent) { $Global:InTag = $true } else { $Global:InTag = $false }

    if ($Online.IsPresent) { $Global:RunOnline = $true }else { $Global:RunOnline = $false }
    if ($Lite.IsPresent) { $Global:RunLite = $true }else { $Global:RunLite = $false }
    if ($DiagramFullEnvironment.IsPresent) {$Global:FullEnv = $true}else{$Global:FullEnv = $false}

    $Global:SRuntime = Measure-Command -Expression {

    <#########################################################          Help          ######################################################################>

    Function usageMode() {
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
        Write-Host "For CloudShell:"
        Write-Host "e.g. />./AzureResourceInventory.ps1"
        Write-Host ""
        Write-Host "For PowerShell Desktop:"
        Write-Host ""
        Write-Host "If you do not specify Resource Inventory will be performed on all subscriptions for the selected tenant. "
        Write-Host "e.g. />./AzureResourceInventory.ps1"
        Write-Host ""
        Write-Host "To perform the inventory in a specific Tenant and subscription use <-TenantID> and <-SubscriptionID> parameter "
        Write-Host "e.g. />./AzureResourceInventory.ps1 -TenantID <Azure Tenant ID> -SubscriptionID <Subscription ID>"
        Write-Host ""
        Write-Host "Including Tags:"
        Write-Host " By Default Azure Resource inventory do not include Resource Tags."
        Write-Host " To include Tags at the inventory use <-IncludeTags> parameter. "
        Write-Host "e.g. />./AzureResourceInventory.ps1 -TenantID <Azure Tenant ID> -IncludeTags"
        Write-Host ""
        Write-Host "Skipping Azure Advisor:"
        Write-Host " By Default Azure Resource inventory collects Azure Advisor Data."
        Write-Host " To ignore this  use <-SkipAdvisory> parameter. "
        Write-Host "e.g. />./AzureResourceInventory.ps1 -TenantID <Azure Tenant ID> -SubscriptionID <Subscription ID> -SkipAdvisory"
        Write-Host ""
        Write-Host "Using the latest modules :"
        Write-Host " You can use the latest modules. For this use <-Online> parameter."
        Write-Host " It's a pre-requisite to have internet access for ARI GitHub repo"
        Write-Host "e.g. />./AzureResourceInventory.ps1 -TenantID <Azure Tenant ID> -Online"
        Write-Host ""
        Write-Host "Running in Debug Mode :"
        Write-Host " To run in a Debug Mode use <-Debug> parameter."
        Write-Host ".e.g. />/AzureResourceInventory.ps1 -TenantID <Azure Tenant ID> -Debug"
        Write-Host ""
    }

    Function Variables {
        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Cleaning default variables')
        $Global:ResourceContainers = @()
        $Global:Resources = @()
        $Global:Advisories = @()
        $Global:Security = @()
        $Global:Policies = @()
        $Global:Subscriptions = ''
        $Global:ReportName = $ReportName

        $Global:Repo = 'https://api.github.com/repos/microsoft/ari/git/trees/main?recursive=1'
        $Global:RawRepo = 'https://raw.githubusercontent.com/microsoft/ARI/main'

        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Checking if -Online parameter will have to be forced.')
        if(!$Online.IsPresent)
            {
                if($PSScriptRoot -like '*\*')
                    {
                        $LocalFilesValidation = New-Object System.IO.StreamReader($PSScriptRoot + '\Extras\Subscriptions.ps1')
                    }
                else
                    {
                        $LocalFilesValidation = New-Object System.IO.StreamReader($PSScriptRoot + '/Extras/Subscriptions.ps1')
                    }
                if([string]::IsNullOrEmpty($LocalFilesValidation))
                    {
                        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Using -Online by force.')
                        $Global:RunOnline = $true
                    }
                else
                    {
                        $Global:RunOnline = $false
                    }
                }

    }

    <#########################################################       Environment      ######################################################################>

    Function Extractor {

        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Starting Extractor function')

        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Powershell Edition: ' + ([string]$psversiontable.psEdition))
        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Powershell Version: ' + ([string]$psversiontable.psVersion))
        function checkAzCli() {
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Starting checkAzCli function')
            Write-Host "Validating Az Cli.."
            $azcli = az --version
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Current az cli version: ' + $azcli[0])
            if ($null -eq $azcli) {
                Read-Host "Azure CLI Not Found. Press <Enter> to finish script"
                Exit
            }
            Write-Host "Validating Az Cli Extension.."
            $azcliExt = az extension list --output json | ConvertFrom-Json
            $azcliExt = $azcliExt | Where-Object {$_.name -eq 'resource-graph'}
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Current Resource-Graph Extension Version: ' + $azcliExt.version)
            $AzcliExtV = $azcliExt | Where-Object {$_.name -eq 'resource-graph'}
            if (!$AzcliExtV) {
                Write-Host "Adding Az Cli Extension"
                az extension add --name resource-graph
            }
            Write-Host "Validating ImportExcel Module.."
            $VarExcel = Get-InstalledModule -Name ImportExcel -ErrorAction silentlycontinue
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'ImportExcel Module Version: ' + ([string]$VarExcel.Version.Major + '.' + [string]$VarExcel.Version.Minor + '.' + [string]$VarExcel.Version.Build))
            if ($null -eq $VarExcel) {
                Write-Host "Trying to install ImportExcel Module.."
                Install-Module -Name ImportExcel -Force
            }
            $VarExcel = Get-InstalledModule -Name ImportExcel -ErrorAction silentlycontinue
            if ($null -eq $VarExcel) {
                Read-Host 'Admininstrator rights required to install ImportExcel Module. Press <Enter> to finish script'
                Exit
            }
        }

        function LoginSession() {
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Starting LoginSession function')
            if(![string]::IsNullOrEmpty($AzureEnvironment))
                {
                    az cloud set --name $AzureEnvironment
                }
            $CloudEnv = az cloud list | ConvertFrom-Json
            Write-Host "Azure Cloud Environment: " -NoNewline
            $CurrentCloudEnvName = $CloudEnv | Where-Object {$_.isActive -eq 'True'}
            Write-Host $CurrentCloudEnvName.name -BackgroundColor Green
            if (!$TenantID) {
                write-host "Tenant ID not specified. Use -TenantID parameter if you want to specify directly. "
                write-host "Authenticating Azure"
                write-host ""
                Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Cleaning az account cache')
                az account clear | Out-Null
                Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Calling az login')
                if($DeviceLogin.IsPresent)
                    {
                        az login --use-device-code
                    }
                else
                    {
                        az login --only-show-errors | Out-Null
                    }
                write-host ""
                write-host ""
                $Tenants = az account list --query [].homeTenantId -o tsv --only-show-errors | Sort-Object -Unique
                Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Checking number of Tenants')
                if ($Tenants.Count -eq 1) {
                    write-host "You have privileges only in One Tenant "
                    write-host ""
                    $TenantID = $Tenants
                }
                else {
                    write-host "Select the the Azure Tenant ID that you want to connect : "
                    write-host ""
                    $SequenceID = 1
                    foreach ($TenantID in $Tenants) {
                        write-host "$SequenceID)  $TenantID"
                        $SequenceID ++
                    }
                    write-host ""
                    [int]$SelectTenant = read-host "Select Tenant ( default 1 )"
                    $defaultTenant = --$SelectTenant
                    $TenantID = $Tenants[$defaultTenant]
                    if($DeviceLogin.IsPresent)
                        {
                            az login --use-device-code -t $TenantID
                        }
                    else
                        {
                            az login -t $TenantID --only-show-errors | Out-Null
                        }
                }

                write-host "Extracting from Tenant $TenantID"
                Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Extracting Subscription details')
                $Global:Subscriptions = az account list --output json --only-show-errors | ConvertFrom-Json
                $Global:Subscriptions = $Subscriptions | Where-Object { $_.tenantID -eq $TenantID }
                if ($SubscriptionID)
                    {
                        if($SubscriptionID.count -gt 1)
                            {
                                $Global:Subscriptions = $Subscriptions | Where-Object { $_.ID -in $SubscriptionID }
                            }
                        else
                            {
                                $Global:Subscriptions = $Subscriptions | Where-Object { $_.ID -eq $SubscriptionID }
                            }
                    }
            }
            else {
                az account clear | Out-Null
                if (!$Appid) {
                    if($DeviceLogin.IsPresent)
                        {
                            az login --use-device-code -t $TenantID
                        }
                    else
                        {
                            $AZConfig = az config get core.enable_broker_on_windows --only-show-errors | ConvertFrom-Json
                            if ($AZConfig.value -eq $true)
                                {
                                    az config set core.enable_broker_on_windows=false --only-show-errors
                                    #az config set core.login_experience_v2=off --only-show-errors
                                    az login -t $TenantID --only-show-errors
                                    az config set core.enable_broker_on_windows=true --only-show-errors
                                }
                            else
                                {
                                    az login -t $TenantID --only-show-errors
                                }
                            
                        }
                    }
                elseif ($Appid -and $Secret -and $tenantid) {
                    write-host "Using Service Principal Authentication Method"
                    az login --service-principal -u $appid -p $secret -t $TenantID | Out-Null
                }
                else{
                    write-host "You are trying to use Service Principal Authentication Method in a wrong way."
                    write-host "It's Mandatory to specify Application ID, Secret and Tenant ID in Azure Resource Inventory"
                    write-host ""
                    write-host ".\AzureResourceInventory.ps1 -appid <SP AppID> -secret <SP Secret> -tenant <TenantID>"
                    Exit
                }
                $Global:Subscriptions = az account list --output json | ConvertFrom-Json
                $Global:Subscriptions = $Subscriptions | Where-Object { $_.tenantID -eq $TenantID }
                if ($SubscriptionID)
                    {
                        if($SubscriptionID.count -gt 1)
                            {
                                $Global:Subscriptions = $Subscriptions | Where-Object { $_.ID -in $SubscriptionID }
                            }
                        else
                            {
                                $Global:Subscriptions = $Subscriptions | Where-Object { $_.ID -eq $SubscriptionID }
                            }
                    }
            }
        }

        function checkPS() {
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Starting checkPS function')
            $CShell = try{Get-CloudShellTip}catch{}
            if ($CShell) {
                write-host 'Azure CloudShell Identified.'
                $Global:PlatOS = 'Azure CloudShell'
                write-host ""
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
                                    Write-Host "ERROR:" -NoNewline -ForegroundColor Red
                                    Write-Host " Wrong ReportDir Path!"
                                    Write-Host ""
                                    Write-Host "ReportDir Parameter must contain the full path."
                                    Write-Host ""
                                    Exit
                                }
                        }
                $Global:DefaultPath = if($ReportDir) {$ReportDir} else {"$HOME/AzureResourceInventory/"}
                $Global:DiagramCache = if($ReportDir) {$ReportDir} else {"$HOME/AzureResourceInventory/DiagramCache/"}
                $Global:Subscriptions = az account list --output json --only-show-errors | ConvertFrom-Json
                if ($SubscriptionID)
                    {
                        if($SubscriptionID.count -gt 1)
                            {
                                $Global:Subscriptions = $Subscriptions | Where-Object { $_.ID -in $SubscriptionID }
                            }
                        else
                            {
                                $Global:Subscriptions = $Subscriptions | Where-Object { $_.ID -eq $SubscriptionID }
                            }
                    }
            }
            else
            {
                if ($PSVersionTable.Platform -eq 'Unix') {
                    write-host "PowerShell Unix Identified."
                    $Global:PlatOS = 'PowerShell Unix'
                    write-host ""
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
                                    Write-Host "ERROR:" -NoNewline -ForegroundColor Red
                                    Write-Host " Wrong ReportDir Path!"
                                    Write-Host ""
                                    Write-Host "ReportDir Parameter must contain the full path."
                                    Write-Host ""
                                    Exit
                                }
                        }
                    $Global:DefaultPath = if($ReportDir) {$ReportDir} else {"$HOME/AzureResourceInventory/"}
                    $Global:DiagramCache = if($ReportDir) {$ReportDir} else {"$HOME/AzureResourceInventory/DiagramCache/"}
                    LoginSession
                }
                else {
                    write-host "PowerShell Desktop Identified."
                    $Global:PlatOS = 'PowerShell Desktop'
                    write-host ""
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
                                    Write-Host "ERROR:" -NoNewline -ForegroundColor Red
                                    Write-Host " Wrong ReportDir Path!"
                                    Write-Host ""
                                    Write-Host "ReportDir Parameter must contain the full path."
                                    Write-Host ""
                                    Exit
                                }
                        }
                    $Global:DefaultPath = if($ReportDir) {$ReportDir} else {"C:\AzureResourceInventory\"}
                    $Global:DiagramCache = if($ReportDir) {($ReportDir+'DiagramCache\')} else {"C:\AzureResourceInventory\DiagramCache\"}
                    LoginSession
                }
            }
        }

        <###################################################### Checking PowerShell ######################################################################>

        checkAzCli
        checkPS

        #Field for tags
        if ($IncludeTags.IsPresent) {
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+"Tags will be included")
            $GraphQueryTags = ",tags "
        } else {
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+"Tags will be ignored")
            $GraphQueryTags = ""
        }

        <###################################################### Subscriptions ######################################################################>

        Write-Progress -activity 'Azure Inventory' -Status "1% Complete." -PercentComplete 2 -CurrentOperation 'Discovering Subscriptions..'

        if (![string]::IsNullOrEmpty($ManagementGroup))
            {
                Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Management group name supplied: ' + $ManagmentGroupName)
                $group = az account management-group entities list --query "[?name =='$ManagementGroup']" | ConvertFrom-Json
                if ($group.Count -lt 1)
                {
                    Write-Host "ERROR:" -NoNewline -ForegroundColor Red
                    Write-Host "Management Group $ManagementGroup not found!"
                    Write-Host ""
                    Write-Host "Please check the Management Group name and try again."
                    Write-Host ""
                    Exit
                }
                else
                {
                    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Management groups found: ' + $group.count)
                    foreach ($item in $group)
                    {
                        $Global:Subscriptions = @()
                        $GraphQuery = "resourcecontainers | where type == 'microsoft.resources/subscriptions' | mv-expand managementGroupParent = properties.managementGroupAncestorsChain | where managementGroupParent.name =~ '$($item.name)' | summarize count()"
                        $EnvSize = az graph query -q $GraphQuery --output json --only-show-errors | ConvertFrom-Json
                        $EnvSizeNum = $EnvSize.data.'count_'

                        if ($EnvSizeNum -ge 1) {
                            $Loop = $EnvSizeNum / 1000
                            $Loop = [math]::ceiling($Loop)
                            $Looper = 0
                            $Limit = 0

                            while ($Looper -lt $Loop) {
                                $GraphQuery = "resourcecontainers | where type == 'microsoft.resources/subscriptions' | mv-expand managementGroupParent = properties.managementGroupAncestorsChain | where managementGroupParent.name =~ '$($item.name)' | project id = subscriptionId"
                                $Resource = (az graph query -q $GraphQuery --skip $Limit --first 1000 --output json --only-show-errors).tolower() | ConvertFrom-Json

                                foreach ($Sub in $Resource.data) {
                                    $Global:Subscriptions += az account show --subscription $Sub.id --output json --only-show-errors | ConvertFrom-Json
                                }

                                Start-Sleep 2
                                $Looper ++
                                Write-Progress -Id 1 -activity "Running Subscription Inventory Job" -Status "$Looper / $Loop of Subscription Jobs" -PercentComplete (($Looper / $Loop) * 100)
                                $Limit = $Limit + 1000
                            }
                        }
                        Write-Progress -Id 1 -activity "Running Subscription Inventory Job" -Status "$Looper / $Loop of Subscription Jobs" -Completed
                    }
                }
            }

        $SubCount = [string]$Global:Subscriptions.id.count

        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Number of Subscriptions Found: ' + $SubCount)
        Write-Progress -activity 'Azure Inventory' -Status "3% Complete." -PercentComplete 3 -CurrentOperation "$SubCount Subscriptions found.."

        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Checking report folder: ' + $DefaultPath )
        if ((Test-Path -Path $DefaultPath -PathType Container) -eq $false) {
            New-Item -Type Directory -Force -Path $DefaultPath | Out-Null
        }
        if ((Test-Path -Path $DiagramCache -PathType Container) -eq $false) {
            New-Item -Type Directory -Force -Path $DiagramCache | Out-Null
        }

        <######################################################## INVENTORY LOOPs #######################################################################>

    $Global:ExtractionRuntime = Measure-Command -Expression {

        Write-Progress -Id 1 -activity "Running Inventory Jobs" -Status "1% Complete." -Completed
        function Invoke-InventoryLoop {
            param($GraphQuery,$FSubscri,$LoopName)

                $LocalResults = @()
                if($FSubscri.count -gt 200)
                    {
                        $SubLoop = $FSubscri.count / 200
                        $SubLooper = 0
                        $NStart = 0
                        $NEnd = 200
                        while ($SubLooper -lt $SubLoop)
                            {
                                $Sub = $FSubscri[$NStart..$NEnd]

                                $QueryResult = (az graph query -q $GraphQuery --subscriptions $Sub --first 1000 --output json --only-show-errors).tolower() | ConvertFrom-Json
                                $LocalResults += $QueryResult
                                while ($QueryResult.skip_token) {
                                    $QueryResult = (az graph query -q $GraphQuery --subscriptions $Sub --skip-token $QueryResult.skip_token --first 1000 --output json --only-show-errors).tolower() | ConvertFrom-Json
                                    $LocalResults += $QueryResult
                                }
                                $NStart = $NStart + 200
                                $NEnd = $NEnd + 200
                                $SubLooper ++
                            }
                    }
                else
                    {
                        $QueryResult = (az graph query -q $GraphQuery --subscriptions $FSubscri --first 1000 --output json --only-show-errors).tolower()
                        try
                            {
                                $QueryResult = $QueryResult | ConvertFrom-Json
                            }
                        catch
                            {
                                $QueryResult = $QueryResult | ConvertFrom-Json -AsHashtable
                            }
                        
                        $LocalResults += $QueryResult
                        while ($QueryResult.skip_token) {
                            $QueryResult = (az graph query -q $GraphQuery --subscriptions $FSubscri --skip-token $QueryResult.skip_token --first 1000 --output json --only-show-errors).tolower() | ConvertFrom-Json
                            try
                                {
                                    $QueryResult = $QueryResult | ConvertFrom-Json
                                }
                            catch
                                {
                                    $QueryResult = $QueryResult | ConvertFrom-Json -AsHashtable
                                }
                            $LocalResults += $QueryResult
                        }
                    }
            $LocalResults.data
        }


        Write-Progress -activity 'Azure Inventory' -Status "4% Complete." -PercentComplete 4 -CurrentOperation "Starting Resources extraction jobs.."

        if(![string]::IsNullOrEmpty($ResourceGroup) -and [string]::IsNullOrEmpty($SubscriptionID))
            {
                Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Resource Group Name present, but missing Subscription ID.')
                Write-Host ''
                Write-Host 'If Using the -ResourceGroup Parameter, the Subscription ID must be informed'
                Write-Host ''
                Exit
            }
        else
            {
                $Subscri = $Global:Subscriptions.id
                $RGQueryExtension = ''
                $TagQueryExtension = ''
                $MGQueryExtension = ''
                if(![string]::IsNullOrEmpty($ResourceGroup) -and ![string]::IsNullOrEmpty($SubscriptionID))
                    {
                        $RGQueryExtension = "| where resourceGroup in~ ('$([String]::Join("','",$ResourceGroup))')"
                    }
                elseif(![string]::IsNullOrEmpty($TagKey) -and ![string]::IsNullOrEmpty($TagValue))
                    {
                        $TagQueryExtension = "| where isnotempty(tags) | mvexpand tags | extend tagKey = tostring(bag_keys(tags)[0]) | extend tagValue = tostring(tags[tagKey]) | where tagKey =~ '$TagKey' and tagValue =~ '$TagValue'"
                    }
                elseif (![string]::IsNullOrEmpty($ManagementGroup)) 
                    {
                        $MGQueryExtension = "| join kind=inner (resourcecontainers | where type == 'microsoft.resources/subscriptions' | mv-expand managementGroupParent = properties.managementGroupAncestorsChain | where managementGroupParent.name =~ '$ManagementGroup' | project subscriptionId, managanagementGroup = managementGroupParent.name) on subscriptionId"
                        $MGContainerExtension = "| mv-expand managementGroupParent = properties.managementGroupAncestorsChain | where managementGroupParent.name =~ '$ManagementGroup'"
                    }
            }

                $GraphQuery = "resources $RGQueryExtension $TagQueryExtension $MGQueryExtension | project id,name,type,tenantId,kind,location,resourceGroup,subscriptionId,managedBy,sku,plan,properties,identity,zones,extendedLocation$($GraphQueryTags) | order by id asc"

                Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Invoking Inventory Loop for Resources')
                $Global:Resources += Invoke-InventoryLoop -GraphQuery $GraphQuery -FSubscri $Subscri -LoopName 'Resources'

                $GraphQuery = "networkresources $RGQueryExtension $TagQueryExtension $MGQueryExtension | project id,name,type,tenantId,kind,location,resourceGroup,subscriptionId,managedBy,sku,plan,properties,identity,zones,extendedLocation$($GraphQueryTags) | order by id asc"

                Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Invoking Inventory Loop for Network Resources')
                $Global:Resources += Invoke-InventoryLoop -GraphQuery $GraphQuery -FSubscri $Subscri -LoopName 'Network Resources'

                $GraphQuery = "recoveryservicesresources $RGQueryExtension $TagQueryExtension | where type =~ 'microsoft.recoveryservices/vaults/backupfabrics/protectioncontainers/protecteditems' or type =~ 'microsoft.recoveryservices/vaults/backuppolicies' $MGQueryExtension  | project id,name,type,tenantId,kind,location,resourceGroup,subscriptionId,managedBy,sku,plan,properties,identity,zones,extendedLocation$($GraphQueryTags) | order by id asc"

                Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Invoking Inventory Loop for Backup Resources')
                $Global:Resources += Invoke-InventoryLoop -GraphQuery $GraphQuery -FSubscri $Subscri -LoopName 'Backup Items'

                $GraphQuery = "desktopvirtualizationresources $RGQueryExtension $MGQueryExtension| project id,name,type,tenantId,kind,location,resourceGroup,subscriptionId,managedBy,sku,plan,properties,identity,zones,extendedLocation$($GraphQueryTags) | order by id asc"

                Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Invoking Inventory Loop for AVD Resources')
                $Global:Resources += Invoke-InventoryLoop -GraphQuery $GraphQuery -FSubscri $Subscri -LoopName 'Virtual Desktop'

                $GraphQuery = "resourcecontainers $RGQueryExtension $TagQueryExtension $MGContainerExtension | project id,name,type,tenantId,kind,location,resourceGroup,subscriptionId,managedBy,sku,plan,properties,identity,zones,extendedLocation$($GraphQueryTags) | order by id asc"

                Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Invoking Inventory Loop for Resource Containers')
                $Global:ResourceContainers = Invoke-InventoryLoop -GraphQuery $GraphQuery -FSubscri $Subscri -LoopName 'Subscriptions and Resource Groups'

                if (!($SkipPolicy.IsPresent)) 
                    {
                        $GraphQuery = "policyresources | where type == 'microsoft.authorization/policyassignments' | order by id asc"

                        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Invoking Inventory Loop for Policies Resources')
                        $Global:Policies = Invoke-InventoryLoop -GraphQuery $GraphQuery -FSubscri $Subscri -LoopName 'Policies'
                    }
                if (!($SkipAdvisory.IsPresent)) 
                    {
                        $GraphQuery = "advisorresources $RGQueryExtension $MGQueryExtension | order by id asc"

                        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Invoking Inventory Loop for Advisories')
                        $Global:Advisories = Invoke-InventoryLoop -GraphQuery $GraphQuery -FSubscri $Subscri -LoopName 'Advisories'
                    }
                if ($SecurityCenter.IsPresent) 
                    {
                        $GraphQuery = "securityresources $RGQueryExtension | where type =~ 'microsoft.security/assessments' and properties['status']['code'] == 'Unhealthy' $MGQueryExtension | order by id asc" 

                        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Invoking Inventory Loop for Security Resources')
                        $Global:Security = Invoke-InventoryLoop -GraphQuery $GraphQuery -FSubscri $Subscri -LoopName 'Security Center'
                    }

        <######################################################### QUOTA JOB ######################################################################>

        if($QuotaUsage.isPresent)
            {
                Start-Job -Name 'Quota Usage' -ScriptBlock {

                $Location = @()
                Foreach($Sub in $($args[1]))
                    {
                        $Locs = ($($args[0]) | Where-Object {$_.subscriptionId -eq $Sub.id -and $_.Type -in 'microsoft.compute/virtualmachines','microsoft.compute/virtualmachinescalesets'} | Group-Object -Property Location).name
                        $Val = @{
                            'Loc' = $Locs;
                            'Sub' = $Sub.name
                        }
                        $Location += $Val
                    }
                $Quotas = @()
                Foreach($Loc in $Location)
                    {
                        if($Loc.Loc.count -eq 1)
                            {
                                $Quota = az vm list-usage --location $Loc.Loc --subscription $Loc.Sub -o json | ConvertFrom-Json
                                $Quota = $Quota | Where-Object {$_.CurrentValue -ge 1}
                                $Q = @{
                                    'Location' = $Loc.Loc;
                                    'Subscription' = $Loc.Sub;
                                    'Data' = $Quota
                                }
                                $Quotas += $Q
                            }
                        else {
                                foreach($Loc1 in $Loc.loc)
                                    {
                                        $Quota = az vm list-usage --location $Loc1 --subscription $Loc.Sub -o json | ConvertFrom-Json
                                        $Quota = $Quota | Where-Object {$_.CurrentValue -ge 1}
                                        $Q = @{
                                            'Location' = $Loc1;
                                            'Subscription' = $Loc.Sub;
                                            'Data' = $Quota
                                        }
                                        $Quotas += $Q
                                    }
                        }
                    }
                    $Quotas
                } -ArgumentList $Global:Resources, $Global:Subscriptions
            }

        Write-Progress -activity 'Azure Inventory' -PercentComplete 20

        Write-Progress -Id 1 -activity "Running Inventory Jobs" -Status "100% Complete." -Completed

        }
    }


    <#########################################################  Creating Excel File   ######################################################################>

    Function RunMain {

        $Global:ReportingRunTime = Measure-Command -Expression {

        #### Creating Excel file variable:
        $Global:File = ($DefaultPath + $Global:ReportName + "_Report_" + (get-date -Format "yyyy-MM-dd_HH_mm") + ".xlsx")
        #$Global:DFile = ($DefaultPath + $Global:ReportName + "_Diagram_" + (get-date -Format "yyyy-MM-dd_HH_mm") + ".vsdx")
        $Global:DDFile = ($DefaultPath + $Global:ReportName + "_Diagram_" + (get-date -Format "yyyy-MM-dd_HH_mm") + ".xml")
        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Excel file:' + $File)

        #### Generic Conditional Text rules, Excel style specifications for the spreadsheets and tables:
        $Global:TableStyle = "Light19"
        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Excel Table Style used: ' + $TableStyle)

        Write-Progress -activity 'Azure Inventory' -Status "21% Complete." -PercentComplete 21 -CurrentOperation "Starting to process extraction data.."


        <######################################################### IMPORT UNSUPPORTED VERSION LIST ######################################################################>

        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Importing List of Unsupported Versions.')
        If ($RunOnline -eq $true) {
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Looking for the following file: '+$RawRepo + '/Extras/Support.json')
            $ModuSeq = (New-Object System.Net.WebClient).DownloadString($RawRepo + '/Extras/Support.json')
        }
        Else {
            if($PSScriptRoot -like '*\*')
                {
                    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Looking for the following file: '+$PSScriptRoot + '\Extras\Support.json')
                    $ModuSeq0 = New-Object System.IO.StreamReader($PSScriptRoot + '\Extras\Support.json')
                }
            else
                {
                    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Looking for the following file: '+$PSScriptRoot + '/Extras/Support.json')
                    $ModuSeq0 = New-Object System.IO.StreamReader($PSScriptRoot + '/Extras/Support.json')
                }
            $ModuSeq = $ModuSeq0.ReadToEnd()
            $ModuSeq0.Dispose()
        }

        $Unsupported = $ModuSeq | ConvertFrom-Json

        $DataActive = ('Azure Resource Inventory Reporting (' + ($resources.count) + ') Resources')

        <######################################################### DRAW.IO DIAGRAM JOB ######################################################################>

        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Checking if Draw.io Diagram Job Should be Run.')
        if (!$SkipDiagram.IsPresent) {
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Starting Draw.io Diagram Processing Job.')
            Start-job -Name 'DrawDiagram' -ScriptBlock {

                $DiagramCache = $($args[5])

                $TempPath = $DiagramCache.split("DiagramCache\")[0]

                $Logfile = ($TempPath+'DiagramLogFile.log')

                Add-Content -Path $Logfile -Value ('DrawIOCoreJob - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Starting Draw.IO Job')

                If ($($args[8]) -eq $true) {
                    Add-Content -Path $Logfile -Value ('DrawIOCoreJob - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Running Online')
                    $ModuSeq = (New-Object System.Net.WebClient).DownloadString($($args[10]) + '/Extras/DrawIODiagram.ps1')
                }
                Else {
                    if($($args[0]) -like '*\*')
                        {
                            Add-Content -Path $Logfile -Value ('DrawIOCoreJob - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Running Local')
                            $ModuSeq0 = New-Object System.IO.StreamReader($($args[0]) + '\Extras\DrawIODiagram.ps1')
                        }
                    else
                        {
                            $ModuSeq0 = New-Object System.IO.StreamReader($($args[0]) + '/Extras/DrawIODiagram.ps1')
                        }
                    $ModuSeq0 = New-Object System.IO.StreamReader($($args[0]) + '/Extras/DrawIODiagram.ps1')
                    $ModuSeq = $ModuSeq0.ReadToEnd()
                    $ModuSeq0.Dispose()
                }

                Add-Content -Path $Logfile -Value ('DrawIOCoreJob - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Calling Draw.IO Thread')
                try
                    {
                        $DrawRun = ([PowerShell]::Create()).AddScript($ModuSeq).AddArgument($($args[1])).AddArgument($($args[2])).AddArgument($($args[3])).AddArgument($($args[4])).AddArgument($($args[5])).AddArgument($($args[6])).AddArgument($($args[7]))

                        $DrawJob = $DrawRun.BeginInvoke()

                        while ($DrawJob.IsCompleted -contains $false) { Start-Sleep -Milliseconds 100 }

                        $DrawRun.EndInvoke($DrawJob)

                        $DrawRun.Dispose()
                    }
                catch
                    {
                        Add-Content -Path $Logfile -Value ('DrawIOCoreJob - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+$_.Exception.Message)
                    }
                Add-Content -Path $Logfile -Value ('DrawIOCoreJob - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Draw.IO Ended.')

            } -ArgumentList $PSScriptRoot, $Subscriptions, $Resources, $Advisories, $DDFile, $DiagramCache, $FullEnv, $ResourceContainers ,$RunOnline, $Repo, $RawRepo   | Out-Null
        }

        <######################################################### VISIO DIAGRAM JOB ######################################################################>
        <#
        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Checking if Visio Diagram Job Should be Run.')
        if ($Diagram.IsPresent) {
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Starting Visio Diagram Processing Job.')
            Start-job -Name 'VisioDiagram' -ScriptBlock {

                If ($($args[5]) -eq $true) {
                    $ModuSeq = (New-Object System.Net.WebClient).DownloadString($($args[7]) + '/Extras/VisioDiagram.ps1')
                }
                Else {
                    $ModuSeq0 = New-Object System.IO.StreamReader($($args[0]) + '\Extras\VisioDiagram.ps1')
                    $ModuSeq = $ModuSeq0.ReadToEnd()
                    $ModuSeq0.Dispose()
                }

                $ScriptBlock = [Scriptblock]::Create($ModuSeq)

                $VisioRun = ([PowerShell]::Create()).AddScript($ScriptBlock).AddArgument($($args[1])).AddArgument($($args[2])).AddArgument($($args[3])).AddArgument($($args[4]))

                $VisioJob = $VisioRun.BeginInvoke()

                while ($VisioJob.IsCompleted -contains $false) {}

                $VisioRun.EndInvoke($VisioJob)

                $VisioRun.Dispose()

            } -ArgumentList $PSScriptRoot, $Subscriptions, $Resources, $Advisories, $DFile, $RunOnline, $Repo, $RawRepo   | Out-Null
        }
        #>

        <######################################################### SECURITY CENTER JOB ######################################################################>

        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Checking If Should Run Security Center Job.')
        if ($SecurityCenter.IsPresent) {
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Starting Security Job.')
            Start-Job -Name 'Security' -ScriptBlock {

                If ($($args[5]) -eq $true) {
                    $ModuSeq = (New-Object System.Net.WebClient).DownloadString($($args[6]) + '/Extras/SecurityCenter.ps1')
                }
                Else {
                    if($($args[0]) -like '*\*')
                        {
                            $ModuSeq0 = New-Object System.IO.StreamReader($($args[0]) + '\Extras\SecurityCenter.ps1')
                        }
                    else
                        {
                            $ModuSeq0 = New-Object System.IO.StreamReader($($args[0]) + '/Extras/SecurityCenter.ps1')
                        }
                    $ModuSeq = $ModuSeq0.ReadToEnd()
                    $ModuSeq0.Dispose()
                }

                $SecRun = ([PowerShell]::Create()).AddScript($ModuSeq).AddArgument($($args[1])).AddArgument($($args[2])).AddArgument($($args[3]))

                $SecJob = $SecRun.BeginInvoke()

                while ($SecJob.IsCompleted -contains $false) { Start-Sleep -Milliseconds 100 }

                $SecResult = $SecRun.EndInvoke($SecJob)

                $SecRun.Dispose()

                $SecResult

            } -ArgumentList $PSScriptRoot, $Subscriptions , $Security, 'Processing' , $File, $RunOnline, $RawRepo | Out-Null
        }

        <######################################################### POLICY JOB ######################################################################>

        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Checking If Should Run Policy Job.')
        if (!$SkipPolicy.IsPresent) {
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Starting Policy Processing Job.')
            Start-Job -Name 'Policy' -ScriptBlock {

                If ($($args[5]) -eq $true) {
                    $ModuSeq = (New-Object System.Net.WebClient).DownloadString($($args[6]) + '/Extras/Policy.ps1')
                }
                Else {
                    if($($args[0]) -like '*\*')
                        {
                            $ModuSeq0 = New-Object System.IO.StreamReader($($args[0]) + '\Extras\Policy.ps1')
                        }
                        else
                        {
                            $ModuSeq0 = New-Object System.IO.StreamReader($($args[0]) + '/Extras/Policy.ps1')
                        }
                    $ModuSeq = $ModuSeq0.ReadToEnd()
                    $ModuSeq0.Dispose()
                }

                $PolRun = ([PowerShell]::Create()).AddScript($ModuSeq).AddArgument($($args[1])).AddArgument($($args[2])).AddArgument($($args[3])).AddArgument($($args[4]))

                $PolJob = $PolRun.BeginInvoke()

                while ($PolJob.IsCompleted -contains $false) { Start-Sleep -Milliseconds 100 }

                $PolResult = $PolRun.EndInvoke($PolJob)

                $PolRun.Dispose()

                $PolResult

            } -ArgumentList $PSScriptRoot, $Policies, 'Processing', $Subscriptions, $File, $RunOnline, $RawRepo | Out-Null
        }

        <######################################################### ADVISORY JOB ######################################################################>

        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Checking If Should Run Advisory Job.')
        if (!$SkipAdvisory.IsPresent) {
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Starting Advisory Processing Job.')
            Start-Job -Name 'Advisory' -ScriptBlock {

                If ($($args[4]) -eq $true) {
                    $ModuSeq = (New-Object System.Net.WebClient).DownloadString($($args[5]) + '/Extras/Advisory.ps1')
                }
                Else {
                    if($($args[0]) -like '*\*')
                        {
                            $ModuSeq0 = New-Object System.IO.StreamReader($($args[0]) + '\Extras\Advisory.ps1')
                        }
                        else
                        {
                            $ModuSeq0 = New-Object System.IO.StreamReader($($args[0]) + '/Extras/Advisory.ps1')
                        }
                    $ModuSeq = $ModuSeq0.ReadToEnd()
                    $ModuSeq0.Dispose()
                }

                $AdvRun = ([PowerShell]::Create()).AddScript($ModuSeq).AddArgument($($args[1])).AddArgument($($args[2])).AddArgument($($args[3]))

                $AdvJob = $AdvRun.BeginInvoke()

                while ($AdvJob.IsCompleted -contains $false) { Start-Sleep -Milliseconds 100 }

                $AdvResult = $AdvRun.EndInvoke($AdvJob)

                $AdvRun.Dispose()

                $AdvResult

            } -ArgumentList $PSScriptRoot, $Advisories, 'Processing' , $File, $RunOnline, $RawRepo | Out-Null
        }

        <######################################################### SUBSCRIPTIONS JOB ######################################################################>

        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Starting Subscriptions job.')
        Start-Job -Name 'Subscriptions' -ScriptBlock {

            If ($($args[5]) -eq $true) {
                $ModuSeq = (New-Object System.Net.WebClient).DownloadString($($args[6]) + '/Extras/Subscriptions.ps1')
            }
            Else {
                if($($args[0]) -like '*\*')
                    {
                        $ModuSeq0 = New-Object System.IO.StreamReader($($args[0]) + '\Extras\Subscriptions.ps1')
                    }
                else
                    {
                        $ModuSeq0 = New-Object System.IO.StreamReader($($args[0]) + '/Extras/Subscriptions.ps1')
                    }
                $ModuSeq = $ModuSeq0.ReadToEnd()
                $ModuSeq0.Dispose()
            }

            $SubRun = ([PowerShell]::Create()).AddScript($ModuSeq).AddArgument($($args[1])).AddArgument($($args[2])).AddArgument($($args[3])).AddArgument($($args[4]))

            $SubJob = $SubRun.BeginInvoke()

            while ($SubJob.IsCompleted -contains $false) { Start-Sleep -Milliseconds 100 }

            $SubResult = $SubRun.EndInvoke($SubJob)

            $SubRun.Dispose()

            $SubResult

        } -ArgumentList $PSScriptRoot, $Subscriptions, $Resources, 'Processing' , $File, $RunOnline, $RawRepo | Out-Null

        <######################################################### RESOURCE GROUP JOB ######################################################################>

        switch ($Resources.count) 
            {
                {$_ -le 1000} 
                    {
                        $EnvSizeLooper = 1000
                        $DebugEnvSize = 'Small'
                    }
                {$_ -gt 1000 -and $_ -le 30000}
                    {
                        $EnvSizeLooper = 5000
                        $DebugEnvSize = 'Medium'
                    }
                {$_ -gt 30000 -and $_ -le 60000}
                    {
                        $EnvSizeLooper = 10000
                        $DebugEnvSize = 'Large'
                        Write-Host $DebugEnvSize -NoNewline -ForegroundColor Green
                        Write-Host (' Size Environment Identified.')
                        Write-Host ('Jobs will be run in batches to avoid CPU Overload.')
                    }
                {$_ -gt 60000}
                    {
                        $EnvSizeLooper = 5000
                        $DebugEnvSize = 'Enormous'
                        Write-Host $DebugEnvSize -NoNewline -ForegroundColor Green
                        Write-Host (' Size Environment Identified.')
                        Write-Host ('Jobs will be run in batches to prevent CPU Overload.')
                    }
            }
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Starting Processing Jobs in '+ $DebugEnvSize +' Mode.')

            $Loop = $resources.count / $EnvSizeLooper
            $Loop = [math]::ceiling($Loop)
            $Looper = 0
            $Limit = 0
            $JobLoop = 1

            $ResourcesCount = [string]$Resources.count
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Total Resources Being Processed: '+ $ResourcesCount)

            while ($Looper -lt $Loop) {
                $Looper ++

                $Resource = $resources | Select-Object -First $EnvSizeLooper -Skip $Limit

                $ResourceCount = [string]$Resource.count
                $LoopCountStr = [string]$Looper
                Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Resources Being Processed in ResourceJob_'+ $LoopCountStr + ': ' + $ResourceCount)

                Start-Job -Name ('ResourceJob_'+$Looper) -ScriptBlock {

                    $Job = @()

                    $Subscriptions = $($args[2])
                    $InTag = $($args[3])
                    $Resource = $($args[4])
                    $Task = $($args[5])
                    $Unsupported = $($args[12])
                    $RunOnline = $($args[9])
                    $Repo = $($args[10])
                    $RawRepo = $($args[11])

                    If ($RunOnline -eq $true) {
                        $OnlineRepo = Invoke-WebRequest -Uri $Repo
                        $RepoContent = $OnlineRepo | ConvertFrom-Json
                        $Modules = ($RepoContent.tree | Where-Object {$_.path -like '*.ps1' -and $_.path -notlike 'Extras/*' -and $_.path -ne 'AzureResourceInventory.ps1' -and $_.path -notlike 'Automation/*'}).path
                    }
                    Else {
                        if($($args[1]) -like '*\*')
                            {
                                $Modules = Get-ChildItem -Path ($($args[1]) + '\Modules\*.ps1') -Recurse
                            }
                        else
                            {
                                $Modules = Get-ChildItem -Path ($($args[1]) + '/Modules/*.ps1') -Recurse
                            }
                    }
                    $job = @()

                    $Modules | ForEach-Object {
                        If ($RunOnline -eq $true) {
                                $Modul = $_.split('/')
                                $ModName = $Modul[2]
                                $ModName = $ModName.replace(".ps1","")
                                $ModuSeq = (New-Object System.Net.WebClient).DownloadString($RawRepo + '/' + $_)
                            } Else {
                                $ModName = $_.Name.replace(".ps1","")
                                $ModuSeq0 = New-Object System.IO.StreamReader($_.FullName)
                                $ModuSeq = $ModuSeq0.ReadToEnd()
                                $ModuSeq0.Dispose()
                        }
                        Start-Sleep -Milliseconds 250

                        New-Variable -Name ('ModRun' + $ModName)
                        New-Variable -Name ('ModJob' + $ModName)

                        Set-Variable -Name ('ModRun' + $ModName) -Value ([PowerShell]::Create()).AddScript($ModuSeq).AddArgument($PSScriptRoot).AddArgument($Subscriptions).AddArgument($InTag).AddArgument($Resource).AddArgument($Task).AddArgument($null).AddArgument($null).AddArgument($null).AddArgument($Unsupported)

                        Set-Variable -Name ('ModJob' + $ModName) -Value ((get-variable -name ('ModRun' + $ModName)).Value).BeginInvoke()

                        $job += (get-variable -name ('ModJob' + $ModName)).Value
                        Start-Sleep -Milliseconds 250
                        Clear-Variable -Name ModName
                    }

                    while ($Job.Runspace.IsCompleted -contains $false) { Start-Sleep -Milliseconds 1000 }

                    $Modules | ForEach-Object {
                        If ($RunOnline -eq $true) {
                                $Modul = $_.split('/')
                                $ModName = $Modul[2]
                                $ModName = $ModName.replace(".ps1","")
                            } Else {
                                $ModName = $_.Name.replace(".ps1","")
                        }
                        Start-Sleep -Milliseconds 250

                        New-Variable -Name ('ModValue' + $ModName)
                        Set-Variable -Name ('ModValue' + $ModName) -Value (((get-variable -name ('ModRun' + $ModName)).Value).EndInvoke((get-variable -name ('ModJob' + $ModName)).Value))

                        Clear-Variable -Name ('ModRun' + $ModName)
                        Clear-Variable -Name ('ModJob' + $ModName)
                        Start-Sleep -Milliseconds 250
                        Clear-Variable -Name ModName
                    }

                    [System.GC]::GetTotalMemory($true) | out-null

                    $Hashtable = New-Object System.Collections.Hashtable

                    $Modules | ForEach-Object {
                        If ($RunOnline -eq $true) {
                                $Modul = $_.split('/')
                                $ModName = $Modul[2]
                                $ModName = $ModName.replace(".ps1","")
                            } Else {
                                $ModName = $_.Name.replace(".ps1","")
                        }
                        Start-Sleep -Milliseconds 250

                        $Hashtable["$ModName"] = (get-variable -name ('ModValue' + $ModName)).Value

                        Clear-Variable -Name ('ModValue' + $ModName)
                        Start-Sleep -Milliseconds 100

                        Clear-Variable -Name ModName
                    }

                    [System.GC]::GetTotalMemory($true) | out-null

                $Hashtable
                } -ArgumentList $null, $PSScriptRoot, $Subscriptions, $InTag, $Resource, 'Processing', $null, $null, $null, $RunOnline, $Repo, $RawRepo, $Unsupported | Out-Null
                $Limit = $Limit + $EnvSizeLooper
                Start-Sleep -Milliseconds 250
                if($DebugEnvSize -in ('Large','Enormous') -and $JobLoop -eq 5)
                    {
                        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Waiting Batch of Jobs to Complete.')

                        $coun = 0

                        $InterJobNames = (Get-Job | Where-Object {$_.name -like 'ResourceJob_*' -and $_.State -eq 'Running'}).Name

                        while (get-job -Name $InterJobNames | Where-Object { $_.State -eq 'Running' }) {
                            $jb = get-job -Name $InterJobNames
                            $c = (((($jb.count - ($jb | Where-Object { $_.State -eq 'Running' }).Count)) / $jb.Count) * 100)
                            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'initial Jobs Running: '+[string]($jb | Where-Object { $_.State -eq 'Running' }).count)
                            $c = [math]::Round($coun)
                            Write-Progress -Id 1 -activity "Processing Initial Resource Jobs" -Status "$coun% Complete." -PercentComplete $coun
                            Start-Sleep -Seconds 15
                        }
                        $JobLoop = 0
                    }
                $JobLoop ++
                [System.GC]::GetTotalMemory($true) | out-null
            }

        <############################################################## RESOURCES LOOP CREATION #############################################################>


        $Global:ResourcesCount = $Global:Resources.Count

        if($DebugEnvSize -in ('Large','Enormous'))
            {
                Clear-Variable Resources -Scope Global
                [System.GC]::GetTotalMemory($true) | out-null
            }

        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Starting Jobs Collector.')
        Write-Progress -activity $DataActive -Status "Processing Inventory" -PercentComplete 0
        $c = 0

        $JobNames = (Get-Job | Where-Object {$_.name -like 'ResourceJob_*'}).Name

        while (get-job -Name $JobNames | Where-Object { $_.State -eq 'Running' }) {
            $jb = get-job -Name $JobNames
            $c = (((($jb.count - ($jb | Where-Object { $_.State -eq 'Running' }).Count)) / $jb.Count) * 100)
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Jobs Still Running: '+[string]($jb | Where-Object { $_.State -eq 'Running' }).count)
            $c = [math]::Round($c)
            Write-Progress -Id 1 -activity "Processing Resource Jobs" -Status "$c% Complete." -PercentComplete $c
            Start-Sleep -Seconds 5
        }
        Write-Progress -Id 1 -activity "Processing Resource Jobs" -Status "100% Complete." -Completed

        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Jobs Compleated.')

        $AzSubs = Receive-Job -Name 'Subscriptions'

        $Global:SmaResources = Foreach ($Job in $JobNames)
            {
                $TempJob = Receive-Job -Name $Job
                Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Job '+ $Job +' Returned: ' + ($TempJob.values | Where-Object {$_ -ne $null}).Count + ' Resource Types.')
                $TempJob
            }

        <############################################################## REPORTING ###################################################################>

        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Starting Reporting Phase.')
        Write-Progress -activity $DataActive -Status "Processing Inventory" -PercentComplete 50

        If ($RunOnline -eq $true) {
            $OnlineRepo = Invoke-WebRequest -Uri $Repo
            $RepoContent = $OnlineRepo | ConvertFrom-Json
            $Modules = ($RepoContent.tree | Where-Object {$_.path -like '*.ps1' -and $_.path -notlike 'Extras/*' -and $_.path -ne 'AzureResourceInventory.ps1' -and $_.path -notlike 'Automation/*'}).path
        }
        Else {
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Running Offline, Gathering List Of Modules.')
            if($PSScriptRoot -like '*\*')
                {
                    $Modules = Get-ChildItem -Path ($PSScriptRoot + '\Modules\*.ps1') -Recurse
                }
            else
                {
                    $Modules = Get-ChildItem -Path ($PSScriptRoot + '/Modules/*.ps1') -Recurse
                }
        }

        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Modules Found: ' + $Modules.Count)
        $Lops = $Modules.count
        $ReportCounter = 0

        foreach ($Module in $Modules) {

            $c = (($ReportCounter / $Lops) * 100)
            $c = [math]::Round($c)
            Write-Progress -Id 1 -activity "Building Report" -Status "$c% Complete." -PercentComplete $c

            If ($RunOnline -eq $true) {
                    $Modul = $Module.split('/')
                    $ModName = $Modul[2]
                    $ModuSeq = (New-Object System.Net.WebClient).DownloadString($RawRepo + '/' + $Module)
                } Else {
                    $ModuSeq0 = New-Object System.IO.StreamReader($Module.FullName)
                    $ModuSeq = $ModuSeq0.ReadToEnd()
                    $ModuSeq0.Dispose()
            }
            Start-Sleep -Milliseconds 50
            $ModuleName = $Module.name.replace('.ps1','')

            $ModuleResourceCount = $SmaResources[$ModuleName].count

            if ($ModuleResourceCount -gt 0)
                {
                    Start-Sleep -Milliseconds 100
                    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+"Running Module: '$ModuleName'. Resources Count: $ModuleResourceCount")

                    $ExcelRun = ([PowerShell]::Create()).AddScript($ModuSeq).AddArgument($PSScriptRoot).AddArgument($null).AddArgument($InTag).AddArgument($null).AddArgument('Reporting').AddArgument($file).AddArgument($SmaResources).AddArgument($TableStyle).AddArgument($Unsupported)

                    $ExcelJob = $ExcelRun.BeginInvoke()

                    while ($ExcelJob.IsCompleted -contains $false) { Start-Sleep -Milliseconds 100 }

                    $ExcelRun.EndInvoke($ExcelJob)

                    $ExcelRun.Dispose()

                    [System.GC]::GetTotalMemory($true) | out-null
                }

            $ReportCounter ++

        }

        if($DebugEnvSize -in ('Large','Enormous'))
            {
                Clear-Variable SmaResources -Scope Global
                [System.GC]::GetTotalMemory($true) | out-null
            }

        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Resource Reporting Phase Done.')

        <################################################################### QUOTAS ###################################################################>

        if($QuotaUsage.IsPresent)
            {
                get-job -Name 'Quota Usage' | Wait-Job

                $Global:AzQuota = Receive-Job -Name 'Quota Usage'

                Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Generating Quota Usage sheet for: ' + $Global:AzQuota.count + ' Subscriptions/Regions.')

                Write-Progress -activity 'Azure Resource Inventory Quota Usage' -Status "50% Complete." -PercentComplete 50 -CurrentOperation "Building Quota Sheet"

                If ($RunOnline -eq $true) {
                    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Looking for the following file: '+$RawRepo + '/Extras/QuotaUsage.ps1')
                    $ModuSeq = (New-Object System.Net.WebClient).DownloadString($RawRepo + '/Extras/QuotaUsage.ps1')
                }
                Else {
                    if($PSScriptRoot -like '*\*')
                        {
                            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Looking for the following file: '+$PSScriptRoot + '\Extras\QuotaUsage.ps1')
                            $ModuSeq0 = New-Object System.IO.StreamReader($PSScriptRoot + '\Extras\QuotaUsage.ps1')
                        }
                    else
                        {
                            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Looking for the following file: '+$PSScriptRoot + '/Extras/QuotaUsage.ps1')
                            $ModuSeq0 = New-Object System.IO.StreamReader($PSScriptRoot + '/Extras/QuotaUsage.ps1')
                        }
                    $ModuSeq = $ModuSeq0.ReadToEnd()
                    $ModuSeq0.Dispose()
                }

                $QuotaRun = ([PowerShell]::Create()).AddScript($ModuSeq).AddArgument($File).AddArgument($Global:AzQuota).AddArgument($TableStyle)

                $QuotaJob = $QuotaRun.BeginInvoke()

                while ($QuotaJob.IsCompleted -contains $false) { Start-Sleep -Milliseconds 100 }

                $QuotaRun.EndInvoke($QuotaJob)

                $QuotaRun.Dispose()

                Write-Progress -activity 'Azure Resource Inventory Quota Usage' -Status "100% Complete." -Completed
            }


        <################################################ SECURITY CENTER #######################################################>
        #### Security Center worksheet is generated apart

        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Checking if Should Generate Security Center Sheet.')
        if ($SecurityCenter.IsPresent) {
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Generating Security Center Sheet.')
            $Global:Secadvco = $Security.Count

            Write-Progress -activity $DataActive -Status "Building Security Center Report" -PercentComplete 0 -CurrentOperation "Considering $Secadvco Security Advisories"

            while (get-job -Name 'Security' | Where-Object { $_.State -eq 'Running' }) {
                Write-Progress -Id 1 -activity 'Processing Security Center Advisories' -Status "50% Complete." -PercentComplete 50
                Start-Sleep -Seconds 2
            }
            Write-Progress -Id 1 -activity 'Processing Security Center Advisories'  -Status "100% Complete." -Completed

            $Sec = Receive-Job -Name 'Security'

            If ($RunOnline -eq $true) {
                Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Looking for the following file: '+$RawRepo + '/Extras/SecurityCenter.ps1')
                $ModuSeq = (New-Object System.Net.WebClient).DownloadString($RawRepo + '/Extras/SecurityCenter.ps1')
            }
            Else {
                if($PSScriptRoot -like '*\*')
                    {
                        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Looking for the following file: '+$PSScriptRoot + '\Extras\SecurityCenter.ps1')
                        $ModuSeq0 = New-Object System.IO.StreamReader($PSScriptRoot + '\Extras\SecurityCenter.ps1')
                    }
                else
                    {
                        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Looking for the following file: '+$PSScriptRoot + '/Extras/SecurityCenter.ps1')
                        $ModuSeq0 = New-Object System.IO.StreamReader($PSScriptRoot + '/Extras/SecurityCenter.ps1')
                    }
                $ModuSeq = $ModuSeq0.ReadToEnd()
                $ModuSeq0.Dispose()
            }

            $SecExcelRun = ([PowerShell]::Create()).AddScript($ModuSeq).AddArgument($null).AddArgument($null).AddArgument('Reporting').AddArgument($file).AddArgument($Sec).AddArgument($TableStyle)

            $SecExcelJob = $SecExcelRun.BeginInvoke()

            while ($SecExcelJob.IsCompleted -contains $false) { Start-Sleep -Milliseconds 100 }

            $SecExcelRun.EndInvoke($SecExcelJob)

            $SecExcelRun.Dispose()
        }


        <################################################ POLICY #######################################################>
        #### Policy worksheet is generated apart from the resources
        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Checking if Should Generate Policy Sheet.')
        if (!$SkipPolicy.IsPresent) {
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Generating Policy Sheet.')
            $Global:polco = $Policies.count

            Write-Progress -activity $DataActive -Status "Building Policy Report" -PercentComplete 0 -CurrentOperation "Considering $polco Policies"

            while (get-job -Name 'Policy' | Where-Object { $_.State -eq 'Running' }) {
                Write-Progress -Id 1 -activity 'Processing Policies' -Status "50% Complete." -PercentComplete 50
                Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Policy Job is: '+(get-job -Name 'Policy').State)
                Start-Sleep -Seconds 2
            }
            Write-Progress -Id 1 -activity 'Processing Policies'  -Status "100% Complete." -Completed

            $Global:Pol = Receive-Job -Name 'Policy'

            If ($RunOnline -eq $true) {
                Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Looking for the following file: '+$RawRepo + '/Extras/Policy.ps1')
                $ModuSeq = (New-Object System.Net.WebClient).DownloadString($RawRepo + '/Extras/Policy.ps1')
            }
            Else {
                if($PSScriptRoot -like '*\*')
                    {
                        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Looking for the following file: '+$PSScriptRoot + '\Extras\Policy.ps1')
                        $ModuSeq0 = New-Object System.IO.StreamReader($PSScriptRoot + '\Extras\Policy.ps1')
                    }
                else
                    {
                        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Looking for the following file: '+$PSScriptRoot + '/Extras/Policy.ps1')
                        $ModuSeq0 = New-Object System.IO.StreamReader($PSScriptRoot + '/Extras/Policy.ps1')
                    }
                $ModuSeq = $ModuSeq0.ReadToEnd()
                $ModuSeq0.Dispose()
            }

            $PolExcelRun = ([PowerShell]::Create()).AddScript($ModuSeq).AddArgument($null).AddArgument('Reporting').AddArgument($null).AddArgument($file).AddArgument($Pol).AddArgument($TableStyle)

            $PolExcelJob = $PolExcelRun.BeginInvoke()

            while ($PolExcelJob.IsCompleted -contains $false) { Start-Sleep -Milliseconds 100 }

            $PolExcelRun.EndInvoke($PolExcelJob)

            $PolExcelRun.Dispose()
        }


        <################################################ ADVISOR #######################################################>
        #### Advisor worksheet is generated apart from the resources
        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Checking if Should Generate Advisory Sheet.')
        if (!$SkipAdvisory.IsPresent) {
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Generating Advisor Sheet.')
            $Global:advco = $Advisories.count

            Write-Progress -activity $DataActive -Status "Building Advisories Report" -PercentComplete 0 -CurrentOperation "Considering $advco Advisories"

            while (get-job -Name 'Advisory' | Where-Object { $_.State -eq 'Running' }) {
                Write-Progress -Id 1 -activity 'Processing Advisories' -Status "50% Complete." -PercentComplete 50
                Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Advisory Job is: '+(get-job -Name 'Advisory').State)
                Start-Sleep -Seconds 2
            }
            Write-Progress -Id 1 -activity 'Processing Advisories'  -Status "100% Complete." -Completed

            $Adv = Receive-Job -Name 'Advisory'

            If ($RunOnline -eq $true) {
                Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Looking for the following file: '+$RawRepo + '/Extras/Advisory.ps1')
                $ModuSeq = (New-Object System.Net.WebClient).DownloadString($RawRepo + '/Extras/Advisory.ps1')
            }
            Else {
                if($PSScriptRoot -like '*\*')
                    {
                        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Looking for the following file: '+$PSScriptRoot + '\Extras\Advisory.ps1')
                        $ModuSeq0 = New-Object System.IO.StreamReader($PSScriptRoot + '\Extras\Advisory.ps1')
                    }
                else
                    {
                        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Looking for the following file: '+$PSScriptRoot + '/Extras/Advisory.ps1')
                        $ModuSeq0 = New-Object System.IO.StreamReader($PSScriptRoot + '/Extras/Advisory.ps1')
                    }
                $ModuSeq = $ModuSeq0.ReadToEnd()
                $ModuSeq0.Dispose()
            }

            $AdvExcelRun = ([PowerShell]::Create()).AddScript($ModuSeq).AddArgument($null).AddArgument('Reporting').AddArgument($file).AddArgument($Adv).AddArgument($TableStyle)

            $AdvExcelJob = $AdvExcelRun.BeginInvoke()

            while ($AdvExcelJob.IsCompleted -contains $false) { Start-Sleep -Milliseconds 100 }

            $AdvExcelRun.EndInvoke($AdvExcelJob)

            $AdvExcelRun.Dispose()
        }

        <################################################################### SUBSCRIPTIONS ###################################################################>

        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Generating Subscription sheet for: ' + $Subscriptions.count + ' Subscriptions.')

        Write-Progress -activity 'Azure Resource Inventory Subscriptions' -Status "50% Complete." -PercentComplete 50 -CurrentOperation "Building Subscriptions Sheet"

        If ($RunOnline -eq $true) {
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Looking for the following file: '+$RawRepo + '/Extras/Subscriptions.ps1')
            $ModuSeq = (New-Object System.Net.WebClient).DownloadString($RawRepo + '/Extras/Subscriptions.ps1')
        }
        Else {
            if($PSScriptRoot -like '*\*')
                {
                    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Looking for the following file: '+$PSScriptRoot + '\Extras\Subscriptions.ps1')
                    $ModuSeq0 = New-Object System.IO.StreamReader($PSScriptRoot + '\Extras\Subscriptions.ps1')
                }
            else
                {
                    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Looking for the following file: '+$PSScriptRoot + '/Extras/Subscriptions.ps1')
                    $ModuSeq0 = New-Object System.IO.StreamReader($PSScriptRoot + '/Extras/Subscriptions.ps1')
                }
            $ModuSeq = $ModuSeq0.ReadToEnd()
            $ModuSeq0.Dispose()
        }

        $SubsRun = ([PowerShell]::Create()).AddScript($ModuSeq).AddArgument($null).AddArgument($null).AddArgument('Reporting').AddArgument($file).AddArgument($AzSubs).AddArgument($TableStyle)

        $SubsJob = $SubsRun.BeginInvoke()

        while ($SubsJob.IsCompleted -contains $false) { Start-Sleep -Milliseconds 100 }

        $SubsRun.EndInvoke($SubsJob)

        $SubsRun.Dispose()

        [System.GC]::GetTotalMemory($true) | out-null

        Write-Progress -activity 'Azure Resource Inventory Subscriptions' -Status "100% Complete." -Completed

        <################################################################### CHARTS ###################################################################>

        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Generating Overview sheet (Charts).')

        Write-Progress -activity 'Azure Resource Inventory Reporting Charts' -Status "10% Complete." -PercentComplete 10 -CurrentOperation "Starting Excel Chart's Thread."

        If ($RunOnline -eq $true) {
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Looking for the following file: '+$RawRepo + '/Extras/Charts.ps1')
            $ModuSeq = (New-Object System.Net.WebClient).DownloadString($RawRepo + '/Extras/Charts.ps1')
        }
        Else {
            if($PSScriptRoot -like '*\*')
                {
                    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Looking for the following file: '+$PSScriptRoot + '\Extras\Charts.ps1')
                    $ModuSeq0 = New-Object System.IO.StreamReader($PSScriptRoot + '\Extras\Charts.ps1')
                }
            else
                {
                    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Looking for the following file: '+$PSScriptRoot + '/Extras/Charts.ps1')
                    $ModuSeq0 = New-Object System.IO.StreamReader($PSScriptRoot + '/Extras/Charts.ps1')
                }
            $ModuSeq = $ModuSeq0.ReadToEnd()
            $ModuSeq0.Dispose()
        }

    }

        Write-Progress -activity 'Azure Resource Inventory Reporting Charts' -Status "15% Complete." -PercentComplete 15 -CurrentOperation "Invoking Excel Chart's Thread."

        $ChartsRun = ([PowerShell]::Create()).AddScript($ModuSeq).AddArgument($file).AddArgument($TableStyle).AddArgument($Global:PlatOS).AddArgument($Global:Subscriptions).AddArgument($Global:ResourcesCount).AddArgument($ExtractionRunTime).AddArgument($ReportingRunTime).AddArgument($RunLite)

        $ChartsJob = $ChartsRun.BeginInvoke()

        Write-Progress -activity 'Azure Resource Inventory Reporting Charts' -Status "30% Complete." -PercentComplete 30 -CurrentOperation "Waiting Excel Chart's Thread."

        while ($ChartsJob.IsCompleted -contains $false) { Start-Sleep -Milliseconds 100 }

        $ChartsRun.EndInvoke($ChartsJob)

        $ChartsRun.Dispose()

        [System.GC]::GetTotalMemory($true) | out-null

        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Finished Charts Phase.')

        Write-Progress -activity 'Azure Resource Inventory Reporting Charts' -Status "100% Complete." -Completed

        if($Diagram.IsPresent)
        {
        Write-Progress -activity 'Diagrams' -Status "Completing Diagram" -PercentComplete 70 -CurrentOperation "Consolidating Diagram"

            while (get-job -Name 'DrawDiagram' | Where-Object { $_.State -eq 'Running' }) {
                Write-Progress -Id 1 -activity 'Processing Diagrams' -Status "50% Complete." -PercentComplete 50
                Start-Sleep -Seconds 2
            }
            Write-Progress -Id 1 -activity 'Processing Diagrams'  -Status "100% Complete." -Completed

        Write-Progress -activity 'Diagrams' -Status "Closing Diagram File" -Completed
        }

        Get-Job | Wait-Job | Remove-Job
    }


    <#########################################################    END OF FUNCTIONS    ######################################################################>

    if ($Help.IsPresent) {
        usageMode
        Exit
    }
    else {
        Variables
        Extractor
        RunMain
    }

}

$Measure = $Global:SRuntime.Totalminutes.ToString('#######.##')

Write-Host ('Report Complete. Total Runtime was: ') -NoNewline
Write-Host $Measure -NoNewline -ForegroundColor Cyan
Write-Host (' Minutes')
Write-Host ('Total Resources: ') -NoNewline
Write-Host $Global:ResourcesCount -ForegroundColor Cyan
if (!$SkipAdvisory.IsPresent)
    {
        Write-Host ('Total Advisories: ') -NoNewline
        write-host $advco -ForegroundColor Cyan
    }
if (!$SkipPolicy.IsPresent)
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