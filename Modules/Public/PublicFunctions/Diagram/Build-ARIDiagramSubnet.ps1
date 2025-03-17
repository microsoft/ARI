Function Build-ARIDiagramSubnet {
    Param($SubnetLocation,$VNET,$IDNum,$DiagramCache,$ContainerID,$LogFile)

    try
        {
        $etag = -join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})
        $DiagID = -join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})
        $CellID2 = -join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})

        $IDNum++

        $SubFileName = ($CellID2 + '.xml')

        $SubFile = Join-Path $DiagramCache $SubFileName

        ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Adding Subnet File: " + $SubFile) | Out-File -FilePath $LogFile -Append

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
        
        }

        ####################################################### Subnet Components ####################################################

        Function Set-ARIDiagramSubnetComponent {
            Param($sub,$SubnetLocation,$Alt0,$ContainerID,$LogFile) 

                $CellID3 = -join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})
                $temp = ''
                remove-variable TrueTemp -ErrorAction SilentlyContinue
                remove-variable RESNames -ErrorAction SilentlyContinue

                <####################################################### FIND THE RESOURCES IN THE SUBNET ###################################################################>

                $LoggingSubName = $Sub.id
                ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Validating ProcType: " + $LoggingSubName) | Out-File -FilePath $LogFile -Append
                if($sub.properties.resourceNavigationLinks.properties.linkedResourceType -eq 'Microsoft.ApiManagement/service')
                    {
                        $TrueTemp = 'APIM'
                    }
                if($sub.properties.serviceAssociationLinks.properties.link -and $null -eq $TrueTemp)
                    {
                        if($sub.properties.serviceAssociationLinks.properties.link.split("/")[6] -eq 'Microsoft.Web') 
                            {
                                $TrueTemp = 'App Service'
                            }
                    }
                if($sub.properties.applicationGatewayIPConfigurations.id -and $null -eq $TrueTemp)
                    {
                        if($sub.properties.applicationGatewayIPConfigurations.id.split("/")[7] -eq 'applicationGateways')
                            {
                                $TrueTemp = 'applicationGateways'
                            }
                    }
                if($sub.properties.ipconfigurations.id.count -eq 1 -and $null -eq $TrueTemp)
                    {                 
                        if($sub.properties.ipconfigurations.id.Split("/")[7] -eq 'virtualNetworkGateways')
                            {               
                                $TrueTemp = 'virtualNetworkGateways'
                            }
                        elseif($sub.properties.ipconfigurations.id.Split("/")[7] -eq 'loadBalancers')
                            {               
                                $TrueTemp = 'loadBalancers'
                            }
                        elseif($sub.properties.ipconfigurations.id.Split("/")[7] -eq 'applicationGateways')
                            {               
                                $TrueTemp = 'applicationGateways'
                            }
                        elseif($sub.properties.ipconfigurations.id.Split("/")[7] -eq 'bastionHosts')
                            {               
                                $TrueTemp = 'bastionHosts'
                            }
                        elseif($sub.properties.ipconfigurations.id.Split("/")[7] -eq 'azureFirewalls')
                            {               
                                $TrueTemp = 'azureFirewalls'
                            }                                                                               
                    }
                if($sub.properties.delegations.properties.serviceName -eq 'Microsoft.Databricks/workspaces' -and $null -eq $TrueTemp)
                    {                                
                        $TrueTemp = 'DataBricks'                                                               
                    }
                if($sub.properties.delegations.properties.serviceName -eq 'Microsoft.Web/serverfarms' -and $null -eq $TrueTemp)
                    {                                
                        $TrueTemp = 'App Service'                                                              
                    }                                                                                                                
                if($sub.properties.delegations.properties.serviceName -eq 'Microsoft.ContainerInstance/containerGroups' -and $null -eq $TrueTemp)
                    {                                
                        $TrueTemp = 'Container Instance'                                                                          
                    }
                if($sub.properties.delegations.properties.serviceName -eq 'Microsoft.Netapp/volumes' -and $null -eq $TrueTemp)
                    {                                
                        $TrueTemp = 'NetApp'                                                                                 
                    }
                if($sub.properties.delegations.properties.serviceName -eq 'Microsoft.Kusto/clusters' -and $null -eq $TrueTemp)
                    {                                
                        $TrueTemp = 'Data Explorer Clusters'                                                                                 
                    }

                if([string]::IsNullOrEmpty($TrueTemp))
                    {
                        $AKS = $Script:AKS
                        if($sub.id -in $AKS.properties.agentPoolProfiles.vnetSubnetID)
                            {
                                $TrueTemp = 'AKS'
                            }
                    }
                if([string]::IsNullOrEmpty($TrueTemp))
                    {
                        $Types = @()
                        
                        Foreach($type in $sub.properties.ipconfigurations.id)
                            {
                                if($type.Split("/")[8] -like 'aks-*')
                                    {
                                        $Types += 'AKS'
                                    }
                                if($type.Split("/")[8] -like 'gwhost*')
                                    {
                                        $Types += 'APIM'
                                    }
                                else
                                    {
                                        $Types += $type.Split("/")[7]
                                    }
                            }                
                        $temp = $Types | Group-Object | Sort-Object -Property Count -Descending
                        if($temp)
                            {
                                $TrueTemp = $temp[0].name
                            }
                    }

                if([string]::IsNullOrEmpty($TrueTemp))
                    {
                        if ($sub.id -in ($Script:VMSS).properties.virtualMachineProfile.networkprofile.networkInterfaceConfigurations.properties.ipconfigurations.properties.subnet.id)
                            {
                                $TrueTemp = 'virtualMachineScaleSets'
                            }
                    }

                <#################################################### FIND RESOURCE NAME AND DETAILS #################################################################>

                if($TrueTemp -eq 'networkInterfaces')
                    {
                        $NIcNames = $Script:NIC | Where-Object {$_.properties.ipConfigurations.properties.subnet.id -eq $sub.id}
            
                        if($sub.properties.privateEndpoints.id)
                            {
                                $PrivEndNames = $Script:PrivEnd | Where-Object {$_.properties.networkInterfaces.id -in $NIcNames.id}
                                $TrueTemp = 'privateLinkServices'
                                $RESNames = $PrivEndNames
                            }
                        else
                            {                    
                                $VMNamesAro = $Script:VM | Where-Object {$_.properties.networkprofile.networkInterfaces.id -in $NIcNames.id}
                                if($VMNamesAro.properties.storageprofile.imageReference.offer -like 'aro*')
                                    {
                                        $ARONames = $Script:ARO | Where-Object {$_.properties.masterprofile.subnetId -eq $sub.id -or $_.properties.workerProfiles.subnetId -eq $sub.id}
                                        $TrueTemp = 'Open Shift'
                                        $RESNames = $ARONames
                                    }
                                if($TrueTemp -ne 'Open Shift')
                                    {
                                        $VMs = @()
                                        $VMNames = ($Script:VM).properties.networkprofile.networkInterfaces.id | Where-Object {$_ -in $NIcNames.id}
                                        $VMs = foreach($NIC in $VMNames)
                                            {
                                                $Script:VM| Where-Object {$NIC -in $_.properties.networkprofile.networkInterfaces.id}
                                            }
                                        if($VMs)
                                            {
                                                $TrueTemp = 'Virtual Machine'
                                                $RESNames = $VMs
                                            }
                                    }
                                if($TrueTemp -eq 'networkInterfaces')
                                    {
                                        $TrueTemp = 'Network Interface'
                                        $RESNames = $NIcNames
                                    }
                            }
                    }
                if($TrueTemp -eq 'AKS')
                    {
                        $AKSNames = $Script:AKS | Where-Object {$_.properties.agentPoolProfiles.vnetSubnetID -eq $sub.id}
                        $RESNames = $AKSNames            
                    }
                if($TrueTemp -eq 'Data Explorer Clusters')
                    {
                        $KustoNames = $Script:Kusto | Where-Object {$_.properties.virtualNetworkConfiguration.subnetid -eq $sub.id}
                        $RESNames = $KustoNames
                    }
                if($TrueTemp -eq 'applicationGateways')
                    {
                        $AppGTWNames = $Script:AppGtw| Where-Object {$_.properties.gatewayIPConfigurations.id -in $sub.properties.applicationGatewayIPConfigurations.id}
                        $RESNames = $AppGTWNames
                    }
                if($TrueTemp -eq 'DataBricks')
                    {
                        $DatabriksNames = @()
                        $Databricks = $Script:Databricks
                        $DatabriksNames = Foreach($Data in $Databricks)
                            {                 
                                if($Data.properties.parameters.customVirtualNetworkId.value+'/subnets/'+$Data.properties.parameters.customPrivateSubnetName.value -eq $sub.id -or $Data.properties.parameters.customVirtualNetworkId.value+'/subnets/'+$Data.properties.parameters.custompublicSubnetName.value -eq $sub.id)
                                    {                         
                                        $Data
                                    }
                            }
                        $RESNames = $DatabriksNames     
                    }
                if($TrueTemp -eq 'App Service')
                    {
                        $Apps = $Script:AppWeb | Where-Object {$_.properties.virtualNetworkSubnetId -eq $Sub.id}
                        if($Apps.kind -like 'functionapp*')
                            {
                                $FuntionAppNames = $Apps
                                $TrueTemp = 'Function App'
                                $RESNames = $FuntionAppNames                    
                            }
                        else
                            {
                                $ServiceAppNames = $Apps
                                $RESNames = $Apps
                            }            
                    }                   
                if($TrueTemp -eq 'APIM')
                    {
                        $APIMNames = $Script:APIM | Where-Object {$_.properties.virtualNetworkConfiguration.subnetResourceId -eq $sub.id}
                        $RESNames = $APIMNames
                    }
                if($TrueTemp -eq 'loadBalancers')
                    {
                        $LBNames = $Script:LB | Where-Object {$_.properties.frontendIPConfigurations.id -in $sub.properties.ipconfigurations.id}
                        $RESNames = $LBNames
                    }
                if($TrueTemp -eq 'virtualMachineScaleSets')
                    {
                        $VMSSNames = $Script:VMSS | Where-Object {$_.properties.virtualMachineProfile.networkProfile.networkInterfaceConfigurations.properties.ipconfigurations.properties.subnet.id -eq $sub.id }
                        $RESNames = $VMSSNames
                    }
                if($TrueTemp -eq 'virtualNetworkGateways')
                    {
                        $VPNGTWNames = $Script:AZVGWs | Where-Object {$_.properties.ipconfigurations.properties.subnet.id -eq $sub.id }
                        $RESNames = $VPNGTWNames
                    }
                if($TrueTemp -eq 'bastionHosts')
                    {
                        $BastionNames = $Script:Bastion | Where-Object {$_.properties.ipConfigurations.properties.subnet.id -eq $sub.id }
                        $RESNames = $BastionNames
                    }
                if($TrueTemp -eq 'azureFirewalls')
                    {
                        $AzFWNames = $Script:FW | Where-Object {$_.properties.ipConfigurations.properties.subnet.id -eq $sub.id }
                        $RESNames = $AzFWNames
                    }
                if($TrueTemp -eq 'Container Instance')
                    {
                        $ContainerNames = ''
                        $ContNICs = $Script:NetProf | Where-Object {$_.properties.containerNetworkInterfaceConfigurations.properties.ipconfigurations.properties.subnet.id -eq $sub.id}
                        $ContainerNames = $Script:Container | Where-Object {$_.properties.networkprofile.id -in $ContNICs.id}
                        $RESNames = $ContainerNames
                        if([string]::IsNullOrEmpty($ContainerNames))
                            {
                                $ARONames = $Script:ARO | Where-Object {$_.properties.masterprofile.subnetId -eq $sub.id -or $_.properties.workerProfiles.subnetId -eq $sub.id}
                                $TrueTemp = 'Open Shift'
                                $RESNames = $ARONames
                            }
                    }
                if($TrueTemp -eq 'NetApp')
                    {
                        $NetAppNames = $Script:ANF | Where-Object {$_.properties.subnetId -eq $sub.id }
                        $RESNames = $NetAppNames
                    }               
            
                <###################################################### DROP THE ICONS ######################################################>
            
                switch ($TrueTemp)
                    {
                        'Virtual Machine' {
                                            ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Adding VM: " + $CellID3+'-1') | Out-File -FilePath $LogFile -Append
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
                                                    $XmlTempWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

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
                        'AKS' {
                                            ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Adding AKS: " + $CellID3+'-1') | Out-File -FilePath $LogFile -Append                                         
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
                        'virtualMachineScaleSets' {
                                            ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Adding VMSS: " + $CellID3+'-1') | Out-File -FilePath $LogFile -Append                                                                             
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
                                                    $XmlTempWriter.WriteAttributeString('Instances', [string]$temp[0].Count)
                                                    $XmlTempWriter.WriteAttributeString('VMSS_SKU_Tier', [string]$RESNames.sku.tier)
                                                    $XmlTempWriter.WriteAttributeString('VMSS_Upgrade_Policy', [string]$RESNames.Properties.upgradePolicy.mode)

                                                    $XmlTempWriter.WriteAttributeString('id', ($CellID3+'-1'))

                                                        New-ARIDiagramSubnetIcon $IconVMSS ($SubnetLocation+65) ($Alt0+40) "68" "68" $ContainerID

                                                    $XmlTempWriter.WriteEndElement()
                                                }                                                                        
                                            } 
                        'loadBalancers' {
                                            ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Adding Load Balancer: " + $CellID3+'-1') | Out-File -FilePath $LogFile -Append                                           
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
                        'virtualNetworkGateways' {
                                            ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Adding VPN Gateway: " + $CellID3+'-1') | Out-File -FilePath $LogFile -Append                                                 
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
                        'azureFirewalls' {
                                            ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Adding Azure Firewall: " + $CellID3+'-1') | Out-File -FilePath $LogFile -Append                                             
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
                        'privateLinkServices' {
                                            ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Adding PrivateLink: " + $CellID3+'-1') | Out-File -FilePath $LogFile -Append                                                 
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
                        'applicationGateways' {
                                            ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Adding AppGateway: " + $CellID3+'-1') | Out-File -FilePath $LogFile -Append                                            
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
                        'bastionHosts' {
                                            ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Adding BastionHost: " + $CellID3+'-1') | Out-File -FilePath $LogFile -Append                                               
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
                        'APIM' {
                                            ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Adding APIM: " + $CellID3+'-1') | Out-File -FilePath $LogFile -Append
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
                        'App Service' {
                                            ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Adding App Service: " + $CellID3+'-1') | Out-File -FilePath $LogFile -Append
                                            if($ServiceAppNames)
                                                {
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
                                            }
                        'Function App' {
                                            ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Adding Function App: " + $CellID3+'-1') | Out-File -FilePath $LogFile -Append
                                            if($FuntionAppNames)
                                                {                                                
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
                                            }
                        'DataBricks' {
                                            ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Adding Databricks: " + $CellID3+'-1') | Out-File -FilePath $LogFile -Append
                                            if($DatabriksNames)
                                                {                                              
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
                                            }
                        'Open Shift' {
                                            ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Adding OpenShift: " + $CellID3+'-1') | Out-File -FilePath $LogFile -Append
                                            if($ARONames)
                                                {
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
                                            }
                        'Container Instance'  {
                                                ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Adding Container Instance: " + $CellID3+'-1') | Out-File -FilePath $LogFile -Append
                                                if($ContainerNames)
                                                    {                                                                                                
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
                                            }
                        'NetApp' {          
                                            ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Adding ANF: " + $CellID3+'-1') | Out-File -FilePath $LogFile -Append
                                            if($NetAppNames)
                                                {                                          
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
                                                            $XmlTempWriter.WriteAttributeString('NetApp_Volume_Name', [string]$ResName.name)

                                                            $XmlTempWriter.WriteAttributeString('id', ($CellID3+'-1'))

                                                                New-ARIDiagramSubnetIcon $IconNetApp ($SubnetLocation+65) ($Alt0+40) "65" "52" $ContainerID

                                                            $XmlTempWriter.WriteEndElement()
                                                        }
                                                }                                                                   
                                            }
                        'Data Explorer Clusters' {
                                                    ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Adding Data Explorer Cluster: " + $CellID3+'-1') | Out-File -FilePath $LogFile -Append
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
                        'Network Interface' {
                                            ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Adding NIC: " + $CellID3+'-1') | Out-File -FilePath $LogFile -Append
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
                                                    $XmlTempWriter.WriteAttributeString($Attr1, [string]$ResName.name)

                                                    $XmlTempWriter.WriteAttributeString('id', ($CellID3+'-1'))

                                                        New-ARIDiagramSubnetIcon $IconNIC ($SubnetLocation+65) ($Alt0+40) "68" "60" $ContainerID

                                                    $XmlTempWriter.WriteEndElement()

                                                }                                                                
                                            }                                                                                                                                                                            
                        '' {('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Not Adding ProcType: " + 'Blank Resource Type Name') | Out-File -FilePath $LogFile -Append}
                        default {('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Not Adding ProcType: $TrueTemp - " + 'Missing ResourceType in the list') | Out-File -FilePath $LogFile -Append}
                    }
                    if($sub.properties.networkSecurityGroup.id)
                        {
                            $NSG = $sub.properties.networkSecurityGroup.id.split('/')[8]
                            $XmlTempWriter.WriteStartElement('object')            
                            $XmlTempWriter.WriteAttributeString('label', '')                                        
                            $XmlTempWriter.WriteAttributeString('Network_Security_Group', [string]$NSG)
                            $XmlTempWriter.WriteAttributeString('id', ($CellID3+'-2'))

                                ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Adding NSG: " + $CellID3+'-2') | Out-File -FilePath $LogFile -Append
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

                                ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Adding UDR: " + $CellID3+'-3') | Out-File -FilePath $LogFile -Append
                                New-ARIDiagramSubnetIcon $IconUDR ($SubnetLocation+15) ($Alt0+15) "30.97" "30" $ContainerID

                            $XmlTempWriter.WriteEndElement()

                        }
                    if($sub.properties.ipconfigurations.id)
                        {
                            Foreach($SubIPs in $sub.properties.ipconfigurations)
                                {
                                    $Script:VNETPIP += $Script:CleanPIPs | Where-Object {$_.properties.ipConfiguration.id -eq $SubIPs.id}
                                }
                        }
            }

        ######################################################### ICON #######################################################

        Function New-ARIDiagramSubnetIcon {    
            Param($Style,$x,$y,$w,$h,$p)
            
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
                                    $Script:VNETPIP = @()
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
                                        ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Adding Subnet ($LoggingSubnetName): " + $CellID2+'-'+$IDNum) | Out-File -FilePath $LogFile -Append

                                        $XmlTempWriter.WriteStartElement('object')            
                                        $XmlTempWriter.WriteAttributeString('label', ("`n" + "`n" + "`n" + "`n" + "`n" + "`n" +[string]$sub.Name + "`n" + [string]$sub.properties.addressPrefix))
                                        $XmlTempWriter.WriteAttributeString('id', ($CellID2+'-'+$IDNum))

                                            New-ARIDiagramSubnetIcon "rounded=0;whiteSpace=wrap;fontSize=16;html=1;sketch=0;fontFamily=Helvetica;" $SubnetLocation0 $Alt1 "200" "200" $ContainerID

                                        $XmlTempWriter.WriteEndElement()      

                                            Set-ARIDiagramSubnetComponent $sub $SubnetLocation0 $Alt1 $ContainerID $LogFile

                                        $SubnetLocation = $SubnetLocation + 210
                                        $SubnetLocation0 = $SubnetLocation0 + 210
                                        $SubC ++
                                    }

                                }
                            Else
                                {
                                    $sizeL = (($sizeL * 210) + 30)
                                    $SubnetLocation0 = 20
                                    $Script:VNETPIP = @()
                                    foreach($Sub in $VNET.properties.subnets)
                                    {
                                        $IDNum++
                                        $LoggingSubnetName = $sub.Name
                                        ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Adding Subnet ($LoggingSubnetName): " + $CellID2+'-'+$IDNum) | Out-File -FilePath $LogFile -Append


                                        $XmlTempWriter.WriteStartElement('object')            
                                        $XmlTempWriter.WriteAttributeString('label', ("`n" + "`n" + "`n" + "`n" + "`n" + "`n" +[string]$sub.Name + "`n" + [string]$sub.properties.addressPrefix))
                                        $XmlTempWriter.WriteAttributeString('id', ($CellID2+'-'+$IDNum))

                                            New-ARIDiagramSubnetIcon "rounded=0;whiteSpace=wrap;fontSize=16;html=1;sketch=0;fontFamily=Helvetica;" $SubnetLocation0 40 "200" "200" $ContainerID

                                        $XmlTempWriter.WriteEndElement()  

                                            Set-ARIDiagramSubnetComponent $sub $SubnetLocation0 40 $ContainerID $LogFile

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
            ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Error: ' + $_.Exception.Message) | Out-File -FilePath $LogFile -Append 
        }
}