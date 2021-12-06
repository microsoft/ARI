##########################################################################################
#                                                                                        #
#                * Azure Resource Inventory ( ARI ) Report Generator *                   #
#                                                                                        #
#       Version: 2.1.10                                                                  #
#                                                                                        #
#       Date: 12/03/2021                                                                 #
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
    AUTHORS: Claudio Merola and Renato Gregio - Customer Engineer - Customer Success Unit | Azure Infrastucture/Automation/Devops/Governance | Microsoft

.LINK
    https://github.com/azureinventory
    Please note that while being developed by a Microsoft employee, Azure inventory Scripts is not a Microsoft service or product. Azure Inventory Scripts are a personal driven project, there are none implicit or explicit obligations related to this project, it is provided 'as is' with no warranties and confer no rights.
#>

param ($TenantID, [switch]$SecurityCenter, $SubscriptionID, $Appid, $Secret, $ResourceGroup, [switch]$SkipAdvisory, [switch]$IncludeTags, [switch]$QuotaUsage, [switch]$Online, [switch]$Diagram , [switch]$Debug, [switch]$Help, [switch]$DeviceLogin)

    if ($Debug.IsPresent) {$DebugPreference = 'Continue'}

    if ($Debug.IsPresent) {$ErrorActionPreference = "Continue" }Else {$ErrorActionPreference = "silentlycontinue" }

    Write-Debug ('Debbuging Mode: On. ErrorActionPreference was set to "Continue", every error will be presented.')

    if ($IncludeTags.IsPresent) { $Global:InTag = $true } else { $Global:InTag = $false }

    $Global:SRuntime = Measure-Command -Expression {

    <#########################################################          Help          ######################################################################>

    Function usageMode() {
        Write-Host ""
        Write-Host "Parameters"
        Write-Host ""
        Write-Host " -TenantID <ID>        :  Specifies the Tenant to be inventoried. "
        Write-Host " -SubscriptionID <ID>  :  Specifies one unique Subscription to be inventoried. "
        Write-Host " -ResourceGroup <NAME> :  Specifies one unique Resource Group to be inventoried, This parameter requires the -SubscriptionID to work. "
        Write-Host " -SkipAdvisory         :  Do not collect Azure Advisory. "
        Write-Host " -SecurityCenter       :  Include Security Center Data. "
        Write-Host " -IncludeTags          :  Include Resource Tags. "
        Write-Host " -Diagram              :  Create a Visio Diagram. "
        Write-Host " -Online               :  Use Online Modules. "
        Write-Host " -Debug                :  Run in a Debug mode. "
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
        Write-Host "Creating Visio Diagram :"
        Write-Host "If you Want to create a Visio Diagram you need to use <-Diagram> parameter."
        Write-Host "It's a pre-requisite to run in a Windows with Microsoft Visio Installed"
        Write-Host " To include Security Center details in the report, use <-SecurityCenter> parameter. "
        Write-Host "e.g. />./AzureResourceInventory.ps1 -TenantID <Azure Tenant ID> -Diagram"
        Write-Host ""
        Write-Host "Using the latest modules :"
        Write-Host " You can use the latest modules. For this use <-Online> parameter."
        Write-Host "It's a pre-requisite to have internet access for ARI GitHub repo"
        Write-Host "e.g. />./AzureResourceInventory.ps1 -TenantID <Azure Tenant ID> -Online"
        Write-Host ""
        Write-Host "Running in Debug Mode :"
        Write-Host "To run in a Debug Mode use <-Debug> parameter."
        Write-Host ".e.g. />/AzureResourceInventory.ps1 -TenantID <Azure Tenant ID> -Debug"
        Write-Host ""
    }

    Function Variables {
        Write-Debug ('Cleaning default variables')
        $Global:Resources = @()
        $Global:Advisories = @()
        $Global:Security = @()
        $Global:Subscriptions = ''

        if ($Online.IsPresent) { $Global:RunOnline = $true }else { $Global:RunOnline = $false }

        $Global:Repo = 'https://github.com/azureinventory/ARI/tree/main/Modules'
        $Global:RawRepo = 'https://raw.githubusercontent.com/azureinventory/ARI/main'

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
                $Global:DefaultPath = "$HOME/AzureResourceInventory/"
                $Global:Subscriptions = az account list --output json --only-show-errors | ConvertFrom-Json
            }
            else
            {
                if ($PSVersionTable.Platform -eq 'Unix') {
                    write-host "PowerShell Unix Identified."
                    $Global:PlatOS = 'PowerShell Unix'
                    write-host ""
                    $Global:DefaultPath = "$HOME/AzureResourceInventory/"
                    LoginSession
                }
                else {
                    write-host "PowerShell Desktop Identified."
                    $Global:PlatOS = 'PowerShell Desktop'
                    write-host ""
                    $Global:DefaultPath = "C:\AzureResourceInventory\"
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
            Write-Debug "Tags will be excluded"
            $GraphQueryTags = ""
        }

        <###################################################### Subscriptions ######################################################################>

        Write-Progress -activity 'Azure Inventory' -Status "1% Complete." -PercentComplete 2 -CurrentOperation 'Discovering Subscriptions..'

        $SubCount = $Subscriptions.count

        Write-Debug ('Number of Subscriptions Found: ' + $SubCount)
        Write-Progress -activity 'Azure Inventory' -Status "3% Complete." -PercentComplete 3 -CurrentOperation "$SubCount Subscriptions found.."

        Write-Debug ('Checking report folder: ' + $DefaultPath )
        if ((Test-Path -Path $DefaultPath -PathType Container) -eq $false) {
            New-Item -Type Directory -Force -Path $DefaultPath | Out-Null
        }

        <######################################################## INVENTORY LOOPs #######################################################################>

        Write-Progress -activity 'Azure Inventory' -Status "4% Complete." -PercentComplete 4 -CurrentOperation "Starting Resources extraction jobs.."

        <######################################################### ADVISOR ######################################################################>

        $Global:ExtractionRuntime = Measure-Command -Expression {

        $Global:Subscri = $Global:Subscriptions.id

        if (!($SkipAdvisory.IsPresent)) {

            Write-Debug ('Subscriptions To be Gather in Advisories: '+$Subscri.Count)
                if ([string]::IsNullOrEmpty($ResourceGroup)) {
                    Write-Debug ('Resource Group name is not present, extracting advisories for all Resource Groups')
                    $GraphQuery = "advisorresources | summarize count()"
                } else {
                    $GraphQuery = "advisorresources | where resourceGroup == '$ResourceGroup' | summarize count()"
                }
                $AdvSize = az graph query -q $GraphQuery --subscriptions $Subscri --output json --only-show-errors | ConvertFrom-Json
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
                        if ([string]::IsNullOrEmpty($ResourceGroup)) {
                            $GraphQuery = "advisorresources | order by id asc"
                        } else {
                            $GraphQuery = "advisorresources | where resourceGroup == '$ResourceGroup' | order by id asc"
                                }
                        
                    $Advisor = (az graph query -q $GraphQuery --subscriptions $Subscri --skip $Limit --first 1000 --output json --only-show-errors).tolower() | ConvertFrom-Json

                    $Global:Advisories += $Advisor.data
                    Start-Sleep 2
                    $Limit = $Limit + 1000
                }
                Write-Progress -Id 1 -activity "Running Advisory Inventory Job" -Status "Completed" -Completed
            }
        }

        <######################################################### Security Center ######################################################################>

        if ($SecurityCenter.IsPresent) {
            Write-Progress -activity 'Azure Inventory' -Status "6% Complete." -PercentComplete 6 -CurrentOperation "Starting Security Advisories extraction jobs.."
            Write-Host " Azure Resource Inventory are collecting Security Center Advisories."
            Write-Host " Collecting Security Center Can increase considerably the execution time of Azure Resource Inventory and the size of final report "
            Write-Host " "

            Write-Debug ('Extracting total number of Security Advisories from Tenant')
            $SecSize = az graph query -q  "securityresources | where properties['status']['code'] == 'Unhealthy' | summarize count()" --subscriptions $Subscri --output json --only-show-errors | ConvertFrom-Json
            $SecSizeNum = $SecSize.data.'count_'


            if ($SecSizeNum -ge 1) {
                $Loop = $SecSizeNum / 1000
                $Loop = [math]::ceiling($Loop)
                $Looper = 0
                $Limit = 0
                while ($Looper -lt $Loop) {
                    $Looper ++
                    Write-Progress -Id 1 -activity "Running Security Advisory Inventory Job" -Status "$Looper / $Loop of Inventory Jobs" -PercentComplete (($Looper / $Loop) * 100)
                        $GraphQuery = "securityresources | where properties['status']['code'] == 'Unhealthy' | order by id asc"
                    
                            $SecCenter = (az graph query -q $GraphQuery --subscriptions $Subscri --skip $Limit --first 1000 --output json --only-show-errors).tolower() | ConvertFrom-Json

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
            }
        elseif([string]::IsNullOrEmpty($ResourceGroup) -and ![string]::IsNullOrEmpty($SubscriptionID))
            {
                Write-Debug ('Extracting Resources from Subscription: '+$SubscriptionID+'.')
                $GraphQuery = "resources | where strlen(properties.definition.actions) < 123000 | summarize count()"
                $EnvSize = az graph query -q $GraphQuery  --output json --subscriptions $Subscri --only-show-errors | ConvertFrom-Json
                $EnvSizeNum = $EnvSize.data.'count_'

                if ($EnvSizeNum -ge 1) {
                    $Loop = $EnvSizeNum / 1000
                    $Loop = [math]::ceiling($Loop)
                    $Looper = 0
                    $Limit = 0

                    while ($Looper -lt $Loop) {
                        $GraphQuery = "resources | where strlen(properties.definition.actions) < 123000 | project id,name,type,tenantId,kind,location,resourceGroup,subscriptionId,managedBy,sku,plan,properties,identity,zones,extendedLocation$($GraphQueryTags) | order by id asc"
                        $Resource = (az graph query -q $GraphQuery --subscriptions $Subscri --skip $Limit --first 1000 --output json --only-show-errors).tolower() | ConvertFrom-Json

                        $Global:Resources += $Resource.data
                        Start-Sleep 2
                        $Looper ++
                        Write-Progress -Id 1 -activity "Running Resource Inventory Job" -Status "$Looper / $Loop of Inventory Jobs" -PercentComplete (($Looper / $Loop) * 100)
                        $Limit = $Limit + 1000
                    }
                }
            } else {
                $GraphQuery = "resources | where strlen(properties.definition.actions) < 123000 | summarize count()"
                $EnvSize = az graph query -q  $GraphQuery  --subscriptions $Subscri --output json --only-show-errors | ConvertFrom-Json
                $EnvSizeNum = $EnvSize.data.'count_'

                if ($EnvSizeNum -ge 1) {
                    $Loop = $EnvSizeNum / 1000
                    $Loop = [math]::ceiling($Loop)
                    $Looper = 0
                    $Limit = 0

                    while ($Looper -lt $Loop) {
                        $GraphQuery = "resources | where strlen(properties.definition.actions) < 123000 | project id,name,type,tenantId,kind,location,resourceGroup,subscriptionId,managedBy,sku,plan,properties,identity,zones,extendedLocation$($GraphQueryTags) | order by id asc"
                        $Resource = (az graph query -q $GraphQuery --subscriptions $Subscri --skip $Limit --first 1000 --output json --only-show-errors).tolower() | ConvertFrom-Json

                        $Global:Resources += $Resource.data
                        Start-Sleep 2
                        $Looper ++
                        Write-Progress -Id 1 -activity "Running Resource Inventory Job" -Status "$Looper / $Loop of Inventory Jobs" -PercentComplete (($Looper / $Loop) * 100)
                        $Limit = $Limit + 1000
                    }
                }
                Write-Progress -Id 1 -activity "Running Resource Inventory Job" -Status "$Looper / $Loop of Inventory Jobs" -PercentComplete (($Looper / $Loop) * 100)
            }

            #AVD Details

            $AVDSize = az graph query -q "desktopvirtualizationresources | summarize count()" --subscriptions $Subscri --output json --only-show-errors | ConvertFrom-Json
                $AVDSizeNum = $AVDSize.data.'count_'

                if ($AVDSizeNum -ge 1) {
                    $Loop = $AVDSizeNum / 1000
                    $Loop = [math]::ceiling($Loop)
                    $Looper = 0
                    $Limit = 0

                    while ($Looper -lt $Loop) {
                        $GraphQuery = "desktopvirtualizationresources | project id,name,type,tenantId,kind,location,resourceGroup,subscriptionId,managedBy,sku,plan,properties,identity,zones,extendedLocation$($GraphQueryTags) | order by id asc"
                        $AVD = (az graph query -q $GraphQuery --subscriptions $Subscri --skip $Limit --first 1000 --output json --only-show-errors).tolower() | ConvertFrom-Json

                        $Global:Resources += $AVD.data
                        Start-Sleep 2
                        $Looper ++
                        $Limit = $Limit + 1000
                    }
                }


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

        }
    }

    <######################################################### END Extractor Function ######################################################################>

    <#########################################################  Creating Excel File   ######################################################################>

    Function RunMain {

        $Global:ReportingRunTime = Measure-Command -Expression {

        #### Creating Excel file variable:
        $Global:File = ($DefaultPath + "AzureResourceInventory_Report_" + (get-date -Format "yyyy-MM-dd_HH_mm") + ".xlsx")
        $Global:DFile = ($DefaultPath + "AzureResourceInventory_Diagram_" + (get-date -Format "yyyy-MM-dd_HH_mm") + ".vsdx")
        $Global:DDFile = ($DefaultPath + "AzureResourceInventory_Diagram_" + (get-date -Format "yyyy-MM-dd_HH_mm") + ".xml")
        Write-Debug ('Excel file:' + $File)

        #### Generic Conditional Text rules, Excel style specifications for the spreadsheets and tables:
        $Global:TableStyle = "Light20"
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

        <######################################################### DIAGRAM JOB ######################################################################>
                
        Write-Debug ('Checking if Draw.io Diagram Job Should be Run.')
        if ($Diagram.IsPresent) {
            Write-Debug ('Starting Draw.io Diagram Processing Job.')
            Start-job -Name 'DrawDiagram' -ScriptBlock {

                If ($($args[5]) -eq $true) {
                    $ModuSeq = (New-Object System.Net.WebClient).DownloadString($($args[7]) + '/Extras/DrawIODiagram.ps1')
                }
                Else {
                    $ModuSeq0 = New-Object System.IO.StreamReader($($args[0]) + '\Extras\DrawIODiagram.ps1')
                    $ModuSeq = $ModuSeq0.ReadToEnd()
                    $ModuSeq0.Dispose()  
                }                  
                    
                $ScriptBlock = [Scriptblock]::Create($ModuSeq)
                    
                $DrawRun = ([PowerShell]::Create()).AddScript($ScriptBlock).AddArgument($($args[1])).AddArgument($($args[2])).AddArgument($($args[3])).AddArgument($($args[4]))

                $DrawJob = $DrawRun.BeginInvoke()

                while ($DrawJob.IsCompleted -contains $false) {}

                $DrawRun.EndInvoke($DrawJob)

                $DrawRun.Dispose()

            } -ArgumentList $PSScriptRoot, $Subscriptions, $Resources, $Advisories, $DDFile, $RunOnline, $Repo, $RawRepo   | Out-Null
        }
         <######################################################### DIAGRAM JOB ######################################################################>
        
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

                while ($SecJob.IsCompleted -contains $false) {}

                $SecResult = $SecRun.EndInvoke($SecJob)

                $SecRun.Dispose()

                $SecResult

            } -ArgumentList $PSScriptRoot, $Subscriptions , $Security, 'Processing' , $File, $RunOnline, $RawRepo | Out-Null
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

                while ($AdvJob.IsCompleted -contains $false) {}

                $AdvResult = $AdvRun.EndInvoke($AdvJob)

                $AdvRun.Dispose()

                $AdvResult

            } -ArgumentList $PSScriptRoot, $Advisories, 'Processing' , $File, $RunOnline, $RawRepo | Out-Null
        }

        <######################################################### SUBSCRIPTIONS JOB ######################################################################>

        Write-Debug ('Starting Subscriptions job.')
        Start-Job -Name 'Subscriptions' -ScriptBlock {

            If ($($args[4]) -eq $true) {
                $ModuSeq = (New-Object System.Net.WebClient).DownloadString($($args[5]) + '/Extras/Subscriptions.ps1')
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

            while ($SubJob.IsCompleted -contains $false) {}

            $SubResult = $SubRun.EndInvoke($SubJob)

            $SubRun.Dispose()

            $SubResult

        } -ArgumentList $PSScriptRoot, $Subscriptions, $Resources, 'Processing' , $File, $RunOnline, $RawRepo | Out-Null

        <######################################################### COMPUTE RESOURCE GROUP JOB ######################################################################>

        Write-Debug ('Starting Compute Processing Job.')
        Start-job -Name 'Compute' -ScriptBlock {

            If ($($args[8]) -eq $true) {
                $OnlineRepo = Invoke-WebRequest -Uri ($($args[9]) + '/Compute')
                $Modules = $OnlineRepo.Links | Where-Object { $_.href -like '*.ps1' }
                $Modules = $Modules.href
            }
            Else {
                if($($args[0]) -like '*\*')
                    {
                        $Modules = Get-ChildItem -Path ($($args[0]) + '\Modules\Compute\*.ps1') -Recurse
                    }
                else
                    {
                        $Modules = Get-ChildItem -Path ($($args[0]) + '/Modules/Compute/*.ps1') -Recurse
                    }
            }
            $job = @()

            foreach ($Module in $Modules) {
                If ($($args[8]) -eq $true) {
                    $Modul = $Module.split('/')
                        $ModName = $Modul[7].Substring(0, $Modul[7].length - ".ps1".length)
                    $ModuSeq = (New-Object System.Net.WebClient).DownloadString($($args[10]) + '/Modules/' + $Modul[6] + '/' + $Modul[7])
                    } Else {
                        $ModName = $Module.Name.Substring(0, $Module.Name.length - ".ps1".length)
                    $ModuSeq0 = New-Object System.IO.StreamReader($Module.FullName)
                    $ModuSeq = $ModuSeq0.ReadToEnd()
                    $ModuSeq0.Dispose()
                }


                $ScriptBlock = [Scriptblock]::Create($ModuSeq)

                New-Variable -Name ('ModRun' + $ModName)
                New-Variable -Name ('ModJob' + $ModName)

                Set-Variable -Name ('ModRun' + $ModName) -Value ([PowerShell]::Create()).AddScript($ScriptBlock).AddArgument($($args[0])).AddArgument($($args[1])).AddArgument($($args[2])).AddArgument($($args[3])).AddArgument($($args[4]))

                Set-Variable -Name ('ModJob' + $ModName) -Value ((get-variable -name ('ModRun' + $ModName)).Value).BeginInvoke()

                $job += (get-variable -name ('ModJob' + $ModName)).Value
            }

            while ($Job.Runspace.IsCompleted -contains $false) {}

            foreach ($Module in $Modules) {
                If ($($args[8]) -eq $true) {
                    $Modul = $Module.split('/')
                        $ModName = $Modul[7].Substring(0, $Modul[7].length - ".ps1".length)
                    } Else {
                        $ModName = $Module.Name.Substring(0, $Module.Name.length - ".ps1".length)
                }

                New-Variable -Name ('ModValue' + $ModName)
                Set-Variable -Name ('ModValue' + $ModName) -Value (((get-variable -name ('ModRun' + $ModName)).Value).EndInvoke((get-variable -name ('ModJob' + $ModName)).Value))

            }

            $Hashtable = New-Object System.Collections.Hashtable

            foreach ($Module in $Modules) {
                If ($($args[8]) -eq $true) {
                    $Modul = $Module.split('/')
                        $ModName = $Modul[7].Substring(0, $Modul[7].length - ".ps1".length)
                    } Else {
                        $ModName = $Module.Name.Substring(0, $Module.Name.length - ".ps1".length)
                }
                $Hashtable["$ModName"] = (get-variable -name ('ModValue' + $ModName)).Value
            }

            $Hashtable

        } -ArgumentList $PSScriptRoot, $Subscriptions, $InTag, $Resources, 'Processing' , $null, $null, $null, $RunOnline, $Repo, $RawRepo   | Out-Null

        <######################################################### NETWORK RESOURCE GROUP JOB ######################################################################>

        Write-Debug ('Starting Networking Processing Job.')
        Start-job -Name 'Networking' -ScriptBlock {

            If ($($args[8]) -eq $true) {
                $OnlineRepo = Invoke-WebRequest -Uri ($($args[9]) + '/Networking')
                $Modules = $OnlineRepo.Links | Where-Object { $_.href -like '*.ps1' }
                $Modules = $Modules.href
            }
            Else {
                if($($args[0]) -like '*\*')
                    {
                        $Modules = Get-ChildItem -Path ($($args[0]) + '\Modules\Networking\*.ps1') -Recurse
                    }
                else
                    {
                        $Modules = Get-ChildItem -Path ($($args[0]) + '/Modules/Networking/*.ps1') -Recurse
                    }
            }
            $job = @()

            foreach ($Module in $Modules) {
                If ($($args[8]) -eq $true) {
                    $Modul = $Module.split('/')
                        $ModName = $Modul[7].Substring(0, $Modul[7].length - ".ps1".length)
                    $ModuSeq = (New-Object System.Net.WebClient).DownloadString($($args[10]) + '/Modules/' + $Modul[6] + '/' + $Modul[7])
                    } Else {
                        $ModName = $Module.Name.Substring(0, $Module.Name.length - ".ps1".length)
                    $ModuSeq0 = New-Object System.IO.StreamReader($Module.FullName)
                    $ModuSeq = $ModuSeq0.ReadToEnd()
                    $ModuSeq0.Dispose()
                }

                $ScriptBlock = [Scriptblock]::Create($ModuSeq)

                New-Variable -Name ('ModRun' + $ModName)
                New-Variable -Name ('ModJob' + $ModName)

                Set-Variable -Name ('ModRun' + $ModName) -Value ([PowerShell]::Create()).AddScript($ScriptBlock).AddArgument($($args[0])).AddArgument($($args[1])).AddArgument($($args[2])).AddArgument($($args[3])).AddArgument($($args[4]))

                Set-Variable -Name ('ModJob' + $ModName) -Value ((get-variable -name ('ModRun' + $ModName)).Value).BeginInvoke()

                $job += (get-variable -name ('ModJob' + $ModName)).Value
            }

            while ($Job.Runspace.IsCompleted -contains $false) {}

            foreach ($Module in $Modules) {
                If ($($args[8]) -eq $true) {
                    $Modul = $Module.split('/')
                        $ModName = $Modul[7].Substring(0, $Modul[7].length - ".ps1".length)
                    } Else {
                        $ModName = $Module.Name.Substring(0, $Module.Name.length - ".ps1".length)
                }

                New-Variable -Name ('ModValue' + $ModName)
                Set-Variable -Name ('ModValue' + $ModName) -Value (((get-variable -name ('ModRun' + $ModName)).Value).EndInvoke((get-variable -name ('ModJob' + $ModName)).Value))

            }

            $Hashtable = New-Object System.Collections.Hashtable

            foreach ($Module in $Modules) {
                If ($($args[8]) -eq $true) {
                    $Modul = $Module.split('/')
                        $ModName = $Modul[7].Substring(0, $Modul[7].length - ".ps1".length)
                    } Else {
                        $ModName = $Module.Name.Substring(0, $Module.Name.length - ".ps1".length)
                }
                $Hashtable["$ModName"] = (get-variable -name ('ModValue' + $ModName)).Value
            }

            $Hashtable

        } -ArgumentList $PSScriptRoot, $Subscriptions, $InTag, $Resources, 'Processing' , $null, $null, $null, $RunOnline, $Repo, $RawRepo   | Out-Null

        <######################################################### INFRASTRUCTURE RESOURCE GROUP JOB ######################################################################>

        Write-Debug ('Starting Infrastructure Processing Job.')
        Start-job -Name 'Infrastructure' -ScriptBlock {

            If ($($args[8]) -eq $true) {
                $OnlineRepo = Invoke-WebRequest -Uri ($($args[9]) + '/Infrastructure')
                $Modules = $OnlineRepo.Links | Where-Object { $_.href -like '*.ps1' }
                $Modules = $Modules.href
            }
            Else {
                if($($args[0]) -like '*\*')
                    {
                        $Modules = Get-ChildItem -Path ($($args[0]) + '\Modules\Infrastructure\*.ps1') -Recurse
                    }
                else
                    {
                        $Modules = Get-ChildItem -Path ($($args[0]) + '/Modules/Infrastructure/*.ps1') -Recurse
                    }
            }
            $job = @()

            foreach ($Module in $Modules) {
                If ($($args[8]) -eq $true) {
                    $Modul = $Module.split('/')
                        $ModName = $Modul[7].Substring(0, $Modul[7].length - ".ps1".length)
                    $ModuSeq = (New-Object System.Net.WebClient).DownloadString($($args[10]) + '/Modules/' + $Modul[6] + '/' + $Modul[7])
                    } Else {
                        $ModName = $Module.Name.Substring(0, $Module.Name.length - ".ps1".length)
                    $ModuSeq0 = New-Object System.IO.StreamReader($Module.FullName)
                    $ModuSeq = $ModuSeq0.ReadToEnd()
                    $ModuSeq0.Dispose()
                }


                $ScriptBlock = [Scriptblock]::Create($ModuSeq)

                New-Variable -Name ('ModRun' + $ModName)
                New-Variable -Name ('ModJob' + $ModName)

                Set-Variable -Name ('ModRun' + $ModName) -Value ([PowerShell]::Create()).AddScript($ScriptBlock).AddArgument($($args[0])).AddArgument($($args[1])).AddArgument($($args[2])).AddArgument($($args[3])).AddArgument($($args[4]))

                Set-Variable -Name ('ModJob' + $ModName) -Value ((get-variable -name ('ModRun' + $ModName)).Value).BeginInvoke()

                $job += (get-variable -name ('ModJob' + $ModName)).Value
            }

            while ($Job.Runspace.IsCompleted -contains $false) {}

            foreach ($Module in $Modules) {
                If ($($args[8]) -eq $true) {
                    $Modul = $Module.split('/')
                        $ModName = $Modul[7].Substring(0, $Modul[7].length - ".ps1".length)
                    } Else {
                        $ModName = $Module.Name.Substring(0, $Module.Name.length - ".ps1".length)
                }

                New-Variable -Name ('ModValue' + $ModName)
                Set-Variable -Name ('ModValue' + $ModName) -Value (((get-variable -name ('ModRun' + $ModName)).Value).EndInvoke((get-variable -name ('ModJob' + $ModName)).Value))

            }

            $Hashtable = New-Object System.Collections.Hashtable

            foreach ($Module in $Modules) {
                If ($($args[8]) -eq $true) {
                    $Modul = $Module.split('/')
                        $ModName = $Modul[7].Substring(0, $Modul[7].length - ".ps1".length)
                    } Else {
                        $ModName = $Module.Name.Substring(0, $Module.Name.length - ".ps1".length)
                }
                $Hashtable["$ModName"] = (get-variable -name ('ModValue' + $ModName)).Value
            }

            $Hashtable

        } -ArgumentList $PSScriptRoot, $Subscriptions, $InTag, $Resources, 'Processing' , $null, $null, $null, $RunOnline, $Repo, $RawRepo   | Out-Null

        <######################################################### DATABASES RESOURCE GROUP JOB ######################################################################>

        Write-Debug ('Starting Database Processing Job.')
        Start-job -Name 'Database' -ScriptBlock {

            If ($($args[8]) -eq $true) {
                $OnlineRepo = Invoke-WebRequest -Uri ($($args[9]) + '/Data')
                $Modules = $OnlineRepo.Links | Where-Object { $_.href -like '*.ps1' }
                $Modules = $Modules.href
            }
            Else {
                if($($args[0]) -like '*\*')
                    {
                        $Modules = Get-ChildItem -Path ($($args[0]) + '\Modules\Data\*.ps1') -Recurse
                    }
                else
                    {
                        $Modules = Get-ChildItem -Path ($($args[0]) + '/Modules/Data/*.ps1') -Recurse
                    }
            }
            $job = @()

            foreach ($Module in $Modules) {
                If ($($args[8]) -eq $true) {
                    $Modul = $Module.split('/')
                        $ModName = $Modul[7].Substring(0, $Modul[7].length - ".ps1".length)
                    $ModuSeq = (New-Object System.Net.WebClient).DownloadString($($args[10]) + '/Modules/' + $Modul[6] + '/' + $Modul[7])
                    } Else {
                        $ModName = $Module.Name.Substring(0, $Module.Name.length - ".ps1".length)
                    $ModuSeq0 = New-Object System.IO.StreamReader($Module.FullName)
                    $ModuSeq = $ModuSeq0.ReadToEnd()
                    $ModuSeq0.Dispose()
                }

                $ScriptBlock = [Scriptblock]::Create($ModuSeq)

                New-Variable -Name ('ModRun' + $ModName)
                New-Variable -Name ('ModJob' + $ModName)

                Set-Variable -Name ('ModRun' + $ModName) -Value ([PowerShell]::Create()).AddScript($ScriptBlock).AddArgument($($args[0])).AddArgument($($args[1])).AddArgument($($args[2])).AddArgument($($args[3])).AddArgument($($args[4]))

                Set-Variable -Name ('ModJob' + $ModName) -Value ((get-variable -name ('ModRun' + $ModName)).Value).BeginInvoke()

                $job += (get-variable -name ('ModJob' + $ModName)).Value
            }

            while ($Job.Runspace.IsCompleted -contains $false) {}

            foreach ($Module in $Modules) {
                If ($($args[8]) -eq $true) {
                    $Modul = $Module.split('/')
                        $ModName = $Modul[7].Substring(0, $Modul[7].length - ".ps1".length)
                    } Else {
                        $ModName = $Module.Name.Substring(0, $Module.Name.length - ".ps1".length)
                }

                New-Variable -Name ('ModValue' + $ModName)
                Set-Variable -Name ('ModValue' + $ModName) -Value (((get-variable -name ('ModRun' + $ModName)).Value).EndInvoke((get-variable -name ('ModJob' + $ModName)).Value))

            }

            $Hashtable = New-Object System.Collections.Hashtable

            foreach ($Module in $Modules) {
                If ($($args[8]) -eq $true) {
                    $Modul = $Module.split('/')
                        $ModName = $Modul[7].Substring(0, $Modul[7].length - ".ps1".length)
                    } Else {
                        $ModName = $Module.Name.Substring(0, $Module.Name.length - ".ps1".length)
                }
                $Hashtable["$ModName"] = (get-variable -name ('ModValue' + $ModName)).Value
            }

            $Hashtable

        } -ArgumentList $PSScriptRoot, $Subscriptions, $InTag, $Resources, 'Processing' , $null, $null, $null, $RunOnline, $Repo, $RawRepo   | Out-Null

        <############################################################## RESOURCES LOOP CREATION #############################################################>

        Write-Debug ('Starting Jobs Collector.')
        Write-Progress -activity $DataActive -Status "Processing Inventory" -PercentComplete 0
        $c = 0

        $JobNames = @()

        $JobNames += 'Subscriptions'
        $JobNames += 'Compute'
        $JobNames += 'Networking'
        $JobNames += 'Infrastructure'
        $JobNames += 'Database'

        if ($QuotaUsage.IsPresent) {
            $JobNames += 'Quota Usage'
        }

        $Jobs = get-job
        Foreach($Job in $Jobs)
            {
                Write-Debug ('Current Status of Job:'+$Job.name+'. is: '+$Job.State)
            }
        while (get-job -Name $JobNames | Where-Object { $_.State -eq 'Running' }) {
            $jb = get-job -Name $JobNames
            $c = (((($jb.count - ($jb | Where-Object { $_.State -eq 'Running' }).Count)) / $jb.Count) * 100)
            Write-Debug ('Jobs Still Running: '+[string]($jb | Where-Object { $_.State -eq 'Running' }).Name)
            $c = [math]::Round($c)
            Write-Progress -Id 1 -activity "Processing Resource Jobs" -Status "$c% Complete." -PercentComplete $c
            Start-Sleep -Seconds 2
        }
        Write-Progress -Id 1 -activity "Processing Resource Jobs" -Status "100% Complete." -Completed

        Write-Debug ('Jobs Compleated.')

        $AzSubs = Receive-Job -Name 'Subscriptions'

        $AzCompute = Receive-Job -Name 'Compute'

        Write-Debug ('Compute Job Returned: ' + ($AzCompute.values | Where-Object {$_ -ne $null}).Count + ' Resource Types.')

        $AzNetworking = Receive-Job -Name 'Networking'

        Write-Debug ('Networking Job Returned: ' + ($AzNetworking.values | Where-Object {$_ -ne $null}).Count + ' Resource Types.')

        $AzInfrastructure = Receive-Job -Name 'Infrastructure'

        Write-Debug ('Infrastructure Job Returned: ' + ($AzInfrastructure.values | Where-Object {$_ -ne $null}).Count + ' Resource Types.')

        $AzDatabase = Receive-Job -Name 'Database'

        Write-Debug ('Database Job Returned: ' + ($AzDatabase.values | Where-Object {$_ -ne $null}).Count + ' Resource Types.')

        if($QuotaUsage.IsPresent)
            {
                $Global:AzQuota = Receive-Job -Name 'Quota Usage'
            }

        $Global:SmaResources = @()

        $Global:SmaResources += $AzCompute
        $Global:SmaResources += $AzNetworking
        $Global:SmaResources += $AzInfrastructure
        $Global:SmaResources += $AzDatabase

        <############################################################## Reporting ###################################################################>

        Write-Debug ('Starting Reporting Phase.')
        Write-Progress -activity $DataActive -Status "Processing Inventory" -PercentComplete 50

        If ($RunOnline -eq $true) {
            $Modules = @()
            Write-Debug ('Running Online, Gethering List Of Modules for Compute.')
            $OnlineRepoComp = Invoke-WebRequest -Uri ($Repo + '/Compute')
            $RepoComp = $OnlineRepoComp.Links | Where-Object { $_.href -like '*.ps1' }
            $Modules += $RepoComp.href
            Write-Debug ('Running Online, Gethering List Of Modules for Networking.')
            $OnlineRepoNetworking = Invoke-WebRequest -Uri ($Repo + '/Networking')
            $RepoNetwork = $OnlineRepoNetworking.Links | Where-Object { $_.href -like '*.ps1' }
            $Modules += $RepoNetwork.href
            Write-Debug ('Running Online, Gethering List Of Modules for Database.')
            $OnlineRepoDB = Invoke-WebRequest -Uri ($Repo + '/Data')
            $RepoData = $OnlineRepoDB.Links | Where-Object { $_.href -like '*.ps1' }
            $Modules += $RepoData.href
            Write-Debug ('Running Online, Gethering List Of Modules for Infrastructure.')
            $OnlineRepoInfra = Invoke-WebRequest -Uri ($Repo + '/Infrastructure')
            $RepoInfra = $OnlineRepoInfra.Links | Where-Object { $_.href -like '*.ps1' }
            $Modules += $RepoInfra.href
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
                    $ModName = $Modul[7].Substring(0, $Modul[7].length - ".ps1".length)
                $ModuSeq = (New-Object System.Net.WebClient).DownloadString($RawRepo + '/Modules/' + $Modul[6] + '/' + $Modul[7])
                } Else {
                $ModuSeq0 = New-Object System.IO.StreamReader($Module.FullName)
                $ModuSeq = $ModuSeq0.ReadToEnd()
                $ModuSeq0.Dispose()
            }

                Write-Debug "Running Module: '$Module'"

            $ScriptBlock = [Scriptblock]::Create($ModuSeq)

            $ExcelRun = ([PowerShell]::Create()).AddScript($ScriptBlock).AddArgument($PSScriptRoot).AddArgument($null).AddArgument($InTag).AddArgument($null).AddArgument('Reporting').AddArgument($file).AddArgument($SmaResources).AddArgument($TableStyle).AddArgument($Unsupported)

            $ExcelJob = $ExcelRun.BeginInvoke()

            while ($ExcelJob.IsCompleted -contains $false) {}

            $ExcelRun.EndInvoke($ExcelJob)

            $ExcelRun.Dispose()

            $ReportCounter ++

        }

        Write-Debug ('Resource Reporting Phase Done.')

        <################################################################### Quotas ###################################################################>

        if($QuotaUsage.IsPresent)
            {
                Write-Debug ('Generating Quota Usage sheet for: ' + $Global:AzQuota.count + ' Regions.')

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

                while ($QuotaJob.IsCompleted -contains $false) {}

                $QuotaRun.EndInvoke($QuotaJob)

                $QuotaRun.Dispose()

                Write-Progress -activity 'Azure Resource Inventory Quota Usage' -Status "100% Complete." -Completed
            }


        <################################################ Security Center #######################################################>
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

            while ($SecExcelJob.IsCompleted -contains $false) {}

            $SecExcelRun.EndInvoke($SecExcelJob)

            $SecExcelRun.Dispose()
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

            while ($AdvExcelJob.IsCompleted -contains $false) {}

            $AdvExcelRun.EndInvoke($AdvExcelJob)

            $AdvExcelRun.Dispose()
        }

            <################################################################### Subscriptions ###################################################################>

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

        while ($SubsJob.IsCompleted -contains $false) {}

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

        $ChartsRun = ([PowerShell]::Create()).AddScript($ScriptBlock).AddArgument($file).AddArgument($TableStyle).AddArgument($Global:PlatOS).AddArgument($Global:Subscriptions).AddArgument($Global:Resources.Count).AddArgument($ExtractionRunTime).AddArgument($ReportingRunTime)

        $ChartsJob = $ChartsRun.BeginInvoke()

        Write-Progress -activity 'Azure Resource Inventory Reporting Charts' -Status "30% Complete." -PercentComplete 30 -CurrentOperation "Waiting Excel Chart's Thread."

        while ($ChartsJob.IsCompleted -contains $false) {}

        $ChartsRun.EndInvoke($ChartsJob)

        $ChartsRun.Dispose()

        Write-Debug ('Finished Charts Phase.')

        Write-Progress -activity 'Azure Resource Inventory Reporting Charts' -Status "100% Complete." -Completed

        if($Diagram.IsPresent)
        {
        Write-Progress -activity 'Diagrams' -Status "Completing Diagram" -PercentComplete 70 -CurrentOperation "Consolidating Diagram"

            while (get-job -Name 'DrawDiagram','VisioDiagram' | Where-Object { $_.State -eq 'Running' }) {
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

    $Global:VisioCheck = Get-ChildItem -Path $DFile -ErrorAction SilentlyContinue
}

$Measure = $Global:SRuntime.Totalminutes.ToString('#######.##')

Write-Host ('Report Complete. Total Runtime was: ' + $Measure + ' Minutes')
Write-Host ('Total Resources: ') -NoNewline
write-host $Resources.count -ForegroundColor Cyan
Write-Host ('Total Advisories: ') -NoNewline
write-host $advco -ForegroundColor Cyan
if ($SecurityCenter.IsPresent) {
    Write-Host ('Total Security Advisories: ' + $Secadvco)
}

Write-Host ''
Write-Host ('Excel file saved at: ') -NoNewline
write-host $File -ForegroundColor Cyan
Write-Host ''

if($Global:PlatOS -eq 'PowerShell Desktop' -and $Diagram.IsPresent) {
    Write-Host ('Draw.io Diagram file saved at: ') -NoNewline
    write-host $DDFile -ForegroundColor Cyan
    Write-Host ''
    }

if ($Diagram.IsPresent -and $Global:VisioCheck) {
    Write-Host ('Visio file saved at: ') -NoNewline
    write-host $DFile -ForegroundColor Cyan
    Write-Host ''
}