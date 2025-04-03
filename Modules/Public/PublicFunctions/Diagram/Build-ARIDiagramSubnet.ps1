<#
.Synopsis
Subnet Module for Draw.io Diagram

.DESCRIPTION
This module is used for building subnet components in the Draw.io Diagram.

.Link
https://github.com/microsoft/ARI/Modules/Public/PublicFunctions/Diagram/Build-ARIDiagramSubnet.ps1

.COMPONENT
This PowerShell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.6.0
First Release Date: 15th Oct, 2024
Authors: Claudio Merola

#>

Function Build-ARIDiagramSubnet {
    Param($SubnetLocation,$VNET,$IDNum,$DiagramCache,$ContainerID,$Job,$LogFile)

    try
        {
        $etag = -join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})
        $DiagID = -join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})
        $CellID2 = -join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})
        $IDNum = 0

        $SubFileName = ($CellID2 + '.xml')

        $SubFile = Join-Path $DiagramCache $SubFileName

        Write-Output ('DrawIOSubnet: '+ $CellID2 + ' - ' +(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Processing Subnets for: " + $VNET.Name)

        Write-Output ('DrawIOSubnet: '+ $CellID2 + ' - ' +(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Adding Subnet File: " + $SubFile)

        ###################################################### STENCILS ####################################################

        Function Publish-ARIDiagramStensils {
            $Script:Ret = "rounded=0;whiteSpace=wrap;fontSize=16;html=1;sketch=0;fontFamily=Helvetica;"

            $Script:IconConnections = "aspect=fixed;html=1;points=[];align=center;image;fontSize=18;image=img/lib/azure2/networking/Connections.svg;" #width="68" height="68"
            $Script:IconExpressRoute = "aspect=fixed;html=1;points=[];align=center;image;fontSize=18;image=img/lib/azure2/networking/ExpressRoute_Circuits.svg;" #width="70" height="64"
            $Script:IconVGW = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/networking/Virtual_Network_Gateways.svg;" #width="52" height="69"
            $Script:IconVGW2 = "aspect=fixed;html=1;points=[];align=center;image;fontSize=18;image=img/lib/azure2/networking/Virtual_Network_Gateways.svg;" #width="52" height="69"
            $Script:IconVNET = "aspect=fixed;html=1;points=[];align=center;image;fontSize=18;image=img/lib/azure2/networking/Virtual_Networks.svg;" #width="67" height="40"
            $Script:IconTraffic = "aspect=fixed;html=1;points=[];align=center;image;fontSize=18;image=img/lib/azure2/networking/Local_Network_Gateways.svg;" #width="68" height="68"
            $Script:IconNIC = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/networking/Network_Interfaces.svg;" #width="68" height="60"
            $Script:IconLBs = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/networking/Load_Balancers.svg;" #width="72" height="72"
            $Script:IconPVTs = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/networking/Private_Endpoint.svg;" #width="72" height="66"
            $Script:IconNSG = "aspect=fixed;html=1;points=[];align=center;image;fontSize=12;image=img/lib/azure2/networking/Network_Security_Groups.svg;" # width="26.35" height="32"
            $Script:IconUDR =  "aspect=fixed;html=1;points=[];align=center;image;fontSize=12;image=img/lib/azure2/networking/Route_Tables.svg;" #width="30.97" height="30"
            $Script:IconDDOS = "aspect=fixed;html=1;points=[];align=center;image;fontSize=12;image=img/lib/azure2/networking/DDoS_Protection_Plans.svg;" # width="23" height="28"
            $Script:IconPIP = "aspect=fixed;html=1;points=[];align=center;image;fontSize=12;image=img/lib/azure2/networking/Public_IP_Addresses.svg;" # width="65" height="52"  
            $Script:IconNAT = "aspect=fixed;html=1;points=[];align=center;image;fontSize=18;image=img/lib/azure2/networking/NAT.svg;" # width="65" height="52"            
        
            <########################## Azure Generic Stencils #############################>
        
            $Script:SymError = "sketch=0;aspect=fixed;pointerEvents=1;shadow=0;dashed=0;html=1;strokeColor=none;labelPosition=center;verticalLabelPosition=bottom;verticalAlign=top;align=center;shape=mxgraph.mscae.enterprise.not_allowed;fillColor=#EA1C24;" #width="50" height="50"
            $Script:SymInfo = "aspect=fixed;html=1;points=[];align=center;image;fontSize=12;image=img/lib/azure2/general/Information.svg;" #width="64" height="64"
            $Script:IconSubscription = "aspect=fixed;html=1;points=[];align=center;image;fontSize=20;image=img/lib/azure2/general/Subscriptions.svg;" #width="44" height="71"
            $Script:IconRG = "image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=12;image=img/lib/mscae/ResourceGroup.svg;" # width="37.5" height="30"
            $Script:IconBastions = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/general/Launch_Portal.svg;" #width="68" height="67"
            $Script:IconContain = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/compute/Container_Instances.svg;" #width="64" height="68"
            $Script:IconVWAN = "aspect=fixed;html=1;points=[];align=center;image;fontSize=18;image=img/lib/azure2/networking/Virtual_WANs.svg;" #width="65" height="64"
            $Script:IconCostMGMT = "aspect=fixed;html=1;points=[];align=center;image;fontSize=12;image=img/lib/azure2/general/Cost_Analysis.svg;" #width="60" height="70"
        
            <########################## Azure Computing Stencils #############################>
        
            $Script:IconVMs = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/compute/Virtual_Machine.svg;" #width="69" height="64"
            $Script:IconAKS = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/containers/Kubernetes_Services.svg;" #width="68" height="60"
            $Script:IconVMSS = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/compute/VM_Scale_Sets.svg;" # width="68" height="68"
            $Script:IconARO = "sketch=0;aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/mscae/OpenShift.svg;" #width="50" height="46"
            $Script:IconFunApps = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/compute/Function_Apps.svg;" # width="68" height="60"
        
            <########################## Azure Service Stencils #############################>
        
            $Script:IconAPIMs = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/app_services/API_Management_Services.svg;" #width="65" height="60"
            $Script:IconAPPs = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/containers/App_Services.svg;" #width="64" height="64"                   
        
            <########################## Azure Storage Stencils #############################>
        
            $Script:IconNetApp = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/storage/Azure_NetApp_Files.svg;" #width="65" height="52"
        
            <########################## Azure Storage Stencils #############################>
        
            $Script:IconDataExplorer = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/databases/Azure_Data_Explorer_Clusters.svg;" #width="68" height="68"
        
            <########################## Other Stencils #############################>
            
            $Script:IconFWs = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/networking/Firewalls.svg;" #width="71" height="60"
            $Script:IconDet =  "aspect=fixed;html=1;points=[];align=center;image;fontSize=12;image=img/lib/azure2/other/Detonation.svg;" #width="42.63" height="44"
            $Script:IconAppGWs = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/networking/Application_Gateways.svg;" #width="64" height="64"
            $Script:IconBricks = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/analytics/Azure_Databricks.svg;" #width="60" height="68"   
            $Script:IconError = "sketch=0;aspect=fixed;pointerEvents=1;shadow=0;dashed=0;html=1;strokeColor=none;labelPosition=center;verticalLabelPosition=bottom;verticalAlign=top;align=center;shape=mxgraph.mscae.enterprise.not_allowed;fillColor=#EA1C24;" #width="30" height="30"
            $Script:OnPrem = "sketch=0;aspect=fixed;html=1;points=[];align=center;image;fontSize=56;image=img/lib/mscae/Exchange_On_premises_Access.svg;" #width="168.2" height="290"
            $Script:Signature = "aspect=fixed;html=1;points=[];align=left;image;fontSize=22;image=img/lib/azure2/general/Dev_Console.svg;" #width="27.5" height="22"
            $Script:CloudOnly = "aspect=fixed;html=1;points=[];align=center;image;fontSize=56;image=img/lib/azure2/compute/Cloud_Services_Classic.svg;" #width="380.77" height="275"
            $Script:IconPowerPlatform = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/analytics/Power_Platform.svg"
        
        }

        ####################################################### Subnet Components ####################################################

        Function Set-ARIDiagramSubnetComponent {
            Param($sub,$SubnetLocation,$Alt0,$ContainerID,$LogFile) 

                $CellID3 = -join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})
                remove-variable TrueTemp -ErrorAction SilentlyContinue
                remove-variable RESNames -ErrorAction SilentlyContinue

                Write-Output ('DrawIOSubnet: '+ $CellID2 + ' - ' +(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Calling Function to Identify Resource Types in the Subnet.")

                $TrueTemp = Get-ARIDiagramSubnetResourceType -sub $sub -LogFile $LogFile

                Write-Output ('DrawIOSubnet: '+ $CellID2 + ' - ' +(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - ProcType Identified as: " + $TrueTemp)

                <#################################################### FIND RESOURCE NAME AND DETAILS #################################################################>

                Write-Output ('DrawIOSubnet: '+ $CellID2 + ' - ' +(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Calling Function to Identify Resource Names in the Subnet.")

                $ResNames = Get-ARIDiagramSubnetResourcesName -sub $sub -TrueTemp $TrueTemp -LogFile $LogFile

                if ([string]::IsNullOrEmpty($ResNames))
                    {
                        $ResNames = @{
                            Name = 'Delegated Subnet'
                        }
                    }

                if ($ResNames.count -gt 1)
                    {
                        Write-Output ('DrawIOSubnet: '+ $CellID2 + ' - ' +(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Multiple Resources Found in the Subnet: " + $ResNames.count)
                    }
                else
                    {
                        Write-Output ('DrawIOSubnet: '+ $CellID2 + ' - ' +(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Single Resource Found in the Subnet: " + $ResNames.name)
                    }

                <###################################################### DROP THE ICONS ######################################################>

                switch ($TrueTemp)
                    {
                        'microsoft.compute/virtualmachines' {
                                            Write-Output ('DrawIOSubnet: '+ $CellID2 + ' - ' +(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Adding VM: " + $CellID3+'-1')
                                            if($RESNames.count -gt 1)
                                                {
                                                    $XmlTempWriter.WriteStartElement('object')            
                                                    $XmlTempWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' VMs'))                                        

                                                    $Count = 1
                                                    foreach ($VMName in $RESNames.Name)
                                                    {
                                                        $Attr1 = ('VirtualMachine-'+[string]("{0:d3}" -f $Count))
                                                        $XmlTempWriter.WriteAttributeString($Attr1, [string]$VMName)

                                                        $Count ++
                                                    }
                                                    $XmlTempWriter.WriteAttributeString('id', ($CellID3+'-1'))

                                                        New-ARIDiagramSubnetIcon $IconVMs ($SubnetLocation+64) ($Alt0+40) "69" "64" $ContainerID

                                                    $XmlTempWriter.WriteEndElement()  
                                                }
                                            else
                                                {

                                                    $XmlTempWriter.WriteStartElement('object')            
                                                    $XmlTempWriter.WriteAttributeString('label', [string]$RESNames.Name)
                                                    $XmlTempWriter.WriteAttributeString('VM_Size', [string]$RESNames.properties.hardwareProfile.vmSize)
                                                    $XmlTempWriter.WriteAttributeString('OS', [string]$RESNames.properties.storageProfile.osDisk.osType)
                                                    $XmlTempWriter.WriteAttributeString('OS_Disk_Size_GB', [string]$RESNames.properties.storageProfile.osDisk.diskSizeGB)
                                                    $XmlTempWriter.WriteAttributeString('Image_Publisher', [string]$RESNames.properties.storageProfile.imageReference.publisher)
                                                    $XmlTempWriter.WriteAttributeString('Image_SKU', [string]$RESNames.properties.storageProfile.imageReference.sku)
                                                    $XmlTempWriter.WriteAttributeString('id', ($CellID3+'-1'))                        

                                                        New-ARIDiagramSubnetIcon $IconVMs ($SubnetLocation+64) ($Alt0+40) "69" "64" $ContainerID

                                                    $XmlTempWriter.WriteEndElement() 

                                                }
                                            }
                        'microsoft.containerservice/managedclusters' {
                                            Write-Output ('DrawIOSubnet: '+ $CellID2 + ' - ' +(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Adding AKS: " + $CellID3+'-1')
                                            if($RESNames.count -gt 1)
                                                {
                                                    $XmlTempWriter.WriteStartElement('object')            
                                                    $XmlTempWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' AKS Clusters'))                                        

                                                    $Count = 1
                                                    foreach ($AKSName in $RESNames.Name)
                                                    {
                                                        $Attr1 = ('Kubernetes_Cluster-'+[string]("{0:d3}" -f $Count))
                                                        $XmlTempWriter.WriteAttributeString($Attr1, [string]$AKSName)

                                                        $Count ++
                                                    }
                                                    $XmlTempWriter.WriteAttributeString('id', ($CellID3+'-1'))

                                                        New-ARIDiagramSubnetIcon $IconAKS ($SubnetLocation+65) ($Alt0+40) "68" "64" $ContainerID

                                                    $XmlTempWriter.WriteEndElement()

                                                }
                                            else 
                                                {
                                                    $XmlTempWriter.WriteStartElement('object')            
                                                    $XmlTempWriter.WriteAttributeString('label', [string]$RESNames.name)                                        

                                                    $Count = 1
                                                    foreach($Pool in $RESNames.properties.agentPoolProfiles)
                                                    {
                                                        $Attr1 = ('Node_Pool-'+[string]("{0:d3}" -f $Count)+'-Name')
                                                        $Attr2 = ('Node_Pool-'+[string]("{0:d3}" -f $Count)+'-Count')
                                                        $Attr3 = ('Node_Pool-'+[string]("{0:d3}" -f $Count)+'-Size')
                                                        $Attr4 = ('Node_Pool-'+[string]("{0:d3}" -f $Count)+'-Version')
                                                        $Attr5 = ('Node_Pool-'+[string]("{0:d3}" -f $Count)+'-Mode')
                                                        $Attr6 = ('Node_Pool-'+[string]("{0:d3}" -f $Count)+'-Max_Pods')

                                                        $XmlTempWriter.WriteAttributeString($Attr1, [string]$Pool.name)
                                                        $XmlTempWriter.WriteAttributeString($Attr2, [string]($Pool | Select-Object -Property 'count').count)
                                                        $XmlTempWriter.WriteAttributeString($Attr3, [string]$Pool.vmSize)
                                                        $XmlTempWriter.WriteAttributeString($Attr4, [string]$Pool.orchestratorVersion)
                                                        $XmlTempWriter.WriteAttributeString($Attr5, [string]$Pool.mode)
                                                        $XmlTempWriter.WriteAttributeString($Attr6, [string]$Pool.maxPods)

                                                        $Count ++
                                                    }
                                                    $XmlTempWriter.WriteAttributeString('id', ($CellID3+'-1'))

                                                        New-ARIDiagramSubnetIcon $IconAKS ($SubnetLocation+65) ($Alt0+40) "68" "64" $ContainerID

                                                    $XmlTempWriter.WriteEndElement()

                                                    }
                                            }
                        'Microsoft.Compute/virtualMachineScaleSets' {
                                            Write-Output ('DrawIOSubnet: '+ $CellID2 + ' - ' +(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Adding VMSS: " + $CellID3+'-1')
                                            if($RESNames.count -gt 1)
                                                {
                                                    $XmlTempWriter.WriteStartElement('object')            
                                                    $XmlTempWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' Virtual Machine Scale Sets'))                                        

                                                    $Count = 1
                                                    foreach ($ResName in $RESNames.Name)
                                                    {
                                                        $Attr1 = ('VMSS-'+[string]("{0:d3}" -f $Count))
                                                        $XmlTempWriter.WriteAttributeString($Attr1, [string]$ResName)

                                                        $Count ++
                                                    }
                                                    $XmlTempWriter.WriteAttributeString('id', ($CellID3+'-1'))

                                                        New-ARIDiagramSubnetIcon $IconVMSS ($SubnetLocation+65) ($Alt0+40) "68" "68" $ContainerID

                                                    $XmlTempWriter.WriteEndElement()

                                                }
                                            else
                                                {
                                                    $XmlTempWriter.WriteStartElement('object')            
                                                    $XmlTempWriter.WriteAttributeString('label', [string]$RESNames.name)                                        

                                                    $XmlTempWriter.WriteAttributeString('VMSS_Name', [string]$RESNames.name)
                                                    $XmlTempWriter.WriteAttributeString('VMSS_SKU_Tier', [string]$RESNames.sku.tier)
                                                    $XmlTempWriter.WriteAttributeString('VMSS_Upgrade_Policy', [string]$RESNames.Properties.upgradePolicy.mode)

                                                    $XmlTempWriter.WriteAttributeString('id', ($CellID3+'-1'))

                                                        New-ARIDiagramSubnetIcon $IconVMSS ($SubnetLocation+65) ($Alt0+40) "68" "68" $ContainerID

                                                    $XmlTempWriter.WriteEndElement()
                                                }                                                                        
                                            } 
                        'microsoft.network/loadbalancers' {
                                            Write-Output ('DrawIOSubnet: '+ $CellID2 + ' - ' +(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Adding Load Balancer: " + $CellID3+'-1')
                                            if($RESNames.count -gt 1)
                                                {
                                                    $XmlTempWriter.WriteStartElement('object')            
                                                    $XmlTempWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' Load Balancers'))                                        

                                                    $Count = 1
                                                    foreach ($ResName in $RESNames)
                                                    {
                                                        $Attr1 = ('LB-'+[string]("{0:d3}" -f $Count)+'-Name')
                                                        $Attr2 = ('LB-'+[string]("{0:d3}" -f $Count)+'-SKU')
                                                        $Attr3 = ('LB-'+[string]("{0:d3}" -f $Count)+'-Backends')
                                                        $Attr4 = ('LB-'+[string]("{0:d3}" -f $Count)+'-Frontends')
                                                        $Attr5 = ('LB-'+[string]("{0:d3}" -f $Count)+'-LB_Rules')
                                                        $Attr6 = ('LB-'+[string]("{0:d3}" -f $Count)+'-Probes')

                                                        $XmlTempWriter.WriteAttributeString($Attr1, [string]$ResName.name)
                                                        $XmlTempWriter.WriteAttributeString($Attr2, [string]$ResName.sku.name)
                                                        $XmlTempWriter.WriteAttributeString($Attr3, [string]$ResName.properties.backendAddressPools.properties.backendIPConfigurations.id.count)
                                                        $XmlTempWriter.WriteAttributeString($Attr4, [string]$ResName.properties.frontendIPConfigurations.properties.count)
                                                        $XmlTempWriter.WriteAttributeString($Attr5, [string]$ResName.properties.loadBalancingRules.count)
                                                        $XmlTempWriter.WriteAttributeString($Attr6, [string]$ResName.properties.probes.count)

                                                        $Count ++
                                                    }
                                                    $XmlTempWriter.WriteAttributeString('id', ($CellID3+'-1'))

                                                        New-ARIDiagramSubnetIcon $IconLBs ($SubnetLocation+65) ($Alt0+40) "72" "72" $ContainerID

                                                    $XmlTempWriter.WriteEndElement()

                                                }
                                            else 
                                                {            
                                                    $XmlTempWriter.WriteStartElement('object')            
                                                    $XmlTempWriter.WriteAttributeString('label', [string]$RESNames.Name)                                        

                                                    $XmlTempWriter.WriteAttributeString('Load_Balancer_Name', [string]$ResNames.name)
                                                    $XmlTempWriter.WriteAttributeString('Load_Balancer_SKU', [string]$ResNames.sku.name)
                                                    $XmlTempWriter.WriteAttributeString('Backends', [string]$ResNames.properties.backendAddressPools.properties.backendIPConfigurations.id.count)
                                                    $XmlTempWriter.WriteAttributeString('Frontends', [string]$ResNames.properties.frontendIPConfigurations.properties.count)
                                                    $XmlTempWriter.WriteAttributeString('LB_Rules', [string]$ResNames.properties.loadBalancingRules.count)
                                                    $XmlTempWriter.WriteAttributeString('Probes', [string]$ResNames.properties.probes.count)

                                                    $XmlTempWriter.WriteAttributeString('id', ($CellID3+'-1'))

                                                        New-ARIDiagramSubnetIcon $IconLBs ($SubnetLocation+65) ($Alt0+40) "72" "72" $ContainerID

                                                    $XmlTempWriter.WriteEndElement()
                                                    
                                                }
                                            } 
                        'microsoft.network/virtualnetworkgateways' {
                                            Write-Output ('DrawIOSubnet: '+ $CellID2 + ' - ' +(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Adding VPN Gateway: " + $CellID3+'-1')
                                            if($RESNames.count -gt 1)
                                                {
                                                    $XmlTempWriter.WriteStartElement('object')            
                                                    $XmlTempWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' Virtual Network Gateways'))                                        

                                                    $Count = 1
                                                    foreach ($ResName in $RESNames)
                                                    {
                                                        $Attr1 = ('Network_Gateway-'+[string]("{0:d3}" -f $Count)+'-Name')

                                                        $XmlTempWriter.WriteAttributeString($Attr1, [string]$ResName.name)

                                                        $Count ++
                                                    }
                                                    $XmlTempWriter.WriteAttributeString('id', ($CellID3+'-1'))

                                                        New-ARIDiagramSubnetIcon $IconVGW ($SubnetLocation+80) ($Alt0+40) "52" "69" $ContainerID

                                                    $XmlTempWriter.WriteEndElement()

                                                }
                                            else
                                                {
                                                    $XmlTempWriter.WriteStartElement('object')            
                                                    $XmlTempWriter.WriteAttributeString('label', [string]$RESNames.Name)                                        

                                                    $XmlTempWriter.WriteAttributeString('id', ($CellID3+'-1'))

                                                        New-ARIDiagramSubnetIcon $IconVGW ($SubnetLocation+80) ($Alt0+40) "52" "69" $ContainerID

                                                    $XmlTempWriter.WriteEndElement()
                                                }                                                                                                         
                                            } 
                        'microsoft.network/azurefirewalls' {
                                            Write-Output ('DrawIOSubnet: '+ $CellID2 + ' - ' +(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Adding Azure Firewall: " + $CellID3+'-1')
                                            if($RESNames.count -gt 1)
                                                {
                                                    $XmlTempWriter.WriteStartElement('object')            
                                                    $XmlTempWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' Firewalls'))                                        

                                                    $Count = 1
                                                    foreach ($ResName in $RESNames)
                                                    {
                                                        $Attr1 = ('Firewall-'+[string]("{0:d3}" -f $Count)+'-Name')
                                                        $Attr2 = ('Firewall-'+[string]("{0:d3}" -f $Count)+'-SKU')
                                                        $Attr3 = ('Firewall-'+[string]("{0:d3}" -f $Count)+'-Threat_Intel_Mode')

                                                        $XmlTempWriter.WriteAttributeString($Attr1, [string]$ResName.name)
                                                        $XmlTempWriter.WriteAttributeString($Attr2, [string]$ResName.properties.sku.tier)
                                                        $XmlTempWriter.WriteAttributeString($Attr3, [string]$ResName.properties.threatIntelMode)

                                                        $Count ++
                                                    }
                                                    $XmlTempWriter.WriteAttributeString('id', ($CellID3+'-1'))

                                                        New-ARIDiagramSubnetIcon $IconFWs ($SubnetLocation+65) ($Alt0+40) "71" "60" $ContainerID

                                                    $XmlTempWriter.WriteEndElement()
                                                }
                                            else 
                                                {
                                                    $XmlTempWriter.WriteStartElement('object')            
                                                    $XmlTempWriter.WriteAttributeString('label', [string]$RESNames.name)      
                                                    

                                                    $XmlTempWriter.WriteAttributeString('Firewall_Name', [string]$ResNames.name)
                                                    $XmlTempWriter.WriteAttributeString('SKU_Tier', [string]$ResNames.properties.sku.tier)
                                                    $XmlTempWriter.WriteAttributeString('Threat_Intel_Mode', [string]$ResNames.properties.threatIntelMode)

                                                    $XmlTempWriter.WriteAttributeString('id', ($CellID3+'-1'))

                                                        New-ARIDiagramSubnetIcon $IconFWs ($SubnetLocation+65) ($Alt0+40) "71" "60" $ContainerID

                                                    $XmlTempWriter.WriteEndElement()
                                                }                                                                
                                            } 
                        'microsoft.network/privateendpoints' {
                                            Write-Output ('DrawIOSubnet: '+ $CellID2 + ' - ' +(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Adding PrivateLink: " + $CellID3+'-1')
                                            if($RESNames.count -gt 1)
                                                {
                                                    $XmlTempWriter.WriteStartElement('object')            
                                                    $XmlTempWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' Private Endpoints'))                                        

                                                    $Count = 1
                                                    foreach ($ResName in $RESNames)
                                                    {
                                                        $Attr1 = ('PVE-'+[string]("{0:d3}" -f $Count)+'-Name')

                                                        $XmlTempWriter.WriteAttributeString($Attr1, [string]$ResName.name)

                                                        $Count ++
                                                    }
                                                    $XmlTempWriter.WriteAttributeString('id', ($CellID3+'-1'))

                                                        New-ARIDiagramSubnetIcon $IconPVTs ($SubnetLocation+65) ($Alt0+40) "72" "66" $ContainerID

                                                    $XmlTempWriter.WriteEndElement()

                                                }
                                            else
                                                {
                                                    $XmlTempWriter.WriteStartElement('object')            
                                                    $XmlTempWriter.WriteAttributeString('label', [string]$RESNames.Name)                                        
                                                    $XmlTempWriter.WriteAttributeString('id', ($CellID3+'-1'))

                                                        New-ARIDiagramSubnetIcon $IconPVTs ($SubnetLocation+65) ($Alt0+40) "72" "66" $ContainerID

                                                    $XmlTempWriter.WriteEndElement()
                                                }                                                                       
                                            } 
                        'microsoft.network/applicationgateways' {
                                            Write-Output ('DrawIOSubnet: '+ $CellID2 + ' - ' +(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Adding AppGateway: " + $CellID3+'-1')
                                            if($RESNames.count -gt 1)
                                                {
                                                    $XmlTempWriter.WriteStartElement('object')            
                                                    $XmlTempWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' Application Gateways'))                                        

                                                    $Count = 1
                                                    foreach ($ResName in $RESNames)
                                                    {
                                                        $Attr1 = ('App_Gateway-'+[string]("{0:d3}" -f $Count)+'-Name')
                                                        $Attr2 = ('App_Gateway-'+[string]("{0:d3}" -f $Count)+'-SKU')
                                                        $Attr3 = ('App_Gateway-'+[string]("{0:d3}" -f $Count)+'-Min_Capacity')
                                                        $Attr4 = ('App_Gateway-'+[string]("{0:d3}" -f $Count)+'-Max_Capacity')

                                                        $XmlTempWriter.WriteAttributeString($Attr1, [string]$ResName.name)
                                                        $XmlTempWriter.WriteAttributeString($Attr2, [string]$RESName.Properties.sku.tier)
                                                        $XmlTempWriter.WriteAttributeString($Attr3, [string]$RESName.Properties.autoscaleConfiguration.minCapacity)
                                                        $XmlTempWriter.WriteAttributeString($Attr4, [string]$RESName.Properties.autoscaleConfiguration.maxCapacity)

                                                        $Count ++
                                                    }
                                                    $XmlTempWriter.WriteAttributeString('id', ($CellID3+'-1'))

                                                        New-ARIDiagramSubnetIcon $IconAppGWs ($SubnetLocation+65) ($Alt0+40) "64" "64" $ContainerID

                                                    $XmlTempWriter.WriteEndElement()

                                                }
                                            else
                                                {
                                                    $XmlTempWriter.WriteStartElement('object')            
                                                    $XmlTempWriter.WriteAttributeString('label', [string]$RESNames.Name)                                                            

                                                    $XmlTempWriter.WriteAttributeString('App_Gateway_Name', [string]$ResNames.name)
                                                    $XmlTempWriter.WriteAttributeString('App_Gateway_SKU', [string]$RESNames.Properties.sku.tier)
                                                    $XmlTempWriter.WriteAttributeString('Autoscale_Min_Capacity', [string]$RESNames.Properties.autoscaleConfiguration.minCapacity)
                                                    $XmlTempWriter.WriteAttributeString('Autoscale_Max_Capacity', [string]$RESNames.Properties.autoscaleConfiguration.maxCapacity)

                                                    $XmlTempWriter.WriteAttributeString('id', ($CellID3+'-1'))

                                                        New-ARIDiagramSubnetIcon $IconAppGWs ($SubnetLocation+65) ($Alt0+40) "64" "64" $ContainerID

                                                    $XmlTempWriter.WriteEndElement()
                                                }                                                                                                                                                                             
                                            }
                        'microsoft.network/bastionhosts' {
                                            Write-Output ('DrawIOSubnet: '+ $CellID2 + ' - ' +(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Adding BastionHost: " + $CellID3+'-1')
                                            if($RESNames.count -gt 1)
                                                {
                                                    $XmlTempWriter.WriteStartElement('object')            
                                                    $XmlTempWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' Bastion Hosts'))                                        

                                                    $Count = 1
                                                    foreach ($ResName in $RESNames)
                                                    {
                                                        $Attr1 = ('Bastion-'+[string]("{0:d3}" -f $Count)+'-Name')

                                                        $XmlTempWriter.WriteAttributeString($Attr1, [string]$ResName.name)

                                                        $Count ++
                                                    }
                                                    $XmlTempWriter.WriteAttributeString('id', ($CellID3+'-1'))

                                                        New-ARIDiagramSubnetIcon $IconBastions ($SubnetLocation+65) ($Alt0+40) "68" "67" $ContainerID

                                                    $XmlTempWriter.WriteEndElement()
                                                }
                                            else 
                                                {
                                                    $XmlTempWriter.WriteStartElement('object')            
                                                    $XmlTempWriter.WriteAttributeString('label', [string]$RESNames.name)                                                            
                                                    $XmlTempWriter.WriteAttributeString('id', ($CellID3+'-1'))

                                                        New-ARIDiagramSubnetIcon $IconBastions ($SubnetLocation+65) ($Alt0+40) "68" "67" $ContainerID

                                                    $XmlTempWriter.WriteEndElement()

                                                }                                                                        
                                            }
                        'Microsoft.PowerPlatform/vnetaccesslinks' {
                                            Write-Output ('DrawIOSubnet: '+ $CellID2 + ' - ' +(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Adding PowerPlatform: " + $CellID3+'-1')
                                            $XmlTempWriter.WriteStartElement('object')            
                                            $XmlTempWriter.WriteAttributeString('label', 'Delegated to Power Platform')

                                            $XmlTempWriter.WriteAttributeString('id', ($CellID3+'-1'))

                                                New-ARIDiagramSubnetIcon $IconPowerPlatform ($SubnetLocation+65) ($Alt0+40) "65" "60" $ContainerID

                                            $XmlTempWriter.WriteEndElement()

                                            }
                        'Microsoft.ApiManagement/service' {
                                            Write-Output ('DrawIOSubnet: '+ $CellID2 + ' - ' +(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Adding APIM: " + $CellID3+'-1')
                                            $XmlTempWriter.WriteStartElement('object')            
                                            $XmlTempWriter.WriteAttributeString('label', [string]$RESNames.Name)                                                            

                                            $APIMHost = [string]($RESNames.properties.hostnameConfigurations | Where-Object {$_.defaultSslBinding -eq $true}).hostname

                                            $XmlTempWriter.WriteAttributeString('APIM_Name', [string]$ResNames.name)
                                            $XmlTempWriter.WriteAttributeString('SKU', [string]$RESNames.sku.name)
                                            $XmlTempWriter.WriteAttributeString('VNET_Type', [string]$RESNames.properties.virtualNetworkType)
                                            $XmlTempWriter.WriteAttributeString('Default_Hostname', $APIMHost)

                                            $XmlTempWriter.WriteAttributeString('id', ($CellID3+'-1'))

                                                New-ARIDiagramSubnetIcon $IconAPIMs ($SubnetLocation+65) ($Alt0+40) "65" "60" $ContainerID

                                            $XmlTempWriter.WriteEndElement()

                                            }
                        'microsoft.web/serverfarms/servicepps' {
                                            Write-Output ('DrawIOSubnet: '+ $CellID2 + ' - ' +(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Adding App Service: " + $CellID3+'-1')
                                            if($RESNames.count -gt 1)
                                                {
                                                    $XmlTempWriter.WriteStartElement('object')            
                                                    $XmlTempWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' App Services'))                                        

                                                    $Count = 1
                                                    foreach ($ResName in $RESNames)
                                                    {
                                                        $Attr1 = ('AppService-'+[string]("{0:d3}" -f $Count)+'-Name')

                                                        $XmlTempWriter.WriteAttributeString($Attr1, [string]$ResName.name)

                                                        $Count ++
                                                    }
                                                    $XmlTempWriter.WriteAttributeString('id', ($CellID3+'-1'))

                                                        New-ARIDiagramSubnetIcon $IconAPPs ($SubnetLocation+65) ($Alt0+40) "64" "64" $ContainerID

                                                    $XmlTempWriter.WriteEndElement()
                                                }
                                            else
                                                {
                                                    $XmlTempWriter.WriteStartElement('object')            
                                                    $XmlTempWriter.WriteAttributeString('label', [string]$ResNames.name)                                                                        

                                                    $XmlTempWriter.WriteAttributeString('App_Name', [string]$ResNames.name)
                                                    $XmlTempWriter.WriteAttributeString('Default_Hostname', [string]$RESNames.properties.defaultHostName)
                                                    $XmlTempWriter.WriteAttributeString('Enabled', [string]$RESNames.properties.enabled)
                                                    $XmlTempWriter.WriteAttributeString('State', [string]$RESNames.properties.state)
                                                    $XmlTempWriter.WriteAttributeString('Inbound_IP_Address', [string]$RESNames.properties.inboundIpAddress)
                                                    $XmlTempWriter.WriteAttributeString('Kind', [string]$RESNames.properties.kind)
                                                    $XmlTempWriter.WriteAttributeString('SKU', [string]$RESNames.properties.sku)
                                                    $XmlTempWriter.WriteAttributeString('Workers', [string]$RESNames.properties.siteConfig.numberOfWorkers)
                                                    $XmlTempWriter.WriteAttributeString('Min_Workers', [string]$RESNames.properties.siteConfig.minimumElasticInstanceCount)
                                                    $XmlTempWriter.WriteAttributeString('Site_Properties', [string]$RESNames.properties.siteProperties.properties.value)

                                                    $XmlTempWriter.WriteAttributeString('id', ($CellID3+'-1'))

                                                        New-ARIDiagramSubnetIcon $IconAPPs ($SubnetLocation+65) ($Alt0+40) "64" "64" $ContainerID

                                                    $XmlTempWriter.WriteEndElement()
                                                }
                                            }
                        'microsoft.web/serverfarms/functionapps' {
                                            Write-Output ('DrawIOSubnet: '+ $CellID2 + ' - ' +(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Adding Function App: " + $CellID3+'-1')
                                            if($RESNames.count -gt 1)
                                                {
                                                    $XmlTempWriter.WriteStartElement('object')            
                                                    $XmlTempWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' Function Apps'))                                        

                                                    $Count = 1
                                                    foreach ($ResName in $RESNames)
                                                    {
                                                        $Attr1 = ('FunctionApp-'+[string]("{0:d3}" -f $Count)+'-Name')

                                                        $XmlTempWriter.WriteAttributeString($Attr1, [string]$ResName.name)

                                                        $Count ++
                                                    }
                                                    $XmlTempWriter.WriteAttributeString('id', ($CellID3+'-1'))

                                                        New-ARIDiagramSubnetIcon $IconFunApps ($SubnetLocation+65) ($Alt0+40) "68" "60" $ContainerID

                                                    $XmlTempWriter.WriteEndElement()
                                                }
                                            else
                                                {
                                                    $XmlTempWriter.WriteStartElement('object')            
                                                    $XmlTempWriter.WriteAttributeString('label', [string]$ResNames.name)                                                                        

                                                    $XmlTempWriter.WriteAttributeString('App_Name', [string]$ResNames.name)
                                                    $XmlTempWriter.WriteAttributeString('Default_Hostname', [string]$RESNames.properties.defaultHostName)
                                                    $XmlTempWriter.WriteAttributeString('Enabled', [string]$RESNames.properties.enabled)
                                                    $XmlTempWriter.WriteAttributeString('State', [string]$RESNames.properties.state)
                                                    $XmlTempWriter.WriteAttributeString('Inbound_IP_Address', [string]$RESNames.properties.inboundIpAddress)
                                                    $XmlTempWriter.WriteAttributeString('Kind', [string]$RESNames.properties.kind)
                                                    $XmlTempWriter.WriteAttributeString('SKU', [string]$RESNames.properties.sku)
                                                    $XmlTempWriter.WriteAttributeString('Workers', [string]$RESNames.properties.siteConfig.numberOfWorkers)
                                                    $XmlTempWriter.WriteAttributeString('Min_Workers', [string]$RESNames.properties.siteConfig.minimumElasticInstanceCount)
                                                    $XmlTempWriter.WriteAttributeString('Site_Properties', [string]$RESNames.properties.siteProperties.properties.value)

                                                    $XmlTempWriter.WriteAttributeString('id', ($CellID3+'-1'))

                                                        New-ARIDiagramSubnetIcon $IconFunApps ($SubnetLocation+65) ($Alt0+40) "68" "60" $ContainerID

                                                    $XmlTempWriter.WriteEndElement()

                                                }
                                            }
                        'Microsoft.Databricks/workspaces' {
                                            Write-Output ('DrawIOSubnet: '+ $CellID2 + ' - ' +(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Adding Databricks: " + $CellID3+'-1')                                            
                                            if($RESNames.count -gt 1)
                                                {
                                                    $XmlTempWriter.WriteStartElement('object')            
                                                    $XmlTempWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' Databricks'))                                        

                                                    $Count = 1
                                                    foreach ($ResName in $RESNames)
                                                    {
                                                        $Attr1 = ('Databrick-'+[string]("{0:d3}" -f $Count)+'-Name')

                                                        $XmlTempWriter.WriteAttributeString($Attr1, [string]$ResName.name)

                                                        $Count ++
                                                    }
                                                    $XmlTempWriter.WriteAttributeString('id', ($CellID3+'-1'))

                                                        New-ARIDiagramSubnetIcon $IconBricks ($SubnetLocation+65) ($Alt0+40) "60" "68" $ContainerID

                                                    $XmlTempWriter.WriteEndElement()
                                                }
                                            else
                                                {
                                                    $XmlTempWriter.WriteStartElement('object')            
                                                    $XmlTempWriter.WriteAttributeString('label', [string]$RESNames.Name)                                                                

                                                    $XmlTempWriter.WriteAttributeString('Databrick_Name', [string]$ResNames.name)
                                                    $XmlTempWriter.WriteAttributeString('Workspace_URL', [string]$RESNames.properties.workspaceUrl )
                                                    $XmlTempWriter.WriteAttributeString('Pricing_Tier', [string]$RESNames.sku.name)
                                                    $XmlTempWriter.WriteAttributeString('Storage_Account', [string]$RESNames.properties.parameters.storageAccountName.value)
                                                    $XmlTempWriter.WriteAttributeString('Storage_Account_SKU', [string]$RESNames.properties.parameters.storageAccountSkuName.value)
                                                    $XmlTempWriter.WriteAttributeString('Relay_Namespace', [string]$RESNames.properties.parameters.relayNamespaceName.value)
                                                    $XmlTempWriter.WriteAttributeString('Require_Infrastructure_Encryption', [string]$RESNames.properties.parameters.requireInfrastructureEncryption.value)
                                                    $XmlTempWriter.WriteAttributeString('Enable_Public_IP', [string]$RESNames.properties.parameters.enableNoPublicIp.value)

                                                    $XmlTempWriter.WriteAttributeString('id', ($CellID3+'-1'))

                                                        New-ARIDiagramSubnetIcon $IconBricks ($SubnetLocation+65) ($Alt0+40) "60" "68" $ContainerID

                                                    $XmlTempWriter.WriteEndElement()
                                                }                                                                                               
                                            }
                        'microsoft.redhatopenshift/openshiftclusters' {
                                            Write-Output ('DrawIOSubnet: '+ $CellID2 + ' - ' +(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Adding OpenShift: " + $CellID3+'-1')
                                            if($RESNames.count -gt 1)
                                                {
                                                    $XmlTempWriter.WriteStartElement('object')            
                                                    $XmlTempWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' OpenShift Clusters'))                                        

                                                    $Count = 1
                                                    foreach ($ResName in $RESNames)
                                                    {
                                                        $Attr1 = ('OpenShift_Cluster-'+[string]("{0:d3}" -f $Count)+'-Name')

                                                        $XmlTempWriter.WriteAttributeString($Attr1, [string]$ResName.name)

                                                        $Count ++
                                                    }
                                                    $XmlTempWriter.WriteAttributeString('id', ($CellID3+'-1'))

                                                        New-ARIDiagramSubnetIcon $IconARO ($SubnetLocation+65) ($Alt0+40) "68" "60" $ContainerID

                                                    $XmlTempWriter.WriteEndElement()

                                                }
                                            else
                                                {
                                                    $XmlTempWriter.WriteStartElement('object')            
                                                    $XmlTempWriter.WriteAttributeString('label', [string]$RESNames.Name)                                                                    

                                                    $XmlTempWriter.WriteAttributeString('ARO_Name', [string]$ResNames.name)
                                                    $XmlTempWriter.WriteAttributeString('OpenShift_Version', [string]$RESNames.properties.clusterProfile.version)
                                                    $XmlTempWriter.WriteAttributeString('OpenShift_Console', [string]$RESNames.properties.consoleProfile.url)
                                                    $XmlTempWriter.WriteAttributeString('Worker_VM_Count', [string]$RESNames.properties.workerprofiles.Count)
                                                    $XmlTempWriter.WriteAttributeString('Worker_VM_Size', [string]$RESNames.properties.workerprofiles.vmSize[0])

                                                    $XmlTempWriter.WriteAttributeString('id', ($CellID3+'-1'))

                                                        New-ARIDiagramSubnetIcon $IconARO ($SubnetLocation+65) ($Alt0+40) "68" "60" $ContainerID

                                                    $XmlTempWriter.WriteEndElement()
                                                }
                                            }
                        'Microsoft.ContainerInstance/containerGroups'  {
                                                Write-Output ('DrawIOSubnet: '+ $CellID2 + ' - ' +(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Adding Container Instance: " + $CellID3+'-1')
                                                if($RESNames.count -gt 1)
                                                    {
                                                        $XmlTempWriter.WriteStartElement('object')            
                                                        $XmlTempWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' Container Intances'))                                        

                                                        $Count = 1
                                                        foreach ($ResName in $RESNames)
                                                        {
                                                            $Attr1 = ('Container_Intance-'+[string]("{0:d3}" -f $Count)+'-Name')

                                                            $XmlTempWriter.WriteAttributeString($Attr1, [string]$ResName.name)

                                                            $Count ++
                                                        }
                                                        $XmlTempWriter.WriteAttributeString('id', ($CellID3+'-1'))

                                                            New-ARIDiagramSubnetIcon $IconContain ($SubnetLocation+65) ($Alt0+40) "64" "68" $ContainerID

                                                        $XmlTempWriter.WriteEndElement()
                                                    }
                                                else
                                                    {
                                                        $XmlTempWriter.WriteStartElement('object')            
                                                        $XmlTempWriter.WriteAttributeString('label', [string]$RESNames.Name)                                        
                                                        $XmlTempWriter.WriteAttributeString('id', ($CellID3+'-1'))

                                                            New-ARIDiagramSubnetIcon $IconContain ($SubnetLocation+65) ($Alt0+40) "64" "68" $ContainerID

                                                        $XmlTempWriter.WriteEndElement()
                                                    }
                                            }
                        'microsoft.netapp/volumes' {          
                                            Write-Output ('DrawIOSubnet: '+ $CellID2 + ' - ' +(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Adding ANF: " + $CellID3+'-1')
                                            if($RESNames.count -gt 1)
                                                {
                                                    $XmlTempWriter.WriteStartElement('object')            
                                                    $XmlTempWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' NetApp Volumes'))                                        

                                                    $Count = 1
                                                    foreach ($ResName in $RESNames)
                                                    {
                                                        $Attr1 = ('NetApp_Volume-'+[string]("{0:d3}" -f $Count))

                                                        $XmlTempWriter.WriteAttributeString($Attr1, [string]$ResName.name)

                                                        $Count ++
                                                    }
                                                    $XmlTempWriter.WriteAttributeString('id', ($CellID3+'-1'))

                                                        New-ARIDiagramSubnetIcon $IconNetApp ($SubnetLocation+65) ($Alt0+40) "65" "52" $ContainerID

                                                    $XmlTempWriter.WriteEndElement()
                                                }
                                            else
                                                {
                                                    $XmlTempWriter.WriteStartElement('object')            
                                                    $XmlTempWriter.WriteAttributeString('label', ([string]1+' NetApp Volume'))                                                                        
                                                    $XmlTempWriter.WriteAttributeString('NetApp_Volume_Name', [string]$ResNames.name)

                                                    $XmlTempWriter.WriteAttributeString('id', ($CellID3+'-1'))

                                                        New-ARIDiagramSubnetIcon $IconNetApp ($SubnetLocation+65) ($Alt0+40) "65" "52" $ContainerID

                                                    $XmlTempWriter.WriteEndElement()
                                                }
                                            }
                        'Microsoft.Kusto/clusters' {
                                            Write-Output ('DrawIOSubnet: '+ $CellID2 + ' - ' +(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Adding Data Explorer Cluster: " + $CellID3+'-1')
                                            if($RESNames.count -gt 1)
                                                {
                                                    $XmlTempWriter.WriteStartElement('object')            
                                                    $XmlTempWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' Data Explorer Clusters'))                                        

                                                    $Count = 1
                                                    foreach ($ResName in $RESNames)
                                                    {
                                                        $Attr1 = ('Data_Cluster-'+[string]("{0:d3}" -f $Count)+'-Name')

                                                        $XmlTempWriter.WriteAttributeString($Attr1, [string]$ResName.name)

                                                        $Count ++
                                                    }
                                                    $XmlTempWriter.WriteAttributeString('id', ($CellID3+'-1'))

                                                        New-ARIDiagramSubnetIcon $IconDataExplorer ($SubnetLocation+65) ($Alt0+40) "68" "68" $ContainerID

                                                    $XmlTempWriter.WriteEndElement()

                                                }
                                            else
                                                {
                                                    $XmlTempWriter.WriteStartElement('object')            
                                                    $XmlTempWriter.WriteAttributeString('label', [string]$RESNames.Name)                                        
                                                    $XmlTempWriter.WriteAttributeString('Data_Explorer_Cluster_Name', [string]$ResNames.name)
                                                    $XmlTempWriter.WriteAttributeString('Data_Explorer_Cluster_URI', [string]$ResNames.name)
                                                    $XmlTempWriter.WriteAttributeString('Data_Explorer_Cluster_State', [string]$ResNames.name)
                                                    $XmlTempWriter.WriteAttributeString('SKU_Tier', [string]$ResNames.name)
                                                    $XmlTempWriter.WriteAttributeString('Computer_Specifications', [string]$ResNames.name)
                                                    $XmlTempWriter.WriteAttributeString('AutoScale_Enabled', [string]$ResNames.name)
                                                    $XmlTempWriter.WriteAttributeString('id', ($CellID3+'-1'))

                                                        New-ARIDiagramSubnetIcon $IconDataExplorer ($SubnetLocation+65) ($Alt0+40) "68" "68" $ContainerID

                                                    $XmlTempWriter.WriteEndElement()
                                                }
                                            } 
                        'microsoft.network/networkinterfaces' {
                                            Write-Output ('DrawIOSubnet: '+ $CellID2 + ' - ' +(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Adding NIC: " + $CellID3+'-1')
                                            if($RESNames.count -gt 1)
                                                {
                                                    $XmlTempWriter.WriteStartElement('object')            
                                                    $XmlTempWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' Network Interfaces'))                                        

                                                    $Count = 1
                                                    foreach ($ResName in $RESNames)
                                                    {
                                                        $Attr1 = ('NIC-'+[string]("{0:d3}" -f $Count)+'-Name')

                                                        $XmlTempWriter.WriteAttributeString($Attr1, [string]$ResName.name)

                                                        $Count ++
                                                    }
                                                    $XmlTempWriter.WriteAttributeString('id', ($CellID3+'-1'))

                                                        New-ARIDiagramSubnetIcon $IconNIC ($SubnetLocation+65) ($Alt0+40) "68" "60" $ContainerID

                                                    $XmlTempWriter.WriteEndElement()

                                                }
                                            else
                                                {
                                                    $XmlTempWriter.WriteStartElement('object')            
                                                    $XmlTempWriter.WriteAttributeString('label', ([string]1+' Network Interface'))                                        

                                                    $Attr1 = ('NIC-Name')
                                                    $XmlTempWriter.WriteAttributeString($Attr1, [string]$ResNames.name)

                                                    $XmlTempWriter.WriteAttributeString('id', ($CellID3+'-1'))

                                                        New-ARIDiagramSubnetIcon $IconNIC ($SubnetLocation+65) ($Alt0+40) "68" "60" $ContainerID

                                                    $XmlTempWriter.WriteEndElement()

                                                }
                                            }                                                                                                                                                                            
                        'EmptySubnet' {Write-Output ('DrawIOSubnet: '+ $CellID2 + ' - ' +(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Not Adding ProcType: " + 'Blank Resource Type Name')}
                        default {Write-Output ('DrawIOSubnet: '+ $CellID2 + ' - ' +(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Not Adding ProcType: $TrueTemp - " + 'Missing ResourceType in the list')}
                    }
                    if($sub.properties.networkSecurityGroup.id)
                        {
                            $NSG = $sub.properties.networkSecurityGroup.id.split('/')[8]
                            $XmlTempWriter.WriteStartElement('object')            
                            $XmlTempWriter.WriteAttributeString('label', '')                                        
                            $XmlTempWriter.WriteAttributeString('Network_Security_Group', [string]$NSG)
                            $XmlTempWriter.WriteAttributeString('id', ($CellID3+'-2'))

                                Write-Output ('DrawIOSubnet: '+ $CellID2 + ' - ' +(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Adding NSG: " + $CellID3+'-2')
                                New-ARIDiagramSubnetIcon $IconNSG ($SubnetLocation+160) ($Alt0+15) "26.35" "32" $ContainerID

                            $XmlTempWriter.WriteEndElement()  
                        }
                    if($sub.properties.routeTable.id)
                        {
                            $UDR = $sub.properties.routeTable.id.split('/')[8]
                            $XmlTempWriter.WriteStartElement('object')            
                            $XmlTempWriter.WriteAttributeString('label', '')                                        
                            $XmlTempWriter.WriteAttributeString('Route_Table', [string]$UDR)
                            $XmlTempWriter.WriteAttributeString('id', ($CellID3+'-3'))

                                Write-Output ('DrawIOSubnet: '+ $CellID2 + ' - ' +(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Adding UDR: " + $CellID3+'-3')
                                New-ARIDiagramSubnetIcon $IconUDR ($SubnetLocation+15) ($Alt0+15) "30.97" "30" $ContainerID

                            $XmlTempWriter.WriteEndElement()

                        }
            }

        Function Get-ARIDiagramSubnetResourceType {
            Param($Sub,$LogFile)

            if (![string]::IsNullOrEmpty($sub.properties.delegations.properties.serviceName))
                {
                    $TrueTemp = $Sub.properties.delegations.properties.serviceName
                }
            elseif ($sub.id -in $Job.AKS.properties.agentPoolProfiles.vnetSubnetID)
                {
                    $TrueTemp = 'microsoft.containerservice/managedclusters'
                }
            elseif ($sub.properties.resourceNavigationLinks.properties.linkedResourceType -eq 'Microsoft.ApiManagement/service')
                {
                    $TrueTemp = 'microsoft.apimanagement/service'
                }
            elseif (![string]::IsNullOrEmpty($sub.properties.serviceAssociationLinks.properties.link))
                {
                    if ($sub.properties.serviceAssociationLinks.properties.link.split("/")[6] -eq 'Microsoft.Web')
                        {
                            $TrueTemp = 'microsoft.web/serverfarms'
                        }
                }
            elseif (![string]::IsNullOrEmpty($sub.properties.applicationGatewayIPConfigurations.id))
                {
                    if($sub.properties.applicationGatewayIPConfigurations.id.split("/")[7] -eq 'applicationGateways')
                        {
                            $TrueTemp = 'microsoft.network/applicationgateways'
                        }
                }
            else
                {
                    $Types = Foreach($type in $sub.properties.ipconfigurations.id)
                        {
                            $SplitedTypes = $type.Split("/")
                            if($SplitedTypes[8] -like 'aks-*')
                                {
                                    'microsoft.containerservice/managedclusters'
                                }
                            elseif($SplitedTypes[8] -like 'gwhost*')
                                {
                                    'microsoft.apimanagement/service'
                                }
                            else
                                {
                                    ($SplitedTypes[6] + '/' + $SplitedTypes[7])
                                }
                        }
                        $TrueTemp = ($Types | Group-Object | Sort-Object -Property Count -Descending | Select-Object -First 1).Name
                }

                if($TrueTemp -eq 'microsoft.network/networkinterfaces')
                    {
                        $NIcNames = $Job.NIC | Where-Object {$_.properties.ipConfigurations.properties.subnet.id -eq $sub.id}
                        $VMsInSubnet = foreach ($VM in $Job.VM)
                                                {
                                                    if ($VM.properties.networkprofile.networkInterfaces.id -in $NICNames.id)
                                                        {
                                                            $VM
                                                        }
                                                }
                        if($VMsInSubnet.properties.storageprofile.imageReference.offer -like 'aro*')
                            {
                                $TrueTemp = 'microsoft.redhatopenshift/openshiftclusters'
                            }
                        elseif (![string]::IsNullOrEmpty($VMsInSubnet))
                            {
                                $TrueTemp = 'microsoft.compute/virtualmachines'
                            }
                        elseif($sub.properties.privateEndpoints.id)
                            {
                                $TrueTemp = 'microsoft.network/privateendpoints'
                            }
                    }

                if($TrueTemp -eq 'microsoft.web/serverfarms')
                    {
                        $WebApps = foreach ($App in $Job.AppWeb)
                            {
                                if($App.properties.virtualNetworkSubnetId -eq $sub.id)
                                    {
                                        $App
                                    }
                            }
                        if('functionapp' -in $WebApps.kind)
                            {
                                $TrueTemp = 'microsoft.web/serverfarms/functionapps'                  
                            }
                        else
                            {
                                $TrueTemp = 'microsoft.web/serverfarms/servicepps'
                            }
                    }

                if([string]::IsNullOrEmpty($TrueTemp))
                    {
                        if ($sub.id -in ($Job.VMSS).properties.virtualMachineProfile.networkprofile.networkInterfaceConfigurations.properties.ipconfigurations.properties.subnet.id)
                            {
                                $TrueTemp = 'microsoft.compute/virtualmachinescalesets'
                            }
                    }

                if ([string]::IsNullOrEmpty($TrueTemp))
                    {
                        $TrueTemp = 'EmptySubnet'
                    }

            return $TrueTemp
        }

        Function Get-ARIDiagramSubnetResourcesName {
            Param($sub,$TrueTemp,$LogFile)

            if($TrueTemp -eq 'microsoft.containerservice/managedclusters')
                {
                    $ResNames = foreach ($AKS in $Job.AKS)
                        {
                            if($AKS.properties.agentPoolProfiles.vnetSubnetID -eq $sub.id)
                                {
                                    $AKS
                                }
                        }
                }
            elseif($TrueTemp -eq 'Microsoft.Kusto/clusters')
                {
                    $RESNames = foreach ($Kusto in $Job.Kusto)
                        {
                            if($Kusto.properties.virtualNetworkConfiguration.subnetid -eq $sub.id)
                                {
                                    $Kusto
                                }
                        }
                }
            elseif($TrueTemp -eq 'microsoft.network/applicationgateways')
                {
                    $RESNames = foreach ($AppGtw in $Job.AppGtw)
                        {
                            if($AppGtw.properties.gatewayIPConfigurations.id -in $sub.properties.applicationGatewayIPConfigurations.id)
                                {
                                    $AppGtw
                                }
                        }
                }
            elseif($TrueTemp -eq 'Microsoft.Databricks/workspaces')
                {
                    $RESNames = Foreach($Data in $Job.Databricks)
                        {                 
                            if($Data.properties.parameters.customVirtualNetworkId.value+'/subnets/'+$Data.properties.parameters.customPrivateSubnetName.value -eq $sub.id -or $Data.properties.parameters.customVirtualNetworkId.value+'/subnets/'+$Data.properties.parameters.custompublicSubnetName.value -eq $sub.id)
                                {                         
                                    $Data
                                }
                        }
                }
            elseif($TrueTemp -like 'microsoft.web/serverfarms*')
                {
                    $RESNames = foreach ($App in $Job.AppWeb)
                        {
                            if($App.properties.virtualNetworkSubnetId -eq $sub.id)
                                {
                                    $App
                                }
                        }
                }                   
            elseif($TrueTemp -eq 'microsoft.apimanagement/service')
                {
                    $RESNames = foreach ($APIM in $Job.APIM)
                        {
                            if($APIM.properties.virtualNetworkConfiguration.subnetResourceId -eq $sub.id)
                                {
                                    $APIM
                                }
                        }
                }
            elseif($TrueTemp -eq 'microsoft.network/loadbalancers')
                {
                    $RESNames = foreach ($LB in $Job.LB)
                        {
                            if($LB.properties.frontendIPConfigurations.id -in $sub.properties.ipconfigurations.id)
                                {
                                    $LB
                                }
                        }
                }
            elseif($TrueTemp -eq 'microsoft.compute/virtualmachinescalesets')
                {
                    $RESNames = foreach ($VMSS in $Job.VMSS)
                        {
                            if($VMSS.properties.virtualMachineProfile.networkProfile.networkInterfaceConfigurations.properties.ipconfigurations.properties.subnet.id -eq $sub.id)
                                {
                                    $VMSS
                                }
                        }
                }
            elseif($TrueTemp -eq 'microsoft.network/virtualnetworkgateways')
                {
                    $RESNames = $Job.AZVGWs | Where-Object {$_.properties.ipconfigurations.properties.subnet.id -eq $sub.id }
                }
            elseif($TrueTemp -eq 'microsoft.network/bastionhosts')
                {
                    $RESNames = $Job.Bastion | Where-Object {$_.properties.ipConfigurations.properties.subnet.id -eq $sub.id }
                }
            elseif($TrueTemp -eq 'microsoft.network/azurefirewalls')
                {
                    $RESNames = $Job.FW | Where-Object {$_.properties.ipConfigurations.properties.subnet.id -eq $sub.id }
                }
            elseif($TrueTemp -eq 'microsoft.containerinstance/containergroups')
                {
                    $ContNICs = $Job.NetProf | Where-Object {$_.properties.containerNetworkInterfaceConfigurations.properties.ipconfigurations.properties.subnet.id -eq $sub.id}
                    $RESNames = $Job.Container | Where-Object {$_.properties.networkprofile.id -in $ContNICs.id}
                    if([string]::IsNullOrEmpty($RESNames))
                        {
                            $RESNames = $Job.ARO | Where-Object {$_.properties.masterprofile.subnetId -eq $sub.id -or $_.properties.workerProfiles.subnetId -eq $sub.id}
                        }
                }
            elseif($TrueTemp -like 'microsoft.netapp*/volumes')
                {
                    $RESNames = $Job.ANF | Where-Object {$_.properties.subnetId -eq $sub.id }
                }
            elseif($TrueTemp -eq 'microsoft.redhatopenshift/openshiftclusters')
                {
                    $RESNames = $Job.ARO | Where-Object {$_.properties.masterprofile.subnetId -eq $sub.id -or $_.properties.workerProfiles.subnetId -eq $sub.id}
                }
            elseif($TrueTemp -eq 'microsoft.compute/virtualmachines')
                {
                    $NIcNames = $Job.NIC | Where-Object {$_.properties.ipConfigurations.properties.subnet.id -eq $sub.id}
                    $ResNames = $Job.VM | Where-Object {$_.properties.networkprofile.networkInterfaces.id -in $NIcNames.id}
                }
            elseif($TrueTemp -eq 'microsoft.network/networkinterfaces')
                {
                    $ResNames = $Job.NIC | Where-Object {$_.properties.ipConfigurations.properties.subnet.id -eq $sub.id}
                }
            elseif($TrueTemp -eq 'microsoft.network/privateendpoints')
                {
                    $NIcNames = $Job.NIC | Where-Object {$_.properties.ipConfigurations.properties.subnet.id -eq $sub.id}
                    $ResNames = $Job.PrivEnd | Where-Object {$_.properties.networkInterfaces.id -in $NIcNames.id}
                }

            return $ResNames
        }


        ######################################################### ICON #######################################################

        Function New-ARIDiagramSubnetIcon {    
            Param($Style,$x,$y,$w,$h,$p)

                Write-Output ('DrawIOSubnet: '+ $CellID2 + ' - ' +(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Adding Resource Icon: " + $Style)

                $XmlTempWriter.WriteStartElement('mxCell')
                $XmlTempWriter.WriteAttributeString('style', $Style)
                $XmlTempWriter.WriteAttributeString('vertex', "1")
                $XmlTempWriter.WriteAttributeString('parent', $p)

                    $XmlTempWriter.WriteStartElement('mxGeometry')
                    $XmlTempWriter.WriteAttributeString('x', $x)
                    $XmlTempWriter.WriteAttributeString('y', $y)
                    $XmlTempWriter.WriteAttributeString('width', $w)
                    $XmlTempWriter.WriteAttributeString('height', $h)
                    $XmlTempWriter.WriteAttributeString('as', "geometry")
                    $XmlTempWriter.WriteEndElement()

                $XmlTempWriter.WriteEndElement()
            }

        ######################################################## SUBNET #######################################################

        Publish-ARIDiagramStensils

        $XmlTempWriter = New-Object System.XMl.XmlTextWriter($SubFile,$Null)

        $XmlTempWriter.Formatting = 'Indented'
        $XmlTempWriter.Indentation = 2

        $XmlTempWriter.WriteStartDocument()

        $XmlTempWriter.WriteStartElement('mxfile')
        $XmlTempWriter.WriteAttributeString('host', 'Electron')
        $XmlTempWriter.WriteAttributeString('modified', '2021-10-01T21:45:40.561Z')
        $XmlTempWriter.WriteAttributeString('agent', '5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) draw.io/15.4.0 Chrome/91.0.4472.164 Electron/13.5.0 Safari/537.36')
        $XmlTempWriter.WriteAttributeString('etag', $etag)
        $XmlTempWriter.WriteAttributeString('version', '15.4.0')
        $XmlTempWriter.WriteAttributeString('type', 'device')

            $XmlTempWriter.WriteStartElement('diagram')
            $XmlTempWriter.WriteAttributeString('id', $DiagID)
            $XmlTempWriter.WriteAttributeString('name', 'Network Topology')

                $XmlTempWriter.WriteStartElement('mxGraphModel')
                $XmlTempWriter.WriteAttributeString('dx', "1326")
                $XmlTempWriter.WriteAttributeString('dy', "798")
                $XmlTempWriter.WriteAttributeString('grid', "1")
                $XmlTempWriter.WriteAttributeString('gridSize', "10")
                $XmlTempWriter.WriteAttributeString('guides', "1")
                $XmlTempWriter.WriteAttributeString('tooltips', "1")
                $XmlTempWriter.WriteAttributeString('connect', "1")
                $XmlTempWriter.WriteAttributeString('arrows', "1")
                $XmlTempWriter.WriteAttributeString('fold', "1")
                $XmlTempWriter.WriteAttributeString('page', "1")
                $XmlTempWriter.WriteAttributeString('pageScale', "1")
                $XmlTempWriter.WriteAttributeString('pageWidth', "850")
                $XmlTempWriter.WriteAttributeString('pageHeight', "1100")
                $XmlTempWriter.WriteAttributeString('math', "0")
                $XmlTempWriter.WriteAttributeString('shadow', "0")

                    $XmlTempWriter.WriteStartElement('root')

                        $XmlTempWriter.WriteStartElement('mxCell')
                        $XmlTempWriter.WriteAttributeString('id', "0")
                        $XmlTempWriter.WriteEndElement()

                        $XmlTempWriter.WriteStartElement('mxCell')
                        $XmlTempWriter.WriteAttributeString('id', "1")
                        $XmlTempWriter.WriteAttributeString('parent', "0")
                        $XmlTempWriter.WriteEndElement()

                            $sizeL =  $VNET.properties.subnets.properties.addressPrefix.count
                            if ($sizeL -gt 5)
                                {                                           
                                    $sizeL = $sizeL / 2
                                    $sizeL = [math]::ceiling($sizeL)
                                    $sizeC = $sizeL
                                    $sizeL = (($sizeL * 210) + 30)

                                    $SubnetLocation0 = 20
                                    $SubC = 0
                                    $alt1 = 40
                                    foreach($Sub in $VNET.properties.subnets)
                                    {
                                        $IDNum++
                                        if ($SubC -eq $sizeC) 
                                        {
                                            $Alt1 = $Alt1 + 230
                                            $SubnetLocation0 = 20
                                            $SubC = 0
                                        }

                                        $LoggingSubnetName = $sub.Name
                                        Write-Output ('DrawIOSubnet: '+ $CellID2 + ' - ' +(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Adding Subnet ($LoggingSubnetName): " + $CellID2+'-'+$IDNum)

                                        $XmlTempWriter.WriteStartElement('object')            
                                        $XmlTempWriter.WriteAttributeString('label', ("`n" + "`n" + "`n" + "`n" + "`n" + "`n" +[string]$sub.Name + "`n" + [string]$sub.properties.addressPrefix))
                                        $XmlTempWriter.WriteAttributeString('id', ($CellID2+'-'+$IDNum))

                                            New-ARIDiagramSubnetIcon "rounded=0;whiteSpace=wrap;fontSize=16;html=1;sketch=0;fontFamily=Helvetica;" $SubnetLocation0 $Alt1 "200" "200" $ContainerID

                                        $XmlTempWriter.WriteEndElement()      

                                            Set-ARIDiagramSubnetComponent -sub $sub -SubnetLocation $SubnetLocation0 -Alt0 $Alt1 -ContainerID $ContainerID -LogFile $LogFile

                                        $SubnetLocation = $SubnetLocation + 210
                                        $SubnetLocation0 = $SubnetLocation0 + 210
                                        $SubC ++
                                    }

                                }
                            Else
                                {
                                    $sizeL = (($sizeL * 210) + 30)
                                    $SubnetLocation0 = 20
                                    foreach($Sub in $VNET.properties.subnets)
                                    {
                                        $IDNum++
                                        $LoggingSubnetName = $sub.Name
                                        Write-Output ('DrawIOSubnet: '+ $CellID2 + ' - ' +(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Adding Subnet ($LoggingSubnetName): " + $CellID2+'-'+$IDNum)


                                        $XmlTempWriter.WriteStartElement('object')            
                                        $XmlTempWriter.WriteAttributeString('label', ("`n" + "`n" + "`n" + "`n" + "`n" + "`n" +[string]$sub.Name + "`n" + [string]$sub.properties.addressPrefix))
                                        $XmlTempWriter.WriteAttributeString('id', ($CellID2+'-'+$IDNum))

                                            New-ARIDiagramSubnetIcon "rounded=0;whiteSpace=wrap;fontSize=16;html=1;sketch=0;fontFamily=Helvetica;" $SubnetLocation0 40 "200" "200" $ContainerID

                                        $XmlTempWriter.WriteEndElement()  

                                            Set-ARIDiagramSubnetComponent -sub $sub -SubnetLocation $SubnetLocation0 -Alt0 40 -ContainerID $ContainerID -LogFile $LogFile

                                        $SubnetLocation = $SubnetLocation + 210
                                        $SubnetLocation0 = $SubnetLocation0 + 210
                                    }
                                }

                        $XmlTempWriter.WriteEndElement()

                    $XmlTempWriter.WriteEndElement()

                $XmlTempWriter.WriteEndElement()
                $XmlTempWriter.WriteEndElement()

            $XmlTempWriter.WriteEndDocument()
            $XmlTempWriter.Flush()
            $XmlTempWriter.Close() 
        }
        catch
        {
            Write-Output ('DrawIOSubnet: '+ $CellID2 + ' - ' +(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Error: ' + $_.Exception.Message)
        }
}