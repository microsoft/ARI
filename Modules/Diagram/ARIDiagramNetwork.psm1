<#
.Synopsis
Network Module for Draw.io Diagram

.DESCRIPTION
This module is use for the Network topology in the Draw.io Diagram.

.Link
https://github.com/microsoft/ARI/Modules/Extras/ARIDiagramNetwork.psm1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 4.0.1
First Release Date: 15th Oct, 2024
Authors: Claudio Merola

#>
Function Invoke-ARIDiagramNetwork {
    Param($Subscriptions,$Resources,$Advisories,$DiagramCache,$FullEnvironment,$DDFile,$XMLFiles,$LogFile)

    ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Starting Network Diagram Job...') | Out-File -FilePath $LogFile -Append 

    Start-Job -Name 'Diagram_NetworkTopology' -ScriptBlock {

        Import-Module AzureResourceInventory

        $Script:jobs = @()
        $Script:jobs2 = @()
        $Script:Subscriptions = $($args[0])
        $Script:Resources = $($args[1])
        $Script:Advisories = $($args[2])
        $Script:DiagramCache = $($args[3])
        $Script:FullEnvironment = $($args[4])
        $Script:DDFile  = $($args[5])
        $Script:XMLFiles  = $($args[6])
        $Script:Logfile = $($args[7])

        Function Icon {    
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
        
        Function VNETContainer {
            Param($x,$y,$w,$h,$title)
                $Script:ContID = (-join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})+'-'+1)
        
                $Script:XmlWriter.WriteStartElement('mxCell')
                $Script:XmlWriter.WriteAttributeString('id', $Script:ContID)
                $Script:XmlWriter.WriteAttributeString('value', "$title")
                $Script:XmlWriter.WriteAttributeString('style', "swimlane;whiteSpace=wrap;html=1;fillColor=#d5e8d4;strokeColor=#82b366;swimlaneFillColor=#D5E8D4;rounded=1;")
                $Script:XmlWriter.WriteAttributeString('vertex', "1")
                $Script:XmlWriter.WriteAttributeString('parent', "1")
            
                    $Script:XmlWriter.WriteStartElement('mxGeometry')
                    $Script:XmlWriter.WriteAttributeString('x', $x)
                    $Script:XmlWriter.WriteAttributeString('y', $y)
                    $Script:XmlWriter.WriteAttributeString('width', $w)
                    $Script:XmlWriter.WriteAttributeString('height', $h)
                    $Script:XmlWriter.WriteAttributeString('as', "geometry")
                    $Script:XmlWriter.WriteEndElement()
                
                $Script:XmlWriter.WriteEndElement()
        }
        
        Function HubContainer {
            Param($x,$y,$w,$h,$title)
                $Script:ContID = (-join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})+'-'+1)
        
                $Script:XmlWriter.WriteStartElement('mxCell')
                $Script:XmlWriter.WriteAttributeString('id', $Script:ContID)
                $Script:XmlWriter.WriteAttributeString('value', "$title")
                $Script:XmlWriter.WriteAttributeString('style', "swimlane;whiteSpace=wrap;html=1;fillColor=#dae8fc;strokeColor=#6c8ebf;rounded=1;swimlaneFillColor=#DAE8FC;")
                $Script:XmlWriter.WriteAttributeString('vertex', "1")
                $Script:XmlWriter.WriteAttributeString('parent', "1")
            
                    $Script:XmlWriter.WriteStartElement('mxGeometry')
                    $Script:XmlWriter.WriteAttributeString('x', $x)
                    $Script:XmlWriter.WriteAttributeString('y', $y)
                    $Script:XmlWriter.WriteAttributeString('width', $w)
                    $Script:XmlWriter.WriteAttributeString('height', $h)
                    $Script:XmlWriter.WriteAttributeString('as', "geometry")
                    $Script:XmlWriter.WriteEndElement()
                
                $Script:XmlWriter.WriteEndElement()
        }

        Function BrokenContainer {
            Param($x,$y,$w,$h,$title)
                $Script:ContID = (-join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})+'-'+1)
        
                $Script:XmlWriter.WriteStartElement('mxCell')
                $Script:XmlWriter.WriteAttributeString('id', $Script:ContID)
                $Script:XmlWriter.WriteAttributeString('value', "$title")
                $Script:XmlWriter.WriteAttributeString('style', "swimlane;whiteSpace=wrap;html=1;fillColor=#fad9d5;strokeColor=#ae4132;swimlaneFillColor=#FAD9D5;")
                $Script:XmlWriter.WriteAttributeString('vertex', "1")
                $Script:XmlWriter.WriteAttributeString('parent', "1")
            
                    $Script:XmlWriter.WriteStartElement('mxGeometry')
                    $Script:XmlWriter.WriteAttributeString('x', $x)
                    $Script:XmlWriter.WriteAttributeString('y', $y)
                    $Script:XmlWriter.WriteAttributeString('width', $w)
                    $Script:XmlWriter.WriteAttributeString('height', $h)
                    $Script:XmlWriter.WriteAttributeString('as', "geometry")
                    $Script:XmlWriter.WriteEndElement()
                
                $Script:XmlWriter.WriteEndElement()
        }

        Function Connect {
        Param($Source,$Target,$Parent)
        
            if($Parent){$Parent = $Parent}else{$Parent = 1}
        
            $Script:XmlWriter.WriteStartElement('mxCell')
            $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
            $Script:XmlWriter.WriteAttributeString('style', "edgeStyle=none;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;endArrow=none;endFill=0;")
            $Script:XmlWriter.WriteAttributeString('edge', "1")
            $Script:XmlWriter.WriteAttributeString('vertex', "1")
            $Script:XmlWriter.WriteAttributeString('parent', $Parent)
            $Script:XmlWriter.WriteAttributeString('source', $Source)
            $Script:XmlWriter.WriteAttributeString('target', $Target)
        
                $Script:XmlWriter.WriteStartElement('mxGeometry')
                $Script:XmlWriter.WriteAttributeString('relative', "1")
                $Script:XmlWriter.WriteAttributeString('as', "geometry")
                $Script:XmlWriter.WriteEndElement()
            
            $Script:XmlWriter.WriteEndElement()
        
        }
        
        <# Function to create the Visio document and import each stencil #>
        Function Stensils {
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
        
        <# Function to begin OnPrem environment drawing. Will begin by Local network Gateway, then Express Route.#>
        Function OnPremNet {
            $Script:VNETHistory = @()
            $Script:RoutsW = $AZVNETs | Select-Object -Property Name, @{N="Subnets";E={$_.properties.subnets.properties.addressPrefix.count}} | Sort-Object -Property Subnets -Descending
        
            $Script:Alt = 0
        
            ##################################### Local Network Gateway #############################################
        
            foreach($GTW in $AZLGWs)
            {
                if($GTW.properties.provisioningState -ne 'Succeeded')
                {
                    $Script:XmlWriter.WriteStartElement('object')            
                    $Script:XmlWriter.WriteAttributeString('label', '')
                    $Script:XmlWriter.WriteAttributeString('Status', 'This Local Network Gateway has Errors')
                    $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
        
                        Icon $IconError 40 ($Script:Alt+25) "25" "25" 1
        
                    $Script:XmlWriter.WriteEndElement()
                }
            
                $Con1 = $AZCONs | Where-Object {$_.properties.localNetworkGateway2.id -eq $GTW.id}
                
                if(!$Con1 -and $GTW.properties.provisioningState -eq 'Succeeded')
                {
                    $Script:XmlWriter.WriteStartElement('object')            
                    $Script:XmlWriter.WriteAttributeString('label', '')
                    $Script:XmlWriter.WriteAttributeString('Status', 'No Connections were found in this Local Network Gateway')
                    $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
        
                        Icon $SymInfo 40 ($Script:Alt+30) "20" "20" 1
        
                    $Script:XmlWriter.WriteEndElement()
                }
                
                $Name = $GTW.name
                $IP = $GTW.properties.gatewayIpAddress
        
                $Script:XmlWriter.WriteStartElement('object')            
                $Script:XmlWriter.WriteAttributeString('label', ("`n" + [string]$Name + "`n" + [string]$IP))
                $Script:XmlWriter.WriteAttributeString('Local_Address_Space', [string]$GTW.properties.localNetworkAddressSpace.addressPrefixes)
                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
        
                    Icon $IconTraffic 50 $Script:Alt "67" "40" 1
        
                $Script:XmlWriter.WriteEndElement()                  
        
                $Script:GTWAddress = ($Script:CellID+'-'+($Script:IDNum-1))
                $Script:ConnSourceResource = 'GTW'

                OnPrem $Con1

                $Script:Alt = $Script:Alt + 150
            }

            ##################################### ERS #############################################

            Foreach($ERs in $AZEXPROUTEs)
            {
                if($ERs.properties.provisioningState -ne 'Succeeded')
                {
                    $Script:XmlWriter.WriteStartElement('object')            
                    $Script:XmlWriter.WriteAttributeString('label', '')
                    $Script:XmlWriter.WriteAttributeString('Status', 'This Express Route has Errors')
                    $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                        Icon $IconError 51 ($Script:Alt+25) "25" "25" 1

                    $Script:XmlWriter.WriteEndElement()
                }       

                $Con1 = $AZCONs | Where-Object {$_.properties.peer.id -eq $ERs.id}
                
                if(!$Con1 -and $ERs.properties.circuitProvisioningState -eq 'Enabled')
                {
                    $Script:XmlWriter.WriteStartElement('object')            
                    $Script:XmlWriter.WriteAttributeString('label', '')
                    $Script:XmlWriter.WriteAttributeString('Status', 'No Connections were found in this Express Route')
                    $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                        Icon $SymInfo 51 ($Script:Alt+30) "20" "20" 1

                    $Script:XmlWriter.WriteEndElement()
                }

                $Name = $ERs.name

                $Script:XmlWriter.WriteStartElement('object')            
                $Script:XmlWriter.WriteAttributeString('label', ("`n" +[string]$Name))
                $Script:XmlWriter.WriteAttributeString('Provider', [string]$ERs.properties.serviceProviderProperties.serviceProviderName)
                $Script:XmlWriter.WriteAttributeString('Peering_location', [string]$ERs.properties.serviceProviderProperties.peeringLocation)
                $Script:XmlWriter.WriteAttributeString('Bandwidth', [string]$ERs.properties.serviceProviderProperties.bandwidthInMbps)
                $Script:XmlWriter.WriteAttributeString('SKU', [string]$ERs.sku.tier)
                $Script:XmlWriter.WriteAttributeString('Billing_model', $ERs.sku.family)
                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                    Icon $IconExpressRoute "61.5" $Script:Alt "44" "40" 1

                $Script:XmlWriter.WriteEndElement()

                $Script:ERAddress = ($Script:CellID+'-'+($Script:IDNum-1))
                $Script:ConnSourceResource = 'ER'

                OnPrem $Con1

                $Script:Alt = $Script:Alt + 150

            }

            ##################################### VWAN VPNSITES #############################################

            foreach($GTW in $AZVPNSITES)
            {
                if($GTW.properties.provisioningState -ne 'Succeeded')
                {
                    $Script:XmlWriter.WriteStartElement('object')            
                    $Script:XmlWriter.WriteAttributeString('label', '')
                    $Script:XmlWriter.WriteAttributeString('Status', 'This VPN Site has Errors')
                    $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                        Icon $IconError 40 ($Script:Alt+25) "25" "25" 1

                    $Script:XmlWriter.WriteEndElement()
                }

                $wan1 = $AZVWAN | Where-Object {$_.properties.vpnSites.id -eq $GTW.id}

                if(!$wan1 -and $GTW.properties.provisioningState -eq 'Succeeded')
                {
                    $Script:XmlWriter.WriteStartElement('object')            
                    $Script:XmlWriter.WriteAttributeString('label', '')
                    $Script:XmlWriter.WriteAttributeString('Status', 'No vWANs were found in this VPN Site')
                    $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                        Icon $SymInfo 40 ($Script:Alt+30) "20" "20" 1

                    $Script:XmlWriter.WriteEndElement()
                }

                $Name = $GTW.name

                $Script:XmlWriter.WriteStartElement('object')            
                $Script:XmlWriter.WriteAttributeString('label', ("`n" + [string]$Name))
                $Script:XmlWriter.WriteAttributeString('Address_Space', [string]$GTW.properties.addressSpace.addressPrefixes)
                $Script:XmlWriter.WriteAttributeString('Link_Speed_In_Mbps', [string]$GTW.properties.deviceProperties.linkSpeedInMbps)
                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                    Icon $IconNAT 50 $Script:Alt "67" "40" 1

                $Script:XmlWriter.WriteEndElement()            
                #$tt = $tt + 200        

                vWan $wan1

                $Script:Alt = $Script:Alt + 150
            }
        
            ##################################### VWAN ERs #############################################
        
            foreach($GTW in $AZVERs)
            {
                if($GTW.properties.provisioningState -ne 'Succeeded')
                {
                    $Script:XmlWriter.WriteStartElement('object')            
                    $Script:XmlWriter.WriteAttributeString('label', '')
                    $Script:XmlWriter.WriteAttributeString('Status', 'This Express Route Circuit has Errors')
                    $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                        Icon $IconError 40 ($Script:Alt+25) "25" "25" 1

                    $Script:XmlWriter.WriteEndElement()
                }

                $wan1 = $AZVWAN | Where-Object {$_.properties.vpnSites.id -eq $GTW.id}

                if(!$wan1 -and $GTW.properties.provisioningState -eq 'Succeeded')
                {
                    $Script:XmlWriter.WriteStartElement('object')            
                    $Script:XmlWriter.WriteAttributeString('label', '')
                    $Script:XmlWriter.WriteAttributeString('Status', 'No vWANs were found in this Express Route Circuit')
                    $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                        Icon $SymInfo 40 ($Script:Alt+30) "20" "20" 1

                    $Script:XmlWriter.WriteEndElement()
                }

                $Name = $GTW.name

                $Script:XmlWriter.WriteStartElement('object')            
                $Script:XmlWriter.WriteAttributeString('label', ("`n" + [string]$Name))
                $Script:XmlWriter.WriteAttributeString('Address_Space', [string]$GTW.properties.addressSpace.addressPrefixes)
                $Script:XmlWriter.WriteAttributeString('LinkSpeed_In_Mbps', [string]$GTW.properties.deviceProperties.linkSpeedInMbps)
                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                    Icon $IconNAT 50 $Script:Alt "67" "40" 1

                $Script:XmlWriter.WriteEndElement()            
                #$tt = $tt + 200        

                vWan $wan1

                $Script:Alt = $Script:Alt + 150
            }

            ##################################### LABELs #############################################

            if(!$Script:FullEnvironment)
                {

                    $Script:XmlWriter.WriteStartElement('object')            
                    $Script:XmlWriter.WriteAttributeString('label', '')
                    $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                        Icon $Ret -520 -100 "500" ($Script:Alt + 100) 1

                    $Script:XmlWriter.WriteEndElement()

                    $Script:XmlWriter.WriteStartElement('object')            
                    $Script:XmlWriter.WriteAttributeString('label', ('On Premises'+ "`n" +'Environment'))
                    $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                        Icon $OnPrem -351 (($Script:Alt + 100)/2) "168.2" "290" 1

                    $Script:XmlWriter.WriteEndElement()  

                    label

                        Icon $Signature -520 ($Script:Alt + 100) "27.5" "22" 1

                    $Script:XmlWriter.WriteEndElement()  
                }

        }

        Function OnPrem {
        Param($Con1)
        foreach ($Con2 in $Con1)
                {
                    if([string]::IsNullOrEmpty($Script:vnetLoc))
                    {
                        $Script:vnetLoc = 700
                    }
                    $VGT = $AZVGWs | Where-Object {$_.id -eq $Con2.properties.virtualNetworkGateway1.id}
                    $VGTPIP = $PIPs | Where-Object {$_.properties.ipConfiguration.id -eq $VGT.properties.ipConfigurations.id}

                    $Name2 = $Con2.Name

                    $Script:XmlWriter.WriteStartElement('object')            
                    $Script:XmlWriter.WriteAttributeString('label', [string]$Name2)
                    $Script:XmlWriter.WriteAttributeString('Connection_Type', [string]$Con2.properties.connectionType)
                    $Script:XmlWriter.WriteAttributeString('Use_Azure_Private_IP_Address', [string]$Con2.properties.useLocalAzureIpAddress)
                    $Script:XmlWriter.WriteAttributeString('Routing_Weight', [string]$Con2.properties.routingWeight)
                    $Script:XmlWriter.WriteAttributeString('Connection_Protocol', [string]$Con2.properties.connectionProtocol)
                    $Script:Source = ($Script:CellID+'-'+($Script:IDNum-1))
                    $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                        Icon $IconConnections 250 $Script:Alt "40" "40" 1

                    $Script:XmlWriter.WriteEndElement()

                    $Script:Target = ($Script:CellID+'-'+($Script:IDNum-1))

                    if($Script:ConnSourceResource -eq 'ER')
                        {
                            Connect $Script:ERAddress $Script:Target
                        }
                    elseif($Script:ConnSourceResource -eq 'GTW')
                        {
                            Connect $Script:GTWAddress $Script:Target
                        }

                    $Script:Source = $Script:Target

                    $Script:XmlWriter.WriteStartElement('object')            
                    $Script:XmlWriter.WriteAttributeString('label', ("`n" +[string]$VGT.Name + "`n" + [string]$VGTPIP.properties.ipAddress))
                    $Script:XmlWriter.WriteAttributeString('VPN_Type', [string]$VGT.properties.vpnType)
                    $Script:XmlWriter.WriteAttributeString('Generation', [string]$VGT.properties.vpnGatewayGeneration )
                    $Script:XmlWriter.WriteAttributeString('SKU', [string]$VGT.properties.sku.name)
                    $Script:XmlWriter.WriteAttributeString('Gateway_Type', [string]$VGT.properties.gatewayType)
                    $Script:XmlWriter.WriteAttributeString('Active_active_mode', [string]$VGT.properties.activeActive)
                    $Script:XmlWriter.WriteAttributeString('Gateway_Private_IPs', [string]$VGT.properties.enablePrivateIpAddress)
                    $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                        Icon $IconVGW2 425 ($Script:Alt-4) "31.34" "48" 1

                    $Script:XmlWriter.WriteEndElement()

                    $Script:Target = ($Script:CellID+'-'+($Script:IDNum-1))

                        Connect $Script:Source $Script:Target

                    $Script:Source = $Script:Target

                    foreach($AZVNETs2 in $AZVNETs)
                    {
                        foreach($VNETTEMP in $AZVNETs2.properties.subnets.properties.ipconfigurations.id)
                        {
                            $VV4 = $VNETTEMP.Split("/")
                            $VNETTEMP1 = ($VV4[0] + '/' + $VV4[1] + '/' + $VV4[2] + '/' + $VV4[3] + '/' + $VV4[4] + '/' + $VV4[5] + '/' + $VV4[6] + '/' + $VV4[7]+ '/' + $VV4[8])
                            if($VNETTEMP1 -eq $VGT.id)
                            {
                                $Script:VNET2 = $AZVNETs2

                                $Script:Alt0 = $Script:Alt
                                if($VNET2.id -notin $VNETHistory.vnet)
                                    {
                                        if($VNET2.properties.addressSpace.addressPrefixes.count -ge 10)
                                        {
                                            $AddSpace = ($VNET2.properties.addressSpace.addressPrefixes | Select-Object -First 20 |  ForEach-Object {$_ + "`n"} ) + "`n" +'...'
                                        }Else{
                                            $AddSpace = ($VNET2.properties.addressSpace.addressPrefixes | ForEach-Object {$_ + "`n"})
                                        }

                                        $Script:XmlWriter.WriteStartElement('object')            
                                        $Script:XmlWriter.WriteAttributeString('label', ([string]$VNET2.Name + "`n" + $AddSpace))
                                        if($VNET2.properties.dhcpoptions.dnsServers)
                                            {
                                                $Script:XmlWriter.WriteAttributeString('Custom_DNS_Servers', [string]$VNET2.properties.dhcpoptions.dnsServers)
                                                $Script:XmlWriter.WriteAttributeString('DDOS_Protection', [string]$VNET2.properties.enableDdosProtection)
                                            }
                                        else
                                            {
                                                $Script:XmlWriter.WriteAttributeString('DDOS_Protection', [string]$VNET2.properties.enableDdosProtection)
                                            }
                                        $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                            Icon $IconVNET 600 $Script:Alt "65" "39" 1

                                        $Script:XmlWriter.WriteEndElement()      

                                        $Script:VNETDrawID = ($Script:CellID+'-'+($Script:IDNum-1))

                                        $Script:Target = ($Script:CellID+'-'+($Script:IDNum-1))

                                            Connect $Script:Source $Script:Target

                                        if($VNET2.properties.enableDdosProtection -eq $true)
                                        {
                                            $Script:XmlWriter.WriteStartElement('object')            
                                            $Script:XmlWriter.WriteAttributeString('label', '')
                                            $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                                Icon $IconDDOS 580 ($Script:Alt + 15) "23" "28" 1

                                            $Script:XmlWriter.WriteEndElement()
                                        }

                                        $Script:Source = $Script:Target

                                            VNETCreator $Script:VNET2

                                        if($VNET2.properties.virtualNetworkPeerings.properties.remoteVirtualNetwork.id)
                                            {
                                                PeerCreator $Script:VNET2
                                            }

                                            $tmp =@{
                                                'VNETid' = $Script:VNETDrawID;
                                                'VNET' = $AZVNETs2.id
                                            }    
                                            $Script:VNETHistory += $tmp 

                                    }
                                else
                                    {     

                                        $VNETDID = $VNETHistory | Where-Object {$_.VNET -eq $AZVNETs2.id}

                                        Connect $Script:Source $VNETDID.VNETid 

                                    }

                                }
                        }

                    }

                    if($Con1.count -gt 1)
                    {
                        $Script:Alt = $Script:Alt + 250
                    }
                }
        
        }
        
        Function vWan {
        Param($wan1)
        
            if([string]::IsNullOrEmpty($Script:vnetLoc))
            {
                $Script:vnetLoc = 700
            }  

            $Name2 = $wan1.Name

            $Script:XmlWriter.WriteStartElement('object')            
            $Script:XmlWriter.WriteAttributeString('label', [string]$Name2)
            $Script:XmlWriter.WriteAttributeString('allow_VnetToVnet_Traffic', [string]$wan1.properties.allowVnetToVnetTraffic)
            $Script:XmlWriter.WriteAttributeString('allow_BranchToBranch_Traffic', [string]$wan1.properties.allowBranchToBranchTraffic)
            $Script:Source = ($Script:CellID+'-'+($Script:IDNum-1))
            $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                Icon $IconVWAN 250 $Script:Alt "40" "40" 1

            $Script:XmlWriter.WriteEndElement()

            $Script:Target = ($Script:CellID+'-'+($Script:IDNum-1))

                Connect $Script:Source $Script:Target

            $Script:Source1 = $Script:Target

            foreach ($Con2 in $wan1.properties.virtualHubs.id)
                {
                    $VHUB = $AZVHUB | Where-Object {$_.id -eq $Con2}           

                    $Script:XmlWriter.WriteStartElement('object')            
                    $Script:XmlWriter.WriteAttributeString('label', ("`n" +[string]$VHUB.Name))
                    $Script:XmlWriter.WriteAttributeString('Address_Prefix', [string]$VHUB.properties.addressPrefix)
                    $Script:XmlWriter.WriteAttributeString('Preferred_Routing_Gateway', [string]$VHUB.properties.preferredRoutingGateway)
                    $Script:XmlWriter.WriteAttributeString('Virtual_Router_Asn', [string]$VHUB.properties.virtualRouterAsn)
                    $Script:XmlWriter.WriteAttributeString('Allow_BranchToBranch_Traffic', [string]$VHUB.properties.allowBranchToBranchTraffic)
                    $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                        Icon $IconVWAN 425 $Script:Alt "40" "40" 1

                    $Script:XmlWriter.WriteEndElement()

                    $Script:Target = ($Script:CellID+'-'+($Script:IDNum-1))

                        Connect $Script:Source1 $Script:Target

                    $Script:Source = $Script:Target

                    foreach($AZVNETs2 in $AZVNETs)
                    {
                        foreach($VNETTEMP in $AZVNETs2.properties.virtualNetworkPeerings.properties.remoteVirtualNetwork.id)
                        {
                            $VV4 = $VNETTEMP.Split("/")
                            $VNETTEMP1 = $VV4[8]
                            if($VNETTEMP1 -like ('HV_'+$VHUB.name+'_*'))
                            {
                                $Script:VNET2 = $AZVNETs2

                                $Script:Alt0 = $Script:Alt
                                if($VNET2.id -notin $VNETHistory.vnet)
                                    {
                                        if($VNET2.properties.addressSpace.addressPrefixes.count -ge 10)
                                        {
                                            $AddSpace = ($VNET2.properties.addressSpace.addressPrefixes | Select-Object -First 20 |  ForEach-Object {$_ + "`n"} ) + "`n" +'...'
                                        }Else{
                                            $AddSpace = ($VNET2.properties.addressSpace.addressPrefixes | ForEach-Object {$_ + "`n"})
                                        }

                                        $Script:XmlWriter.WriteStartElement('object')            
                                        $Script:XmlWriter.WriteAttributeString('label', ([string]$VNET2.Name + "`n" + $AddSpace))
                                        if($VNET2.properties.dhcpoptions.dnsServers)
                                            {
                                                $Script:XmlWriter.WriteAttributeString('Custom_DNS_Servers', [string]$VNET2.properties.dhcpoptions.dnsServers)
                                                $Script:XmlWriter.WriteAttributeString('DDOS_Protection', [string]$VNET2.properties.enableDdosProtection)
                                            }
                                        else
                                            {
                                                $Script:XmlWriter.WriteAttributeString('DDOS_Protection', [string]$VNET2.properties.enableDdosProtection)
                                            }
                                        $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                            Icon $IconVNET 600 $Script:Alt "65" "39" 1

                                        $Script:XmlWriter.WriteEndElement()      
                                        
                                        $Script:VNETDrawID = ($Script:CellID+'-'+($Script:IDNum-1))
                                                            
                                        $Script:Target = ($Script:CellID+'-'+($Script:IDNum-1))

                                            Connect $Script:Source $Script:Target

                                        if($VNET2.properties.enableDdosProtection -eq $true)
                                        {
                                            $Script:XmlWriter.WriteStartElement('object')            
                                            $Script:XmlWriter.WriteAttributeString('label', '')
                                            $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                                Icon $IconDDOS 580 ($Script:Alt + 15) "23" "28" 1

                                            $Script:XmlWriter.WriteEndElement()
                                        }

                                            VNETCreator $Script:VNET2

                                        if($VNET2.properties.virtualNetworkPeerings.properties.remoteVirtualNetwork.id -and $VNET2.properties.virtualNetworkPeerings.properties.remoteVirtualNetwork.id -notlike ('*/HV_'+$VHUB.name+'_*'))
                                            {
                                                PeerCreator $Script:VNET2
                                            }

                                            $tmp =@{
                                                'VNETid' = $Script:VNETDrawID;
                                                'VNET' = $AZVNETs2.id
                                            }    
                                            $Script:VNETHistory += $tmp 
                                            
                                    }
                                else
                                    {     
                                        $VNETDID = $VNETHistory | Where-Object {$_.VNET -eq $AZVNETs2.id}

                                        Connect $Script:Source $VNETDID.VNETid 
                                    }
                                }
                        }
                    }
                    
                    if($Con1.count -gt 1)
                    {
                        $Script:Alt = $Script:Alt + 250
                    }
                }
        
        }
        
        <# Function for Cloud Only Environments #>
        Function CloudOnly {
        $Script:RoutsW = $AZVNETs | Select-Object -Property Name, @{N="Subnets";E={$_.properties.subnets.properties.addressPrefix.count}} | Sort-Object -Property Subnets -Descending
        
        $Script:VNETHistory = @()
        if([string]::IsNullOrEmpty($Script:vnetLoc))
            {
                $Script:vnetLoc = 700
            }
        $Script:Alt = 2
        
            foreach($AZVNETs2 in $AZVNETs)
                {             
                    $Script:VNET2 = $AZVNETs2
        
                    $Script:Alt0 = $Script:Alt
                    if($VNET2.id -notin $VNETHistory.vnet)
                        {
        
                            if($VNET2.properties.addressSpace.addressPrefixes.count -ge 10)
                            {
                                $AddSpace = ($VNET2.properties.addressSpace.addressPrefixes | Select-Object -First 20 |  ForEach-Object {$_ + "`n"} ) + "`n" +'...'
                            }Else{
                                $AddSpace = ($VNET2.properties.addressSpace.addressPrefixes | ForEach-Object {$_ + "`n"})
                            }
        
                            $Script:XmlWriter.WriteStartElement('object')            
                            $Script:XmlWriter.WriteAttributeString('label', ([string]$VNET2.Name + "`n" + $AddSpace))
                            if($VNET2.properties.dhcpoptions.dnsServers)
                                {
                                    $Script:XmlWriter.WriteAttributeString('Custom_DNS_Servers', [string]$VNET2.properties.dhcpoptions.dnsServers)
                                    $Script:XmlWriter.WriteAttributeString('DDOS_Protection', [string]$VNET2.properties.enableDdosProtection)
                                }
                            else
                                {
                                    $Script:XmlWriter.WriteAttributeString('DDOS_Protection', [string]$VNET2.properties.enableDdosProtection)
                                }
                            $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
        
                                Icon $IconVNET 600 $Script:Alt "65" "39" 1
        
                            $Script:XmlWriter.WriteEndElement()      
                            
                            $Script:VNETDrawID = ($Script:CellID+'-'+($Script:IDNum-1))
                                                
                            $Script:Target = ($Script:CellID+'-'+($Script:IDNum-1))
                
                            if($VNET2.properties.enableDdosProtection -eq $true)
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', '')
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
                    
                                    Icon $IconDDOS 580 ($Script:Alt + 15) "23" "28" 1
                    
                                $Script:XmlWriter.WriteEndElement()
                            }
        
                            $Script:Source = $Script:Target
        
                                VNETCreator $Script:VNET2
        
                            if($VNET2.properties.virtualNetworkPeerings.properties.remoteVirtualNetwork.id)
                                {
                                    PeerCreator $Script:VNET2
                                }
        
                                $tmp =@{
                                    'VNETid' = $Script:VNETDrawID;
                                    'VNET' = $AZVNETs2.id
                                }    
                                $Script:VNETHistory += $tmp 
                                            
                        }
                    }
        
                    $Script:XmlWriter.WriteStartElement('object')            
                    $Script:XmlWriter.WriteAttributeString('label', '')
                    $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
        
                        Icon $Ret -520 -100 "500" ($Script:Alt + 100) 1
        
                    $Script:XmlWriter.WriteEndElement()
        
                    $Script:XmlWriter.WriteStartElement('object')            
                    $Script:XmlWriter.WriteAttributeString('label', ('Cloud Only'+ "`n" +'Environment'))
                    $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
        
                        Icon $Script:CloudOnly -460 (($Script:Alt + 100)/2) "380" "275" 1
        
                    $Script:XmlWriter.WriteEndElement()  
        
                    label
        
                        Icon $Signature -520 ($Script:Alt + 100) "27.5" "22" 1
        
                    $Script:XmlWriter.WriteEndElement()  
        
        }
        
        Function FullEnvironment {
            foreach($AZVNETs2 in $AZVNETs)
                {             
                    $Script:VNET2 = $AZVNETs2
        
                    if($VNET2.id -notin $VNETHistory.vnet)
                        {
                            if($VNET2.properties.addressSpace.addressPrefixes.count -ge 10)
                            {
                                $AddSpace = ($VNET2.properties.addressSpace.addressPrefixes | Select-Object -First 20 |  ForEach-Object {$_ + "`n"} ) + "`n" +'...'
                            }Else{
                                $AddSpace = ($VNET2.properties.addressSpace.addressPrefixes | ForEach-Object {$_ + "`n"})
                            }
        
                            $Script:XmlWriter.WriteStartElement('object')            
                            $Script:XmlWriter.WriteAttributeString('label', ([string]$VNET2.Name + "`n" + $AddSpace))
                            if($VNET2.properties.dhcpoptions.dnsServers)
                                {
                                    $Script:XmlWriter.WriteAttributeString('Custom_DNS_Servers', [string]$VNET2.properties.dhcpoptions.dnsServers)
                                    $Script:XmlWriter.WriteAttributeString('DDOS_Protection', [string]$VNET2.properties.enableDdosProtection)
                                }
                            else
                                {
                                    $Script:XmlWriter.WriteAttributeString('DDOS_Protection', [string]$VNET2.properties.enableDdosProtection)
                                }
                            $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
        
                                Icon $IconVNET 600 $Script:Alt "65" "39" 1
        
                            $Script:XmlWriter.WriteEndElement()
        
                            VNETCreator $Script:VNET2
        
                            if($VNET2.properties.virtualNetworkPeerings.properties.remoteVirtualNetwork.id)
                                {
                                    PeerCreator $Script:VNET2
                                }  
                        }
        
                        $Script:Alt = $Script:Alt + 250
                    }
        
                    $Script:XmlWriter.WriteStartElement('object')            
                    $Script:XmlWriter.WriteAttributeString('label', '')
                    $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
        
                        Icon $Ret -520 -100 "500" ($Script:Alt + 100) 1
        
                    $Script:XmlWriter.WriteEndElement()
        
                    $Script:XmlWriter.WriteStartElement('object')            
                    $Script:XmlWriter.WriteAttributeString('label', ('On Premises'+ "`n" +'Environment'))
                    $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
        
                        Icon $OnPrem -351 (($Script:Alt + 100)/2) "168.2" "290" 1
        
                    $Script:XmlWriter.WriteEndElement()  
        
                    label
        
                        Icon $Signature -520 ($Script:Alt + 100) "27.5" "22" 1
        
                    $Script:XmlWriter.WriteEndElement()  
        
        }
        
        <# Function for VNET creation #>
        Function VNETCreator {
        Param($VNET2)
                $Script:sizeL =  $VNET2.properties.subnets.properties.addressPrefix.count

                [System.GC]::GetTotalMemory($true) | out-null

                if($VNET2.id -notin $VNETHistory.vnet)
                    {
                    if ($Script:sizeL -gt 5)
                    {            
                        $Script:sizeL = $Script:sizeL / 2
                        $Script:sizeL = [math]::ceiling($Script:sizeL)
                        $Script:sizeC = $Script:sizeL
                        $Script:sizeL = (($Script:sizeL * 210) + 30)

                        if('gatewaysubnet' -in $VNET2.properties.subnets.name)
                            {
                                HubContainer ($Script:vnetLoc) ($Script:Alt0 - 20) $Script:sizeL "490" $VNET2.Name
                            }
                        else
                            {
                                VNETContainer ($Script:vnetLoc) ($Script:Alt0 - 20) $Script:sizeL "490" $VNET2.Name
                            }
        
                            
                        
                        $Script:VNETSquare = ($Script:CellID+'-'+($Script:IDNum-1))
        
                        $SubName = $Subscriptions | Where-Object {$_.id -eq $VNET2.subscriptionId}
        
                        $Script:XmlWriter.WriteStartElement('object')            
                        $Script:XmlWriter.WriteAttributeString('label', $SubName.name)
                        $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
        
                            Icon $IconSubscription $Script:sizeL 460 "67" "40" $Script:ContID
        
                        $Script:XmlWriter.WriteEndElement()  
        
                        $ADVS = ''
                        $ADVS = $Advisories | Where-Object {$_.Properties.Category -eq 'Cost' -and $_.Properties.resourceMetadata.resourceId -eq ('/subscriptions/'+$SubName.id)}
                        If($ADVS)
                        {
                            $Count = 1
                            $Script:XmlWriter.WriteStartElement('object')            
                            $Script:XmlWriter.WriteAttributeString('label', '')
        
                            foreach ($ADV in $ADVS)
                                {
                                    $Attr1 = ('Recommendation'+[string]$Count)
                                    $Script:XmlWriter.WriteAttributeString($Attr1, [string]$ADV.Properties.shortDescription.solution)
        
                                    $Count ++
                                }
        
                            $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
        
                                Icon $IconCostMGMT ($Script:sizeL + 150) 460 "30" "35" $Script:ContID
        
                            $Script:XmlWriter.WriteEndElement()
                            
                        }
        
                        Subnet ($Script:vnetLoc + 15) $VNET2 $Script:IDNum $Script:DiagramCache $Script:ContID 
        
                        if($Script:VNETPIP)
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', '')
        
                                $Count = 1
                                Foreach ($PIPDetail in $Script:VNETPIP)
                                    {
                                        $Attr1 = ('PublicIP-'+[string]("{0:d3}" -f $Count)+'-Name')
                                        $Attr2 = ('PublicIP-'+[string]("{0:d3}" -f $Count)+'-IP')
                                        $Script:XmlWriter.WriteAttributeString($Attr1, [string]$PIPDetail.name)
                                        $Script:XmlWriter.WriteAttributeString($Attr2, [string]$PIPDetail.properties.ipaddress)
        
                                        $Count ++
                                    }
        
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
        
                                    Icon $IconDet ($Script:sizeL + 500) 225 "42.63" "44" $Script:ContID
        
                                $Script:XmlWriter.WriteEndElement()
                                
                                    Connect ($Script:CellID+'-'+($Script:IDNum-1)) $Script:ContID $Script:ContID
                            }
        
                            $Script:Alt = $Script:Alt + 650
                    }
                else
                    {
                        $Script:sizeL = (($Script:sizeL * 210) + 30)
        
                        if('gatewaysubnet' -in $VNET2.properties.subnets.name)
                            {
                                HubContainer ($Script:vnetLoc) ($Script:Alt0 - 15) $Script:sizeL "260" $VNET2.Name
                            }
                        else
                            {
                                VNETContainer ($Script:vnetLoc) ($Script:Alt0 - 15) $Script:sizeL "260" $VNET2.Name
                            }

        
                        $Script:VNETSquare = ($Script:CellID+'-'+($Script:IDNum-1))
        
                        $SubName = $Subscriptions | Where-Object {$_.id -eq $VNET2.subscriptionId}
        
                        $Script:XmlWriter.WriteStartElement('object')            
                        $Script:XmlWriter.WriteAttributeString('label', $SubName.name)
                        $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
        
                            Icon $IconSubscription $Script:sizeL 225 "67" "40" $Script:ContID
        
                        $Script:XmlWriter.WriteEndElement()  
        
                        $ADVS = ''
                        $ADVS = $Advisories | Where-Object {$_.Properties.Category -eq 'Cost' -and $_.Properties.resourceMetadata.resourceId -eq ('/subscriptions/'+$SubName.id)}
                        If($ADVS)
                        {
                            $Count = 1
                            $Script:XmlWriter.WriteStartElement('object')            
                            $Script:XmlWriter.WriteAttributeString('label', '')
        
                            foreach ($ADV in $ADVS)
                                {
                                    $Attr1 = ('Recommendation'+[string]$Count)
                                    $Script:XmlWriter.WriteAttributeString($Attr1, [string]$ADV.Properties.shortDescription.solution)
        
                                    $Count ++
                                }
        
                            $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
        
                                Icon $IconCostMGMT ($Script:sizeL + 150) 225 "30" "35" $Script:ContID
        
                            $Script:XmlWriter.WriteEndElement()
        
                        }
        
                        Subnet ($Script:vnetLoc + 15) $VNET2 $Script:IDNum $Script:DiagramCache $Script:ContID
        
                        if($Script:VNETPIP)
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', '')
        
                                $Count = 1
                                Foreach ($PIPDetail in $Script:VNETPIP)
                                    {
                                        $Attr1 = ('PublicIP-'+[string]("{0:d3}" -f $Count)+'-Name')
                                        $Attr2 = ('PublicIP-'+[string]("{0:d3}" -f $Count)+'-IP')
                                        $Script:XmlWriter.WriteAttributeString($Attr1, [string]$PIPDetail.name)
                                        $Script:XmlWriter.WriteAttributeString($Attr2, [string]$PIPDetail.properties.ipaddress)
        
                                        $Count ++
                                    }
        
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
        
                                    Icon $IconDet ($Script:sizeL + 500) 107 "42.63" "44" $Script:ContID
        
                                $Script:XmlWriter.WriteEndElement()
                                
                                    Connect ($Script:CellID+'-'+($Script:IDNum-1)) $Script:ContID $Script:ContID
                            }
                        $Script:Alt = $Script:Alt + 350 
                    }
                }

                [System.GC]::GetTotalMemory($true) | out-null
        }
        
        <# Function for create peered VNETs #>
        Function PeerCreator {
        Param($VNET2)
        
            $Script:vnetLoc1 = $Script:Alt                                    
        
            Foreach ($Peer in $VNET2.properties.virtualNetworkPeerings)
                {
                    $VNETSUB = $AZVNETs | Where-Object {$_.id -eq $Peer.properties.remoteVirtualNetwork.id}                                                
        
                    if($VNETSUB.id -in $VNETHistory.VNET)
                        {        
                            $VNETDID = $VNETHistory | Where-Object {$_.VNET -eq $VNETSUB.id}
        
                            $Script:XmlWriter.WriteStartElement('object')
                            $Script:XmlWriter.WriteAttributeString('label', '')
                            $Script:XmlWriter.WriteAttributeString('Peering_Name', $Peer.name)
                            $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
            
                                $Script:XmlWriter.WriteStartElement('mxCell')
                                $Script:XmlWriter.WriteAttributeString('style', "edgeStyle=none;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;endArrow=none;endFill=0;")
                                $Script:XmlWriter.WriteAttributeString('edge', "1")
                                $Script:XmlWriter.WriteAttributeString('vertex', "1")
                                $Script:XmlWriter.WriteAttributeString('parent', "1")
                                $Script:XmlWriter.WriteAttributeString('source', $Script:VNETDrawID)
                                $Script:XmlWriter.WriteAttributeString('target', $VNETDID.VNETid)
            
                                    $Script:XmlWriter.WriteStartElement('mxGeometry')
                                    $Script:XmlWriter.WriteAttributeString('relative', "1")
                                    $Script:XmlWriter.WriteAttributeString('as', "geometry")
                                    $Script:XmlWriter.WriteEndElement()
                                
                                $Script:XmlWriter.WriteEndElement()
            
                            $Script:XmlWriter.WriteEndElement()
                        }
                    else
                    {
                        $Script:sizeL =  $VNETSUB.properties.subnets.properties.addressPrefix.count
                        $BrokenVNET = if($VNETSUB.properties.subnets.properties.addressPrefix.count){'Not Broken'}else{'Broken'}                                                                                                                                       
                        
                        if($VNETSUB.properties.addressSpace.addressPrefixes.count -ge 10)
                        {
                            $AddSpace = ($VNETSUB.properties.addressSpace.addressPrefixes | Select-Object -First 20 |  ForEach-Object {$_ + "`n"} ) + "`n" +'...'
                        }Else{
                            $AddSpace = ($VNETSUB.properties.addressSpace.addressPrefixes | ForEach-Object {$_ + "`n"})
                        }
        
                        $Script:XmlWriter.WriteStartElement('object')            
                        $Script:XmlWriter.WriteAttributeString('label', ($VNETSUB.name + "`n" + $AddSpace))
                        if($VNETSUB.properties.dhcpoptions.dnsServers)
                            {
                                $Script:XmlWriter.WriteAttributeString('Custom_DNS_Servers', [string]$VNETSUB.properties.dhcpoptions.dnsServers)
                                $Script:XmlWriter.WriteAttributeString('DDOS_Protection', [string]$VNETSUB.properties.enableDdosProtection)
                            }
                        else
                            {
                                $Script:XmlWriter.WriteAttributeString('DDOS_Protection', [string]$VNETSUB.properties.enableDdosProtection)
                            }
                        $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
        
                            Icon $IconVNET $Script:vnetLoc $Script:vnetLoc1 "67" "40" 1
        
                        $Script:XmlWriter.WriteEndElement()
        
        
                        $TwoTarget = ($Script:CellID+'-'+($Script:IDNum-1))
        
                        $Script:XmlWriter.WriteStartElement('object')            
                        $Script:XmlWriter.WriteAttributeString('label', '')
                        $Script:XmlWriter.WriteAttributeString('Peering_Name', $Peer.name)
                        $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
        
                            $Script:XmlWriter.WriteStartElement('mxCell')
                            $Script:XmlWriter.WriteAttributeString('style', "edgeStyle=none;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;endArrow=none;endFill=0;")
                            $Script:XmlWriter.WriteAttributeString('edge', "1")
                            $Script:XmlWriter.WriteAttributeString('vertex', "1")
                            $Script:XmlWriter.WriteAttributeString('parent', "1")
                            $Script:XmlWriter.WriteAttributeString('source', $Script:Source)
                            $Script:XmlWriter.WriteAttributeString('target', $TwoTarget)
        
                                $Script:XmlWriter.WriteStartElement('mxGeometry')
                                $Script:XmlWriter.WriteAttributeString('relative', "1")
                                $Script:XmlWriter.WriteAttributeString('as', "geometry")
                                $Script:XmlWriter.WriteEndElement()
                            
                            $Script:XmlWriter.WriteEndElement()
        
                        $Script:XmlWriter.WriteEndElement()
        
        
                        if($VNETSUB.properties.enableDdosProtection -eq $true)
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', '')
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
                    
                                    Icon $IconDDOS ($Script:vnetLoc - 20) ($Script:vnetLoc1 + 15) "23" "28" 1
                    
                                $Script:XmlWriter.WriteEndElement()
                            }
        
        
                        if ($Script:sizeL -gt 5)
                            {
                                $Script:sizeL = $Script:sizeL / 2
                                $Script:sizeL = [math]::ceiling($Script:sizeL)
                                $Script:sizeC = $Script:sizeL
                                $Script:sizeL = (($Script:sizeL * 210) + 30)

                                if('gatewaysubnet' -in $VNETSUB.properties.subnets.name)
                                    {
                                        HubContainer ($Script:vnetLoc + 100) ($Script:vnetLoc1 - 20) $Script:sizeL "490" $VNETSUB.name
                                    }
                                else
                                    {
                                        VNETContainer ($Script:vnetLoc + 100) ($Script:vnetLoc1 - 20) $Script:sizeL "490" $VNETSUB.name
                                    }
        
                                $Script:VNETSquare = ($Script:CellID+'-'+($Script:IDNum-1))
        
                                $SubName = $Subscriptions | Where-Object {$_.id -eq $VNETSUB.subscriptionId}
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', $SubName.name)
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
        
                                    Icon $IconSubscription $Script:sizeL 460 "67" "40" $Script:ContID
        
                                $Script:XmlWriter.WriteEndElement()                    
        
                                $ADVS = ''
                                $ADVS = $Advisories | Where-Object {$_.Properties.Category -eq 'Cost' -and $_.Properties.resourceMetadata.resourceId -eq ('/subscriptions/'+$SubName.id)}
                                If($ADVS)
                                    {
                                        $Count = 1
                                        $Script:XmlWriter.WriteStartElement('object')            
                                        $Script:XmlWriter.WriteAttributeString('label', '')
        
                                        foreach ($ADV in $ADVS)
                                            {
                                                $Attr1 = ('Recommendation'+[string]$Count)
                                                $Script:XmlWriter.WriteAttributeString($Attr1, [string]$ADV.Properties.shortDescription.solution)
        
                                                $Count ++
                                            }
        
                                        $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
        
                                            Icon $IconCostMGMT ($Script:sizeL + 150) 460 "30" "35" $Script:ContID
        
                                        $Script:XmlWriter.WriteEndElement()
                                        
                                    }
        
                                    Subnet ($Script:vnetLoc + 120) $VNETSUB $Script:IDNum $Script:DiagramCache $Script:ContID
        
                                    $Script:vnetLoc1 = $Script:vnetLoc1 + 230 
        
                                if($Script:VNETPIP)
                                    {
                                        $Script:XmlWriter.WriteStartElement('object')            
                                        $Script:XmlWriter.WriteAttributeString('label', '')
                    
                                        $Count = 1
                                        Foreach ($PIPDetail in $Script:VNETPIP)
                                            {
                                                $Attr1 = ('PublicIP-'+[string]("{0:d3}" -f $Count)+'-Name')
                                                $Attr2 = ('PublicIP-'+[string]("{0:d3}" -f $Count)+'-IP')
                                                $Script:XmlWriter.WriteAttributeString($Attr1, [string]$PIPDetail.name)
                                                $Script:XmlWriter.WriteAttributeString($Attr2, [string]$PIPDetail.properties.ipaddress)
                    
                                                $Count ++
                                            }
                    
                                        $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
                    
                                            Icon $IconDet ($Script:sizeL + 500) 225 "42.63" "44" $Script:ContID
                    
                                        $Script:XmlWriter.WriteEndElement()
                                        
                                            Connect ($Script:CellID+'-'+($Script:IDNum-1)) $Script:ContID $Script:ContID
                                    }  
        
                                $Script:Alt = $Script:Alt + 650                                                                         
                            }
                        else
                            {
                                $Script:sizeL = (($Script:sizeL * 210) + 30)
        
                                if($BrokenVNET -eq 'Not Broken')
                                    {                                        
                                        if('gatewaysubnet' -in $VNETSUB.properties.subnets.name)
                                            {
                                                HubContainer ($Script:vnetLoc + 100) ($Script:vnetLoc1 - 20) $Script:sizeL "260" $VNETSUB.name
                                            }
                                        else
                                            {
                                                VNETContainer ($Script:vnetLoc + 100) ($Script:vnetLoc1 - 20) $Script:sizeL "260" $VNETSUB.name
                                            }
                                    }
                                else
                                    {
                                        BrokenContainer ($Script:vnetLoc + 100) ($Script:vnetLoc1 - 20) "250" "260" 'Broken Peering'
                                        $Script:sizeL = '250'
                                    }
        
                                $Script:VNETSquare = ($Script:CellID+'-'+($Script:IDNum-1))
        
                                $SubName = $Subscriptions | Where-Object {$_.id -eq $VNETSUB.subscriptionId}
        
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', $SubName.name)
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
        
                                    Icon $IconSubscription $Script:sizeL 225 "67" "40" $Script:ContID
        
                                $Script:XmlWriter.WriteEndElement()  
        
                                $ADVS = ''
                                $ADVS = $Advisories | Where-Object {$_.Properties.Category -eq 'Cost' -and $_.Properties.resourceMetadata.resourceId -eq ('/subscriptions/'+$SubName.id)}
                                If($ADVS)
                                    {
                                        $Count = 1
                                        $Script:XmlWriter.WriteStartElement('object')            
                                        $Script:XmlWriter.WriteAttributeString('label', '')
        
                                        foreach ($ADV in $ADVS)
                                            {
                                                $Attr1 = ('Recommendation'+[string]$Count)
                                                $Script:XmlWriter.WriteAttributeString($Attr1, [string]$ADV.Properties.shortDescription.solution)
        
                                                $Count ++
                                            }
        
                                        $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
        
                                            Icon $IconCostMGMT ($Script:sizeL + 150) 225 "30" "35" $Script:ContID
        
                                        $Script:XmlWriter.WriteEndElement()
                                        
                                    }
        
                                    Subnet ($Script:vnetLoc + 120) $VNETSUB $Script:IDNum $Script:DiagramCache $Script:ContID
        
                                if($Script:VNETPIP)
                                    {
                                        $Script:XmlWriter.WriteStartElement('object')            
                                        $Script:XmlWriter.WriteAttributeString('label', '')
                    
                                        $Count = 1
                                        Foreach ($PIPDetail in $Script:VNETPIP)
                                            {
                                                $Attr1 = ('PublicIP-'+[string]("{0:d3}" -f $Count)+'-Name')
                                                $Attr2 = ('PublicIP-'+[string]("{0:d3}" -f $Count)+'-IP')
                                                $Script:XmlWriter.WriteAttributeString($Attr1, [string]$PIPDetail.name)
                                                $Script:XmlWriter.WriteAttributeString($Attr2, [string]$PIPDetail.properties.ipaddress)
                    
                                                $Count ++
                                            }
                    
                                        $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
                    
                                            Icon $IconDet ($Script:sizeL+ 500) 107 "42.63" "44" $Script:ContID
                    
                                        $Script:XmlWriter.WriteEndElement()
                                        
                                        Connect ($Script:CellID+'-'+($Script:IDNum-1)) $Script:ContID $Script:ContID
        
                                    }
        
                            }
                            
                        $tmp =@{
                            'VNETid' = $TwoTarget;
                            'VNET' = $VNETSUB.id
                        }    
                        $Script:VNETHistory += $tmp 
        
                        $Script:vnetLoc1 = $Script:vnetLoc1 + 350                                         
                    }
                }
            $Script:Alt = $Script:vnetLoc1
        }
        
        Function Subnet {
            Param($subloc,$VNET,$IDNum,$DiagramCache,$ContID)
        
            $NameString = -join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})
        
            New-Variable -Name ('Run_'+$NameString) -Scope Global
        
            Set-Variable -name ('Run_'+$NameString) -Value ([PowerShell]::Create()).AddScript({param($subloc,$VNET,$IDNum,$DiagramCache,$ContID,$Resources)
            
                $etag = -join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})
                $DiagID = -join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})
                $CellID = -join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})
        
                $IDNum++
        
                $SubFile = ($DiagramCache+$CellID+'.xml')
        
                ###################################################### STENCILS ####################################################
        
                Function Stensils {
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
        
                ####################################################### PROCTYPE ####################################################
        
        
                Function ProcType {
                    Param($sub,$subloc,$Alt0,$ContainerID) 

                        $temp = ''
                        remove-variable TrueTemp -ErrorAction SilentlyContinue
                        remove-variable RESNames -ErrorAction SilentlyContinue

                        <####################################################### FIND THE RESOURCES IN THE SUBNET ###################################################################>

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
                                                    if($RESNames.count -gt 1)
                                                        {
                                                            $Script:XmlTempWriter.WriteStartElement('object')            
                                                            $Script:XmlTempWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' VMs'))                                        
                                            
                                                            $Count = 1
                                                            foreach ($VMName in $RESNames.Name)
                                                            {
                                                                $Attr1 = ('VirtualMachine-'+[string]("{0:d3}" -f $Count))
                                                                $Script:XmlTempWriter.WriteAttributeString($Attr1, [string]$VMName)
                    
                                                                $Count ++
                                                            }
                                                            $Script:XmlTempWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
                    
                                                                Icon2 $IconVMs ($subloc+64) ($Alt0+40) "69" "64" $ContainerID
                                            
                                                            $Script:XmlTempWriter.WriteEndElement()  
                                                        }
                                                    else
                                                        {
                    
                                                            $Script:XmlTempWriter.WriteStartElement('object')            
                                                            $Script:XmlTempWriter.WriteAttributeString('label', [string]$RESNames.Name)
                                                            $Script:XmlTempWriter.WriteAttributeString('VM_Size', [string]$RESNames.properties.hardwareProfile.vmSize)
                                                            $Script:XmlTempWriter.WriteAttributeString('OS', [string]$RESNames.properties.storageProfile.osDisk.osType)
                                                            $Script:XmlTempWriter.WriteAttributeString('OS_Disk_Size_GB', [string]$RESNames.properties.storageProfile.osDisk.diskSizeGB)
                                                            $Script:XmlTempWriter.WriteAttributeString('Image_Publisher', [string]$RESNames.properties.storageProfile.imageReference.publisher)
                                                            $Script:XmlTempWriter.WriteAttributeString('Image_SKU', [string]$RESNames.properties.storageProfile.imageReference.sku)
                                                            $Script:XmlTempWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))                        
                    
                                                                Icon2 $IconVMs ($subloc+64) ($Alt0+40) "69" "64" $ContainerID
                                            
                                                            $Script:XmlTempWriter.WriteEndElement() 
                    
                                                        }                                                                                                                                    
                                                    }
                                'AKS' {                                                
                                                    if($RESNames.count -gt 1)
                                                        {
                                                            $Script:XmlTempWriter.WriteStartElement('object')            
                                                            $Script:XmlTempWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' AKS Clusters'))                                        
                                            
                                                            $Count = 1
                                                            foreach ($AKSName in $RESNames.Name)
                                                            {
                                                                $Attr1 = ('Kubernetes_Cluster-'+[string]("{0:d3}" -f $Count))
                                                                $Script:XmlTempWriter.WriteAttributeString($Attr1, [string]$AKSName)
                    
                                                                $Count ++
                                                            }
                                                            $Script:XmlTempWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
                    
                                                                Icon2 $IconAKS ($subloc+65) ($Alt0+40) "68" "64" $ContainerID
                                            
                                                            $Script:XmlTempWriter.WriteEndElement()
                    
                                                        }
                                                    else 
                                                        {
                                                            $Script:XmlTempWriter.WriteStartElement('object')            
                                                            $Script:XmlTempWriter.WriteAttributeString('label', [string]$RESNames.name)                                        
                                            
                                                            $Count = 1
                                                            foreach($Pool in $RESNames.properties.agentPoolProfiles)
                                                            {
                                                                $Attr1 = ('Node_Pool-'+[string]("{0:d3}" -f $Count)+'-Name')
                                                                $Attr2 = ('Node_Pool-'+[string]("{0:d3}" -f $Count)+'-Count')
                                                                $Attr3 = ('Node_Pool-'+[string]("{0:d3}" -f $Count)+'-Size')
                                                                $Attr4 = ('Node_Pool-'+[string]("{0:d3}" -f $Count)+'-Version')
                                                                $Attr5 = ('Node_Pool-'+[string]("{0:d3}" -f $Count)+'-Mode')
                                                                $Attr6 = ('Node_Pool-'+[string]("{0:d3}" -f $Count)+'-Max_Pods')
                    
                                                                $Script:XmlTempWriter.WriteAttributeString($Attr1, [string]$Pool.name)
                                                                $Script:XmlTempWriter.WriteAttributeString($Attr2, [string]($Pool | Select-Object -Property 'count').count)
                                                                $Script:XmlTempWriter.WriteAttributeString($Attr3, [string]$Pool.vmSize)
                                                                $Script:XmlTempWriter.WriteAttributeString($Attr4, [string]$Pool.orchestratorVersion)
                                                                $Script:XmlTempWriter.WriteAttributeString($Attr5, [string]$Pool.mode)
                                                                $Script:XmlTempWriter.WriteAttributeString($Attr6, [string]$Pool.maxPods)
                    
                                                                $Count ++
                                                            }
                                                            $Script:XmlTempWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
                    
                                                                Icon2 $IconAKS ($subloc+65) ($Alt0+40) "68" "64" $ContainerID
                                            
                                                            $Script:XmlTempWriter.WriteEndElement()
                    
                                                            }
                                                    }
                                'virtualMachineScaleSets' {                                                                                  
                                                    if($RESNames.count -gt 1)
                                                        {
                                                            $Script:XmlTempWriter.WriteStartElement('object')            
                                                            $Script:XmlTempWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' Virtual Machine Scale Sets'))                                        
                                            
                                                            $Count = 1
                                                            foreach ($ResName in $RESNames.Name)
                                                            {
                                                                $Attr1 = ('VMSS-'+[string]("{0:d3}" -f $Count))
                                                                $Script:XmlTempWriter.WriteAttributeString($Attr1, [string]$ResName)
                    
                                                                $Count ++
                                                            }
                                                            $Script:XmlTempWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
                    
                                                                Icon2 $IconVMSS ($subloc+65) ($Alt0+40) "68" "68" $ContainerID
                                            
                                                            $Script:XmlTempWriter.WriteEndElement()
                    
                                                        }
                                                    else
                                                        {
                                                            $Script:XmlTempWriter.WriteStartElement('object')            
                                                            $Script:XmlTempWriter.WriteAttributeString('label', [string]$RESNames.name)                                        
                                            
                                                            $Script:XmlTempWriter.WriteAttributeString('VMSS_Name', [string]$RESNames.name)
                                                            $Script:XmlTempWriter.WriteAttributeString('Instances', [string]$temp[0].Count)
                                                            $Script:XmlTempWriter.WriteAttributeString('VMSS_SKU_Tier', [string]$RESNames.sku.tier)
                                                            $Script:XmlTempWriter.WriteAttributeString('VMSS_Upgrade_Policy', [string]$RESNames.Properties.upgradePolicy.mode)
                    
                                                            $Script:XmlTempWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
                    
                                                                Icon2 $IconVMSS ($subloc+65) ($Alt0+40) "68" "68" $ContainerID
                                            
                                                            $Script:XmlTempWriter.WriteEndElement()
                                                        }                                                                        
                                                    } 
                                'loadBalancers' {                                                    
                                                    if($RESNames.count -gt 1)
                                                        {
                                                            $Script:XmlTempWriter.WriteStartElement('object')            
                                                            $Script:XmlTempWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' Load Balancers'))                                        
                                            
                                                            $Count = 1
                                                            foreach ($ResName in $RESNames)
                                                            {
                                                                $Attr1 = ('LB-'+[string]("{0:d3}" -f $Count)+'-Name')
                                                                $Attr2 = ('LB-'+[string]("{0:d3}" -f $Count)+'-SKU')
                                                                $Attr3 = ('LB-'+[string]("{0:d3}" -f $Count)+'-Backends')
                                                                $Attr4 = ('LB-'+[string]("{0:d3}" -f $Count)+'-Frontends')
                                                                $Attr5 = ('LB-'+[string]("{0:d3}" -f $Count)+'-LB_Rules')
                                                                $Attr6 = ('LB-'+[string]("{0:d3}" -f $Count)+'-Probes')
                    
                                                                $Script:XmlTempWriter.WriteAttributeString($Attr1, [string]$ResName.name)
                                                                $Script:XmlTempWriter.WriteAttributeString($Attr2, [string]$ResName.sku.name)
                                                                $Script:XmlTempWriter.WriteAttributeString($Attr3, [string]$ResName.properties.backendAddressPools.properties.backendIPConfigurations.id.count)
                                                                $Script:XmlTempWriter.WriteAttributeString($Attr4, [string]$ResName.properties.frontendIPConfigurations.properties.count)
                                                                $Script:XmlTempWriter.WriteAttributeString($Attr5, [string]$ResName.properties.loadBalancingRules.count)
                                                                $Script:XmlTempWriter.WriteAttributeString($Attr6, [string]$ResName.properties.probes.count)
                    
                                                                $Count ++
                                                            }
                                                            $Script:XmlTempWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
                    
                                                                Icon2 $IconLBs ($subloc+65) ($Alt0+40) "72" "72" $ContainerID
                                            
                                                            $Script:XmlTempWriter.WriteEndElement()
                    
                                                        }
                                                    else 
                                                        {            
                                                            $Script:XmlTempWriter.WriteStartElement('object')            
                                                            $Script:XmlTempWriter.WriteAttributeString('label', [string]$RESNames.Name)                                        
                    
                                                            $Script:XmlTempWriter.WriteAttributeString('Load_Balancer_Name', [string]$ResNames.name)
                                                            $Script:XmlTempWriter.WriteAttributeString('Load_Balancer_SKU', [string]$ResNames.sku.name)
                                                            $Script:XmlTempWriter.WriteAttributeString('Backends', [string]$ResNames.properties.backendAddressPools.properties.backendIPConfigurations.id.count)
                                                            $Script:XmlTempWriter.WriteAttributeString('Frontends', [string]$ResNames.properties.frontendIPConfigurations.properties.count)
                                                            $Script:XmlTempWriter.WriteAttributeString('LB_Rules', [string]$ResNames.properties.loadBalancingRules.count)
                                                            $Script:XmlTempWriter.WriteAttributeString('Probes', [string]$ResNames.properties.probes.count)
                    
                                                            $Script:XmlTempWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
                    
                                                                Icon2 $IconLBs ($subloc+65) ($Alt0+40) "72" "72" $ContainerID
                                            
                                                            $Script:XmlTempWriter.WriteEndElement()
                                                            
                                                        }
                                                    } 
                                'virtualNetworkGateways' {                                                    
                                                    if($RESNames.count -gt 1)
                                                        {
                                                            $Script:XmlTempWriter.WriteStartElement('object')            
                                                            $Script:XmlTempWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' Virtual Network Gateways'))                                        
                                            
                                                            $Count = 1
                                                            foreach ($ResName in $RESNames)
                                                            {
                                                                $Attr1 = ('Network_Gateway-'+[string]("{0:d3}" -f $Count)+'-Name')
                    
                                                                $Script:XmlTempWriter.WriteAttributeString($Attr1, [string]$ResName.name)
                    
                                                                $Count ++
                                                            }
                                                            $Script:XmlTempWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
                    
                                                                Icon2 $IconVGW ($subloc+80) ($Alt0+40) "52" "69" $ContainerID
                                            
                                                            $Script:XmlTempWriter.WriteEndElement()
                    
                                                        }
                                                    else
                                                        {
                                                            $Script:XmlTempWriter.WriteStartElement('object')            
                                                            $Script:XmlTempWriter.WriteAttributeString('label', [string]$RESNames.Name)                                        
                                            
                                                            $Script:XmlTempWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
                    
                                                                Icon2 $IconVGW ($subloc+80) ($Alt0+40) "52" "69" $ContainerID
                                            
                                                            $Script:XmlTempWriter.WriteEndElement()
                                                        }                                                                                                         
                                                    } 
                                'azureFirewalls' {                                                    
                                                    if($RESNames.count -gt 1)
                                                        {
                                                            $Script:XmlTempWriter.WriteStartElement('object')            
                                                            $Script:XmlTempWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' Firewalls'))                                        
                                            
                                                            $Count = 1
                                                            foreach ($ResName in $RESNames)
                                                            {
                                                                $Attr1 = ('Firewall-'+[string]("{0:d3}" -f $Count)+'-Name')
                                                                $Attr2 = ('Firewall-'+[string]("{0:d3}" -f $Count)+'-SKU')
                                                                $Attr3 = ('Firewall-'+[string]("{0:d3}" -f $Count)+'-Threat_Intel_Mode')
                    
                                                                $Script:XmlTempWriter.WriteAttributeString($Attr1, [string]$ResName.name)
                                                                $Script:XmlTempWriter.WriteAttributeString($Attr2, [string]$ResName.properties.sku.tier)
                                                                $Script:XmlTempWriter.WriteAttributeString($Attr3, [string]$ResName.properties.threatIntelMode)
                    
                                                                $Count ++
                                                            }
                                                            $Script:XmlTempWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
                    
                                                                Icon2 $IconFWs ($subloc+65) ($Alt0+40) "71" "60" $ContainerID
                                            
                                                            $Script:XmlTempWriter.WriteEndElement()
                                                        }
                                                    else 
                                                        {
                                                            $Script:XmlTempWriter.WriteStartElement('object')            
                                                            $Script:XmlTempWriter.WriteAttributeString('label', [string]$RESNames.name)      
                                                            
                    
                                                            $Script:XmlTempWriter.WriteAttributeString('Firewall_Name', [string]$ResNames.name)
                                                            $Script:XmlTempWriter.WriteAttributeString('SKU_Tier', [string]$ResNames.properties.sku.tier)
                                                            $Script:XmlTempWriter.WriteAttributeString('Threat_Intel_Mode', [string]$ResNames.properties.threatIntelMode)
                    
                                                            $Script:XmlTempWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
                    
                                                                Icon2 $IconFWs ($subloc+65) ($Alt0+40) "71" "60" $ContainerID
                                            
                                                            $Script:XmlTempWriter.WriteEndElement()
                                                        }                                                                
                                                    } 
                                'privateLinkServices' {                                                    
                                                    if($RESNames.count -gt 1)
                                                        {
                                                            $Script:XmlTempWriter.WriteStartElement('object')            
                                                            $Script:XmlTempWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' Private Endpoints'))                                        
                                            
                                                            $Count = 1
                                                            foreach ($ResName in $RESNames)
                                                            {
                                                                $Attr1 = ('PVE-'+[string]("{0:d3}" -f $Count)+'-Name')
                    
                                                                $Script:XmlTempWriter.WriteAttributeString($Attr1, [string]$ResName.name)
                    
                                                                $Count ++
                                                            }
                                                            $Script:XmlTempWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
                    
                                                                Icon2 $IconPVTs ($subloc+65) ($Alt0+40) "72" "66" $ContainerID
                                            
                                                            $Script:XmlTempWriter.WriteEndElement()
                    
                                                        }
                                                    else
                                                        {
                                                            $Script:XmlTempWriter.WriteStartElement('object')            
                                                            $Script:XmlTempWriter.WriteAttributeString('label', [string]$RESNames.Name)                                        
                                                            $Script:XmlTempWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
                    
                                                                Icon2 $IconPVTs ($subloc+65) ($Alt0+40) "72" "66" $ContainerID
                                            
                                                            $Script:XmlTempWriter.WriteEndElement()
                                                        }                                                                       
                                                    } 
                                'applicationGateways' {                                                    
                                                    if($RESNames.count -gt 1)
                                                        {
                                                            $Script:XmlTempWriter.WriteStartElement('object')            
                                                            $Script:XmlTempWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' Application Gateways'))                                        
                                            
                                                            $Count = 1
                                                            foreach ($ResName in $RESNames)
                                                            {
                                                                $Attr1 = ('App_Gateway-'+[string]("{0:d3}" -f $Count)+'-Name')
                                                                $Attr2 = ('App_Gateway-'+[string]("{0:d3}" -f $Count)+'-SKU')
                                                                $Attr3 = ('App_Gateway-'+[string]("{0:d3}" -f $Count)+'-Min_Capacity')
                                                                $Attr4 = ('App_Gateway-'+[string]("{0:d3}" -f $Count)+'-Max_Capacity')
                    
                                                                $Script:XmlTempWriter.WriteAttributeString($Attr1, [string]$ResName.name)
                                                                $Script:XmlTempWriter.WriteAttributeString($Attr2, [string]$RESName.Properties.sku.tier)
                                                                $Script:XmlTempWriter.WriteAttributeString($Attr3, [string]$RESName.Properties.autoscaleConfiguration.minCapacity)
                                                                $Script:XmlTempWriter.WriteAttributeString($Attr4, [string]$RESName.Properties.autoscaleConfiguration.maxCapacity)
                    
                                                                $Count ++
                                                            }
                                                            $Script:XmlTempWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
                    
                                                                Icon2 $IconAppGWs ($subloc+65) ($Alt0+40) "64" "64" $ContainerID
                                            
                                                            $Script:XmlTempWriter.WriteEndElement()
                    
                                                        }
                                                    else
                                                        {
                                                            $Script:XmlTempWriter.WriteStartElement('object')            
                                                            $Script:XmlTempWriter.WriteAttributeString('label', [string]$RESNames.Name)                                                            
                    
                                                            $Script:XmlTempWriter.WriteAttributeString('App_Gateway_Name', [string]$ResNames.name)
                                                            $Script:XmlTempWriter.WriteAttributeString('App_Gateway_SKU', [string]$RESNames.Properties.sku.tier)
                                                            $Script:XmlTempWriter.WriteAttributeString('Autoscale_Min_Capacity', [string]$RESNames.Properties.autoscaleConfiguration.minCapacity)
                                                            $Script:XmlTempWriter.WriteAttributeString('Autoscale_Max_Capacity', [string]$RESNames.Properties.autoscaleConfiguration.maxCapacity)
                    
                                                            $Script:XmlTempWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
                    
                                                                Icon2 $IconAppGWs ($subloc+65) ($Alt0+40) "64" "64" $ContainerID
                                            
                                                            $Script:XmlTempWriter.WriteEndElement()
                                                        }                                                                                                                                                                             
                                                    }
                                'bastionHosts' {                                                    
                                                    if($RESNames.count -gt 1)
                                                        {
                                                            $Script:XmlTempWriter.WriteStartElement('object')            
                                                            $Script:XmlTempWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' Bastion Hosts'))                                        
                                            
                                                            $Count = 1
                                                            foreach ($ResName in $RESNames)
                                                            {
                                                                $Attr1 = ('Bastion-'+[string]("{0:d3}" -f $Count)+'-Name')
                    
                                                                $Script:XmlTempWriter.WriteAttributeString($Attr1, [string]$ResName.name)
                    
                                                                $Count ++
                                                            }
                                                            $Script:XmlTempWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
                    
                                                                Icon2 $IconBastions ($subloc+65) ($Alt0+40) "68" "67" $ContainerID
                                            
                                                            $Script:XmlTempWriter.WriteEndElement()
                                                        }
                                                    else 
                                                        {
                                                            $Script:XmlTempWriter.WriteStartElement('object')            
                                                            $Script:XmlTempWriter.WriteAttributeString('label', [string]$RESNames.name)                                                            
                                                            $Script:XmlTempWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
                    
                                                                Icon2 $IconBastions ($subloc+65) ($Alt0+40) "68" "67" $ContainerID
                                            
                                                            $Script:XmlTempWriter.WriteEndElement()
                    
                                                        }                                                                        
                                                    } 
                                'APIM' {                                
                                                    $Script:XmlTempWriter.WriteStartElement('object')            
                                                    $Script:XmlTempWriter.WriteAttributeString('label', [string]$RESNames.Name)                                                            
                    
                                                    $APIMHost = [string]($RESNames.properties.hostnameConfigurations | Where-Object {$_.defaultSslBinding -eq $true}).hostname
                    
                                                    $Script:XmlTempWriter.WriteAttributeString('APIM_Name', [string]$ResNames.name)
                                                    $Script:XmlTempWriter.WriteAttributeString('SKU', [string]$RESNames.sku.name)
                                                    $Script:XmlTempWriter.WriteAttributeString('VNET_Type', [string]$RESNames.properties.virtualNetworkType)
                                                    $Script:XmlTempWriter.WriteAttributeString('Default_Hostname', $APIMHost)
                    
                                                    $Script:XmlTempWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
                    
                                                        Icon2 $IconAPIMs ($subloc+65) ($Alt0+40) "65" "60" $ContainerID
                                    
                                                    $Script:XmlTempWriter.WriteEndElement()
                                                
                                                    }
                                'App Service' {
                                                    if($ServiceAppNames)
                                                        {
                                                            if($RESNames.count -gt 1)
                                                                {
                                                                    $Script:XmlTempWriter.WriteStartElement('object')            
                                                                    $Script:XmlTempWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' App Services'))                                        
                                                    
                                                                    $Count = 1
                                                                    foreach ($ResName in $RESNames)
                                                                    {
                                                                        $Attr1 = ('AppService-'+[string]("{0:d3}" -f $Count)+'-Name')
                            
                                                                        $Script:XmlTempWriter.WriteAttributeString($Attr1, [string]$ResName.name)
                            
                                                                        $Count ++
                                                                    }
                                                                    $Script:XmlTempWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
                            
                                                                        Icon2 $IconAPPs ($subloc+65) ($Alt0+40) "64" "64" $ContainerID
                                                    
                                                                    $Script:XmlTempWriter.WriteEndElement()
                                                                }
                                                            else
                                                                {
                                                                    $Script:XmlTempWriter.WriteStartElement('object')            
                                                                    $Script:XmlTempWriter.WriteAttributeString('label', [string]$ResNames.name)                                                                        
                            
                                                                    $Script:XmlTempWriter.WriteAttributeString('App_Name', [string]$ResNames.name)
                                                                    $Script:XmlTempWriter.WriteAttributeString('Default_Hostname', [string]$RESNames.properties.defaultHostName)
                                                                    $Script:XmlTempWriter.WriteAttributeString('Enabled', [string]$RESNames.properties.enabled)
                                                                    $Script:XmlTempWriter.WriteAttributeString('State', [string]$RESNames.properties.state)
                                                                    $Script:XmlTempWriter.WriteAttributeString('Inbound_IP_Address', [string]$RESNames.properties.inboundIpAddress)
                                                                    $Script:XmlTempWriter.WriteAttributeString('Kind', [string]$RESNames.properties.kind)
                                                                    $Script:XmlTempWriter.WriteAttributeString('SKU', [string]$RESNames.properties.sku)
                                                                    $Script:XmlTempWriter.WriteAttributeString('Workers', [string]$RESNames.properties.siteConfig.numberOfWorkers)
                                                                    $Script:XmlTempWriter.WriteAttributeString('Min_Workers', [string]$RESNames.properties.siteConfig.minimumElasticInstanceCount)
                                                                    $Script:XmlTempWriter.WriteAttributeString('Site_Properties', [string]$RESNames.properties.siteProperties.properties.value)
                    
                    
                                                                    $Script:XmlTempWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
                            
                                                                        Icon2 $IconAPPs ($subloc+65) ($Alt0+40) "64" "64" $ContainerID
                                                    
                                                                    $Script:XmlTempWriter.WriteEndElement()
                                                                }
                                                        }                                                                                                                                  
                                                    }
                                'Function App' {    
                                                    if($FuntionAppNames)
                                                        {                                                
                                                            if($RESNames.count -gt 1)
                                                                {
                                                                    $Script:XmlTempWriter.WriteStartElement('object')            
                                                                    $Script:XmlTempWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' Function Apps'))                                        
                                                    
                                                                    $Count = 1
                                                                    foreach ($ResName in $RESNames)
                                                                    {
                                                                        $Attr1 = ('FunctionApp-'+[string]("{0:d3}" -f $Count)+'-Name')
                            
                                                                        $Script:XmlTempWriter.WriteAttributeString($Attr1, [string]$ResName.name)
                            
                                                                        $Count ++
                                                                    }
                                                                    $Script:XmlTempWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
                            
                                                                        Icon2 $IconFunApps ($subloc+65) ($Alt0+40) "68" "60" $ContainerID
                                                    
                                                                    $Script:XmlTempWriter.WriteEndElement()
                                                                }
                                                            else
                                                                {
                                                                    $Script:XmlTempWriter.WriteStartElement('object')            
                                                                    $Script:XmlTempWriter.WriteAttributeString('label', [string]$ResNames.name)                                                                        
                            
                                                                    $Script:XmlTempWriter.WriteAttributeString('App_Name', [string]$ResNames.name)
                                                                    $Script:XmlTempWriter.WriteAttributeString('Default_Hostname', [string]$RESNames.properties.defaultHostName)
                                                                    $Script:XmlTempWriter.WriteAttributeString('Enabled', [string]$RESNames.properties.enabled)
                                                                    $Script:XmlTempWriter.WriteAttributeString('State', [string]$RESNames.properties.state)
                                                                    $Script:XmlTempWriter.WriteAttributeString('Inbound_IP_Address', [string]$RESNames.properties.inboundIpAddress)
                                                                    $Script:XmlTempWriter.WriteAttributeString('Kind', [string]$RESNames.properties.kind)
                                                                    $Script:XmlTempWriter.WriteAttributeString('SKU', [string]$RESNames.properties.sku)
                                                                    $Script:XmlTempWriter.WriteAttributeString('Workers', [string]$RESNames.properties.siteConfig.numberOfWorkers)
                                                                    $Script:XmlTempWriter.WriteAttributeString('Min_Workers', [string]$RESNames.properties.siteConfig.minimumElasticInstanceCount)
                                                                    $Script:XmlTempWriter.WriteAttributeString('Site_Properties', [string]$RESNames.properties.siteProperties.properties.value)
                    
                                                                    $Script:XmlTempWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
                            
                                                                        Icon2 $IconFunApps ($subloc+65) ($Alt0+40) "68" "60" $ContainerID
                                                    
                                                                    $Script:XmlTempWriter.WriteEndElement()
                    
                                                                }
                                                        }
                                                    }
                                'DataBricks' {      
                                                    if($DatabriksNames)
                                                        {                                              
                                                        if($RESNames.count -gt 1)
                                                            {
                                                                $Script:XmlTempWriter.WriteStartElement('object')            
                                                                $Script:XmlTempWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' Databricks'))                                        
                                                
                                                                $Count = 1
                                                                foreach ($ResName in $RESNames)
                                                                {
                                                                    $Attr1 = ('Databrick-'+[string]("{0:d3}" -f $Count)+'-Name')
                        
                                                                    $Script:XmlTempWriter.WriteAttributeString($Attr1, [string]$ResName.name)
                        
                                                                    $Count ++
                                                                }
                                                                $Script:XmlTempWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
                        
                                                                    Icon2 $IconBricks ($subloc+65) ($Alt0+40) "60" "68" $ContainerID
                                                
                                                                $Script:XmlTempWriter.WriteEndElement()
                                                            }
                                                        else
                                                            {
                                                                $Script:XmlTempWriter.WriteStartElement('object')            
                                                                $Script:XmlTempWriter.WriteAttributeString('label', [string]$RESNames.Name)                                                                
                        
                                                                $Script:XmlTempWriter.WriteAttributeString('Databrick_Name', [string]$ResNames.name)
                                                                $Script:XmlTempWriter.WriteAttributeString('Workspace_URL', [string]$RESNames.properties.workspaceUrl )
                                                                $Script:XmlTempWriter.WriteAttributeString('Pricing_Tier', [string]$RESNames.sku.name)
                                                                $Script:XmlTempWriter.WriteAttributeString('Storage_Account', [string]$RESNames.properties.parameters.storageAccountName.value)
                                                                $Script:XmlTempWriter.WriteAttributeString('Storage_Account_SKU', [string]$RESNames.properties.parameters.storageAccountSkuName.value)
                                                                $Script:XmlTempWriter.WriteAttributeString('Relay_Namespace', [string]$RESNames.properties.parameters.relayNamespaceName.value)
                                                                $Script:XmlTempWriter.WriteAttributeString('Require_Infrastructure_Encryption', [string]$RESNames.properties.parameters.requireInfrastructureEncryption.value)
                                                                $Script:XmlTempWriter.WriteAttributeString('Enable_Public_IP', [string]$RESNames.properties.parameters.enableNoPublicIp.value)
                        
                                                                $Script:XmlTempWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
                        
                                                                    Icon2 $IconBricks ($subloc+65) ($Alt0+40) "60" "68" $ContainerID
                                                
                                                                $Script:XmlTempWriter.WriteEndElement()
                                                            }                                                                                               
                                                        }
                                                    }
                                'Open Shift' {        
                                                    if($ARONames)
                                                        {
                                                            if($RESNames.count -gt 1)
                                                                {
                                                                    $Script:XmlTempWriter.WriteStartElement('object')            
                                                                    $Script:XmlTempWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' OpenShift Clusters'))                                        
                                                    
                                                                    $Count = 1
                                                                    foreach ($ResName in $RESNames)
                                                                    {
                                                                        $Attr1 = ('OpenShift_Cluster-'+[string]("{0:d3}" -f $Count)+'-Name')
                            
                                                                        $Script:XmlTempWriter.WriteAttributeString($Attr1, [string]$ResName.name)
                            
                                                                        $Count ++
                                                                    }
                                                                    $Script:XmlTempWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
                            
                                                                        Icon2 $IconARO ($subloc+65) ($Alt0+40) "68" "60" $ContainerID
                    
                                                                    $Script:XmlTempWriter.WriteEndElement()
                    
                                                                }
                                                            else
                                                                {
                                                                    $Script:XmlTempWriter.WriteStartElement('object')            
                                                                    $Script:XmlTempWriter.WriteAttributeString('label', [string]$RESNames.Name)                                                                    
                    
                                                                    $Script:XmlTempWriter.WriteAttributeString('ARO_Name', [string]$ResNames.name)
                                                                    $Script:XmlTempWriter.WriteAttributeString('OpenShift_Version', [string]$RESNames.properties.clusterProfile.version)
                                                                    $Script:XmlTempWriter.WriteAttributeString('OpenShift_Console', [string]$RESNames.properties.consoleProfile.url)
                                                                    $Script:XmlTempWriter.WriteAttributeString('Worker_VM_Count', [string]$RESNames.properties.workerprofiles.Count)
                                                                    $Script:XmlTempWriter.WriteAttributeString('Worker_VM_Size', [string]$RESNames.properties.workerprofiles.vmSize[0])
                    
                                                                    $Script:XmlTempWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
                    
                                                                        Icon2 $IconARO ($subloc+65) ($Alt0+40) "68" "60" $ContainerID
                    
                                                                    $Script:XmlTempWriter.WriteEndElement()
                                                                }
                                                        }                                                                                               
                                                    }
                                'Container Instance'  {
                                                        if($ContainerNames)
                                                            {                                                                                                
                                                                if($RESNames.count -gt 1)
                                                                    {
                                                                        $Script:XmlTempWriter.WriteStartElement('object')            
                                                                        $Script:XmlTempWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' Container Intances'))                                        
                    
                                                                        $Count = 1
                                                                        foreach ($ResName in $RESNames)
                                                                        {
                                                                            $Attr1 = ('Container_Intance-'+[string]("{0:d3}" -f $Count)+'-Name')
                    
                                                                            $Script:XmlTempWriter.WriteAttributeString($Attr1, [string]$ResName.name)
                                
                                                                            $Count ++
                                                                        }
                                                                        $Script:XmlTempWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
                                
                                                                            Icon2 $IconContain ($subloc+65) ($Alt0+40) "64" "68" $ContainerID
                                                        
                                                                        $Script:XmlTempWriter.WriteEndElement()
                                                                    }
                                                                else
                                                                    {
                                                                        $Script:XmlTempWriter.WriteStartElement('object')            
                                                                        $Script:XmlTempWriter.WriteAttributeString('label', [string]$RESNames.Name)                                        
                                                                        $Script:XmlTempWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
                                
                                                                            Icon2 $IconContain ($subloc+65) ($Alt0+40) "64" "68" $ContainerID
                                                        
                                                                        $Script:XmlTempWriter.WriteEndElement()
                                                                    }
                                                            }                                                                                               
                                                    }
                                'NetApp' {          
                                                    if($NetAppNames)
                                                        {                                          
                                                            if($RESNames.count -gt 1)
                                                                {
                                                                    $Script:XmlTempWriter.WriteStartElement('object')            
                                                                    $Script:XmlTempWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' NetApp Volumes'))                                        
                                                    
                                                                    $Count = 1
                                                                    foreach ($ResName in $RESNames)
                                                                    {
                                                                        $Attr1 = ('NetApp_Volume-'+[string]("{0:d3}" -f $Count))
                            
                                                                        $Script:XmlTempWriter.WriteAttributeString($Attr1, [string]$ResName.name)
                            
                                                                        $Count ++
                                                                    }
                                                                    $Script:XmlTempWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
                            
                                                                        Icon2 $IconNetApp ($subloc+65) ($Alt0+40) "65" "52" $ContainerID
                                                    
                                                                    $Script:XmlTempWriter.WriteEndElement()
                                                                }
                                                            else
                                                                {
                                                                    $Script:XmlTempWriter.WriteStartElement('object')            
                                                                    $Script:XmlTempWriter.WriteAttributeString('label', ([string]1+' NetApp Volume'))                                                                        
                                                                    $Script:XmlTempWriter.WriteAttributeString('NetApp_Volume_Name', [string]$ResName.name)
                    
                                                                    $Script:XmlTempWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
                            
                                                                        Icon2 $IconNetApp ($subloc+65) ($Alt0+40) "65" "52" $ContainerID
                                                    
                                                                    $Script:XmlTempWriter.WriteEndElement()
                                                                }
                                                        }                                                                   
                                                    }
                                'Data Explorer Clusters' {  
                                                            if($RESNames.count -gt 1)
                                                                {
                                                                    $Script:XmlTempWriter.WriteStartElement('object')            
                                                                    $Script:XmlTempWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' Data Explorer Clusters'))                                        
                                                    
                                                                    $Count = 1
                                                                    foreach ($ResName in $RESNames)
                                                                    {
                                                                        $Attr1 = ('Data_Cluster-'+[string]("{0:d3}" -f $Count)+'-Name')
                            
                                                                        $Script:XmlTempWriter.WriteAttributeString($Attr1, [string]$ResName.name)
                            
                                                                        $Count ++
                                                                    }
                                                                    $Script:XmlTempWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
                            
                                                                        Icon2 $IconDataExplorer ($subloc+65) ($Alt0+40) "68" "68" $ContainerID
                                                    
                                                                    $Script:XmlTempWriter.WriteEndElement()
                    
                                                                }
                                                            else
                                                                {
                                                                    $Script:XmlTempWriter.WriteStartElement('object')            
                                                                    $Script:XmlTempWriter.WriteAttributeString('label', [string]$RESNames.Name)                                        
                                                                    $Script:XmlTempWriter.WriteAttributeString('Data_Explorer_Cluster_Name', [string]$ResNames.name)
                                                                    $Script:XmlTempWriter.WriteAttributeString('Data_Explorer_Cluster_URI', [string]$ResNames.name)
                                                                    $Script:XmlTempWriter.WriteAttributeString('Data_Explorer_Cluster_State', [string]$ResNames.name)
                                                                    $Script:XmlTempWriter.WriteAttributeString('SKU_Tier', [string]$ResNames.name)
                                                                    $Script:XmlTempWriter.WriteAttributeString('Computer_Specifications', [string]$ResNames.name)
                                                                    $Script:XmlTempWriter.WriteAttributeString('AutoScale_Enabled', [string]$ResNames.name)
                                                                    $Script:XmlTempWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
                            
                                                                        Icon2 $IconDataExplorer ($subloc+65) ($Alt0+40) "68" "68" $ContainerID
                                                    
                                                                    $Script:XmlTempWriter.WriteEndElement()
                                                                }                                                               
                                                    } 
                                'Network Interface' {                                                    
                                                    if($RESNames.count -gt 1)
                                                        {
                                                            $Script:XmlTempWriter.WriteStartElement('object')            
                                                            $Script:XmlTempWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' Network Interfaces'))                                        
                                            
                                                            $Count = 1
                                                            foreach ($ResName in $RESNames)
                                                            {
                                                                $Attr1 = ('NIC-'+[string]("{0:d3}" -f $Count)+'-Name')
                    
                                                                $Script:XmlTempWriter.WriteAttributeString($Attr1, [string]$ResName.name)
                    
                                                                $Count ++
                                                            }
                                                            $Script:XmlTempWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
                    
                                                                Icon2 $IconNIC ($subloc+65) ($Alt0+40) "68" "60" $ContainerID
                                            
                                                            $Script:XmlTempWriter.WriteEndElement()
                    
                                                        }
                                                    else
                                                        {
                                                            $Script:XmlTempWriter.WriteStartElement('object')            
                                                            $Script:XmlTempWriter.WriteAttributeString('label', ([string]1+' Network Interface'))                                        
                                            
                                                            $Attr1 = ('NIC-Name')
                                                            $Script:XmlTempWriter.WriteAttributeString($Attr1, [string]$ResName.name)
                    
                                                            $Script:XmlTempWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
                    
                                                                Icon2 $IconNIC ($subloc+65) ($Alt0+40) "68" "60" $ContainerID
                                            
                                                            $Script:XmlTempWriter.WriteEndElement()
                    
                                                        }                                                                
                                                    }                                                                                                                                                                            
                                '' {}
                                default {}
                            }
                            if($sub.properties.networkSecurityGroup.id)
                                {
                                    $NSG = $sub.properties.networkSecurityGroup.id.split('/')[8]
                                    $Script:XmlTempWriter.WriteStartElement('object')            
                                    $Script:XmlTempWriter.WriteAttributeString('label', '')                                        
                                    $Script:XmlTempWriter.WriteAttributeString('Network_Security_Group', [string]$NSG)
                                    $Script:XmlTempWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
                    
                                        Icon2 $IconNSG ($subloc+160) ($Alt0+15) "26.35" "32" $ContainerID
                    
                                    $Script:XmlTempWriter.WriteEndElement()  
                                }
                            if($sub.properties.routeTable.id)
                                {
                                    $UDR = $sub.properties.routeTable.id.split('/')[8]
                                    $Script:XmlTempWriter.WriteStartElement('object')            
                                    $Script:XmlTempWriter.WriteAttributeString('label', '')                                        
                                    $Script:XmlTempWriter.WriteAttributeString('Route_Table', [string]$UDR)
                                    $Script:XmlTempWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
                    
                                        Icon2 $IconUDR ($subloc+15) ($Alt0+15) "30.97" "30" $ContainerID
                    
                                    $Script:XmlTempWriter.WriteEndElement()
                    
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
        
                Function Icon2 {    
                    Param($Style,$x,$y,$w,$h,$p)
                    
                        $Script:XmlTempWriter.WriteStartElement('mxCell')
                        $Script:XmlTempWriter.WriteAttributeString('style', $Style)
                        $Script:XmlTempWriter.WriteAttributeString('vertex', "1")
                        $Script:XmlTempWriter.WriteAttributeString('parent', $p)
                    
                            $Script:XmlTempWriter.WriteStartElement('mxGeometry')
                            $Script:XmlTempWriter.WriteAttributeString('x', $x)
                            $Script:XmlTempWriter.WriteAttributeString('y', $y)
                            $Script:XmlTempWriter.WriteAttributeString('width', $w)
                            $Script:XmlTempWriter.WriteAttributeString('height', $h)
                            $Script:XmlTempWriter.WriteAttributeString('as', "geometry")
                            $Script:XmlTempWriter.WriteEndElement()
                        
                        $Script:XmlTempWriter.WriteEndElement()
                    }
        
                ######################################################## SUBNET #######################################################
        
                Stensils
        
                $Script:XmlTempWriter = New-Object System.XMl.XmlTextWriter($SubFile,$Null)
        
                $Script:XmlTempWriter.Formatting = 'Indented'
                $Script:XmlTempWriter.Indentation = 2
        
                $Script:XmlTempWriter.WriteStartDocument()
        
                $Script:XmlTempWriter.WriteStartElement('mxfile')
                $Script:XmlTempWriter.WriteAttributeString('host', 'Electron')
                $Script:XmlTempWriter.WriteAttributeString('modified', '2021-10-01T21:45:40.561Z')
                $Script:XmlTempWriter.WriteAttributeString('agent', '5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) draw.io/15.4.0 Chrome/91.0.4472.164 Electron/13.5.0 Safari/537.36')
                $Script:XmlTempWriter.WriteAttributeString('etag', $etag)
                $Script:XmlTempWriter.WriteAttributeString('version', '15.4.0')
                $Script:XmlTempWriter.WriteAttributeString('type', 'device')
        
                    $Script:XmlTempWriter.WriteStartElement('diagram')
                    $Script:XmlTempWriter.WriteAttributeString('id', $DiagID)
                    $Script:XmlTempWriter.WriteAttributeString('name', 'Network Topology')
        
                        $Script:XmlTempWriter.WriteStartElement('mxGraphModel')
                        $Script:XmlTempWriter.WriteAttributeString('dx', "1326")
                        $Script:XmlTempWriter.WriteAttributeString('dy', "798")
                        $Script:XmlTempWriter.WriteAttributeString('grid', "1")
                        $Script:XmlTempWriter.WriteAttributeString('gridSize', "10")
                        $Script:XmlTempWriter.WriteAttributeString('guides', "1")
                        $Script:XmlTempWriter.WriteAttributeString('tooltips', "1")
                        $Script:XmlTempWriter.WriteAttributeString('connect', "1")
                        $Script:XmlTempWriter.WriteAttributeString('arrows', "1")
                        $Script:XmlTempWriter.WriteAttributeString('fold', "1")
                        $Script:XmlTempWriter.WriteAttributeString('page', "1")
                        $Script:XmlTempWriter.WriteAttributeString('pageScale', "1")
                        $Script:XmlTempWriter.WriteAttributeString('pageWidth', "850")
                        $Script:XmlTempWriter.WriteAttributeString('pageHeight', "1100")
                        $Script:XmlTempWriter.WriteAttributeString('math', "0")
                        $Script:XmlTempWriter.WriteAttributeString('shadow', "0")
        
                            $Script:XmlTempWriter.WriteStartElement('root')
        
                                $Script:XmlTempWriter.WriteStartElement('mxCell')
                                $Script:XmlTempWriter.WriteAttributeString('id', "0")
                                $Script:XmlTempWriter.WriteEndElement()
        
                                $Script:XmlTempWriter.WriteStartElement('mxCell')
                                $Script:XmlTempWriter.WriteAttributeString('id', "1")
                                $Script:XmlTempWriter.WriteAttributeString('parent', "0")
                                $Script:XmlTempWriter.WriteEndElement()
                
                                    $sizeL =  $VNET.properties.subnets.properties.addressPrefix.count
                                    if ($sizeL -gt 5)
                                        {                                           
                                            $sizeL = $sizeL / 2
                                            $sizeL = [math]::ceiling($sizeL)
                                            $sizeC = $sizeL
                                            $sizeL = (($sizeL * 210) + 30)
        
                                            $subloc0 = 20
                                            $SubC = 0
                                            $alt1 = 40
                                            $Script:VNETPIP = @()
                                            foreach($Sub in $VNET.properties.subnets)
                                            {
                                                if ($SubC -eq $sizeC) 
                                                {
                                                    $Alt1 = $Alt1 + 230
                                                    $subloc0 = 20
                                                    $SubC = 0
                                                }
        
                                                $Script:XmlTempWriter.WriteStartElement('object')            
                                                $Script:XmlTempWriter.WriteAttributeString('label', ("`n" + "`n" + "`n" + "`n" + "`n" + "`n" +[string]$sub.Name + "`n" + [string]$sub.properties.addressPrefix))
                                                $Script:XmlTempWriter.WriteAttributeString('id', ($CellID+'-'+($IDNum++)))
        
                                                    Icon2 "rounded=0;whiteSpace=wrap;fontSize=16;html=1;sketch=0;fontFamily=Helvetica;" $subloc0 $Alt1 "200" "200" $ContID
        
                                                $Script:XmlTempWriter.WriteEndElement()      
                                                
                                                    ProcType $sub $subloc0 $Alt1 $ContID               
        
                                                $subloc = $subloc + 210
                                                $subloc0 = $subloc0 + 210
                                                $SubC ++
                                            }
        
                                        }
                                    Else
                                        {
                                            $sizeL = (($sizeL * 210) + 30)
                                            $subloc0 = 20
                                            $Script:VNETPIP = @()
                                            foreach($Sub in $VNET.properties.subnets)
                                            {
                                                $Script:XmlTempWriter.WriteStartElement('object')            
                                                $Script:XmlTempWriter.WriteAttributeString('label', ("`n" + "`n" + "`n" + "`n" + "`n" + "`n" +[string]$sub.Name + "`n" + [string]$sub.properties.addressPrefix))
                                                $Script:XmlTempWriter.WriteAttributeString('id', ($CellID+'-'+($IDNum++)))
        
                                                    Icon2 "rounded=0;whiteSpace=wrap;fontSize=16;html=1;sketch=0;fontFamily=Helvetica;" $subloc0 40 "200" "200" $ContID
        
                                                $Script:XmlTempWriter.WriteEndElement()  
        
                                                    ProcType $sub $subloc0 40 $ContID              
        
                                                $subloc = $subloc + 210
                                                $subloc0 = $subloc0 + 210
                                            }
                                        }
        
                                $Script:XmlTempWriter.WriteEndElement()
        
                            $Script:XmlTempWriter.WriteEndElement()
        
                        $Script:XmlTempWriter.WriteEndElement()
                        $Script:XmlTempWriter.WriteEndElement()
        
                    $Script:XmlTempWriter.WriteEndDocument()
                    $Script:XmlTempWriter.Flush()
                    $Script:XmlTempWriter.Close() 
        
            }).AddArgument($subloc).AddArgument($VNET).AddArgument($IDNum).AddArgument($DiagramCache).AddArgument($ContID).AddArgument($Resources)
        
            New-Variable -Name ('Job_'+$NameString) -Scope Global
        
            Set-Variable -Name ('Job_'+$NameString) -Value ((get-variable -name ('Run_'+$NameString)).Value).BeginInvoke()
        
            $Script:jobs2 += (get-variable -name ('Job_'+$NameString)).Value
        
            $Script:jobs += $NameString
        
            #New-Variable -Name ('End_'+$NameString)
            #Set-Variable -Name ('End_'+$NameString) -Value (((get-variable -name ('Run_'+$NameString)).Value).EndInvoke((get-variable -name ('Job_'+$NameString)).Value))
        
            #((get-variable -name ('Run_'+$NameString)).Value).Dispose()
        
            #while ($Job.Runspace.IsCompleted -contains $false) {}
        
            KillJobs
        
        }
        
        Function KillJobs {
        
            foreach($job in $Script:jobs)
            {
                if((get-variable -name ('Job_'+$job) -Scope Global).Value.IsCompleted -eq $true)
                    {
                        #((get-variable -name ('Run_'+$job)).Value).EndInvoke((get-variable -name ('Job_'+$job)).Value)
                        ((get-variable -name ('Run_'+$job)).Value).Dispose()
                        Remove-Variable -Name ('Run_'+$job) -Scope Global -Force
                        Remove-Variable -Name ('Job_'+$job) -Scope Global -Force
                    }
            }
        }

        <# Function to create the Label of Version #>
        Function label {
            $Script:XmlWriter.WriteStartElement('object')            
            $Script:XmlWriter.WriteAttributeString('label', ('Powered by:'+ "`n" +'Azure Resource Inventory v3.0'+ "`n" +'https://github.com/microsoft/ARI'))
            $Script:XmlWriter.WriteAttributeString('author', 'Claudio Merola')
            $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
        }

        Function Icon {    
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

        Function Container {
            Param($x,$y,$w,$h,$title)
                $Script:ContID = (-join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})+'-'+1)
        
                $Script:XmlWriter.WriteStartElement('mxCell')
                $Script:XmlWriter.WriteAttributeString('id', $Script:ContID)
                $Script:XmlWriter.WriteAttributeString('value', "$title")
                $Script:XmlWriter.WriteAttributeString('style', "swimlane")
                $Script:XmlWriter.WriteAttributeString('vertex', "1")
                $Script:XmlWriter.WriteAttributeString('parent', "1")
            
                    $Script:XmlWriter.WriteStartElement('mxGeometry')
                    $Script:XmlWriter.WriteAttributeString('x', $x)
                    $Script:XmlWriter.WriteAttributeString('y', $y)
                    $Script:XmlWriter.WriteAttributeString('width', $w)
                    $Script:XmlWriter.WriteAttributeString('height', $h)
                    $Script:XmlWriter.WriteAttributeString('as', "geometry")
                    $Script:XmlWriter.WriteEndElement()
                
                $Script:XmlWriter.WriteEndElement()
        }

        Function Connect {
        Param($Source,$Target,$Parent)
        
            if($Parent){$Parent = $Parent}else{$Parent = 1}
        
            $Script:XmlWriter.WriteStartElement('mxCell')
            $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
            $Script:XmlWriter.WriteAttributeString('style', "edgeStyle=none;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;endArrow=none;endFill=0;")
            $Script:XmlWriter.WriteAttributeString('edge', "1")
            $Script:XmlWriter.WriteAttributeString('vertex', "1")
            $Script:XmlWriter.WriteAttributeString('parent', $Parent)
            $Script:XmlWriter.WriteAttributeString('source', $Source)
            $Script:XmlWriter.WriteAttributeString('target', $Target)
        
                $Script:XmlWriter.WriteStartElement('mxGeometry')
                $Script:XmlWriter.WriteAttributeString('relative', "1")
                $Script:XmlWriter.WriteAttributeString('as', "geometry")
                $Script:XmlWriter.WriteEndElement()
            
            $Script:XmlWriter.WriteEndElement()
        
        }

        Function Variables0 {
            Start-Job -Name 'DiagramVariables' -ScriptBlock {
                $job = @()                

                $AZVGWs = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.network/virtualnetworkgateways'} | Select-Object -Property * -Unique}).AddArgument($($args[0]))
                $AZLGWs = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.network/localnetworkgateways'} | Select-Object -Property * -Unique}).AddArgument($($args[0]))
                $AZVNETs = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.network/virtualnetworks'} | Select-Object -Property * -Unique}).AddArgument($($args[0]))
                $AZCONs = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.network/connections'} | Select-Object -Property * -Unique}).AddArgument($($args[0]))
                $AZEXPROUTEs = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.network/expressroutecircuits'} | Select-Object -Property * -Unique }).AddArgument($($args[0]))
                $PIPs = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.network/publicipaddresses'} | Select-Object -Property * -Unique}).AddArgument($($args[0]))
                $AZVWAN = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.network/virtualwans'} | Select-Object -Property * -Unique}).AddArgument($($args[0]))
                $AZVHUB = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.network/virtualhubs'} | Select-Object -Property * -Unique}).AddArgument($($args[0]))
                $AZVPNSITES = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.network/vpnsites'} | Select-Object -Property * -Unique}).AddArgument($($args[0]))
                $AZVERs = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.network/expressroutegateways'} | Select-Object -Property * -Unique}).AddArgument($($args[0]))

                $AZAKS = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.containerservice/managedclusters'} | Select-Object -Property * -Unique}).AddArgument($($args[0]))
                $AZVMSS = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'Microsoft.Compute/virtualMachineScaleSets'} | Select-Object -Property * -Unique}).AddArgument($($args[0]))
                $AZNIC = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.network/networkinterfaces'} | Select-Object -Property * -Unique}).AddArgument($($args[0]))
                $AZPrivEnd = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.network/privateendpoints'} | Select-Object -Property * -Unique}).AddArgument($($args[0]))
                $AZVM = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.compute/virtualmachines'} | Select-Object -Property * -Unique}).AddArgument($($args[0]))
                $AZARO = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.redhatopenshift/openshiftclusters'} | Select-Object -Property * -Unique}).AddArgument($($args[0]))
                $AZKusto = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'Microsoft.Kusto/clusters'} | Select-Object -Property * -Unique}).AddArgument($($args[0]))
                $AZAppGW = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.network/applicationgateways'} | Select-Object -Property * -Unique}).AddArgument($($args[0]))
                $AZDW = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'Microsoft.Databricks/workspaces'} | Select-Object -Property * -Unique}).AddArgument($($args[0]))
                $AZAppWeb = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.web/sites'} | Select-Object -Property * -Unique}).AddArgument($($args[0]))
                $AZAPIM = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'Microsoft.ApiManagement/service'} | Select-Object -Property * -Unique}).AddArgument($($args[0]))
                $AZLB = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.network/loadbalancers'} | Select-Object -Property * -Unique}).AddArgument($($args[0]))
                $AZBastion = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.network/bastionhosts'} | Select-Object -Property * -Unique}).AddArgument($($args[0]))
                $AZFW = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.network/azurefirewalls'} | Select-Object -Property * -Unique}).AddArgument($($args[0]))
                $AZNetProf = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.network/networkprofiles'} | Select-Object -Property * -Unique}).AddArgument($($args[0]))
                $AZCont = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'Microsoft.ContainerInstance/containerGroups'} | Select-Object -Property * -Unique}).AddArgument($($args[0]))
                $AZANF = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.netapp/netappaccounts/capacitypools/volumes'} | Select-Object -Property * -Unique}).AddArgument($($args[0]))

                $jobAZVGWs = $AZVGWs.BeginInvoke()
                $jobAZLGWs = $AZLGWs.BeginInvoke()
                $jobAZVNETs = $AZVNETs.BeginInvoke()
                $jobAZCONs = $AZCONs.BeginInvoke()
                $jobAZEXPROUTEs = $AZEXPROUTEs.BeginInvoke()
                $jobPIPs = $PIPs.BeginInvoke()
                $jobAZVWAN = $AZVWAN.BeginInvoke()
                $jobAZVHUB = $AZVHUB.BeginInvoke()
                $jobAZVERs = $AZVERs.BeginInvoke()
                $jobAZVPNSITES = $AZVPNSITES.BeginInvoke()
                $jobAZAKS = $AZAKS.BeginInvoke()
                $jobAZVMSS = $AZVMSS.BeginInvoke()
                $jobAZNIC = $AZNIC.BeginInvoke()
                $jobAZPrivEnd = $AZPrivEnd.BeginInvoke()
                $jobAZVM = $AZVM.BeginInvoke()
                $jobAZARO = $AZARO.BeginInvoke()
                $jobAZKusto = $AZKusto.BeginInvoke()
                $jobAZAppGW = $AZAppGW.BeginInvoke()
                $jobAZDW = $AZDW.BeginInvoke()
                $jobAZAppWeb = $AZAppWeb.BeginInvoke()
                $jobAZAPIM = $AZAPIM.BeginInvoke()
                $jobAZLB = $AZLB.BeginInvoke()
                $jobAZBastion = $AZBastion.BeginInvoke()
                $jobAZFW = $AZFW.BeginInvoke()
                $jobAZNetProf = $AZNetProf.BeginInvoke()
                $jobAZCont = $AZCont.BeginInvoke()
                $jobAZANF = $AZANF.BeginInvoke()

                $job += $jobAZVGWs
                $job += $jobAZLGWs
                $job += $jobAZVNETs
                $job += $jobAZCONs
                $job += $jobAZEXPROUTEs
                $job += $jobPIPs
                $job += $jobAZVWAN
                $job += $jobAZVHUB
                $job += $jobAZVPNSITES
                $job += $jobAZVERs
                $job += $jobAZAKS
                $job += $jobAZVMSS
                $job += $jobAZNIC
                $job += $jobAZPrivEnd
                $job += $jobAZVM
                $job += $jobAZARO
                $job += $jobAZKusto
                $job += $jobAZAppGW
                $job += $jobAZDW
                $job += $jobAZAppWeb
                $job += $jobAZAPIM
                $job += $jobAZLB
                $job += $jobAZBastion
                $job += $jobAZFW
                $job += $jobAZNetProf
                $job += $jobAZCont
                $job += $jobAZANF

                while ($Job.Runspace.IsCompleted -contains $false) {}

                $AZVGWsS = $AZVGWs.EndInvoke($jobAZVGWs)
                $AZLGWsS = $AZLGWs.EndInvoke($jobAZLGWs)
                $AZVNETsS = $AZVNETs.EndInvoke($jobAZVNETs)
                $AZCONsS = $AZCONs.EndInvoke($jobAZCONs)
                $AZEXPROUTEsS = $AZEXPROUTEs.EndInvoke($jobAZEXPROUTEs)
                $PIPsS = $PIPs.EndInvoke($jobPIPs)
                $AZVWANS = $AZVWAN.EndInvoke($jobAZVWAN)
                $AZVHUBS = $AZVHUB.EndInvoke($jobAZVHUB)
                $AZVPNSITESS = $AZVPNSITES.EndInvoke($jobAZVPNSITES)
                $AZVERsS = $AZVERs.EndInvoke($jobAZVERs)
                $AZAKSs = $AZAKS.EndInvoke($jobAZAKS)
                $AZVMSSs = $AZVMSS.EndInvoke($jobAZVMSS)
                $AZNICs = $AZNIC.EndInvoke($jobAZNIC)
                $AZPrivEnds = $AZPrivEnd.EndInvoke($jobAZPrivEnd)
                $AZVMs = $AZVM.EndInvoke($jobAZVM)
                $AZAROs = $AZARO.EndInvoke($jobAZARO)
                $AZKustos = $AZKusto.EndInvoke($jobAZKusto)
                $AZAppGWs = $AZAppGW.EndInvoke($jobAZAppGW)
                $AZDWs = $AZDW.EndInvoke($jobAZDW)
                $AZAppWebs = $AZAppWeb.EndInvoke($jobAZAppWeb)
                $AZAPIMs = $AZAPIM.EndInvoke($jobAZAPIM)
                $AZLBs = $AZLB.EndInvoke($jobAZLB)
                $AZBastions = $AZBastion.EndInvoke($jobAZBastion)
                $AZFWs = $AZFW.EndInvoke($jobAZFW)
                $AZNetProfs = $AZNetProf.EndInvoke($jobAZNetProf)
                $AZConts = $AZCont.EndInvoke($jobAZCont)
                $AZANFs = $AZANF.EndInvoke($jobAZANF)


                $AZVGWs.Dispose()
                $AZLGWs.Dispose()
                $AZVNETs.Dispose()
                $AZCONs.Dispose()
                $AZEXPROUTEs.Dispose()
                $PIPs.Dispose()
                $AZVWAN.Dispose()
                $AZVHUB.Dispose()
                $AZVPNSITES.Dispose()
                $AZVERs.Dispose()
                $AZAKS.Dispose()
                $AZVMSS.Dispose()
                $AZNIC.Dispose()
                $AZPrivEnd.Dispose()
                $AZVM.Dispose()
                $AZARO.Dispose()
                $AZKusto.Dispose()
                $AZAppGW.Dispose()
                $AZDW.Dispose()
                $AZAppWeb.Dispose()
                $AZAPIM.Dispose()
                $AZLB.Dispose()
                $AZBastion.Dispose()
                $AZFW.Dispose()
                $AZNetProf.Dispose()
                $AZCont.Dispose()
                $AZANF.Dispose()

                $CleanPIPs = $PIPsS | Where-Object {$_.id -notin $AZVGWsS.properties.ipConfigurations.properties.publicIPAddress.id}

                $Variables = @{
                        'AZVGWs' = $AZVGWsS;
                        'AZLGWs' = $AZLGWsS;
                        'AZVNETs' = $AZVNETsS;
                        'AZCONs' = $AZCONsS;
                        'AZEXPROUTEs' = $AZEXPROUTEsS;
                        'PIPs' = $PIPsS;
                        'AZVWAN' = $AZVWANS;
                        'AZVHUB' = $AZVHUBS;
                        'AZVPNSITES' = $AZVPNSITESS;
                        'AZVERs' = $AZVERsS;
                        'CleanPIPs' = $CleanPIPs;
                        'AKS' = $AZAKSs;
                        'VMSS' = $AZVMSSs;
                        'NIC' = $AZNICs;
                        'PrivEnd' = $AZPrivEnds;
                        'VM' = $AZVMs;
                        'ARO' = $AZAROs;
                        'Kusto' = $AZKustos;
                        'AppGtw' = $AZAppGWs;
                        'DW' = $AZDWs;
                        'AppWeb' = $AZAppWebs;
                        'APIM' = $AZAPIMs;
                        'LB' = $AZLBs;
                        'Bastion' = $AZBastions;
                        'FW' = $AZFWs;
                        'NetProf' = $AZNetProfs;
                        'Container' = $AZConts;
                        'ANF' = $AZANFs
                    }
        
                $Variables
        
            } -ArgumentList $resources, $null
        
        }

        ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Setting Subnet files') | Out-File -FilePath $LogFile -Append 

        $Subnetfiles = Get-ChildItem -Path $DiagramCache

        foreach($SubFile in $Subnetfiles)
            {
                if($SubFile.FullName -notin $XMLFiles)
                        {
                            Remove-Item -Path $SubFile.FullName
                        }
            }
        
        ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Calling Variables0 Function') | Out-File -FilePath $LogFile -Append 

        Variables0

        ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Waiting Variables Job to complete') | Out-File -FilePath $LogFile -Append 

        Get-Job -Name 'DiagramVariables' | Wait-Job

        $Job = Receive-Job -Name 'DiagramVariables'

        Get-Job -Name 'DiagramVariables' | Remove-Job

        ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Setting Variables') | Out-File -FilePath $LogFile -Append 

        $Script:AZVGWs = $Job.AZVGWs
        $Script:AZLGWs = $Job.AZLGWs
        $Script:AZVNETs = $Job.AZVNETs
        $Script:AZCONs = $Job.AZCONs
        $Script:AZEXPROUTEs = $Job.AZEXPROUTEs
        $Script:PIPs = $Job.PIPs
        $Script:AZVWAN = $Job.AZVWAN
        $Script:AZVHUB = $Job.AZVHUB
        $Script:AZVPNSITES = $Job.AZVPNSITES
        $Script:AZVERs = $Job.AZVERs
        $Script:CleanPIPs = $Job.CleanPIPs
        $Script:AKS = $Job.AKS
        $Script:VMSS = $Job.VMSS
        $Script:NIC = $Job.NIC
        $Script:PrivEnd = $Job.PrivEnd
        $Script:VM = $Job.VM
        $Script:ARO = $Job.ARO
        $Script:Kusto = $Job.Kusto
        $Script:AppGtw = $Job.AppGtw
        $Script:Databricks = $Job.DW
        $Script:AppWeb = $Job.AppWeb
        $Script:APIM = $Job.APIM
        $Script:LB = $Job.LB
        $Script:Bastion = $Job.Bastion
        $Script:FW = $Job.FW
        $Script:NetProf = $Job.NetProf
        $Script:Container = $Job.Container
        $Script:ANF = $Job.ANF

        $Script:etag = -join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})
        $Script:DiagID = -join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})
        $Script:CellID = -join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})

        $Script:IDNum = 0

        ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Defining XML file') | Out-File -FilePath $LogFile -Append 

        $Script:XmlWriter = New-Object System.XMl.XmlTextWriter($DDFile,$Null)

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

            $Script:XmlWriter.WriteStartElement('diagram')
            $Script:XmlWriter.WriteAttributeString('id', $DiagID)
            $Script:XmlWriter.WriteAttributeString('name', 'Network Topology')

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

                        ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Calling Stensils') | Out-File -FilePath $LogFile -Append 

                            Stensils

                            if($AZLGWs -or $AZEXPROUTEs -or $AZVERs -or $AZVPNSITES)
                                {
                                    ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Calling OnPremNet') | Out-File -FilePath $LogFile -Append 

                                    OnPremNet
                                    if($Script:FullEnvironment)
                                        {
                                            ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Calling as FullEnvironment') | Out-File -FilePath $LogFile -Append 

                                            FullEnvironment
                                        }
                                }
                            else
                                {
                                    ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Calling CloudOnly Function') | Out-File -FilePath $LogFile -Append
                                    CloudOnly
                                }


                        $Script:XmlWriter.WriteEndElement()

                    $Script:XmlWriter.WriteEndElement()

                $Script:XmlWriter.WriteEndElement()

            $Script:XmlWriter.WriteEndDocument()
            $Script:XmlWriter.Flush()
            $Script:XmlWriter.Close()                

            ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Waiting Job2 to complete') | Out-File -FilePath $LogFile -Append 

            while ($Script:jobs2.IsCompleted -contains $false) {}

            #$VNetFile = ($DiagramCache+'Network.xml')

            $Subnetfiles = Get-ChildItem -Path $DiagramCache

            ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Processing Subnet files') | Out-File -FilePath $LogFile -Append 

            foreach($SubFile in $Subnetfiles)
                {
                    if($SubFile.FullName -notin $XMLFiles)
                        {
                            $newxml = New-Object XML
                            $newxml.Load($SubFile.FullName)

                            $Innerxml = $newxml.mxfile.diagram.mxGraphModel.root.InnerXml

                            $Innerxml2 = $Innerxml.Replace('<mxCell id="0" /><mxCell id="1" parent="0" />','')

                            #force the config into an XML
                            $xml = [xml](get-content $DDFile)

                            $xmlFrag=$xml.CreateDocumentFragment()
                            $xmlFrag.InnerXml=$Innerxml2

                            $xml.mxfile.diagram.mxGraphModel.root.AppendChild($xmlFrag)

                            #save file
                            $xml.Save($DDFile)

                            Remove-Item -Path $SubFile.FullName
                        }
                }

            ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - End of Network Diagram') | Out-File -FilePath $LogFile -Append 

    } -ArgumentList $Subscriptions,$Resources,$Advisories,$DiagramCache,$FullEnvironment,$DDFile,$XMLFiles,$Logfile
}