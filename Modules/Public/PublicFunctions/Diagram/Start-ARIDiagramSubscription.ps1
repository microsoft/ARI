<#
.Synopsis
Subscription Module for Draw.io Diagram

.DESCRIPTION
This module is used for the Subscription topology in the Draw.io Diagram.

.Link
https://github.com/microsoft/ARI/Modules/Public/PublicFunctions/Diagram/Start-ARIDiagramSubscription.ps1

.COMPONENT
This PowerShell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.6.0
First Release Date: 15th Oct, 2024
Authors: Claudio Merola

#>
Function Start-ARIDiagramSubscription {
    Param($Subscriptions,$Resources,$DiagramCache,$LogFile) 

    ('DrawIOSubsFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Starting Subscription Function')
        Function Add-Icon {    
            Param($Style,$x,$y,$w,$h,$p)
            
                $Script:XmlWriter.WriteStartElement('mxCell')
                $Script:XmlWriter.WriteAttributeString('style', $Style)
                $Script:XmlWriter.WriteAttributeString('vertex', "1")
                $Script:XmlWriter.WriteAttributeString('parent', $p)
            
                    $Script:XmlWriter.WriteStartElement('mxGeometry')
                    $Script:XmlWriter.WriteAttributeString('x', $x)
                    $Script:XmlWriter.WriteAttributeString('y', $y)
                    $Script:XmlWriter.WriteAttributeString('width', $w)
                    $Script:XmlWriter.WriteAttributeString('height', $h)
                    $Script:XmlWriter.WriteAttributeString('as', "geometry")
                    $Script:XmlWriter.WriteEndElement()
                
                $Script:XmlWriter.WriteEndElement()
            }

        function Set-Variable {
        
        $Script:Ret = "rounded=0;whiteSpace=wrap;fontSize=16;html=1;sketch=0;fontFamily=Helvetica;"
        $Script:RetRound = "rounded=1;whiteSpace=wrap;fontSize=16;html=1;sketch=0;fontFamily=Helvetica;"

        ############# Azure AI
        $Script:AzureBotServices = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/ai_machine_learning/Bot_Services.svg;'
        $Script:AzureMachineLearning = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/ai_machine_learning/Machine_Learning.svg;'
        $Script:AzureCognitive = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/ai_machine_learning/Cognitive_Services.svg;' 
        
        ############# Azure Analytics
        $Script:AzureDatabricks = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/analytics/Azure_Databricks.svg;'
        $Script:AzureAnalysis = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/analytics/Analysis_Services.svg;'
        $Script:AzureSynapses = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/analytics/Azure_Synapse_Analytics.svg;'
        
        ############# Azure App Service
        $Script:IconAPPs = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/containers/App_Services.svg;" #width="64" height="64"
        $Script:AppSvcPlan = 'image;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/app_services/App_Service_Plans.svg;' #width="43.5" height="43.5"
        $Script:AzureAppDomain = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/app_services/App_Service_Domains.svg;' 
        
        
        ############# Azure VMware
        $Script:AzureAVSPrivateCloud = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/azure_vmware_solution/AVS.svg;' 
        
        
        ############# Azure Compute
        $Script:SvcFabric = 'image;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/compute/Service_Fabric_Clusters.svg;' #width="49.47" height="47.25"
        $Script:IconVMSS = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/compute/VM_Scale_Sets.svg;" # width="68" height="68"
        $Script:Disks = 'image;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/compute/Disks.svg;' #width="40.72" height="40"
        $Script:RestorePoint = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/compute/Restore_Points_Collections.svg;'
        $Script:AzureCloudSvc = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/compute/Cloud_Services_Classic.svg;'
        $Script:AvSet = 'image;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/compute/Availability_Sets.svg;' #width="43.5" height="43.5"
        $Script:AzureVMImage = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/compute/Images.svg;'
        $Script:AzureAVDWorkspace = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/compute/Workspaces.svg;'
        $Script:IconVMs = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/compute/Virtual_Machine.svg;" #width="69" height="64"
        
        ############ Azure Container
        $Script:IconAKS = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/containers/Kubernetes_Services.svg;" #width="68" height="60"
        $Script:ContRegis = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/containers/Container_Registries.svg;'
        $Script:AzureContainerInstances = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/containers/Container_Instances.svg;'
        $Script:AzureContainerApp = "image;aspect=fixed;html=1;points=[];align=center;fontSize=12;image=img/lib/azure2/other/Worker_Container_App.svg;"
        $Script:AzureContainerAppEnv = "image;aspect=fixed;html=1;points=[];align=center;fontSize=12;image=img/lib/azure2/other/Container_App_Environments.svg;"
        
        ############ Azure Database
        $Script:AzureSQLDB = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/databases/SQL_Database.svg;'
        $Script:AzureSQLDBServer = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/databases/SQL_Server.svg;'
        $Script:AzureDataExplorer = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/databases/Azure_Data_Explorer_Clusters.svg;'
        $Script:AzureDBforPostgre = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/databases/Azure_Database_PostgreSQL_Server.svg;'
        $Script:AzureDBforPostgreFlex = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/databases/Azure_Database_PostgreSQL_Server_Group.svg;'
        $Script:AzureRedisCa = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/databases/Cache_Redis.svg;'
        $Script:AzureDataFactory = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/devops/Azure_DevOps.svg;'
        $Script:AzureCosmos = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/databases/Azure_Cosmos_DB.svg;'
        $Script:AzureElastic = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/databases/SQL_Elastic_Pools.svg;'
        $Script:AzureElasticJobAgent = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/databases/Elastic_Job_Agents.svg;'
        $Script:AzureDB4MySQL = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/databases/Azure_Database_MySQL_Server.svg;'
        $Script:AzureSQLManagedInstances = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/databases/SQL_Managed_Instance.svg;'
        $Script:AzureSQLManagedInstancesDB = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/databases/Managed_Database.svg;'
        $Script:AzureSQLVM = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/databases/Azure_SQL_VM.svg;'
        $Script:AzureSQLVirtualCluster = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/databases/Virtual_Clusters.svg;'
        $Script:AzureDBMigration = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/databases/Azure_Database_Migration_Services.svg;'
        $Script:AzurePurviewAcc = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/databases/Azure_Purview_Accounts.svg;' 
        $Script:AzureMariaDB = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/databases/Azure_Database_MariaDB_Server.svg;' 
        
        ############ Azure DevOps
        $Script:Insight = 'image;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/devops/Application_Insights.svg;' #width="44" height="63"
        $Script:AzureDevOpsOrg = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/devops/Azure_DevOps.svg;'
        
        ############ Azure General
        $Script:AzureError = 'image;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/general/Error.svg;' #width="50.12" height="48"
        $Script:AzureWebSlot = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/general/Web_Slots.svg;'
        $Script:AzureWorkbooks = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/general/Workbooks.svg;'
        $Script:AzureWebTest = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/general/Web_Test.svg;'
        $Script:IconSubscription = "aspect=fixed;html=1;points=[];align=center;image;fontSize=20;image=img/lib/azure2/general/Subscriptions.svg;" #width="44" height="71"
        $Script:IconRG = "image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=12;image=img/lib/mscae/ResourceGroup.svg;" # width="37.5" height="30"
        
        ############ Azure Identity
        $Script:AzureB2C = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/identity/Azure_AD_B2C.svg;'
        
        ########### Azure Integration
        $Script:SvcBus = 'image;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/integration/Service_Bus.svg;' #width="45.05" height="39.75"
        $Script:AzureAPIConnections = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/integration/Logic_Apps_Custom_Connector.svg;'
        $Script:AzureLogicApp = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/integration/Logic_Apps.svg;'
        $Script:AzureDataCatalog = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/integration/Azure_Data_Catalog.svg;'
        $Script:AzureEventGridSymtopics = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/integration/System_Topic.svg;'
        $Script:AzureAppConfiguration = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/integration/App_Configuration.svg;'
        $Script:AzureIntegrationAcc = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/integration/Integration_Accounts.svg;'  
        $Script:AzureEvtGridTopics = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/integration/Event_Grid_Topics.svg;'  
        $Script:AzureAPIMangement = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/integration/API_Management_Services.svg;'
        $Script:AzureEvtGridDomain = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/integration/Event_Grid_Subscriptions.svg;'  
        
        ########### Azure IoT
        $Script:AzureEvtHubs = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/iot/Event_Hubs.svg;'
        $Script:AzureIoTHubs = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/iot/Event_Hubs.svg;' 
        
        ########### Azure Management Governance
        $Script:RecoveryVault = 'image;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/management_governance/Recovery_Services_Vaults.svg;' #width="43.7" height="38"
        $Script:AutAcc = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/management_governance/Automation_Accounts.svg;'
        $Script:AzureArcServer = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/management_governance/MachinesAzureArc.svg;' 
        
        
        ########### Azure Migrate
        $Script:AzureMigration = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/migrate/Azure_Migrate.svg;' 
        
        
        ########### Azure Networking
        $Script:AzureConnections = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/networking/Connections.svg;" #width="68" height="68"
        $Script:AzureExpressRoute = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/networking/ExpressRoute_Circuits.svg;" #width="70" height="64"
        $Script:AzureVGW = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/networking/Virtual_Network_Gateways.svg;" #width="52" height="69"
        $Script:AzureVNET = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/networking/Virtual_Networks.svg;" #width="67" height="40"
        $Script:AzurePIP = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/networking/Public_IP_Addresses.svg;" # width="65" height="52"
        $Script:Azureproximityplacementgroups = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/networking/Proximity_Placement_Groups.svg;'
        $Script:AzureUDRs = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/networking/Route_Tables.svg;'
        $Script:AzureRouteFilters = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/networking/Route_Filters.svg;'
        $Script:AzureBastionHost = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/networking/Bastions.svg;'
        $Script:IconLBs = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/networking/Load_Balancers.svg;" #width="72" height="72"
        $Script:NetWatcher = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/networking/Network_Watcher.svg;'
        $Script:AzurePvtLinks = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/networking/Private_Link_Service.svg;'
        $Script:AzureIPGroups = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/networking/IP_Groups.svg;'
        $Script:AzureFW = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/networking/Firewalls.svg;'
        $Script:AzureLNG = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/networking/Local_Network_Gateways.svg;'
        $Script:AzureFrontDoor = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/networking/Front_Doors.svg;'
        $Script:AzurePIPPrefixes = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/networking/Public_IP_Prefixes.svg;'
        $Script:AzureNATGateways = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/networking/NAT.svg;'
        $Script:AzureCDN = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/networking/CDN_Profiles.svg;'
        $Script:AzureNSG = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/networking/Network_Security_Groups.svg;'
        $Script:AzureSvcEndpointPol = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/networking/Service_Endpoint_Policies.svg;'  
        $Script:AzureVMNIC = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/networking/Network_Interfaces.svg;'   
        $Script:AzureWAFPolicies = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/networking/Web_Application_Firewall_Policies_WAF.svg;'  
        $Script:AzureDNSZone = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/networking/DNS_Zones.svg;'
        $Script:AzureAppGateway = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/networking/Application_Gateways.svg;' 
        $Script:AzureDDOS = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/networking/DDoS_Protection_Plans.svg;' 
        $Script:AzureTrafficManager = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/networking/Traffic_Manager_Profiles.svg;' 
        $Script:AzurePvtLink = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/networking/Private_Link.svg;' 
        $Script:IconPVTs = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/networking/Private_Endpoint.svg;" #width="72" height="66"
        $Script:IconLBs = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/networking/Load_Balancers.svg;" #width="72" height="72"
        
        ########### Azure Other
        $Script:Dashboard = 'image;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/other/Dashboard_Hub.svg;' #width="50.02" height="38.25"
        $Script:TemplSpec = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/other/Template_Specs.svg;'
        $Script:AzureBackupVault = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/other/Azure_Backup_Center.svg;'
        $Script:AzureERDirect = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/other/ExpressRoute_Direct.svg;'
        $Script:AzureAVDSessionHost = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/other/AVS_VM.svg;'
        $Script:AzureAVDHostPool = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/other/Windows_Virtual_Desktop.svg;'
        $Script:AzureGrafana = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/other/Grafana.svg;' 
        $Script:AzureNetworkManager = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/other/Azure_Network_Manager.svg;' 
        
        
        ########### Azure Security
        $Script:KeyVault = 'image;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/security/Key_Vaults.svg;' #width="49.5" height="49.5"
        $Script:AzureAppSecGroup = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/security/Application_Security_Groups.svg;'
        $Script:AzureDefender = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/security/Azure_Defender.svg;' 
        
        
        ########### Azure Storage
        $Script:StorageAcc = 'image;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/storage/Storage_Accounts.svg;' #width="43.75" height="35"
        $Script:AzureNetApp = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/storage/Azure_NetApp_Files.svg;'
        $Script:AzureDatalakeGen1 = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/storage/Data_Lake_Storage_Gen1.svg;' 
        
        
        ########### Azure Web
        $Script:AzureMediaServices = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/web/Azure_Media_Service.svg;' 
        
        ########### MSCAE
        $Script:Certificate = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/mscae/Certificate.svg;' #width="50" height="42"
        $Script:LogAnalytics = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/mscae/Log_Analytics_Workspaces.svg;' #width="40" height="40"
        $Script:PvtDNS = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/mscae/DNS_Private_Zones.svg;' #width="50" height="50"
        $Script:AzureSaaS = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/mscae/Software_as_a_Service.svg;'
        $Script:AzureRelay = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/mscae/Service_Bus_Relay.svg;'
        $Script:AzureLogAlertRule = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/mscae/Notification.svg;'
        $Script:AzureSignalR = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/mscae/SignalR.svg;' 
        
        
        }

        function Add-ResourceType {
            Param($TempResourceType,$TempResLeft,$TempResTop) 
        
                switch ($TempResourceType.Name)
                    {
                        <########## AZURE AI  ############>
        
                        'microsoft.botservice/botservices'   
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Bot' + "`n" + 'Services'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureBotServices $TempResLeft $TempResTop "40" "40" 1

                                $Script:XmlWriter.WriteEndElement()  
                            }      
                        'microsoft.machinelearningservices/workspaces'   
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Machine' + "`n" + 'Learning'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureMachineLearning $TempResLeft $TempResTop "40" "43" 1

                                $Script:XmlWriter.WriteEndElement()  
                            }     
                        'microsoft.cognitiveservices/accounts'   
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Cognitive' + "`n" + 'Services'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureCognitive $TempResLeft $TempResTop "58" "38" 1

                                $Script:XmlWriter.WriteEndElement()  
                            }                                 

                        <########## AZURE ANALYTICS  ############>

                        'microsoft.databricks/workspaces'   
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Databricks'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureDatabricks $TempResLeft $TempResTop "48" "52" 1

                                $Script:XmlWriter.WriteEndElement()  
                            } 
                        'microsoft.analysisservices/servers'   
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Analysis' + "`n" + 'Services'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureAnalysis $TempResLeft $TempResTop "53" "41" 1

                                $Script:XmlWriter.WriteEndElement()  
                            } 
                        'microsoft.synapse/workspaces'   
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Synapse' + "`n" + 'Analytics'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureSynapses $TempResLeft $TempResTop "45" "54" 1

                                $Script:XmlWriter.WriteEndElement()  
                            }                     

                        <########## AZURE APP  ############>

                        'microsoft.web/sites'   
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Web App'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $IconAPPs $TempResLeft $TempResTop "45" "45" 1

                                $Script:XmlWriter.WriteEndElement()  
                            } 
                        'microsoft.web/serverfarms'   
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' App' + "`n" + 'Service Plan'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AppSvcPlan $TempResLeft $TempResTop "43.5" "43.5" 1

                                $Script:XmlWriter.WriteEndElement()  
                            }
                        'microsoft.domainregistration/domains'   
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' App Service' + "`n" + 'Domain'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureAppDomain $TempResLeft $TempResTop "50" "38" 1

                                $Script:XmlWriter.WriteEndElement()  
                            }                    

                        <########## AZURE VMWARE ############>

                        'microsoft.avs/privateclouds'   
                        {
                            $Script:XmlWriter.WriteStartElement('object')            
                            $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' VMware' + "`n" + 'Private Cloud'))
                            $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                Add-Icon $AzureAVSPrivateCloud $TempResLeft $TempResTop "60" "46" 1

                            $Script:XmlWriter.WriteEndElement()  
                        }                

                        <########## AZURE COMPUTE ############>

                        'microsoft.desktopvirtualization/workspaces'   
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' AVD' + "`n" + 'Workspaces'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureAVDWorkspace $TempResLeft $TempResTop "48" "42" 1

                                $Script:XmlWriter.WriteEndElement()  
                            }
                        'microsoft.compute/virtualmachinescalesets'   
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' VMSS'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $IconVMSS $TempResLeft $TempResTop "45" "45" 1

                                $Script:XmlWriter.WriteEndElement()  
                            }
                        'microsoft.servicefabric/clusters'   
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Service' + "`n" + 'Fabric'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $SvcFabric $TempResLeft $TempResTop "49.4" "47.2" 1

                                $Script:XmlWriter.WriteEndElement()  
                            }
                        'microsoft.compute/disks'   
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Disk'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $Disks  $TempResLeft $TempResTop "40.72" "40" 1

                                $Script:XmlWriter.WriteEndElement()
                            }
                        'microsoft.compute/virtualmachines'   
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Virtual' + "`n" + 'Machine'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $IconVMs  $TempResLeft $TempResTop "43" "40" 1

                                $Script:XmlWriter.WriteEndElement()
                            }
                        'microsoft.compute/availabilitysets'   
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Availability' + "`n" + 'Set'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AvSet  $TempResLeft $TempResTop "43.5" "43.5" 1

                                $Script:XmlWriter.WriteEndElement()
                            }
                        'microsoft.compute/restorepointcollections'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Restore' + "`n" + 'Point Collection'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $RestorePoint  $TempResLeft $TempResTop "50" "40" 1

                                $Script:XmlWriter.WriteEndElement()
                            } 
                        'microsoft.classiccompute/domainnames'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Cloud' + "`n" + 'Services'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureCloudSvc  $TempResLeft $TempResTop "51" "37" 1

                                $Script:XmlWriter.WriteEndElement()
                            }
                        'microsoft.compute/images'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Images'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureVMImage  $TempResLeft $TempResTop "47" "44" 1

                                $Script:XmlWriter.WriteEndElement()
                            }

                        <########## AZURE CONTAINERS ############>

                        'microsoft.containerservice/managedclusters'   
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' AKS'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $IconAKS $TempResLeft $TempResTop "51" "45" 1

                                $Script:XmlWriter.WriteEndElement()  
                            }
                        'microsoft.containerregistry/registries'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Container' + "`n" + 'Registry'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $ContRegis  $TempResLeft $TempResTop "45" "40" 1

                                $Script:XmlWriter.WriteEndElement()
                            }
                        'microsoft.kubernetes/connectedclusters'   
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Kubernetes' + "`n" + 'Azure Arc'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $IconAKS $TempResLeft $TempResTop "51" "45" 1

                                $Script:XmlWriter.WriteEndElement()  
                            }
                        'microsoft.containerinstance/containergroups'   
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Container' + "`n" + 'Instances'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureContainerInstances $TempResLeft $TempResTop "46" "50" 1

                                $Script:XmlWriter.WriteEndElement()  
                            }
                        'microsoft.app/containerapps'   # Container App
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Container' + "`n" + 'Instances'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureContainerApp $TempResLeft $TempResTop "46" "50" 1

                                $Script:XmlWriter.WriteEndElement()  
                            }
                        'microsoft.app/managedenvironments'   # COntainer App Environment
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Container' + "`n" + 'Instances'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureContainerAppEnv $TempResLeft $TempResTop "46" "50" 1

                                $Script:XmlWriter.WriteEndElement()  
                            }
                        <########## AZURE DATABASES ############>

                        'microsoft.sql/servers/databases'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' SQL' + "`n" + 'Database'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureSQLDB  $TempResLeft $TempResTop "36" "49" 1

                                $Script:XmlWriter.WriteEndElement()
                            }  
                        'microsoft.sql/servers'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' SQL' + "`n" + 'Server'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureSQLDBServer  $TempResLeft $TempResTop "49" "49" 1

                                $Script:XmlWriter.WriteEndElement()
                            }  
                        'microsoft.kusto/clusters'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Data' + "`n" + 'Explorer Cluster'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureDataExplorer  $TempResLeft $TempResTop "41" "41" 1

                                $Script:XmlWriter.WriteEndElement()
                            }                      
                        'microsoft.dbforpostgresql/servers'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Database' + "`n" + 'PostgreSQL'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureDBforPostgre  $TempResLeft $TempResTop "38" "43" 1

                                $Script:XmlWriter.WriteEndElement()
                            }  
                        'microsoft.dbforpostgresql/flexibleservers'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' PostgreSQL' + "`n" + 'Flexible Server'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureDBforPostgreFlex  $TempResLeft $TempResTop "37.94" "43" 1

                                $Script:XmlWriter.WriteEndElement()
                            } 
                        'microsoft.cache/redis'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Redis' + "`n" + 'Cache'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureRedisCa  $TempResLeft $TempResTop "55" "45" 1

                                $Script:XmlWriter.WriteEndElement()
                            } 
                        'microsoft.datafactory/factories'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Data' + "`n" + 'Factory'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureDataFactory  $TempResLeft $TempResTop "44" "44" 1

                                $Script:XmlWriter.WriteEndElement()
                            }    
                        'microsoft.documentdb/databaseaccounts'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Cosmos' + "`n" + 'Database'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureCosmos  $TempResLeft $TempResTop "51" "51" 1

                                $Script:XmlWriter.WriteEndElement()
                            }         
                        'microsoft.sql/servers/elasticpools'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' SQL' + "`n" + 'Elastic Pool'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureElastic  $TempResLeft $TempResTop "51" "51" 1

                                $Script:XmlWriter.WriteEndElement()
                            }      
                        'microsoft.sql/servers/jobagents'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Elastic' + "`n" + 'Job Agent'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureElasticJobAgent  $TempResLeft $TempResTop "50" "50" 1

                                $Script:XmlWriter.WriteEndElement()
                            }          
                        'microsoft.dbformysql/servers'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' MySQL' + "`n" + 'Database Server'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureDB4MySQL  $TempResLeft $TempResTop "35" "46" 1

                                $Script:XmlWriter.WriteEndElement()
                            }      
                        'microsoft.dbformysql/flexibleservers'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' MySQL' + "`n" + 'Flexible Server'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureDB4MySQL  $TempResLeft $TempResTop "35" "46" 1

                                $Script:XmlWriter.WriteEndElement()
                            } 
                        'microsoft.sql/managedinstances/databases'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Managed Instances' + "`n" + 'Database'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureSQLManagedInstancesDB  $TempResLeft $TempResTop "51" "47" 1

                                $Script:XmlWriter.WriteEndElement()
                            }                                              
                        'microsoft.sql/managedinstances'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' SQL' + "`n" + 'Managed Instances'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureSQLManagedInstances  $TempResLeft $TempResTop "50" "49" 1

                                $Script:XmlWriter.WriteEndElement()
                            }     
                        'microsoft.sqlvirtualmachine/sqlvirtualmachines'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' SQL' + "`n" + 'Virtual Machine'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureSQLVM  $TempResLeft $TempResTop "50" "46" 1

                                $Script:XmlWriter.WriteEndElement()
                            }                     
                        'microsoft.sql/virtualclusters'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' SQL' + "`n" + 'Virtual Cluster'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureSQLVirtualCluster  $TempResLeft $TempResTop "50" "48" 1

                                $Script:XmlWriter.WriteEndElement()
                            }        
                        'microsoft.datamigration/sqlmigrationservices'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Database' + "`n" + 'Migration Service'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureDBMigration  $TempResLeft $TempResTop "46" "50" 1

                                $Script:XmlWriter.WriteEndElement()
                            }      
                        'microsoft.datamigration/services'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Database' + "`n" + 'Migration Service'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureDBMigration  $TempResLeft $TempResTop "46" "50" 1

                                $Script:XmlWriter.WriteEndElement()
                            }  
                        'microsoft.datamigration/services/projects'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Database' + "`n" + 'Migration Project'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureDBMigration  $TempResLeft $TempResTop "46" "50" 1

                                $Script:XmlWriter.WriteEndElement()
                            }  
                        'microsoft.purview/accounts'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Purview' + "`n" + 'Account'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzurePurviewAcc  $TempResLeft $TempResTop "58" "32" 1

                                $Script:XmlWriter.WriteEndElement()
                            }     
                        'microsoft.dbformariadb/servers'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' MariaDB' + "`n" + 'Server'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureMariaDB  $TempResLeft $TempResTop "34" "50" 1

                                $Script:XmlWriter.WriteEndElement()
                            }                                                              

                        <########## AZURE DEVOPS ############>

                        'microsoft.insights/metricalerts'
                            {
                                $Script:XmlWriter.WriteStartElement('object') 
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Insight' + "`n" + 'Metrics'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $Insight $TempResLeft $TempResTop "33" "42" 1

                                $Script:XmlWriter.WriteEndElement()
                            }
                        'microsoft.insights/components'   
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' App' + "`n" + 'Insights'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $Insight $TempResLeft $TempResTop "50" "42" 1

                                $Script:XmlWriter.WriteEndElement()  
                            }
                        'microsoft.visualstudio/account'   
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' DevOps' + "`n" + 'Organization'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureDevOpsOrg $TempResLeft $TempResTop "41" "41" 1

                                $Script:XmlWriter.WriteEndElement()  
                            }                    

                        <########## AZURE GENERAL ############>

                        'microsoft.web/sites/slots'   
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Web' + "`n" + 'Slots'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureWebSlot $TempResLeft $TempResTop "44" "49" 1

                                $Script:XmlWriter.WriteEndElement()  
                            }
                        'microsoft.insights/workbooks'   
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Workbooks'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureWorkbooks $TempResLeft $TempResTop "39" "43" 1

                                $Script:XmlWriter.WriteEndElement()  
                            }
                        'microsoft.insights/webtests'   
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Web' + "`n" + 'Test'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureWebTest $TempResLeft $TempResTop "50" "50" 1

                                $Script:XmlWriter.WriteEndElement()  
                            }

                        <########## AZURE IDENTITY ############>

                        'microsoft.azureactivedirectory/b2cdirectories'   
                        {
                            $Script:XmlWriter.WriteStartElement('object')            
                            $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' B2C' + "`n" + 'Directories'))
                            $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                Add-Icon $AzureB2C $TempResLeft $TempResTop "49" "45" 1

                            $Script:XmlWriter.WriteEndElement()  
                        }

                        <########## AZURE INTEGRATION ############>

                        'microsoft.servicebus/namespaces'   
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Service' + "`n" + 'Bus'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $SvcBus $TempResLeft $TempResTop "45.05" "39.75" 1

                                $Script:XmlWriter.WriteEndElement()
                            }
                        'microsoft.web/connections'   
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' API' + "`n" + 'Connections'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureAPIConnections $TempResLeft $TempResTop "43" "43" 1

                                $Script:XmlWriter.WriteEndElement()
                            }
                        'microsoft.logic/workflows'   
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Logic' + "`n" + 'Apps'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureLogicApp $TempResLeft $TempResTop "57" "44" 1

                                $Script:XmlWriter.WriteEndElement()
                            }
                        'microsoft.datacatalog/catalogs'   
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Data' + "`n" + 'Catalog'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureDataCatalog $TempResLeft $TempResTop "46" "52" 1

                                $Script:XmlWriter.WriteEndElement()
                            }             
                        'microsoft.web/customapis'   
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Logic App' + "`n" + 'Custom Connector'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureAPIConnections $TempResLeft $TempResTop "43" "43" 1

                                $Script:XmlWriter.WriteEndElement()
                            }   
                        'microsoft.eventgrid/systemtopics'   
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Event Grid' + "`n" + 'System Topics'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureEventGridSymtopics $TempResLeft $TempResTop "44" "40" 1

                                $Script:XmlWriter.WriteEndElement()
                            }   
                        'microsoft.appconfiguration/configurationstores'   
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' App' + "`n" + 'Configuration'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureAppConfiguration $TempResLeft $TempResTop "46" "50" 1

                                $Script:XmlWriter.WriteEndElement()
                            }           
                        'microsoft.logic/integrationaccounts'   
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Integration' + "`n" + 'Accounts'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureIntegrationAcc $TempResLeft $TempResTop "50" "50" 1

                                $Script:XmlWriter.WriteEndElement()
                            }      
                        'microsoft.eventgrid/topics'   
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Event Grid' + "`n" + 'Topics'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureEvtGridTopics $TempResLeft $TempResTop "44" "40" 1

                                $Script:XmlWriter.WriteEndElement()
                            }     
                        'microsoft.apimanagement/service'   
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' API' + "`n" + 'Management'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureAPIMangement $TempResLeft $TempResTop "50" "45" 1

                                $Script:XmlWriter.WriteEndElement()
                            }     
                        'microsoft.eventgrid/domains'   
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Event Grid' + "`n" + 'Domain'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureEvtGridDomain $TempResLeft $TempResTop "50" "43" 1

                                $Script:XmlWriter.WriteEndElement()
                            }                                                                              

                        <########## AZURE IOT ############>

                        'microsoft.eventhub/namespaces'   
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Event' + "`n" + 'Hubs'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureEvtHubs $TempResLeft $TempResTop "50" "45" 1

                                $Script:XmlWriter.WriteEndElement()
                            }
                        'microsoft.devices/iothubs'   
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' IoT' + "`n" + 'Hubs'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureIoTHubs $TempResLeft $TempResTop "50" "43" 1

                                $Script:XmlWriter.WriteEndElement()
                            }

                        <########## AZURE MANAGEMENT GOVERNANCE ############>

                        'microsoft.recoveryservices/vaults'   
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Recovery' + "`n" + 'Services Vault'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $RecoveryVault  $TempResLeft $TempResTop "43.5" "38" 1

                                $Script:XmlWriter.WriteEndElement()
                            }
                        'microsoft.automation/automationaccounts'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Automation' + "`n" + 'Account'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AutAcc  $TempResLeft $TempResTop "40" "40" 1

                                $Script:XmlWriter.WriteEndElement()
                            } 
                        'Microsoft.HybridCompute/machines'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Arc' + "`n" + 'Server'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureArcServer  $TempResLeft $TempResTop "30" "54" 1

                                $Script:XmlWriter.WriteEndElement()
                            } 

                        <########## AZURE MIGRATE ############>

                        'microsoft.migrate/projects'    
                        {
                            $Script:XmlWriter.WriteStartElement('object')            
                            $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Migration' + "`n" + 'Project'))
                            $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                Add-Icon $AzureMigration  $TempResLeft $TempResTop "62" "34" 1

                            $Script:XmlWriter.WriteEndElement()
                        } 
                        
                        <########## AZURE NETWORKING ############>

                        'microsoft.network/privateendpoints'   
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Private' + "`n" + 'Endpoint'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $IconPVTs $TempResLeft $TempResTop "44" "40" 1

                                $Script:XmlWriter.WriteEndElement()  
                            }
                        'microsoft.network/loadbalancers'   
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Load' + "`n" + 'Balancer'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $IconLBs $TempResLeft $TempResTop "41" "41" 1

                                $Script:XmlWriter.WriteEndElement()  
                            } 
                        'microsoft.network/publicipaddresses'   
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Public IPs'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzurePIP $TempResLeft $TempResTop "51" "42" 1

                                $Script:XmlWriter.WriteEndElement()  
                            }
                        'microsoft.network/virtualnetworks'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Virtual' + "`n" + 'Network'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureVNET  $TempResLeft $TempResTop "62" "42" 1

                                $Script:XmlWriter.WriteEndElement()
                            }  
                        'microsoft.network/networkwatchers'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Network' + "`n" + 'Watcher'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $NetWatcher  $TempResLeft $TempResTop "44" "44" 1

                                $Script:XmlWriter.WriteEndElement()
                            }  
                        'microsoft.network/virtualnetworkgateways'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' VPN' + "`n" + 'Gateway'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureVGW  $TempResLeft $TempResTop "36" "40" 1

                                $Script:XmlWriter.WriteEndElement()
                            } 
                        'microsoft.network/connections'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Connection'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureConnections  $TempResLeft $TempResTop "44" "44" 1

                                $Script:XmlWriter.WriteEndElement()
                            } 
                        'microsoft.network/expressroutecircuits'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Express' + "`n" + 'Route'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureExpressRoute  $TempResLeft $TempResTop "45" "40" 1

                                $Script:XmlWriter.WriteEndElement()
                            } 
                        'microsoft.network/networksecuritygroups'   
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Network' + "`n" + 'Security Group'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureNSG  $TempResLeft $TempResTop "37" "46" 1

                                $Script:XmlWriter.WriteEndElement()
                            }  
                        'microsoft.network/routetables'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' User Defined' + "`n" + 'Route Tables'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureUDRs  $TempResLeft $TempResTop "43" "42" 1

                                $Script:XmlWriter.WriteEndElement()
                            } 
                        'microsoft.network/routefilters'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Route' + "`n" + 'Filters'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureRouteFilters  $TempResLeft $TempResTop "54" "34" 1

                                $Script:XmlWriter.WriteEndElement()
                            } 
                        'microsoft.network/bastionhosts'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Bastion' + "`n" + 'Host'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureBastionHost  $TempResLeft $TempResTop "31" "37" 1

                                $Script:XmlWriter.WriteEndElement()
                            } 
                        'microsoft.compute/proximityplacementgroups'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Proximity' + "`n" + 'Placement Groups'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $Azureproximityplacementgroups  $TempResLeft $TempResTop "47" "45" 1

                                $Script:XmlWriter.WriteEndElement()
                            } 
                        'microsoft.network/privatelinkservices'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Private' + "`n" + 'Link Services'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzurePvtLinks  $TempResLeft $TempResTop "56" "33" 1

                                $Script:XmlWriter.WriteEndElement()
                            } 
                        'microsoft.network/ipgroups'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' IP' + "`n" + 'Groups'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureIPGroups  $TempResLeft $TempResTop "56" "33" 1

                                $Script:XmlWriter.WriteEndElement()
                            } 
                        'microsoft.network/azurefirewalls'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Firewall'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureFW  $TempResLeft $TempResTop "64" "42" 1

                                $Script:XmlWriter.WriteEndElement()
                            } 
                        'microsoft.network/localnetworkgateways'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Local' + "`n" + 'Network Gateway'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureLNG  $TempResLeft $TempResTop "50" "50" 1

                                $Script:XmlWriter.WriteEndElement()
                            } 
                        'microsoft.network/frontdoors'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Front Door'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureFrontDoor  $TempResLeft $TempResTop "50" "50" 1

                                $Script:XmlWriter.WriteEndElement()
                            }   
                        'microsoft.network/natgateways'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' NAT' + "`n" + 'Gateways'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureNATGateways  $TempResLeft $TempResTop "50" "50" 1

                                $Script:XmlWriter.WriteEndElement()
                            } 
                        'microsoft.network/publicipprefixes'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Public IP' + "`n" + 'Prefixes'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzurePIPPrefixes  $TempResLeft $TempResTop "51" "40" 1

                                $Script:XmlWriter.WriteEndElement()
                            } 
                        'microsoft.cdn/profiles'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' CDN' + "`n" + 'Profile'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureCDN  $TempResLeft $TempResTop "64" "36" 1

                                $Script:XmlWriter.WriteEndElement()
                            }          
                        'microsoft.network/serviceendpointpolicies'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Service' + "`n" + 'Endpoint Polices'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureSvcEndpointPol  $TempResLeft $TempResTop "48" "50" 1

                                $Script:XmlWriter.WriteEndElement()
                            }       
                        'microsoft.Network/networkInterfaces'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Network' + "`n" + 'Interface'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureVMNIC  $TempResLeft $TempResTop "50" "42" 1

                                $Script:XmlWriter.WriteEndElement()
                            }                                
                        'microsoft.network/frontdoorwebapplicationfirewallpolicies'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' WAF Policies' + "`n" + '(FrontDoor)'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureWAFPolicies  $TempResLeft $TempResTop "48" "48" 1

                                $Script:XmlWriter.WriteEndElement()
                            }      
                        'microsoft.cdn/cdnwebapplicationfirewallpolicies'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' WAF Policies' + "`n" + '(CDN)'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureWAFPolicies  $TempResLeft $TempResTop "48" "48" 1

                                $Script:XmlWriter.WriteEndElement()
                            }       
                        'microsoft.network/applicationgatewaywebapplicationfirewallpolicies'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' WAF Policies' + "`n" + '(App Gateway)'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureWAFPolicies  $TempResLeft $TempResTop "48" "48" 1

                                $Script:XmlWriter.WriteEndElement()
                            }                
                        'microsoft.network/dnszones'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' DNS' + "`n" + 'Zone'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureDNSZone  $TempResLeft $TempResTop "48" "48" 1

                                $Script:XmlWriter.WriteEndElement()
                            }     
                        'microsoft.network/applicationgateways'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Application' + "`n" + 'Gateway'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureAppGateway  $TempResLeft $TempResTop "50" "50" 1

                                $Script:XmlWriter.WriteEndElement()
                            }                    
                        'microsoft.network/ddosprotectionplans'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' DDOS' + "`n" + 'Protection'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureDDOS  $TempResLeft $TempResTop "38" "50" 1

                                $Script:XmlWriter.WriteEndElement()
                            }   
                        'microsoft.network/trafficmanagerprofiles'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Traffic Manager' + "`n" + 'Profiles'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureTrafficManager  $TempResLeft $TempResTop "50" "50" 1

                                $Script:XmlWriter.WriteEndElement()
                            }         
                        'microsoft.hybridcompute/privatelinkscopes'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Arc Private' + "`n" + 'Link Scope'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzurePvtLink  $TempResLeft $TempResTop "50" "44" 1

                                $Script:XmlWriter.WriteEndElement()
                            }    

                        <########## AZURE OTHER ############>

                        'microsoft.portal/dashboards'   
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Shared' + "`n" + 'Dashboard'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $Dashboard $TempResLeft $TempResTop "50.02" "38.25" 1

                                $Script:XmlWriter.WriteEndElement()
                            }
                        'microsoft.resources/templatespecs'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Template' + "`n" + 'Specs'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $TemplSpec  $TempResLeft $TempResTop "33" "39" 1

                                $Script:XmlWriter.WriteEndElement()
                            }  
                        'microsoft.dataprotection/backupvaults'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Backup' + "`n" + 'Services Vault'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureBackupVault  $TempResLeft $TempResTop "40" "36" 1

                                $Script:XmlWriter.WriteEndElement()
                            } 
                        'microsoft.network/expressrouteports'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' ExpressRoute' + "`n" + 'Direct'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureBackupVault  $TempResLeft $TempResTop "45" "40" 1

                                $Script:XmlWriter.WriteEndElement()
                            }     
                        'microsoft.desktopvirtualization/hostpools/sessionhosts'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' AVD' + "`n" + 'Session Host'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureAVDSessionHost  $TempResLeft $TempResTop "51" "51" 1

                                $Script:XmlWriter.WriteEndElement()
                            }       
                        'microsoft.desktopvirtualization/hostpools'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' AVD' + "`n" + 'Host Pool'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureAVDHostPool  $TempResLeft $TempResTop "51" "51" 1

                                $Script:XmlWriter.WriteEndElement()
                            }   
                        'microsoft.dashboard/grafana'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Grafana'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureGrafana  $TempResLeft $TempResTop "50" "48" 1

                                $Script:XmlWriter.WriteEndElement()
                            }             
                        'microsoft.network/networkmanagers'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Network' + "`n" + 'Manager'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureNetworkManager  $TempResLeft $TempResTop "46" "50" 1

                                $Script:XmlWriter.WriteEndElement()
                            }                                                          
        
                        <########## AZURE SECURITY ############>
        
                        'microsoft.keyvault/vaults'   
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Key' + "`n" + 'Vault'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $KeyVault $TempResLeft $TempResTop "40" "40" 1

                                $Script:XmlWriter.WriteEndElement()  
                            } 
                        'microsoft.network/applicationsecuritygroups'   
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Application' + "`n" + 'Security Group'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureAppSecGroup $TempResLeft $TempResTop "35" "43" 1

                                $Script:XmlWriter.WriteEndElement()  
                            } 
                        'microsoft.easm/workspaces'   
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Defender' + "`n" + 'EASM'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureDefender $TempResLeft $TempResTop "50" "38" 1

                                $Script:XmlWriter.WriteEndElement()  
                            }                     

                        <########## AZURE STORAGE ############>

                        'microsoft.storage/storageaccounts'   
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Storage' + "`n" + 'Account'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $StorageAcc $TempResLeft $TempResTop "49.94" "40" 1

                                $Script:XmlWriter.WriteEndElement()  
                            }
                        'microsoft.netapp/netappaccounts'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' NetApp' + "`n" + 'Account'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureNetApp  $TempResLeft $TempResTop "40" "32" 1

                                $Script:XmlWriter.WriteEndElement()
                            } 
                        'Microsoft.DataLakeStore/accounts'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Data Lake' + "`n" + 'Storage Gen1'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureDatalakeGen1  $TempResLeft $TempResTop "54" "42" 1

                                $Script:XmlWriter.WriteEndElement()
                            }                     

                        <########## AZURE WEB ############>

                        'microsoft.media/mediaservices'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Media' + "`n" + 'Services'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureMediaServices  $TempResLeft $TempResTop "50" "50" 1

                                $Script:XmlWriter.WriteEndElement()
                            }                     

                        <########## MSCAE ############>

                        'microsoft.web/certificates'   
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Certificate'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $Certificate $TempResLeft $TempResTop "50" "42" 1

                                $Script:XmlWriter.WriteEndElement()  
                            }
                        'microsoft.operationalinsights/workspaces'   
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Log' + "`n" + 'Analytics'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $LogAnalytics  $TempResLeft $TempResTop "40" "40" 1

                                $Script:XmlWriter.WriteEndElement()
                            }
                        'microsoft.network/privatednszones'   
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Private' + "`n" + 'DNS Zone'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $PvtDNS  $TempResLeft $TempResTop "40" "40" 1

                                $Script:XmlWriter.WriteEndElement()
                            }
                        'microsoft.saas/resources'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' SaaS' + "`n" + 'Resource'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureSaaS  $TempResLeft $TempResTop "50" "50" 1

                                $Script:XmlWriter.WriteEndElement()
                            }     
                        'microsoft.relay/namespaces'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Relay'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureRelay  $TempResLeft $TempResTop "50" "50" 1

                                $Script:XmlWriter.WriteEndElement()
                            }      
                        'microsoft.Insights/ActivityLogAlerts'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Activity Log' + "`n" + 'Alert Rule'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureLogAlertRule  $TempResLeft $TempResTop "48" "48" 1

                                $Script:XmlWriter.WriteEndElement()
                            }   
                        'Microsoft.AlertsManagement/smartDetectorAlertRules'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Smart Detector' + "`n" + 'Alert Rule'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureLogAlertRule  $TempResLeft $TempResTop "48" "48" 1

                                $Script:XmlWriter.WriteEndElement()
                            }        
                        'microsoft.insights/scheduledqueryrules'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Log Search' + "`n" + 'Alert Rule'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureLogAlertRule  $TempResLeft $TempResTop "48" "48" 1

                                $Script:XmlWriter.WriteEndElement()
                            }    
                        'Microsoft.SignalRService/SignalR'    
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' SignalR'))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureSignalR  $TempResLeft $TempResTop "48" "48" 1

                                $Script:XmlWriter.WriteEndElement()
                            }     
                            

                        default
                            {
                                $TempName = [string]$TempResourceType.Name
                                $TempName = $TempName.Replace('microsoft.','')
                                $TempName = $TempName.split('/')
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' ' + $TempName[0]+ "`n" + $TempName[1]))
                                #$Script:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Name))
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $AzureError $TempResLeft $TempResTop "50" "48" 1

                                $Script:XmlWriter.WriteEndElement()  
                            }
                    }
        }


        $Script:NonTypes = ('microsoft.compute/virtualmachines/extensions',
                            'microsoft.operationsmanagement/solutions',
                            'microsoft.network/privatednszones/virtualnetworklinks',
                            'microsoft.devtestlab/schedules',
                            'microsoft.managedidentity/userassignedidentities',
                            'microsoft.compute/virtualmachines/runcommands',
                            'microsoft.compute/sshpublickeys',
                            'microsoft.resources/templatespecs/versions',
                            'microsoft.containerregistry/registries/replications',
                            'microsoft.automation/automationaccounts/runbooks',
                            'microsoft.compute/snapshots',
                            'microsoft.insights/autoscalesettings',
                            'microsoft.insights/actiongroups',
                            'microsoft.network/networkwatchers/flowlogs',
                            'microsoft.compute/diskencryptionsets',
                            'microsoft.insights/datacollectionrules',
                            'microsoft.netapp/netappaccounts/capacitypools',
                            'microsoft.netapp/netappaccounts/capacitypools/volumes',
                            'microsoft.network/firewallpolicies',
                            'microsoft.web/connectiongateways',
                            'microsoft.security/automations',
                            'microsoft.datacatalog/catalogs',
                            'microsoft.hybridcompute/machines/extensions',
                            'microsoft.compute/galleries/images',
                            'microsoft.compute/galleries/images/versions',
                            'microsoft.desktopvirtualization/applicationgroups',
                            'microsoft.network/networkintentpolicies',
                            'microsoft.resourcegraph/queries',
                            'microsoft.cdn/profiles/endpoints',
                            'microsoft.network/networkwatchers/connectionmonitors',
                            'microsoft.compute/galleries',
                            'microsoft.synapse/workspaces/sqlpools',
                            'microsoft.containerregistry/registries/webhooks',
                            'microsoft.migrate/movecollections',
                            'microsoft.databricks/accessconnectors',
                            'microsoft.insights/datacollectionendpoints',
                            'microsoft.synapse/workspaces/bigdatapools',
                            'microsoft.media/mediaservices/streamingendpoints',
                            'microsoft.security/customentitystoreassignments',
                            'microsoft.security/securityconnectors',
                            'microsoft.security/customassessmentautomations',
                            'microsoft.datashare/accounts',
                            'microsoft.cdn/profiles/afdendpoints',
                            'microsoft.securitydevops/azuredevopsconnectors',
                            'microsoft.securitydevops/githubconnectors',
                            'microsoft.security/datascanners',
                            'microsoft.offazure/importsites',
                            'microsoft.offazure/vmwaresites',
                            'microsoft.migrate/migrateprojects',
                            'microsoft.migrate/assessmentprojects',
                            'microsoft.offazure/mastersites',
                            'microsoft.automation/automationaccounts/configurations',
                            'microsoft.alertsmanagement/actionrules',
                            'microsoft.resourceconnector/appliances',
                            'microsoft.automanage/configurationprofiles',
                            'microsoft.offazure/hypervsites',
                            'microsoft.machinelearningservices/registries',
                            'microsoft.machinelearningservices/workspaces/onlineendpoints/deployments',
                            'microsoft.machinelearningservices/workspaces/onlineendpoints',
                            'microsoft.serviceshub/connectors',
                            'microsoft.containerregistry/registries/tasks',
                            'microsoft.web/staticsites',
                            'microsoft.security/standards',
                            'microsoft.security/iotsecuritysolutions',
                            'microsoft.security/assignments',
                            'microsoft.connectedvmwarevsphere/virtualmachines',
                            'microsoft.connectedvmwarevsphere/vcenters',
                            'microsoft.extendedlocation/customlocations',
                            'microsoft.offazure/serversites',
                            'microsoft.signalrservice/webpubsub',
                            'microsoft.eventgrid/partnerconfigurations')

        $Subs = $Resources | group-object -Property subscriptionId | Sort-Object -Property Count -Descending

        $DDDFile = Join-Path $DiagramCache 'Subscriptions.xml'

        $XLeft = 100
        $XTop = 100
        $CelNum = 0

        $Script:etag = -join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})
        $Script:CellID = -join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})

        $Script:IDNum = 0

        Write-Output ('DrawIOSubsFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Creating XML File: ' + $DDDFile)

        $Script:XmlWriter = New-Object System.XMl.XmlTextWriter($DDDFile,$Null)

        $Script:XmlWriter.Formatting = 'Indented'
        $Script:XmlWriter.Indentation = 2

        $Script:XmlWriter.WriteStartDocument()

        $Script:XmlWriter.WriteStartElement('mxfile')
        $Script:XmlWriter.WriteAttributeString('host', 'Electron')
        $Script:XmlWriter.WriteAttributeString('modified', '2021-10-01T21:45:40.561Z')
        $Script:XmlWriter.WriteAttributeString('agent', '5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) draw.io/15.4.0 Chrome/91.0.4472.164 Electron/13.5.0 Safari/537.36')
        $Script:XmlWriter.WriteAttributeString('etag', $etag)
        $Script:XmlWriter.WriteAttributeString('version', '15.4.0')
        $Script:XmlWriter.WriteAttributeString('type', 'device')

        foreach($Sub in $Subs.Name)
            {
                $RGLeft = $XLeft + 40
                $RGTop = $XTop + 40
                $Resource = $Resources | Where-Object {$_.subscriptionId -eq $Sub}
                $SubName = $Subscriptions | Where-Object {$_.id -eq $Sub}
                $Resource0 = $Resource | Group-Object -Property resourceGroup | Sort-Object -Property Count -Descending   
                $SubName = $SubName.Name             

                $DiagID1 = -join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})    

                $Script:XmlWriter.WriteStartElement('diagram')
                $Script:XmlWriter.WriteAttributeString('id', $DiagID1)
                $Script:XmlWriter.WriteAttributeString('name', $SubName)

                    $Script:XmlWriter.WriteStartElement('mxGraphModel')
                    $Script:XmlWriter.WriteAttributeString('dx', "1326")
                    $Script:XmlWriter.WriteAttributeString('dy', "798")
                    $Script:XmlWriter.WriteAttributeString('grid', "1")
                    $Script:XmlWriter.WriteAttributeString('gridSize', "10")
                    $Script:XmlWriter.WriteAttributeString('guides', "1")
                    $Script:XmlWriter.WriteAttributeString('tooltips', "1")
                    $Script:XmlWriter.WriteAttributeString('connect', "1")
                    $Script:XmlWriter.WriteAttributeString('arrows', "1")
                    $Script:XmlWriter.WriteAttributeString('fold', "1")
                    $Script:XmlWriter.WriteAttributeString('page', "1")
                    $Script:XmlWriter.WriteAttributeString('pageScale', "1")
                    $Script:XmlWriter.WriteAttributeString('pageWidth', "850")
                    $Script:XmlWriter.WriteAttributeString('pageHeight', "1100")
                    $Script:XmlWriter.WriteAttributeString('math', "0")
                    $Script:XmlWriter.WriteAttributeString('shadow', "0")

                        $Script:XmlWriter.WriteStartElement('root')

                            $Script:XmlWriter.WriteStartElement('mxCell')
                            $Script:XmlWriter.WriteAttributeString('id', "0")
                            $Script:XmlWriter.WriteEndElement()

                            $Script:XmlWriter.WriteStartElement('mxCell')
                            $Script:XmlWriter.WriteAttributeString('id', "1")
                            $Script:XmlWriter.WriteAttributeString('parent', "0")
                            $Script:XmlWriter.WriteEndElement()

                                Set-Variable

                                $Script:CellIDRes = -join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})

                                $Witd = 2060

                                $Counter = 1
                                $ZCounter = 0
                                    foreach($RG in $Resource0.Name)
                                        {

                                            Write-Output ('DrawIOSubsFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Processing Resource Group: ' + $RG)

                                            $Res = $Resource | Where-Object {$_.resourceGroup -eq $RG -and $_.Type -notin $NonTypes}
                                            $Resource1 = $Res | Group-Object -Property type | Sort-Object -Property Count -Descending                        

                                            $RGHeigh = if($Resource1.name.count -le 8){1}else{[math]::ceiling($Resource1.name.count / 8)}

                                            if($Counter -eq 1)
                                                {
                                                    $RGLeft = $RGLeft + $RGWitdh + 40                                
                                                    $TempHeight1 = $RGTop + ($RGHeigh*120) + 40
                                                    if($ZCounter -eq 1)
                                                        {
                                                            $RGTop = $TempHeight2
                                                        }                                
                                                }
                                            else
                                                {
                                                    $RGLeft = $XLeft + 40
                                                    $TempHeight2 = $RGTop + ($RGHeigh*120) + 40
                                                    $RGTop = $TempHeight1
                                                    $ZCounter = 1
                                                }                                                

                                            if($Counter -eq 1){$Counter = 2}else{$Counter = 1}
                                        }

                                if($TempHeight1 -gt $TempHeight2){$RGTop = $TempHeight1}else{$RGTop = $TempHeight2}   

                                $SubHeight = $RGTop - $XTop

                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', '')
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellIDRes+'-'+($CelNum++)))

                                    Add-Icon $Ret $XLeft $XTop $Witd $SubHeight 1

                                $Script:XmlWriter.WriteEndElement()

                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', $SubName)
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    Add-Icon $IconSubscription 30 ($XTop+$SubHeight-20) "67" "40" 1

                                $Script:XmlWriter.WriteEndElement()  

                                $RGLeft = $XLeft + 40
                                $RGTop = $XTop + 40

                                $Counter = 1
                                $ZCounter = 0
                                    foreach($RG in $Resource0.Name)
                                        {
                                            $Res = $Resource | Where-Object {$_.resourceGroup -eq $RG -and $_.subscriptionId -eq $Sub -and $_.Type -notin $NonTypes}
                                            $Resource1 = $Res | Group-Object -Property type | Sort-Object -Property Count -Descending 

                                            $RGWitdh = 960
                                            $RGHeigh = if($Resource1.name.count -le 8){1}else{[math]::ceiling($Resource1.name.count / 8)}

                                            $Script:XmlWriter.WriteStartElement('object')
                                            $Script:XmlWriter.WriteAttributeString('label', '')
                                            $Script:XmlWriter.WriteAttributeString('id', ($Script:CellIDRes+'-'+($CelNum++)))

                                                Add-Icon $RetRound $RGLeft $RGTop $RGWitdh ($RGHeigh*120) 1

                                            $Script:XmlWriter.WriteEndElement()                        

                                            if($Counter -eq 1)
                                                {
                                                    $Script:XmlWriter.WriteStartElement('object')            
                                                    $Script:XmlWriter.WriteAttributeString('label', $RG)
                                                    $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                                        Add-Icon $IconRG ($XLeft+20) ($RGTop+($RGHeigh*120)-20) "37.5" "30" 1

                                                    $Script:XmlWriter.WriteEndElement()  

                                                    $ResTypeLeft = $RGLeft + 60
                                                    $ResTypeTop = $RGTop + 25
                                                    $YCounter = 1

                                                    foreach($res0 in $Resource1)
                                                        {
                                                            Add-ResourceType $res0 $ResTypeLeft $ResTypeTop
                                                            if($YCounter -ge 8)
                                                                {
                                                                    $ResTypeLeft = $RGLeft + 60
                                                                    $ResTypeTop = $ResTypeTop + 110
                                                                    $YCounter = 1
                                                                }
                                                            else
                                                                {
                                                                    $ResTypeLeft = $ResTypeLeft + 110
                                                                    $YCounter++ 
                                                                }

                                                        }
                                                    $RGLeft = $RGLeft + $RGWitdh + 40                                
                                                    $TempHeight1 = $RGTop + ($RGHeigh*120) + 40
                                                    if($ZCounter -eq 1)
                                                        {
                                                            $RGTop = $TempHeight2
                                                        }                                              
                                                }
                                            else
                                                {
                                                    $Script:XmlWriter.WriteStartElement('object')            
                                                    $Script:XmlWriter.WriteAttributeString('label', $RG)
                                                    $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                                        Add-Icon $IconRG ($RGLeft + $RGWitdh - 20) ($RGTop+($RGHeigh*120)-20) "37.5" "30" 1

                                                    $Script:XmlWriter.WriteEndElement()  

                                                    $ResTypeLeft = $RGLeft + 60
                                                    $ResTypeTop = $RGTop + 25
                                                    $YCounter = 1

                                                    foreach($res0 in $Resource1)
                                                        {
                                                            Add-ResourceType $res0 $ResTypeLeft $ResTypeTop
                                                            if($YCounter -ge 8)
                                                                {
                                                                    $ResTypeLeft = $RGLeft + 60
                                                                    $ResTypeTop = $ResTypeTop + 110
                                                                    $YCounter = 1
                                                                }
                                                            else
                                                                {
                                                                    $ResTypeLeft = $ResTypeLeft + 110
                                                                    $YCounter++ 
                                                                }

                                                        }

                                                    $RGLeft = $XLeft + 40
                                                    $TempHeight2 = $RGTop + ($RGHeigh*120) + 40
                                                    $RGTop = $TempHeight1
                                                    $ZCounter = 1
                                                }                                                

                                            if($Counter -eq 1){$Counter = 2}else{$Counter = 1}

                                        }

                                    if($TempHeight1 -gt $TempHeight2){$RGTop = $TempHeight1}else{$RGTop = $TempHeight2}                                    

                                $XTop = $RGTop + 200

                            $Script:XmlWriter.WriteEndElement()

                        $Script:XmlWriter.WriteEndElement()

                    $Script:XmlWriter.WriteEndElement()
            }

            $Script:XmlWriter.WriteEndDocument()
            $Script:XmlWriter.Flush()
            $Script:XmlWriter.Close()

            Write-Output ('DrawIOSubsFile - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - End of Subscription Function: ')

}
