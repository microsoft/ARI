##########################################################################################
#                                                                                        #
#                        * Azure Grinder Report Generator *                              #
#                                                                                        #
#       Version: 1.0.4                                                                   #
#       Authors: Claudio Merola <clvieira@microsoft.com>                                 #
#                Renato Gregio <renato.gregio@microsoft.com>                             #
#                                                                                        #
#       Date: 12/05/2020                                                                 #
#                                                                                        #
#           https://github.com/RenatoGregio/AzureResourceInventory                       #
#                                                                                        #
#                                                                                        #
#        DISCLAIMER:                                                                     #
#        Please note that while being developed by Microsoft employees,                  #
#        Azure Grinder Inventory is not a Microsoft service or product.                  #
#                                                                                        #         
#        Azure Grinder Inventory is a personal driven project, there are none implicit   # 
#        or explicit obligations related to this project, it is provided 'as is' with    #
#        no warranties and confer no rights.                                             #
#                                                                                        #
##########################################################################################


param ($TenantID, $SkipSecurityCenter = $false,$SubscriptionID) 

$Runtime = Measure-Command -Expression {

    if ($DebugPreference -eq 'Inquire') {
        $DebugPreference = 'Continue'
    }

    $ErrorActionPreference = "silentlycontinue"
    $DesktopPath = "C:\AzureGrinder"
    $CSPath = "$HOME/AzureGrinder"
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
        Write-Output "./AzGrinder.ps1"      
        Write-Output ""
        Write-Output "For PowerShell Desktop:"      
        Write-Output "./AzGrinder.ps1 -TenantID <Azure Tenant ID> "
        Write-Output "" 
        Write-Output "" 
    }

    <###################################################### Environment ######################################################################>

    function Extractor {
        function checkAzCli() {
            $azcli = az --version
            if ($null -eq $azcli) {
                throw "Azure Cli not found!"
                $host.Exit()
            }
            $azcliExt = az extension list --output json | ConvertFrom-Json
            if ($azcliExt.name -notin 'resource-graph') {
                az extension add --name resource-graph 
            }
            if ($null -eq (Get-InstalledModule -Name ImportExcel | Out-Null)) {
                Write-Debug ('ImportExcel Module is not installed, installing..')
                Install-Module -Name ImportExcel -Force
            }
            if ($null -eq (Get-InstalledModule -Name ImportExcel | Out-Null)) {
                Write-Debug ('ImportExcel Module is not installed, installing..')
                Install-Module -Name ImportExcel -Force -AllowClobber
            }
            if ($null -eq (Get-InstalledModule -Name ImportExcel | Out-Null)) {
                Write-Debug ('ImportExcel Module is not installed, installing..')
                Install-Module -Name ImportExcel -Scope CurrentUser
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
                $Tenants = az account list --query [].homeTenantId -o tsv --only-show-errors | Get-Unique
                    
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
                if($SubscriptionID)
                    {
                        $Global:Subscriptions = $Subscriptions | Where-Object { $_.ID -eq $SubscriptionID}
                    }
            }
        
            else {
                az account clear | Out-Null
                az login -t $TenantID | Out-Null
                $Global:Subscriptions = az account list --output json --only-show-errors | ConvertFrom-Json
                $Global:Subscriptions = $Subscriptions | Where-Object { $_.tenantID -eq $TenantID }
                if($SubscriptionID)
                {
                    $Global:Subscriptions = $Subscriptions | Where-Object { $_.ID -eq $SubscriptionID}
                }
            }
        }

        function checkPS() {
            if ($PSVersionTable.PSEdition -eq 'Desktop') {
                $Global:PSEnvironment = "Desktop"
                write-host "PowerShell Desktop Identified."
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

        Write-Progress -activity 'Azure Inventory' -Status "0% Complete." -PercentComplete 0 -CurrentOperation 'Checking Powershell..'
        checkPS

        <###################################################### Subscriptions ######################################################################>

        Write-Progress -activity 'Azure Inventory' -Status "2% Complete." -PercentComplete 2 -CurrentOperation 'Discovering Subscriptions..'

        $SubCount = $Subscriptions.count

        Write-Debug ('Number of Subscriptions Found: '+$SubCount)
        Write-Progress -activity 'Azure Inventory' -Status "3% Complete." -PercentComplete 3 -CurrentOperation "$SubCount Subscriptions found.."

        if ((Test-Path -Path $DefaultPath -PathType Container) -eq $false) {
            New-Item -Type Directory -Force -Path $DefaultPath | Out-Null
        }

        <######################################################## RESOURCES #######################################################################>

        Write-Progress -activity 'Azure Inventory' -Status "4% Complete." -PercentComplete 4 -CurrentOperation "Starting Resources extraction.."
 
        $Counter = 0

        Foreach ($Subscription in $Subscriptions) {

            $Prog = ($Counter / $SubCount) * 100
            $Prog = [math]::Round($Prog)
            $SubName = $Subscription.Name
                       
            $SUBID = $Subscription.id
            az account set --subscription $SUBID
            Write-Debug ('Extracting total number of Resources from Subscription: '+$SUBID)
            $EnvSize = az graph query -q "resources | where subscriptionId == '$SUBID' | summarize count()" --output json --only-show-errors | ConvertFrom-Json
            $EnvSizeNum = $EnvSize.'count_'
                
            Write-Debug ('Starting Resource Loop Extraction.')
            if ($EnvSizeNum -ge 1) 
                {
                    $Loop = $EnvSizeNum / 1000
                    $Loop = [math]::ceiling($Loop)
                    $Looper = 0
                    $Limit = 0

                    while ($Looper -lt $Loop) 
                        {
                            $Resource = az graph query -q  "resources | where subscriptionId == '$SUBID' | order by id asc" --skip $Limit --first 1000 --output json --only-show-errors | ConvertFrom-Json
                            $Global:Resources += $Resource 
                            if ($EnvSizeNum -ge 500000) 
                                {
                                    Start-Sleep 3
                                }
                            else 
                                {
                                    Start-Sleep 1
                                }        
                            $Looper ++
                            $Limit = $Limit + 1000
                            Write-Progress -activity 'Azure Inventory' -Status "$Looper / $Loop" -PercentComplete $Prog -CurrentOperation "Inventoring $EnvSizeNum Resources in Subscription: $SubName"
                        }
                }
            $Counter ++
        }   

        <######################################################### ADVISOR ######################################################################>

        Write-Debug ('Extracting total number of Advisories from Tenant')
        $AdvSize = az graph query -q  "advisorresources | summarize count()" --output json --only-show-errors | ConvertFrom-Json
        $AdvSizeNum = $AdvSize.'count_'


        if ($AdvSizeNum -ge 1) {
            $Loop = $AdvSizeNum / 1000
            $Loop = [math]::ceiling($Loop)
            $Looper = 0
            $Limit = 0
        
            while ($Looper -lt $Loop) 
                {
                    $Looper ++
                    Write-Progress -activity 'Azure Inventory' -Status "$Looper / $Loop" -PercentComplete 0 -CurrentOperation "Inventoring $AdvSizeNum Advisories"
                    $Advisor = az graph query -q "advisorresources | order by id asc" --skip $Limit --first 1000 --output json --only-show-errors | ConvertFrom-Json
                    $Global:Advisories += $Advisor
                    if ($AdvSizeNum -ge 500000) 
                        {
                            Start-Sleep 3
                        }
                    else 
                        {
                            Start-Sleep 1
                        }
                    $Limit = $Limit + 1000
                            
                    Write-Progress -activity 'Azure Inventory' -Status "$Looper / $Loop" -PercentComplete 100 -Completed
                }
        }

        <######################################################### Security Center ######################################################################>

        if ($SkipSecurityCenter) {
            Write-Host " Skiping Secuity Center Extraction"
            Write-Host " You set Azure Grinder Inventory to not collect Security Center Advisories."
            Write-Host " "
            Write-Host " Collecting Security Center Can increase considerably the execution time of Azure Grinder Inventory and the size of final report "
            Write-Host " "
            Write-Host " To skip Security Center report use <-SkipSecurityCenter> parameter. " 
            Write-Host " "
        }
        else {
            Write-Host " Azure Grinder Inventory are collecting Security Center Advisories."
            Write-Host " Collecting Security Center Can increase considerably the execution time of Azure Grinder Inventory and the size of final report "
            Write-Host " "
            Write-Host " If you want to skip Security Center report use <-SkipSecurityCenter> parameter. "
            Write-Host " "

            Write-Debug ('Extracting total number of Security Advisories from Tenant')
            $SecSize = az graph query -q  "securityresources | where properties['status']['code'] == 'Unhealthy' | summarize count()" --output json --only-show-errors | ConvertFrom-Json
            $SecSizeNum = $SecSize.'count_'


            if ($SecSizeNum -ge 1) {
                $Loop = $SecSizeNum / 1000
                $Loop = [math]::ceiling($Loop)
                $Looper = 0
                $Limit = 0
            
                while ($Looper -lt $Loop) {
                    $Looper ++
                    Write-Progress -activity 'Azure Security Center' -Status "$Looper / $Loop" -PercentComplete 0 -CurrentOperation "Inventoring $SecSizeNum Security Center Advisories"
                    $SecCenter = az graph query -q "securityresources | order by id asc | where properties['status']['code'] == 'Unhealthy'" --skip $Limit --first 1000 --output json --only-show-errors | ConvertFrom-Json
                    $Global:Security += $SecCenter
                    if ($SecSizeNum -ge 500000) 
                        {
                            Start-Sleep 3
                        }
                    else 
                        {
                            Start-Sleep 1
                        }
                    $Limit = $Limit + 1000
                            
                    Write-Progress -activity 'Azure Security Center' -Status "$Looper / $Loop" -PercentComplete 100 -Completed
                }
            }
        } 
    }
    <######################################################### END Extractor Function ######################################################################>



    <################################################################################################ GRINDER  #############################################################################################>

    function Grinder {
        $SUBs = $Subscriptions

        Get-Job | Remove-Job

        <######################################################### RESOURCES JOB ######################################################################>

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
        $VMSCS = @()
        $LB = @()
        $SQLSERVER = @()

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
            if ($Resource.TYPE -eq 'microsoft.compute/virtualmachinescalesets' ) { $VMSCS += $Resource }
            if ($Resource.TYPE -eq 'microsoft.network/loadbalancers' ) { $LB += $Resource }
            if ($Resource.TYPE -eq 'microsoft.sql/servers' ) { $SQLSERVER += $Resource }
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
                    'Subscription ID'    = $sub1.Name;
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
        } -ArgumentList $Security, $Subs | Out-Null


        <######################################################### COMPUTE RESOURCE GROUP JOB ######################################################################>

        Start-Job -Name 'Compute' -ScriptBlock {

            $job = @()

            $VM = ([PowerShell]::Create()).AddScript( { param($Sub, $VM, $NIC, $NSG, $EXT)
                    $vm = $VM
                    $vmexp = $EXT
                    $nic = $NIC
                    $nsg = $NSG
                    $Subs = $Sub

                    $obj = ''
                    $tmp = @()

                    foreach ($1 in $vm) {
                        $sub1 = $SUBs | Where-Object { $_.id -eq $1.subscriptionId }
                        $data = $1.PROPERTIES 
                        $os = if ($null -eq $data.OSProfile.LinuxConfiguration) { 'Windows' }else { 'Linux' }
                        $AVSET = ''
                        $dataSize = ''
                        $StorAcc = ''

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

                        if ($null -ne $data.networkProfile.networkInterfaces.id) {
                            foreach ($2 in $data.networkProfile.networkInterfaces.id) {
                                $vmnic = $nic | Where-Object { $_.ID -eq $2 }
                                $vmnsg = $nsg | Where-Object { $_.properties.networkInterfaces.id -eq $2 }
                                foreach ($3 in $vmnic.properties.ipConfigurations.properties) {
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
                                        'Boot Diagnostics'              = $bootdg;
                                        'Performance Diagnostic Agent'  = if ($azDiag -ne '') { $true }else { $false };
                                        'Azure Monitor'                 = if ($Azinsights -ne '') { $true }else { $false };
                                        'OS Disk Storage Type'          = $data.storageProfile.osDisk.managedDisk.storageAccountType;
                                        'OS Disk Size (GB)'             = $data.storageProfile.osDisk.diskSizeGB;
                                        'Data Disk Storage Type'        = $StorAcc;
                                        'Data Disk Size (GB)'           = $dataSize;
                                        'Power State'                   = $data.extended.instanceView.powerState.displayStatus;
                                        'NIC Name'                      = $vmnic.name;
                                        'NIC Type'                      = $vmnic.properties.nicType;
                                        'NSG'                           = if ($null -eq $vmnsg.NAME) { 'None' }else { $vmnsg.NAME };
                                        'Enable Accelerated Networking' = $vmnic.properties.enableAcceleratedNetworking;
                                        'Enable IP Forwarding'          = $vmnic.properties.enableIPForwarding;
                                        'Primary IP'                    = $3.primary;
                                        'Private IP Version'            = $3.privateIPAddressVersion;
                                        'Private IP Address'            = $3.privateIPAddress;
                                        'Private IP Allocation Method'  = $3.privateIPAllocationMethod;
                                        'VM Extensions'                 = $ext
                                    }
                                    $tmp += $obj
                                }
                            }
                        }
                        else {
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
                                'VM Extensions'                 = $ext
                            }
                            $tmp += $obj
                        }
                    }
                    $tmp
                }).AddArgument($($args[0])).AddArgument($($args[1])).AddArgument($($args[2])).AddArgument($($args[3])).AddArgument($($args[4]))

            $VMDisk = ([PowerShell]::Create()).AddScript( { param($Sub, $VMDisk)
                    $tmp = @()

                    $disk = $VMDisk
                    $Subs = $Sub

                    foreach ($1 in $disk) {

                        $sub1 = $SUBs | Where-Object { $_.id -eq $1.subscriptionId }
                        $data = $1.PROPERTIES
                        $SKU = $1.SKU 

                        $obj = @{
                            'Subscription'           = $sub1.name;
                            'Resource Group'         = $1.RESOURCEGROUP;
                            'Virtual Machine'        = $1.MANAGEDBY.split('/')[8];
                            'Disk Name'              = $1.NAME;
                            'Location'               = $1.LOCATION;
                            'Zone'                   = [string]$1.ZONES;
                            'SKU'                    = $SKU.Name;
                            'Disk Size'              = $data.diskSizeGB;
                            'OS Type'                = $data.osType;
                            'Disk IOPS Read / Write' = $data.diskIOPSReadWrite;
                            'Disk MBps Read / Write' = $data.diskMBpsReadWrite;
                            'Disk State'             = $data.diskState;
                            'HyperV Generation'      = $data.hyperVGeneration
                        }         
                        $tmp += $obj
                    }
                    $tmp
                }).AddArgument($($args[0])).AddArgument($($args[5]))


            $SQLVM = ([PowerShell]::Create()).AddScript( { param($Sub, $SQLVM)
                    $tmp = @()

                    $sqlvm = $SQLVM
                    $Subs = $Sub

                    foreach ($1 in $sqlvm) {

                        $sub1 = $SUBs | Where-Object { $_.id -eq $1.subscriptionId }
                        $data = $1.PROPERTIES

                        $obj = @{
                            'Subscription'            = $sub1.name;
                            'ResourceGroup'           = $1.RESOURCEGROUP;
                            'Name'                    = $1.NAME;
                            'Location'                = $1.LOCATION;
                            'Zone'                    = $1.ZONES;
                            'SQL Server License Type' = $data.sqlServerLicenseType;
                            'SQL Image'               = $data.sqlImageOffer;
                            'SQL Management'          = $data.sqlManagement;
                            'SQL Image Sku'           = $data.sqlImageSku
                        }
                        $tmp += $obj
                    }
                    $tmp
                }).AddArgument($($args[0])).AddArgument($($args[6]))



            $WebServerFarm = ([PowerShell]::Create()).AddScript( { param($Sub, $SERVERFARM)
                    $tmp = @()

                    $webfarm = $SERVERFARM
                    $Subs = $Sub

                    foreach ($1 in $webfarm) {

                        $sub1 = $SUBs | Where-Object { $_.id -eq $1.subscriptionId }
                        $data = $1.PROPERTIES
                        $sku = $1.SKU

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
                            'Plan Name'           = $data.planName
                        }
                        $tmp += $obj
                    }
                    $tmp
                }).AddArgument($($args[0])).AddArgument($($args[7]))



            $AKS = ([PowerShell]::Create()).AddScript( { param($Sub, $AKS)
                    $tmp = @()

                    $AKS = $AKS
                    $Subs = $Sub

                    foreach ($1 in $AKS) {

                        $sub1 = $SUBs | Where-Object { $_.id -eq $1.subscriptionId }
                        $data = $1.PROPERTIES
                        if ($data.kubernetesVersion -lt 1.17) {
                            $ver = 'UNSUPPORTED'
                        }
                        else {
                            $ver = 'SUPPORTED'
                        }

                        foreach ($2 in $data.agentPoolProfiles) {
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
                            }
                            $tmp += $obj
                        }
                    }
                    $tmp
                }).AddArgument($($args[0])).AddArgument($($args[8]))


            $VMSCS = ([PowerShell]::Create()).AddScript( { param($Sub, $vmscs)
                    $tmp = @()

                    $vmscs = $vmscs
                    $Subs = $Sub

                    foreach ($1 in $vmscs) {

                        $sub1 = $SUBs | Where-Object { $_.id -eq $1.subscriptionId }
                        $data = $1.PROPERTIES
                            
                        foreach ($2 in $data.virtualMachineProfile.networkProfile.networkInterfaceConfigurations) {
        
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
                                'VM Name Prefix'                = $data.virtualMachineProfile.osProfile.computerNamePrefix
                            }
                            $tmp += $obj
                        }
                    }
                    $tmp
                }).AddArgument($($args[0])).AddArgument($($args[9]))


            $CON = ([PowerShell]::Create()).AddScript( { param($Sub, $con)
                    $tmp = @()

                    $con = $con
                    $Subs = $Sub

                    foreach ($1 in $con) {

                        $sub1 = $SUBs | Where-Object { $_.id -eq $1.subscriptionId }
                        $data = $1.PROPERTIES

                        foreach ($2 in $data.containers) {

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
                                'Port'                = [string]$2.properties.ports.port
                            }

                            $tmp += $obj
                        }
                    }
                    $tmp
                }).AddArgument($($args[0])).AddArgument($($args[10]))



            $SQLSRV = ([PowerShell]::Create()).AddScript( { param($Sub, $SQLSERVER)
                    $tmp = @()

                    $SQLServer = $SQLSERVER
                    $Subs = $Sub
    
                    foreach ($1 in $SQLServer) {
                        $Progress = ($Counter / $SQLServer.count) * 100
                        $Progress = [math]::Round($Progress)
                        Write-Progress -id 1 -activity "Building SQL Servers Report" -Status "$Progress% Complete." -PercentComplete $Progress 
                        $Counter ++
    
                        $sub1 = $SUBs | Where-Object { $_.id -eq $1.subscriptionId }
                        $data = $1.PROPERTIES
    
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
                            'Version'               = $data.version
                        }
                        $tmp += $obj
                    }
                    $tmp
                }).AddArgument($($args[0])).AddArgument($($args[11]))

            $jobVM = $VM.BeginInvoke()
            $jobVMDisk = $VMDisk.BeginInvoke()
            $jobSQLVM = $SQLVM.BeginInvoke()
            $jobSERVERFARM = $WebServerFarm.BeginInvoke()
            $jobAKS = $AKS.BeginInvoke()
            $jobVMSCS = $VMSCS.BeginInvoke()
            $jobCON = $CON.BeginInvoke()
            $jobSQLSRV = $SQLSRV.BeginInvoke()
    
            $job += $jobVM
            $job += $jobVMDisk
            $job += $jobSQLVM
            $job += $jobSERVERFARM
            $job += $jobAKS
            $job += $jobVMSCS
            $job += $jobCON
            $job += $jobSQLSRV

            while ($Job.Runspace.IsCompleted -contains $false) {}

            $VMS = $VM.EndInvoke($jobVM)
            $VMDiskS = $VMDisk.EndInvoke($jobVMDisk)
            $SQLVMS = $SQLVM.EndInvoke($jobSQLVM)
            $WebServerFarmS = $WebServerFarm.EndInvoke($jobSERVERFARM)
            $AKSS = $AKS.EndInvoke($jobAKS)
            $VMSCSS = $VMSCS.EndInvoke($jobVMSCS)
            $CONS = $CON.EndInvoke($jobCON)
            $SQLSRVS = $SQLSRV.EndInvoke($jobSQLSRV)
    
            $VM.Dispose()
            $VMDisk.Dispose()
            $SQLVM.Dispose()
            $WebServerFarm.Dispose()
            $AKS.Dispose()
            $VMSCS.Dispose()
            $CON.Dispose()
            $SQLSRV.Dispose()

            $AzCompute = @{
                'VM'         = $VMS;
                'VMDisk'     = $VMDiskS;
                'SQLVM'      = $SQLVMS;
                'SERVERFARM' = $WebServerFarmS;
                'AKS'        = $AKSS;
                'VMSCS'      = $VMSCSS;
                'CON'        = $CONS;
                'SQLSERVER'  = $SQLSRVS
            }

            $AzCompute

        } -ArgumentList $SUBs, $VM, $VMNIC, $NSG, $VMExp, $VMDisk, $SQLVM, $SERVERFARM, $AKS, $VMSCS, $CON, $SQLSERVER   | Out-Null


        <######################################################### NETWORK RESOURCE GROUP JOB ######################################################################>

        Start-Job -Name 'Network' -ScriptBlock {

            $job = @()

            $VNET = ([PowerShell]::Create()).AddScript( { param($Sub, $VNet)
                    $tmp = @()

                    $vnet = $VNet
                    $Subs = $Sub

                    foreach ($1 in $vnet) {

                        $sub1 = $SUBs | Where-Object { $_.id -eq $1.subscriptionId }
                        $data = $1.PROPERTIES

                        foreach ($2 in $data.addressSpace.addressPrefixes) {
                            foreach ($3 in $data.subnets) {
                                
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
                                    'Subnet Private Endpoint Network Policies'     = $3.properties.privateEndpointNetworkPolicies
                                }
                                $tmp += $obj
                            }
                        }
                    }
                    $tmp
                }).AddArgument($($args[0])).AddArgument($($args[1]))


            $VNETGTW = ([PowerShell]::Create()).AddScript( { param($Sub, $VNETGTW)
                    $tmp = @()

                    $vgtws = $VNETGTW
                    $Subs = $Sub

                    foreach ($1 in $vgtws) {

                        $sub1 = $SUBs | Where-Object { $_.id -eq $1.subscriptionId }
                        $data = $1.PROPERTIES
                                                    
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
                        }
                        $tmp += $obj
                    }
                    $tmp
                }).AddArgument($($args[0])).AddArgument($($args[2]))


            $PIP = ([PowerShell]::Create()).AddScript( { param($Sub, $PIP)
                    $tmp = @()

                    $pubip = $PIP
                    $Subs = $Sub

                    foreach ($1 in $pubip) {

                        $sub1 = $SUBs | Where-Object { $_.id -eq $1.subscriptionId }
                        $data = $1.PROPERTIES

                        if ($null -ne $data.ipConfiguration.id) {
                            $obj = @{
                                'Subscription'             = $sub1.name;
                                'Resource Group'           = $1.RESOURCEGROUP;
                                'Name'                     = $1.NAME;
                                'SKU'                      = $1.SKU.Name;
                                'Location'                 = $1.LOCATION;
                                'Type'                     = $data.publicIPAllocationMethod;
                                'Version'                  = $data.publicIPAddressVersion;
                                'IP Address'               = $data.ipAddress;
                                'Associated Resource'      = $data.ipConfiguration.id.split('/')[8];
                                'Associated Resource Type' = $data.ipConfiguration.id.split('/')[7]
                            }
                            $tmp += $obj
                        }
                        else {
                            $obj = @{
                                'Subscription'             = $sub1.name;
                                'Resource Group'           = $1.RESOURCEGROUP;
                                'Name'                     = $1.NAME;
                                'SKU'                      = $1.SKU.Name;
                                'Location'                 = $1.LOCATION;
                                'Type'                     = $data.publicIPAllocationMethod;
                                'Version'                  = $data.publicIPAddressVersion;
                                'IP Address'               = $data.ipAddress;
                                'Associated Resource'      = $null;
                                'Associated Resource Type' = $null
                            }
                            $tmp += $obj
                        }
                    }
                    $tmp
                }).AddArgument($($args[0])).AddArgument($($args[3]))


            $LB = ([PowerShell]::Create()).AddScript( { param($Sub, $LB)
                    $tmp = @()

                    $lbs = $LB
                    $Subs = $Sub

                    foreach ($1 in $lbs) {

                        $sub1 = $SUBs | Where-Object { $_.id -eq $1.subscriptionId }
                        $data = $1.PROPERTIES

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
                                        }
                                        $tmp += $obj          
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
                                    }
                                    $tmp += $obj         
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
                                }
                                $tmp += $obj             
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
                                    }
                                    $tmp += $obj            
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
                                    }
                                    $tmp += $obj            
                                }
                            }            
                        }    
                        elseif ($null -eq $data.frontendIPConfigurations -and $null -eq $data.backendAddressPools -and $null -ne $data.probes) {
                            foreach ($2 in $data.probes) {
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
                                }
                                $tmp += $obj
                            }            
                        }
                    }
                    $tmp
                }).AddArgument($($args[0])).AddArgument($($args[4]))



            $Peering = ([PowerShell]::Create()).AddScript( { param($Sub, $VNET)
                    $tmp = @()

                    $vnet = $VNET
                    $vpeering = $vnet | Where-Object { $null -ne $_.properties.virtualNetworkPeerings }

                    $Subs = $Sub

                    foreach ($1 in $vpeering) {

                        $sub1 = $SUBs | Where-Object { $_.id -eq $1.subscriptionId }
                        $data = $1.PROPERTIES

                        foreach ($2 in $data.addressSpace.addressPrefixes) {
                            foreach ($4 in $data.virtualNetworkPeerings) {
                                foreach ($5 in $4.properties.remoteAddressSpace.addressPrefixes) {
                            
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
                                        'Peering Address Space'                 = $5
                                    }
                                    $tmp += $obj
                                }
                            }
                        }
                            
                    }
                    $tmp
                }).AddArgument($($args[0])).AddArgument($($args[1]))

            $jobVNET = $VNET.BeginInvoke()
            $jobVNETGTW = $VNETGTW.BeginInvoke()
            $jobPIP = $PIP.BeginInvoke()
            $jobLB = $LB.BeginInvoke()
            $jobPeering = $Peering.BeginInvoke()

            $job += $jobVNET
            $job += $jobVNETGTW
            $job += $jobPIP
            $job += $jobLB
            $job += $jobPeering

            while ($Job.Runspace.IsCompleted -contains $false) {}

            $VNETS = $VNET.EndInvoke($jobVNET)
            $VNETGTWS = $VNETGTW.EndInvoke($jobVNETGTW)
            $PIPS = $PIP.EndInvoke($jobPIP)
            $LBS = $LB.EndInvoke($jobLB)
            $PeeringS = $Peering.EndInvoke($jobPeering)

            $VNET.Dispose()
            $VNETGTW.Dispose()
            $PIP.Dispose()
            $LB.Dispose()
            $Peering.Dispose()

            $AzNetwork = @{
                'VNET'    = $VNETS;
                'VNETGTW' = $VNETGTWS;
                'PIP'     = $PIPS;
                'LB'      = $LBS;
                'Peering' = $PeeringS
            }

            $AzNetwork

        } -ArgumentList $Subs, $VNET, $VNETGTW, $PIP, $LB | Out-Null


        <######################################################### INFRASTRUCTURE RESOURCE GROUP JOB ######################################################################>


        Start-Job -Name 'Infra' -ScriptBlock {

            $job = @()

            $StorageAcc = ([PowerShell]::Create()).AddScript( { param($Sub, $StorageAcc)
                    $tmp = @()

                    $storageacc = $StorageAcc
                    $Subs = $Sub

                    foreach ($1 in $storageacc) {

                        $sub1 = $SUBs | Where-Object { $_.id -eq $1.subscriptionId }
                        $data = $1.PROPERTIES
                        $TLSv = if ($data.minimumTlsVersion -eq 'TLS1_2') { "TLS 1.2" }elseif ($data.minimumTlsVersion -eq 'TLS1_1') { "TLS 1.1" }else { "TLS 1.0" }

                        $obj = @{
                            'Subscription'                          = $sub1.name;
                            'Resource Group'                        = $1.RESOURCEGROUP;
                            'Name'                                  = $1.NAME;
                            'Location'                              = $1.LOCATION;
                            'Zone'                                  = $1.ZONES;
                            'Supports HTTPs Traffic Only'           = $data.supportsHttpsTrafficOnly;
                            'Allow Blob Public Access'              = if ($data.allowBlobPublicAccess -eq 'False') { $false }else { $true };
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
                            'Network Acls'                          = $data.networkAcls.defaultAction
                        }
                        $tmp += $obj
                    }
                    $tmp
                }).AddArgument($($args[0])).AddArgument($($args[1]))



            $AutAcc = ([PowerShell]::Create()).AddScript( { param($Sub, $RunBook, $AutAcc)
                    $tmp = @()

                    $runbook = $RunBook
                    $autacc = $AutAcc
                    $Subs = $Sub

                    foreach ($0 in $autacc) {

                        $sub1 = $SUBs | Where-Object { $_.id -eq $0.subscriptionId }
                            
                        $rbs = $runbook | Where-Object { $_.id.split('/')[8] -eq $0.name }
                        if ($null -ne $rbs) {
                            foreach ($1 in $rbs) {
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
                                    'Job Count'                = $data.jobCount
                                }
                                $tmp += $obj
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
                                'Job Count'                = $null
                            }
                            $tmp += $obj
                        }
                    }
                    $tmp
                }).AddArgument($($args[0])).AddArgument($($args[2])).AddArgument($($args[3]))


            $EvtHub = ([PowerShell]::Create()).AddScript( { param($Sub, $evthub)
                    $tmp = @()

                    $evthub = $evthub
                    $Subs = $Sub

                    foreach ($1 in $evthub) {

                        $sub1 = $SUBs | Where-Object { $_.id -eq $1.subscriptionId }
                        $data = $1.PROPERTIES
                        $sku = $1.SKU

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
                            'Endpoint'             = $data.serviceBusEndpoint
                        }

                        $tmp += $obj
                    }
                    $tmp
                }).AddArgument($($args[0])).AddArgument($($args[4]))



            $WrkSpace = ([PowerShell]::Create()).AddScript( { param($Sub, $WRKSPACE)
                    $tmp = @()

                    $wrkspace = $WRKSPACE
                    $Subs = $Sub

                    foreach ($1 in $wrkspace) {

                        $sub1 = $SUBs | Where-Object { $_.id -eq $1.subscriptionId }
                        $data = $1.PROPERTIES

                        $obj = @{
                            'Subscription'     = $sub1.name;
                            'Resource Group'   = $1.RESOURCEGROUP;
                            'Name'             = $1.NAME;
                            'Location'         = $1.LOCATION;
                            'SKU'              = $data.sku.name;
                            'Retention Days'   = $data.retentionInDays;
                            'Daily Quota (GB)' = [decimal]$data.workspaceCapping.dailyQuotaGb
                        }
                        $tmp += $obj
                    }
                    $tmp
                }).AddArgument($($args[0])).AddArgument($($args[5]))


            $AvSet = ([PowerShell]::Create()).AddScript( { param($Sub, $AvSet)
                    $tmp = @()

                    $AvSet = $AvSet
                    $Subs = $Sub

                    foreach ($1 in $AvSet) {

                        $sub1 = $SUBs | Where-Object { $_.id -eq $1.subscriptionId }
                        $data = $1.PROPERTIES

                        Foreach ($vmid in $data.virtualMachines.id) {
                            $vmIds = $vmid.split('/')[8]


                            $obj = @{
                                'Subscription'     = $sub1.name;
                                'Resource Group'   = $1.RESOURCEGROUP;
                                'Name'             = $1.NAME;
                                'Location'         = $1.LOCATION;
                                'Fault Domains'    = $data.platformFaultDomainCount;
                                'Update Domains'   = $data.platformUpdateDomainCount;
                                'Virtual Machines' = $vmIds
                            }

                            $tmp += $obj
                        }
                    }
                    $tmp
                }).AddArgument($($args[0])).AddArgument($($args[6]))


            $WebSite = ([PowerShell]::Create()).AddScript( { param($Sub, $SITES)
                    $tmp = @()

                    $WebSite = $SITES
                    $Subs = $Sub

                    foreach ($1 in $WebSite) {

                        $sub1 = $SUBs | Where-Object { $_.id -eq $1.subscriptionId }
                        $data = $1.PROPERTIES

                        foreach ($2 in $data.hostNameSslStates) {
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
                                'HTTPS Only'                    = $data.httpsOnly
                            }
                            $tmp += $obj
                        }
                    }
                    $tmp
                }).AddArgument($($args[0])).AddArgument($($args[7]))




            $jobStorageAcc = $StorageAcc.BeginInvoke()
            $jobAutAcc = $AutAcc.BeginInvoke()
            $jobEvtHub = $EvtHub.BeginInvoke()
            $jobWrkSpace = $WrkSpace.BeginInvoke()
            $jobAvSet = $AvSet.BeginInvoke()
            $jobWebSite = $WebSite.BeginInvoke()

            $job += $jobStorageAcc
            $job += $jobAutAcc
            $job += $jobEvtHub
            $job += $jobWrkSpace
            $job += $jobAvSet
            $job += $jobWebSite

            while ($Job.Runspace.IsCompleted -contains $false) {}

            $StorageAccS = $StorageAcc.EndInvoke($jobStorageAcc)
            $AutAccS = $AutAcc.EndInvoke($jobAutAcc)
            $EvtHubS = $EvtHub.EndInvoke($jobEvtHub)
            $WrkSpaceS = $WrkSpace.EndInvoke($jobWrkSpace)
            $AvSetS = $AvSet.EndInvoke($jobAvSet)
            $WebSiteS = $WebSite.EndInvoke($jobWebSite)

            $StorageAcc.Dispose()
            $AutAcc.Dispose()
            $EvtHub.Dispose()
            $WrkSpace.Dispose()
            $AvSet.Dispose()
            $WebSite.Dispose()

            $AzInfra = @{
                'StorageAcc'    = $StorageAccS;
                'AutomationAcc' = $AutAccS;
                'EvtHub'        = $EvtHubS;
                'WrkSpace'      = $WrkSpaceS;
                'AvSet'         = $AvSetS;
                'WebSite'       = $WebSiteS
            }

            $AzInfra

        } -ArgumentList $Subs, $StorageAcc, $RB, $AUT, $EVTHUB, $WRKSPACE, $AVSET, $SITES | Out-Null



        <######################################################### DATABASES RESOURCE GROUP JOB ######################################################################>


        Start-Job -Name 'Database' -ScriptBlock {

            $job = @()

            $DB = ([PowerShell]::Create()).AddScript( { param($Sub, $DB)
                    $tmp = @()

                    $db = $DB
                    $Subs = $Sub

                    foreach ($1 in $db) {

                        $sub1 = $SUBs | Where-Object { $_.id -eq $1.subscriptionId }
                        $data = $1.PROPERTIES

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
                        }
                        $tmp += $obj
                    }
                    $tmp
                }).AddArgument($($args[0])).AddArgument($($args[1]))

            $MySQL = ([PowerShell]::Create()).AddScript( { param($Sub, $MySQL)
                    $tmp = @()

                    $mysql = $MySQL
                    $Subs = $Sub

                    foreach ($1 in $mysql) {

                        $sub1 = $SUBs | Where-Object { $_.id -eq $1.subscriptionId }
                        $data = $1.PROPERTIES
                        $sku = $1.SKU

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
                            'ssl Enforcement'           = $data.sslEnforcement
                        }

                        $tmp += $obj
                    }
                    $tmp
                }).AddArgument($($args[0])).AddArgument($($args[2]))

            $PostGre = ([PowerShell]::Create()).AddScript( { param($Sub, $PostGre)
                    $tmp = @()

                    $postgre = $PostGre
                    $Subs = $Sub

                    foreach ($1 in $postgre) {

                        $sub1 = $SUBs | Where-Object { $_.id -eq $1.subscriptionId }
                        $data = $1.PROPERTIES
                        $sku = $1.SKU

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
                            'ssl Enforcement'           = $data.sslEnforcement
                        }
                        $tmp += $obj
                    }
                    $tmp
                }).AddArgument($($args[0])).AddArgument($($args[3]))

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

        } -ArgumentList $Subs, $DB, $MySQL, $POSTGRE | Out-Null



        <########################################## INITIAL VALIDATIONS ######################################################>

        #### Creating Excel file variable:
        $Global:File = ($DefaultPath + "AzureGrinder_Report_" + (get-date -Format "yyyy-MM-dd_HH_mm") + ".xlsx")
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

            $GrinderActive = ('Azure Grinder Reporting (' + ($resources.count - $advco) + ') Resources')

            Write-Progress -activity $GrinderActive -Status "Building Advisories Report" -PercentComplete 0 -CurrentOperation "Considering $advco Advisories"
        
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

            Write-Progress -activity $GrinderActive -Status "Building Security Center Report" -PercentComplete 0 -CurrentOperation "Considering $Secadvco Security Advisories"

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


        Write-Progress -activity $GrinderActive -Status "Processing Resources Inventory" -PercentComplete 0
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

                Write-Progress -activity $GrinderActive -Status "$Prog% Complete." -PercentComplete $Prog 
                $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0' -VerticalAlignment Center
                $StyleExt = New-ExcelStyle -HorizontalAlignment Left -Range AD:AD -Width 60 -WrapText 
                $condtxtvm = $(New-ConditionalText None -Range W:W
                    New-ConditionalText false -Range K:K
                    New-ConditionalText falso -Range K:K
                    New-ConditionalText false -Range L:L
                    New-ConditionalText falso -Range L:L
                    New-ConditionalText false -Range M:M
                    New-ConditionalText falso -Range M:M
                    New-ConditionalText false -Range X:X
                    New-ConditionalText falso -Range X:X)


                $ExcelVMs = $AzCompute.VM

                $ExcelVMs | 
                ForEach-Object { [PSCustomObject]$_ } | 
                Select-Object 'Subscription',
                'Resource Group',
                'Computer Name',
                'VM Size',
                'OS Type',
                'Location',
                'Image Reference',
                'Image Version',
                'SKU',
                'Admin Username',
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
                'VM Extensions' | 
                Export-Excel -Path $File -WorksheetName 'VMs' -TableName 'AzureVMs' -TableStyle $tableStyle -ConditionalText $condtxtvm -Style $Style, $StyleExt

            }

            <################################################################# 2 - Virtual Machine Disks ###################################################################>

            if ($Type -eq 'microsoft.compute/disks') {

                Write-Progress -activity $GrinderActive -Status "$Prog% Complete." -PercentComplete $Prog 
                $condtxtdsk = New-ConditionalText Unattached -Range J:J
                $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'
         

                $ExcelVMDisks = $AzCompute.VMDisk
                        
                $ExcelVMDisks | 
                ForEach-Object { [PSCustomObject]$_ } | 
                Select-Object 'Subscription',
                'Resource Group',
                'Virtual Machine',
                'Disk Name',
                'Zone',
                'SKU',
                'Disk Size',
                'Location',
                'OS Type',
                'Disk State',
                'Disk IOPS Read / Write',
                'Disk MBps Read / Write',
                'HyperV Generation' | 
                Export-Excel -Path $File -WorksheetName 'Disks' -TableName 'AzureDisks' -TableStyle $tableStyle -ConditionalText $condtxtdsk -Style $Style

            }


            <############################################################################## 3 - Storage Account ###################################################################>


            if ($Type -eq 'microsoft.storage/storageaccounts') {

                Write-Progress -activity $GrinderActive -Status "$Prog% Complete." -PercentComplete $Prog 
                $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0

                $condtxtStorage = $(New-ConditionalText false -Range F:F
                    New-ConditionalText falso -Range F:F
                    New-ConditionalText true -Range G:G
                    New-ConditionalText verdadeiro -Range G:G
                    New-ConditionalText 1.0 -Range H:H)

                $ExcelStorageAcc = $AzInfra.StorageAcc
            
                $ExcelStorageAcc | 
                ForEach-Object { [PSCustomObject]$_ } | 
                Select-Object 'Subscription',
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


            <############################################################################## 4 - Virtual Network  ###################################################################>

            if ($Type -eq 'microsoft.network/virtualnetworks') {
                Write-Progress -activity $GrinderActive -Status "$Prog% Complete." -PercentComplete $Prog 
                $txtvnet = $(New-ConditionalText false -Range G:H
                    New-ConditionalText falso -Range G:H)

                $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

                $ExcelVNET = $AzNetwork.VNET          

                $ExcelVNET | 
                ForEach-Object { [PSCustomObject]$_ } | 
                Select-Object 'Subscription',
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
                'Subnet Private Endpoint Network Policies' | 
                Export-Excel -Path $File -WorksheetName 'VNET' -AutoSize -TableName 'AzureVNETs' -TableStyle $tableStyle -ConditionalText $txtvnet -Style $Style

            }


            <############################################################################## 5 - Virtual Network Gateway  ###################################################################>


            if ($Type -eq 'microsoft.network/virtualnetworkgateways') {

                Write-Progress -activity $GrinderActive -Status "$Prog% Complete." -PercentComplete $Prog
                $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'
    
                $ExcelVNETGTW = $AzNetwork.VNETGTW
                        
                $ExcelVNETGTW | 
                ForEach-Object { [PSCustomObject]$_ } | 
                Select-Object 'Subscription',
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
                'Gateway Subnet Name' | 
                Export-Excel -Path $File -WorksheetName 'Gateways' -AutoSize -TableName 'AzureVNETGateways' -TableStyle $tableStyle -ConditionalText $txtvnet -Style $Style
    
            }
    

            <############################################################################## 6 - SQL Virtual Machines  ###################################################################>


            if ($Type -eq 'microsoft.sqlvirtualmachine/sqlvirtualmachines') {

                Write-Progress -activity $GrinderActive -Status "$Prog% Complete." -PercentComplete $Prog 
                Write-Debug ('Generating SQL Virtual Machines sheet for: ' + $sqlvm.count + ' VMs.')

                $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

                $ExcelSQLVM = $AzCompute.SQLVM
            
                $ExcelSQLVM | 
                ForEach-Object { [PSCustomObject]$_ } | 
                Select-Object 'Subscription',
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


            <############################################################################## 7 - SQL Databases ###################################################################>


            if ($Type -eq 'microsoft.sql/servers/databases') {

                Write-Progress -activity $GrinderActive -Status "$Prog% Complete." -PercentComplete $Prog
                Write-Debug ('Generating SQL Database sheet for: ' + $db.count + ' DBs.')

                $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

                $ExcelDB = $AzDatabase.DB

                $ExcelDB | 
                ForEach-Object { [PSCustomObject]$_ } | 
                Select-Object 'Subscription',
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


            <############################################################################## 8 - Automation Acc / Runbooks ###################################################################>

            if ($Type -eq 'microsoft.automation/automationaccounts/runbooks') {

                Write-Progress -activity $GrinderActive -Status "$Prog% Complete." -PercentComplete $Prog
                Write-Debug ('Generating Runbook sheet for: ' + $runbook.count + ' Runbooks.')

                $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'
                $StyleExt = New-ExcelStyle -HorizontalAlignment Left -Range K:K -Width 80 -WrapText 

                $ExcelAutAcc = $AzInfra.AutomationAcc
            
                $ExcelAutAcc | 
                ForEach-Object { [PSCustomObject]$_ } | 
                Select-Object 'Subscription',
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

            <############################################################################## 9 - Public IPs ###################################################################>

            if ($Type -eq 'microsoft.network/publicipaddresses') {

                Write-Progress -activity $GrinderActive -Status "$Prog% Complete." -PercentComplete $Prog
                Write-Debug ('Generating Public IP sheet for: ' + $pubip.count + ' Public IPs.')

                $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

                $ExcelPIP = $AzNetwork.PIP
            
                $ExcelPIP | 
                ForEach-Object { [PSCustomObject]$_ } | 
                Select-Object 'Subscription',
                'Resource Group',
                'Name',
                'SKU',
                'Location',
                'Type',
                'Version',
                'IP Address',
                'Associated Resource',
                'Associated Resource Type' | 
                Export-Excel -Path $File -WorksheetName 'Public IPs' -AutoSize -TableName 'AzurePubIPs' -TableStyle $tableStyle -Style $Style

            }

            <############################################################################## 10 - Event Hubs ###################################################################>

            if ($Type -eq 'microsoft.eventhub/namespaces') {

                Write-Progress -activity $GrinderActive -Status "$Prog% Complete." -PercentComplete $Prog
                Write-Debug ('Generating Event Hub sheet for: ' + $evthub.count + ' Event Hubs.')

                $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

                $txtEvt = $(New-ConditionalText false -Range I:I
                    New-ConditionalText falso -Range I:I)

                $ExcelEvtHub = $AzInfra.EvtHub

                $ExcelEvtHub | 
                ForEach-Object { [PSCustomObject]$_ } | 
                Select-Object 'Subscription',
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

            <############################################################################## 11 - MySQL ###################################################################>

            if ($Type -eq 'microsoft.dbformysql/servers') {

                Write-Progress -activity $GrinderActive -Status "$Prog% Complete." -PercentComplete $Prog
                Write-Debug ('Generating MySQL Database sheet for: ' + $mysql.count + ' DBs.')

                $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'
          
                $ExcelMySQL = $AzDatabase.MySQL

                $ExcelMySQL | 
                ForEach-Object { [PSCustomObject]$_ } | 
                Select-Object 'Subscription',
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
                Export-Excel -Path $File -WorksheetName 'MySQL' -AutoSize -TableName 'AzureMySQL' -TableStyle $tableStyle -Style $Style

            }

            <############################################################################## 12 - PostgreSQL ###################################################################>

            if ($Type -eq 'microsoft.dbforpostgresql/servers') {

                Write-Progress -activity $GrinderActive -Status "$Prog% Complete." -PercentComplete $Prog
                Write-Debug ('Generating PostgreSQL sheet for: ' + $postgre.count + ' DBs.')

                $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

                $ExcelPostGre = $AzDatabase.PostGre
            
                $ExcelPostGre | 
                ForEach-Object { [PSCustomObject]$_ } | 
                Select-Object 'Subscription',
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

            <############################################################################## 13 - Web Server Farm ###################################################################>

            if ($Type -eq 'microsoft.web/serverfarms') {

                Write-Progress -activity $GrinderActive -Status "$Prog% Complete." -PercentComplete $Prog
                Write-Debug ('Generating Web Server Farm sheet for: ' + $webfarm.count + ' Web Servers.')

                $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

                $ExcelWebFarm = $AzCompute.SERVERFARM

                $ExcelWebFarm | 
                ForEach-Object { [PSCustomObject]$_ } | 
                Select-Object 'Subscription',
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

            <############################################################################## 14 - Workspaces ###################################################################>


            if ($Type -eq 'microsoft.operationalinsights/workspaces') {

                Write-Progress -activity $GrinderActive -Status "$Prog% Complete." -PercentComplete $Prog
                Write-Debug ('Generating Log Analytics Workspaces sheet for: ' + $wrkspace.count + ' Workspaces.')

                $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0.0'
            
                $ExcelWrkSpace = $AzInfra.WrkSpace

                $ExcelWrkSpace | 
                ForEach-Object { [PSCustomObject]$_ } | 
                Select-Object 'Subscription',
                'Resource Group',
                'Name',
                'Location',
                'SKU',
                'Retention Days',
                'Daily Quota (GB)' | 
                Export-Excel -Path $File -WorksheetName 'Workspaces' -AutoSize -TableName 'AzureWorkspace' -TableStyle $tableStyle -Style $Style

            }

            <############################################################################## 15 - AKS ###################################################################>


            if ($Type -eq 'microsoft.containerservice/managedclusters') {

                Write-Progress -activity $GrinderActive -Status "$Prog% Complete." -PercentComplete $Prog
                Write-Debug ('Generating AKS sheet for: ' + $AKS.count + ' Kubernetes Clusters.')

                $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

                $txtaksv = New-ConditionalText UNSUPPORTED -Range F:F

                $ExcelAKS = $AzCompute.AKS

                $ExcelAKS | 
                ForEach-Object { [PSCustomObject]$_ } | 
                Select-Object 'Subscription',
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

            <############################################################################## 16 - Containers ###################################################################>

            if ($Type -eq 'microsoft.containerinstance/containergroups') {

                Write-Progress -activity $GrinderActive -Status "$Prog% Complete." -PercentComplete $Prog
                Write-Debug ('Generating Containers sheet for: ' + $con.count + ' Containers.')

                $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

                $ExcelContainer = $AzCompute.CON
            
                $ExcelContainer | 
                ForEach-Object { [PSCustomObject]$_ } | 
                Select-Object 'Subscription',
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

            <############################################################################## 17 - Availability Sets ###################################################################>

            if ($Type -eq 'microsoft.compute/availabilitysets') {

                Write-Progress -activity $GrinderActive -Status "$Prog% Complete." -PercentComplete $Prog
                Write-Debug ('Generating Availability Set sheet for: ' + $AvSet.count + ' AV Sets.')

                $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'
            
                $ExcelAvSet = $AzInfra.AvSet

                $ExcelAvSet | 
                ForEach-Object { [PSCustomObject]$_ } | 
                Select-Object 'Subscription',
                'Resource Group',
                'Name',
                'Location',
                'Fault Domains',
                'Update Domains',
                'Virtual Machines' | 
                Export-Excel -Path $File -WorksheetName 'Availability Sets' -AutoSize -TableName 'AvailabilitySets' -TableStyle $tableStyle -Style $Style

            }

            <############################################################################## 18 - Web Sites ###################################################################>

            if ($Type -eq 'microsoft.web/sites') {

                Write-Progress -activity $GrinderActive -Status "$Prog% Complete." -PercentComplete $Prog
                Write-Debug ('Generating Web Site sheet for: ' + $db.count + ' Web Sites.')

                $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

                $ExcelWebSite = $AzInfra.WebSite

                $ExcelWebSite | 
                ForEach-Object { [PSCustomObject]$_ } | 
                Select-Object 'Subscription',
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

            <############################################################################## 19 - VM Scale Sets ###################################################################>

            if ($Type -eq 'microsoft.compute/virtualmachinescalesets') {
                Write-Progress -activity $GrinderActive -Status "$Prog% Complete." -PercentComplete $Prog 
                Write-Debug ('Generating Virtual Machine Scale Set sheet for: ' + $vmscs.count + ' VMSS.')

                $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'
                        
                $ExcelVMSCS = $AzCompute.VMSCS

                $ExcelVMSCS | 
                ForEach-Object { [PSCustomObject]$_ } | 
                Select-Object 'Subscription',
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
                Export-Excel -Path $File -WorksheetName 'VM Scale Sets' -AutoSize -TableName 'VMScaleSets' -TableStyle $tableStyle -Style $Style

            }


            <############################################################################## 20 - Load Balancers ###################################################################>


            if ($Type -eq 'microsoft.network/loadbalancers') {
                Write-Progress -activity $GrinderActive -Status "$Prog% Complete." -PercentComplete $Prog
                Write-Debug ('Generating Load Balancer sheet for: ' + $lbs.count + ' LBs.')

                $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

                $txtLB = New-ConditionalText Basic -Range E:E
                        
                $ExcelLB = $AzNetwork.LB

                $ExcelLB | 
                ForEach-Object { [PSCustomObject]$_ } | 
                Select-Object 'Subscription',
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


            <############################################################################## 21 - SQL Servers ###################################################################>

            if ($Type -eq 'microsoft.sql/servers') {

                Write-Progress -activity $GrinderActive -Status "$Prog% Complete." -PercentComplete $Prog
                Write-Debug ('Generating SQL Server sheet for: ' + $SQLServer.count + ' Servers.')
                    
                $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'
                    
                $ExcelSQLServer = $AzCompute.SQLSERVER
    
                $ExcelSQLServer | 
                ForEach-Object { [PSCustomObject]$_ } | 
                Select-Object 'Subscription',
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

            


            <############################################################################## 22 - Virtual Network Peering  ###################################################################>


            if ($Type -eq 'microsoft.network/virtualnetworks' -and $null -ne $AzNetwork.Peering -and $AzNetwork.Peering -ne '') {


                Write-Progress -activity $GrinderActive -Status "$Prog% Complete." -PercentComplete $Prog
                $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

                $ExcelPeering = $AzNetwork.Peering

                $ExcelPeering | 
                ForEach-Object { [PSCustomObject]$_ } | 
                Select-Object 'Subscription',
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

        Write-Progress -activity 'Azure Grinder Reporting Charts' -Status "1% Complete." -PercentComplete 10 -CurrentOperation "Building Excel Charts"
        $excel = Open-ExcelPackage -Path $file -KillExcel

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

        $PTParams = @{
            PivotTableName    = "P3"
            Address           = $excel.Overview.cells["M25"] # top-left corner of the table
            SourceWorkSheet   = $excel.VMs
            PivotRows         = @("VM Size")
            PivotData         = @{"VM Size" = "Count" }
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

        Close-ExcelPackage $excel 

        Write-Progress -activity 'Azure Grinder Reporting Charts' -Status "100% Complete." -Completed

        Get-Job | Remove-Job
    }


    Extractor
    Grinder

}
$Measure = $Runtime.Totalminutes.ToString('#######.##')

$Total = $Resources.count

Write-Host ('Report Complete. Total Runtime was: ' + $Measure + ' Minutes')
Write-Host ('Total Resources: ' + $Total)
Write-Host ('Total Advisories: ' + $advco )
Write-Host ('Total Security Advisories: ' + $Secadvco)


Write-Host ''
Write-Host ('Excel file saved at: ') -NoNewline
write-host $File -ForegroundColor Cyan
Write-Host ''
