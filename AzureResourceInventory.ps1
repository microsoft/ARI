##########################################################################################
#                                                                                        #
#                * Azure Resource Inventory ( ARI ) Report Generator *                   #
#                                                                                        #
#       Version: 3.1.04                                                                  #
#                                                                                        #
#       Date: 07/21/2023                                                                 #
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
        $ResourceGroup, 
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

    Write-Debug ('Debbuging Mode: On. ErrorActionPreference was set to "Continue", every error will be presented.')

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
        Write-Host " -ResourceGroup <NAME> :  Specifies one unique Resource Group to be inventoried, This parameter requires the -SubscriptionID to work. "
        Write-Host " -TagKey <NAME>        :  Specifies the tag key to be inventoried, This parameter requires the -SubscriptionID to work. "
        Write-Host " -TagValue <NAME>      :  Specifies the tag value be inventoried, This parameter requires the -SubscriptionID to work. "
        Write-Host " -SkipAdvisory         :  Do not collect Azure Advisory. "
        Write-Host " -SecurityCenter       :  Include Security Center Data. "
        Write-Host " -IncludeTags          :  Include Resource Tags. "
        Write-Host " -Diagram              :  Create a Visio Diagram. "
        Write-Host " -Online               :  Use Online Modules. "
        Write-Host " -Debug                :  Run in a Debug mode. "
        Write-Host " -AzureEnvironment     :  Change the Azure Cloud Environment. "
        Write-Host " -ReportName           :  Change the Default Name of the report. "
        Write-Host " -ReportDir            :  Change the Default path of the report. "
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
        Write-Host "e.g. />./AzureResourceInventory.ps1 -TenantID <Azure Tenant ID> --IncludeTags"
        Write-Host ""
        Write-Host "Collecting Security Center Data :"
        Write-Host " By Default Azure Resource inventory do not collect Security Center Data."
        Write-Host " To include Security Center details in the report, use <-SecurityCenter> parameter. "
        Write-Host "e.g. />./AzureResourceInventory.ps1 -TenantID <Azure Tenant ID> -SubscriptionID <Subscription ID> -SecurityCenter"
        Write-Host ""
        Write-Host "Skipping Azure Advisor:"
        Write-Host " By Default Azure Resource inventory collects Azure Advisor Data."
        Write-Host " To ignore this  use <-SkipAdvisory> parameter. "
        Write-Host "e.g. />./AzureResourceInventory.ps1 -TenantID <Azure Tenant ID> -SubscriptionID <Subscription ID> -SkipAdvisory"
        Write-Host ""
        Write-Host "Creating Network Diagram :"
        Write-Host " If you Want to create a Draw.io Diagram you need to use <-Diagram> parameter."
        Write-Host " This feature only works on Windows O.S. "
        Write-Host "e.g. />./AzureResourceInventory.ps1 -TenantID <Azure Tenant ID> -Diagram"
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
        Write-Debug ('Cleaning default variables')
        $Global:ResourceContainers = @()
        $Global:Resources = @()
        $Global:Advisories = @()
        $Global:Security = @()
        $Global:Policies = @()
        $Global:Subscriptions = ''
        $Global:ReportName = $ReportName        

        $Global:Repo = 'https://api.github.com/repos/microsoft/ari/git/trees/main?recursive=1'
        $Global:RawRepo = 'https://raw.githubusercontent.com/microsoft/ARI/main'

        Write-Debug ('Checking if -Online parameter will have to be forced.')
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
                        Write-Debug ('Using -Online by force.')
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

        Write-Debug ('Starting Extractor function')
        function checkAzCli() {
            Write-Debug ('Starting checkAzCli function')
            Write-Host "Validating Az Cli.."
            $azcli = az --version
            Write-Debug ('Current az cli version: ' + $azcli[0])
            if ($null -eq $azcli) {
                Read-Host "Azure CLI Not Found. Press <Enter> to finish script"
                Exit
            }
            Write-Host "Validating Az Cli Extension.."
            $azcliExt = az extension list --output json | ConvertFrom-Json
            $azcliExt = $azcliExt | Where-Object {$_.name -eq 'resource-graph'}
            Write-Debug ('Current Resource-Graph Extension Version: ' + $azcliExt.version)
            $AzcliExtV = $azcliExt | Where-Object {$_.name -eq 'resource-graph'}
            if (!$AzcliExtV) {
                Write-Host "Adding Az Cli Extension"
                az extension add --name resource-graph
            }
            Write-Host "Validating ImportExcel Module.."
            $VarExcel = Get-InstalledModule -Name ImportExcel -ErrorAction silentlycontinue
            Write-Debug ('ImportExcel Module Version: ' + ([string]$VarExcel.Version.Major + '.' + [string]$VarExcel.Version.Minor + '.' + [string]$VarExcel.Version.Build))
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
            Write-Debug ('Starting LoginSession function')            
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
                Write-Debug ('Cleaning az account cache')
                az account clear | Out-Null
                Write-Debug ('Calling az login')
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
                Write-Debug ('Checking number of Tenants')
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
                Write-Debug ('Extracting Subscription details')
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
                            az login -t $TenantID --only-show-errors | Out-Null
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
        }

        function checkPS() {
            Write-Debug ('Starting checkPS function')
            $CShell = try{Get-CloudDrive}catch{}
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
                    $Global:DiagramCache = if($ReportDir) {$ReportDir} else {"C:\AzureResourceInventory\DiagramCache\"}
                    LoginSession
                }
            }
        }

        <###################################################### Checking PowerShell ######################################################################>

        checkAzCli
        checkPS

        #Field for tags
        if ($IncludeTags.IsPresent) {
            Write-Debug "Tags will be included"
            $GraphQueryTags = ",tags "
        } else {
            Write-Debug "Tags will be ignored"
            $GraphQueryTags = ""
        }

        <###################################################### Subscriptions ######################################################################>

        Write-Progress -activity 'Azure Inventory' -Status "1% Complete." -PercentComplete 2 -CurrentOperation 'Discovering Subscriptions..'

        if (![string]::IsNullOrEmpty($ManagementGroup))
            {
                Write-Debug ('Management group name supplied: ' + $ManagmentGroupName)
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
                    Write-Debug ('Management groups found: ' + $group.count)
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

        $SubCount = $Global:Subscriptions.count

        Write-Debug ('Number of Subscriptions Found: ' + $SubCount)
        Write-Progress -activity 'Azure Inventory' -Status "3% Complete." -PercentComplete 3 -CurrentOperation "$SubCount Subscriptions found.."

        Write-Debug ('Checking report folder: ' + $DefaultPath )
        if ((Test-Path -Path $DefaultPath -PathType Container) -eq $false) {
            New-Item -Type Directory -Force -Path $DefaultPath | Out-Null
        }
        if ((Test-Path -Path $DiagramCache -PathType Container) -eq $false) {
            New-Item -Type Directory -Force -Path $DiagramCache | Out-Null
        }

        <######################################################## INVENTORY LOOPs #######################################################################>

        Write-Progress -activity 'Azure Inventory' -Status "4% Complete." -PercentComplete 4 -CurrentOperation "Starting Resources extraction jobs.."        

        if(![string]::IsNullOrEmpty($ResourceGroup) -and [string]::IsNullOrEmpty($SubscriptionID))
            {
                Write-Debug ('Resource Group Name present, but missing Subscription ID.')
                Write-Host ''
                Write-Host 'If Using the -ResourceGroup Parameter, the Subscription ID must be informed'
                Write-Host ''
                Exit
            }
        if(![string]::IsNullOrEmpty($ResourceGroup) -and ![string]::IsNullOrEmpty($SubscriptionID))
            {
                Write-Debug ('Extracting Resources from Subscription: '+$SubscriptionID+'. And from Resource Group: '+$ResourceGroup)

                $Subscri = $SubscriptionID

                $GraphQuery = "resources | where resourceGroup == '$ResourceGroup' and strlen(properties.definition.actions) < 123000 | summarize count()"
                $EnvSize = az graph query -q $GraphQuery --subscriptions $Subscri --output json --only-show-errors | ConvertFrom-Json
                $EnvSizeNum = $EnvSize.data.'count_'

                if ($EnvSizeNum -ge 1) {
                    $Loop = $EnvSizeNum / 1000
                    $Loop = [math]::ceiling($Loop)
                    $Looper = 0
                    $Limit = 0

                    while ($Looper -lt $Loop) {
                        $GraphQuery = "resources | where resourceGroup == '$ResourceGroup' and strlen(properties.definition.actions) < 123000 | project id,name,type,tenantId,kind,location,resourceGroup,subscriptionId,managedBy,sku,plan,properties,identity,zones,extendedLocation$($GraphQueryTags) | order by id asc"
                        $Resource = (az graph query -q $GraphQuery --subscriptions $Subscri --skip $Limit --first 1000 --output json --only-show-errors).tolower() | ConvertFrom-Json

                        $Global:Resources += $Resource.data
                        Start-Sleep 2
                        $Looper ++
                        Write-Progress -Id 1 -activity "Running Resource Inventory Job" -Status "$Looper / $Loop of Inventory Jobs" -PercentComplete (($Looper / $Loop) * 100)
                        $Limit = $Limit + 1000
                    }
                }
                Write-Progress -Id 1 -activity "Running Resource Inventory Job" -Status "$Looper / $Loop of Inventory Jobs" -Completed
            }
        elseif(![string]::IsNullOrEmpty($TagKey) -and ![string]::IsNullOrEmpty($TagValue) -and ![string]::IsNullOrEmpty($SubscriptionID))
            {
                $Subscri = $SubscriptionID

                Write-Debug ('Extracting Resources from Subscription: '+$SubscriptionID+'. And from Tag: '+ $TagKey+ ':'+ $TagValue)
                $GraphQuery = "resources | where isnotempty(tags) | mvexpand tags | extend tagKey = tostring(bag_keys(tags)[0]) | extend tagValue = tostring(tags[tagKey]) | where tagKey == '$TagKey' and tagValue == '$TagValue' | where strlen(properties.definition.actions) < 123000 | summarize count()"
                $EnvSize = az graph query -q $GraphQuery  --output json --subscriptions $Subscri --only-show-errors | ConvertFrom-Json
                $EnvSizeNum = $EnvSize.data.'count_'

                if ($EnvSizeNum -ge 1) {
                    $Loop = $EnvSizeNum / 1000
                    $Loop = [math]::ceiling($Loop)
                    $Looper = 0
                    $Limit = 0

                    while ($Looper -lt $Loop) {
                        $GraphQuery = "resources | where isnotempty(tags) | mvexpand tags | extend tagKey = tostring(bag_keys(tags)[0]) | extend tagValue = tostring(tags[tagKey]) | where tagKey == '$TagKey' and tagValue == '$TagValue' | where strlen(properties.definition.actions) < 123000 | project id,name,type,tenantId,kind,location,resourceGroup,subscriptionId,managedBy,sku,plan,properties,identity,zones,extendedLocation$($GraphQueryTags) | order by id asc"
                        $Resource = (az graph query -q $GraphQuery --subscriptions $Subscri --skip $Limit --first 1000 --output json --only-show-errors).tolower() | ConvertFrom-Json

                        $Global:Resources += $Resource.data
                        Start-Sleep 2
                        $Looper ++
                        Write-Progress -Id 1 -activity "Running Resource Inventory Job" -Status "$Looper / $Loop of Inventory Jobs" -PercentComplete (($Looper / $Loop) * 100)
                        $Limit = $Limit + 1000
                    }
                }
                Write-Progress -Id 1 -activity "Running Resource Inventory Job" -Status "$Looper / $Loop of Inventory Jobs" -Completed
            } 
        elseif([string]::IsNullOrEmpty($ResourceGroup) -and ![string]::IsNullOrEmpty($SubscriptionID))
            {

                Write-Debug ('Extracting Resources from Subscription: '+$SubscriptionID+'.')
                $GraphQuery = "resources | where strlen(properties.definition.actions) < 123000 | summarize count()"
                $EnvSize = az graph query -q $GraphQuery  --output json --subscriptions $SubscriptionID --only-show-errors | ConvertFrom-Json
                $EnvSizeNum = $EnvSize.data.'count_'

                if ($EnvSizeNum -ge 1) {
                    $Loop = $EnvSizeNum / 1000
                    $Loop = [math]::ceiling($Loop)
                    $Looper = 0
                    $Limit = 0

                    while ($Looper -lt $Loop) {
                        $GraphQuery = "resources | where strlen(properties.definition.actions) < 123000 | project id,name,type,tenantId,kind,location,resourceGroup,subscriptionId,managedBy,sku,plan,properties,identity,zones,extendedLocation$($GraphQueryTags) | order by id asc"
                        $Resource = (az graph query -q $GraphQuery --subscriptions $SubscriptionID --skip $Limit --first 1000 --output json --only-show-errors).tolower() | ConvertFrom-Json

                        $Global:Resources += $Resource.data
                        Start-Sleep 2
                        $Looper ++
                        Write-Progress -Id 1 -activity "Running Resource Inventory Job" -Status "$Looper / $Loop of Inventory Jobs" -PercentComplete (($Looper / $Loop) * 100)
                        $Limit = $Limit + 1000
                    }
                }
                Write-Progress -Id 1 -activity "Running Resource Inventory Job" -Status "$Looper / $Loop of Inventory Jobs" -Completed
            } 
        else 
            {
                $GraphQueryExtension = ""
                if (![string]::IsNullOrEmpty($ManagementGroup)) {
                    $GraphQueryExtension = "| join kind=inner (resourcecontainers | where type == 'microsoft.resources/subscriptions' | mv-expand managementGroupParent = properties.managementGroupAncestorsChain | where managementGroupParent.name =~ '$ManagementGroup' | project subscriptionId, managanagementGroup = managementGroupParent.name) on subscriptionId"
                }
                $GraphQuery = "resources | where strlen(properties.definition.actions) < 123000 $GraphQueryExtension | summarize count()"
                
                #$EnvSize = az graph query -q  $GraphQuery --output json --subscriptions $SubscriptionID --only-show-errors | ConvertFrom-Json
                $EnvSize = az graph query -q  $GraphQuery --output json --only-show-errors | ConvertFrom-Json
                $EnvSizeNum = $EnvSize.data.'count_'

                if ($EnvSizeNum -ge 1) {
                    $Loop = $EnvSizeNum / 1000
                    $Loop = [math]::ceiling($Loop)
                    $Looper = 0
                    $Limit = 0

                    while ($Looper -lt $Loop) {
                        $GraphQuery = "resources | where strlen(properties.definition.actions) < 123000 $GraphQueryExtension | project id,name,type,tenantId,kind,location,resourceGroup,subscriptionId,managedBy,sku,plan,properties,identity,zones,extendedLocation$($GraphQueryTags) | order by id asc"
                        #$Resource = (az graph query -q $GraphQuery --skip $Limit --first 1000 --output json --subscriptions $SubscriptionID --only-show-errors).tolower() | ConvertFrom-Json
                        $Resource = (az graph query -q $GraphQuery --skip $Limit --first 1000 --output json --only-show-errors).tolower() | ConvertFrom-Json

                        $Global:Resources += $Resource.data
                        Start-Sleep 2
                        $Looper ++
                        Write-Progress -Id 1 -activity "Running Resource Inventory Job" -Status "$Looper / $Loop of Inventory Jobs" -PercentComplete (($Looper / $Loop) * 100)
                        $Limit = $Limit + 1000
                    }
                }
                Write-Progress -Id 1 -activity "Running Resource Inventory Job" -Status "$Looper / $Loop of Inventory Jobs" -Completed
            }

        <######################################################### RESOURCE CONTAINER ######################################################################>

            $GraphQueryExtension = ""
            if (![string]::IsNullOrEmpty($ManagementGroup)) {
                $GraphQueryExtension = "| mv-expand managementGroupParent = properties.managementGroupAncestorsChain | where managementGroupParent.name =~ '$ManagementGroup'"
            }
            $GraphQuery = "resourcecontainers $GraphQueryExtension | summarize count()"
            $EnvSize = az graph query -q  $GraphQuery --output json --only-show-errors | ConvertFrom-Json
            $EnvSizeNum = $EnvSize.data.'count_'

            if ($EnvSizeNum -ge 1) {
                $Loop = $EnvSizeNum / 1000
                $Loop = [math]::ceiling($Loop)
                $Looper = 0
                $Limit = 0

                while ($Looper -lt $Loop) {
                    $GraphQuery = "resourcecontainers $GraphQueryExtension | order by id asc"
                    $Container = (az graph query -q $GraphQuery --skip $Limit --first 1000 --output json --only-show-errors).tolower() | ConvertFrom-Json

                    $Global:ResourceContainers += $Container.data
                    Start-Sleep 2
                    $Looper ++
                    Write-Progress -Id 1 -activity "Running Subscription Inventory Job" -Status "$Looper / $Loop of Inventory Jobs" -PercentComplete (($Looper / $Loop) * 100)
                    $Limit = $Limit + 1000
                }
            }
            Write-Progress -Id 1 -activity "Running Subscription Inventory Job" -Status "$Looper / $Loop of Inventory Jobs" -Completed


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

        <######################################################### Policies ######################################################################>

            if (!($SkipPolicy.IsPresent)) {                

                $GraphQuery = "policyresources | where type == 'microsoft.authorization/policyassignments' | summarize count()"
    
                $PolSize = az graph query -q $GraphQuery -m $TenantID --output json --only-show-errors | ConvertFrom-Json
                $PolSizeNum = $PolSize.data.'count_'
    
                Write-Debug ('Policy: '+$PolSizeNum)
                Write-Progress -activity 'Azure Inventory' -Status "5% Complete." -PercentComplete 5 -CurrentOperation "Starting Policy extraction jobs.."
    
                if ($PolSizeNum -ge 1) {
                    $Loop = $PolSizeNum / 1000
                    $Loop = [math]::ceiling($Loop)
                    $Looper = 0
                    $Limit = 0
    
                    while ($Looper -lt $Loop) {
                        $Looper ++
                        Write-Progress -Id 1 -activity "Running Policy Inventory Job" -Status "$Looper / $Loop of Inventory Jobs" -PercentComplete (($Looper / $Loop) * 100)
                        $GraphQuery = "policyresources | where type == 'microsoft.authorization/policyassignments' | order by id asc"
    
                        $Policy = (az graph query -q $GraphQuery -m $TenantID --skip $Limit --first 1000 --output json --only-show-errors).tolower() | ConvertFrom-Json
    
                        $Global:Policies += $Policy.data
                        Start-Sleep 2
                        $Limit = $Limit + 1000
                    }
                    Write-Progress -Id 1 -activity "Running Policy Inventory Job" -Status "Completed" -Completed
                }
    
            }


        <######################################################### ADVISOR ######################################################################>

        $Global:ExtractionRuntime = Measure-Command -Expression {

        $Subscri = $Global:Subscriptions.id

        if (!($SkipAdvisory.IsPresent)) {

            Write-Debug ('Subscriptions To be Gather in Advisories: '+$Subscri.Count)
            
            $GraphQueryExtension = ""
            if (![string]::IsNullOrEmpty($ManagementGroup)) {
                $GraphQueryExtension = "| join kind=inner (resourcecontainers | where type == 'microsoft.resources/subscriptions' | mv-expand managementGroupParent = properties.managementGroupAncestorsChain | where managementGroupParent.name =~ '$ManagementGroup' | project subscriptionId, managanagementGroup = managementGroupParent.name) on subscriptionId"
            }
            if (![string]::IsNullOrEmpty($ResourceGroup)) {
                $GraphQueryExtension = "$GraphQueryExtension | where resourceGroup == '$ResourceGroup'"
            }
            $GraphQuery = "advisorresources $GraphQueryExtension | summarize count()"

            #$AdvSize = az graph query -q $GraphQuery --subscriptions $Subscri --output json --only-show-errors | ConvertFrom-Json
            $AdvSize = az graph query -q $GraphQuery --output json --only-show-errors | ConvertFrom-Json
            $AdvSizeNum = $AdvSize.data.'count_'

            Write-Debug ('Advisories: '+$AdvSizeNum)
            Write-Progress -activity 'Azure Inventory' -Status "5% Complete." -PercentComplete 5 -CurrentOperation "Starting Advisories extraction jobs.."

            if ($AdvSizeNum -ge 1) {
                $Loop = $AdvSizeNum / 1000
                $Loop = [math]::ceiling($Loop)
                $Looper = 0
                $Limit = 0

                while ($Looper -lt $Loop) {
                    $Looper ++
                    Write-Progress -Id 1 -activity "Running Advisory Inventory Job" -Status "$Looper / $Loop of Inventory Jobs" -PercentComplete (($Looper / $Loop) * 100)
                    $GraphQuery = "advisorresources $GraphQueryExtension | order by id asc"

                    #$Advisor = (az graph query -q $GraphQuery --subscriptions $Subscri --skip $Limit --first 1000 --output json --only-show-errors).tolower() | ConvertFrom-Json
                    $Advisor = (az graph query -q $GraphQuery --skip $Limit --first 1000 --output json --only-show-errors).tolower() | ConvertFrom-Json

                    $Global:Advisories += $Advisor.data
                    Start-Sleep 2
                    $Limit = $Limit + 1000
                }
                Write-Progress -Id 1 -activity "Running Advisory Inventory Job" -Status "Completed" -Completed
            }

            $Global:Advisories = $Global:Advisories | Where-Object {$_.subscriptionid -in $Subscri}
        }

        <######################################################### Security Center ######################################################################>

        if ($SecurityCenter.IsPresent) {
            Write-Progress -activity 'Azure Inventory' -Status "6% Complete." -PercentComplete 6 -CurrentOperation "Starting Security Advisories extraction jobs.."
            Write-Host " Azure Resource Inventory are collecting Security Center Advisories."
            Write-Host " Collecting Security Center Can increase considerably the execution time of Azure Resource Inventory and the size of final report "
            Write-Host " "

            $Subscri = $Global:Subscriptions.id

            Write-Debug ('Extracting total number of Security Advisories from Tenant')
            $GraphQueryExtension = ""
            if (![string]::IsNullOrEmpty($ManagementGroup)) {
                $GraphQueryExtension = "| join kind=inner (resourcecontainers | where type == 'microsoft.resources/subscriptions' | mv-expand managementGroupParent = properties.managementGroupAncestorsChain | where managementGroupParent.name =~ '$ManagementGroup' | project subscriptionId, managanagementGroup = managementGroupParent.name) on subscriptionId"
            }
            if (![string]::IsNullOrEmpty($ResourceGroup)) {
                $GraphQueryExtension = "$GraphQueryExtension | where resourceGroup == '$ResourceGroup'"
            }
            #$SecSize = az graph query -q  "securityresources | where properties['status']['code'] == 'Unhealthy' | summarize count()" --subscriptions $Subscri --output json --only-show-errors | ConvertFrom-Json
            $SecSize = az graph query -q  "securityresources $GraphQueryExtension | where properties['status']['code'] == 'Unhealthy' | summarize count()" --output json --only-show-errors | ConvertFrom-Json
            $SecSizeNum = $SecSize.data.'count_'            

            if ($SecSizeNum -ge 1) {
                $Loop = $SecSizeNum / 1000
                $Loop = [math]::ceiling($Loop)
                $Looper = 0
                $Limit = 0
                while ($Looper -lt $Loop) {
                    $Looper ++
                    Write-Progress -Id 1 -activity "Running Security Advisory Inventory Job" -Status "$Looper / $Loop of Inventory Jobs" -PercentComplete (($Looper / $Loop) * 100)
                    $GraphQuery = "securityresources $GraphQueryExtension | where properties['status']['code'] == 'Unhealthy' | order by id asc"
                
                    #$SecCenter = (az graph query -q $GraphQuery --subscriptions $Subscri --skip $Limit --first 1000 --output json --only-show-errors).tolower() | ConvertFrom-Json
                    $SecCenter = (az graph query -q $GraphQuery --skip $Limit --first 1000 --output json --only-show-errors).tolower() | ConvertFrom-Json

                    $Global:Security += $SecCenter.data
                    Start-Sleep 3
                    $Limit = $Limit + 1000
                }
                Write-Progress -Id 1 -activity "Running Security Advisory Inventory Job" -Status "Completed" -Completed
            }
        }
        else {
            Write-Host " "
            Write-Host " To include Security Center details in the report, use <-SecurityCenter> parameter. "
            Write-Host " "
        }

        Write-Progress -activity 'Azure Inventory' -PercentComplete 20

        Write-Progress -Id 1 -activity "Running Inventory Jobs" -Status "100% Complete." -Completed

        <######################################################### AVD ######################################################################>


        $Subscri = $Global:Subscriptions.id
        $GraphQueryExtension = ""
        if (![string]::IsNullOrEmpty($ManagementGroup)) {
            $GraphQueryExtension = "| join kind=inner (resourcecontainers | where type == 'microsoft.resources/subscriptions' | mv-expand managementGroupParent = properties.managementGroupAncestorsChain | where managementGroupParent.name =~ '$ManagementGroup' | project subscriptionId, managanagementGroup = managementGroupParent.name) on subscriptionId"
        }
        if (![string]::IsNullOrEmpty($ResourceGroup)) {
            $GraphQueryExtension = "$GraphQueryExtension | where resourceGroup == '$ResourceGroup'"
        }
        #$AVDSize = az graph query -q "desktopvirtualizationresources | summarize count()" --subscriptions $Subscri --output json --only-show-errors | ConvertFrom-Json
        $AVDSize = az graph query -q "desktopvirtualizationresources $GraphQueryExtension | summarize count()" --output json --only-show-errors | ConvertFrom-Json
        $AVDSizeNum = $AVDSize.data.'count_'

        if ($AVDSizeNum -ge 1) {
            $Loop = $AVDSizeNum / 1000
            $Loop = [math]::ceiling($Loop)
            $Looper = 0
            $Limit = 0

            while ($Looper -lt $Loop) {
                $GraphQuery = "desktopvirtualizationresources $GraphQueryExtension | project id,name,type,tenantId,kind,location,resourceGroup,subscriptionId,managedBy,sku,plan,properties,identity,zones,extendedLocation$($GraphQueryTags) | order by id asc"
                #$AVD = (az graph query -q $GraphQuery --subscriptions $Subscri --skip $Limit --first 1000 --output json --only-show-errors).tolower() | ConvertFrom-Json
                $AVD = (az graph query -q $GraphQuery --skip $Limit --first 1000 --output json --only-show-errors).tolower() | ConvertFrom-Json

                $Global:Resources += $AVD.data
                Start-Sleep 2
                $Looper ++
                $Limit = $Limit + 1000
            }
        }


        }
    }


    <#########################################################  Creating Excel File   ######################################################################>

    Function RunMain {

        $Global:ReportingRunTime = Measure-Command -Expression {

        #### Creating Excel file variable:
        $Global:File = ($DefaultPath + $Global:ReportName + "_Report_" + (get-date -Format "yyyy-MM-dd_HH_mm") + ".xlsx")
        #$Global:DFile = ($DefaultPath + $Global:ReportName + "_Diagram_" + (get-date -Format "yyyy-MM-dd_HH_mm") + ".vsdx")
        $Global:DDFile = ($DefaultPath + $Global:ReportName + "_Diagram_" + (get-date -Format "yyyy-MM-dd_HH_mm") + ".xml")
        Write-Debug ('Excel file:' + $File)

        #### Generic Conditional Text rules, Excel style specifications for the spreadsheets and tables:
        $Global:TableStyle = "Light19"
        Write-Debug ('Excel Table Style used: ' + $TableStyle)

        Write-Progress -activity 'Azure Inventory' -Status "21% Complete." -PercentComplete 21 -CurrentOperation "Starting to process extraction data.."


        <######################################################### IMPORT UNSUPPORTED VERSION LIST ######################################################################>

        Write-Debug ('Importing List of Unsupported Versions.')
        If ($RunOnline -eq $true) {
            Write-Debug ('Looking for the following file: '+$RawRepo + '/Extras/Support.json')
            $ModuSeq = (New-Object System.Net.WebClient).DownloadString($RawRepo + '/Extras/Support.json')
        }
        Else {
            if($PSScriptRoot -like '*\*')
                {
                    Write-Debug ('Looking for the following file: '+$PSScriptRoot + '\Extras\Support.json')
                    $ModuSeq0 = New-Object System.IO.StreamReader($PSScriptRoot + '\Extras\Support.json')
                }
            else
                {
                    Write-Debug ('Looking for the following file: '+$PSScriptRoot + '/Extras/Support.json')
                    $ModuSeq0 = New-Object System.IO.StreamReader($PSScriptRoot + '/Extras/Support.json')
                }
            $ModuSeq = $ModuSeq0.ReadToEnd()
            $ModuSeq0.Dispose()
        }

        $Unsupported = $ModuSeq | ConvertFrom-Json

        $DataActive = ('Azure Resource Inventory Reporting (' + ($resources.count) + ') Resources')

        <######################################################### DRAW.IO DIAGRAM JOB ######################################################################>

        Write-Debug ('Checking if Draw.io Diagram Job Should be Run.')
        if (!$SkipDiagram.IsPresent) {
            Write-Debug ('Starting Draw.io Diagram Processing Job.')
            Start-job -Name 'DrawDiagram' -ScriptBlock {

                If ($($args[8]) -eq $true) {
                    $ModuSeq = (New-Object System.Net.WebClient).DownloadString($($args[10]) + '/Extras/DrawIODiagram.ps1')
                }
                Else {
                    if($($args[0]) -like '*\*')
                        {
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
                    
                $ScriptBlock = [Scriptblock]::Create($ModuSeq)
                    
                $DrawRun = ([PowerShell]::Create()).AddScript($ScriptBlock).AddArgument($($args[1])).AddArgument($($args[2] | ConvertFrom-Json)).AddArgument($($args[3])).AddArgument($($args[4])).AddArgument($($args[5])).AddArgument($($args[6])).AddArgument($($args[7]))

                $DrawJob = $DrawRun.BeginInvoke()

                while ($DrawJob.IsCompleted -contains $false) { Start-Sleep -Milliseconds 100 }

                $DrawRun.EndInvoke($DrawJob)

                $DrawRun.Dispose()

            } -ArgumentList $PSScriptRoot, $Subscriptions, ($Resources | ConvertTo-Json -Depth 50), $Advisories, $DDFile, $DiagramCache, $FullEnv, $ResourceContainers ,$RunOnline, $Repo, $RawRepo   | Out-Null
        }

        <######################################################### VISIO DIAGRAM JOB ######################################################################>
        <#
        Write-Debug ('Checking if Visio Diagram Job Should be Run.')
        if ($Diagram.IsPresent) {
            Write-Debug ('Starting Visio Diagram Processing Job.')
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

        Write-Debug ('Checking If Should Run Security Center Job.')
        if ($SecurityCenter.IsPresent) {
            Write-Debug ('Starting Security Job.')
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

                $ScriptBlock = [Scriptblock]::Create($ModuSeq)

                $SecRun = ([PowerShell]::Create()).AddScript($ScriptBlock).AddArgument($($args[1])).AddArgument($($args[2])).AddArgument($($args[3]))

                $SecJob = $SecRun.BeginInvoke()

                while ($SecJob.IsCompleted -contains $false) { Start-Sleep -Milliseconds 100 }

                $SecResult = $SecRun.EndInvoke($SecJob)

                $SecRun.Dispose()

                $SecResult

            } -ArgumentList $PSScriptRoot, $Subscriptions , $Security, 'Processing' , $File, $RunOnline, $RawRepo | Out-Null
        }

        <######################################################### POLICY JOB ######################################################################>

        Write-Debug ('Checking If Should Run Policy Job.')
        if (!$SkipPolicy.IsPresent) {
            Write-Debug ('Starting Policy Processing Job.')
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

                $ScriptBlock = [Scriptblock]::Create($ModuSeq)

                $PolRun = ([PowerShell]::Create()).AddScript($ScriptBlock).AddArgument($($args[1])).AddArgument($($args[2])).AddArgument($($args[3])).AddArgument($($args[4]))

                $PolJob = $PolRun.BeginInvoke()

                while ($PolJob.IsCompleted -contains $false) { Start-Sleep -Milliseconds 100 }

                $PolResult = $PolRun.EndInvoke($PolJob)

                $PolRun.Dispose()

                $PolResult

            } -ArgumentList $PSScriptRoot, $Policies, 'Processing', $Subscriptions, $File, $RunOnline, $RawRepo | Out-Null
        }

        <######################################################### ADVISORY JOB ######################################################################>

        Write-Debug ('Checking If Should Run Advisory Job.')
        if (!$SkipAdvisory.IsPresent) {
            Write-Debug ('Starting Advisory Processing Job.')
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

                $ScriptBlock = [Scriptblock]::Create($ModuSeq)

                $AdvRun = ([PowerShell]::Create()).AddScript($ScriptBlock).AddArgument($($args[1])).AddArgument($($args[2])).AddArgument($($args[3]))

                $AdvJob = $AdvRun.BeginInvoke()

                while ($AdvJob.IsCompleted -contains $false) { Start-Sleep -Milliseconds 100 }

                $AdvResult = $AdvRun.EndInvoke($AdvJob)

                $AdvRun.Dispose()

                $AdvResult

            } -ArgumentList $PSScriptRoot, $Advisories, 'Processing' , $File, $RunOnline, $RawRepo | Out-Null
        }

        <######################################################### SUBSCRIPTIONS JOB ######################################################################>

        Write-Debug ('Starting Subscriptions job.')
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

            $ScriptBlock = [Scriptblock]::Create($ModuSeq)

            $SubRun = ([PowerShell]::Create()).AddScript($ScriptBlock).AddArgument($($args[1])).AddArgument($($args[2])).AddArgument($($args[3])).AddArgument($($args[4]))

            $SubJob = $SubRun.BeginInvoke()

            while ($SubJob.IsCompleted -contains $false) { Start-Sleep -Milliseconds 100 }

            $SubResult = $SubRun.EndInvoke($SubJob)

            $SubRun.Dispose()

            $SubResult

        } -ArgumentList $PSScriptRoot, $Subscriptions, $Resources, 'Processing' , $File, $RunOnline, $RawRepo | Out-Null

        <######################################################### RESOURCE GROUP JOB ######################################################################>

        Write-Debug ('Starting Processing Jobs.')

        $Loop = $resources.count / 1000
        $Loop = [math]::ceiling($Loop)
        $Looper = 0
        $Limit = 0                    

        while ($Looper -lt $Loop) {
            $Looper ++            

            $Resource = $resources | Select-Object -First 1000 -Skip $Limit

            Start-Job -Name ('ResourceJob_'+$Looper) -ScriptBlock {

                    $Job = @()

                    $Repo = $($args[10])
                    $RawRepo = $($args[11])

                    If ($($args[9]) -eq $true) {
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

                    foreach ($Module in $Modules) {
                        If ($($args[9]) -eq $true) {
                                $Modul = $Module.split('/')
                                $ModName = $Modul[2].Substring(0, $Modul[2].length - ".ps1".length)
                                $ModuSeq = (New-Object System.Net.WebClient).DownloadString($RawRepo + '/' + $Module)
                            } Else {
                                $ModName = $Module.Name.Substring(0, $Module.Name.length - ".ps1".length)
                                $ModuSeq0 = New-Object System.IO.StreamReader($Module.FullName)
                                $ModuSeq = $ModuSeq0.ReadToEnd()
                                $ModuSeq0.Dispose()
                        }

                        $ScriptBlock = [Scriptblock]::Create($ModuSeq)

                        New-Variable -Name ('ModRun' + $ModName)
                        New-Variable -Name ('ModJob' + $ModName)

                        Set-Variable -Name ('ModRun' + $ModName) -Value ([PowerShell]::Create()).AddScript($ScriptBlock).AddArgument($($args[1])).AddArgument($($args[2])).AddArgument($($args[3])).AddArgument($($args[4] | ConvertFrom-Json)).AddArgument($($args[5])).AddArgument($null).AddArgument($null).AddArgument($null).AddArgument($($args[12]))

                        Set-Variable -Name ('ModJob' + $ModName) -Value ((get-variable -name ('ModRun' + $ModName)).Value).BeginInvoke()

                        $job += (get-variable -name ('ModJob' + $ModName)).Value
                    }

                    while ($Job.Runspace.IsCompleted -contains $false) { Start-Sleep -Milliseconds 100 }

                    foreach ($Module in $Modules) {
                        If ($($args[9]) -eq $true) {
                                $Modul = $Module.split('/')
                                $ModName = $Modul[2].Substring(0, $Modul[2].length - ".ps1".length)
                            } Else {
                                $ModName = $Module.Name.Substring(0, $Module.Name.length - ".ps1".length)
                        }

                        New-Variable -Name ('ModValue' + $ModName)
                        Set-Variable -Name ('ModValue' + $ModName) -Value (((get-variable -name ('ModRun' + $ModName)).Value).EndInvoke((get-variable -name ('ModJob' + $ModName)).Value))
                    }

                    $Hashtable = New-Object System.Collections.Hashtable

                    foreach ($Module in $Modules) {
                        If ($($args[9]) -eq $true) {
                                $Modul = $Module.split('/')
                                $ModName = $Modul[2].Substring(0, $Modul[2].length - ".ps1".length)
                            } Else {
                                $ModName = $Module.Name.Substring(0, $Module.Name.length - ".ps1".length)
                        }
                        $Hashtable["$ModName"] = (get-variable -name ('ModValue' + $ModName)).Value
                    }

                $Hashtable
                } -ArgumentList $null, $PSScriptRoot, $Subscriptions, $InTag, ($Resource | ConvertTo-Json -Depth 50), 'Processing', $null, $null, $null, $RunOnline, $Repo, $RawRepo, $Unsupported | Out-Null                    
                $Limit = $Limit + 1000   
            }

        <############################################################## RESOURCES LOOP CREATION #############################################################>

        Write-Debug ('Starting Jobs Collector.')
        Write-Progress -activity $DataActive -Status "Processing Inventory" -PercentComplete 0
        $c = 0

        $JobNames = @()

        Foreach($Job in (Get-Job | Where-Object {$_.name -like 'ResourceJob_*'}))
            {
                $JobNames += $Job.Name 
            }                  

        while (get-job -Name $JobNames | Where-Object { $_.State -eq 'Running' }) {
            $jb = get-job -Name $JobNames
            $c = (((($jb.count - ($jb | Where-Object { $_.State -eq 'Running' }).Count)) / $jb.Count) * 100)
            Write-Debug ('Jobs Still Running: '+[string]($jb | Where-Object { $_.State -eq 'Running' }).count)
            $c = [math]::Round($c)
            Write-Progress -Id 1 -activity "Processing Resource Jobs" -Status "$c% Complete." -PercentComplete $c
            Start-Sleep -Seconds 2
        }
        Write-Progress -Id 1 -activity "Processing Resource Jobs" -Status "100% Complete." -Completed

        Write-Debug ('Jobs Compleated.')

        $AzSubs = Receive-Job -Name 'Subscriptions'

        $Global:SmaResources = @()

        Foreach ($Job in $JobNames)
            {
                $TempJob = Receive-Job -Name $Job
                Write-Debug ('Job '+ $Job +' Returned: ' + ($TempJob.values | Where-Object {$_ -ne $null}).Count + ' Resource Types.')
                $Global:SmaResources += $TempJob
            }        

            
        <############################################################## REPORTING ###################################################################>

        Write-Debug ('Starting Reporting Phase.')
        Write-Progress -activity $DataActive -Status "Processing Inventory" -PercentComplete 50

        If ($RunOnline -eq $true) {
            $OnlineRepo = Invoke-WebRequest -Uri $Repo
            $RepoContent = $OnlineRepo | ConvertFrom-Json
            $Modules = ($RepoContent.tree | Where-Object {$_.path -like '*.ps1' -and $_.path -notlike 'Extras/*' -and $_.path -ne 'AzureResourceInventory.ps1' -and $_.path -notlike 'Automation/*'}).path
        }
        Else {
            Write-Debug ('Running Offline, Gathering List Of Modules.')
            if($PSScriptRoot -like '*\*')
                {
                    $Modules = Get-ChildItem -Path ($PSScriptRoot + '\Modules\*.ps1') -Recurse
                }
            else
                {
                    $Modules = Get-ChildItem -Path ($PSScriptRoot + '/Modules/*.ps1') -Recurse
                }
        }

        Write-Debug ('Modules Found: ' + $Modules.Count)
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

                Write-Debug "Running Module: '$Module'"

            $ScriptBlock = [Scriptblock]::Create($ModuSeq)

            $ExcelRun = ([PowerShell]::Create()).AddScript($ScriptBlock).AddArgument($PSScriptRoot).AddArgument($null).AddArgument($InTag).AddArgument($null).AddArgument('Reporting').AddArgument($file).AddArgument($SmaResources).AddArgument($TableStyle).AddArgument($Unsupported)

            $ExcelJob = $ExcelRun.BeginInvoke()

            while ($ExcelJob.IsCompleted -contains $false) { Start-Sleep -Milliseconds 100 }

            $ExcelRun.EndInvoke($ExcelJob)

            $ExcelRun.Dispose()

            $ReportCounter ++

        }

        Write-Debug ('Resource Reporting Phase Done.')

        <################################################################### QUOTAS ###################################################################>

        if($QuotaUsage.IsPresent)
            {

                get-job -Name 'Quota Usage' | Wait-Job

                $Global:AzQuota = Receive-Job -Name 'Quota Usage'

                Write-Debug ('Generating Quota Usage sheet for: ' + $Global:AzQuota.count + ' Subscriptions/Regions.')

                Write-Progress -activity 'Azure Resource Inventory Quota Usage' -Status "50% Complete." -PercentComplete 50 -CurrentOperation "Building Quota Sheet"

                If ($RunOnline -eq $true) {
                    Write-Debug ('Looking for the following file: '+$RawRepo + '/Extras/QuotaUsage.ps1')
                    $ModuSeq = (New-Object System.Net.WebClient).DownloadString($RawRepo + '/Extras/QuotaUsage.ps1')
                }
                Else {
                    if($PSScriptRoot -like '*\*')
                        {
                            Write-Debug ('Looking for the following file: '+$PSScriptRoot + '\Extras\QuotaUsage.ps1')
                            $ModuSeq0 = New-Object System.IO.StreamReader($PSScriptRoot + '\Extras\QuotaUsage.ps1')
                        }
                    else
                        {
                            Write-Debug ('Looking for the following file: '+$PSScriptRoot + '/Extras/QuotaUsage.ps1')
                            $ModuSeq0 = New-Object System.IO.StreamReader($PSScriptRoot + '/Extras/QuotaUsage.ps1')
                        }
                    $ModuSeq = $ModuSeq0.ReadToEnd()
                    $ModuSeq0.Dispose()
                }

                $ScriptBlock = [Scriptblock]::Create($ModuSeq)

                $QuotaRun = ([PowerShell]::Create()).AddScript($ScriptBlock).AddArgument($File).AddArgument($Global:AzQuota).AddArgument($TableStyle)

                $QuotaJob = $QuotaRun.BeginInvoke()

                while ($QuotaJob.IsCompleted -contains $false) { Start-Sleep -Milliseconds 100 }

                $QuotaRun.EndInvoke($QuotaJob)

                $QuotaRun.Dispose()

                Write-Progress -activity 'Azure Resource Inventory Quota Usage' -Status "100% Complete." -Completed
            }


        <################################################ SECURITY CENTER #######################################################>
        #### Security Center worksheet is generated apart

        Write-Debug ('Checking if Should Generate Security Center Sheet.')
        if ($SecurityCenter.IsPresent) {
            Write-Debug ('Generating Security Center Sheet.')
            $Global:Secadvco = $Security.Count

            Write-Progress -activity $DataActive -Status "Building Security Center Report" -PercentComplete 0 -CurrentOperation "Considering $Secadvco Security Advisories"

            while (get-job -Name 'Security' | Where-Object { $_.State -eq 'Running' }) {
                Write-Progress -Id 1 -activity 'Processing Security Center Advisories' -Status "50% Complete." -PercentComplete 50
                Start-Sleep -Seconds 2
            }
            Write-Progress -Id 1 -activity 'Processing Security Center Advisories'  -Status "100% Complete." -Completed

            $Sec = Receive-Job -Name 'Security'

            If ($RunOnline -eq $true) {
                Write-Debug ('Looking for the following file: '+$RawRepo + '/Extras/SecurityCenter.ps1')
                $ModuSeq = (New-Object System.Net.WebClient).DownloadString($RawRepo + '/Extras/SecurityCenter.ps1')
            }
            Else {
                if($PSScriptRoot -like '*\*')
                    {
                        Write-Debug ('Looking for the following file: '+$PSScriptRoot + '\Extras\SecurityCenter.ps1')
                        $ModuSeq0 = New-Object System.IO.StreamReader($PSScriptRoot + '\Extras\SecurityCenter.ps1')
                    }
                else
                    {
                        Write-Debug ('Looking for the following file: '+$PSScriptRoot + '/Extras/SecurityCenter.ps1')
                        $ModuSeq0 = New-Object System.IO.StreamReader($PSScriptRoot + '/Extras/SecurityCenter.ps1')
                    }
                $ModuSeq = $ModuSeq0.ReadToEnd()
                $ModuSeq0.Dispose()
            }

            $ScriptBlock = [Scriptblock]::Create($ModuSeq)

            $SecExcelRun = ([PowerShell]::Create()).AddScript($ScriptBlock).AddArgument($null).AddArgument($null).AddArgument('Reporting').AddArgument($file).AddArgument($Sec).AddArgument($TableStyle)

            $SecExcelJob = $SecExcelRun.BeginInvoke()

            while ($SecExcelJob.IsCompleted -contains $false) { Start-Sleep -Milliseconds 100 }

            $SecExcelRun.EndInvoke($SecExcelJob)

            $SecExcelRun.Dispose()
        }


        <################################################ POLICY #######################################################>
        #### Policy worksheet is generated apart from the resources
        Write-Debug ('Checking if Should Generate Policy Sheet.')
        if (!$SkipPolicy.IsPresent) {
            Write-Debug ('Generating Policy Sheet.')
            $Global:polco = $Policies.count

            Write-Progress -activity $DataActive -Status "Building Policy Report" -PercentComplete 0 -CurrentOperation "Considering $polco Policies"

            while (get-job -Name 'Policy' | Where-Object { $_.State -eq 'Running' }) {
                Write-Progress -Id 1 -activity 'Processing Policies' -Status "50% Complete." -PercentComplete 50
                Write-Debug ('Policy Job is: '+(get-job -Name 'Policy').State)
                Start-Sleep -Seconds 2
            }
            Write-Progress -Id 1 -activity 'Processing Policies'  -Status "100% Complete." -Completed

            $Global:Pol = Receive-Job -Name 'Policy'

            If ($RunOnline -eq $true) {
                Write-Debug ('Looking for the following file: '+$RawRepo + '/Extras/Policy.ps1')
                $ModuSeq = (New-Object System.Net.WebClient).DownloadString($RawRepo + '/Extras/Policy.ps1')
            }
            Else {
                if($PSScriptRoot -like '*\*')
                    {
                        Write-Debug ('Looking for the following file: '+$PSScriptRoot + '\Extras\Policy.ps1')
                        $ModuSeq0 = New-Object System.IO.StreamReader($PSScriptRoot + '\Extras\Policy.ps1')
                    }
                else
                    {
                        Write-Debug ('Looking for the following file: '+$PSScriptRoot + '/Extras/Policy.ps1')
                        $ModuSeq0 = New-Object System.IO.StreamReader($PSScriptRoot + '/Extras/Policy.ps1')
                    }
                $ModuSeq = $ModuSeq0.ReadToEnd()
                $ModuSeq0.Dispose()
            }

            $ScriptBlock = [Scriptblock]::Create($ModuSeq)

            $PolExcelRun = ([PowerShell]::Create()).AddScript($ScriptBlock).AddArgument($null).AddArgument('Reporting').AddArgument($null).AddArgument($file).AddArgument($Pol).AddArgument($TableStyle)

            $PolExcelJob = $PolExcelRun.BeginInvoke()

            while ($PolExcelJob.IsCompleted -contains $false) { Start-Sleep -Milliseconds 100 }

            $PolExcelRun.EndInvoke($PolExcelJob)

            $PolExcelRun.Dispose()
        }


        <################################################ ADVISOR #######################################################>
        #### Advisor worksheet is generated apart from the resources
        Write-Debug ('Checking if Should Generate Advisory Sheet.')
        if (!$SkipAdvisory.IsPresent) {
            Write-Debug ('Generating Advisor Sheet.')
            $Global:advco = $Advisories.count

            Write-Progress -activity $DataActive -Status "Building Advisories Report" -PercentComplete 0 -CurrentOperation "Considering $advco Advisories"

            while (get-job -Name 'Advisory' | Where-Object { $_.State -eq 'Running' }) {
                Write-Progress -Id 1 -activity 'Processing Advisories' -Status "50% Complete." -PercentComplete 50
                Write-Debug ('Advisory Job is: '+(get-job -Name 'Advisory').State)
                Start-Sleep -Seconds 2
            }
            Write-Progress -Id 1 -activity 'Processing Advisories'  -Status "100% Complete." -Completed

            $Adv = Receive-Job -Name 'Advisory'

            If ($RunOnline -eq $true) {
                Write-Debug ('Looking for the following file: '+$RawRepo + '/Extras/Advisory.ps1')
                $ModuSeq = (New-Object System.Net.WebClient).DownloadString($RawRepo + '/Extras/Advisory.ps1')
            }
            Else {
                if($PSScriptRoot -like '*\*')
                    {
                        Write-Debug ('Looking for the following file: '+$PSScriptRoot + '\Extras\Advisory.ps1')
                        $ModuSeq0 = New-Object System.IO.StreamReader($PSScriptRoot + '\Extras\Advisory.ps1')
                    }
                else
                    {
                        Write-Debug ('Looking for the following file: '+$PSScriptRoot + '/Extras/Advisory.ps1')
                        $ModuSeq0 = New-Object System.IO.StreamReader($PSScriptRoot + '/Extras/Advisory.ps1')
                    }
                $ModuSeq = $ModuSeq0.ReadToEnd()
                $ModuSeq0.Dispose()
            }

            $ScriptBlock = [Scriptblock]::Create($ModuSeq)

            $AdvExcelRun = ([PowerShell]::Create()).AddScript($ScriptBlock).AddArgument($null).AddArgument('Reporting').AddArgument($file).AddArgument($Adv).AddArgument($TableStyle)

            $AdvExcelJob = $AdvExcelRun.BeginInvoke()

            while ($AdvExcelJob.IsCompleted -contains $false) { Start-Sleep -Milliseconds 100 }

            $AdvExcelRun.EndInvoke($AdvExcelJob)

            $AdvExcelRun.Dispose()
        }

        <################################################################### SUBSCRIPTIONS ###################################################################>

        Write-Debug ('Generating Subscription sheet for: ' + $Subscriptions.count + ' Subscriptions.')

        Write-Progress -activity 'Azure Resource Inventory Subscriptions' -Status "50% Complete." -PercentComplete 50 -CurrentOperation "Building Subscriptions Sheet"

        If ($RunOnline -eq $true) {
            Write-Debug ('Looking for the following file: '+$RawRepo + '/Extras/Subscriptions.ps1')
            $ModuSeq = (New-Object System.Net.WebClient).DownloadString($RawRepo + '/Extras/Subscriptions.ps1')
        }
        Else {
            if($PSScriptRoot -like '*\*')
                {
                    Write-Debug ('Looking for the following file: '+$PSScriptRoot + '\Extras\Subscriptions.ps1')
                    $ModuSeq0 = New-Object System.IO.StreamReader($PSScriptRoot + '\Extras\Subscriptions.ps1')
                }
            else
                {
                    Write-Debug ('Looking for the following file: '+$PSScriptRoot + '/Extras/Subscriptions.ps1')
                    $ModuSeq0 = New-Object System.IO.StreamReader($PSScriptRoot + '/Extras/Subscriptions.ps1')
                }
            $ModuSeq = $ModuSeq0.ReadToEnd()
            $ModuSeq0.Dispose()
        }

        $ScriptBlock = [Scriptblock]::Create($ModuSeq)

        $SubsRun = ([PowerShell]::Create()).AddScript($ScriptBlock).AddArgument($null).AddArgument($null).AddArgument('Reporting').AddArgument($file).AddArgument($AzSubs).AddArgument($TableStyle)

        $SubsJob = $SubsRun.BeginInvoke()

        while ($SubsJob.IsCompleted -contains $false) { Start-Sleep -Milliseconds 100 }

        $SubsRun.EndInvoke($SubsJob)

        $SubsRun.Dispose()

        Write-Progress -activity 'Azure Resource Inventory Subscriptions' -Status "100% Complete." -Completed

        <################################################################### CHARTS ###################################################################>

        Write-Debug ('Generating Overview sheet (Charts).')

        Write-Progress -activity 'Azure Resource Inventory Reporting Charts' -Status "10% Complete." -PercentComplete 10 -CurrentOperation "Starting Excel Chart's Thread."

        If ($RunOnline -eq $true) {
            Write-Debug ('Looking for the following file: '+$RawRepo + '/Extras/Charts.ps1')
            $ModuSeq = (New-Object System.Net.WebClient).DownloadString($RawRepo + '/Extras/Charts.ps1')
        }
        Else {
            if($PSScriptRoot -like '*\*')
                {
                    Write-Debug ('Looking for the following file: '+$PSScriptRoot + '\Extras\Charts.ps1')
                    $ModuSeq0 = New-Object System.IO.StreamReader($PSScriptRoot + '\Extras\Charts.ps1')
                }
            else
                {
                    Write-Debug ('Looking for the following file: '+$PSScriptRoot + '/Extras/Charts.ps1')
                    $ModuSeq0 = New-Object System.IO.StreamReader($PSScriptRoot + '/Extras/Charts.ps1')
                }
            $ModuSeq = $ModuSeq0.ReadToEnd()
            $ModuSeq0.Dispose()
        }

    }

        $ScriptBlock = [Scriptblock]::Create($ModuSeq)

        Write-Progress -activity 'Azure Resource Inventory Reporting Charts' -Status "15% Complete." -PercentComplete 15 -CurrentOperation "Invoking Excel Chart's Thread."

        $ChartsRun = ([PowerShell]::Create()).AddScript($ScriptBlock).AddArgument($file).AddArgument($TableStyle).AddArgument($Global:PlatOS).AddArgument($Global:Subscriptions).AddArgument($Global:Resources.Count).AddArgument($ExtractionRunTime).AddArgument($ReportingRunTime).AddArgument($RunLite)

        $ChartsJob = $ChartsRun.BeginInvoke()

        Write-Progress -activity 'Azure Resource Inventory Reporting Charts' -Status "30% Complete." -PercentComplete 30 -CurrentOperation "Waiting Excel Chart's Thread."

        while ($ChartsJob.IsCompleted -contains $false) { Start-Sleep -Milliseconds 100 }

        $ChartsRun.EndInvoke($ChartsJob)

        $ChartsRun.Dispose()

        Write-Debug ('Finished Charts Phase.')

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
write-host $Resources.count -ForegroundColor Cyan
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

