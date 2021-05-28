##########################################################################################
#                                                                                        #
#                * Azure Resource Inventory ( ARI ) Report Generator *                   #
#                                                                                        #
#       Version: 1.4.8                                                                   #
#                                                                                        #
#       Date: 05/28/2021                                                                 #
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
    AUTHOR: Claudio Merola and Renato Gregio - Customer Engineer - Customer Success Unit | Azure Infrastucture/Automation/Devops/Governance | Microsoft

.LINK
    https://github.com/azureinventory
    Please note that while being developed by a Microsoft employee, Azure inventory Scripts is not a Microsoft service or product. Azure Inventory Scripts are a personal driven project, there are none implicit or explicit obligations related to this project, it is provided 'as is' with no warranties and confer no rights.
#>

param ($TenantID, [switch]$SecurityCenter, $SubscriptionID, [switch]$SkipAdvisory, [switch]$IncludeTags) 

$Runtime = Measure-Command -Expression {

    if ($DebugPreference -eq 'Inquire') {
        $DebugPreference = 'Continue'
    }
    if ($IncludeTags.IsPresent) {$InTag = $true} else {$InTag = $false}
    $ErrorActionPreference = "silentlycontinue"
    $DesktopPath = "C:\AzureResourceInventory"
    $CSPath = "$HOME/AzureResourceInventory"
    $Global:Resources = @()
    $Global:Advisories = @()
    $Global:Security = @()
    $Global:Subscriptions = ''

    <######################################### Help ################################################>

    function usageMode() {
        Write-Output "" 
        Write-Output "" 
        Write-Output "Usage: "
        Write-Output "For CloudShell:"
        Write-Output "./AzureResourceInventory.ps1"      
        Write-Output ""
        Write-Output "For PowerShell Desktop:"      
        Write-Output "./AzureResourceInventory.ps1 -TenantID <Azure Tenant ID> -SubscriptionID <Subscription ID>"
        Write-Output "" 
        Write-Output "" 
    }

    <###################################################### Environment ######################################################################>

    function Extractor {
        function checkAzCli() {
            Write-Host "Validating Az Cli.."
            $azcli = az --version
            if ($null -eq $azcli) {
                Read-Host "Azure CLI Not Found. Press <Enter> to finish script"
                Exit
            }
            Write-Host "Validating Az Cli Extension.."
            $azcliExt = az extension list --output json | ConvertFrom-Json
            if ($azcliExt.name -notin 'resource-graph') {
                Write-Host "Adding Az Cli Extension"
                az extension add --name resource-graph 
            }
            Write-Host "Validating ImportExcel Module.."
            $VarExcel = Get-InstalledModule -Name ImportExcel -ErrorAction silentlycontinue
            if ($null -eq $VarExcel) 
                {
                    Write-Host "Trying to install ImportExcel Module.."
                    Install-Module -Name ImportExcel -Force
                }
            $VarExcel = Get-InstalledModule -Name ImportExcel -ErrorAction silentlycontinue
            if ($null -eq $VarExcel) 
                {
                    Read-Host 'Admininstrator rights required to install ImportExcel Module. Press <Enter> to finish script'
                    Exit
                }
        }

        function LoginSession() {
            $Global:DefaultPath = "$DesktopPath\"
            if ($TenantID -eq '' -or $null -eq $TenantID) {
                write-host "Tenant ID not specified. Use -TenantID parameter if you want to specify directly. "        
                write-host "Authenticating Azure"
                write-host ""
                az account clear | Out-Null
                az login | Out-Null
                write-host ""
                write-host ""
                $Tenants = az account list --query [].homeTenantId -o tsv --only-show-errors | Sort-Object -Unique
                    
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
                }
        
                write-host "Extracting from Tenant $TenantID"
                $Global:Subscriptions = az account list --output json --only-show-errors | ConvertFrom-Json
                $Global:Subscriptions = $Subscriptions | Where-Object { $_.tenantID -eq $TenantID }
                if ($SubscriptionID) {
                    $Global:Subscriptions = $Subscriptions | Where-Object { $_.ID -eq $SubscriptionID }
                }
            }
        
            else {
                az account clear | Out-Null
                az login -t $TenantID | Out-Null
                $Global:Subscriptions = az account list --output json --only-show-errors | ConvertFrom-Json
                $Global:Subscriptions = $Subscriptions | Where-Object { $_.tenantID -eq $TenantID }
                if ($SubscriptionID) {
                    $Global:Subscriptions = $Subscriptions | Where-Object { $_.ID -eq $SubscriptionID }
                }
            }
        }

        function checkPS() {
            if ($PSVersionTable.PSEdition -eq 'Desktop') {
                write-host "PowerShell Desktop Identified."
                write-host ""
                LoginSession
            }
            elseif ($PSVersionTable.PSEdition -eq 'Core') {
                write-host "PowerShell Core Identified."
                write-host ""
                LoginSession
            }
            else {
                $Global:PSEnvironment = "CloudShell"
                write-host 'Azure CloudShell Identified.'
                write-host ""
                <#### For Azure CloudShell change your StorageAccount Name, Container and SAS for Grid Extractor transfer. ####>
                $Global:DefaultPath = "$CSPath/" 
                $Global:Subscriptions = az account list --output json --only-show-errors | ConvertFrom-Json
            }
        }

        <###################################################### Checking PowerShell ######################################################################>

        checkAzCli
        checkPS

        <###################################################### Subscriptions ######################################################################>

        Write-Progress -activity 'Azure Inventory' -Status "1% Complete." -PercentComplete 2 -CurrentOperation 'Discovering Subscriptions..'

        $SubCount = $Subscriptions.count

        Write-Debug ('Number of Subscriptions Found: ' + $SubCount)
        Write-Progress -activity 'Azure Inventory' -Status "3% Complete." -PercentComplete 3 -CurrentOperation "$SubCount Subscriptions found.."

        if ((Test-Path -Path $DefaultPath -PathType Container) -eq $false) {
            New-Item -Type Directory -Force -Path $DefaultPath | Out-Null
        }

        <######################################################## INVENTORY LOOPs #######################################################################>

        Write-Progress -activity 'Azure Inventory' -Status "4% Complete." -PercentComplete 4 -CurrentOperation "Starting Resources extraction jobs.."

        <######################################################### ADVISOR ######################################################################>

        if (!($SkipAdvisory.IsPresent)) {
            Write-Debug ('Extracting total number of Advisories from Tenant')
            $AdvSize = az graph query -q  "advisorresources | summarize count()" --output json --only-show-errors | ConvertFrom-Json
            if($AdvSize.data) {$AdvSizeNum = $AdvSize.data.'count_'}else{$AdvSizeNum = $AdvSize.'count_'}

            Write-Progress -activity 'Azure Inventory' -Status "5% Complete." -PercentComplete 5 -CurrentOperation "Starting Advisories extraction jobs.."

            if ($AdvSizeNum -ge 1) {
                $Loop = $AdvSizeNum / 1000
                $Loop = [math]::ceiling($Loop)
                $Looper = 0
                $Limit = 0

                while ($Looper -lt $Loop) 
                    {
                        $Looper ++
                        Write-Progress -Id 1 -activity "Running Advisory Inventory Job" -Status "$Looper / $Loop of Inventory Jobs" -PercentComplete (($Looper / $Loop) * 100)
                        $Advisor = az graph query -q "advisorresources | order by id asc" --skip $Limit --first 1000 --output json --only-show-errors | ConvertFrom-Json
                        if($Advisor.data) {$Global:Advisories += $Advisor.data} else {$Global:Advisories += $Advisor}
                        Start-Sleep 3
                        $Limit = $Limit + 1000
                    }
                    Write-Progress -Id 1 -activity "Running Advisory Inventory Job" -Status "Completed" -Completed
            }
        }   

        <######################################################### Security Center ######################################################################>

        if ($SecurityCenter.IsPresent) 
            {
                Write-Progress -activity 'Azure Inventory' -Status "6% Complete." -PercentComplete 6 -CurrentOperation "Starting Security Advisories extraction jobs.."
                Write-Host " Azure Resource Inventory are collecting Security Center Advisories."
                Write-Host " Collecting Security Center Can increase considerably the execution time of Azure Resource Inventory and the size of final report "
                Write-Host " "
                Write-Host " If you want to skip Security Center report use <-SkipSecurityCenter> parameter. "
                Write-Host " "

                Write-Debug ('Extracting total number of Security Advisories from Tenant')
                $SecSize = az graph query -q  "securityresources | where properties['status']['code'] == 'Unhealthy' | summarize count()" --output json --only-show-errors | ConvertFrom-Json
                if($SecSize.data) {$SecSizeNum = $SecSize.data.'count_'} else {$SecSizeNum = $SecSize.'count_'}


                if ($SecSizeNum -ge 1) 
                    {
                        $Loop = $SecSizeNum / 1000
                        $Loop = [math]::ceiling($Loop)
                        $Looper = 0
                        $Limit = 0
                        while ($Looper -lt $Loop) 
                            {
                                $Looper ++
                                Write-Progress -Id 1 -activity "Running Security Advisory Inventory Job" -Status "$Looper / $Loop of Inventory Jobs" -PercentComplete (($Looper / $Loop) * 100)
                                $SecCenter = az graph query -q "securityresources | order by id asc | where properties['status']['code'] == 'Unhealthy'" --skip $Limit --first 1000 --output json --only-show-errors | ConvertFrom-Json
                                if($SecCenter.data) {$Global:Security += $SecCenter.data} else {$Global:Security += $SecCenter}
                                Start-Sleep 3
                                $Limit = $Limit + 1000
                            }
                            Write-Progress -Id 1 -activity "Running Security Advisory Inventory Job" -Status "Completed" -Completed
                    }
            }
        else 
            {
                Write-Host " "
                Write-Host " To include Security Center details in the report, use <-SecurityCenter> parameter. " 
                Write-Host " " 
            }
            
            Write-Progress -activity 'Azure Inventory' -PercentComplete 20

            Write-Progress -Id 1 -activity "Running Inventory Jobs" -Status "100% Complete." -Completed
 

            Foreach ($Subscription in $Subscriptions) {

                Write-Debug ('Extracting total number of Resources from Subscription: ' + $Subscription.Name)
                          
                    $SUBID = $Subscription.id
                    $SubName = $Subscription.name
                    az account set --subscription $SUBID
                    
                    $EnvSize = az graph query -q "resources | where subscriptionId == '$SUBID' | summarize count()" --output json --only-show-errors | ConvertFrom-Json
                    if($EnvSize.data) {$EnvSizeNum = $EnvSize.data.'count_'} else {$EnvSizeNum = $EnvSize.'count_'}
                        
                    if ($EnvSizeNum -ge 1) {
                        $Loop = $EnvSizeNum / 1000
                        $Loop = [math]::ceiling($Loop)
                        $Looper = 0
                        $Limit = 0
    
                        while ($Looper -lt $Loop) {
                            $Resource = az graph query -q  "resources | where subscriptionId == '$SUBID' | order by id asc" --skip $Limit --first 1000 --output json --only-show-errors | ConvertFrom-Json
                            if($Resource.data) {$Global:Resources += $Resource.data} else {$Global:Resources += $Resource} 
                            Start-Sleep 3      
                            $Looper ++
                            Write-Progress -Id 1 -activity "Running Resource Inventory Job" -Status "$Looper / $Loop of Inventory Jobs ($SubName)" -PercentComplete (($Looper / $Loop) * 100)
                            $Limit = $Limit + 1000
                        }
                    }
                    Write-Progress -Id 1 -activity "Running Resource Inventory Job" -Status "$Looper / $Loop of Inventory Jobs ($SubName)" -PercentComplete (($Looper / $Loop) * 100)
            }   
    
    }

    <######################################################### END Extractor Function ######################################################################>










    

    <####################################################### Importing Data to Excel  #####################################################################>

    function ImportDataExcel {
        $SUBs = $Subscriptions
        
        Write-Progress -activity 'Azure Inventory' -Status "21% Complete." -PercentComplete 21 -CurrentOperation "Starting to process extraction data.."

        <######################################################### RESOURCES JOB ######################################################################>

        Write-Progress -activity 'Azure Inventory' -Status "22% Complete." -PercentComplete 22 -CurrentOperation "Starting to process extraction data.."

        $VM = @()
        $VMDisk = @()
        $StorageAcc = @()
        $VNET = @()
        $VMNIC = @()
        $NSG = @()
        $VMExp = @()
        $VNETGTW = @()
        $SQLVM = @()
        $DB = @()
        $RB = @()
        $AUT = @()
        $PIP = @()
        $EVTHUB = @()
        $MySQL = @()
        $POSTGRE = @()
        $SERVERFARM = @()
        $WRKSPACE = @()
        $AKS = @()
        $CON = @()
        $AVSET = @()
        $SITES = @()
        $VMSS = @()
        $LB = @()
        $SQLSERVER = @()
        $FRONTDOOR = @()
        $APPGTW = @()
        $ROUTETABLE = @()
        $VAULT = @()
        $RECOVERYVAULT = @()
        $DNSZONE = @()
        $IOT = @()
        $APIM = @()


        ForEach ($Resource in $Resources) {
            if ($Resource.TYPE -eq 'microsoft.compute/virtualmachines') { $VM += $Resource }
            if ($Resource.TYPE -eq 'microsoft.compute/disks' ) { $VMDisk += $Resource }
            if ($Resource.TYPE -eq 'microsoft.storage/storageaccounts') { $StorageAcc += $Resource }
            if ($Resource.TYPE -eq 'microsoft.network/virtualnetworks') { $VNET += $Resource }
            if ($Resource.TYPE -eq 'microsoft.network/networkinterfaces') { $VMNIC += $Resource }
            if ($Resource.TYPE -eq 'microsoft.network/networksecuritygroups') { $NSG += $Resource }
            if ($Resource.TYPE -eq 'microsoft.compute/virtualmachines/extensions' ) { $VMExp += $Resource }
            if ($Resource.TYPE -eq 'microsoft.network/virtualnetworkgateways' ) { $VNETGTW += $Resource }
            if ($Resource.TYPE -eq 'microsoft.sqlvirtualmachine/sqlvirtualmachines' ) { $SQLVM += $Resource }
            if ($Resource.TYPE -eq 'microsoft.sql/servers/databases' -and $_.name -ne 'master' ) { $DB += $Resource }
            if ($Resource.TYPE -eq 'microsoft.automation/automationaccounts/runbooks' ) { $RB += $Resource }
            if ($Resource.TYPE -eq 'microsoft.automation/automationaccounts' ) { $AUT += $Resource }
            if ($Resource.TYPE -eq 'microsoft.network/publicipaddresses') { $PIP += $Resource }
            if ($Resource.TYPE -eq 'microsoft.eventhub/namespaces' ) { $EVTHUB += $Resource }
            if ($Resource.TYPE -eq 'microsoft.dbformysql/servers') { $MySQL += $Resource }
            if ($Resource.TYPE -eq 'microsoft.dbforpostgresql/servers' ) { $POSTGRE += $Resource }
            if ($Resource.TYPE -eq 'microsoft.web/serverfarms' ) { $SERVERFARM += $Resource }
            if ($Resource.TYPE -eq 'microsoft.operationalinsights/workspaces') { $WRKSPACE += $Resource }
            if ($Resource.TYPE -eq 'microsoft.containerservice/managedclusters' ) { $AKS += $Resource }
            if ($Resource.TYPE -eq 'microsoft.containerinstance/containergroups') { $CON += $Resource }
            if ($Resource.TYPE -eq 'microsoft.compute/availabilitysets' ) { $AVSET += $Resource }
            if ($Resource.TYPE -eq 'microsoft.web/sites' ) { $SITES += $Resource }
            if ($Resource.TYPE -eq 'microsoft.compute/virtualmachinescalesets' ) { $VMSS += $Resource }
            if ($Resource.TYPE -eq 'microsoft.network/loadbalancers' ) { $LB += $Resource }
            if ($Resource.TYPE -eq 'microsoft.sql/servers' ) { $SQLSERVER += $Resource }
            if ($Resource.TYPE -eq 'microsoft.network/frontdoors' ) { $FRONTDOOR += $Resource }
            if ($Resource.TYPE -eq 'microsoft.network/applicationgateways' ) { $APPGTW += $Resource }
            if ($Resource.TYPE -eq 'microsoft.network/routetables' ) { $ROUTETABLE += $Resource }
            if ($Resource.TYPE -eq 'microsoft.keyvault/vaults' ) { $VAULT += $Resource }
            if ($Resource.TYPE -eq 'microsoft.recoveryservices/vaults' ) { $RECOVERYVAULT += $Resource }
            if ($Resource.TYPE -eq 'microsoft.network/dnszones' ) { $DNSZONE += $Resource }
            if ($Resource.TYPE -eq 'microsoft.devices/iothubs' ) { $IOT += $Resource }

            if ($Resource.TYPE -eq 'microsoft.apimanagement/service' ) { $APIM += $Resource }
        }


        <######################################################### ADVISORY JOB ######################################################################>

        Start-Job -Name 'Advisory' -ScriptBlock {

            $obj = ''
            $tmp = @()

            foreach ($1 in $($args)) {
                $data = $1.PROPERTIES

                $obj = @{
                    'ResourceGroup'          = $1.RESOURCEGROUP;
                    'Affected Resource Type' = $data.impactedField;
                    'Name'                   = $data.impactedValue;
                    'Category'               = $data.category;
                    'Impact'                 = $data.impact;
                    'Score'                  = $data.extendedproperties.score;
                    'Problem'                = $data.shortDescription.problem
                }    
                $tmp += $obj
            }
            $tmp
        } -ArgumentList $Advisories | Out-Null



        <######################################################### SECURITY CENTER JOB ######################################################################>

        Start-Job -Name 'Security' -ScriptBlock {

            $obj = ''
            $tmp = @()

            foreach ($1 in $($args[0])) {
                $data = $1.PROPERTIES

                $sub1 = $($args[1]) | Where-Object { $_.id -eq $1.properties.resourceDetails.Id.Split("/")[2] }

                $obj = @{
                    'Subscription'       = $sub1.Name;
                    'Resource Group'     = $1.RESOURCEGROUP;
                    'Resource Type'      = $data.resourceDetails.Id.Split("/")[7];
                    'Resource Name'      = $data.resourceDetails.Id.Split("/")[8];
                    'Categories'         = [string]$data.metadata.categories;
                    'Control'            = $data.displayName;
                    'Severity'           = $data.metadata.severity;
                    'Status'             = $data.status.code;
                    'Remediation'        = $data.metadata.remediationDescription;
                    'Remediation Effort' = $data.metadata.implementationEffort;
                    'User Impact'        = $data.metadata.userImpact;
                    'Threats'            = [string]$data.metadata.threats
                }    
                $tmp += $obj
            }
            $tmp
        } -ArgumentList $Security, $SUBs | Out-Null


        <######################################################### COMPUTE RESOURCE GROUP JOB ######################################################################>

        Start-Job -Name 'Compute' -ScriptBlock {

            $job = @()

            $VM = ([PowerShell]::Create()).AddScript( { param($Sub,$Intag, $VM, $NIC, $NSG, $EXT)
                    $vm = $VM
                    $vmexp = $EXT
                    $nic = $NIC
                    $nsg = $NSG
                    $Subs = $Sub

                    $obj = ''
                    $tmp = @()

                    foreach ($1 in $vm) {
                        $ResUCount = 1
                        $sub1 = $SUBs | Where-Object { $_.id -eq $1.subscriptionId }
                        $data = $1.PROPERTIES 
                        $os = if ($null -eq $data.OSProfile.LinuxConfiguration) { 'Windows' }else { 'Linux' }
                        $AVSET = ''
                        $dataSize = ''
                        $StorAcc = ''
                        $UpdateMgmt = if ($null -eq $data.osProfile.LinuxConfiguration.patchSettings.patchMode) {$data.osProfile.WindowsConfiguration.patchSettings.patchMode} else {$data.osProfile.LinuxConfiguration.patchSettings.patchMode}

                        $ext = @()
                        $AzDiag = ''
                        $Azinsights = ''
                        $ext = ($vmexp | Where-Object { ($_.id -split "/")[8] -eq $1.name }).properties.Publisher
                        if ($null -ne $ext) {
                            $ext = foreach ($ex in $ext) {
                                if ($ex | Where-Object { $_ -eq 'Microsoft.Azure.Performance.Diagnostics' }) { $AzDiag = $true }
                                if ($ex | Where-Object { $_ -eq 'Microsoft.EnterpriseCloud.Monitoring' }) { $Azinsights = $true }
                                $ex + ', '
                            }
                            $ext = [string]$ext
                            $ext = $ext.Substring(0, $ext.Length - 2)
                        }
                            
                        if ($null -ne $data.availabilitySet) { $AVSET = 'True' }else { $AVSET = 'False' }
                        if ($data.diagnosticsProfile.bootDiagnostics.enabled -eq $true) { $bootdg = $true }else { $bootdg = $false }
                        if ($null -ne $data.storageProfile.dataDisks.managedDisk.storageAccountType) {
                            $StorAcc = if ($data.storageProfile.dataDisks.managedDisk.storageAccountType.count -ge 2) { ($data.storageProfile.dataDisks.managedDisk.storageAccountType.count.ToString() + ' Disks found.') }else { $data.storageProfile.dataDisks.managedDisk.storageAccountType }
                            $dataSize = if ($data.storageProfile.dataDisks.managedDisk.storageAccountType.count -ge 2) { ($data.storageProfile.dataDisks.diskSizeGB | Measure-Object -Sum).Sum }else { $data.storageProfile.dataDisks.diskSizeGB }
                        }

                        $Tag = @{}
                        $1.tags.psobject.properties | ForEach-Object { $Tag[$_.Name] = $_.Value }

                        if ($null -ne $data.networkProfile.networkInterfaces.id) {
                            foreach ($2 in $data.networkProfile.networkInterfaces.id) {
                                $vmnic = $nic | Where-Object { $_.ID -eq $2 }
                                $vmnsg = $nsg | Where-Object { $_.properties.networkInterfaces.id -eq $2 }
                                foreach ($3 in $vmnic.properties.ipConfigurations.properties) {
                                    if (![string]::IsNullOrEmpty($Tag.Keys) -and $InTag -eq $true) {
                                        foreach ($TagKey in $Tag.Keys) {
                                            $obj = @{
                                                'Subscription'                  = $sub1.name;
                                                'Resource Group'                = $1.RESOURCEGROUP;
                                                'Computer Name'                 = $1.NAME;
                                                'Location'                      = $1.LOCATION;
                                                'Zone'                          = [string]$1.ZONES;
                                                'Availability Set'              = $AVSET;
                                                'VM Size'                       = $data.hardwareProfile.vmSize;
                                                'Image Reference'               = $data.storageProfile.imageReference.publisher;
                                                'Image Version'                 = $data.storageProfile.imageReference.exactVersion;
                                                'SKU'                           = $data.storageProfile.imageReference.sku;
                                                'Admin Username'                = $data.osProfile.adminUsername;
                                                'OS Type'                       = $os;
                                                'Update Management'             = $UpdateMgmt;
                                                'Boot Diagnostics'              = $bootdg;
                                                'Performance Diagnostic Agent'  = if ($azDiag -ne '') { $true }else { $false };
                                                'Azure Monitor'                 = if ($Azinsights -ne '') { $true }else { $false };
                                                'OS Disk Storage Type'          = $data.storageProfile.osDisk.managedDisk.storageAccountType;
                                                'OS Disk Size (GB)'             = $data.storageProfile.osDisk.diskSizeGB;
                                                'Data Disk Storage Type'        = $StorAcc;
                                                'Data Disk Size (GB)'           = $dataSize;
                                                'Power State'                   = $data.extended.instanceView.powerState.displayStatus;
                                                'NIC Name'                      = [string]$vmnic[0].name;
                                                'NIC Type'                      = [string]$vmnic[0].properties.nicType;
                                                'NSG'                           = if ($null -eq $vmnsg.NAME) { 'None' }else { $vmnsg.NAME };
                                                'Enable Accelerated Networking' = [string]$vmnic[0].properties.enableAcceleratedNetworking;
                                                'Enable IP Forwarding'          = [string]$vmnic[0].properties.enableIPForwarding;
                                                'Primary IP'                    = $3.primary;
                                                'Private IP Version'            = $3.privateIPAddressVersion;
                                                'Private IP Address'            = $3.privateIPAddress;
                                                'Private IP Allocation Method'  = $3.privateIPAllocationMethod;
                                                'VM Extensions'                 = $ext;
                                                'Resource U'                    = $ResUCount;
                                                'Tag Name'                      = [string]$TagKey;
                                                'Tag Value'                     = [string]$Tag.$TagKey
                                            }
                                            $tmp += $obj
                                            if ($ResUCount -eq 1) {$ResUCount = 0} 
                                        } 
                                    }
                                    elseif ([string]::IsNullOrEmpty($Tag.Keys) -or $InTag -ne $true) {
                                        $obj = @{
                                            'Subscription'                  = $sub1.name;
                                            'Resource Group'                = $1.RESOURCEGROUP;
                                            'Computer Name'                 = $1.NAME;
                                            'Location'                      = $1.LOCATION;
                                            'Zone'                          = [string]$1.ZONES;
                                            'Availability Set'              = $AVSET;
                                            'VM Size'                       = $data.hardwareProfile.vmSize;
                                            'Image Reference'               = $data.storageProfile.imageReference.publisher;
                                            'Image Version'                 = $data.storageProfile.imageReference.exactVersion;
                                            'SKU'                           = $data.storageProfile.imageReference.sku;
                                            'Admin Username'                = $data.osProfile.adminUsername;
                                            'OS Type'                       = $os;
                                            'Update Management'             = $UpdateMgmt;
                                            'Boot Diagnostics'              = $bootdg;
                                            'Performance Diagnostic Agent'  = if ($azDiag -ne '') { $true }else { $false };
                                            'Azure Monitor'                 = if ($Azinsights -ne '') { $true }else { $false };
                                            'OS Disk Storage Type'          = $data.storageProfile.osDisk.managedDisk.storageAccountType;
                                            'OS Disk Size (GB)'             = $data.storageProfile.osDisk.diskSizeGB;
                                            'Data Disk Storage Type'        = $StorAcc;
                                            'Data Disk Size (GB)'           = $dataSize;
                                            'Power State'                   = $data.extended.instanceView.powerState.displayStatus;
                                            'NIC Name'                      = [string]$vmnic[0].name;
                                            'NIC Type'                      = [string]$vmnic[0].properties.nicType;
                                            'NSG'                           = if ($null -eq $vmnsg.NAME) { 'None' }else { $vmnsg.NAME };
                                            'Enable Accelerated Networking' = [string]$vmnic[0].properties.enableAcceleratedNetworking;
                                            'Enable IP Forwarding'          = [string]$vmnic[0].properties.enableIPForwarding;
                                            'Primary IP'                    = $3.primary;
                                            'Private IP Version'            = $3.privateIPAddressVersion;
                                            'Private IP Address'            = $3.privateIPAddress;
                                            'Private IP Allocation Method'  = $3.privateIPAllocationMethod;
                                            'VM Extensions'                 = $ext;
                                            'Resource U'                    = $ResUCount;
                                            'Tag Name'                      = $null;
                                            'Tag Value'                     = $null
                                        }
                                        $tmp += $obj  
                                        if ($ResUCount -eq 1) {$ResUCount = 0} 
                                    }   
                                }
                            }
                        }
                        elseif ($null -eq $data.networkProfile.networkInterfaces.id) {
                            if (![string]::IsNullOrEmpty($Tag.Keys) -and $InTag -eq $true) {
                                foreach ($TagKey in $Tag.Keys) {
                                    $obj = @{
                                        'Subscription'                  = $sub1.name;
                                        'Resource Group'                = $1.RESOURCEGROUP;
                                        'Computer Name'                 = $1.NAME;
                                        'Location'                      = $1.LOCATION;
                                        'Zone'                          = [string]$1.ZONES;
                                        'Availability Set'              = $AVSET;
                                        'VM Size'                       = $data.hardwareProfile.vmSize;
                                        'Image Reference'               = $data.storageProfile.imageReference.publisher;
                                        'Image Version'                 = $data.storageProfile.imageReference.exactVersion;
                                        'SKU'                           = $data.storageProfile.imageReference.sku;
                                        'Admin Username'                = $data.osProfile.adminUsername;
                                        'OS Type'                       = $os;
                                        'Update Management'             = $UpdateMgmt;
                                        'Boot Diagnostics'              = $bootdg;
                                        'Performance Diagnostic Agent'  = if ($azDiag -ne '') { $true }else { $false };
                                        'Azure Monitor'                 = if ($Azinsights -ne '') { $true }else { $false };
                                        'OS Disk Storage Type'          = $data.storageProfile.osDisk.managedDisk.storageAccountType;
                                        'OS Disk Size (GB)'             = $data.storageProfile.osDisk.diskSizeGB;
                                        'Data Disk Storage Type'        = $StorAcc;
                                        'Data Disk Size (GB)'           = $dataSize;
                                        'Power State'                   = $data.extended.instanceView.powerState.displayStatus;
                                        'NIC Name'                      = $null;
                                        'NIC Type'                      = $null;
                                        'NSG'                           = 'None';
                                        'Enable Accelerated Networking' = $null;
                                        'Enable IP Forwarding'          = $null;
                                        'Primary IP'                    = $null;
                                        'Private IP Version'            = $null;
                                        'Private IP Address'            = $null;
                                        'Private IP Allocation Method'  = $null;
                                        'VM Extensions'                 = $ext;
                                        'Resource U'                    = $ResUCount;
                                        'Tag Name'                      = [string]$TagKey;
                                        'Tag Value'                     = [string]$Tag.$TagKey
                                    }
                                    $tmp += $obj
                                    if ($ResUCount -eq 1) {$ResUCount = 0} 
                                }
                            }
                            elseif ([string]::IsNullOrEmpty($Tag.Keys) -or $InTag -ne $true) {
                                $obj = @{
                                    'Subscription'                  = $sub1.name;
                                    'Resource Group'                = $1.RESOURCEGROUP;
                                    'Computer Name'                 = $1.NAME;
                                    'Location'                      = $1.LOCATION;
                                    'Zone'                          = [string]$1.ZONES;
                                    'Availability Set'              = $AVSET;
                                    'VM Size'                       = $data.hardwareProfile.vmSize;
                                    'Image Reference'               = $data.storageProfile.imageReference.publisher;
                                    'Image Version'                 = $data.storageProfile.imageReference.exactVersion;
                                    'SKU'                           = $data.storageProfile.imageReference.sku;
                                    'Admin Username'                = $data.osProfile.adminUsername;
                                    'OS Type'                       = $os;
                                    'Update Management'             = $UpdateMgmt;
                                    'Boot Diagnostics'              = $bootdg;
                                    'Performance Diagnostic Agent'  = if ($azDiag -ne '') { $true }else { $false };
                                    'Azure Monitor'                 = if ($Azinsights -ne '') { $true }else { $false };
                                    'OS Disk Storage Type'          = $data.storageProfile.osDisk.managedDisk.storageAccountType;
                                    'OS Disk Size (GB)'             = $data.storageProfile.osDisk.diskSizeGB;
                                    'Data Disk Storage Type'        = $StorAcc;
                                    'Data Disk Size (GB)'           = $dataSize;
                                    'Power State'                   = $data.extended.instanceView.powerState.displayStatus;
                                    'NIC Name'                      = $null;
                                    'NIC Type'                      = $null;
                                    'NSG'                           = 'None';
                                    'Enable Accelerated Networking' = $null;
                                    'Enable IP Forwarding'          = $null;
                                    'Primary IP'                    = $null;
                                    'Private IP Version'            = $null;
                                    'Private IP Address'            = $null;
                                    'Private IP Allocation Method'  = $null;
                                    'VM Extensions'                 = $ext;
                                    'Resource U'                    = $ResUCount;
                                    'Tag Name'                      = $null;
                                    'Tag Value'                     = $null
                                }
                                $tmp += $obj
                                if ($ResUCount -eq 1) {$ResUCount = 0} 
                            }   
                        }
                    }    
                    $tmp
                }).AddArgument($($args[0])).AddArgument($($args[1])).AddArgument($($args[2])).AddArgument($($args[3])).AddArgument($($args[4])).AddArgument($($args[5]))

            $VMDisk = ([PowerShell]::Create()).AddScript( { param($Sub, $Intag,$VMDisk)
                    $tmp = @()

                    $disk = $VMDisk
                    $Subs = $Sub

                    foreach ($1 in $disk) {
                        $ResUCount = 1
                        $sub1 = $SUBs | Where-Object { $_.id -eq $1.subscriptionId }
                        $data = $1.PROPERTIES
                        $SKU = $1.SKU 
                        $Tag = @{}
                        $1.tags.psobject.properties | ForEach-Object { $Tag[$_.Name] = $_.Value }
                        if (![string]::IsNullOrEmpty($Tag.Keys) -and $InTag -eq $true) {
                            foreach ($TagKey in $Tag.Keys) {
                                $obj = @{
                                    'Subscription'           = $sub1.name;
                                    'Resource Group'         = $1.RESOURCEGROUP;
                                    'Virtual Machine'        = $1.MANAGEDBY.split('/')[8];
                                    'Disk Name'              = $1.NAME;
                                    'Location'               = $1.LOCATION;
                                    'Zone'                   = [string]$1.ZONES;
                                    'SKU'                    = $SKU.Name;
                                    'Disk Size'              = $data.diskSizeGB;
                                    'Encryption'             = $data.encryption.type;
                                    'OS Type'                = $data.osType;
                                    'Disk IOPS Read / Write' = $data.diskIOPSReadWrite;
                                    'Disk MBps Read / Write' = $data.diskMBpsReadWrite;
                                    'Disk State'             = $data.diskState;
                                    'HyperV Generation'      = $data.hyperVGeneration;
                                    'Resource U'             = $ResUCount;
                                    'Tag Name'               = [string]$TagKey;
                                    'Tag Value'              = [string]$Tag.$TagKey
                                }         
                                $tmp += $obj
                                if ($ResUCount -eq 1) {$ResUCount = 0} 
                            }
                        }
                        else 
                        {
                            $obj = @{
                                'Subscription'           = $sub1.name;
                                'Resource Group'         = $1.RESOURCEGROUP;
                                'Virtual Machine'        = $1.MANAGEDBY.split('/')[8];
                                'Disk Name'              = $1.NAME;
                                'Location'               = $1.LOCATION;
                                'Zone'                   = [string]$1.ZONES;
                                'SKU'                    = $SKU.Name;
                                'Disk Size'              = $data.diskSizeGB;
                                'Encryption'             = $data.encryption.type;
                                'OS Type'                = $data.osType;
                                'Disk IOPS Read / Write' = $data.diskIOPSReadWrite;
                                'Disk MBps Read / Write' = $data.diskMBpsReadWrite;
                                'Disk State'             = $data.diskState;
                                'HyperV Generation'      = $data.hyperVGeneration;
                                'Resource U'             = $ResUCount;
                                'Tag Name'               = $null;
                                'Tag Value'              = $null
                            }         
                            $tmp += $obj
                            if ($ResUCount -eq 1) {$ResUCount = 0} 
                        }
                    }
                    $tmp
                }).AddArgument($($args[0])).AddArgument($($args[1])).AddArgument($($args[6]))


            $SQLVM = ([PowerShell]::Create()).AddScript( { param($Sub, $InTag,$SQLVM)
                    $tmp = @()

                    $sqlvm = $SQLVM
                    $Subs = $Sub

                    foreach ($1 in $sqlvm) {
                        $ResUCount = 1
                        $sub1 = $SUBs | Where-Object { $_.id -eq $1.subscriptionId }
                        $data = $1.PROPERTIES
                        $Tag = @{}
                        $1.tags.psobject.properties | ForEach-Object { $Tag[$_.Name] = $_.Value }
                        if (![string]::IsNullOrEmpty($Tag.Keys) -and $InTag -eq $true) {
                            foreach ($TagKey in $Tag.Keys) {
                                $obj = @{
                                    'Subscription'            = $sub1.name;
                                    'ResourceGroup'           = $1.RESOURCEGROUP;
                                    'Name'                    = $1.NAME;
                                    'Location'                = $1.LOCATION;
                                    'Zone'                    = $1.ZONES;
                                    'SQL Server License Type' = $data.sqlServerLicenseType;
                                    'SQL Image'               = $data.sqlImageOffer;
                                    'SQL Management'          = $data.sqlManagement;
                                    'SQL Image Sku'           = $data.sqlImageSku;
                                    'Resource U'              = $ResUCount;
                                    'Tag Name'                = [string]$TagKey;
                                    'Tag Value'               = [string]$Tag.$TagKey
                                }
                                $tmp += $obj
                                if ($ResUCount -eq 1) {$ResUCount = 0} 
                            }
                        }
                        else 
                            {
                                $obj = @{
                                    'Subscription'            = $sub1.name;
                                    'ResourceGroup'           = $1.RESOURCEGROUP;
                                    'Name'                    = $1.NAME;
                                    'Location'                = $1.LOCATION;
                                    'Zone'                    = $1.ZONES;
                                    'SQL Server License Type' = $data.sqlServerLicenseType;
                                    'SQL Image'               = $data.sqlImageOffer;
                                    'SQL Management'          = $data.sqlManagement;
                                    'SQL Image Sku'           = $data.sqlImageSku;
                                    'Resource U'              = $ResUCount;
                                    'Tag Name'                = $null;
                                    'Tag Value'               = $null
                                }
                                $tmp += $obj
                                if ($ResUCount -eq 1) {$ResUCount = 0} 
                            }
                    }
                    $tmp
                }).AddArgument($($args[0])).AddArgument($($args[1])).AddArgument($($args[7]))



            $WebServerFarm = ([PowerShell]::Create()).AddScript( { param($Sub, $Intag,$SERVERFARM)
                    $tmp = @()

                    $webfarm = $SERVERFARM
                    $Subs = $Sub

                    foreach ($1 in $webfarm) {
                        $ResUCount = 1
                        $sub1 = $SUBs | Where-Object { $_.id -eq $1.subscriptionId }
                        $data = $1.PROPERTIES
                        $sku = $1.SKU
                        $Tag = @{}
                        $1.tags.psobject.properties | ForEach-Object { $Tag[$_.Name] = $_.Value }
                        if (![string]::IsNullOrEmpty($Tag.Keys) -and $InTag -eq $true) {
                            foreach ($TagKey in $Tag.Keys) {
                                $obj = @{
                                    'Subscription'        = $sub1.name;
                                    'Resource Group'      = $1.RESOURCEGROUP;
                                    'Name'                = $1.NAME;
                                    'Location'            = $1.LOCATION;
                                    'SKU'                 = $sku.name;
                                    'SKU Family'          = $sku.family;
                                    'Tier'                = $sku.tier;
                                    'Capacity'            = $sku.capacity;
                                    'Workers'             = $data.currentNumberOfWorkers;
                                    'Compute Mode'        = $data.computeMode;
                                    'Max Elastic Workers' = $data.maximumElasticWorkerCount;
                                    'Max Workers'         = $data.maximumNumberOfWorkers;
                                    'Worker Kind'         = $data.kind;
                                    'Number Of Sites'     = $data.numberOfSites;
                                    'Plan Name'           = $data.planName;
                                    'Resource U'          = $ResUCount;
                                    'Tag Name'            = [string]$TagKey;
                                    'Tag Value'           = [string]$Tag.$TagKey
                                }
                                $tmp += $obj
                                if ($ResUCount -eq 1) {$ResUCount = 0} 
                            }
                        }
                        else {
                            $obj = @{
                                'Subscription'        = $sub1.name;
                                'Resource Group'      = $1.RESOURCEGROUP;
                                'Name'                = $1.NAME;
                                'Location'            = $1.LOCATION;
                                'SKU'                 = $sku.name;
                                'SKU Family'          = $sku.family;
                                'Tier'                = $sku.tier;
                                'Capacity'            = $sku.capacity;
                                'Workers'             = $data.currentNumberOfWorkers;
                                'Compute Mode'        = $data.computeMode;
                                'Max Elastic Workers' = $data.maximumElasticWorkerCount;
                                'Max Workers'         = $data.maximumNumberOfWorkers;
                                'Worker Kind'         = $data.kind;
                                'Number Of Sites'     = $data.numberOfSites;
                                'Plan Name'           = $data.planName;
                                'Resource U'          = $ResUCount;
                                'Tag Name'            = $null;
                                'Tag Value'           = $null
                            }
                            $tmp += $obj
                            if ($ResUCount -eq 1) {$ResUCount = 0} 
                        }    
                    }
                    $tmp
                }).AddArgument($($args[0])).AddArgument($($args[1])).AddArgument($($args[8]))



            $AKS = ([PowerShell]::Create()).AddScript( { param($Sub, $Intag,$AKS)
                    $tmp = @()

                    $AKS = $AKS
                    $Subs = $Sub

                    foreach ($1 in $AKS) {
                        $ResUCount = 1
                        $sub1 = $SUBs | Where-Object { $_.id -eq $1.subscriptionId }
                        $data = $1.PROPERTIES
                        if ($data.kubernetesVersion -lt 1.17) {
                            $ver = 'UNSUPPORTED'
                        }
                        else {
                            $ver = 'SUPPORTED'
                        }
                        $Tag = @{}
                        $1.tags.psobject.properties | ForEach-Object { $Tag[$_.Name] = $_.Value }
                        foreach ($2 in $data.agentPoolProfiles) {
                            if (![string]::IsNullOrEmpty($Tag.Keys) -and $InTag -eq $true) {
                                foreach ($TagKey in $Tag.Keys) {
                                    $obj = @{
                                        'Subscription'               = $sub1.name;
                                        'Resource Group'             = $1.RESOURCEGROUP;
                                        'Clusters'                   = $1.NAME;
                                        'Location'                   = $1.LOCATION;
                                        'Kubernetes Version'         = $data.kubernetesVersion;
                                        'Kubernetes Version Support' = $ver;
                                        'Role-Based Access Control'  = $data.enableRBAC;
                                        'AAD Enabled'                = if ($data.aadProfile) { $true }else { $false };
                                        'Network Type'               = $data.networkProfile.networkPlugin;
                                        'Outbound Type'              = $data.networkProfile.outboundType;
                                        'LoadBalancer Sku'           = $data.networkProfile.loadBalancerSku;
                                        'Docker Pod Cidr'            = $data.networkProfile.podCidr;
                                        'Service Cidr'               = $data.networkProfile.serviceCidr;
                                        'Docker Bridge Cidr'         = $data.networkProfile.dockerBridgeCidr;                   
                                        'Network DNS Service IP'     = $data.networkProfile.dnsServiceIP;
                                        'FQDN'                       = $data.fqdn
                                        'HTTP Application Routing'   = if ($data.addonProfiles.httpapplicationrouting.enabled) { $true }else { $false };
                                        'Node Pool Name'             = $2.name;
                                        'Pool Profile Type'          = $2.type;
                                        'Pool OS'                    = $2.osType;
                                        'Node Size'                  = $2.vmSize;
                                        'OS Disk Size (GB)'          = $2.osDiskSizeGB;
                                        'Nodes'                      = $2.count;
                                        'Autoscale'                  = $2.enableAutoScaling;
                                        'Autoscale Max'              = $2.maxCount;
                                        'Autoscale Min'              = $2.minCount;
                                        'Max Pods Per Node'          = $2.maxPods;
                                        'Orchestrator Version'       = $2.orchestratorVersion;
                                        'Enable Node Public IP'      = $2.enableNodePublicIP;
                                        'Resource U'                 = $ResUCount;
                                        'Tag Name'                   = [string]$TagKey;
                                        'Tag Value'                  = [string]$Tag.$TagKey
                                    }
                                    $tmp += $obj
                                    if ($ResUCount -eq 1) {$ResUCount = 0} 
                                }
                            }
                            else {
                                $obj = @{
                                    'Subscription'               = $sub1.name;
                                    'Resource Group'             = $1.RESOURCEGROUP;
                                    'Clusters'                   = $1.NAME;
                                    'Location'                   = $1.LOCATION;
                                    'Kubernetes Version'         = $data.kubernetesVersion;
                                    'Kubernetes Version Support' = $ver;
                                    'Role-Based Access Control'  = $data.enableRBAC;
                                    'AAD Enabled'                = if ($data.aadProfile) { $true }else { $false };
                                    'Network Type'               = $data.networkProfile.networkPlugin;
                                    'Outbound Type'              = $data.networkProfile.outboundType;
                                    'LoadBalancer Sku'           = $data.networkProfile.loadBalancerSku;
                                    'Docker Pod Cidr'            = $data.networkProfile.podCidr;
                                    'Service Cidr'               = $data.networkProfile.serviceCidr;
                                    'Docker Bridge Cidr'         = $data.networkProfile.dockerBridgeCidr;                   
                                    'Network DNS Service IP'     = $data.networkProfile.dnsServiceIP;
                                    'FQDN'                       = $data.fqdn
                                    'HTTP Application Routing'   = if ($data.addonProfiles.httpapplicationrouting.enabled) { $true }else { $false };
                                    'Node Pool Name'             = $2.name;
                                    'Pool Profile Type'          = $2.type;
                                    'Pool OS'                    = $2.osType;
                                    'Node Size'                  = $2.vmSize;
                                    'OS Disk Size (GB)'          = $2.osDiskSizeGB;
                                    'Nodes'                      = $2.count;
                                    'Autoscale'                  = $2.enableAutoScaling;
                                    'Autoscale Max'              = $2.maxCount;
                                    'Autoscale Min'              = $2.minCount;
                                    'Max Pods Per Node'          = $2.maxPods;
                                    'Orchestrator Version'       = $2.orchestratorVersion;
                                    'Enable Node Public IP'      = $2.enableNodePublicIP;
                                    'Resource U'                 = $ResUCount;
                                    'Tag Name'                   = $null;
                                    'Tag Value'                  = $null
                                }
                                $tmp += $obj
                                if ($ResUCount -eq 1) {$ResUCount = 0} 
                            }
                        }
                    }
                    $tmp
                }).AddArgument($($args[0])).AddArgument($($args[1])).AddArgument($($args[9]))


            $VMSS = ([PowerShell]::Create()).AddScript( { param($Sub, $Intag,$vmss)
                    $tmp = @()

                    $vmss = $vmss
                    $Subs = $Sub

                    foreach ($1 in $vmss) {
                        $ResUCount = 1
                        $sub1 = $SUBs | Where-Object { $_.id -eq $1.subscriptionId }
                        $data = $1.PROPERTIES
                        $Tag = @{}
                        $1.tags.psobject.properties | ForEach-Object { $Tag[$_.Name] = $_.Value }
                        foreach ($2 in $data.virtualMachineProfile.networkProfile.networkInterfaceConfigurations) {
                            if (![string]::IsNullOrEmpty($Tag.Keys) -and $InTag -eq $true) {
                                foreach ($TagKey in $Tag.Keys) {
                                    $obj = @{
                                        'Subscription'                  = $sub1.name;
                                        'Resource Group'                = $1.RESOURCEGROUP;
                                        'Name'                          = $1.NAME;
                                        'Location'                      = $1.LOCATION;
                                        'SKU Tier'                      = $1.sku.tier;
                                        'Fault Domain'                  = $data.platformFaultDomainCount;
                                        'Upgrade Policy'                = $data.upgradePolicy.mode;
                                        'Capacity'                      = $1.sku.capacity;
                                        'VM Size'                       = $1.sku.name;
                                        'VM OS'                         = if ($null -eq $data.virtualMachineProfile.osProfile.LinuxConfiguration) { 'Windows' }else { 'Linux' };
                                        'Network Interface Name'        = $2.name;
                                        'Enable Accelerated Networking' = $2.properties.enableAcceleratedNetworking;
                                        'Enable IP Forwarding'          = $2.properties.enableIPForwarding;
                                        'Admin Username'                = $data.virtualMachineProfile.osProfile.adminUsername;
                                        'VM Name Prefix'                = $data.virtualMachineProfile.osProfile.computerNamePrefix;
                                        'Resource U'                    = $ResUCount;
                                        'Tag Name'                      = [string]$TagKey;
                                        'Tag Value'                     = [string]$Tag.$TagKey
                                    }
                                    $tmp += $obj
                                    if ($ResUCount -eq 1) {$ResUCount = 0} 
                                }
                            }
                            else { 
                                $obj = @{
                                    'Subscription'                  = $sub1.name;
                                    'Resource Group'                = $1.RESOURCEGROUP;
                                    'Name'                          = $1.NAME;
                                    'Location'                      = $1.LOCATION;
                                    'SKU Tier'                      = $1.sku.tier;
                                    'Fault Domain'                  = $data.platformFaultDomainCount;
                                    'Upgrade Policy'                = $data.upgradePolicy.mode;
                                    'Capacity'                      = $1.sku.capacity;
                                    'VM Size'                       = $1.sku.name;
                                    'VM OS'                         = if ($null -eq $data.virtualMachineProfile.osProfile.LinuxConfiguration) { 'Windows' }else { 'Linux' };
                                    'Network Interface Name'        = $2.name;
                                    'Enable Accelerated Networking' = $2.properties.enableAcceleratedNetworking;
                                    'Enable IP Forwarding'          = $2.properties.enableIPForwarding;
                                    'Admin Username'                = $data.virtualMachineProfile.osProfile.adminUsername;
                                    'VM Name Prefix'                = $data.virtualMachineProfile.osProfile.computerNamePrefix;
                                    'Resource U'                    = $ResUCount;
                                    'Tag Name'                      = $null;
                                    'Tag Value'                     = $null
                                }
                                $tmp += $obj
                                if ($ResUCount -eq 1) {$ResUCount = 0} 
                            }
                        }
                    }
                    $tmp
                }).AddArgument($($args[0])).AddArgument($($args[1])).AddArgument($($args[10]))


            $CON = ([PowerShell]::Create()).AddScript( { param($Sub, $Intag,$con)
                    $tmp = @()

                    $con = $con
                    $Subs = $Sub

                    foreach ($1 in $con) {
                        $ResUCount = 1
                        $sub1 = $SUBs | Where-Object { $_.id -eq $1.subscriptionId }
                        $data = $1.PROPERTIES
                        $Tag = @{}
                        $1.tags.psobject.properties | ForEach-Object { $Tag[$_.Name] = $_.Value }
                        foreach ($2 in $data.containers) {
                            if (![string]::IsNullOrEmpty($Tag.Keys) -and $InTag -eq $true) {
                                foreach ($TagKey in $Tag.Keys) {
                                    $obj = @{
                                        'Subscription'        = $sub1.name;
                                        'Resource Group'      = $1.RESOURCEGROUP;
                                        'Instance Name'       = $1.NAME;
                                        'Location'            = $1.LOCATION;
                                        'Instance OS Type'    = $data.osType;
                                        'Container Name'      = $2.name;
                                        'Container State'     = $2.properties.instanceView.currentState.state;
                                        'Container Image'     = [string]$2.properties.image;
                                        'Restart Count'       = $2.properties.instanceView.restartCount;
                                        'Start Time'          = $2.properties.instanceView.currentState.startTime;
                                        'Command'             = [string]$2.properties.command;
                                        'Request CPU'         = $2.properties.resources.requests.cpu;
                                        'Request Memory (GB)' = $2.properties.resources.requests.memoryInGB;
                                        'IP'                  = $data.ipAddress.ip;
                                        'Protocol'            = [string]$2.properties.ports.protocol;
                                        'Port'                = [string]$2.properties.ports.port;
                                        'Resource U'          = $ResUCount;
                                        'Tag Name'            = [string]$TagKey;
                                        'Tag Value'           = [string]$Tag.$TagKey
                                    }
                                    $tmp += $obj
                                    if ($ResUCount -eq 1) {$ResUCount = 0} 
                                }
                            }
                            else {
                                $obj = @{
                                    'Subscription'        = $sub1.name;
                                    'Resource Group'      = $1.RESOURCEGROUP;
                                    'Instance Name'       = $1.NAME;
                                    'Location'            = $1.LOCATION;
                                    'Instance OS Type'    = $data.osType;
                                    'Container Name'      = $2.name;
                                    'Container State'     = $2.properties.instanceView.currentState.state;
                                    'Container Image'     = [string]$2.properties.image;
                                    'Restart Count'       = $2.properties.instanceView.restartCount;
                                    'Start Time'          = $2.properties.instanceView.currentState.startTime;
                                    'Command'             = [string]$2.properties.command;
                                    'Request CPU'         = $2.properties.resources.requests.cpu;
                                    'Request Memory (GB)' = $2.properties.resources.requests.memoryInGB;
                                    'IP'                  = $data.ipAddress.ip;
                                    'Protocol'            = [string]$2.properties.ports.protocol;
                                    'Port'                = [string]$2.properties.ports.port;
                                    'Resource U'          = $ResUCount;
                                    'Tag Name'            = $null;
                                    'Tag Value'           = $null
                                }
                                $tmp += $obj
                                if ($ResUCount -eq 1) {$ResUCount = 0} 
                            }
                        }
                    }
                    $tmp
                }).AddArgument($($args[0])).AddArgument($($args[1])).AddArgument($($args[11]))



            $SQLSRV = ([PowerShell]::Create()).AddScript( { param($Sub, $InTag,$SQLSERVER)
                    $tmp = @()

                    $SQLServer = $SQLSERVER
                    $Subs = $Sub
    
                    foreach ($1 in $SQLServer) {
                        $ResUCount = 1
                        $sub1 = $SUBs | Where-Object { $_.id -eq $1.subscriptionId }
                        $data = $1.PROPERTIES
                        $Tag = @{}
                        $1.tags.psobject.properties | ForEach-Object { $Tag[$_.Name] = $_.Value }
                        if (![string]::IsNullOrEmpty($Tag.Keys) -and $InTag -eq $true) {
                            foreach ($TagKey in $Tag.Keys) {
                                $obj = @{
                                    'Subscription'          = $sub1.name;
                                    'Resource Group'        = $1.RESOURCEGROUP;
                                    'Name'                  = $1.NAME;
                                    'Location'              = $1.LOCATION;
                                    'Kind'                  = $1.kind;
                                    'Admin Login'           = $data.administratorLogin;
                                    'FQDN'                  = $data.fullyQualifiedDomainName;
                                    'Public Network Access' = $data.publicNetworkAccess;
                                    'State'                 = $data.state;
                                    'Version'               = $data.version;
                                    'Resource U'            = $ResUCount;
                                    'Tag Name'              = [string]$TagKey;
                                    'Tag Value'             = [string]$Tag.$TagKey
                                }
                                $tmp += $obj
                                if ($ResUCount -eq 1) {$ResUCount = 0} 
                            }
                        }
                        else {
                            $obj = @{
                                'Subscription'          = $sub1.name;
                                'Resource Group'        = $1.RESOURCEGROUP;
                                'Name'                  = $1.NAME;
                                'Location'              = $1.LOCATION;
                                'Kind'                  = $1.kind;
                                'Admin Login'           = $data.administratorLogin;
                                'FQDN'                  = $data.fullyQualifiedDomainName;
                                'Public Network Access' = $data.publicNetworkAccess;
                                'State'                 = $data.state;
                                'Version'               = $data.version;
                                'Resource U'            = $ResUCount;
                                'Tag Name'              = $null;
                                'Tag Value'             = $null
                            }
                            $tmp += $obj
                            if ($ResUCount -eq 1) {$ResUCount = 0} 
                        }
                    }
                    $tmp
                }).AddArgument($($args[0])).AddArgument($($args[1])).AddArgument($($args[12]))

            $IOT = ([PowerShell]::Create()).AddScript( { param($Sub, $Intag,$IOT)
                    $tmp = @()

                    $Subs = $Sub
    
                    foreach ($1 in $IOT) {
                        $ResUCount = 1
                        $sub1 = $SUBs | Where-Object { $_.id -eq $1.subscriptionId }
                        $data = $1.PROPERTIES
                        $Tag = @{}
                        $1.tags.psobject.properties | ForEach-Object { $Tag[$_.Name] = $_.Value }
                        if (![string]::IsNullOrEmpty($Tag.Keys) -and $InTag -eq $true) {
                            foreach ($TagKey in $Tag.Keys) {
                                $obj = @{
                                    'Subscription'          = $sub1.name;
                                    'Resource Group'        = $1.RESOURCEGROUP;
                                    'Name'                  = $1.NAME;
                                    'HostName'              = $data.hostname;
                                    'State'                 = $data.state;
                                    'SKU'                   = $1.sku.name;
                                    'SKU Tier'              = $1.sku.tier;
                                    'SKU Capacity'          = $1.sku.capacity;
                                    'Features'              = $data.features;
                                    'Enable File Upload Notifications' = $data.enableFileUploadNotifications;
                                    'Default TTL As ISO8601' = $data.cloudToDevice.defaultTtlAsIso8601;
                                    'Max Delivery Count'    = $data.cloudToDevice.maxDeliveryCount;
                                    'EventHubs Endpoint'    = $data.eventHubEndpoints.events.endpoint;
                                    'EventHubs Partition Count' = $data.eventHubEndpoints.events.partitionCount;
                                    'EventHubs Path'        = $data.eventHubEndpoints.events.path;
                                    'EventHubs Retention Days' = $data.eventHubEndpoints.events.retentionTimeInDays;
                                    'Locations'             = [string]$data.locations.location;
                                    'Resource U'              = $ResUCount;
                                    'Tag Name'                = [string]$TagKey;
                                    'Tag Value'               = [string]$Tag.$TagKey
                                }
                                $tmp += $obj
                                if ($ResUCount -eq 1) {$ResUCount = 0} 
                            }
                        }
                        else {
                            $obj = @{
                                'Subscription'          = $sub1.name;
                                'Resource Group'        = $1.RESOURCEGROUP;
                                'Name'                  = $1.NAME;
                                'HostName'              = $data.hostname;
                                'State'                 = $data.state;
                                'SKU'                   = $1.sku.name;
                                'SKU Tier'              = $1.sku.tier;
                                'SKU Capacity'          = $1.sku.capacity;
                                'Features'              = $data.features;
                                'Enable File Upload Notifications' = $data.enableFileUploadNotifications;
                                'Default TTL As ISO8601' = $data.cloudToDevice.defaultTtlAsIso8601;
                                'Max Delivery Count'    = $data.cloudToDevice.maxDeliveryCount;
                                'EventHubs Endpoint'    = $data.eventHubEndpoints.events.endpoint;
                                'EventHubs Partition Count' = $data.eventHubEndpoints.events.partitionCount;
                                'EventHubs Path'        = $data.eventHubEndpoints.events.path;
                                'EventHubs Retention Days' = $data.eventHubEndpoints.events.retentionTimeInDays;
                                'Locations'             = [string]$data.locations.location;
                                'Resource U'            = $ResUCount;
                                'Tag Name'              = $null;
                                'Tag Value'             = $null
                            }
                            $tmp += $obj
                            if ($ResUCount -eq 1) {$ResUCount = 0} 
                        }
                    }
                    $tmp
                }).AddArgument($($args[0])).AddArgument($($args[1])).AddArgument($($args[13]))


            $jobVM = $VM.BeginInvoke()
            $jobVMDisk = $VMDisk.BeginInvoke()
            $jobSQLVM = $SQLVM.BeginInvoke()
            $jobSERVERFARM = $WebServerFarm.BeginInvoke()
            $jobAKS = $AKS.BeginInvoke()
            $jobVMSS = $VMSS.BeginInvoke()
            $jobCON = $CON.BeginInvoke()
            $jobSQLSRV = $SQLSRV.BeginInvoke()
            $jobIOT = $IOT.BeginInvoke()
    
            $job += $jobVM
            $job += $jobVMDisk
            $job += $jobSQLVM
            $job += $jobSERVERFARM
            $job += $jobAKS
            $job += $jobVMSS
            $job += $jobCON
            $job += $jobSQLSRV
            $job += $jobIOT

            while ($Job.Runspace.IsCompleted -contains $false) {}

            $VMS = $VM.EndInvoke($jobVM)
            $VMDiskS = $VMDisk.EndInvoke($jobVMDisk)
            $SQLVMS = $SQLVM.EndInvoke($jobSQLVM)
            $WebServerFarmS = $WebServerFarm.EndInvoke($jobSERVERFARM)
            $AKSS = $AKS.EndInvoke($jobAKS)
            $VMSSS = $VMSS.EndInvoke($jobVMSS)
            $CONS = $CON.EndInvoke($jobCON)
            $SQLSRVS = $SQLSRV.EndInvoke($jobSQLSRV)
            $IOTS = $IOT.EndInvoke($jobIOT)
    
            $VM.Dispose()
            $VMDisk.Dispose()
            $SQLVM.Dispose()
            $WebServerFarm.Dispose()
            $AKS.Dispose()
            $VMSS.Dispose()
            $CON.Dispose()
            $SQLSRV.Dispose()
            $IOT.Dispose()

            $AzCompute = @{
                'VM'         = $VMS;
                'VMDisk'     = $VMDiskS;
                'SQLVM'      = $SQLVMS;
                'SERVERFARM' = $WebServerFarmS;
                'AKS'        = $AKSS;
                'VMSS'       = $VMSSS;
                'CON'        = $CONS;
                'SQLSERVER'  = $SQLSRVS;
                'IOT'        = $IOTS
            }

            $AzCompute

        } -ArgumentList $SUBs,$InTag, $VM, $VMNIC, $NSG, $VMExp, $VMDisk, $SQLVM, $SERVERFARM, $AKS, $VMSS, $CON, $SQLSERVER, $IOT   | Out-Null


        <######################################################### NETWORK RESOURCE GROUP JOB ######################################################################>

        Start-Job -Name 'Network' -ScriptBlock {

            $job = @()

            $VNET = ([PowerShell]::Create()).AddScript( { param($Sub, $InTag,$VNet)
                    $tmp = @()

                    $vnet = $VNet
                    $Subs = $Sub

                    foreach ($1 in $vnet) {
                        $ResUCount = 1
                        $sub1 = $SUBs | Where-Object { $_.id -eq $1.subscriptionId }
                        $data = $1.PROPERTIES
                        $Tag = @{}
                        $1.tags.psobject.properties | ForEach-Object { $Tag[$_.Name] = $_.Value }
                        foreach ($2 in $data.addressSpace.addressPrefixes) {
                            foreach ($3 in $data.subnets) {
                                if (![string]::IsNullOrEmpty($Tag.Keys) -and $InTag -eq $true) {
                                    foreach ($TagKey in $Tag.Keys) {
                                            $obj = @{
                                                'Subscription'                                 = $sub1.name;
                                                'Resource Group'                               = $1.RESOURCEGROUP;
                                                'Name'                                         = $1.NAME;
                                                'Location'                                     = $1.LOCATION;
                                                'Zone'                                         = $1.ZONES;
                                                'Address Space'                                = $2;
                                                'Enable DDOS Protection'                       = $data.enableDdosProtection;
                                                'Enable VM Protection'                         = $data.enableVmProtection;
                                                'Subnet Name'                                  = $3.name;
                                                'Subnet Prefix'                                = $3.properties.addressPrefix;
                                                'Subnet Private Link Service Network Policies' = $3.properties.privateLinkServiceNetworkPolicies;
                                                'Subnet Private Endpoint Network Policies'     = $3.properties.privateEndpointNetworkPolicies;
                                                'Resource U'                                   = $ResUCount;
                                                'Tag Name'                                     = [string]$TagKey;
                                                'Tag Value'                                    = [string]$Tag.$TagKey
                                            }
                                            $tmp += $obj
                                            if ($ResUCount -eq 1) {$ResUCount = 0} 
                                        }
                                    }
                                    else {
                                        $obj = @{
                                            'Subscription'                                 = $sub1.name;
                                            'Resource Group'                               = $1.RESOURCEGROUP;
                                            'Name'                                         = $1.NAME;
                                            'Location'                                     = $1.LOCATION;
                                            'Zone'                                         = $1.ZONES;
                                            'Address Space'                                = $2;
                                            'Enable DDOS Protection'                       = $data.enableDdosProtection;
                                            'Enable VM Protection'                         = $data.enableVmProtection;
                                            'Subnet Name'                                  = $3.name;
                                            'Subnet Prefix'                                = $3.properties.addressPrefix;
                                            'Subnet Private Link Service Network Policies' = $3.properties.privateLinkServiceNetworkPolicies;
                                            'Subnet Private Endpoint Network Policies'     = $3.properties.privateEndpointNetworkPolicies;
                                            'Resource U'                                   = $ResUCount;
                                            'Tag Name'                                     = $null;
                                            'Tag Value'                                    = $null
                                        }
                                        $tmp += $obj
                                        if ($ResUCount -eq 1) {$ResUCount = 0} 
                                    }
                            }
                        }
                    }
                    $tmp
                }).AddArgument($($args[0])).AddArgument($($args[1])).AddArgument($($args[2]))


            $VNETGTW = ([PowerShell]::Create()).AddScript( { param($Sub, $InTag,$VNETGTW)
                    $tmp = @()

                    $vgtws = $VNETGTW
                    $Subs = $Sub

                    foreach ($1 in $vgtws) {
                        $ResUCount = 1
                        $sub1 = $SUBs | Where-Object { $_.id -eq $1.subscriptionId }
                        $data = $1.PROPERTIES
                        $Tag = @{}
                        $1.tags.psobject.properties | ForEach-Object { $Tag[$_.Name] = $_.Value }
                        if (![string]::IsNullOrEmpty($Tag.Keys) -and $InTag -eq $true) {
                            foreach ($TagKey in $Tag.Keys) {  
                                    $obj = @{
                                        'Subscription'           = $sub1.name;
                                        'Resource Group'         = $1.RESOURCEGROUP;
                                        'Name'                   = $1.NAME;
                                        'Location'               = $1.LOCATION;
                                        'SKU'                    = $data.sku.tier;
                                        'Active-active mode'     = $data.activeActive; 
                                        'Gateway Type'           = $data.gatewayType;
                                        'Gateway Generation'     = $data.vpnGatewayGeneration;
                                        'VPN Type'               = $data.vpnType;
                                        'Enable Private Address' = $data.enablePrivateIpAddress;
                                        'Enable BGP'             = $data.enableBgp;
                                        'BGP ASN'                = $data.bgpsettings.asn;
                                        'BGP Peering Address'    = $data.bgpSettings.bgpPeeringAddress;
                                        'BGP Peer Weight'        = $data.bgpSettings.peerWeight;
                                        'Gateway Public IP'      = [string]$data.ipConfigurations.properties.publicIPAddress.id.split("/")[8];
                                        'Gateway Subnet Name'    = [string]$data.ipConfigurations.properties.subnet.id.split("/")[8];
                                        'Resource U'             = $ResUCount;
                                        'Tag Name'               = [string]$TagKey;
                                        'Tag Value'              = [string]$Tag.$TagKey
                                    }
                                    $tmp += $obj
                                    if ($ResUCount -eq 1) {$ResUCount = 0} 
                                }
                            }
                            else {
                                $obj = @{
                                    'Subscription'           = $sub1.name;
                                    'Resource Group'         = $1.RESOURCEGROUP;
                                    'Name'                   = $1.NAME;
                                    'Location'               = $1.LOCATION;
                                    'SKU'                    = $data.sku.tier;
                                    'Active-active mode'     = $data.activeActive; 
                                    'Gateway Type'           = $data.gatewayType;
                                    'Gateway Generation'     = $data.vpnGatewayGeneration;
                                    'VPN Type'               = $data.vpnType;
                                    'Enable Private Address' = $data.enablePrivateIpAddress;
                                    'Enable BGP'             = $data.enableBgp;
                                    'BGP ASN'                = $data.bgpsettings.asn;
                                    'BGP Peering Address'    = $data.bgpSettings.bgpPeeringAddress;
                                    'BGP Peer Weight'        = $data.bgpSettings.peerWeight;
                                    'Gateway Public IP'      = [string]$data.ipConfigurations.properties.publicIPAddress.id.split("/")[8];
                                    'Gateway Subnet Name'    = [string]$data.ipConfigurations.properties.subnet.id.split("/")[8];
                                    'Resource U'             = $ResUCount;
                                    'Tag Name'               = $null;
                                    'Tag Value'              = $null
                                }
                                $tmp += $obj
                                if ($ResUCount -eq 1) {$ResUCount = 0} 
                            }
                    }
                    $tmp
                }).AddArgument($($args[0])).AddArgument($($args[1])).AddArgument($($args[3]))


            $PIP = ([PowerShell]::Create()).AddScript( { param($Sub, $InTag,$PIP)
                    $tmp = @()

                    $pubip = $PIP
                    $Subs = $Sub

                    foreach ($1 in $pubip) {
                        $ResUCount = 1
                        $sub1 = $SUBs | Where-Object { $_.id -eq $1.subscriptionId }
                        $data = $1.PROPERTIES
                        $Tag = @{}
                        if(!($data.ipConfiguration.id)) {$Use = 'Underutilized'} else {$Use = 'Utilized'}
                        $1.tags.psobject.properties | ForEach-Object { $Tag[$_.Name] = $_.Value }
                        if ($null -ne $data.ipConfiguration.id -and ![string]::IsNullOrEmpty($Tag.Keys) -and $InTag -eq $true) {
                            foreach ($TagKey in $Tag.Keys) { 
                                    $obj = @{
                                        'Subscription'             = $sub1.name;
                                        'Resource Group'           = $1.RESOURCEGROUP;
                                        'Name'                     = $1.NAME;
                                        'SKU'                      = $1.SKU.Name;
                                        'Location'                 = $1.LOCATION;
                                        'Type'                     = $data.publicIPAllocationMethod;
                                        'Version'                  = $data.publicIPAddressVersion;
                                        'IP Address'               = $data.ipAddress;
                                        'Use'                      = $Use;
                                        'Associated Resource'      = $data.ipConfiguration.id.split('/')[8];
                                        'Associated Resource Type' = $data.ipConfiguration.id.split('/')[7];
                                        'Resource U'               = $ResUCount;
                                        'Tag Name'                 = [string]$TagKey;
                                        'Tag Value'                = [string]$Tag.$TagKey
                                    }
                                    $tmp += $obj
                                    if ($ResUCount -eq 1) {$ResUCount = 0} 
                                }
                        }
                        elseif ($null -ne $data.ipConfiguration.id -and $InTag -ne $true) { 
                            $obj = @{
                                'Subscription'             = $sub1.name;
                                'Resource Group'           = $1.RESOURCEGROUP;
                                'Name'                     = $1.NAME;
                                'SKU'                      = $1.SKU.Name;
                                'Location'                 = $1.LOCATION;
                                'Type'                     = $data.publicIPAllocationMethod;
                                'Version'                  = $data.publicIPAddressVersion;
                                'IP Address'               = $data.ipAddress;
                                'Use'                      = $Use;
                                'Associated Resource'      = $data.ipConfiguration.id.split('/')[8];
                                'Associated Resource Type' = $data.ipConfiguration.id.split('/')[7];
                                'Resource U'               = $ResUCount;
                                'Tag Name'                 = $null;
                                'Tag Value'                = $null
                            }
                            $tmp += $obj
                            if ($ResUCount -eq 1) {$ResUCount = 0} 
                        }
                        elseif ($null -eq $data.ipConfiguration.id -and ![string]::IsNullOrEmpty($Tag.Keys) -and $InTag -eq $true) {
                            foreach ($TagKey in $Tag.Keys) {  
                                    $obj = @{
                                        'Subscription'             = $sub1.name;
                                        'Resource Group'           = $1.RESOURCEGROUP;
                                        'Name'                     = $1.NAME;
                                        'SKU'                      = $1.SKU.Name;
                                        'Location'                 = $1.LOCATION;
                                        'Type'                     = $data.publicIPAllocationMethod;
                                        'Version'                  = $data.publicIPAddressVersion;
                                        'IP Address'               = $data.ipAddress;
                                        'Use'                      = $Use;
                                        'Associated Resource'      = $null;
                                        'Associated Resource Type' = $null;
                                        'Resource U'               = $ResUCount;
                                        'Tag Name'                 = [string]$TagKey;
                                        'Tag Value'                = [string]$Tag.$TagKey
                                    }
                                    $tmp += $obj
                                    if ($ResUCount -eq 1) {$ResUCount = 0} 
                                }
                        }
                        elseif ($null -eq $data.ipConfiguration.id -and $InTag -ne $true) {  
                            $obj = @{
                                'Subscription'             = $sub1.name;
                                'Resource Group'           = $1.RESOURCEGROUP;
                                'Name'                     = $1.NAME;
                                'SKU'                      = $1.SKU.Name;
                                'Location'                 = $1.LOCATION;
                                'Type'                     = $data.publicIPAllocationMethod;
                                'Version'                  = $data.publicIPAddressVersion;
                                'IP Address'               = $data.ipAddress;
                                'Use'                      = $Use;
                                'Associated Resource'      = $null;
                                'Associated Resource Type' = $null;
                                'Resource U'               = $ResUCount;
                                'Tag Name'                 = $null;
                                'Tag Value'                = $null
                            }
                            $tmp += $obj
                            if ($ResUCount -eq 1) {$ResUCount = 0} 
                        }
                    }
                    $tmp
                }).AddArgument($($args[0])).AddArgument($($args[1])).AddArgument($($args[4]))


            $LB = ([PowerShell]::Create()).AddScript( { param($Sub, $InTag,$LB)
                    $tmp = @()

                    $lbs = $LB
                    $Subs = $Sub

                    foreach ($1 in $lbs) {
                        $ResUCount = 1
                        $sub1 = $SUBs | Where-Object { $_.id -eq $1.subscriptionId }
                        $data = $1.PROPERTIES
                        $Tag = @{}
                        $1.tags.psobject.properties | ForEach-Object { $Tag[$_.Name] = $_.Value }
                        if ($null -ne $data.frontendIPConfigurations -and $null -ne $data.backendAddressPools -and $null -ne $data.probes) {
                            foreach ($2 in $data.frontendIPConfigurations) {
                                $Fronttarget = ''    
                                $Frontsub = ''
                                $FrontType = ''
                                if ($null -ne $2.properties.subnet.id) {
                                    $Fronttarget = $2.properties.subnet.id.split('/')[8]
                                    $Frontsub = $2.properties.subnet.id.split('/')[10]
                                    $FrontType = 'VNET' 
                                }
                                elseif ($null -ne $2.properties.publicIPAddress.id) {
                                    $Fronttarget = $2.properties.publicIPAddress.id.split('/')[8]
                                    $Frontsub = ''
                                    $FrontType = 'Public IP' 
                                }       
                                foreach ($3 in $data.backendAddressPools) {
                                    $BackTarget = ''
                                    $BackType = ''
                                    if ($null -ne $3.properties.backendIPConfigurations.id) {
                                        $BackTarget = $3.properties.backendIPConfigurations.id.split('/')[8]
                                        $BackType = $3.properties.backendIPConfigurations.id.split('/')[7]
                                    }
                                    foreach ($4 in $data.probes) {
                                        if (![string]::IsNullOrEmpty($Tag.Keys) -and $InTag -eq $true) {
                                            foreach ($TagKey in $Tag.Keys) {
                                                    $obj = @{
                                                        'Subscription'              = $sub1.name;
                                                        'Resource Group'            = $1.RESOURCEGROUP;
                                                        'Name'                      = $1.NAME;
                                                        'Location'                  = $1.LOCATION;
                                                        'SKU'                       = $1.sku.name;
                                                        'Frontend Name'             = $2.name;
                                                        'Frontend Target'           = $Fronttarget;
                                                        'Frontend Type'             = $FrontType;
                                                        'Frontend Subnet'           = $frontsub;
                                                        'Backend Pool Name'         = $3.name;
                                                        'Backend Target'            = $BackTarget;
                                                        'Backend Type'              = $BackType;
                                                        'Probe Name'                = $4.name;
                                                        'Probe Interval (sec)'      = $4.properties.intervalInSeconds;
                                                        'Probe Protocol'            = $4.properties.protocol;
                                                        'Probe Port'                = $4.properties.port;
                                                        'Probe Unhealthy threshold' = $4.properties.numberOfProbes;
                                                        'Resource U'                = $ResUCount;
                                                        'Tag Name'                  = [string]$TagKey;
                                                        'Tag Value'                 = [string]$Tag.$TagKey
                                                    }
                                                    $tmp += $obj
                                                    if ($ResUCount -eq 1) {$ResUCount = 0} 
                                                }
                                            }
                                            else { 
                                                $obj = @{
                                                    'Subscription'              = $sub1.name;
                                                    'Resource Group'            = $1.RESOURCEGROUP;
                                                    'Name'                      = $1.NAME;
                                                    'Location'                  = $1.LOCATION;
                                                    'SKU'                       = $1.sku.name;
                                                    'Frontend Name'             = $2.name;
                                                    'Frontend Target'           = $Fronttarget;
                                                    'Frontend Type'             = $FrontType;
                                                    'Frontend Subnet'           = $frontsub;
                                                    'Backend Pool Name'         = $3.name;
                                                    'Backend Target'            = $BackTarget;
                                                    'Backend Type'              = $BackType;
                                                    'Probe Name'                = $4.name;
                                                    'Probe Interval (sec)'      = $4.properties.intervalInSeconds;
                                                    'Probe Protocol'            = $4.properties.protocol;
                                                    'Probe Port'                = $4.properties.port;
                                                    'Probe Unhealthy threshold' = $4.properties.numberOfProbes;
                                                    'Resource U'                = $ResUCount;
                                                    'Tag Name'                  = $null;
                                                    'Tag Value'                 = $null
                                                }
                                                $tmp += $obj
                                                if ($ResUCount -eq 1) {$ResUCount = 0} 
                                            }    
                                    }
                                }
                            }
                        }  
                        elseif ($null -ne $data.frontendIPConfigurations -and $null -ne $data.backendAddressPools -and $null -eq $data.probes) {
                            foreach ($2 in $data.frontendIPConfigurations) {
                                $Fronttarget = ''    
                                $Frontsub = ''
                                if ($null -ne $2.properties.subnet.id) {
                                    $Fronttarget = $2.properties.subnet.id.split('/')[8]
                                    $Frontsub = $2.properties.subnet.id.split('/')[10]
                                    $FrontType = 'VNET' 
                                }
                                elseif ($null -ne $2.properties.publicIPAddress.id) {
                                    $Fronttarget = $2.properties.publicIPAddress.id.split('/')[8]
                                    $Frontsub = ''
                                    $FrontType = 'Public IP' 
                                }        
                                foreach ($3 in $data.backendAddressPools) {
                                    $BackTarget = ''
                                    $BackType = ''
                                    if ($null -ne $3.properties.backendIPConfigurations.id) {
                                        $BackTarget = $3.properties.backendIPConfigurations.id.split('/')[8]
                                        $BackType = $3.properties.backendIPConfigurations.id.split('/')[7]
                                    }
                                    if (![string]::IsNullOrEmpty($Tag.Keys) -and $InTag -eq $true) {
                                        foreach ($TagKey in $Tag.Keys) {  
                                                $obj = @{
                                                    'Subscription'              = $sub1.name;
                                                    'Resource Group'            = $1.RESOURCEGROUP;
                                                    'Name'                      = $1.NAME;
                                                    'Location'                  = $1.LOCATION;
                                                    'SKU'                       = $1.sku.name;
                                                    'Frontend Name'             = $2.name;
                                                    'Frontend Target'           = $Fronttarget;
                                                    'Frontend Type'             = $FrontType;
                                                    'Frontend Subnet'           = $frontsub;
                                                    'Backend Pool Name'         = $3.name;
                                                    'Backend Target'            = $BackTarget;
                                                    'Backend Type'              = $BackType;
                                                    'Probe Name'                = $null;
                                                    'Probe Interval (sec)'      = $null;
                                                    'Probe Protocol'            = $null;
                                                    'Probe Port'                = $null;
                                                    'Probe Unhealthy threshold' = $null;
                                                    'Resource U'                = $ResUCount;
                                                    'Tag Name'                  = [string]$TagKey;
                                                    'Tag Value'                 = [string]$Tag.$TagKey
                                                }
                                                $tmp += $obj
                                                if ($ResUCount -eq 1) {$ResUCount = 0}          
                                            }
                                        }
                                        else {
                                            $obj = @{
                                                'Subscription'              = $sub1.name;
                                                'Resource Group'            = $1.RESOURCEGROUP;
                                                'Name'                      = $1.NAME;
                                                'Location'                  = $1.LOCATION;
                                                'SKU'                       = $1.sku.name;
                                                'Frontend Name'             = $2.name;
                                                'Frontend Target'           = $Fronttarget;
                                                'Frontend Type'             = $FrontType;
                                                'Frontend Subnet'           = $frontsub;
                                                'Backend Pool Name'         = $3.name;
                                                'Backend Target'            = $BackTarget;
                                                'Backend Type'              = $BackType;
                                                'Probe Name'                = $null;
                                                'Probe Interval (sec)'      = $null;
                                                'Probe Protocol'            = $null;
                                                'Probe Port'                = $null;
                                                'Probe Unhealthy threshold' = $null;
                                                'Resource U'                = $ResUCount;
                                                'Tag Name'                  = $null;
                                                'Tag Value'                 = $null
                                            }
                                            $tmp += $obj 
                                            if ($ResUCount -eq 1) {$ResUCount = 0} 
                                        }
                                }
                            }
                        }   
                        elseif ($null -ne $data.frontendIPConfigurations -and $null -eq $data.backendAddressPools -and $null -eq $data.probes) {
                            foreach ($2 in $data.frontendIPConfigurations) {
                                $Fronttarget = ''    
                                $Frontsub = ''
                                if ($null -ne $2.properties.subnet.id) {
                                    $Fronttarget = $2.properties.subnet.id.split('/')[8]
                                    $Frontsub = $2.properties.subnet.id.split('/')[10]
                                    $FrontType = 'VNET' 
                                }
                                elseif ($null -ne $2.properties.publicIPAddress.id) {
                                    $Fronttarget = $2.properties.publicIPAddress.id.split('/')[8]
                                    $Frontsub = ''
                                    $FrontType = 'Public IP' 
                                }         
                                if (![string]::IsNullOrEmpty($Tag.Keys) -and $InTag -eq $true) {
                                    foreach ($TagKey in $Tag.Keys) {
                                            $obj = @{
                                                'Subscription'              = $sub1.name;
                                                'Resource Group'            = $1.RESOURCEGROUP;
                                                'Name'                      = $1.NAME;
                                                'Location'                  = $1.LOCATION;
                                                'SKU'                       = $1.sku.name;
                                                'Frontend Name'             = $2.name;
                                                'Frontend Target'           = $Fronttarget;
                                                'Frontend Type'             = $FrontType;
                                                'Frontend Subnet'           = $frontsub;
                                                'Backend Pool Name'         = $null;
                                                'Backend Target'            = $null;
                                                'Backend Type'              = $null;
                                                'Probe Name'                = $null;
                                                'Probe Interval (sec)'      = $null;
                                                'Probe Protocol'            = $null;
                                                'Probe Port'                = $null;
                                                'Probe Unhealthy threshold' = $null;
                                                'Resource U'                = $ResUCount;
                                                'Tag Name'                  = [string]$TagKey;
                                                'Tag Value'                 = [string]$Tag.$TagKey
                                            }
                                            $tmp += $obj   
                                            if ($ResUCount -eq 1) {$ResUCount = 0}      
                                        }
                                    }
                                    else {
                                        $obj = @{
                                            'Subscription'              = $sub1.name;
                                            'Resource Group'            = $1.RESOURCEGROUP;
                                            'Name'                      = $1.NAME;
                                            'Location'                  = $1.LOCATION;
                                            'SKU'                       = $1.sku.name;
                                            'Frontend Name'             = $2.name;
                                            'Frontend Target'           = $Fronttarget;
                                            'Frontend Type'             = $FrontType;
                                            'Frontend Subnet'           = $frontsub;
                                            'Backend Pool Name'         = $null;
                                            'Backend Target'            = $null;
                                            'Backend Type'              = $null;
                                            'Probe Name'                = $null;
                                            'Probe Interval (sec)'      = $null;
                                            'Probe Protocol'            = $null;
                                            'Probe Port'                = $null;
                                            'Probe Unhealthy threshold' = $null;
                                            'Resource U'                = $ResUCount;
                                            'Tag Name'                  = $null;
                                            'Tag Value'                 = $null
                                        }
                                        $tmp += $obj 
                                        if ($ResUCount -eq 1) {$ResUCount = 0}  
                                    }     
                            }
                        }   
                        elseif ($null -ne $data.frontendIPConfigurations -and $null -eq $data.backendAddressPools -and $null -ne $data.probes) {
                            foreach ($2 in $data.frontendIPConfigurations) {
                                $Fronttarget = ''    
                                $Frontsub = ''
                                if ($null -ne $2.properties.subnet.id) {
                                    $Fronttarget = $2.properties.subnet.id.split('/')[8]
                                    $Frontsub = $2.properties.subnet.id.split('/')[10]
                                    $FrontType = 'VNET' 
                                }
                                elseif ($null -ne $2.properties.publicIPAddress.id) {
                                    $Fronttarget = $2.properties.publicIPAddress.id.split('/')[8]
                                    $Frontsub = ''
                                    $FrontType = 'Public IP' 
                                }        
                                foreach ($3 in $data.probes) {
                                    if (![string]::IsNullOrEmpty($Tag.Keys) -and $InTag -eq $true) {
                                        foreach ($TagKey in $Tag.Keys) {
                                                $obj = @{
                                                    'Subscription'              = $sub1.name;
                                                    'Resource Group'            = $1.RESOURCEGROUP;
                                                    'Name'                      = $1.NAME;
                                                    'Location'                  = $1.LOCATION;
                                                    'SKU'                       = $1.sku.name;
                                                    'Frontend Name'             = $2.name;
                                                    'Frontend Target'           = $Fronttarget;
                                                    'Frontend Type'             = $FrontType;
                                                    'Frontend Subnet'           = $frontsub;
                                                    'Backend Pool Name'         = $null;
                                                    'Backend Target'            = $null;
                                                    'Backend Type'              = $null;
                                                    'Probe Name'                = $3.name;
                                                    'Probe Interval (sec)'      = $3.properties.intervalInSeconds;
                                                    'Probe Protocol'            = $3.properties.protocol;
                                                    'Probe Port'                = $3.properties.port;
                                                    'Probe Unhealthy threshold' = $3.properties.numberOfProbes;
                                                    'Resource U'                = $ResUCount;
                                                    'Tag Name'                  = [string]$TagKey;
                                                    'Tag Value'                 = [string]$Tag.$TagKey
                                                }
                                                $tmp += $obj  
                                                if ($ResUCount -eq 1) {$ResUCount = 0}     
                                            }
                                        }
                                        else {  
                                            $obj = @{
                                                'Subscription'              = $sub1.name;
                                                'Resource Group'            = $1.RESOURCEGROUP;
                                                'Name'                      = $1.NAME;
                                                'Location'                  = $1.LOCATION;
                                                'SKU'                       = $1.sku.name;
                                                'Frontend Name'             = $2.name;
                                                'Frontend Target'           = $Fronttarget;
                                                'Frontend Type'             = $FrontType;
                                                'Frontend Subnet'           = $frontsub;
                                                'Backend Pool Name'         = $null;
                                                'Backend Target'            = $null;
                                                'Backend Type'              = $null;
                                                'Probe Name'                = $3.name;
                                                'Probe Interval (sec)'      = $3.properties.intervalInSeconds;
                                                'Probe Protocol'            = $3.properties.protocol;
                                                'Probe Port'                = $3.properties.port;
                                                'Probe Unhealthy threshold' = $3.properties.numberOfProbes;
                                                'Resource U'                = $ResUCount;
                                                'Tag Name'                  = $null;
                                                'Tag Value'                 = $null
                                            }
                                            $tmp += $obj
                                            if ($ResUCount -eq 1) {$ResUCount = 0} 
                                        }      
                                }
                            }
                        }   
                        elseif ($null -eq $data.frontendIPConfigurations -and $null -ne $data.backendAddressPools -and $null -ne $data.probes) {
                            foreach ($2 in $data.backendAddressPools) {
                                $BackTarget = ''
                                $BackType = ''
                                if ($null -ne $3.properties.backendIPConfigurations.id) {
                                    $BackTarget = $2.properties.backendIPConfigurations.id.split('/')[8]
                                    $BackType = $2.properties.backendIPConfigurations.id.split('/')[7]
                                }
                                foreach ($3 in $data.probes) {
                                    if (![string]::IsNullOrEmpty($Tag.Keys) -and $InTag -eq $true) {
                                        foreach ($TagKey in $Tag.Keys) {
                                                $obj = @{
                                                    'Subscription'              = $sub1.name;
                                                    'Resource Group'            = $1.RESOURCEGROUP;
                                                    'Name'                      = $1.NAME;
                                                    'Location'                  = $1.LOCATION;
                                                    'SKU'                       = $1.sku.name;
                                                    'Frontend Name'             = $null;
                                                    'Frontend Target'           = $null;
                                                    'Frontend Type'             = $null;
                                                    'Frontend Subnet'           = $null;
                                                    'Backend Pool Name'         = $2.name;
                                                    'Backend Target'            = $BackTarget;
                                                    'Backend Type'              = $BackType;
                                                    'Probe Name'                = $3.name;
                                                    'Probe Interval (sec)'      = $3.properties.intervalInSeconds;
                                                    'Probe Protocol'            = $3.properties.protocol;
                                                    'Probe Port'                = $3.properties.port;
                                                    'Probe Unhealthy threshold' = $3.properties.numberOfProbes;
                                                    'Resource U'                = $ResUCount;
                                                    'Tag Name'                  = [string]$TagKey;
                                                    'Tag Value'                 = [string]$Tag.$TagKey
                                                }
                                                $tmp += $obj   
                                                if ($ResUCount -eq 1) {$ResUCount = 0}     
                                            }
                                        }
                                        else { 
                                            $obj = @{
                                                'Subscription'              = $sub1.name;
                                                'Resource Group'            = $1.RESOURCEGROUP;
                                                'Name'                      = $1.NAME;
                                                'Location'                  = $1.LOCATION;
                                                'SKU'                       = $1.sku.name;
                                                'Frontend Name'             = $null;
                                                'Frontend Target'           = $null;
                                                'Frontend Type'             = $null;
                                                'Frontend Subnet'           = $null;
                                                'Backend Pool Name'         = $2.name;
                                                'Backend Target'            = $BackTarget;
                                                'Backend Type'              = $BackType;
                                                'Probe Name'                = $3.name;
                                                'Probe Interval (sec)'      = $3.properties.intervalInSeconds;
                                                'Probe Protocol'            = $3.properties.protocol;
                                                'Probe Port'                = $3.properties.port;
                                                'Probe Unhealthy threshold' = $3.properties.numberOfProbes;
                                                'Resource U'                = $ResUCount;
                                                'Tag Name'                  = $null;
                                                'Tag Value'                 = $null
                                            }
                                            $tmp += $obj   
                                            if ($ResUCount -eq 1) {$ResUCount = 0} 
                                        }     
                                }
                            }            
                        }    
                        elseif ($null -eq $data.frontendIPConfigurations -and $null -eq $data.backendAddressPools -and $null -ne $data.probes) {
                            foreach ($2 in $data.probes) {
                                if (![string]::IsNullOrEmpty($Tag.Keys) -and $InTag -eq $true) {
                                    foreach ($TagKey in $Tag.Keys) {
                                            $obj = @{
                                                'Subscription'              = $sub1.name;
                                                'Resource Group'            = $1.RESOURCEGROUP;
                                                'Name'                      = $1.NAME;
                                                'Location'                  = $1.LOCATION;
                                                'SKU'                       = $1.sku.name;
                                                'Frontend Name'             = $null;
                                                'Frontend Target'           = $null;
                                                'Frontend Type'             = $null;
                                                'Frontend Subnet'           = $null;
                                                'Backend Pool Name'         = $null;
                                                'Backend Target'            = $null;
                                                'Backend Type'              = $null;
                                                'Probe Name'                = $2.name;
                                                'Probe Interval (sec)'      = $2.properties.intervalInSeconds;
                                                'Probe Protocol'            = $2.properties.protocol;
                                                'Probe Port'                = $2.properties.port;
                                                'Probe Unhealthy threshold' = $2.properties.numberOfProbes;
                                                'Resource U'                = $ResUCount;
                                                'Tag Name'                  = [string]$TagKey;
                                                'Tag Value'                 = [string]$Tag.$TagKey
                                            }
                                            $tmp += $obj
                                            if ($ResUCount -eq 1) {$ResUCount = 0} 
                                        }
                                    }
                                    else { 
                                        $obj = @{
                                            'Subscription'              = $sub1.name;
                                            'Resource Group'            = $1.RESOURCEGROUP;
                                            'Name'                      = $1.NAME;
                                            'Location'                  = $1.LOCATION;
                                            'SKU'                       = $1.sku.name;
                                            'Frontend Name'             = $null;
                                            'Frontend Target'           = $null;
                                            'Frontend Type'             = $null;
                                            'Frontend Subnet'           = $null;
                                            'Backend Pool Name'         = $null;
                                            'Backend Target'            = $null;
                                            'Backend Type'              = $null;
                                            'Probe Name'                = $2.name;
                                            'Probe Interval (sec)'      = $2.properties.intervalInSeconds;
                                            'Probe Protocol'            = $2.properties.protocol;
                                            'Probe Port'                = $2.properties.port;
                                            'Probe Unhealthy threshold' = $2.properties.numberOfProbes;
                                            'Resource U'                = $ResUCount;
                                            'Tag Name'                  = $null;
                                            'Tag Value'                 = $null
                                        }
                                        $tmp += $obj
                                        if ($ResUCount -eq 1) {$ResUCount = 0} 
                                    }
                            }            
                        }
                    }
                    $tmp
                }).AddArgument($($args[0])).AddArgument($($args[1])).AddArgument($($args[5]))



            $Peering = ([PowerShell]::Create()).AddScript( { param($Sub, $InTag,$VNET)
                    $tmp = @()

                    $vnet = $VNET
                    $vpeering = $vnet | Where-Object { $null -ne $_.properties.virtualNetworkPeerings }

                    $Subs = $Sub

                    foreach ($1 in $vpeering) {
                        $ResUCount = 1
                        $sub1 = $SUBs | Where-Object { $_.id -eq $1.subscriptionId }
                        $data = $1.PROPERTIES
                        $Tag = @{}
                        $1.tags.psobject.properties | ForEach-Object { $Tag[$_.Name] = $_.Value }
                        foreach ($2 in $data.addressSpace.addressPrefixes) {
                            foreach ($4 in $data.virtualNetworkPeerings) {
                                foreach ($5 in $4.properties.remoteAddressSpace.addressPrefixes) {
                                    if (![string]::IsNullOrEmpty($Tag.Keys) -and $InTag -eq $true) {
                                        foreach ($TagKey in $Tag.Keys) {  
                                                $obj = @{
                                                    'Subscription'                          = $sub1.name;
                                                    'Resource Group'                        = $1.RESOURCEGROUP;
                                                    'VNET Name'                             = $1.NAME;
                                                    'Location'                              = $1.LOCATION;
                                                    'Zone'                                  = $1.ZONES;
                                                    'Address Space'                         = $2;
                                                    'Peering Name'                          = $4.name;
                                                    'Peering VNet'                          = $4.properties.remoteVirtualNetwork.id.split('/')[8];
                                                    'Peering State'                         = $4.properties.peeringState;
                                                    'Peering Use Remote Gateways'           = $4.properties.useRemoteGateways;
                                                    'Peering Allow Gateway Transit'         = $4.properties.allowGatewayTransit;
                                                    'Peering Allow Forwarded Traffic'       = $4.properties.allowForwardedTraffic;
                                                    'Peering Do Not Verify Remote Gateways' = $4.properties.doNotVerifyRemoteGateways;
                                                    'Peering Allow Virtual Network Access'  = $4.properties.allowVirtualNetworkAccess;
                                                    'Peering Address Space'                 = $5;
                                                    'Resource U'                            = $ResUCount;
                                                    'Tag Name'                              = [string]$TagKey;
                                                    'Tag Value'                             = [string]$Tag.$TagKey
                                                }
                                                $tmp += $obj
                                                if ($ResUCount -eq 1) {$ResUCount = 0} 
                                            }
                                        }
                                        else {   
                                                $obj = @{
                                                    'Subscription'                          = $sub1.name;
                                                    'Resource Group'                        = $1.RESOURCEGROUP;
                                                    'VNET Name'                             = $1.NAME;
                                                    'Location'                              = $1.LOCATION;
                                                    'Zone'                                  = $1.ZONES;
                                                    'Address Space'                         = $2;
                                                    'Peering Name'                          = $4.name;
                                                    'Peering VNet'                          = $4.properties.remoteVirtualNetwork.id.split('/')[8];
                                                    'Peering State'                         = $4.properties.peeringState;
                                                    'Peering Use Remote Gateways'           = $4.properties.useRemoteGateways;
                                                    'Peering Allow Gateway Transit'         = $4.properties.allowGatewayTransit;
                                                    'Peering Allow Forwarded Traffic'       = $4.properties.allowForwardedTraffic;
                                                    'Peering Do Not Verify Remote Gateways' = $4.properties.doNotVerifyRemoteGateways;
                                                    'Peering Allow Virtual Network Access'  = $4.properties.allowVirtualNetworkAccess;
                                                    'Peering Address Space'                 = $5;
                                                    'Resource U'                            = $ResUCount;
                                                    'Tag Name'                              = $null;
                                                    'Tag Value'                             = $null
                                                }
                                                $tmp += $obj
                                                if ($ResUCount -eq 1) {$ResUCount = 0} 
                                        }
                                }
                            }
                        }
                            
                    }
                    $tmp
                }).AddArgument($($args[0])).AddArgument($($args[1])).AddArgument($($args[2]))

            $FrontDoor = ([PowerShell]::Create()).AddScript( { param($Sub, $InTag,$FRONTDOOR)
                    $tmp = @()

                    $Subs = $Sub

                    foreach ($1 in $FRONTDOOR) {
                        $ResUCount = 1
                        $sub1 = $SUBs | Where-Object { $_.id -eq $1.subscriptionId }
                        $data = $1.PROPERTIES
                        $Tag = @{}
                        $1.tags.psobject.properties | ForEach-Object { $Tag[$_.Name] = $_.Value }
                        if (![string]::IsNullOrEmpty($Tag.Keys) -and $InTag -eq $true) {
                            foreach ($TagKey in $Tag.Keys) {  
                                    $obj = @{
                                        'Subscription'           = $sub1.name;
                                        'Resource Group'         = $1.RESOURCEGROUP;
                                        'Name'                   = $1.NAME;
                                        'Location'               = $1.LOCATION;
                                        'Friendly Name'          = $data.friendlyName;
                                        'cName'                  = $data.cName;
                                        'State'                  = $data.enabledState;
                                        'Frontend'               = [string]$data.frontendEndpoints.name;
                                        'Backend'                = [string]$data.backendPools.name;
                                        'Health Probe'           = [string]$data.healthProbeSettings.name;
                                        'Load Balancing'         = [string]$data.loadBalancingSettings.name;
                                        'Routing Rules'          = [string]$data.routingRules.name;
                                        'Resource U'             = $ResUCount;
                                        'Tag Name'               = [string]$TagKey;
                                        'Tag Value'              = [string]$Tag.$TagKey
                                    }
                                    $tmp += $obj
                                    if ($ResUCount -eq 1) {$ResUCount = 0} 
                                }
                            }
                            else {    
                                $obj = @{
                                    'Subscription'           = $sub1.name;
                                    'Resource Group'         = $1.RESOURCEGROUP;
                                    'Name'                   = $1.NAME;
                                    'Location'               = $1.LOCATION;
                                    'Friendly Name'          = $data.friendlyName;
                                    'cName'                  = $data.cName;
                                    'State'                  = $data.enabledState;
                                    'Frontend'               = [string]$data.frontendEndpoints.name;
                                    'Backend'                = [string]$data.backendPools.name;
                                    'Health Probe'           = [string]$data.healthProbeSettings.name;
                                    'Load Balancing'         = [string]$data.loadBalancingSettings.name;
                                    'Routing Rules'          = [string]$data.routingRules.name;
                                    'Resource U'             = $ResUCount;
                                    'Tag Name'               = $null;
                                    'Tag Value'              = $null
                                }
                                $tmp += $obj
                                if ($ResUCount -eq 1) {$ResUCount = 0} 
                            }
                    }
                    $tmp
                }).AddArgument($($args[0])).AddArgument($($args[1])).AddArgument($($args[6]))

            $AppGateway = ([PowerShell]::Create()).AddScript( { param($Sub, $InTag,$APPGTW)
                    $tmp = @()

                    $Subs = $Sub

                    foreach ($1 in $APPGTW) {
                        $ResUCount = 1
                        $sub1 = $SUBs | Where-Object { $_.id -eq $1.subscriptionId }
                        $data = $1.PROPERTIES
                        $Tag = @{}
                        $1.tags.psobject.properties | ForEach-Object { $Tag[$_.Name] = $_.Value }
                        if (![string]::IsNullOrEmpty($Tag.Keys) -and $InTag -eq $true) {
                            foreach ($TagKey in $Tag.Keys) {        
                                    $obj = @{
                                        'Subscription'           = $sub1.name;
                                        'Resource Group'         = $1.RESOURCEGROUP;
                                        'Name'                   = $1.NAME;
                                        'Location'               = $1.LOCATION;
                                        'State'                  = $data.OperationalState;
                                        'SKU Name'               = $data.sku.tier;
                                        'SKU Capacity'           = $data.sku.capacity;
                                        'Backend'                = [string]$data.backendAddressPools.name;
                                        'Frontend'               = [string]$data.frontendIPConfigurations.name;
                                        'Frontend Ports'         = [string]$data.frontendports.properties.port;
                                        'Gateways'               = [string]$data.gatewayIPConfigurations.name;
                                        'HTTP Listeners'         = [string]$data.httpListeners.name;
                                        'Request Routing Rules'  = [string]$data.RequestRoutingRules.Name;
                                        'Resource U'             = $ResUCount;
                                        'Tag Name'               = [string]$TagKey;
                                        'Tag Value'              = [string]$Tag.$TagKey
                                    }
                                    $tmp += $obj
                                    if ($ResUCount -eq 1) {$ResUCount = 0} 
                                }
                            }
                            else {        
                                $obj = @{
                                    'Subscription'           = $sub1.name;
                                    'Resource Group'         = $1.RESOURCEGROUP;
                                    'Name'                   = $1.NAME;
                                    'Location'               = $1.LOCATION;
                                    'State'                  = $data.OperationalState;
                                    'SKU Name'               = $data.sku.tier;
                                    'SKU Capacity'           = $data.sku.capacity;
                                    'Backend'                = [string]$data.backendAddressPools.name;
                                    'Frontend'               = [string]$data.frontendIPConfigurations.name;
                                    'Frontend Ports'         = [string]$data.frontendports.properties.port;
                                    'Gateways'               = [string]$data.gatewayIPConfigurations.name;
                                    'HTTP Listeners'         = [string]$data.httpListeners.name;
                                    'Request Routing Rules'  = [string]$data.RequestRoutingRules.Name;
                                    'Resource U'             = $ResUCount;
                                    'Tag Name'               = $null;
                                    'Tag Value'              = $null
                                }
                                $tmp += $obj
                                if ($ResUCount -eq 1) {$ResUCount = 0} 
                            }
                    }
                    $tmp
                }).AddArgument($($args[0])).AddArgument($($args[1])).AddArgument($($args[7]))

            $RouteTable = ([PowerShell]::Create()).AddScript( { param($Sub, $InTag,$ROUTETABLE)
                    $tmp = @()

                    $Subs = $Sub

                    foreach ($1 in $ROUTETABLE) {
                        $ResUCount = 1
                        $sub1 = $SUBs | Where-Object { $_.id -eq $1.subscriptionId }
                        $data = $1.PROPERTIES
                        $Tag = @{}
                        $1.tags.psobject.properties | ForEach-Object { $Tag[$_.Name] = $_.Value } 
                        if (![string]::IsNullOrEmpty($Tag.Keys) -and $InTag -eq $true) {
                            foreach ($TagKey in $Tag.Keys) { 
                                    $obj = @{
                                        'Subscription'           = $sub1.name;
                                        'Resource Group'         = $1.RESOURCEGROUP;
                                        'Name'                   = $1.NAME;
                                        'Location'               = $1.LOCATION;
                                        'Disable BGP Route Propagation' = $data.disableBgpRoutePropagation;
                                        'Routes'                 = [string]$data.routes.name;
                                        'Routes Prefixes'        = [string]$data.routes.properties.addressPrefix;
                                        'Routes BGP Override'    = [string]$data.routes.properties.hasBgpOverride;
                                        'Routes Next Hop IP'     = [string]$data.routes.properties.nextHopIpAddress;
                                        'Routes Next Hop Type'   = [string]$data.routes.properties.nextHopType;
                                        'Resource U'             = $ResUCount;
                                        'Tag Name'               = [string]$TagKey;
                                        'Tag Value'              = [string]$Tag.$TagKey
                                    }
                                    $tmp += $obj
                                    if ($ResUCount -eq 1) {$ResUCount = 0} 
                                }
                            }
                            else {  
                                $obj = @{
                                    'Subscription'           = $sub1.name;
                                    'Resource Group'         = $1.RESOURCEGROUP;
                                    'Name'                   = $1.NAME;
                                    'Location'               = $1.LOCATION;
                                    'Disable BGP Route Propagation' = $data.disableBgpRoutePropagation;
                                    'Routes'                 = [string]$data.routes.name;
                                    'Routes Prefixes'        = [string]$data.routes.properties.addressPrefix;
                                    'Routes BGP Override'    = [string]$data.routes.properties.hasBgpOverride;
                                    'Routes Next Hop IP'     = [string]$data.routes.properties.nextHopIpAddress;
                                    'Routes Next Hop Type'   = [string]$data.routes.properties.nextHopType;
                                    'Resource U'             = $ResUCount;
                                    'Tag Name'               = $null;
                                    'Tag Value'              = $null
                                }
                                $tmp += $obj
                                if ($ResUCount -eq 1) {$ResUCount = 0} 
                            }
                    }
                    $tmp
                }).AddArgument($($args[0])).AddArgument($($args[1])).AddArgument($($args[8]))                

            $DNSZone = ([PowerShell]::Create()).AddScript( { param($Sub, $InTag,$DNSZONE)
                    $tmp = @()

                    $Subs = $Sub

                    foreach ($1 in $DNSZONE) {
                        $ResUCount = 1
                        $sub1 = $SUBs | Where-Object { $_.id -eq $1.subscriptionId }
                        $data = $1.PROPERTIES
                        $Tag = @{}
                        $1.tags.psobject.properties | ForEach-Object { $Tag[$_.Name] = $_.Value }
                        if (![string]::IsNullOrEmpty($Tag.Keys) -and $InTag -eq $true) {
                            foreach ($TagKey in $Tag.Keys) {     
                                    $obj = @{
                                        'Subscription'           = $sub1.name;
                                        'Resource Group'         = $1.RESOURCEGROUP;
                                        'Name'                   = $1.NAME;
                                        'Location'               = $1.LOCATION;
                                        'Zone Type'              = $data.zoneType;
                                        'Number of Record Sets'  = $data.numberOfRecordSets;
                                        'Max Number of Record Sets' = $data.maxNumberofRecordSets;
                                        'Name Servers'           = [string]$data.nameServers;
                                        'Resource U'             = $ResUCount;
                                        'Tag Name'               = [string]$TagKey;
                                        'Tag Value'              = [string]$Tag.$TagKey
                                    }
                                    $tmp += $obj
                                    if ($ResUCount -eq 1) {$ResUCount = 0} 
                                }
                            }
                            else {    
                                $obj = @{
                                    'Subscription'           = $sub1.name;
                                    'Resource Group'         = $1.RESOURCEGROUP;
                                    'Name'                   = $1.NAME;
                                    'Location'               = $1.LOCATION;
                                    'Zone Type'              = $data.zoneType;
                                    'Number of Record Sets'  = $data.numberOfRecordSets;
                                    'Max Number of Record Sets' = $data.maxNumberofRecordSets;
                                    'Name Servers'           = [string]$data.nameServers;
                                    'Resource U'             = $ResUCount;
                                    'Tag Name'               = $null;
                                    'Tag Value'              = $null
                                }
                                $tmp += $obj
                                if ($ResUCount -eq 1) {$ResUCount = 0} 
                            }
                    }
                    $tmp
                }).AddArgument($($args[0])).AddArgument($($args[1])).AddArgument($($args[9]))  


            $jobVNET = $VNET.BeginInvoke()
            $jobVNETGTW = $VNETGTW.BeginInvoke()
            $jobPIP = $PIP.BeginInvoke()
            $jobLB = $LB.BeginInvoke()
            $jobPeering = $Peering.BeginInvoke()
            $jobFrontDoor = $FrontDoor.BeginInvoke()
            $jobAppGateway = $AppGateway.BeginInvoke()
            $jobRouteTable = $RouteTable.BeginInvoke()
            $jobDNSZone = $DNSZone.BeginInvoke()

            $job += $jobVNET
            $job += $jobVNETGTW
            $job += $jobPIP
            $job += $jobLB
            $job += $jobPeering
            $job += $jobFrontDoor
            $job += $jobAppGateway
            $job += $jobRouteTable
            $job += $jobDNSZone

            while ($Job.Runspace.IsCompleted -contains $false) {}

            $VNETS = $VNET.EndInvoke($jobVNET)
            $VNETGTWS = $VNETGTW.EndInvoke($jobVNETGTW)
            $PIPS = $PIP.EndInvoke($jobPIP)
            $LBS = $LB.EndInvoke($jobLB)
            $PeeringS = $Peering.EndInvoke($jobPeering)
            $FrontDoorS = $FrontDoor.EndInvoke($jobFrontDoor)
            $AppGatewayS = $AppGateway.EndInvoke($jobAppGateway)
            $RouteTableS = $RouteTable.EndInvoke($jobRouteTable)
            $DNSZoneS = $DNSZone.EndInvoke($jobDNSZone)

            $VNET.Dispose()
            $VNETGTW.Dispose()
            $PIP.Dispose()
            $LB.Dispose()
            $Peering.Dispose()
            $FrontDoor.Dispose()
            $AppGateway.Dispose()
            $RouteTable.Dispose()
            $DNSZone.Dispose()

            $AzNetwork = @{
                'VNET'    = $VNETS;
                'VNETGTW' = $VNETGTWS;
                'PIP'     = $PIPS;
                'LB'      = $LBS;
                'Peering' = $PeeringS;
                'FrontDoor' = $FrontDoorS;
                'AppGateway' = $AppGatewayS;
                'RouteTable' = $RouteTableS;
                'DNSZone' = $DNSZoneS
            }

            $AzNetwork

        } -ArgumentList $Subs,$InTag, $VNET, $VNETGTW, $PIP, $LB, $FRONTDOOR, $APPGTW, $ROUTETABLE, $DNSZONE | Out-Null


        <######################################################### INFRASTRUCTURE RESOURCE GROUP JOB ######################################################################>


        Start-Job -Name 'Infra' -ScriptBlock {

            $job = @()

            $StorageAcc = ([PowerShell]::Create()).AddScript( { param($Sub, $InTag,$StorageAcc)
                    $tmp = @()

                    $storageacc = $StorageAcc
                    $Subs = $Sub

                    foreach ($1 in $storageacc) {
                        $ResUCount = 1
                        $sub1 = $SUBs | Where-Object { $_.id -eq $1.subscriptionId }
                        $data = $1.PROPERTIES
                        $TLSv = if ($data.minimumTlsVersion -eq 'TLS1_2') { "TLS 1.2" }elseif ($data.minimumTlsVersion -eq 'TLS1_1') { "TLS 1.1" }else { "TLS 1.0" }
                        $Tag = @{}
                        $1.tags.psobject.properties | ForEach-Object { $Tag[$_.Name] = $_.Value }
                        if (![string]::IsNullOrEmpty($Tag.Keys) -and $InTag -eq $true) {
                            foreach ($TagKey in $Tag.Keys) {   
                                    $obj = @{
                                        'Subscription'                          = $sub1.name;
                                        'Resource Group'                        = $1.RESOURCEGROUP;
                                        'Name'                                  = $1.NAME;
                                        'Location'                              = $1.LOCATION;
                                        'Zone'                                  = $1.ZONES;
                                        'Supports HTTPs Traffic Only'           = $data.supportsHttpsTrafficOnly;
                                        'Allow Blob Public Access'              = if ($data.allowBlobPublicAccess -eq $false) { $false }else { $true };
                                        'TLS Version'                           = $TLSv;
                                        'Identity-based access for file shares' = if ($data.azureFilesIdentityBasedAuthentication.directoryServiceOptions -eq 'None') { $false }elseif ($null -eq $data.azureFilesIdentityBasedAuthentication.directoryServiceOptions) { $false }else { $true };
                                        'Access Tier'                           = $data.accessTier;
                                        'Primary Location'                      = $data.primaryLocation;
                                        'Status Of Primary'                     = $data.statusOfPrimary;
                                        'Secondary Location'                    = $data.secondaryLocation;
                                        'Blob Address'                          = [string]$data.primaryEndpoints.blob;
                                        'File Address'                          = [string]$data.primaryEndpoints.file;
                                        'Table Address'                         = [string]$data.primaryEndpoints.table;
                                        'Queue Address'                         = [string]$data.primaryEndpoints.queue;
                                        'Network Acls'                          = $data.networkAcls.defaultAction;
                                        'Resource U'                            = $ResUCount;
                                        'Tag Name'                              = [string]$TagKey;
                                        'Tag Value'                             = [string]$Tag.$TagKey
                                    }
                                    $tmp += $obj
                                    if ($ResUCount -eq 1) {$ResUCount = 0} 
                                }
                            }
                            else {   
                                $obj = @{
                                    'Subscription'                          = $sub1.name;
                                    'Resource Group'                        = $1.RESOURCEGROUP;
                                    'Name'                                  = $1.NAME;
                                    'Location'                              = $1.LOCATION;
                                    'Zone'                                  = $1.ZONES;
                                    'Supports HTTPs Traffic Only'           = $data.supportsHttpsTrafficOnly;
                                    'Allow Blob Public Access'              = if ($data.allowBlobPublicAccess -eq $false) { $false }else { $true };
                                    'TLS Version'                           = $TLSv;
                                    'Identity-based access for file shares' = if ($data.azureFilesIdentityBasedAuthentication.directoryServiceOptions -eq 'None') { $false }elseif ($null -eq $data.azureFilesIdentityBasedAuthentication.directoryServiceOptions) { $false }else { $true };
                                    'Access Tier'                           = $data.accessTier;
                                    'Primary Location'                      = $data.primaryLocation;
                                    'Status Of Primary'                     = $data.statusOfPrimary;
                                    'Secondary Location'                    = $data.secondaryLocation;
                                    'Blob Address'                          = [string]$data.primaryEndpoints.blob;
                                    'File Address'                          = [string]$data.primaryEndpoints.file;
                                    'Table Address'                         = [string]$data.primaryEndpoints.table;
                                    'Queue Address'                         = [string]$data.primaryEndpoints.queue;
                                    'Network Acls'                          = $data.networkAcls.defaultAction;
                                    'Resource U'                            = $ResUCount;
                                    'Tag Name'                              = $null;
                                    'Tag Value'                             = $null
                                }
                                $tmp += $obj
                                if ($ResUCount -eq 1) {$ResUCount = 0} 
                            }
                    }
                    $tmp
                }).AddArgument($($args[0])).AddArgument($($args[1])).AddArgument($($args[2]))



            $AutAcc = ([PowerShell]::Create()).AddScript( { param($Sub, $InTag,$RunBook, $AutAcc)
                    $tmp = @()

                    $runbook = $RunBook
                    $autacc = $AutAcc
                    $Subs = $Sub

                    foreach ($0 in $autacc) {
                        $ResUCount = 1
                        $sub1 = $SUBs | Where-Object { $_.id -eq $0.subscriptionId }
                            
                        $rbs = $runbook | Where-Object { $_.id.split('/')[8] -eq $0.name }
                        $Tag = @{}
                        $1.tags.psobject.properties | ForEach-Object { $Tag[$_.Name] = $_.Value }
                        if ($null -ne $rbs) {
                            foreach ($1 in $rbs) {
                                if (![string]::IsNullOrEmpty($Tag.Keys) -and $InTag -eq $true) {
                                    foreach ($TagKey in $Tag.Keys) {    
                                        $data = $1.PROPERTIES
                                        $obj = @{
                                            'Subscription'             = $sub1.name;
                                            'Resource Group'           = $0.RESOURCEGROUP;
                                            'Automation Account Name'  = $0.NAME;
                                            'Automation Account State' = $0.properties.State;
                                            'Automation Account SKU'   = $0.properties.sku.name;
                                            'Location'                 = $0.LOCATION;
                                            'Runbook Name'             = $1.Name;
                                            'Last Modified Time'       = ([datetime]$data.lastModifiedTime).tostring('MM/dd/yyyy hh:mm') ;
                                            'Runbook State'            = $data.state;
                                            'Runbook Type'             = $data.runbookType;
                                            'Runbook Description'      = $data.description;
                                            'Job Count'                = $data.jobCount;
                                            'Resource U'               = $ResUCount;
                                            'Tag Name'                 = [string]$TagKey;
                                            'Tag Value'                = [string]$Tag.$TagKey
                                        }
                                        $tmp += $obj
                                        if ($ResUCount -eq 1) {$ResUCount = 0} 
                                    }
                                }
                                else {   
                                        $data = $1.PROPERTIES
                                        $obj = @{
                                            'Subscription'             = $sub1.name;
                                            'Resource Group'           = $0.RESOURCEGROUP;
                                            'Automation Account Name'  = $0.NAME;
                                            'Automation Account State' = $0.properties.State;
                                            'Automation Account SKU'   = $0.properties.sku.name;
                                            'Location'                 = $0.LOCATION;
                                            'Runbook Name'             = $1.Name;
                                            'Last Modified Time'       = ([datetime]$data.lastModifiedTime).tostring('MM/dd/yyyy hh:mm') ;
                                            'Runbook State'            = $data.state;
                                            'Runbook Type'             = $data.runbookType;
                                            'Runbook Description'      = $data.description;
                                            'Job Count'                = $data.jobCount;
                                            'Resource U'               = $ResUCount;
                                            'Tag Name'                 = $null;
                                            'Tag Value'                = $null
                                        }
                                        $tmp += $obj
                                        if ($ResUCount -eq 1) {$ResUCount = 0} 
                                }
                            }
                        }
                        else {
                            if (![string]::IsNullOrEmpty($Tag.Keys) -and $InTag -eq $true) {
                                foreach ($TagKey in $Tag.Keys) {  
                                    $obj = @{
                                        'Subscription'             = $sub1.name;
                                        'Resource Group'           = $0.RESOURCEGROUP;
                                        'Automation Account Name'  = $0.NAME;
                                        'Automation Account State' = $0.properties.State;
                                        'Automation Account SKU'   = $0.properties.sku.name;
                                        'Location'                 = $0.LOCATION;
                                        'Runbook Name'             = $null;
                                        'Last Modified Time'       = $null;
                                        'Runbook State'            = $null;
                                        'Runbook Type'             = $null;
                                        'Runbook Description'      = $null;
                                        'Job Count'                = $null;
                                        'Resource U'               = $ResUCount;
                                        'Tag Name'                 = [string]$TagKey;
                                        'Tag Value'                = [string]$Tag.$TagKey
                                    }
                                    $tmp += $obj
                                    if ($ResUCount -eq 1) {$ResUCount = 0} 
                                }
                            }
                            else {   
                                    $obj = @{
                                        'Subscription'             = $sub1.name;
                                        'Resource Group'           = $0.RESOURCEGROUP;
                                        'Automation Account Name'  = $0.NAME;
                                        'Automation Account State' = $0.properties.State;
                                        'Automation Account SKU'   = $0.properties.sku.name;
                                        'Location'                 = $0.LOCATION;
                                        'Runbook Name'             = $null;
                                        'Last Modified Time'       = $null;
                                        'Runbook State'            = $null;
                                        'Runbook Type'             = $null;
                                        'Runbook Description'      = $null;
                                        'Job Count'                = $null;
                                        'Resource U'               = $ResUCount;
                                        'Tag Name'                 = $null;
                                        'Tag Value'                = $null
                                    }
                                    $tmp += $obj
                                    if ($ResUCount -eq 1) {$ResUCount = 0} 
                            }
                        }
                    }
                    $tmp
                }).AddArgument($($args[0])).AddArgument($($args[1])).AddArgument($($args[3])).AddArgument($($args[4]))


            $EvtHub = ([PowerShell]::Create()).AddScript( { param($Sub, $InTag,$evthub)
                    $tmp = @()

                    $evthub = $evthub
                    $Subs = $Sub

                    foreach ($1 in $evthub) {
                        $ResUCount = 1
                        $sub1 = $SUBs | Where-Object { $_.id -eq $1.subscriptionId }
                        $data = $1.PROPERTIES
                        $sku = $1.SKU
                        $Tag = @{}
                        $1.tags.psobject.properties | ForEach-Object { $Tag[$_.Name] = $_.Value }
                        if (![string]::IsNullOrEmpty($Tag.Keys) -and $InTag -eq $true) {
                            foreach ($TagKey in $Tag.Keys) { 
                                    $obj = @{
                                        'Subscription'         = $sub1.name;
                                        'Resource Group'       = $1.RESOURCEGROUP;
                                        'Name'                 = $1.NAME;
                                        'Location'             = $1.LOCATION;
                                        'SKU'                  = $sku.name;
                                        'Status'               = $data.status;
                                        'Geo-Replication'      = $data.zoneRedundant;
                                        'Throughput Units'     = $1.sku.capacity;
                                        'Auto-Inflate'         = $data.isAutoInflateEnabled;
                                        'Max Throughput Units' = $data.maximumThroughputUnits;
                                        'Kafka Enabled'        = $data.kafkaEnabled;
                                        'Endpoint'             = $data.serviceBusEndpoint;
                                        'Resource U'           = $ResUCount;
                                        'Tag Name'             = [string]$TagKey;
                                        'Tag Value'            = [string]$Tag.$TagKey
                                    }
                                    $tmp += $obj
                                    if ($ResUCount -eq 1) {$ResUCount = 0} 
                                }
                            }
                            else { 
                                    $obj = @{
                                        'Subscription'         = $sub1.name;
                                        'Resource Group'       = $1.RESOURCEGROUP;
                                        'Name'                 = $1.NAME;
                                        'Location'             = $1.LOCATION;
                                        'SKU'                  = $sku.name;
                                        'Status'               = $data.status;
                                        'Geo-Replication'      = $data.zoneRedundant;
                                        'Throughput Units'     = $1.sku.capacity;
                                        'Auto-Inflate'         = $data.isAutoInflateEnabled;
                                        'Max Throughput Units' = $data.maximumThroughputUnits;
                                        'Kafka Enabled'        = $data.kafkaEnabled;
                                        'Endpoint'             = $data.serviceBusEndpoint;
                                        'Resource U'           = $ResUCount;
                                        'Tag Name'             = $null;
                                        'Tag Value'            = $null
                                    }
                                    $tmp += $obj
                                    if ($ResUCount -eq 1) {$ResUCount = 0} 
                            }
                    }
                    $tmp
                }).AddArgument($($args[0])).AddArgument($($args[1])).AddArgument($($args[5]))



            $WrkSpace = ([PowerShell]::Create()).AddScript( { param($Sub, $InTag,$WRKSPACE)
                    $tmp = @()

                    $wrkspace = $WRKSPACE
                    $Subs = $Sub

                    foreach ($1 in $wrkspace) {
                        $ResUCount = 1
                        $sub1 = $SUBs | Where-Object { $_.id -eq $1.subscriptionId }
                        $data = $1.PROPERTIES
                        $Tag = @{}
                        $1.tags.psobject.properties | ForEach-Object { $Tag[$_.Name] = $_.Value }
                        if (![string]::IsNullOrEmpty($Tag.Keys) -and $InTag -eq $true) {
                            foreach ($TagKey in $Tag.Keys) {
                                    $obj = @{
                                        'Subscription'     = $sub1.name;
                                        'Resource Group'   = $1.RESOURCEGROUP;
                                        'Name'             = $1.NAME;
                                        'Location'         = $1.LOCATION;
                                        'SKU'              = $data.sku.name;
                                        'Retention Days'   = $data.retentionInDays;
                                        'Daily Quota (GB)' = [decimal]$data.workspaceCapping.dailyQuotaGb;
                                        'Resource U'       = $ResUCount;
                                        'Tag Name'         = [string]$TagKey;
                                        'Tag Value'        = [string]$Tag.$TagKey
                                    }
                                    $tmp += $obj
                                    if ($ResUCount -eq 1) {$ResUCount = 0} 
                                }
                            }
                            else {
                                $obj = @{
                                    'Subscription'     = $sub1.name;
                                    'Resource Group'   = $1.RESOURCEGROUP;
                                    'Name'             = $1.NAME;
                                    'Location'         = $1.LOCATION;
                                    'SKU'              = $data.sku.name;
                                    'Retention Days'   = $data.retentionInDays;
                                    'Daily Quota (GB)' = [decimal]$data.workspaceCapping.dailyQuotaGb;
                                    'Resource U'       = $ResUCount;
                                    'Tag Name'         = $null;
                                    'Tag Value'        = $null
                                }
                                $tmp += $obj
                                if ($ResUCount -eq 1) {$ResUCount = 0} 
                            }
                    }
                    $tmp
                }).AddArgument($($args[0])).AddArgument($($args[1])).AddArgument($($args[6]))


            $AvSet = ([PowerShell]::Create()).AddScript( { param($Sub, $InTag,$AvSet)
                    $tmp = @()

                    $AvSet = $AvSet
                    $Subs = $Sub

                    foreach ($1 in $AvSet) {
                        $ResUCount = 1
                        $sub1 = $SUBs | Where-Object { $_.id -eq $1.subscriptionId }
                        $data = $1.PROPERTIES
                        $Tag = @{}
                        $1.tags.psobject.properties | ForEach-Object { $Tag[$_.Name] = $_.Value }
                        Foreach ($vmid in $data.virtualMachines.id) {
                            $vmIds = $vmid.split('/')[8]
                            if (![string]::IsNullOrEmpty($Tag.Keys) -and $InTag -eq $true) {
                                foreach ($TagKey in $Tag.Keys) {
                                        $obj = @{
                                            'Subscription'     = $sub1.name;
                                            'Resource Group'   = $1.RESOURCEGROUP;
                                            'Name'             = $1.NAME;
                                            'Location'         = $1.LOCATION;
                                            'Fault Domains'    = $data.platformFaultDomainCount;
                                            'Update Domains'   = $data.platformUpdateDomainCount;
                                            'Virtual Machines' = $vmIds;
                                            'Resource U'       = $ResUCount;
                                            'Tag Name'         = [string]$TagKey;
                                            'Tag Value'        = [string]$Tag.$TagKey
                                        }
                                        $tmp += $obj
                                        if ($ResUCount -eq 1) {$ResUCount = 0} 
                                    }
                                }
                                else {
                                        $obj = @{
                                            'Subscription'     = $sub1.name;
                                            'Resource Group'   = $1.RESOURCEGROUP;
                                            'Name'             = $1.NAME;
                                            'Location'         = $1.LOCATION;
                                            'Fault Domains'    = $data.platformFaultDomainCount;
                                            'Update Domains'   = $data.platformUpdateDomainCount;
                                            'Virtual Machines' = $vmIds;
                                            'Resource U'       = $ResUCount;
                                            'Tag Name'         = $null;
                                            'Tag Value'        = $null
                                        }
                                        $tmp += $obj
                                        if ($ResUCount -eq 1) {$ResUCount = 0} 
                                }
                        }
                    }
                    $tmp
                }).AddArgument($($args[0])).AddArgument($($args[1])).AddArgument($($args[7]))


            $WebSite = ([PowerShell]::Create()).AddScript( { param($Sub, $InTag,$SITES)
                    $tmp = @()

                    $WebSite = $SITES
                    $Subs = $Sub

                    foreach ($1 in $WebSite) {
                        $ResUCount = 1
                        $sub1 = $SUBs | Where-Object { $_.id -eq $1.subscriptionId }
                        $data = $1.PROPERTIES
                        $Tag = @{}
                        $1.tags.psobject.properties | ForEach-Object { $Tag[$_.Name] = $_.Value }
                        foreach ($2 in $data.hostNameSslStates) {
                            if (![string]::IsNullOrEmpty($Tag.Keys) -and $InTag -eq $true) {
                                foreach ($TagKey in $Tag.Keys) {
                                        $obj = @{
                                            'Subscription'                  = $sub1.name;
                                            'Resource Group'                = $1.RESOURCEGROUP;
                                            'Name'                          = $1.NAME;
                                            'Kind'                          = $1.KIND;
                                            'Location'                      = $1.LOCATION;
                                            'Enabled'                       = $data.enabled;
                                            'state'                         = $data.state;
                                            'SKU'                           = $data.sku;
                                            'Content Availability State'    = $data.contentAvailabilityState;
                                            'Runtime Availability State'    = $data.runtimeAvailabilityState;
                                            'Possible Inbound IP Addresses' = $data.possibleInboundIpAddresses;
                                            'Repository Site Name'          = $data.repositorySiteName;
                                            'Availability State'            = $data.availabilityState;
                                            'HostNames'                     = $2.Name;
                                            'HostName Type'                 = $2.hostType;
                                            'ssl State'                     = $2.sslState;
                                            'Default Hostname'              = $data.defaultHostName;
                                            'Client Cert Mode'              = $data.clientCertMode;
                                            'ContainerSize'                 = $data.containerSize;
                                            'Admin Enabled'                 = $data.adminEnabled;
                                            'FTPs Host Name'                = $data.ftpsHostName;
                                            'HTTPS Only'                    = $data.httpsOnly;
                                            'Resource U'                    = $ResUCount;
                                            'Tag Name'                      = [string]$TagKey;
                                            'Tag Value'                     = [string]$Tag.$TagKey
                                        }
                                        $tmp += $obj
                                        if ($ResUCount -eq 1) {$ResUCount = 0} 
                                    }
                                }
                                else {
                                    $obj = @{
                                        'Subscription'                  = $sub1.name;
                                        'Resource Group'                = $1.RESOURCEGROUP;
                                        'Name'                          = $1.NAME;
                                        'Kind'                          = $1.KIND;
                                        'Location'                      = $1.LOCATION;
                                        'Enabled'                       = $data.enabled;
                                        'state'                         = $data.state;
                                        'SKU'                           = $data.sku;
                                        'Content Availability State'    = $data.contentAvailabilityState;
                                        'Runtime Availability State'    = $data.runtimeAvailabilityState;
                                        'Possible Inbound IP Addresses' = $data.possibleInboundIpAddresses;
                                        'Repository Site Name'          = $data.repositorySiteName;
                                        'Availability State'            = $data.availabilityState;
                                        'HostNames'                     = $2.Name;
                                        'HostName Type'                 = $2.hostType;
                                        'ssl State'                     = $2.sslState;
                                        'Default Hostname'              = $data.defaultHostName;
                                        'Client Cert Mode'              = $data.clientCertMode;
                                        'ContainerSize'                 = $data.containerSize;
                                        'Admin Enabled'                 = $data.adminEnabled;
                                        'FTPs Host Name'                = $data.ftpsHostName;
                                        'HTTPS Only'                    = $data.httpsOnly;
                                        'Resource U'                    = $ResUCount;
                                        'Tag Name'                      = $null;
                                        'Tag Value'                     = $null
                                    }
                                    $tmp += $obj
                                    if ($ResUCount -eq 1) {$ResUCount = 0} 
                                }
                        }
                    }
                    $tmp
                }).AddArgument($($args[0])).AddArgument($($args[1])).AddArgument($($args[8]))


            $Vault = ([PowerShell]::Create()).AddScript( { param($Sub, $InTag,$VAULT)
                    $tmp = @()

                    $Subs = $Sub

                    foreach ($1 in $VAULT) {
                        $ResUCount = 1
                        $sub1 = $SUBs | Where-Object { $_.id -eq $1.subscriptionId }
                        $data = $1.PROPERTIES
                        $Tag = @{}
                        $1.tags.psobject.properties | ForEach-Object { $Tag[$_.Name] = $_.Value }
                        if (![string]::IsNullOrEmpty($Tag.Keys) -and $InTag -eq $true) {
                            foreach ($TagKey in $Tag.Keys) {
                                    $obj = @{
                                        'Subscription'                  = $sub1.name;
                                        'Resource Group'                = $1.RESOURCEGROUP;
                                        'Name'                          = $1.NAME;
                                        'Location'                      = $1.LOCATION;
                                        'SKU Family'                    = $data.sku.family;
                                        'SKU'                           = $data.sku.name;
                                        'Vault Uri'                     = $data.vaultUri;
                                        'Enable RBAC'                   = $data.enableRbacAuthorization;
                                        'Enable Soft Delete'            = $data.enableSoftDelete;
                                        'Enable for Disk Encryption'    = $data.enabledForDiskEncryption;
                                        'Enable for Template Deploy'    = $data.enabledForTemplateDeployment;
                                        'Soft Delete Retention Days'    = $data.softDeleteRetentionInDays;
                                        'Certificate Permissions'       = [string]$data.accessPolicies.permissions.certificates;
                                        'Key Permissions'               = [string]$data.accessPolicies.permissions.keys;
                                        'Secret Permissions'            = [string]$data.accessPolicies.permissions.secrets;
                                        'Resource U'                    = $ResUCount;
                                        'Tag Name'                      = [string]$TagKey;
                                        'Tag Value'                     = [string]$Tag.$TagKey
                                    }
                                    $tmp += $obj
                                    if ($ResUCount -eq 1) {$ResUCount = 0} 
                                }
                            }
                            else {
                                $obj = @{
                                    'Subscription'                  = $sub1.name;
                                    'Resource Group'                = $1.RESOURCEGROUP;
                                    'Name'                          = $1.NAME;
                                    'Location'                      = $1.LOCATION;
                                    'SKU Family'                    = $data.sku.family;
                                    'SKU'                           = $data.sku.name;
                                    'Vault Uri'                     = $data.vaultUri;
                                    'Enable RBAC'                   = $data.enableRbacAuthorization;
                                    'Enable Soft Delete'            = $data.enableSoftDelete;
                                    'Enable for Disk Encryption'    = $data.enabledForDiskEncryption;
                                    'Enable for Template Deploy'    = $data.enabledForTemplateDeployment;
                                    'Soft Delete Retention Days'    = $data.softDeleteRetentionInDays;
                                    'Certificate Permissions'       = [string]$data.accessPolicies.permissions.certificates;
                                    'Key Permissions'               = [string]$data.accessPolicies.permissions.keys;
                                    'Secret Permissions'            = [string]$data.accessPolicies.permissions.secrets;
                                    'Resource U'                    = $ResUCount;
                                    'Tag Name'                      = $null;
                                    'Tag Value'                     = $null
                                }
                                $tmp += $obj
                                if ($ResUCount -eq 1) {$ResUCount = 0} 
                            }
                    }
                    $tmp
                }).AddArgument($($args[0])).AddArgument($($args[1])).AddArgument($($args[9]))


            $RecoveryVault = ([PowerShell]::Create()).AddScript( { param($Sub, $InTag,$RECOVAULT)
                    $tmp = @()

                    $Subs = $Sub

                    foreach ($1 in $RECOVAULT) {
                        $ResUCount = 1
                        $sub1 = $SUBs | Where-Object { $_.id -eq $1.subscriptionId }
                        $data = $1.PROPERTIES
                        $Tag = @{}
                        $1.tags.psobject.properties | ForEach-Object { $Tag[$_.Name] = $_.Value }
                        if (![string]::IsNullOrEmpty($Tag.Keys) -and $InTag -eq $true) {
                            foreach ($TagKey in $Tag.Keys) {
                                    $obj = @{
                                        'Subscription'                  = $sub1.name;
                                        'Resource Group'                = $1.RESOURCEGROUP;
                                        'Name'                          = $1.NAME;
                                        'Location'                      = $1.LOCATION;
                                        'SKU Name'                      = $1.sku.name;
                                        'SKU Tier'                      = $1.sku.tier;
                                        'Private Endpoint State for Backup' = $data.privateEndpointStateForBackup;
                                        'Private Endpoint State for Site Recovery' = $data.privateEndpointStateForSiteRecovery;
                                        'Resource U'                    = $ResUCount;
                                        'Tag Name'                      = [string]$TagKey;
                                        'Tag Value'                     = [string]$Tag.$TagKey
                                    }
                                    $tmp += $obj
                                    if ($ResUCount -eq 1) {$ResUCount = 0} 
                                }
                            }
                            else {
                                $obj = @{
                                    'Subscription'                  = $sub1.name;
                                    'Resource Group'                = $1.RESOURCEGROUP;
                                    'Name'                          = $1.NAME;
                                    'Location'                      = $1.LOCATION;
                                    'SKU Name'                      = $1.sku.name;
                                    'SKU Tier'                      = $1.sku.tier;
                                    'Private Endpoint State for Backup' = $data.privateEndpointStateForBackup;
                                    'Private Endpoint State for Site Recovery' = $data.privateEndpointStateForSiteRecovery;
                                    'Resource U'                    = $ResUCount;
                                    'Tag Name'                      = $null;
                                    'Tag Value'                     = $null
                                }
                                $tmp += $obj
                                if ($ResUCount -eq 1) {$ResUCount = 0} 
                            }
                    }
                    $tmp
                }).AddArgument($($args[0])).AddArgument($($args[1])).AddArgument($($args[10]))                


                $APIM = ([PowerShell]::Create()).AddScript( { param($Sub, $InTag,$APIM)
                    $tmp = @()

                    $Subs = $Sub

                    foreach ($1 in $APIM) {
                        $ResUCount = 1
                        $sub1 = $SUBs | Where-Object { $_.id -eq $1.subscriptionId }
                        $data = $1.PROPERTIES
                        $Tag = @{}
                        $1.tags.psobject.properties | ForEach-Object { $Tag[$_.Name] = $_.Value }
                        if (![string]::IsNullOrEmpty($Tag.Keys) -and $InTag -eq $true) {
                            foreach ($TagKey in $Tag.Keys) {
                                    $obj = @{
                                        'Subscription'                  = $sub1.name;
                                        'Resource Group'                = $1.RESOURCEGROUP;
                                        'Name'                          = $1.NAME;
                                        'Location'                      = $1.LOCATION;
                                        'SKU'                           = $1.sku.name;
                                        'Gateway URL'                   = $data.gatewayUrl;
                                        'Virtual Network Type'          = $data.virtualNetworkType;
                                        'Virtual Network'               = $data.virtualNetworkConfiguration.subnetResourceId.split("/")[8];
                                        'Http2'                         = $data.customProperties."Microsoft.WindowsAzure.ApiManagement.Gateway.Protocols.Server.Http2";
                                        'Backend SSL 3.0'               = $data.customProperties."Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Ssl30";
                                        'Backend TLS 1.0'               = $data.customProperties."Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls10";
                                        'Backend TLS 1.1'               = $data.customProperties."Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls11";
                                        'Triple DES'                    = $data.customProperties."Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TripleDes168";
                                        'Client SSL 3.0'                = $data.customProperties."Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Ssl30";
                                        'Client TLS 1.0'                = $data.customProperties."Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls10";
                                        'Client TLS 1.1'                = $data.customProperties."Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls11";
                                        'Public IP'                     = [string]$data.publicIPAddresses;
                                        'Tag Name'                      = [string]$TagKey;
                                        'Tag Value'                     = [string]$Tag.$TagKey
                                    }
                                    $tmp += $obj
                                    if ($ResUCount -eq 1) {$ResUCount = 0} 
                                }
                            }
                            else {
                                $obj = @{
                                    'Subscription'                  = $sub1.name;
                                    'Resource Group'                = $1.RESOURCEGROUP;
                                    'Name'                          = $1.NAME;
                                    'Location'                      = $1.LOCATION;
                                    'SKU'                           = $1.sku.name;
                                    'Gateway URL'                   = $data.gatewayUrl;
                                    'Virtual Network Type'          = $data.virtualNetworkType;
                                    'Virtual Network'               = $data.virtualNetworkConfiguration.subnetResourceId.split("/")[8];
                                    'Http2'                         = $data.customProperties."Microsoft.WindowsAzure.ApiManagement.Gateway.Protocols.Server.Http2";
                                    'Backend SSL 3.0'               = $data.customProperties."Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Ssl30";
                                    'Backend TLS 1.0'               = $data.customProperties."Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls10";
                                    'Backend TLS 1.1'               = $data.customProperties."Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls11";
                                    'Triple DES'                    = $data.customProperties."Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TripleDes168";
                                    'Client SSL 3.0'                = $data.customProperties."Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Ssl30";
                                    'Client TLS 1.0'                = $data.customProperties."Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls10";
                                    'Client TLS 1.1'                = $data.customProperties."Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls11";
                                    'Public IP'                     = [string]$data.publicIPAddresses;
                                    'Tag Name'                      = $null;
                                    'Tag Value'                     = $null
                                }
                                $tmp += $obj
                                if ($ResUCount -eq 1) {$ResUCount = 0} 
                            }
                    }
                    $tmp
                }).AddArgument($($args[0])).AddArgument($($args[1])).AddArgument($($args[11]))                



                
            $jobStorageAcc = $StorageAcc.BeginInvoke()
            $jobAutAcc = $AutAcc.BeginInvoke()
            $jobEvtHub = $EvtHub.BeginInvoke()
            $jobWrkSpace = $WrkSpace.BeginInvoke()
            $jobAvSet = $AvSet.BeginInvoke()
            $jobWebSite = $WebSite.BeginInvoke()
            $jobVault = $Vault.BeginInvoke()
            $jobRecoveryVault = $RecoveryVault.BeginInvoke()
            $jobAPIM = $APIM.BeginInvoke()

            $job += $jobStorageAcc
            $job += $jobAutAcc
            $job += $jobEvtHub
            $job += $jobWrkSpace
            $job += $jobAvSet
            $job += $jobWebSite
            $job += $jobVault
            $job += $jobRecoveryVault
            $job += $APIM

            while ($Job.Runspace.IsCompleted -contains $false) {}

            $StorageAccS = $StorageAcc.EndInvoke($jobStorageAcc)
            $AutAccS = $AutAcc.EndInvoke($jobAutAcc)
            $EvtHubS = $EvtHub.EndInvoke($jobEvtHub)
            $WrkSpaceS = $WrkSpace.EndInvoke($jobWrkSpace)
            $AvSetS = $AvSet.EndInvoke($jobAvSet)
            $WebSiteS = $WebSite.EndInvoke($jobWebSite)
            $VaultS = $Vault.EndInvoke($jobVault)
            $RecoveryVaultS = $RecoveryVault.EndInvoke($jobRecoveryVault)
            $APIMS = $APIM.EndInvoke($jobAPIM)

            $StorageAcc.Dispose()
            $AutAcc.Dispose()
            $EvtHub.Dispose()
            $WrkSpace.Dispose()
            $AvSet.Dispose()
            $WebSite.Dispose()
            $Vault.Dispose()
            $RecoveryVault.Dispose()
            $APIM.Dispose()

            $AzInfra = @{
                'StorageAcc'    = $StorageAccS;
                'AutomationAcc' = $AutAccS;
                'EvtHub'        = $EvtHubS;
                'WrkSpace'      = $WrkSpaceS;
                'AvSet'         = $AvSetS;
                'WebSite'       = $WebSiteS;
                'Vault'         = $VaultS;
                'RecoveryVault' = $RecoveryVaultS;
                'APIM'          = $APIMS
            }

            $AzInfra

        } -ArgumentList $Subs, $InTag,$StorageAcc, $RB, $AUT, $EVTHUB, $WRKSPACE, $AVSET, $SITES, $VAULT, $RECOVERYVAULT, $APIM | Out-Null



        <######################################################### DATABASES RESOURCE GROUP JOB ######################################################################>


        Start-Job -Name 'Database' -ScriptBlock {

            $job = @()

            $DB = ([PowerShell]::Create()).AddScript( { param($Sub, $InTag,$DB)
                    $tmp = @()

                    $db = $DB
                    $Subs = $Sub

                    foreach ($1 in $db) {
                        $ResUCount = 1
                        $sub1 = $SUBs | Where-Object { $_.id -eq $1.subscriptionId }
                        $data = $1.PROPERTIES
                        $Tag = @{}
                        $1.tags.psobject.properties | ForEach-Object { $Tag[$_.Name] = $_.Value }
                        if (![string]::IsNullOrEmpty($Tag.Keys) -and $InTag -eq $true) {
                            foreach ($TagKey in $Tag.Keys) {
                                    $obj = @{
                                        'Subscription'               = $sub1.name;
                                        'Resource Group'             = $1.RESOURCEGROUP;
                                        'Name'                       = $1.NAME;
                                        'Location'                   = $1.LOCATION;
                                        'Storage Account Type'       = $data.storageAccountType;
                                        'Default Secondary Location' = $data.defaultSecondaryLocation;
                                        'Status'                     = $data.status;
                                        'DTU Capacity'               = $data.currentSku.capacity;
                                        'DTU Tier'                   = $data.requestedServiceObjectiveName;
                                        'Zone Redundant'             = $data.zoneRedundant;
                                        'Catalog Collation'          = $data.catalogCollation;
                                        'Read Replica Count'         = $data.readReplicaCount;
                                        'Data Max Size (GB)'         = (($data.maxSizeBytes / 1024) / 1024) / 1024;
                                        'Resource U'                 = $ResUCount;
                                        'Tag Name'                   = [string]$TagKey;
                                        'Tag Value'                  = [string]$Tag.$TagKey
                                    }
                                    $tmp += $obj
                                    if ($ResUCount -eq 1) {$ResUCount = 0} 
                                }
                            }
                            else {
                                $obj = @{
                                    'Subscription'               = $sub1.name;
                                    'Resource Group'             = $1.RESOURCEGROUP;
                                    'Name'                       = $1.NAME;
                                    'Location'                   = $1.LOCATION;
                                    'Storage Account Type'       = $data.storageAccountType;
                                    'Default Secondary Location' = $data.defaultSecondaryLocation;
                                    'Status'                     = $data.status;
                                    'DTU Capacity'               = $data.currentSku.capacity;
                                    'DTU Tier'                   = $data.requestedServiceObjectiveName;
                                    'Zone Redundant'             = $data.zoneRedundant;
                                    'Catalog Collation'          = $data.catalogCollation;
                                    'Read Replica Count'         = $data.readReplicaCount;
                                    'Data Max Size (GB)'         = (($data.maxSizeBytes / 1024) / 1024) / 1024;
                                    'Resource U'                 = $ResUCount;
                                    'Tag Name'                   = $null;
                                    'Tag Value'                  = $null
                                }
                                $tmp += $obj
                                if ($ResUCount -eq 1) {$ResUCount = 0} 
                            }
                    }
                    $tmp
                }).AddArgument($($args[0])).AddArgument($($args[1])).AddArgument($($args[2]))

            $MySQL = ([PowerShell]::Create()).AddScript( { param($Sub, $InTag,$MySQL)
                    $tmp = @()

                    $mysql = $MySQL
                    $Subs = $Sub

                    foreach ($1 in $mysql) {
                        $ResUCount = 1
                        $sub1 = $SUBs | Where-Object { $_.id -eq $1.subscriptionId }
                        $data = $1.PROPERTIES
                        $sku = $1.SKU
                        $Tag = @{}
                        $1.tags.psobject.properties | ForEach-Object { $Tag[$_.Name] = $_.Value }
                        if (![string]::IsNullOrEmpty($Tag.Keys) -and $InTag -eq $true) {
                            foreach ($TagKey in $Tag.Keys) {
                                    $obj = @{
                                        'Subscription'              = $sub1.name;
                                        'Resource Group'            = $1.RESOURCEGROUP;
                                        'Name'                      = $1.NAME;
                                        'Location'                  = $1.LOCATION;
                                        'SKU'                       = $sku.name;
                                        'SKU Family'                = $sku.family;
                                        'Tier'                      = $sku.tier;
                                        'Capacity'                  = $sku.capacity;
                                        'MySQL Version'             = $data.version;
                                        'Backup Retention Days'     = $data.storageProfile.backupRetentionDays;
                                        'Geo-Redundant Backup'      = $data.storageProfile.geoRedundantBackup;
                                        'Auto Grow'                 = $data.storageProfile.storageAutogrow;
                                        'Storage MB'                = $data.storageProfile.storageMB;
                                        'Public Network Access'     = $data.publicNetworkAccess;
                                        'Admin Login'               = $data.administratorLogin;
                                        'Infrastructure Encryption' = $data.InfrastructureEncryption;
                                        'Minimal Tls Version'       = $data.minimalTlsVersion;
                                        'State'                     = $data.userVisibleState;
                                        'Replica Capacity'          = $data.replicaCapacity;
                                        'Replication Role'          = $data.replicationRole;
                                        'BYOK Enforcement'          = $data.byokEnforcement;
                                        'ssl Enforcement'           = $data.sslEnforcement;
                                        'Resource U'                = $ResUCount;
                                        'Tag Name'                  = [string]$TagKey;
                                        'Tag Value'                 = [string]$Tag.$TagKey
                                    }
                                    $tmp += $obj
                                    if ($ResUCount -eq 1) {$ResUCount = 0} 
                                }
                            }
                            else {
                                $obj = @{
                                    'Subscription'              = $sub1.name;
                                    'Resource Group'            = $1.RESOURCEGROUP;
                                    'Name'                      = $1.NAME;
                                    'Location'                  = $1.LOCATION;
                                    'SKU'                       = $sku.name;
                                    'SKU Family'                = $sku.family;
                                    'Tier'                      = $sku.tier;
                                    'Capacity'                  = $sku.capacity;
                                    'MySQL Version'             = $data.version;
                                    'Backup Retention Days'     = $data.storageProfile.backupRetentionDays;
                                    'Geo-Redundant Backup'      = $data.storageProfile.geoRedundantBackup;
                                    'Auto Grow'                 = $data.storageProfile.storageAutogrow;
                                    'Storage MB'                = $data.storageProfile.storageMB;
                                    'Public Network Access'     = $data.publicNetworkAccess;
                                    'Admin Login'               = $data.administratorLogin;
                                    'Infrastructure Encryption' = $data.InfrastructureEncryption;
                                    'Minimal Tls Version'       = $data.minimalTlsVersion;
                                    'State'                     = $data.userVisibleState;
                                    'Replica Capacity'          = $data.replicaCapacity;
                                    'Replication Role'          = $data.replicationRole;
                                    'BYOK Enforcement'          = $data.byokEnforcement;
                                    'ssl Enforcement'           = $data.sslEnforcement;
                                    'Resource U'                = $ResUCount;
                                    'Tag Name'                  = $null;
                                    'Tag Value'                 = $null
                                }
                                $tmp += $obj
                                if ($ResUCount -eq 1) {$ResUCount = 0} 
                            }
                    }
                    $tmp
                }).AddArgument($($args[0])).AddArgument($($args[1])).AddArgument($($args[3]))

            $PostGre = ([PowerShell]::Create()).AddScript( { param($Sub, $InTag,$PostGre)
                    $tmp = @()

                    $postgre = $PostGre
                    $Subs = $Sub

                    foreach ($1 in $postgre) {
                        $ResUCount = 1
                        $sub1 = $SUBs | Where-Object { $_.id -eq $1.subscriptionId }
                        $data = $1.PROPERTIES
                        $sku = $1.SKU
                        $Tag = @{}
                        $1.tags.psobject.properties | ForEach-Object { $Tag[$_.Name] = $_.Value }
                        if (![string]::IsNullOrEmpty($Tag.Keys) -and $InTag -eq $true) {
                            foreach ($TagKey in $Tag.Keys) {
                                    $obj = @{
                                        'Subscription'              = $sub1.name;
                                        'Resource Group'            = $1.RESOURCEGROUP;
                                        'Name'                      = $1.NAME;
                                        'Location'                  = $1.LOCATION;
                                        'SKU'                       = $sku.name;
                                        'SKU Family'                = $sku.family;
                                        'Tier'                      = $sku.tier;
                                        'Capacity'                  = $sku.capacity;
                                        'MySQL Version'             = $data.version;
                                        'Backup Retention Days'     = $data.storageProfile.backupRetentionDays;
                                        'Geo-Redundant Backup'      = $data.storageProfile.geoRedundantBackup;
                                        'Auto Grow'                 = $data.storageProfile.storageAutogrow;
                                        'Storage MB'                = $data.storageProfile.storageMB;
                                        'Public Network Access'     = $data.publicNetworkAccess;
                                        'Admin Login'               = $data.administratorLogin;
                                        'Infrastructure Encryption' = $data.InfrastructureEncryption;
                                        'Minimal Tls Version'       = $data.minimalTlsVersion;
                                        'State'                     = $data.userVisibleState;
                                        'Replica Capacity'          = $data.replicaCapacity;
                                        'Replication Role'          = $data.replicationRole;
                                        'BYOK Enforcement'          = $data.byokEnforcement;
                                        'ssl Enforcement'           = $data.sslEnforcement;
                                        'Resource U'                = $ResUCount;
                                        'Tag Name'                  = [string]$TagKey;
                                        'Tag Value'                 = [string]$Tag.$TagKey
                                    }
                                    $tmp += $obj
                                    if ($ResUCount -eq 1) {$ResUCount = 0} 
                                }
                            }
                            else {
                                $obj = @{
                                    'Subscription'              = $sub1.name;
                                    'Resource Group'            = $1.RESOURCEGROUP;
                                    'Name'                      = $1.NAME;
                                    'Location'                  = $1.LOCATION;
                                    'SKU'                       = $sku.name;
                                    'SKU Family'                = $sku.family;
                                    'Tier'                      = $sku.tier;
                                    'Capacity'                  = $sku.capacity;
                                    'MySQL Version'             = $data.version;
                                    'Backup Retention Days'     = $data.storageProfile.backupRetentionDays;
                                    'Geo-Redundant Backup'      = $data.storageProfile.geoRedundantBackup;
                                    'Auto Grow'                 = $data.storageProfile.storageAutogrow;
                                    'Storage MB'                = $data.storageProfile.storageMB;
                                    'Public Network Access'     = $data.publicNetworkAccess;
                                    'Admin Login'               = $data.administratorLogin;
                                    'Infrastructure Encryption' = $data.InfrastructureEncryption;
                                    'Minimal Tls Version'       = $data.minimalTlsVersion;
                                    'State'                     = $data.userVisibleState;
                                    'Replica Capacity'          = $data.replicaCapacity;
                                    'Replication Role'          = $data.replicationRole;
                                    'BYOK Enforcement'          = $data.byokEnforcement;
                                    'ssl Enforcement'           = $data.sslEnforcement;
                                    'Resource U'                = $ResUCount;
                                    'Tag Name'                  = $null;
                                    'Tag Value'                 = $null
                                }
                                $tmp += $obj
                                if ($ResUCount -eq 1) {$ResUCount = 0} 
                            }
                    }
                    $tmp
                }).AddArgument($($args[0])).AddArgument($($args[1])).AddArgument($($args[4]))

            $jobDB = $DB.BeginInvoke()
            $jobMySQL = $MySQL.BeginInvoke()
            $jobPostGre = $PostGre.BeginInvoke()

            $job += $jobDB
            $job += $jobMySQL
            $job += $jobPostGre

            while ($Job.Runspace.IsCompleted -contains $false) {}

            $DBS = $DB.EndInvoke($jobDB)
            $MySQLS = $MySQL.EndInvoke($jobMySQL)
            $PostGreS = $PostGre.EndInvoke($jobPostGre)

            $DB.Dispose()
            $MySQL.Dispose()
            $PostGre.Dispose()

            $AzDB = @{
                'DB'      = $DBS;
                'MySQL'   = $MySQLS;
                'PostGre' = $PostGreS
            }

            $AzDB

        } -ArgumentList $Subs, $InTag,$DB, $MySQL, $POSTGRE | Out-Null



        <########################################## INITIAL VALIDATIONS ######################################################>

        #### Creating Excel file variable:
        $Global:File = ($DefaultPath + "AzureResourceInventory_Report_" + (get-date -Format "yyyy-MM-dd_HH_mm") + ".xlsx")
        Write-Debug ('Excel file:' + $File)

        #### Generic Conditional Text rules, Excel style specifications for the spreadsheets and tables:
        $tableStyle = "Light20"
        Write-Debug ('Excel Table Style used: ' + $tableStyle)

        #### Number of Resource Types to be considered in the script:
        $ResourceTypes = 100
        Write-Debug ('Number of Resource Types considered in Excel: ' + $ResourceTypes)


        <################################################ ADVISOR #######################################################>

        #### Advisor worksheet is always the first sheet created:
        Write-Debug ('Generating Advisor sheet.')
        if ($Advisories) {

            $condtxtadv = $(New-ConditionalText High -Range E:E
                New-ConditionalText Security -Range D:D -BackgroundColor Wheat)

            $Global:advco = $Advisories.count

            $DataActive = ('Azure Resource Inventory Reporting (' + ($resources.count) + ') Resources')

            Write-Progress -activity $DataActive -Status "Building Advisories Report" -PercentComplete 0 -CurrentOperation "Considering $advco Advisories"
        
            while (get-job -Name 'Advisory' | Where-Object { $_.State -eq 'Running' }) {
                Write-Progress -Id 1 -activity 'Processing Advisories' -Status "50% Complete." -PercentComplete 50
                Start-Sleep -Seconds 2
            }
            Write-Progress -Id 1 -activity 'Processing Advisories'  -Status "100% Complete." -Completed

            $Adv = Receive-Job -Name 'Advisory'

            $Adv | 
            ForEach-Object { [PSCustomObject]$_ } | 
            Select-Object 'ResourceGroup',
            'Affected Resource Type',
            'Name', 'Category',
            'Impact',
            'Score',
            'Problem' | 
            Export-Excel -Path $File -WorksheetName 'Advisor' -AutoSize -TableName 'AzureAdvisor' -TableStyle $tableStyle -ConditionalText $condtxtadv -KillExcel 

        }

        <################################################ Security Center #######################################################>

        #### Security Center worksheet is always the third sequence:
        Write-Debug ('Generating Security Center sheet.')
        if ($Security) {

            $condtxtsec = $(New-ConditionalText High -Range G:G
                New-ConditionalText High -Range L:L)

            $Global:Secadvco = $Security.Count

            Write-Progress -activity $DataActive -Status "Building Security Center Report" -PercentComplete 0 -CurrentOperation "Considering $Secadvco Security Advisories"

            while (get-job -Name 'Security' | Where-Object { $_.State -eq 'Running' }) {
                Write-Progress -Id 1 -activity 'Processing Security Center Advisories' -Status "50% Complete." -PercentComplete 50
                Start-Sleep -Seconds 2
            }
            Write-Progress -Id 1 -activity 'Processing Security Center Advisories'  -Status "100% Complete." -Completed

            $Sec = Receive-Job -Name 'Security'

            $Sec | 
            ForEach-Object { [PSCustomObject]$_ } | 
            Select-Object 'Subscription ID',
            'Resource Group',
            'Resource Type',
            'Resource Name',
            'Categories',
            'Control',
            'Severity',
            'Status',
            'Remediation',
            'Remediation Effort',
            'User Impact',
            'Threats' | 
            Export-Excel -Path $File -WorksheetName 'SecurityCenter' -AutoSize -TableName 'SecurityCenter' -TableStyle $tableStyle -ConditionalText $condtxtsec -KillExcel 

        }

        <############################################################## RESOURCES LOOP CREATION #############################################################>

        $TableExclusion = @(
            'microsoft.advisor/recommendations',
            'microsoft.security/assessments',
            'microsoft.automation/automationaccounts/configurations',
            'microsoft.compute/virtualmachines/extensions',
            'microsoft.network/networkinterfaces',
            'microsoft.network/networksecuritygroups',
            'microsoft.insights/workbooks',
            'microsoft.web/connections',
            'microsoft.resourcegraph/queries',
            'microsoft.compute/sshpublickeys',
            'microsoft.insights/activitylogalerts',
            'microsoft.insights/metricalerts',
            'microsoft.network/networkwatchers/connectionmonitors',
            'microsoft.network/networkwatchers')

        $LoopTable = $resources.TYPE | Where-Object { $_.Name -ne 'TYPE' } | Group-Object | Select-Object 'Count', 'Name' | Where-Object { $_.Name -notin $TableExclusion } |  Sort-Object 'Count' -Descending | Select-Object -First $ResourceTypes

        Write-Debug ('Processing: ') -NoNewline
        write-Debug ($resources.Count - $adv.count) -NoNewline -ForegroundColor Magenta
        Write-Debug (' Resources and ') -NoNewline
        write-Debug $adv.count -NoNewline -ForegroundColor Magenta
        Write-Debug (' Advisories.')

        #### Validated Resources:
        #### 1 - Virtual Machines
        #### 2 - Virtual Machines Disk
        #### 3 - Storage Account
        #### 4 - Virtual Network
        #### 5 - Virtual Network Gateway
        #### 6 - SQL Virtual Machines
        #### 7 - SQL Databases
        #### 8 - Automation Acc / Runbooks
        #### 9 - Public IPs
        #### 10 - Event Hubs
        #### 11 - MySQL
        #### 12 - Postgres
        #### 13 - Web Server Farm
        #### 14 - Workspaces
        #### 15 - AKS
        #### 16 - Containers
        #### 17 - Availability Sets
        #### 18 - Web Sites
        #### 19 - VM Scale Sets
        #### 20 - Load Balancers
        #### 21 - SQL Servers
        #### 22 - VNET Peering
        #### 23 - FrontDoor
        #### 24 - Application Gateway
        #### 25 - Route Table
        #### 26 - Key Vault
        #### 27 - Recovery Vault
        #### 28 - DNS Zone
        #### 29 - IOT
        #### 30 - APIM

        Write-Progress -activity $DataActive -Status "Processing Resources Inventory" -PercentComplete 0
        $c = 0
        while (get-job -Name 'Compute', 'Network', 'Infra', 'Database' | Where-Object { $_.State -eq 'Running' }) {
            $jb = get-job -Name 'Compute', 'Network', 'Infra', 'Database'
            $c = (((($jb.count - ($jb | Where-Object { $_.State -eq 'Running' }).Count)) / $jb.Count) * 100)
            $c = [math]::Round($c)
            Write-Progress -Id 1 -activity "Processing Resource Groups" -Status "$c% Complete." -PercentComplete $c
            Start-Sleep -Seconds 2
        }
        Write-Progress -Id 1 -activity "Processing Resource Groups" -Status "100% Complete." -Completed


        $AzCompute = Receive-Job -Name 'Compute'
        $AzNetwork = Receive-Job -Name 'Network'
        $AzInfra = Receive-Job -Name 'Infra'
        $AzDatabase = Receive-Job -Name 'Database'


        #### Begin of the Resources Loop:
        Write-Debug ('Entering Resource Type loop')

        $c = 0

        Foreach ($Type in $LoopTable.name) {
            $Prog = ($c / $LoopTable.count) * 100
            $Prog = [math]::Round($Prog)
                
            <############################################################## 1 - Virtual Machines ###################################################################>

            if ($Type -eq 'microsoft.compute/virtualmachines') {

                Write-Progress -activity $DataActive -Status "$Prog% Complete." -PercentComplete $Prog 
                $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0' -VerticalAlignment Center
                $StyleExt = New-ExcelStyle -HorizontalAlignment Left -Range AE:AE -Width 60 -WrapText 
                $condtxtvm = $(New-ConditionalText None -Range X:X
                    New-ConditionalText false -Range L:L
                    New-ConditionalText falso -Range L:L
                    New-ConditionalText false -Range M:M
                    New-ConditionalText falso -Range M:M
                    New-ConditionalText false -Range N:N
                    New-ConditionalText falso -Range N:N
                    New-ConditionalText false -Range Y:Y
                    New-ConditionalText falso -Range Y:Y)


                $ExcelVMs = $AzCompute.VM

                if ($IncludeTags.IsPresent) 
                    {
                        $ExcelVMs | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Computer Name',
                        'VM Size',
                        'OS Type',
                        'Location',
                        'Image Reference',
                        'Image Version',
                        'SKU',
                        'Admin Username',
                        'Update Management',
                        'Boot Diagnostics',
                        'Performance Diagnostic Agent',
                        'Azure Monitor',
                        'OS Disk Storage Type',
                        'OS Disk Size (GB)',
                        'Data Disk Storage Type',
                        'Data Disk Size (GB)',
                        'Power State',
                        'Availability Set',
                        'Zone',
                        'NIC Name',
                        'NIC Type',
                        'NSG',
                        'Enable Accelerated Networking',
                        'Enable IP Forwarding',
                        'Primary IP',
                        'Private IP Version',
                        'Private IP Address',
                        'Private IP Allocation Method',
                        'VM Extensions',
                        'Resource U',
                        'Tag Name',
                        'Tag Value' | 
                        Export-Excel -Path $File -WorksheetName 'VMs' -TableName 'AzureVMs' -TableStyle $tableStyle -ConditionalText $condtxtvm -Style $Style, $StyleExt
                    }
                    else 
                    {
                        $ExcelVMs | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Computer Name',
                        'VM Size',
                        'OS Type',
                        'Location',
                        'Image Reference',
                        'Image Version',
                        'SKU',
                        'Admin Username',
                        'Update Management',
                        'Boot Diagnostics',
                        'Performance Diagnostic Agent',
                        'Azure Monitor',
                        'OS Disk Storage Type',
                        'OS Disk Size (GB)',
                        'Data Disk Storage Type',
                        'Data Disk Size (GB)',
                        'Power State',
                        'Availability Set',
                        'Zone',
                        'NIC Name',
                        'NIC Type',
                        'NSG',
                        'Enable Accelerated Networking',
                        'Enable IP Forwarding',
                        'Primary IP',
                        'Private IP Version',
                        'Private IP Address',
                        'Private IP Allocation Method',
                        'VM Extensions',
                        'Resource U' | 
                        Export-Excel -Path $File -WorksheetName 'VMs' -TableName 'AzureVMs' -TableStyle $tableStyle -ConditionalText $condtxtvm -Style $Style, $StyleExt
                    }

            }

            <################################################################# 2 - Virtual Machine Disks ###################################################################>

            if ($Type -eq 'microsoft.compute/disks') {

                Write-Progress -activity $DataActive -Status "$Prog% Complete." -PercentComplete $Prog 
                $condtxtdsk = New-ConditionalText Unattached -Range K:K
                $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'
         

                $ExcelVMDisks = $AzCompute.VMDisk
                        
                if ($IncludeTags.IsPresent)
                    {
                        $ExcelVMDisks | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Virtual Machine',
                        'Disk Name',
                        'Zone',
                        'SKU',
                        'Disk Size',
                        'Location',
                        'Encryption',
                        'OS Type',
                        'Disk State',
                        'Disk IOPS Read / Write',
                        'Disk MBps Read / Write',
                        'HyperV Generation',
                        'Tag Name',
                        'Tag Value' | 
                        Export-Excel -Path $File -WorksheetName 'Disks' -TableName 'AzureDisks' -TableStyle $tableStyle -ConditionalText $condtxtdsk -Style $Style
                    }
                else 
                    {
                        $ExcelVMDisks | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Virtual Machine',
                        'Disk Name',
                        'Zone',
                        'SKU',
                        'Disk Size',
                        'Location',
                        'Encryption',
                        'OS Type',
                        'Disk State',
                        'Disk IOPS Read / Write',
                        'Disk MBps Read / Write',
                        'HyperV Generation' | 
                        Export-Excel -Path $File -WorksheetName 'Disks' -TableName 'AzureDisks' -TableStyle $tableStyle -ConditionalText $condtxtdsk -Style $Style
                    }

            }


            <############################################################################## 3 - Storage Account ###################################################################>


            if ($Type -eq 'microsoft.storage/storageaccounts') {

                Write-Progress -activity $DataActive -Status "$Prog% Complete." -PercentComplete $Prog 
                $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0

                $condtxtStorage = $(New-ConditionalText false -Range F:F
                    New-ConditionalText falso -Range F:F
                    New-ConditionalText true -Range G:G
                    New-ConditionalText verdadeiro -Range G:G
                    New-ConditionalText 1.0 -Range H:H)

                $ExcelStorageAcc = $AzInfra.StorageAcc
            
                if ($IncludeTags.IsPresent)
                    {
                        $ExcelStorageAcc | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Name',
                        'Location',
                        'Zone',
                        'Supports HTTPS Traffic Only',
                        'Allow Blob Public Access',
                        'TLS Version',
                        'Identity-based access for file shares',
                        'Access Tier',
                        'Primary Location',
                        'Status Of Primary',
                        'Secondary Location',
                        'Blob Address',
                        'File Address',
                        'Table Address',
                        'Queue Address',
                        'Network Acls',
                        'Tag Name',
                        'Tag Value'  | 
                        Export-Excel -Path $File -WorksheetName 'StorageAcc' -AutoSize -TableName 'AzureStorageAccs' -TableStyle $tableStyle -ConditionalText $condtxtStorage -Style $Style
                    }
                else 
                    {
                        $ExcelStorageAcc | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Name',
                        'Location',
                        'Zone',
                        'Supports HTTPS Traffic Only',
                        'Allow Blob Public Access',
                        'TLS Version',
                        'Identity-based access for file shares',
                        'Access Tier',
                        'Primary Location',
                        'Status Of Primary',
                        'Secondary Location',
                        'Blob Address',
                        'File Address',
                        'Table Address',
                        'Queue Address',
                        'Network Acls' | 
                        Export-Excel -Path $File -WorksheetName 'StorageAcc' -AutoSize -TableName 'AzureStorageAccs' -TableStyle $tableStyle -ConditionalText $condtxtStorage -Style $Style
                    }
            }


            <############################################################################## 4 - Virtual Network  ###################################################################>

            if ($Type -eq 'microsoft.network/virtualnetworks') {
                Write-Progress -activity $DataActive -Status "$Prog% Complete." -PercentComplete $Prog 
                $txtvnet = $(New-ConditionalText false -Range G:H
                    New-ConditionalText falso -Range G:H)

                $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

                $ExcelVNET = $AzNetwork.VNET          

                if ($IncludeTags.IsPresent)
                    {
                        $ExcelVNET | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Name',
                        'Location',
                        'Zone',
                        'Address Space',
                        'Enable DDOS Protection',
                        'Enable VM Protection',
                        'Subnet Name',
                        'Subnet Prefix',
                        'Subnet Private Link Service Network Policies',
                        'Subnet Private Endpoint Network Policies',
                        'Tag Name',
                        'Tag Value'  | 
                        Export-Excel -Path $File -WorksheetName 'VNET' -AutoSize -TableName 'AzureVNETs' -TableStyle $tableStyle -ConditionalText $txtvnet -Style $Style
                    }
                else 
                    {
                        $ExcelVNET | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Name',
                        'Location',
                        'Zone',
                        'Address Space',
                        'Enable DDOS Protection',
                        'Enable VM Protection',
                        'Subnet Name',
                        'Subnet Prefix',
                        'Subnet Private Link Service Network Policies',
                        'Subnet Private Endpoint Network Policies'| 
                        Export-Excel -Path $File -WorksheetName 'VNET' -AutoSize -TableName 'AzureVNETs' -TableStyle $tableStyle -ConditionalText $txtvnet -Style $Style
                    }

            }


            <############################################################################## 5 - Virtual Network Gateway  ###################################################################>


            if ($Type -eq 'microsoft.network/virtualnetworkgateways') {

                Write-Progress -activity $DataActive -Status "$Prog% Complete." -PercentComplete $Prog
                $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'
    
                $ExcelVNETGTW = $AzNetwork.VNETGTW
                        
                if ($IncludeTags.IsPresent)
                    {
                        $ExcelVNETGTW | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Name',
                        'Location',
                        'SKU',
                        'Active-active mode',
                        'Gateway Type',
                        'Gateway Generation',
                        'VPN Type',
                        'Enable Private Address',
                        'Enable BGP',
                        'BGP ASN',
                        'BGP Peering Address',
                        'BGP Peer Weight',
                        'Gateway Public IP',
                        'Gateway Subnet Name',
                        'Tag Name',
                        'Tag Value'  | 
                        Export-Excel -Path $File -WorksheetName 'Gateways' -AutoSize -TableName 'AzureVNETGateways' -TableStyle $tableStyle -ConditionalText $txtvnet -Style $Style
                    }
                else 
                    {
                        $ExcelVNETGTW | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Name',
                        'Location',
                        'SKU',
                        'Active-active mode',
                        'Gateway Type',
                        'Gateway Generation',
                        'VPN Type',
                        'Enable Private Address',
                        'Enable BGP',
                        'BGP ASN',
                        'BGP Peering Address',
                        'BGP Peer Weight',
                        'Gateway Public IP',
                        'Gateway Subnet Name'| 
                        Export-Excel -Path $File -WorksheetName 'Gateways' -AutoSize -TableName 'AzureVNETGateways' -TableStyle $tableStyle -ConditionalText $txtvnet -Style $Style
                    }
    
            }
    

            <############################################################################## 6 - SQL Virtual Machines  ###################################################################>


            if ($Type -eq 'microsoft.sqlvirtualmachine/sqlvirtualmachines') {

                Write-Progress -activity $DataActive -Status "$Prog% Complete." -PercentComplete $Prog 
                Write-Debug ('Generating SQL Virtual Machines sheet for: ' + $sqlvm.count + ' VMs.')

                $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

                $ExcelSQLVM = $AzCompute.SQLVM
            
                if ($IncludeTags.IsPresent)
                    {
                        $ExcelSQLVM | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'ResourceGroup',
                        'Name',
                        'Location',
                        'Zone',
                        'SQL Server License Type',
                        'SQL Image',
                        'SQL Management',
                        'SQL Image Sku',
                        'Tag Name',
                        'Tag Value'  | 
                        Export-Excel -Path $File -WorksheetName 'SQL VMs' -AutoSize -TableName 'AzureSQLVMs' -TableStyle $tableStyle -Style $Style
                    }
                else 
                    {
                        $ExcelSQLVM | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'ResourceGroup',
                        'Name',
                        'Location',
                        'Zone',
                        'SQL Server License Type',
                        'SQL Image',
                        'SQL Management',
                        'SQL Image Sku' | 
                        Export-Excel -Path $File -WorksheetName 'SQL VMs' -AutoSize -TableName 'AzureSQLVMs' -TableStyle $tableStyle -Style $Style
                    }

            }


            <############################################################################## 7 - SQL Databases ###################################################################>


            if ($Type -eq 'microsoft.sql/servers/databases') {

                Write-Progress -activity $DataActive -Status "$Prog% Complete." -PercentComplete $Prog
                Write-Debug ('Generating SQL Database sheet for: ' + $db.count + ' DBs.')

                $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

                $ExcelDB = $AzDatabase.DB

                if ($IncludeTags.IsPresent)
                    {
                        $ExcelDB | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Name',
                        'Location',
                        'Storage Account Type',
                        'Default Secondary Location',
                        'Status',
                        'DTU Capacity',
                        'DTU Tier',
                        'Data Max Size (GB)',
                        'Zone Redundant',
                        'Catalog Collation',
                        'Read Replica Count',
                        'Tag Name',
                        'Tag Value'  | 
                        Export-Excel -Path $File -WorksheetName 'SQL DBs' -AutoSize -TableName 'AzureSQLDBs' -TableStyle $tableStyle -Style $Style
                    }
                else 
                    {
                        $ExcelDB | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Name',
                        'Location',
                        'Storage Account Type',
                        'Default Secondary Location',
                        'Status',
                        'DTU Capacity',
                        'DTU Tier',
                        'Data Max Size (GB)',
                        'Zone Redundant',
                        'Catalog Collation',
                        'Read Replica Count' | 
                        Export-Excel -Path $File -WorksheetName 'SQL DBs' -AutoSize -TableName 'AzureSQLDBs' -TableStyle $tableStyle -Style $Style
                    }

            }


            <############################################################################## 8 - Automation Acc / Runbooks ###################################################################>

            if ($Type -eq 'microsoft.automation/automationaccounts/runbooks') {

                Write-Progress -activity $DataActive -Status "$Prog% Complete." -PercentComplete $Prog
                Write-Debug ('Generating Runbook sheet for: ' + $runbook.count + ' Runbooks.')

                $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'
                $StyleExt = New-ExcelStyle -HorizontalAlignment Left -Range K:K -Width 80 -WrapText 

                $ExcelAutAcc = $AzInfra.AutomationAcc
            
                if ($IncludeTags.IsPresent)
                    {
                        $ExcelAutAcc | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Automation Account Name',
                        'Automation Account State',
                        'Automation Account SKU',
                        'Location',
                        'Runbook Name',
                        'Last Modified Time',
                        'Runbook State',
                        'Runbook Type',
                        'Runbook Description',
                        'Job Count',
                        'Tag Name',
                        'Tag Value' |
                        Export-Excel -Path $File -WorksheetName 'Runbooks' -AutoSize -TableName 'AzureRunbooks' -TableStyle $tableStyle -Style $Style, $StyleExt
                    }
                else 
                    {
                        $ExcelAutAcc | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Automation Account Name',
                        'Automation Account State',
                        'Automation Account SKU',
                        'Location',
                        'Runbook Name',
                        'Last Modified Time',
                        'Runbook State',
                        'Runbook Type',
                        'Runbook Description',
                        'Job Count' |
                        Export-Excel -Path $File -WorksheetName 'Runbooks' -AutoSize -TableName 'AzureRunbooks' -TableStyle $tableStyle -Style $Style, $StyleExt
                    }

            }

            <############################################################################## 9 - Public IPs ###################################################################>

            if ($Type -eq 'microsoft.network/publicipaddresses') {

                Write-Progress -activity $DataActive -Status "$Prog% Complete." -PercentComplete $Prog
                $condtxtpip = New-ConditionalText Underutilized -Range I:I
                Write-Debug ('Generating Public IP sheet for: ' + $pubip.count + ' Public IPs.')

                $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

                $ExcelPIP = $AzNetwork.PIP
            
                if ($IncludeTags.IsPresent)
                    {
                        $ExcelPIP | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Name',
                        'SKU',
                        'Location',
                        'Type',
                        'Version',
                        'IP Address',
                        'Use',
                        'Associated Resource',
                        'Associated Resource Type',
                        'Tag Name',
                        'Tag Value' | 
                        Export-Excel -Path $File -WorksheetName 'Public IPs' -AutoSize -TableName 'AzurePubIPs' -TableStyle $tableStyle -Style $Style -ConditionalText $condtxtpip
                    }
                else 
                    {
                        $ExcelPIP | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Name',
                        'SKU',
                        'Location',
                        'Type',
                        'Version',
                        'IP Address',
                        'Use',
                        'Associated Resource',
                        'Associated Resource Type' | 
                        Export-Excel -Path $File -WorksheetName 'Public IPs' -AutoSize -TableName 'AzurePubIPs' -TableStyle $tableStyle -Style $Style -ConditionalText $condtxtpip
                    }

            }

            <############################################################################## 10 - Event Hubs ###################################################################>

            if ($Type -eq 'microsoft.eventhub/namespaces') {

                Write-Progress -activity $DataActive -Status "$Prog% Complete." -PercentComplete $Prog
                Write-Debug ('Generating Event Hub sheet for: ' + $evthub.count + ' Event Hubs.')

                $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

                $txtEvt = $(New-ConditionalText false -Range I:I
                    New-ConditionalText falso -Range I:I)

                $ExcelEvtHub = $AzInfra.EvtHub

                if ($IncludeTags.IsPresent)
                    {
                        $ExcelEvtHub | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Name',
                        'Location',
                        'SKU',
                        'Status',
                        'Geo-Rep',
                        'Throughput Units',
                        'Auto-Inflate',
                        'Max Throughput Units',
                        'Kafka Enabled',
                        'Endpoint',
                        'Tag Name',
                        'Tag Value' | 
                        Export-Excel -Path $File -WorksheetName 'Event Hubs' -AutoSize -TableName 'AzureEventHubs' -TableStyle $tableStyle -ConditionalText $txtEvt -Style $Style
                    }
                else 
                    {
                        $ExcelEvtHub | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Name',
                        'Location',
                        'SKU',
                        'Status',
                        'Geo-Rep',
                        'Throughput Units',
                        'Auto-Inflate',
                        'Max Throughput Units',
                        'Kafka Enabled',
                        'Endpoint' | 
                        Export-Excel -Path $File -WorksheetName 'Event Hubs' -AutoSize -TableName 'AzureEventHubs' -TableStyle $tableStyle -ConditionalText $txtEvt -Style $Style
                    }

            }

            <############################################################################## 11 - MySQL ###################################################################>

            if ($Type -eq 'microsoft.dbformysql/servers') {

                Write-Progress -activity $DataActive -Status "$Prog% Complete." -PercentComplete $Prog
                Write-Debug ('Generating MySQL Database sheet for: ' + $mysql.count + ' DBs.')

                $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'
          
                $ExcelMySQL = $AzDatabase.MySQL

                if ($IncludeTags.IsPresent)
                    {
                        $ExcelMySQL | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Name',
                        'Location',
                        'SKU',
                        'SKU Family',
                        'Tier',
                        'Capacity',
                        'MySQL Version',
                        'Backup Retention Days',
                        'Geo-Redundant Backup',
                        'Auto Grow',
                        'Storage MB',
                        'Public Network Access',
                        'Admin Login',
                        'Infrastructure Encryption',
                        'Minimal Tls Version',
                        'State',
                        'Replica Capacity',
                        'Replication Role',
                        'BYOK Enforcement',
                        'ssl Enforcement',
                        'Tag Name',
                        'Tag Value' | 
                        Export-Excel -Path $File -WorksheetName 'MySQL' -AutoSize -TableName 'AzureMySQL' -TableStyle $tableStyle -Style $Style
                    }
                else 
                    {
                        $ExcelMySQL | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Name',
                        'Location',
                        'SKU',
                        'SKU Family',
                        'Tier',
                        'Capacity',
                        'MySQL Version',
                        'Backup Retention Days',
                        'Geo-Redundant Backup',
                        'Auto Grow',
                        'Storage MB',
                        'Public Network Access',
                        'Admin Login',
                        'Infrastructure Encryption',
                        'Minimal Tls Version',
                        'State',
                        'Replica Capacity',
                        'Replication Role',
                        'BYOK Enforcement',
                        'ssl Enforcement'| 
                        Export-Excel -Path $File -WorksheetName 'MySQL' -AutoSize -TableName 'AzureMySQL' -TableStyle $tableStyle -Style $Style
                    }

            }

            <############################################################################## 12 - PostgreSQL ###################################################################>

            if ($Type -eq 'microsoft.dbforpostgresql/servers') {

                Write-Progress -activity $DataActive -Status "$Prog% Complete." -PercentComplete $Prog
                Write-Debug ('Generating PostgreSQL sheet for: ' + $postgre.count + ' DBs.')

                $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

                $ExcelPostGre = $AzDatabase.PostGre
            
                if ($IncludeTags.IsPresent)
                    {
                        $ExcelPostGre | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Name',
                        'Location',
                        'SKU',
                        'SKU Family',
                        'Tier',
                        'Capacity',
                        'MySQL Version',
                        'Backup Retention Days',
                        'Geo-Redundant Backup',
                        'Auto Grow',
                        'Storage MB',
                        'Public Network Access',
                        'Admin Login',
                        'Infrastructure Encryption',
                        'Minimal Tls Version',
                        'State',
                        'Replica Capacity',
                        'Replication Role',
                        'BYOK Enforcement',
                        'ssl Enforcement',
                        'Tag Name',
                        'Tag Value' | 
                        Export-Excel -Path $File -WorksheetName 'PostgreSQL' -AutoSize -TableName 'AzurePostgreSQL' -TableStyle $tableStyle -Style $Style
                    }
                else 
                    {
                        $ExcelPostGre | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Name',
                        'Location',
                        'SKU',
                        'SKU Family',
                        'Tier',
                        'Capacity',
                        'MySQL Version',
                        'Backup Retention Days',
                        'Geo-Redundant Backup',
                        'Auto Grow',
                        'Storage MB',
                        'Public Network Access',
                        'Admin Login',
                        'Infrastructure Encryption',
                        'Minimal Tls Version',
                        'State',
                        'Replica Capacity',
                        'Replication Role',
                        'BYOK Enforcement',
                        'ssl Enforcement' | 
                        Export-Excel -Path $File -WorksheetName 'PostgreSQL' -AutoSize -TableName 'AzurePostgreSQL' -TableStyle $tableStyle -Style $Style
                    }

            }

            <############################################################################## 13 - Web Server Farm ###################################################################>

            if ($Type -eq 'microsoft.web/serverfarms') {

                Write-Progress -activity $DataActive -Status "$Prog% Complete." -PercentComplete $Prog
                Write-Debug ('Generating Web Server Farm sheet for: ' + $webfarm.count + ' Web Servers.')

                $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

                $ExcelWebFarm = $AzCompute.SERVERFARM

                if ($IncludeTags.IsPresent)
                    {
                        $ExcelWebFarm | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Name',
                        'Location',
                        'SKU',
                        'SKU Family',
                        'Tier',
                        'Capacity',
                        'Workers',
                        'Compute Mode',
                        'Max Elastic Workers',
                        'Max Workers',
                        'Worker Kind',
                        'Number Of Sites',
                        'Plan Name',
                        'Tag Name',
                        'Tag Value' | 
                        Export-Excel -Path $File -WorksheetName 'Web Servers' -AutoSize -TableName 'AzureWebServers' -TableStyle $tableStyle -Style $Style
                    }
                else 
                    {
                        $ExcelWebFarm | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Name',
                        'Location',
                        'SKU',
                        'SKU Family',
                        'Tier',
                        'Capacity',
                        'Workers',
                        'Compute Mode',
                        'Max Elastic Workers',
                        'Max Workers',
                        'Worker Kind',
                        'Number Of Sites',
                        'Plan Name' | 
                        Export-Excel -Path $File -WorksheetName 'Web Servers' -AutoSize -TableName 'AzureWebServers' -TableStyle $tableStyle -Style $Style
                    }

            }

            <############################################################################## 14 - Workspaces ###################################################################>


            if ($Type -eq 'microsoft.operationalinsights/workspaces') {

                Write-Progress -activity $DataActive -Status "$Prog% Complete." -PercentComplete $Prog
                Write-Debug ('Generating Log Analytics Workspaces sheet for: ' + $wrkspace.count + ' Workspaces.')

                $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0.0'
            
                $ExcelWrkSpace = $AzInfra.WrkSpace

                if ($IncludeTags.IsPresent)
                    {
                        $ExcelWrkSpace | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Name',
                        'Location',
                        'SKU',
                        'Retention Days',
                        'Daily Quota (GB)',
                        'Tag Name',
                        'Tag Value' | 
                        Export-Excel -Path $File -WorksheetName 'Workspaces' -AutoSize -TableName 'AzureWorkspace' -TableStyle $tableStyle -Style $Style
                    }
                else 
                    {
                        $ExcelWrkSpace | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Name',
                        'Location',
                        'SKU',
                        'Retention Days',
                        'Daily Quota (GB)' | 
                        Export-Excel -Path $File -WorksheetName 'Workspaces' -AutoSize -TableName 'AzureWorkspace' -TableStyle $tableStyle -Style $Style
                    }

            }

            <############################################################################## 15 - AKS ###################################################################>


            if ($Type -eq 'microsoft.containerservice/managedclusters') {

                Write-Progress -activity $DataActive -Status "$Prog% Complete." -PercentComplete $Prog
                Write-Debug ('Generating AKS sheet for: ' + $AKS.count + ' Kubernetes Clusters.')

                $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

                $txtaksv = New-ConditionalText UNSUPPORTED -Range F:F

                $ExcelAKS = $AzCompute.AKS

                if ($IncludeTags.IsPresent)
                    {
                        $ExcelAKS | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Clusters',
                        'Location',
                        'Kubernetes Version',
                        'Kubernetes Version Support',
                        'Role-Based Access Control',
                        'AAD Enabled',
                        'Network Type',
                        'Outbound Type',
                        'LoadBalancer Sku',
                        'Docker Pod Cidr',
                        'Service Cidr',
                        'Docker Bridge Cidr',           
                        'Network DNS Service IP',
                        'FQDN',
                        'HTTP Application Routing',
                        'Node Pool Name',
                        'Pool Profile Type',
                        'Pool OS',
                        'Node Size',
                        'OS Disk Size (GB)',
                        'Nodes',
                        'Autoscale',
                        'Autoscale Max',
                        'Autoscale Min',
                        'Max Pods Per Node',
                        'Orchestrator Version',
                        'Enable Node Public IP',
                        'Tag Name',
                        'Tag Value' | 
                        Export-Excel -Path $File -WorksheetName 'AKS' -AutoSize -TableName 'AzureKubernetes' -TableStyle $tableStyle -ConditionalText $txtaksv -Numberformat '0' -Style $Style
                    }
                else 
                    {
                        $ExcelAKS | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Clusters',
                        'Location',
                        'Kubernetes Version',
                        'Kubernetes Version Support',
                        'Role-Based Access Control',
                        'AAD Enabled',
                        'Network Type',
                        'Outbound Type',
                        'LoadBalancer Sku',
                        'Docker Pod Cidr',
                        'Service Cidr',
                        'Docker Bridge Cidr',           
                        'Network DNS Service IP',
                        'FQDN',
                        'HTTP Application Routing',
                        'Node Pool Name',
                        'Pool Profile Type',
                        'Pool OS',
                        'Node Size',
                        'OS Disk Size (GB)',
                        'Nodes',
                        'Autoscale',
                        'Autoscale Max',
                        'Autoscale Min',
                        'Max Pods Per Node',
                        'Orchestrator Version',
                        'Enable Node Public IP' | 
                        Export-Excel -Path $File -WorksheetName 'AKS' -AutoSize -TableName 'AzureKubernetes' -TableStyle $tableStyle -ConditionalText $txtaksv -Numberformat '0' -Style $Style
                    }

            }

            <############################################################################## 16 - Containers ###################################################################>

            if ($Type -eq 'microsoft.containerinstance/containergroups') {

                Write-Progress -activity $DataActive -Status "$Prog% Complete." -PercentComplete $Prog
                Write-Debug ('Generating Containers sheet for: ' + $con.count + ' Containers.')

                $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

                $ExcelContainer = $AzCompute.CON
            
                if ($IncludeTags.IsPresent)
                    {
                        $ExcelContainer | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Instance Name',
                        'Location',
                        'Instance OS Type',
                        'Container Name',
                        'Container State',
                        'Container Image',
                        'Restart Count',
                        'Start Time',
                        'Command',
                        'Request CPU',
                        'Request Memory (GB)',
                        'IP',
                        'Protocol',
                        'Port',
                        'Tag Name',
                        'Tag Value' | 
                        Export-Excel -Path $File -WorksheetName 'Containers' -AutoSize -TableName 'AzureContainers' -TableStyle $tableStyle -Style $Style
                    }
                else
                    {
                        $ExcelContainer | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Instance Name',
                        'Location',
                        'Instance OS Type',
                        'Container Name',
                        'Container State',
                        'Container Image',
                        'Restart Count',
                        'Start Time',
                        'Command',
                        'Request CPU',
                        'Request Memory (GB)',
                        'IP',
                        'Protocol',
                        'Port' | 
                        Export-Excel -Path $File -WorksheetName 'Containers' -AutoSize -TableName 'AzureContainers' -TableStyle $tableStyle -Style $Style
                    }

            }

            <############################################################################## 17 - Availability Sets ###################################################################>

            if ($Type -eq 'microsoft.compute/availabilitysets') {

                Write-Progress -activity $DataActive -Status "$Prog% Complete." -PercentComplete $Prog
                Write-Debug ('Generating Availability Set sheet for: ' + $AvSet.count + ' AV Sets.')

                $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'
            
                $ExcelAvSet = $AzInfra.AvSet

                if ($IncludeTags.IsPresent)
                    {
                        $ExcelAvSet | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Name',
                        'Location',
                        'Fault Domains',
                        'Update Domains',
                        'Virtual Machines',
                        'Tag Name',
                        'Tag Value' | 
                        Export-Excel -Path $File -WorksheetName 'Availability Sets' -AutoSize -TableName 'AvailabilitySets' -TableStyle $tableStyle -Style $Style
                    }
                else 
                    {
                        $ExcelAvSet | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Name',
                        'Location',
                        'Fault Domains',
                        'Update Domains',
                        'Virtual Machines' | 
                        Export-Excel -Path $File -WorksheetName 'Availability Sets' -AutoSize -TableName 'AvailabilitySets' -TableStyle $tableStyle -Style $Style
                    }

            }

            <############################################################################## 18 - Web Sites ###################################################################>

            if ($Type -eq 'microsoft.web/sites') {

                Write-Progress -activity $DataActive -Status "$Prog% Complete." -PercentComplete $Prog
                Write-Debug ('Generating Web Site sheet for: ' + $db.count + ' Web Sites.')

                $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

                $ExcelWebSite = $AzInfra.WebSite

                if ($IncludeTags.IsPresent)
                    {
                        $ExcelWebSite | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Name',
                        'Kind',
                        'Location',
                        'Enabled',
                        'State',
                        'SKU',
                        'Content Availability State',
                        'Runtime Availability State',
                        'Possible Inbound IP Addresses',
                        'Repository Site Name',
                        'AvailabilityState',
                        'HostNames',
                        'HostName Type',
                        'sslState',
                        'Default Hostname',
                        'Client Cert Mode',
                        'ContainerSize',
                        'Admin Enabled',
                        'FTPs Host Name',
                        'HTTPS Only',
                        'Tag Name',
                        'Tag Value' | 
                        Export-Excel -Path $File -WorksheetName 'Web Sites' -AutoSize -TableName 'WebSites' -TableStyle $tableStyle -Style $Style
                    }
                else 
                    {
                        $ExcelWebSite | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Name',
                        'Kind',
                        'Location',
                        'Enabled',
                        'State',
                        'SKU',
                        'Content Availability State',
                        'Runtime Availability State',
                        'Possible Inbound IP Addresses',
                        'Repository Site Name',
                        'AvailabilityState',
                        'HostNames',
                        'HostName Type',
                        'sslState',
                        'Default Hostname',
                        'Client Cert Mode',
                        'ContainerSize',
                        'Admin Enabled',
                        'FTPs Host Name',
                        'HTTPS Only' | 
                        Export-Excel -Path $File -WorksheetName 'Web Sites' -AutoSize -TableName 'WebSites' -TableStyle $tableStyle -Style $Style
                    }

            }

            <############################################################################## 19 - VM Scale Sets ###################################################################>

            if ($Type -eq 'microsoft.compute/virtualmachinescalesets') {
                Write-Progress -activity $DataActive -Status "$Prog% Complete." -PercentComplete $Prog 
                Write-Debug ('Generating Virtual Machine Scale Set sheet for: ' + $vmscs.count + ' VMSS.')

                $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'
                        
                $ExcelVMSS = $AzCompute.VMSS

                if ($IncludeTags.IsPresent)
                    {
                        $ExcelVMSS | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Name',
                        'Location',
                        'SKU Tier',
                        'Fault Domain',
                        'Upgrade Policy',
                        'Capacity',
                        'VM Size',
                        'VM OS',
                        'Network Interface Name',
                        'Enable Accelerated Networking',
                        'Enable IP Forwading',
                        'Admin Username',
                        'VM Name Prefix',
                        'Tag Name',
                        'Tag Value' | 
                        Export-Excel -Path $File -WorksheetName 'VMSS' -AutoSize -TableName 'AzureVMSS' -TableStyle $tableStyle -Style $Style
                    }
                else    
                    {
                        $ExcelVMSS | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Name',
                        'Location',
                        'SKU Tier',
                        'Fault Domain',
                        'Upgrade Policy',
                        'Capacity',
                        'VM Size',
                        'VM OS',
                        'Network Interface Name',
                        'Enable Accelerated Networking',
                        'Enable IP Forwading',
                        'Admin Username',
                        'VM Name Prefix' | 
                        Export-Excel -Path $File -WorksheetName 'VMSS' -AutoSize -TableName 'AzureVMSS' -TableStyle $tableStyle -Style $Style
                    }

            }


            <############################################################################## 20 - Load Balancers ###################################################################>


            if ($Type -eq 'microsoft.network/loadbalancers') {
                Write-Progress -activity $DataActive -Status "$Prog% Complete." -PercentComplete $Prog
                Write-Debug ('Generating Load Balancer sheet for: ' + $lbs.count + ' LBs.')

                $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

                $txtLB = New-ConditionalText Basic -Range E:E
                        
                $ExcelLB = $AzNetwork.LB

                if ($IncludeTags.IsPresent)
                    {
                        $ExcelLB | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Name',
                        'Location',
                        'SKU',
                        'Frontend Name',
                        'Frontend Target',
                        'Frontend Type',
                        'Frontend Subnet',
                        'Backend Pool Name',
                        'Backend Target',
                        'Backend Type',
                        'Probe Name',
                        'Probe Interval (sec)',
                        'Probe Protocol',
                        'Probe Port',
                        'Probe Unhealthy threshold',
                        'Tag Name',
                        'Tag Value'  | 
                        Export-Excel -Path $File -WorksheetName 'Load Balancers' -AutoSize -TableName 'LoadBalancers' -TableStyle $tableStyle -ConditionalText $txtLB -Style $Style
                    }
                else 
                    {
                        $ExcelLB | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Name',
                        'Location',
                        'SKU',
                        'Frontend Name',
                        'Frontend Target',
                        'Frontend Type',
                        'Frontend Subnet',
                        'Backend Pool Name',
                        'Backend Target',
                        'Backend Type',
                        'Probe Name',
                        'Probe Interval (sec)',
                        'Probe Protocol',
                        'Probe Port',
                        'Probe Unhealthy threshold' | 
                        Export-Excel -Path $File -WorksheetName 'Load Balancers' -AutoSize -TableName 'LoadBalancers' -TableStyle $tableStyle -ConditionalText $txtLB -Style $Style
                    }

            }


            <############################################################################## 21 - SQL Servers ###################################################################>

            if ($Type -eq 'microsoft.sql/servers') {

                Write-Progress -activity $DataActive -Status "$Prog% Complete." -PercentComplete $Prog
                Write-Debug ('Generating SQL Server sheet for: ' + $SQLServer.count + ' Servers.')
                    
                $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'
                    
                $ExcelSQLServer = $AzCompute.SQLSERVER
    
                if ($IncludeTags.IsPresent)
                    {
                        $ExcelSQLServer | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Name',
                        'Location',
                        'Kind',
                        'Admin Login',
                        'FQDN',
                        'Public Network Access',
                        'State',
                        'Version',
                        'Tag Name',
                        'Tag Value' | 
                        Export-Excel -Path $File -WorksheetName 'SQL Servers' -AutoSize -TableName 'AzureSQLServers' -TableStyle $tableStyle -Style $Style
                    }
                else 
                    {
                        $ExcelSQLServer | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Name',
                        'Location',
                        'Kind',
                        'Admin Login',
                        'FQDN',
                        'Public Network Access',
                        'State',
                        'Version' | 
                        Export-Excel -Path $File -WorksheetName 'SQL Servers' -AutoSize -TableName 'AzureSQLServers' -TableStyle $tableStyle -Style $Style
                    }
      
            }

            


            <############################################################################## 22 - Virtual Network Peering  ###################################################################>


            if ($Type -eq 'microsoft.network/virtualnetworks' -and $null -ne $AzNetwork.Peering -and $AzNetwork.Peering -ne '') {


                Write-Progress -activity $DataActive -Status "$Prog% Complete." -PercentComplete $Prog
                $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

                $ExcelPeering = $AzNetwork.Peering

                if ($IncludeTags.IsPresent)
                    {
                        $ExcelPeering | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Location',
                        'Zone',
                        'Peering Name',
                        'VNET Name',
                        'Address Space',
                        'Peering VNet',
                        'Peering Address Space',
                        'Peering State',
                        'Peering Use Remote Gateways',
                        'Peering Allow Gateway Transit',
                        'Peering Allow Forwarded Traffic',
                        'Peering Do Not Verify Remote Gateways',
                        'Peering Allow Virtual NetworkAccess',
                        'Tag Name',
                        'Tag Value' | 
                        Export-Excel -Path $File -WorksheetName 'Peering' -AutoSize -TableName 'AzureVNETPeerings' -TableStyle $tableStyle -Style $Style
                    }
                else 
                    {
                        $ExcelPeering | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Location',
                        'Zone',
                        'Peering Name',
                        'VNET Name',
                        'Address Space',
                        'Peering VNet',
                        'Peering Address Space',
                        'Peering State',
                        'Peering Use Remote Gateways',
                        'Peering Allow Gateway Transit',
                        'Peering Allow Forwarded Traffic',
                        'Peering Do Not Verify Remote Gateways',
                        'Peering Allow Virtual NetworkAccess' | 
                        Export-Excel -Path $File -WorksheetName 'Peering' -AutoSize -TableName 'AzureVNETPeerings' -TableStyle $tableStyle -Style $Style
                    }

            }
            

            <############################################################################## 23 - Front Door  ###################################################################>


            if ($Type -eq 'microsoft.network/frontdoors') {


                Write-Progress -activity $DataActive -Status "$Prog% Complete." -PercentComplete $Prog
                $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

                $ExcelFrontDoor = $AzNetwork.FrontDoor

                if ($IncludeTags.IsPresent)
                    {
                        $ExcelFrontDoor | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Name',
                        'Location',
                        'Friendly Name',
                        'cName',
                        'State',
                        'Frontend',
                        'Backend',
                        'Health Probe',
                        'Load Balancing',
                        'Routing Rules',
                        'Tag Name',
                        'Tag Value' | 
                        Export-Excel -Path $File -WorksheetName 'FrontDoor' -AutoSize -TableName 'AzureFrontDoor' -TableStyle $tableStyle -Style $Style
                    }
                else 
                    {
                        $ExcelFrontDoor | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Name',
                        'Location',
                        'Friendly Name',
                        'cName',
                        'State',
                        'Frontend',
                        'Backend',
                        'Health Probe',
                        'Load Balancing',
                        'Routing Rules'| 
                        Export-Excel -Path $File -WorksheetName 'FrontDoor' -AutoSize -TableName 'AzureFrontDoor' -TableStyle $tableStyle -Style $Style
                    }

            }            

            <############################################################################## 24 - Application Gateway ###################################################################>


            if ($Type -eq 'microsoft.network/applicationgateways') {


                Write-Progress -activity $DataActive -Status "$Prog% Complete." -PercentComplete $Prog
                $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

                $ExcelAppGateway = $AzNetwork.AppGateway

                if ($IncludeTags.IsPresent)
                    {
                        $ExcelAppGateway | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Name',
                        'Location',
                        'State',
                        'SKU Name',
                        'SKU Capacity',
                        'Backend',
                        'Frontend',
                        'Frontend Ports',
                        'Gateways',
                        'HTTP Listeners',
                        'Request Routing Rules',
                        'Tag Name',
                        'Tag Value' | 
                        Export-Excel -Path $File -WorksheetName 'App Gateway' -AutoSize -TableName 'AzureAppGateway' -TableStyle $tableStyle -Style $Style
                    }
                else 
                    {
                        $ExcelAppGateway | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Name',
                        'Location',
                        'State',
                        'SKU Name',
                        'SKU Capacity',
                        'Backend',
                        'Frontend',
                        'Frontend Ports',
                        'Gateways',
                        'HTTP Listeners',
                        'Request Routing Rules'| 
                        Export-Excel -Path $File -WorksheetName 'App Gateway' -AutoSize -TableName 'AzureAppGateway' -TableStyle $tableStyle -Style $Style
                    }

            }  

            <############################################################################## 25 - Route Tables ###################################################################>


            if ($Type -eq 'microsoft.network/routetables') {

                Write-Progress -activity $DataActive -Status "$Prog% Complete." -PercentComplete $Prog
                $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

                $ExcelRouteTable = $AzNetwork.RouteTable

                if ($IncludeTags.IsPresent)
                    {
                        $ExcelRouteTable | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Name',
                        'Location',
                        'Disable BGP Route Propagation',
                        'Routes',
                        'Routes Prefixes',
                        'Routes BGP Override',
                        'Routes Next Hop IP',
                        'Routes Next Hop Type',
                        'Tag Name',
                        'Tag Value' | 
                        Export-Excel -Path $File -WorksheetName 'Route Tables' -AutoSize -TableName 'AzureRouteTables' -TableStyle $tableStyle -Style $Style
                    }
                else 
                    {
                        $ExcelRouteTable | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Name',
                        'Location',
                        'Disable BGP Route Propagation',
                        'Routes',
                        'Routes Prefixes',
                        'Routes BGP Override',
                        'Routes Next Hop IP',
                        'Routes Next Hop Type'| 
                        Export-Excel -Path $File -WorksheetName 'Route Tables' -AutoSize -TableName 'AzureRouteTables' -TableStyle $tableStyle -Style $Style
                    }

            }  

            <############################################################################## 26 - Key Vaults ###################################################################>


            if ($Type -eq 'microsoft.keyvault/vaults') {

                Write-Progress -activity $DataActive -Status "$Prog% Complete." -PercentComplete $Prog
                $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

                $ExcelVault = $AzInfra.Vault

                if ($IncludeTags.IsPresent)
                    {
                        $ExcelVault | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Name',
                        'Location',
                        'SKU Family',
                        'SKU',
                        'Vault Uri',
                        'Enable RBAC',
                        'Enable Soft Delete',
                        'Enable for Disk Encryption',
                        'Enable for Template Deploy',
                        'Soft Delete Retention Days',
                        'Certificate Permissions',
                        'Key Permissions',
                        'Secret Permissions',
                        'Tag Name',
                        'Tag Value' | 
                        Export-Excel -Path $File -WorksheetName 'Key Vaults' -AutoSize -TableName 'AzureKeyVault' -TableStyle $tableStyle -Style $Style
                    }
                else 
                    {
                        $ExcelVault | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Name',
                        'Location',
                        'SKU Family',
                        'SKU',
                        'Vault Uri',
                        'Enable RBAC',
                        'Enable Soft Delete',
                        'Enable for Disk Encryption',
                        'Enable for Template Deploy',
                        'Soft Delete Retention Days',
                        'Certificate Permissions',
                        'Key Permissions',
                        'Secret Permissions'| 
                        Export-Excel -Path $File -WorksheetName 'Key Vaults' -AutoSize -TableName 'AzureKeyVault' -TableStyle $tableStyle -Style $Style
                    }

            }  

            <############################################################################## 27 - Recovery Vaults ###################################################################>


            if ($Type -eq 'microsoft.recoveryservices/vaults') {

                Write-Progress -activity $DataActive -Status "$Prog% Complete." -PercentComplete $Prog
                $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

                $ExcelRecVault = $AzInfra.RecoveryVault

                if ($IncludeTags.IsPresent)
                    {
                        $ExcelRecVault | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Name',
                        'Location',
                        'SKU Name',
                        'SKU Tier',
                        'Private Endpoint State for Backup',
                        'Private Endpoint State for Site Recovery',
                        'Tag Name',
                        'Tag Value' | 
                        Export-Excel -Path $File -WorksheetName 'Recovery Vaults' -AutoSize -TableName 'AzureRecVault' -TableStyle $tableStyle -Style $Style
                    }
                else 
                    {
                        $ExcelRecVault | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Name',
                        'Location',
                        'SKU Name',
                        'SKU Tier',
                        'Private Endpoint State for Backup',
                        'Private Endpoint State for Site Recovery'| 
                        Export-Excel -Path $File -WorksheetName 'Recovery Vaults' -AutoSize -TableName 'AzureRecVault' -TableStyle $tableStyle -Style $Style
                    }

            }             

            <############################################################################## 28 - DNS Zones ###################################################################>


            if ($Type -eq 'microsoft.network/dnszones') {

                Write-Progress -activity $DataActive -Status "$Prog% Complete." -PercentComplete $Prog
                $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

                $ExcelDNSZone = $AzNetwork.DNSZone

                if ($IncludeTags.IsPresent)
                    {
                        $ExcelDNSZone | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Name',
                        'Location',
                        'Zone Type',
                        'Number of Record Sets',
                        'Max Number of Record Sets',
                        'Name Servers',
                        'Tag Name',
                        'Tag Value' | 
                        Export-Excel -Path $File -WorksheetName 'DNS Zones' -AutoSize -TableName 'AzureDNSZones' -TableStyle $tableStyle -Style $Style
                    }
                else 
                    {
                        $ExcelDNSZone | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Name',
                        'Location',
                        'Zone Type',
                        'Number of Record Sets',
                        'Max Number of Record Sets',
                        'Name Servers'| 
                        Export-Excel -Path $File -WorksheetName 'DNS Zones' -AutoSize -TableName 'AzureDNSZones' -TableStyle $tableStyle -Style $Style
                    }

            }   

            <############################################################################## 29 - IOT ###################################################################>


            if ($Type -eq 'microsoft.devices/iothubs') {

                Write-Progress -activity $DataActive -Status "$Prog% Complete." -PercentComplete $Prog
                $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

                $ExcelIot = $AzCompute.Iot

                if ($IncludeTags.IsPresent)
                    {
                        $ExcelIot | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Name',
                        'HostName',
                        'State',
                        'SKU',
                        'SKU Tier',
                        'SKU Capacity',
                        'Features',
                        'Enable File Upload Notifications',
                        'Default TTL As ISO8601',
                        'Max Delivery Count',
                        'EventHubs Endpoint',
                        'EventHubs Partition Count',
                        'EventHubs Path',
                        'EventHubs Retention Days',
                        'Locations',
                        'Tag Name',
                        'Tag Value' | 
                        Export-Excel -Path $File -WorksheetName 'IoT Hubs' -AutoSize -TableName 'AzureIOT' -TableStyle $tableStyle -Style $Style
                    }
                else 
                    {
                        $ExcelIot | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Name',
                        'HostName',
                        'State',
                        'SKU',
                        'SKU Tier',
                        'SKU Capacity',
                        'Features',
                        'Enable File Upload Notifications',
                        'Default TTL As ISO8601',
                        'Max Delivery Count',
                        'EventHubs Endpoint',
                        'EventHubs Partition Count',
                        'EventHubs Path',
                        'EventHubs Retention Days',
                        'Locations'| 
                        Export-Excel -Path $File -WorksheetName 'IoT Hubs' -AutoSize -TableName 'AzureIOT' -TableStyle $tableStyle -Style $Style
                    }

            } 

            <############################################################################## 30 - APIM ###################################################################>


            if ($Type -eq 'microsoft.apimanagement/service') {

                Write-Progress -activity $DataActive -Status "$Prog% Complete." -PercentComplete $Prog
                $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

                $ExcelAPIM = $AzInfra.APIM

                if ($IncludeTags.IsPresent)
                    {
                        $ExcelAPIM | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Name',
                        'Location',
                        'SKU',
                        'Gateway URL',
                        'Virtual Network Type',
                        'Virtual Network',
                        'Http2',
                        'Backend SSL 3.0',
                        'Backend TLS 1.0',
                        'Backend TLS 1.1',
                        'Triple DES',
                        'Client SSL 3.0',
                        'Client TLS 1.0',
                        'Client TLS 1.1',
                        'Public IP',
                        'Tag Name',
                        'Tag Value' | 
                        Export-Excel -Path $File -WorksheetName 'APIM' -AutoSize -TableName 'AzureAPIM' -TableStyle $tableStyle -Style $Style
                    }
                else 
                    {
                        $ExcelAPIM | 
                        ForEach-Object { [PSCustomObject]$_ } | 
                        Select-Object -Unique 'Subscription',
                        'Resource Group',
                        'Name',
                        'Location',
                        'SKU',
                        'Gateway URL',
                        'Virtual Network Type',
                        'Virtual Network',
                        'Http2',
                        'Backend SSL 3.0',
                        'Backend TLS 1.0',
                        'Backend TLS 1.1',
                        'Triple DES',
                        'Client SSL 3.0',
                        'Client TLS 1.0',
                        'Client TLS 1.1',
                        'Public IP'| 
                        Export-Excel -Path $File -WorksheetName 'APIM' -AutoSize -TableName 'AzureAPIM' -TableStyle $tableStyle -Style $Style
                    }

            } 

            $c++
        }


        <################################################################### Subscriptions ###################################################################>


        $ResTable = $resources | Where-Object { $_.type -ne 'microsoft.advisor/recommendations' }
        $resTable2 = $ResTable | Select-Object id, Type, resourcegroup, subscriptionid
        $ResTable3 = $ResTable2 | Group-Object -Property type, resourcegroup, subscriptionid 

        Write-Debug ('Generating Subscription sheet for: ' + $SUBs.count + ' Subscriptions.')

        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

        if ($null -ne $obj) {
            Remove-Variable obj
        }
        $tmp = @()

        foreach ($ResourcesSUB in $ResTable3) {
            $ResourceDetails = $ResourcesSUB.name -split ","
            $SubName = $SUBs | Where-Object { $_.id -eq ($ResourceDetails[2] -replace (" ", "")) }

            $obj = @{
                'Subscription'   = $SubName.Name;
                'Resource Group' = $ResourceDetails[1];
                'Resource Type'  = $ResourceDetails[0];
                'Resources'      = $ResourcesSUB.Count
            }
            $tmp += $obj
        }

        $tmp | 
        ForEach-Object { [PSCustomObject]$_ } | 
        Select-Object 'Subscription',
        'Resource Group',
        'Resource Type',
        'Resources' | Export-Excel -Path $File -WorksheetName 'Subscriptions' -AutoSize -TableName 'Subscriptions' -TableStyle $tableStyle -Style $Style -Numberformat '0' -MoveToEnd 

        Remove-Variable tmp


        <################################################################### CHARTS ###################################################################>

        Write-Debug ('Generating Overview sheet (Charts).')
        "" | Export-Excel -Path $File -WorksheetName 'Overview' -MoveToStart 

        Write-Progress -activity 'Azure Resource Inventory Reporting Charts' -Status "1% Complete." -PercentComplete 10 -CurrentOperation "Building Excel Charts"
        $excel = Open-ExcelPackage -Path $file -KillExcel

        if($ExcelVMs)
            {
                $null=$excel.VMs.Cells["L1"].AddComment("Boot diagnostics is a debugging feature for Azure virtual machines (VM) that allows diagnosis of VM boot failures.", "Azure Resource Inventory")
                $excel.VMs.Cells["L1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/virtual-machines/boot-diagnostics'
                $null=$excel.VMs.Cells["M1"].AddComment("Is recommended to install Performance Diagnostics Agent in every Azure Virtual Machine upfront. The agent is only used when triggered by the console and may save time in an event of performance struggling.", "Azure Resource Inventory")
                $excel.VMs.Cells["M1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/virtual-machines/troubleshooting/performance-diagnostics'
                $null=$excel.VMs.Cells["N1"].AddComment("We recommend that you use Azure Monitor to gain visibility into your resource’s health.", "Azure Resource Inventory")
                $excel.VMs.Cells["N1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/security/fundamentals/iaas#monitor-vm-performance'
                $null=$excel.VMs.Cells["X1"].AddComment("Use a network security group to protect against unsolicited traffic into Azure subnets. Network security groups are simple, stateful packet inspection devices that use the 5-tuple approach (source IP, source port, destination IP, destination port, and layer 4 protocol) to create allow/deny rules for network traffic.", "Azure Resource Inventory")
                $excel.VMs.Cells["X1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/security/fundamentals/network-best-practices#logically-segment-subnets'
                $null=$excel.VMs.Cells["Y1"].AddComment("Accelerated networking enables single root I/O virtualization (SR-IOV) to a VM, greatly improving its networking performance. This high-performance path bypasses the host from the datapath, reducing latency, jitter, and CPU utilization.", "Azure Resource Inventory")
                $excel.VMs.Cells["Y1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/virtual-network/create-vm-accelerated-networking-cli'
            }
        if($ExcelVMDisks)
            {
                $null=$excel.Disks.Cells["K1"].AddComment("When you delete a virtual machine (VM) in Azure, by default, any disks that are attached to the VM aren't deleted. After a VM is deleted, you will continue to pay for unattached disks.", "Azure Resource Inventory")
                $excel.Disks.Cells["K1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/virtual-machines/windows/find-unattached-disks'
            }
        if($ExcelStorageAcc)
            {
                $null=$excel.StorageAcc.Cells["F1"].AddComment("Is recommended that you configure your storage account to accept requests from secure connections only by setting the Secure transfer required property for the storage account.", "Azure Resource Inventory")
                $excel.StorageAcc.Cells["F1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/storage/common/storage-require-secure-transfer'
                $null=$excel.StorageAcc.Cells["G1"].AddComment("When a container is configured for public access, any client can read data in that container. Public access presents a potential security risk, so if your scenario does not require it, Microsoft recommends that you disallow it for the storage account.", "Azure Resource Inventory")
                $excel.StorageAcc.Cells["G1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/storage/blobs/anonymous-read-access-configure?tabs=portal'
                $null=$excel.StorageAcc.Cells["H1"].AddComment("By default, Azure Storage accounts permit clients to send and receive data with the oldest version of TLS, TLS 1.0, and above. To enforce stricter security measures, you can configure your storage account to require that clients send and receive data with a newer version of TLS", "Azure Resource Inventory")
                $excel.StorageAcc.Cells["H1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/storage/common/transport-layer-security-configure-minimum-version?tabs=portal'
            }
        if($ExcelVNET)
            {
                $null=$excel.VNET.Cells["G1"].AddComment("Azure DDoS Protection Standard, combined with application design best practices, provides enhanced DDoS mitigation features to defend against DDoS attacks.", "Azure Resource Inventory")
                $excel.VNET.Cells["G1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/ddos-protection/ddos-protection-overview'
            }
        if($ExcelEvtHub)
            {
                $null=$excel.'Event Hubs'.Cells["I1"].AddComment("The Auto-inflate feature of Event Hubs automatically scales up by increasing the number of throughput units, to meet usage needs. Increasing throughput units prevents throttling scenarios.", "Azure Resource Inventory")
                $excel.'Event Hubs'.Cells["I1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/event-hubs/event-hubs-auto-inflate'
            }
        if($ExcelLB)
            {
                $null=$excel.'Load Balancers'.Cells["E1"].AddComment("No SLA is provided for Basic Load Balancer!", "Azure Resource Inventory")
                $excel.'Load Balancers'.Cells["E1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/load-balancer/skus'
            }


        if ($Adv)            
            {
                $PTParams = @{
                    PivotTableName    = "P0"
                    Address           = $excel.Overview.cells["A3"] # top-left corner of the table
                    SourceWorkSheet   = $excel.Advisor
                    PivotRows         = @("Category")
                    PivotData         = @{"Category" = "Count" }
                    PivotTableStyle   = $tableStyle
                    IncludePivotChart = $true
                    ChartType         = "Pie"
                    ChartRow          = 0 # place the chart below row 22nd
                    ChartColumn       = 3
                    Activate          = $true
                    PivotFilter       = 'Impact'
                    ChartTitle        = 'Advisory'
                    ShowPercent       = $true
                    ChartHeight       = 300
                    ChartWidth        = 500
                }

                Add-PivotTable @PTParams
            }


        $PTParams = @{
            PivotTableName    = "P1"
            Address           = $excel.Overview.cells["A24"] # top-left corner of the table
            SourceWorkSheet   = $excel.Subscriptions
            PivotRows         = @("Subscription")
            PivotData         = @{"Resources" = "sum" }
            PivotTableStyle   = $tableStyle
            IncludePivotChart = $true
            ChartType         = "BarClustered"
            ChartRow          = 16 # place the chart below row 22nd
            ChartColumn       = 3
            Activate          = $true
            PivotFilter       = 'Resource Group', 'Resource Type'
            ChartTitle        = 'Subscriptions'
            NoLegend          = $true
            ShowPercent       = $true
            ChartHeight       = 500
            ChartWidth        = 500
        }

        Add-PivotTable @PTParams

        if ($AzCompute.AKS)
            {
                $PTParams = @{
                    PivotTableName    = "P2"
                    Address           = $excel.Overview.cells["M3"] # top-left corner of the table
                    SourceWorkSheet   = $excel.AKS
                    PivotRows         = @("Kubernetes Version")
                    PivotData         = @{"Clusters" = "Count" }
                    PivotTableStyle   = $tableStyle
                    IncludePivotChart = $true
                    ChartType         = "Pie"
                    ChartRow          = 0 # place the chart below row 22nd
                    ChartColumn       = 15
                    Activate          = $true
                    ChartTitle        = 'Azure Kubernetes Service'
                    PivotFilter       = 'Node Size', 'Location'
                    ShowPercent       = $true
                    ChartHeight       = 300
                    ChartWidth        = 500
                }

                Add-PivotTable @PTParams
            }
        elseif ($Security)
            {
                $PTParams = @{
                    PivotTableName    = "P2"
                    Address           = $excel.Overview.cells["M3"] # top-left corner of the table
                    SourceWorkSheet   = $excel.SecurityCenter
                    PivotRows         = @("Severity")
                    PivotData         = @{"Resource Name" = "Count" }
                    PivotTableStyle   = $tableStyle
                    IncludePivotChart = $true
                    ChartType         = "Pie"
                    ChartRow          = 0 # place the chart below row 22nd
                    ChartColumn       = 15
                    Activate          = $true
                    ChartTitle        = 'Azure Security Center'
                    PivotFilter       = 'Categories'
                    ShowPercent       = $true
                    ChartHeight       = 300
                    ChartWidth        = 500
                }

                Add-PivotTable @PTParams
            }

        if ($AzCompute.VM)
            {
                $PTParams = @{
                    PivotTableName  = "P3"
                    Address         = $excel.Overview.cells["M25"] # top-left corner of the table
                    SourceWorkSheet = $excel.VMs
                    PivotRows       = @("VM Size")
                    PivotData       = @{"Resource U" = "Sum" }
                    PivotTableStyle   = $tableStyle
                    IncludePivotChart = $true
                    ChartType         = "BarClustered"
                    ChartRow          = 16 # place the chart below row 22nd
                    ChartColumn       = 15
                    Activate          = $true
                    NoLegend          = $true
                    ChartTitle        = 'Azure Virtual Machine Sizes'
                    PivotFilter       = 'OS Type', 'Location', 'Power State'
                    ShowPercent       = $true
                    ChartHeight       = 500
                    ChartWidth        = 500
                }

                Add-PivotTable @PTParams
            }

        Close-ExcelPackage $excel 

        Write-Progress -activity 'Azure Resource Inventory Reporting Charts' -Status "100% Complete." -Completed

        Get-Job | Remove-Job
    }


    Extractor
    ImportDataExcel

}
$Measure = $Runtime.Totalminutes.ToString('#######.##')

$Total = $Resources.count

Write-Host ('Report Complete. Total Runtime was: ' + $Measure + ' Minutes')
Write-Host ('Total Resources: ' + $Total)
Write-Host ('Total Advisories: ' + $advco )
if ($SecurityCenter.IsPresent)
    {
        Write-Host ('Total Security Advisories: ' + $Secadvco)
    }

Write-Host ''
Write-Host ('Excel file saved at: ') -NoNewline
write-host $File -ForegroundColor Cyan
Write-Host ''
