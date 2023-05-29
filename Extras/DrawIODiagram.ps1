<#
.Synopsis
Diagram Module for Draw.io

.DESCRIPTION
This script process and creates a Draw.io Diagram based on resources present in the extraction variable $Resources. 

.Link
https://github.com/microsoft/ARI/Extras/DrawIODiagram.ps1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.0.6
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

#>
param($Subscriptions, $Resources, $Advisories, $DDFile, $DiagramCache, $FullEnvironment, $ResourceContainers)

$Global:DiagramCache = $DiagramCache

$Global:FullEnvironment = $FullEnvironment

Function Network {
    Param($Subscriptions,$Resources,$Advisories,$DiagramCache,$FullEnvironment,$DDFile,$XMLFiles)

    Start-Job -Name 'Diagram_NetworkTopology' -ScriptBlock {
        
        $Global:jobs = @()
        $Global:jobs2 = @()
        $Global:Subscriptions = $($args[0])
        $Global:Resources = $($args[1])
        $Global:Advisories = $($args[2])
        $Global:DiagramCache = $($args[3])
        $Global:FullEnvironment = $($args[4])
        $Global:DDFile  = $($args[5])
        $Global:XMLFiles  = $($args[6])

        Function Icon {    
            Param($Style,$x,$y,$w,$h,$p)
            
                $Global:XmlWriter.WriteStartElement('mxCell')
                $Global:XmlWriter.WriteAttributeString('style', $Style)
                $Global:XmlWriter.WriteAttributeString('vertex', "1")
                $Global:XmlWriter.WriteAttributeString('parent', $p)
            
                    $Global:XmlWriter.WriteStartElement('mxGeometry')
                    $Global:XmlWriter.WriteAttributeString('x', $x)
                    $Global:XmlWriter.WriteAttributeString('y', $y)
                    $Global:XmlWriter.WriteAttributeString('width', $w)
                    $Global:XmlWriter.WriteAttributeString('height', $h)
                    $Global:XmlWriter.WriteAttributeString('as', "geometry")
                    $Global:XmlWriter.WriteEndElement()
                
                $Global:XmlWriter.WriteEndElement()
            }
        
        Function VNETContainer {
            Param($x,$y,$w,$h,$title)
                $Global:ContID = (-join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})+'-'+1)
        
                $Global:XmlWriter.WriteStartElement('mxCell')
                $Global:XmlWriter.WriteAttributeString('id', $Global:ContID)
                $Global:XmlWriter.WriteAttributeString('value', "$title")
                $Global:XmlWriter.WriteAttributeString('style', "swimlane;whiteSpace=wrap;html=1;fillColor=#d5e8d4;strokeColor=#82b366;swimlaneFillColor=#D5E8D4;rounded=1;")
                $Global:XmlWriter.WriteAttributeString('vertex', "1")
                $Global:XmlWriter.WriteAttributeString('parent', "1")
            
                    $Global:XmlWriter.WriteStartElement('mxGeometry')
                    $Global:XmlWriter.WriteAttributeString('x', $x)
                    $Global:XmlWriter.WriteAttributeString('y', $y)
                    $Global:XmlWriter.WriteAttributeString('width', $w)
                    $Global:XmlWriter.WriteAttributeString('height', $h)
                    $Global:XmlWriter.WriteAttributeString('as', "geometry")
                    $Global:XmlWriter.WriteEndElement()
                
                $Global:XmlWriter.WriteEndElement()
        }
        
        Function HubContainer {
            Param($x,$y,$w,$h,$title)
                $Global:ContID = (-join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})+'-'+1)
        
                $Global:XmlWriter.WriteStartElement('mxCell')
                $Global:XmlWriter.WriteAttributeString('id', $Global:ContID)
                $Global:XmlWriter.WriteAttributeString('value', "$title")
                $Global:XmlWriter.WriteAttributeString('style', "swimlane;whiteSpace=wrap;html=1;fillColor=#dae8fc;strokeColor=#6c8ebf;rounded=1;swimlaneFillColor=#DAE8FC;")
                $Global:XmlWriter.WriteAttributeString('vertex', "1")
                $Global:XmlWriter.WriteAttributeString('parent', "1")
            
                    $Global:XmlWriter.WriteStartElement('mxGeometry')
                    $Global:XmlWriter.WriteAttributeString('x', $x)
                    $Global:XmlWriter.WriteAttributeString('y', $y)
                    $Global:XmlWriter.WriteAttributeString('width', $w)
                    $Global:XmlWriter.WriteAttributeString('height', $h)
                    $Global:XmlWriter.WriteAttributeString('as', "geometry")
                    $Global:XmlWriter.WriteEndElement()
                
                $Global:XmlWriter.WriteEndElement()
        }

        Function BrokenContainer {
            Param($x,$y,$w,$h,$title)
                $Global:ContID = (-join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})+'-'+1)
        
                $Global:XmlWriter.WriteStartElement('mxCell')
                $Global:XmlWriter.WriteAttributeString('id', $Global:ContID)
                $Global:XmlWriter.WriteAttributeString('value', "$title")
                $Global:XmlWriter.WriteAttributeString('style', "swimlane;whiteSpace=wrap;html=1;fillColor=#fad9d5;strokeColor=#ae4132;swimlaneFillColor=#FAD9D5;")
                $Global:XmlWriter.WriteAttributeString('vertex', "1")
                $Global:XmlWriter.WriteAttributeString('parent', "1")
            
                    $Global:XmlWriter.WriteStartElement('mxGeometry')
                    $Global:XmlWriter.WriteAttributeString('x', $x)
                    $Global:XmlWriter.WriteAttributeString('y', $y)
                    $Global:XmlWriter.WriteAttributeString('width', $w)
                    $Global:XmlWriter.WriteAttributeString('height', $h)
                    $Global:XmlWriter.WriteAttributeString('as', "geometry")
                    $Global:XmlWriter.WriteEndElement()
                
                $Global:XmlWriter.WriteEndElement()
        }

        Function Connect {
        Param($Source,$Target,$Parent)
        
            if($Parent){$Parent = $Parent}else{$Parent = 1}
        
            $Global:XmlWriter.WriteStartElement('mxCell')
            $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
            $Global:XmlWriter.WriteAttributeString('style', "edgeStyle=none;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;endArrow=none;endFill=0;")
            $Global:XmlWriter.WriteAttributeString('edge', "1")
            $Global:XmlWriter.WriteAttributeString('vertex', "1")
            $Global:XmlWriter.WriteAttributeString('parent', $Parent)
            $Global:XmlWriter.WriteAttributeString('source', $Source)
            $Global:XmlWriter.WriteAttributeString('target', $Target)
        
                $Global:XmlWriter.WriteStartElement('mxGeometry')
                $Global:XmlWriter.WriteAttributeString('relative', "1")
                $Global:XmlWriter.WriteAttributeString('as', "geometry")
                $Global:XmlWriter.WriteEndElement()
            
            $Global:XmlWriter.WriteEndElement()
        
        }
        
        <# Function to create the Visio document and import each stencil #>
        Function Stensils {
            $Global:Ret = "rounded=0;whiteSpace=wrap;fontSize=16;html=1;sketch=0;fontFamily=Helvetica;"
        
            $Global:IconConnections = "aspect=fixed;html=1;points=[];align=center;image;fontSize=18;image=img/lib/azure2/networking/Connections.svg;" #width="68" height="68"
            $Global:IconExpressRoute = "aspect=fixed;html=1;points=[];align=center;image;fontSize=18;image=img/lib/azure2/networking/ExpressRoute_Circuits.svg;" #width="70" height="64"
            $Global:IconVGW = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/networking/Virtual_Network_Gateways.svg;" #width="52" height="69"
            $Global:IconVGW2 = "aspect=fixed;html=1;points=[];align=center;image;fontSize=18;image=img/lib/azure2/networking/Virtual_Network_Gateways.svg;" #width="52" height="69"
            $Global:IconVNET = "aspect=fixed;html=1;points=[];align=center;image;fontSize=18;image=img/lib/azure2/networking/Virtual_Networks.svg;" #width="67" height="40"
            $Global:IconTraffic = "aspect=fixed;html=1;points=[];align=center;image;fontSize=18;image=img/lib/azure2/networking/Local_Network_Gateways.svg;" #width="68" height="68"
            $Global:IconNIC = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/networking/Network_Interfaces.svg;" #width="68" height="60"
            $Global:IconLBs = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/networking/Load_Balancers.svg;" #width="72" height="72"
            $Global:IconPVTs = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/networking/Private_Endpoint.svg;" #width="72" height="66"
            $Global:IconNSG = "aspect=fixed;html=1;points=[];align=center;image;fontSize=12;image=img/lib/azure2/networking/Network_Security_Groups.svg;" # width="26.35" height="32"
            $Global:IconUDR =  "aspect=fixed;html=1;points=[];align=center;image;fontSize=12;image=img/lib/azure2/networking/Route_Tables.svg;" #width="30.97" height="30"
            $Global:IconDDOS = "aspect=fixed;html=1;points=[];align=center;image;fontSize=12;image=img/lib/azure2/networking/DDoS_Protection_Plans.svg;" # width="23" height="28"
            $Global:IconPIP = "aspect=fixed;html=1;points=[];align=center;image;fontSize=12;image=img/lib/azure2/networking/Public_IP_Addresses.svg;" # width="65" height="52"  
            $Global:IconNAT = "aspect=fixed;html=1;points=[];align=center;image;fontSize=18;image=img/lib/azure2/networking/NAT.svg;" # width="65" height="52"            
        
            <########################## Azure Generic Stencils #############################>
        
            $Global:SymError = "sketch=0;aspect=fixed;pointerEvents=1;shadow=0;dashed=0;html=1;strokeColor=none;labelPosition=center;verticalLabelPosition=bottom;verticalAlign=top;align=center;shape=mxgraph.mscae.enterprise.not_allowed;fillColor=#EA1C24;" #width="50" height="50"
            $Global:SymInfo = "aspect=fixed;html=1;points=[];align=center;image;fontSize=12;image=img/lib/azure2/general/Information.svg;" #width="64" height="64"
            $Global:IconSubscription = "aspect=fixed;html=1;points=[];align=center;image;fontSize=20;image=img/lib/azure2/general/Subscriptions.svg;" #width="44" height="71"
            $GLobal:IconRG = "image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=12;image=img/lib/mscae/ResourceGroup.svg;" # width="37.5" height="30"
            $Global:IconBastions = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/general/Launch_Portal.svg;" #width="68" height="67"
            $Global:IconContain = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/compute/Container_Instances.svg;" #width="64" height="68"
            $Global:IconVWAN = "aspect=fixed;html=1;points=[];align=center;image;fontSize=18;image=img/lib/azure2/networking/Virtual_WANs.svg;" #width="65" height="64"
            $Global:IconCostMGMT = "aspect=fixed;html=1;points=[];align=center;image;fontSize=12;image=img/lib/azure2/general/Cost_Analysis.svg;" #width="60" height="70"
        
            <########################## Azure Computing Stencils #############################>
        
            $Global:IconVMs = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/compute/Virtual_Machine.svg;" #width="69" height="64"
            $Global:IconAKS = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/containers/Kubernetes_Services.svg;" #width="68" height="60"
            $Global:IconVMSS = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/compute/VM_Scale_Sets.svg;" # width="68" height="68"
            $Global:IconARO = "sketch=0;aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/mscae/OpenShift.svg;" #width="50" height="46"
            $Global:IconFunApps = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/compute/Function_Apps.svg;" # width="68" height="60"
        
            <########################## Azure Service Stencils #############################>
        
            $Global:IconAPIMs = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/app_services/API_Management_Services.svg;" #width="65" height="60"
            $Global:IconAPPs = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/containers/App_Services.svg;" #width="64" height="64"                   
        
            <########################## Azure Storage Stencils #############################>
        
            $Global:IconNetApp = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/storage/Azure_NetApp_Files.svg;" #width="65" height="52"
        
            <########################## Azure Storage Stencils #############################>
        
            $Global:IconDataExplorer = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/databases/Azure_Data_Explorer_Clusters.svg;" #width="68" height="68"
        
            <########################## Other Stencils #############################>
            
            $Global:IconFWs = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/networking/Firewalls.svg;" #width="71" height="60"
            $Global:IconDet =  "aspect=fixed;html=1;points=[];align=center;image;fontSize=12;image=img/lib/azure2/other/Detonation.svg;" #width="42.63" height="44"
            $Global:IconAppGWs = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/networking/Application_Gateways.svg;" #width="64" height="64"
            $Global:IconBricks = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/analytics/Azure_Databricks.svg;" #width="60" height="68"   
            $Global:IconError = "sketch=0;aspect=fixed;pointerEvents=1;shadow=0;dashed=0;html=1;strokeColor=none;labelPosition=center;verticalLabelPosition=bottom;verticalAlign=top;align=center;shape=mxgraph.mscae.enterprise.not_allowed;fillColor=#EA1C24;" #width="30" height="30"
            $Global:OnPrem = "sketch=0;aspect=fixed;html=1;points=[];align=center;image;fontSize=56;image=img/lib/mscae/Exchange_On_premises_Access.svg;" #width="168.2" height="290"
            $Global:Signature = "aspect=fixed;html=1;points=[];align=left;image;fontSize=22;image=img/lib/azure2/general/Dev_Console.svg;" #width="27.5" height="22"
            $Global:CloudOnly = "aspect=fixed;html=1;points=[];align=center;image;fontSize=56;image=img/lib/azure2/compute/Cloud_Services_Classic.svg;" #width="380.77" height="275"
        
        }
        
        <# Function to begin OnPrem environment drawing. Will begin by Local network Gateway, then Express Route.#>
        Function OnPremNet {
            $Global:VNETHistory = @()
            $Global:RoutsW = $AZVNETs | Select-Object -Property Name, @{N="Subnets";E={$_.properties.subnets.properties.addressPrefix.count}} | Sort-Object -Property Subnets -Descending
        
            $Global:Alt = 0
        
            ##################################### Local Network Gateway #############################################
        
            foreach($GTW in $AZLGWs)
            {
                if($GTW.properties.provisioningState -ne 'Succeeded')
                {
                    $Global:XmlWriter.WriteStartElement('object')            
                    $Global:XmlWriter.WriteAttributeString('label', '')
                    $Global:XmlWriter.WriteAttributeString('Status', 'This Local Network Gateway has Errors')
                    $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                        Icon $IconError 40 ($Global:Alt+25) "25" "25" 1
        
                    $Global:XmlWriter.WriteEndElement()
                }
            
                $Con1 = $AZCONs | Where-Object {$_.properties.localNetworkGateway2.id -eq $GTW.id}
                
                if(!$Con1 -and $GTW.properties.provisioningState -eq 'Succeeded')
                {
                    $Global:XmlWriter.WriteStartElement('object')            
                    $Global:XmlWriter.WriteAttributeString('label', '')
                    $Global:XmlWriter.WriteAttributeString('Status', 'No Connections were found in this Local Network Gateway')
                    $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                        Icon $SymInfo 40 ($Global:Alt+30) "20" "20" 1
        
                    $Global:XmlWriter.WriteEndElement()
                }
                
                $Name = $GTW.name
                $IP = $GTW.properties.gatewayIpAddress
        
                $Global:XmlWriter.WriteStartElement('object')            
                $Global:XmlWriter.WriteAttributeString('label', ("`n" + [string]$Name + "`n" + [string]$IP))
                $Global:XmlWriter.WriteAttributeString('Local_Address_Space', [string]$GTW.properties.localNetworkAddressSpace.addressPrefixes)
                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                    Icon $IconTraffic 50 $Global:Alt "67" "40" 1
        
                $Global:XmlWriter.WriteEndElement()                  
        
                $Global:GTWAddress = ($Global:CellID+'-'+($Global:IDNum-1))
                $Global:ConnSourceResource = 'GTW'

                OnPrem $Con1
        
                $Global:Alt = $Global:Alt + 150
            }
        
            ##################################### ERS #############################################
        
            Foreach($ERs in $AZEXPROUTEs)
            {
                if($ERs.properties.provisioningState -ne 'Succeeded')
                {
                    $Global:XmlWriter.WriteStartElement('object')            
                    $Global:XmlWriter.WriteAttributeString('label', '')
                    $Global:XmlWriter.WriteAttributeString('Status', 'This Express Route has Errors')
                    $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                        Icon $IconError 51 ($Global:Alt+25) "25" "25" 1
        
                    $Global:XmlWriter.WriteEndElement()
                }       
        
                $Con1 = $AZCONs | Where-Object {$_.properties.peer.id -eq $ERs.id}
                
                if(!$Con1 -and $ERs.properties.circuitProvisioningState -eq 'Enabled')
                {
                    $Global:XmlWriter.WriteStartElement('object')            
                    $Global:XmlWriter.WriteAttributeString('label', '')
                    $Global:XmlWriter.WriteAttributeString('Status', 'No Connections were found in this Express Route')
                    $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                        Icon $SymInfo 51 ($Global:Alt+30) "20" "20" 1
        
                    $Global:XmlWriter.WriteEndElement()
                }
        
                $Name = $ERs.name
        
                $Global:XmlWriter.WriteStartElement('object')            
                $Global:XmlWriter.WriteAttributeString('label', ("`n" +[string]$Name))
                $Global:XmlWriter.WriteAttributeString('Provider', [string]$ERs.properties.serviceProviderProperties.serviceProviderName)
                $Global:XmlWriter.WriteAttributeString('Peering_location', [string]$ERs.properties.serviceProviderProperties.peeringLocation)
                $Global:XmlWriter.WriteAttributeString('Bandwidth', [string]$ERs.properties.serviceProviderProperties.bandwidthInMbps)
                $Global:XmlWriter.WriteAttributeString('SKU', [string]$ERs.sku.tier)
                $Global:XmlWriter.WriteAttributeString('Billing_model', $ERs.sku.family)
                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                    Icon $IconExpressRoute "61.5" $Global:Alt "44" "40" 1
        
                $Global:XmlWriter.WriteEndElement()

                $Global:ERAddress = ($Global:CellID+'-'+($Global:IDNum-1))
                $Global:ConnSourceResource = 'ER'
        
                OnPrem $Con1
        
                $Global:Alt = $Global:Alt + 150
        
            }
        
            ##################################### VWAN VPNSITES #############################################
        
            foreach($GTW in $AZVPNSITES)
            {
                if($GTW.properties.provisioningState -ne 'Succeeded')
                {
                    $Global:XmlWriter.WriteStartElement('object')            
                    $Global:XmlWriter.WriteAttributeString('label', '')
                    $Global:XmlWriter.WriteAttributeString('Status', 'This VPN Site has Errors')
                    $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                        Icon $IconError 40 ($Global:Alt+25) "25" "25" 1
        
                    $Global:XmlWriter.WriteEndElement()
                }
            
                $wan1 = $AZVWAN | Where-Object {$_.properties.vpnSites.id -eq $GTW.id}
                
                if(!$wan1 -and $GTW.properties.provisioningState -eq 'Succeeded')
                {
                    $Global:XmlWriter.WriteStartElement('object')            
                    $Global:XmlWriter.WriteAttributeString('label', '')
                    $Global:XmlWriter.WriteAttributeString('Status', 'No vWANs were found in this VPN Site')
                    $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                        Icon $SymInfo 40 ($Global:Alt+30) "20" "20" 1
        
                    $Global:XmlWriter.WriteEndElement()
                }
                
                $Name = $GTW.name
        
                $Global:XmlWriter.WriteStartElement('object')            
                $Global:XmlWriter.WriteAttributeString('label', ("`n" + [string]$Name))
                $Global:XmlWriter.WriteAttributeString('Address_Space', [string]$GTW.properties.addressSpace.addressPrefixes)
                $Global:XmlWriter.WriteAttributeString('Link_Speed_In_Mbps', [string]$GTW.properties.deviceProperties.linkSpeedInMbps)
                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                    Icon $IconNAT 50 $Global:Alt "67" "40" 1
        
                $Global:XmlWriter.WriteEndElement()            
                #$tt = $tt + 200        
        
                vWan $wan1
        
                $Global:Alt = $Global:Alt + 150
            }
        
            ##################################### VWAN ERs #############################################
        
            foreach($GTW in $AZVERs)
            {
                if($GTW.properties.provisioningState -ne 'Succeeded')
                {
                    $Global:XmlWriter.WriteStartElement('object')            
                    $Global:XmlWriter.WriteAttributeString('label', '')
                    $Global:XmlWriter.WriteAttributeString('Status', 'This Express Route Circuit has Errors')
                    $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                        Icon $IconError 40 ($Global:Alt+25) "25" "25" 1
        
                    $Global:XmlWriter.WriteEndElement()
                }
            
                $wan1 = $AZVWAN | Where-Object {$_.properties.vpnSites.id -eq $GTW.id}
                
                if(!$wan1 -and $GTW.properties.provisioningState -eq 'Succeeded')
                {
                    $Global:XmlWriter.WriteStartElement('object')            
                    $Global:XmlWriter.WriteAttributeString('label', '')
                    $Global:XmlWriter.WriteAttributeString('Status', 'No vWANs were found in this Express Route Circuit')
                    $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                        Icon $SymInfo 40 ($Global:Alt+30) "20" "20" 1
        
                    $Global:XmlWriter.WriteEndElement()
                }
                
                $Name = $GTW.name
        
                $Global:XmlWriter.WriteStartElement('object')            
                $Global:XmlWriter.WriteAttributeString('label', ("`n" + [string]$Name))
                $Global:XmlWriter.WriteAttributeString('Address_Space', [string]$GTW.properties.addressSpace.addressPrefixes)
                $Global:XmlWriter.WriteAttributeString('LinkSpeed_In_Mbps', [string]$GTW.properties.deviceProperties.linkSpeedInMbps)
                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                    Icon $IconNAT 50 $Global:Alt "67" "40" 1
        
                $Global:XmlWriter.WriteEndElement()            
                #$tt = $tt + 200        
        
                vWan $wan1
        
                $Global:Alt = $Global:Alt + 150
            }
        
            ##################################### LABELs #############################################
        
            if(!$Global:FullEnvironment)
                {
        
                    $Global:XmlWriter.WriteStartElement('object')            
                    $Global:XmlWriter.WriteAttributeString('label', '')
                    $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                        Icon $Ret -520 -100 "500" ($Global:Alt + 100) 1
        
                    $Global:XmlWriter.WriteEndElement()
        
                    $Global:XmlWriter.WriteStartElement('object')            
                    $Global:XmlWriter.WriteAttributeString('label', ('On Premises'+ "`n" +'Environment'))
                    $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                        Icon $OnPrem -351 (($Global:Alt + 100)/2) "168.2" "290" 1
        
                    $Global:XmlWriter.WriteEndElement()  
        
                    label
        
                        Icon $Signature -520 ($Global:Alt + 100) "27.5" "22" 1
        
                    $Global:XmlWriter.WriteEndElement()  
                }
        
        }
        
        Function OnPrem {
        Param($Con1)
        foreach ($Con2 in $Con1)
                {
                    $Global:vnetLoc = 700
                    $VGT = $AZVGWs | Where-Object {$_.id -eq $Con2.properties.virtualNetworkGateway1.id}
                    $VGTPIP = $PIPs | Where-Object {$_.properties.ipConfiguration.id -eq $VGT.properties.ipConfigurations.id}
        
                    $Name2 = $Con2.Name
        
                    $Global:XmlWriter.WriteStartElement('object')            
                    $Global:XmlWriter.WriteAttributeString('label', [string]$Name2)
                    $Global:XmlWriter.WriteAttributeString('Connection_Type', [string]$Con2.properties.connectionType)
                    $Global:XmlWriter.WriteAttributeString('Use_Azure_Private_IP_Address', [string]$Con2.properties.useLocalAzureIpAddress)
                    $Global:XmlWriter.WriteAttributeString('Routing_Weight', [string]$Con2.properties.routingWeight)
                    $Global:XmlWriter.WriteAttributeString('Connection_Protocol', [string]$Con2.properties.connectionProtocol)
                    $Global:Source = ($Global:CellID+'-'+($Global:IDNum-1))
                    $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                        Icon $IconConnections 250 $Global:Alt "40" "40" 1
        
                    $Global:XmlWriter.WriteEndElement()
        
                    $Global:Target = ($Global:CellID+'-'+($Global:IDNum-1))
        
                    if($Global:ConnSourceResource -eq 'ER')
                        {
                            Connect $Global:ERAddress $Global:Target
                        }
                    elseif($Global:ConnSourceResource -eq 'GTW')
                        {
                            Connect $Global:GTWAddress $Global:Target
                        }
        
                    $Global:Source = $Global:Target
                    
                    $Global:XmlWriter.WriteStartElement('object')            
                    $Global:XmlWriter.WriteAttributeString('label', ("`n" +[string]$VGT.Name + "`n" + [string]$VGTPIP.properties.ipAddress))
                    $Global:XmlWriter.WriteAttributeString('VPN_Type', [string]$VGT.properties.vpnType)
                    $Global:XmlWriter.WriteAttributeString('Generation', [string]$VGT.properties.vpnGatewayGeneration )
                    $Global:XmlWriter.WriteAttributeString('SKU', [string]$VGT.properties.sku.name)
                    $Global:XmlWriter.WriteAttributeString('Gateway_Type', [string]$VGT.properties.gatewayType)
                    $Global:XmlWriter.WriteAttributeString('Active_active_mode', [string]$VGT.properties.activeActive)
                    $Global:XmlWriter.WriteAttributeString('Gateway_Private_IPs', [string]$VGT.properties.enablePrivateIpAddress)
                    $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                        Icon $IconVGW2 425 ($Global:Alt-4) "31.34" "48" 1
        
                    $Global:XmlWriter.WriteEndElement()
        
                    $Global:Target = ($Global:CellID+'-'+($Global:IDNum-1))
        
                        Connect $Global:Source $Global:Target
        
                    $Global:Source = $Global:Target
        
                    foreach($AZVNETs2 in $AZVNETs)
                    {
                        foreach($VNETTEMP in $AZVNETs2.properties.subnets.properties.ipconfigurations.id)
                        {
                            $VV4 = $VNETTEMP.Split("/")
                            $VNETTEMP1 = ($VV4[0] + '/' + $VV4[1] + '/' + $VV4[2] + '/' + $VV4[3] + '/' + $VV4[4] + '/' + $VV4[5] + '/' + $VV4[6] + '/' + $VV4[7]+ '/' + $VV4[8])
                            if($VNETTEMP1 -eq $VGT.id)
                            {
                                $Global:VNET2 = $AZVNETs2
        
                                $Global:Alt0 = $Global:Alt
                                if($VNET2.id -notin $VNETHistory.vnet)
                                    {
                                        if($VNET2.properties.addressSpace.addressPrefixes.count -ge 10)
                                        {
                                            $AddSpace = ($VNET2.properties.addressSpace.addressPrefixes | Select-Object -First 20 |  ForEach-Object {$_ + "`n"} ) + "`n" +'...'
                                        }Else{
                                            $AddSpace = ($VNET2.properties.addressSpace.addressPrefixes | ForEach-Object {$_ + "`n"})
                                        }
        
                                        $Global:XmlWriter.WriteStartElement('object')            
                                        $Global:XmlWriter.WriteAttributeString('label', ([string]$VNET2.Name + "`n" + $AddSpace))
                                        if($VNET2.properties.dhcpoptions.dnsServers)
                                            {
                                                $Global:XmlWriter.WriteAttributeString('Custom_DNS_Servers', [string]$VNET2.properties.dhcpoptions.dnsServers)
                                                $Global:XmlWriter.WriteAttributeString('DDOS_Protection', [string]$VNET2.properties.enableDdosProtection)
                                            }
                                        else
                                            {
                                                $Global:XmlWriter.WriteAttributeString('DDOS_Protection', [string]$VNET2.properties.enableDdosProtection)
                                            }
                                        $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                            Icon $IconVNET 600 $Global:Alt "65" "39" 1
        
                                        $Global:XmlWriter.WriteEndElement()      
                                        
                                        $Global:VNETDrawID = ($Global:CellID+'-'+($Global:IDNum-1))
                                                            
                                        $Global:Target = ($Global:CellID+'-'+($Global:IDNum-1))
        
                                            Connect $Global:Source $Global:Target
                            
                                        if($VNET2.properties.enableDdosProtection -eq $true)
                                        {
                                            $Global:XmlWriter.WriteStartElement('object')            
                                            $Global:XmlWriter.WriteAttributeString('label', '')
                                            $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
                                
                                                Icon $IconDDOS 580 ($Global:Alt + 15) "23" "28" 1
                                
                                            $Global:XmlWriter.WriteEndElement()
                                        }
        
                                        $Global:Source = $Global:Target
        
                                            VNETCreator $Global:VNET2
        
                                        if($VNET2.properties.virtualNetworkPeerings.properties.remoteVirtualNetwork.id)
                                            {
                                                PeerCreator $Global:VNET2
                                            }
        
                                            $tmp =@{
                                                'VNETid' = $Global:VNETDrawID;
                                                'VNET' = $AZVNETs2.id
                                            }    
                                            $Global:VNETHistory += $tmp 
                                            
                                    }
                                else
                                    {     
        
                                        $VNETDID = $VNETHistory | Where-Object {$_.VNET -eq $AZVNETs2.id}
        
                                        Connect $Global:Source $VNETDID.VNETid 
        
                                    }
                            
                                    
                                }
                        }
        
                    }
        
                    
                    if($Con1.count -gt 1)
                    {
                        $Global:Alt = $Global:Alt + 250
                    }
                }
        
        }
        
        Function vWan {
        Param($wan1)
        
            $Global:vnetLoc = 700
            $VWAN = $wan1    
        
            $Name2 = $wan1.Name
        
            $Global:XmlWriter.WriteStartElement('object')            
            $Global:XmlWriter.WriteAttributeString('label', [string]$Name2)
            $Global:XmlWriter.WriteAttributeString('allow_VnetToVnet_Traffic', [string]$wan1.properties.allowVnetToVnetTraffic)
            $Global:XmlWriter.WriteAttributeString('allow_BranchToBranch_Traffic', [string]$wan1.properties.allowBranchToBranchTraffic)
            $Global:Source = ($Global:CellID+'-'+($Global:IDNum-1))
            $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                Icon $IconVWAN 250 $Global:Alt "40" "40" 1
        
            $Global:XmlWriter.WriteEndElement()
        
            $Global:Target = ($Global:CellID+'-'+($Global:IDNum-1))
        
                Connect $Global:Source $Global:Target
        
            $Global:Source1 = $Global:Target
        
            foreach ($Con2 in $wan1.properties.virtualHubs.id)
                {
                    $VHUB = $AZVHUB | Where-Object {$_.id -eq $Con2}           
                    
                    $Global:XmlWriter.WriteStartElement('object')            
                    $Global:XmlWriter.WriteAttributeString('label', ("`n" +[string]$VHUB.Name))
                    $Global:XmlWriter.WriteAttributeString('Address_Prefix', [string]$VHUB.properties.addressPrefix)
                    $Global:XmlWriter.WriteAttributeString('Preferred_Routing_Gateway', [string]$VHUB.properties.preferredRoutingGateway)
                    $Global:XmlWriter.WriteAttributeString('Virtual_Router_Asn', [string]$VHUB.properties.virtualRouterAsn)
                    $Global:XmlWriter.WriteAttributeString('Allow_BranchToBranch_Traffic', [string]$VHUB.properties.allowBranchToBranchTraffic)
                    $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                        Icon $IconVWAN 425 $Global:Alt "40" "40" 1
        
                    $Global:XmlWriter.WriteEndElement()
        
                    $Global:Target = ($Global:CellID+'-'+($Global:IDNum-1))
        
                        Connect $Global:Source1 $Global:Target
        
                    $Global:Source = $Global:Target
        
                    foreach($AZVNETs2 in $AZVNETs)
                    {
                        foreach($VNETTEMP in $AZVNETs2.properties.virtualNetworkPeerings.properties.remoteVirtualNetwork.id)
                        {
                            $VV4 = $VNETTEMP.Split("/")
                            $VNETTEMP1 = $VV4[8]
                            if($VNETTEMP1 -like ('HV_'+$VHUB.name+'_*'))
                            {
                                $Global:VNET2 = $AZVNETs2
        
                                $Global:Alt0 = $Global:Alt
                                if($VNET2.id -notin $VNETHistory.vnet)
                                    {
                                        if($VNET2.properties.addressSpace.addressPrefixes.count -ge 10)
                                        {
                                            $AddSpace = ($VNET2.properties.addressSpace.addressPrefixes | Select-Object -First 20 |  ForEach-Object {$_ + "`n"} ) + "`n" +'...'
                                        }Else{
                                            $AddSpace = ($VNET2.properties.addressSpace.addressPrefixes | ForEach-Object {$_ + "`n"})
                                        }
        
                                        $Global:XmlWriter.WriteStartElement('object')            
                                        $Global:XmlWriter.WriteAttributeString('label', ([string]$VNET2.Name + "`n" + $AddSpace))
                                        if($VNET2.properties.dhcpoptions.dnsServers)
                                            {
                                                $Global:XmlWriter.WriteAttributeString('Custom_DNS_Servers', [string]$VNET2.properties.dhcpoptions.dnsServers)
                                                $Global:XmlWriter.WriteAttributeString('DDOS_Protection', [string]$VNET2.properties.enableDdosProtection)
                                            }
                                        else
                                            {
                                                $Global:XmlWriter.WriteAttributeString('DDOS_Protection', [string]$VNET2.properties.enableDdosProtection)
                                            }
                                        $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                            Icon $IconVNET 600 $Global:Alt "65" "39" 1
        
                                        $Global:XmlWriter.WriteEndElement()      
                                        
                                        $Global:VNETDrawID = ($Global:CellID+'-'+($Global:IDNum-1))
                                                            
                                        $Global:Target = ($Global:CellID+'-'+($Global:IDNum-1))
        
                                            Connect $Global:Source $Global:Target
                            
                                        if($VNET2.properties.enableDdosProtection -eq $true)
                                        {
                                            $Global:XmlWriter.WriteStartElement('object')            
                                            $Global:XmlWriter.WriteAttributeString('label', '')
                                            $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
                                
                                                Icon $IconDDOS 580 ($Global:Alt + 15) "23" "28" 1
                                
                                            $Global:XmlWriter.WriteEndElement()
                                        }
        
                                            VNETCreator $Global:VNET2
        
                                        if($VNET2.properties.virtualNetworkPeerings.properties.remoteVirtualNetwork.id -and $VNET2.properties.virtualNetworkPeerings.properties.remoteVirtualNetwork.id -notlike ('*/HV_'+$VHUB.name+'_*'))
                                            {
                                                PeerCreator $Global:VNET2
                                            }
        
                                            $tmp =@{
                                                'VNETid' = $Global:VNETDrawID;
                                                'VNET' = $AZVNETs2.id
                                            }    
                                            $Global:VNETHistory += $tmp 
                                            
                                    }
                                else
                                    {     
        
                                        $VNETDID = $VNETHistory | Where-Object {$_.VNET -eq $AZVNETs2.id}
        
                                        Connect $Global:Source $VNETDID.VNETid 
        
                                    }
                            
                                    
                                }
                        }
        
        
                    }
        
                    
                    if($Con1.count -gt 1)
                    {
                        $Global:Alt = $Global:Alt + 250
                    }
                }
        
        }
        
        <# Function for Cloud Only Environments #>
        Function CloudOnly {
        $Global:RoutsW = $AZVNETs | Select-Object -Property Name, @{N="Subnets";E={$_.properties.subnets.properties.addressPrefix.count}} | Sort-Object -Property Subnets -Descending
        
        $Global:VNETHistory = @()
        $Global:vnetLoc = 700
        $Global:Alt = 2
        
            foreach($AZVNETs2 in $AZVNETs)
                {             
                    $Global:VNET2 = $AZVNETs2
        
                    $Global:Alt0 = $Global:Alt
                    if($VNET2.id -notin $VNETHistory.vnet)
                        {
        
                            if($VNET2.properties.addressSpace.addressPrefixes.count -ge 10)
                            {
                                $AddSpace = ($VNET2.properties.addressSpace.addressPrefixes | Select-Object -First 20 |  ForEach-Object {$_ + "`n"} ) + "`n" +'...'
                            }Else{
                                $AddSpace = ($VNET2.properties.addressSpace.addressPrefixes | ForEach-Object {$_ + "`n"})
                            }
        
                            $Global:XmlWriter.WriteStartElement('object')            
                            $Global:XmlWriter.WriteAttributeString('label', ([string]$VNET2.Name + "`n" + $AddSpace))
                            if($VNET2.properties.dhcpoptions.dnsServers)
                                {
                                    $Global:XmlWriter.WriteAttributeString('Custom_DNS_Servers', [string]$VNET2.properties.dhcpoptions.dnsServers)
                                    $Global:XmlWriter.WriteAttributeString('DDOS_Protection', [string]$VNET2.properties.enableDdosProtection)
                                }
                            else
                                {
                                    $Global:XmlWriter.WriteAttributeString('DDOS_Protection', [string]$VNET2.properties.enableDdosProtection)
                                }
                            $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                Icon $IconVNET 600 $Global:Alt "65" "39" 1
        
                            $Global:XmlWriter.WriteEndElement()      
                            
                            $Global:VNETDrawID = ($Global:CellID+'-'+($Global:IDNum-1))
                                                
                            $Global:Target = ($Global:CellID+'-'+($Global:IDNum-1))
                
                            if($VNET2.properties.enableDdosProtection -eq $true)
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', '')
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
                    
                                    Icon $IconDDOS 580 ($Global:Alt + 15) "23" "28" 1
                    
                                $Global:XmlWriter.WriteEndElement()
                            }
        
                            $Global:Source = $Global:Target
        
                                VNETCreator $Global:VNET2
        
                            if($VNET2.properties.virtualNetworkPeerings.properties.remoteVirtualNetwork.id)
                                {
                                    PeerCreator $Global:VNET2
                                }
        
                                $tmp =@{
                                    'VNETid' = $Global:VNETDrawID;
                                    'VNET' = $AZVNETs2.id
                                }    
                                $Global:VNETHistory += $tmp 
                                            
                        }
                    }
        
                    $Global:XmlWriter.WriteStartElement('object')            
                    $Global:XmlWriter.WriteAttributeString('label', '')
                    $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                        Icon $Ret -520 -100 "500" ($Global:Alt + 100) 1
        
                    $Global:XmlWriter.WriteEndElement()
        
                    $Global:XmlWriter.WriteStartElement('object')            
                    $Global:XmlWriter.WriteAttributeString('label', ('Cloud Only'+ "`n" +'Environment'))
                    $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                        Icon $Global:CloudOnly -460 (($Global:Alt + 100)/2) "380" "275" 1
        
                    $Global:XmlWriter.WriteEndElement()  
        
                    label
        
                        Icon $Signature -520 ($Global:Alt + 100) "27.5" "22" 1
        
                    $Global:XmlWriter.WriteEndElement()  
        
        }
        
        Function FullEnvironment {
            foreach($AZVNETs2 in $AZVNETs)
                {             
                    $Global:VNET2 = $AZVNETs2
        
                    if($VNET2.id -notin $VNETHistory.vnet)
                        {
                            if($VNET2.properties.addressSpace.addressPrefixes.count -ge 10)
                            {
                                $AddSpace = ($VNET2.properties.addressSpace.addressPrefixes | Select-Object -First 20 |  ForEach-Object {$_ + "`n"} ) + "`n" +'...'
                            }Else{
                                $AddSpace = ($VNET2.properties.addressSpace.addressPrefixes | ForEach-Object {$_ + "`n"})
                            }
        
                            $Global:XmlWriter.WriteStartElement('object')            
                            $Global:XmlWriter.WriteAttributeString('label', ([string]$VNET2.Name + "`n" + $AddSpace))
                            if($VNET2.properties.dhcpoptions.dnsServers)
                                {
                                    $Global:XmlWriter.WriteAttributeString('Custom_DNS_Servers', [string]$VNET2.properties.dhcpoptions.dnsServers)
                                    $Global:XmlWriter.WriteAttributeString('DDOS_Protection', [string]$VNET2.properties.enableDdosProtection)
                                }
                            else
                                {
                                    $Global:XmlWriter.WriteAttributeString('DDOS_Protection', [string]$VNET2.properties.enableDdosProtection)
                                }
                            $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                Icon $IconVNET 600 $Global:Alt "65" "39" 1
        
                            $Global:XmlWriter.WriteEndElement()
        
                            VNETCreator $Global:VNET2
        
                            if($VNET2.properties.virtualNetworkPeerings.properties.remoteVirtualNetwork.id)
                                {
                                    PeerCreator $Global:VNET2
                                }  
                        }
        
                        $Global:Alt = $Global:Alt + 250
                    }
        
                    $Global:XmlWriter.WriteStartElement('object')            
                    $Global:XmlWriter.WriteAttributeString('label', '')
                    $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                        Icon $Ret -520 -100 "500" ($Global:Alt + 100) 1
        
                    $Global:XmlWriter.WriteEndElement()
        
                    $Global:XmlWriter.WriteStartElement('object')            
                    $Global:XmlWriter.WriteAttributeString('label', ('On Premises'+ "`n" +'Environment'))
                    $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                        Icon $OnPrem -351 (($Global:Alt + 100)/2) "168.2" "290" 1
        
                    $Global:XmlWriter.WriteEndElement()  
        
                    label
        
                        Icon $Signature -520 ($Global:Alt + 100) "27.5" "22" 1
        
                    $Global:XmlWriter.WriteEndElement()  
        
        }
        
        <# Function for VNET creation #>
        Function VNETCreator {
        Param($VNET2)
                $Global:sizeL =  $VNET2.properties.subnets.properties.addressPrefix.count
                if($VNET2.id -notin $VNETHistory.vnet)
                    {
                    if ($Global:sizeL -gt 5)
                    {            
                        $Global:sizeL = $Global:sizeL / 2
                        $Global:sizeL = [math]::ceiling($Global:sizeL)
                        $Global:sizeC = $Global:sizeL
                        $Global:sizeL = (($Global:sizeL * 210) + 30)

                        if('gatewaysubnet' -in $VNET2.properties.subnets.name)
                            {
                                HubContainer ($Global:vnetLoc) ($Global:Alt0 - 20) $Global:sizeL "490" $VNET2.Name
                            }
                        else
                            {
                                VNETContainer ($Global:vnetLoc) ($Global:Alt0 - 20) $Global:sizeL "490" $VNET2.Name
                            }
        
                            
                        
                        $Global:VNETSquare = ($Global:CellID+'-'+($Global:IDNum-1))
        
                        $SubName = $Subscriptions | Where-Object {$_.id -eq $VNET2.subscriptionId}
        
                        $Global:XmlWriter.WriteStartElement('object')            
                        $Global:XmlWriter.WriteAttributeString('label', $SubName.name)
                        $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                            Icon $IconSubscription $Global:sizeL 460 "67" "40" $Global:ContID
        
                        $Global:XmlWriter.WriteEndElement()  
        
                        $ADVS = ''
                        $ADVS = $Advisories | Where-Object {$_.Properties.Category -eq 'Cost' -and $_.Properties.resourceMetadata.resourceId -eq ('/subscriptions/'+$SubName.id)}
                        If($ADVS)
                        {
                            $Count = 1
                            $Global:XmlWriter.WriteStartElement('object')            
                            $Global:XmlWriter.WriteAttributeString('label', '')
        
                            foreach ($ADV in $ADVS)
                                {
                                    $Attr1 = ('Recommendation'+[string]$Count)
                                    $Global:XmlWriter.WriteAttributeString($Attr1, [string]$ADV.Properties.shortDescription.solution)
        
                                    $Count ++
                                }
        
                            $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                Icon $IconCostMGMT ($Global:sizeL + 150) 460 "30" "35" $Global:ContID
        
                            $Global:XmlWriter.WriteEndElement()
                            
                        }
        
                        Subnet ($Global:vnetLoc + 15) $VNET2 $Global:IDNum $Global:DiagramCache $Global:ContID 
        
                        if($Global:VNETPIP)
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', '')
        
                                $Count = 1
                                Foreach ($PIPDetail in $Global:VNETPIP)
                                    {
                                        $Attr1 = ('PublicIP-'+[string]("{0:d3}" -f $Count)+'-Name')
                                        $Attr2 = ('PublicIP-'+[string]("{0:d3}" -f $Count)+'-IP')
                                        $Global:XmlWriter.WriteAttributeString($Attr1, [string]$PIPDetail.name)
                                        $Global:XmlWriter.WriteAttributeString($Attr2, [string]$PIPDetail.properties.ipaddress)
        
                                        $Count ++
                                    }
        
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $IconDet ($Global:sizeL + 500) 225 "42.63" "44" $Global:ContID
        
                                $Global:XmlWriter.WriteEndElement()
                                
                                    Connect ($Global:CellID+'-'+($Global:IDNum-1)) $Global:ContID $Global:ContID
                            }
        
                            $Global:Alt = $Global:Alt + 650
                    }
                else
                    {
                        $Global:sizeL = (($Global:sizeL * 210) + 30)
        
                        if('gatewaysubnet' -in $VNET2.properties.subnets.name)
                            {
                                HubContainer ($Global:vnetLoc) ($Global:Alt0 - 15) $Global:sizeL "260" $VNET2.Name
                            }
                        else
                            {
                                VNETContainer ($Global:vnetLoc) ($Global:Alt0 - 15) $Global:sizeL "260" $VNET2.Name
                            }

        
                        $Global:VNETSquare = ($Global:CellID+'-'+($Global:IDNum-1))
        
                        $SubName = $Subscriptions | Where-Object {$_.id -eq $VNET2.subscriptionId}
        
                        $Global:XmlWriter.WriteStartElement('object')            
                        $Global:XmlWriter.WriteAttributeString('label', $SubName.name)
                        $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                            Icon $IconSubscription $Global:sizeL 225 "67" "40" $Global:ContID
        
                        $Global:XmlWriter.WriteEndElement()  
        
                        $ADVS = ''
                        $ADVS = $Advisories | Where-Object {$_.Properties.Category -eq 'Cost' -and $_.Properties.resourceMetadata.resourceId -eq ('/subscriptions/'+$SubName.id)}
                        If($ADVS)
                        {
                            $Count = 1
                            $Global:XmlWriter.WriteStartElement('object')            
                            $Global:XmlWriter.WriteAttributeString('label', '')
        
                            foreach ($ADV in $ADVS)
                                {
                                    $Attr1 = ('Recommendation'+[string]$Count)
                                    $Global:XmlWriter.WriteAttributeString($Attr1, [string]$ADV.Properties.shortDescription.solution)
        
                                    $Count ++
                                }
        
                            $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                Icon $IconCostMGMT ($Global:sizeL + 150) 225 "30" "35" $Global:ContID
        
                            $Global:XmlWriter.WriteEndElement()
        
                        }
        
                        Subnet ($Global:vnetLoc + 15) $VNET2 $Global:IDNum $Global:DiagramCache $Global:ContID
        
                        if($Global:VNETPIP)
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', '')
        
                                $Count = 1
                                Foreach ($PIPDetail in $Global:VNETPIP)
                                    {
                                        $Attr1 = ('PublicIP-'+[string]("{0:d3}" -f $Count)+'-Name')
                                        $Attr2 = ('PublicIP-'+[string]("{0:d3}" -f $Count)+'-IP')
                                        $Global:XmlWriter.WriteAttributeString($Attr1, [string]$PIPDetail.name)
                                        $Global:XmlWriter.WriteAttributeString($Attr2, [string]$PIPDetail.properties.ipaddress)
        
                                        $Count ++
                                    }
        
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $IconDet ($Global:sizeL + 500) 107 "42.63" "44" $Global:ContID
        
                                $Global:XmlWriter.WriteEndElement()
                                
                                    Connect ($Global:CellID+'-'+($Global:IDNum-1)) $Global:ContID $Global:ContID
                            }
                        $Global:Alt = $Global:Alt + 350 
                    }
                }
        }
        
        <# Function for create peered VNETs #>
        Function PeerCreator {
        Param($VNET2)
        
            $Global:vnetLoc1 = $Global:Alt                                    
        
            Foreach ($Peer in $VNET2.properties.virtualNetworkPeerings)
                {
                    $VNETSUB = $AZVNETs | Where-Object {$_.id -eq $Peer.properties.remoteVirtualNetwork.id}                                                
        
                    if($VNETSUB.id -in $VNETHistory.VNET)
                        {        
                            $VNETDID = $VNETHistory | Where-Object {$_.VNET -eq $VNETSUB.id}
        
                            $Global:XmlWriter.WriteStartElement('object')
                            $Global:XmlWriter.WriteAttributeString('label', '')
                            $Global:XmlWriter.WriteAttributeString('Peering_Name', $Peer.name)
                            $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
            
                                $Global:XmlWriter.WriteStartElement('mxCell')
                                $Global:XmlWriter.WriteAttributeString('style', "edgeStyle=none;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;endArrow=none;endFill=0;")
                                $Global:XmlWriter.WriteAttributeString('edge', "1")
                                $Global:XmlWriter.WriteAttributeString('vertex', "1")
                                $Global:XmlWriter.WriteAttributeString('parent', "1")
                                $Global:XmlWriter.WriteAttributeString('source', $Global:VNETDrawID)
                                $Global:XmlWriter.WriteAttributeString('target', $VNETDID.VNETid)
            
                                    $Global:XmlWriter.WriteStartElement('mxGeometry')
                                    $Global:XmlWriter.WriteAttributeString('relative', "1")
                                    $Global:XmlWriter.WriteAttributeString('as', "geometry")
                                    $Global:XmlWriter.WriteEndElement()
                                
                                $Global:XmlWriter.WriteEndElement()
            
                            $Global:XmlWriter.WriteEndElement()
                        }
                    else
                    {
                        $Global:sizeL =  $VNETSUB.properties.subnets.properties.addressPrefix.count
                        $BrokenVNET = if($VNETSUB.properties.subnets.properties.addressPrefix.count){'Not Broken'}else{'Broken'}                                                                                                                                       
                        
                        if($VNETSUB.properties.addressSpace.addressPrefixes.count -ge 10)
                        {
                            $AddSpace = ($VNETSUB.properties.addressSpace.addressPrefixes | Select-Object -First 20 |  ForEach-Object {$_ + "`n"} ) + "`n" +'...'
                        }Else{
                            $AddSpace = ($VNETSUB.properties.addressSpace.addressPrefixes | ForEach-Object {$_ + "`n"})
                        }
        
                        $Global:XmlWriter.WriteStartElement('object')            
                        $Global:XmlWriter.WriteAttributeString('label', ($VNETSUB.name + "`n" + $AddSpace))
                        if($VNETSUB.properties.dhcpoptions.dnsServers)
                            {
                                $Global:XmlWriter.WriteAttributeString('Custom_DNS_Servers', [string]$VNETSUB.properties.dhcpoptions.dnsServers)
                                $Global:XmlWriter.WriteAttributeString('DDOS_Protection', [string]$VNETSUB.properties.enableDdosProtection)
                            }
                        else
                            {
                                $Global:XmlWriter.WriteAttributeString('DDOS_Protection', [string]$VNETSUB.properties.enableDdosProtection)
                            }
                        $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                            Icon $IconVNET $Global:vnetLoc $Global:vnetLoc1 "67" "40" 1
        
                        $Global:XmlWriter.WriteEndElement()
        
        
                        $TwoTarget = ($Global:CellID+'-'+($Global:IDNum-1))
        
                        $Global:XmlWriter.WriteStartElement('object')            
                        $Global:XmlWriter.WriteAttributeString('label', '')
                        $Global:XmlWriter.WriteAttributeString('Peering_Name', $Peer.name)
                        $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                            $Global:XmlWriter.WriteStartElement('mxCell')
                            $Global:XmlWriter.WriteAttributeString('style', "edgeStyle=none;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;endArrow=none;endFill=0;")
                            $Global:XmlWriter.WriteAttributeString('edge', "1")
                            $Global:XmlWriter.WriteAttributeString('vertex', "1")
                            $Global:XmlWriter.WriteAttributeString('parent', "1")
                            $Global:XmlWriter.WriteAttributeString('source', $Global:Source)
                            $Global:XmlWriter.WriteAttributeString('target', $TwoTarget)
        
                                $Global:XmlWriter.WriteStartElement('mxGeometry')
                                $Global:XmlWriter.WriteAttributeString('relative', "1")
                                $Global:XmlWriter.WriteAttributeString('as', "geometry")
                                $Global:XmlWriter.WriteEndElement()
                            
                            $Global:XmlWriter.WriteEndElement()
        
                        $Global:XmlWriter.WriteEndElement()
        
        
                        if($VNETSUB.properties.enableDdosProtection -eq $true)
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', '')
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
                    
                                    Icon $IconDDOS ($Global:vnetLoc - 20) ($Global:vnetLoc1 + 15) "23" "28" 1
                    
                                $Global:XmlWriter.WriteEndElement()
                            }
        
        
                        if ($Global:sizeL -gt 5)
                            {
                                $Global:sizeL = $Global:sizeL / 2
                                $Global:sizeL = [math]::ceiling($Global:sizeL)
                                $Global:sizeC = $Global:sizeL
                                $Global:sizeL = (($Global:sizeL * 210) + 30)

                                if('gatewaysubnet' -in $VNETSUB.properties.subnets.name)
                                    {
                                        HubContainer ($Global:vnetLoc + 100) ($Global:vnetLoc1 - 20) $Global:sizeL "490" $VNETSUB.name
                                    }
                                else
                                    {
                                        VNETContainer ($Global:vnetLoc + 100) ($Global:vnetLoc1 - 20) $Global:sizeL "490" $VNETSUB.name
                                    }
        
                                $Global:VNETSquare = ($Global:CellID+'-'+($Global:IDNum-1))
        
                                $SubName = $Subscriptions | Where-Object {$_.id -eq $VNETSUB.subscriptionId}
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', $SubName.name)
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $IconSubscription $Global:sizeL 460 "67" "40" $Global:ContID
        
                                $Global:XmlWriter.WriteEndElement()                    
        
                                $ADVS = ''
                                $ADVS = $Advisories | Where-Object {$_.Properties.Category -eq 'Cost' -and $_.Properties.resourceMetadata.resourceId -eq ('/subscriptions/'+$SubName.id)}
                                If($ADVS)
                                    {
                                        $Count = 1
                                        $Global:XmlWriter.WriteStartElement('object')            
                                        $Global:XmlWriter.WriteAttributeString('label', '')
        
                                        foreach ($ADV in $ADVS)
                                            {
                                                $Attr1 = ('Recommendation'+[string]$Count)
                                                $Global:XmlWriter.WriteAttributeString($Attr1, [string]$ADV.Properties.shortDescription.solution)
        
                                                $Count ++
                                            }
        
                                        $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                            Icon $IconCostMGMT ($Global:sizeL + 150) 460 "30" "35" $Global:ContID
        
                                        $Global:XmlWriter.WriteEndElement()
                                        
                                    }
        
                                    Subnet ($Global:vnetLoc + 120) $VNETSUB $Global:IDNum $Global:DiagramCache $Global:ContID
        
                                    $Global:vnetLoc1 = $Global:vnetLoc1 + 230 
        
                                if($Global:VNETPIP)
                                    {
                                        $Global:XmlWriter.WriteStartElement('object')            
                                        $Global:XmlWriter.WriteAttributeString('label', '')
                    
                                        $Count = 1
                                        Foreach ($PIPDetail in $Global:VNETPIP)
                                            {
                                                $Attr1 = ('PublicIP-'+[string]("{0:d3}" -f $Count)+'-Name')
                                                $Attr2 = ('PublicIP-'+[string]("{0:d3}" -f $Count)+'-IP')
                                                $Global:XmlWriter.WriteAttributeString($Attr1, [string]$PIPDetail.name)
                                                $Global:XmlWriter.WriteAttributeString($Attr2, [string]$PIPDetail.properties.ipaddress)
                    
                                                $Count ++
                                            }
                    
                                        $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
                    
                                            Icon $IconDet ($Global:sizeL + 500) 225 "42.63" "44" $Global:ContID
                    
                                        $Global:XmlWriter.WriteEndElement()
                                        
                                            Connect ($Global:CellID+'-'+($Global:IDNum-1)) $Global:ContID $Global:ContID
                                    }  
        
                                $Global:Alt = $Global:Alt + 650                                                                         
                            }
                        else
                            {
                                $Global:sizeL = (($Global:sizeL * 210) + 30)
        
                                if($BrokenVNET -eq 'Not Broken')
                                    {                                        
                                        if('gatewaysubnet' -in $VNETSUB.properties.subnets.name)
                                            {
                                                HubContainer ($Global:vnetLoc + 100) ($Global:vnetLoc1 - 20) $Global:sizeL "260" $VNETSUB.name
                                            }
                                        else
                                            {
                                                VNETContainer ($Global:vnetLoc + 100) ($Global:vnetLoc1 - 20) $Global:sizeL "260" $VNETSUB.name
                                            }
                                    }
                                else
                                    {
                                        BrokenContainer ($Global:vnetLoc + 100) ($Global:vnetLoc1 - 20) "250" "260" 'Broken Peering'
                                        $Global:sizeL = '250'
                                    }
        
                                $Global:VNETSquare = ($Global:CellID+'-'+($Global:IDNum-1))
        
                                $SubName = $Subscriptions | Where-Object {$_.id -eq $VNETSUB.subscriptionId}
        
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', $SubName.name)
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $IconSubscription $Global:sizeL 225 "67" "40" $Global:ContID
        
                                $Global:XmlWriter.WriteEndElement()  
        
                                $ADVS = ''
                                $ADVS = $Advisories | Where-Object {$_.Properties.Category -eq 'Cost' -and $_.Properties.resourceMetadata.resourceId -eq ('/subscriptions/'+$SubName.id)}
                                If($ADVS)
                                    {
                                        $Count = 1
                                        $Global:XmlWriter.WriteStartElement('object')            
                                        $Global:XmlWriter.WriteAttributeString('label', '')
        
                                        foreach ($ADV in $ADVS)
                                            {
                                                $Attr1 = ('Recommendation'+[string]$Count)
                                                $Global:XmlWriter.WriteAttributeString($Attr1, [string]$ADV.Properties.shortDescription.solution)
        
                                                $Count ++
                                            }
        
                                        $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                            Icon $IconCostMGMT ($Global:sizeL + 150) 225 "30" "35" $Global:ContID
        
                                        $Global:XmlWriter.WriteEndElement()
                                        
                                    }
        
                                    Subnet ($Global:vnetLoc + 120) $VNETSUB $Global:IDNum $Global:DiagramCache $Global:ContID
        
                                if($Global:VNETPIP)
                                    {
                                        $Global:XmlWriter.WriteStartElement('object')            
                                        $Global:XmlWriter.WriteAttributeString('label', '')
                    
                                        $Count = 1
                                        Foreach ($PIPDetail in $Global:VNETPIP)
                                            {
                                                $Attr1 = ('PublicIP-'+[string]("{0:d3}" -f $Count)+'-Name')
                                                $Attr2 = ('PublicIP-'+[string]("{0:d3}" -f $Count)+'-IP')
                                                $Global:XmlWriter.WriteAttributeString($Attr1, [string]$PIPDetail.name)
                                                $Global:XmlWriter.WriteAttributeString($Attr2, [string]$PIPDetail.properties.ipaddress)
                    
                                                $Count ++
                                            }
                    
                                        $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
                    
                                            Icon $IconDet ($Global:sizeL+ 500) 107 "42.63" "44" $Global:ContID
                    
                                        $Global:XmlWriter.WriteEndElement()
                                        
                                        Connect ($Global:CellID+'-'+($Global:IDNum-1)) $Global:ContID $Global:ContID
        
                                    }
        
                            }
                            
                        $tmp =@{
                            'VNETid' = $TwoTarget;
                            'VNET' = $VNETSUB.id
                        }    
                        $Global:VNETHistory += $tmp 
        
                        $Global:vnetLoc1 = $Global:vnetLoc1 + 350                                         
                    }
                }
            $Global:Alt = $Global:vnetLoc1
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
                    $Global:Ret = "rounded=0;whiteSpace=wrap;fontSize=16;html=1;sketch=0;fontFamily=Helvetica;"
                
                    $Global:IconConnections = "aspect=fixed;html=1;points=[];align=center;image;fontSize=18;image=img/lib/azure2/networking/Connections.svg;" #width="68" height="68"
                    $Global:IconExpressRoute = "aspect=fixed;html=1;points=[];align=center;image;fontSize=18;image=img/lib/azure2/networking/ExpressRoute_Circuits.svg;" #width="70" height="64"
                    $Global:IconVGW = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/networking/Virtual_Network_Gateways.svg;" #width="52" height="69"
                    $Global:IconVGW2 = "aspect=fixed;html=1;points=[];align=center;image;fontSize=18;image=img/lib/azure2/networking/Virtual_Network_Gateways.svg;" #width="52" height="69"
                    $Global:IconVNET = "aspect=fixed;html=1;points=[];align=center;image;fontSize=18;image=img/lib/azure2/networking/Virtual_Networks.svg;" #width="67" height="40"
                    $Global:IconTraffic = "aspect=fixed;html=1;points=[];align=center;image;fontSize=18;image=img/lib/azure2/networking/Local_Network_Gateways.svg;" #width="68" height="68"
                    $Global:IconNIC = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/networking/Network_Interfaces.svg;" #width="68" height="60"
                    $Global:IconLBs = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/networking/Load_Balancers.svg;" #width="72" height="72"
                    $Global:IconPVTs = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/networking/Private_Endpoint.svg;" #width="72" height="66"
                    $Global:IconNSG = "aspect=fixed;html=1;points=[];align=center;image;fontSize=12;image=img/lib/azure2/networking/Network_Security_Groups.svg;" # width="26.35" height="32"
                    $Global:IconUDR =  "aspect=fixed;html=1;points=[];align=center;image;fontSize=12;image=img/lib/azure2/networking/Route_Tables.svg;" #width="30.97" height="30"
                    $Global:IconDDOS = "aspect=fixed;html=1;points=[];align=center;image;fontSize=12;image=img/lib/azure2/networking/DDoS_Protection_Plans.svg;" # width="23" height="28"
                    $Global:IconPIP = "aspect=fixed;html=1;points=[];align=center;image;fontSize=12;image=img/lib/azure2/networking/Public_IP_Addresses.svg;" # width="65" height="52"  
                    $Global:IconNAT = "aspect=fixed;html=1;points=[];align=center;image;fontSize=18;image=img/lib/azure2/networking/NAT.svg;" # width="65" height="52"            
                
                    <########################## Azure Generic Stencils #############################>
                
                    $Global:SymError = "sketch=0;aspect=fixed;pointerEvents=1;shadow=0;dashed=0;html=1;strokeColor=none;labelPosition=center;verticalLabelPosition=bottom;verticalAlign=top;align=center;shape=mxgraph.mscae.enterprise.not_allowed;fillColor=#EA1C24;" #width="50" height="50"
                    $Global:SymInfo = "aspect=fixed;html=1;points=[];align=center;image;fontSize=12;image=img/lib/azure2/general/Information.svg;" #width="64" height="64"
                    $Global:IconSubscription = "aspect=fixed;html=1;points=[];align=center;image;fontSize=20;image=img/lib/azure2/general/Subscriptions.svg;" #width="44" height="71"
                    $GLobal:IconRG = "image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=12;image=img/lib/mscae/ResourceGroup.svg;" # width="37.5" height="30"
                    $Global:IconBastions = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/general/Launch_Portal.svg;" #width="68" height="67"
                    $Global:IconContain = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/compute/Container_Instances.svg;" #width="64" height="68"
                    $Global:IconVWAN = "aspect=fixed;html=1;points=[];align=center;image;fontSize=18;image=img/lib/azure2/networking/Virtual_WANs.svg;" #width="65" height="64"
                    $Global:IconCostMGMT = "aspect=fixed;html=1;points=[];align=center;image;fontSize=12;image=img/lib/azure2/general/Cost_Analysis.svg;" #width="60" height="70"
                
                    <########################## Azure Computing Stencils #############################>
                
                    $Global:IconVMs = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/compute/Virtual_Machine.svg;" #width="69" height="64"
                    $Global:IconAKS = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/containers/Kubernetes_Services.svg;" #width="68" height="60"
                    $Global:IconVMSS = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/compute/VM_Scale_Sets.svg;" # width="68" height="68"
                    $Global:IconARO = "sketch=0;aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/mscae/OpenShift.svg;" #width="50" height="46"
                    $Global:IconFunApps = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/compute/Function_Apps.svg;" # width="68" height="60"
                
                    <########################## Azure Service Stencils #############################>
                
                    $Global:IconAPIMs = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/app_services/API_Management_Services.svg;" #width="65" height="60"
                    $Global:IconAPPs = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/containers/App_Services.svg;" #width="64" height="64"                   
                
                    <########################## Azure Storage Stencils #############################>
                
                    $Global:IconNetApp = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/storage/Azure_NetApp_Files.svg;" #width="65" height="52"
                
                    <########################## Azure Storage Stencils #############################>
                
                    $Global:IconDataExplorer = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/databases/Azure_Data_Explorer_Clusters.svg;" #width="68" height="68"
                
                    <########################## Other Stencils #############################>
                    
                    $Global:IconFWs = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/networking/Firewalls.svg;" #width="71" height="60"
                    $Global:IconDet =  "aspect=fixed;html=1;points=[];align=center;image;fontSize=12;image=img/lib/azure2/other/Detonation.svg;" #width="42.63" height="44"
                    $Global:IconAppGWs = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/networking/Application_Gateways.svg;" #width="64" height="64"
                    $Global:IconBricks = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/analytics/Azure_Databricks.svg;" #width="60" height="68"   
                    $Global:IconError = "sketch=0;aspect=fixed;pointerEvents=1;shadow=0;dashed=0;html=1;strokeColor=none;labelPosition=center;verticalLabelPosition=bottom;verticalAlign=top;align=center;shape=mxgraph.mscae.enterprise.not_allowed;fillColor=#EA1C24;" #width="30" height="30"
                    $Global:OnPrem = "sketch=0;aspect=fixed;html=1;points=[];align=center;image;fontSize=56;image=img/lib/mscae/Exchange_On_premises_Access.svg;" #width="168.2" height="290"
                    $Global:Signature = "aspect=fixed;html=1;points=[];align=left;image;fontSize=22;image=img/lib/azure2/general/Dev_Console.svg;" #width="27.5" height="22"
                    $Global:CloudOnly = "aspect=fixed;html=1;points=[];align=center;image;fontSize=56;image=img/lib/azure2/compute/Cloud_Services_Classic.svg;" #width="380.77" height="275"
                
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
                        if($null -eq $TrueTemp)
                            {
                                $AKS = $resources | Where-Object {$_.type -eq 'microsoft.containerservice/managedclusters'}
                                if($sub.id -in $AKS.properties.agentPoolProfiles.vnetSubnetID)
                                    {
                                        $TrueTemp = 'AKS'
                                    }
                            }
                        if($null -eq $TrueTemp)
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
                    
                    
                        <#################################################### FIND RESOURCE NAME AND DETAILS #################################################################>
                    
                    
                        if($TrueTemp -eq 'networkInterfaces')
                            {
                                $NIcNames = $resources | Where-Object {$_.type -eq 'microsoft.network/networkinterfaces' -and $_.properties.ipConfigurations.properties.subnet.id -eq $sub.id}
                    
                                if($sub.properties.privateEndpoints.id)
                                    {
                                        $PrivEndNames = $resources | Where-Object {$_.type -eq 'microsoft.network/privateendpoints' -and $_.properties.networkInterfaces.id -in $NIcNames.id}
                                        $TrueTemp = 'privateLinkServices'
                                        $RESNames = $PrivEndNames
                                    }
                                else
                                    {                    
                                        $VMNamesAro = $resources | Where-Object {$_.type -eq 'microsoft.compute/virtualmachines' -and $_.properties.networkprofile.networkInterfaces.id -in $NIcNames.id}
                                        if($VMNamesAro.properties.storageprofile.imageReference.offer -like 'aro*')
                                            {
                                                $AROs = $Resources | Where-Object {$_.Type -eq 'microsoft.redhatopenshift/openshiftclusters'}
                                                $ARONames = $AROs | Where-Object {$_.properties.masterprofile.subnetId -eq $sub.id -or $_.properties.workerProfiles.subnetId -eq $sub.id}
                                                $TrueTemp = 'Open Shift'
                                                $RESNames = $ARONames
                                            }
                                        if($TrueTemp -ne 'Open Shift')
                                            {
                                                $VMs = @()
                                                $VMNames = ($resources | Where-Object {$_.type -eq 'microsoft.compute/virtualmachines'}).properties.networkprofile.networkInterfaces.id | Where-Object {$_ -in $NIcNames.id}
                                                foreach($NIC in $VMNames)
                                                    {
                                                        $VMs += $resources | Where-Object {$_.type -eq 'microsoft.compute/virtualmachines' -and $NIC -in $_.properties.networkprofile.networkInterfaces.id}
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
                                $AKSNames = $resources | Where-Object {$_.type -eq 'microsoft.containerservice/managedclusters' -and $_.properties.agentPoolProfiles.vnetSubnetID -eq $sub.id}
                                $RESNames = $AKSNames            
                            }
                        if($TrueTemp -eq 'Data Explorer Clusters')
                            {
                                $KustoNames = $resources | Where-Object {$_.type -eq 'Microsoft.Kusto/clusters' -and $_.properties.virtualNetworkConfiguration.subnetid -eq $sub.id}
                                $RESNames = $KustoNames
                            }
                        if($TrueTemp -eq 'applicationGateways')
                            {
                                $AppGTWNames = $resources | Where-Object {$_.type -eq 'microsoft.network/applicationgateways' -and $_.properties.gatewayIPConfigurations.id -in $sub.properties.applicationGatewayIPConfigurations.id}
                                $RESNames = $AppGTWNames
                            }
                        if($TrueTemp -eq 'DataBricks')
                            {
                                $DatabriksNames = @()
                                $Databricks = $Resources | Where-Object {$_.Type -eq 'Microsoft.Databricks/workspaces'}
                                Foreach($Data in $Databricks)
                                    {                 
                                        if($Data.properties.parameters.customVirtualNetworkId.value+'/subnets/'+$Data.properties.parameters.customPrivateSubnetName.value -eq $sub.id -or $Data.properties.parameters.customVirtualNetworkId.value+'/subnets/'+$Data.properties.parameters.custompublicSubnetName.value -eq $sub.id)
                                            {                         
                                            $DatabriksNames += $Data
                                            }
                                    }
                                $RESNames = $DatabriksNames     
                            }
                        if($TrueTemp -eq 'App Service')
                            {
                                $Apps = $Resources | Where-Object {$_.Type -eq 'microsoft.web/sites' -and $_.properties.virtualNetworkSubnetId -eq $Sub.id}
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
                                $APIMNames = $Resources | Where-Object {$_.Type -eq 'Microsoft.ApiManagement/service' -and $_.properties.virtualNetworkConfiguration.subnetResourceId -eq $sub.id}
                                $RESNames = $APIMNames
                            }
                        if($TrueTemp -eq 'loadBalancers')
                            {
                                $LBNames = $Resources | Where-Object {$_.Type -eq 'microsoft.network/loadbalancers' -and $_.properties.frontendIPConfigurations.id -in $sub.properties.ipconfigurations.id}
                                $RESNames = $LBNames
                            }
                        if($TrueTemp -eq 'virtualMachineScaleSets')
                            {
                                $VMSSNames = $Resources | Where-Object {$_.Type -eq 'microsoft.compute/virtualMachineScaleSets' -and $_.properties.virtualMachineProfile.networkProfile.networkInterfaceConfigurations.properties.ipconfigurations.properties.subnet.id -eq $sub.id }
                                $RESNames = $VMSSNames
                            }
                        if($TrueTemp -eq 'virtualNetworkGateways')
                            {
                                $VPNGTWNames = $Resources | Where-Object {$_.Type -eq 'microsoft.network/virtualnetworkgateways' -and $_.properties.ipconfigurations.properties.subnet.id -eq $sub.id }
                                $RESNames = $VPNGTWNames
                            }
                        if($TrueTemp -eq 'bastionHosts')
                            {
                                $BastionNames = $Resources | Where-Object {$_.Type -eq 'microsoft.network/bastionhosts' -and $_.properties.ipConfigurations.properties.subnet.id -eq $sub.id }
                                $RESNames = $BastionNames
                            }
                        if($TrueTemp -eq 'azureFirewalls')
                            {
                                $AzFWNames = $Resources | Where-Object {$_.Type -eq 'microsoft.network/azurefirewalls' -and $_.properties.ipConfigurations.properties.subnet.id -eq $sub.id }
                                $RESNames = $AzFWNames
                            }
                        if($TrueTemp -eq 'Container Instance')
                            {
                                $ContainerNames = ''
                                $ContNICs = $resources | Where-Object {$_.Type -eq 'microsoft.network/networkprofiles' -and $_.properties.containerNetworkInterfaceConfigurations.properties.ipconfigurations.properties.subnet.id -eq $sub.id}
                                $ContainerNames = $Resources | Where-Object {$_.Type -eq 'Microsoft.ContainerInstance/containerGroups' -and $_.properties.networkprofile.id -in $ContNICs.id}
                                $RESNames = $ContainerNames
                                if([string]::IsNullOrEmpty($ContainerNames))
                                    {
                                        $AROs = $Resources | Where-Object {$_.Type -eq 'microsoft.redhatopenshift/openshiftclusters'}
                                        $ARONames = $AROs | Where-Object {$_.properties.masterprofile.subnetId -eq $sub.id -or $_.properties.workerProfiles.subnetId -eq $sub.id}
                                        $TrueTemp = 'Open Shift'
                                        $RESNames = $ARONames
                                    }
                            }
                        if($TrueTemp -eq 'NetApp')
                            {
                                $NetAppNames = $Resources | Where-Object {$_.Type -eq 'microsoft.netapp/netappaccounts/capacitypools/volumes' -and $_.properties.subnetId -eq $sub.id }
                                $RESNames = $NetAppNames
                            }               
                    
                        <###################################################### DROP THE ICONS ######################################################>
                    
                        switch ($TrueTemp)
                            {
                                'Virtual Machine' {
                                                    if($RESNames.count -gt 1)
                                                        {
                                                            $Global:XmlTempWriter.WriteStartElement('object')            
                                                            $Global:XmlTempWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' VMs'))                                        
                                            
                                                            $Count = 1
                                                            foreach ($VMName in $RESNames.Name)
                                                            {
                                                                $Attr1 = ('VirtualMachine-'+[string]("{0:d3}" -f $Count))
                                                                $Global:XmlTempWriter.WriteAttributeString($Attr1, [string]$VMName)
                    
                                                                $Count ++
                                                            }
                                                            $Global:XmlTempWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
                    
                                                                Icon2 $IconVMs ($subloc+64) ($Alt0+40) "69" "64" $ContainerID
                                            
                                                            $Global:XmlTempWriter.WriteEndElement()  
                                                        }
                                                    else
                                                        {
                    
                                                            $Global:XmlTempWriter.WriteStartElement('object')            
                                                            $Global:XmlTempWriter.WriteAttributeString('label', [string]$RESNames.Name)
                                                            $Global:XmlTempWriter.WriteAttributeString('VM_Size', [string]$RESNames.properties.hardwareProfile.vmSize)
                                                            $Global:XmlTempWriter.WriteAttributeString('OS', [string]$RESNames.properties.storageProfile.osDisk.osType)
                                                            $Global:XmlTempWriter.WriteAttributeString('OS_Disk_Size_GB', [string]$RESNames.properties.storageProfile.osDisk.diskSizeGB)
                                                            $Global:XmlTempWriter.WriteAttributeString('Image_Publisher', [string]$RESNames.properties.storageProfile.imageReference.publisher)
                                                            $Global:XmlTempWriter.WriteAttributeString('Image_SKU', [string]$RESNames.properties.storageProfile.imageReference.sku)
                                                            $Global:XmlTempWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))                        
                    
                                                                Icon2 $IconVMs ($subloc+64) ($Alt0+40) "69" "64" $ContainerID
                                            
                                                            $Global:XmlTempWriter.WriteEndElement() 
                    
                                                        }                                                                                                                                    
                                                    }
                                'AKS' {                                                
                                                    if($RESNames.count -gt 1)
                                                        {
                                                            $Global:XmlTempWriter.WriteStartElement('object')            
                                                            $Global:XmlTempWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' AKS Clusters'))                                        
                                            
                                                            $Count = 1
                                                            foreach ($AKSName in $RESNames.Name)
                                                            {
                                                                $Attr1 = ('Kubernetes_Cluster-'+[string]("{0:d3}" -f $Count))
                                                                $Global:XmlTempWriter.WriteAttributeString($Attr1, [string]$AKSName)
                    
                                                                $Count ++
                                                            }
                                                            $Global:XmlTempWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
                    
                                                                Icon2 $IconAKS ($subloc+65) ($Alt0+40) "68" "64" $ContainerID
                                            
                                                            $Global:XmlTempWriter.WriteEndElement()
                    
                                                        }
                                                    else 
                                                        {
                                                            $Global:XmlTempWriter.WriteStartElement('object')            
                                                            $Global:XmlTempWriter.WriteAttributeString('label', [string]$RESNames.name)                                        
                                            
                                                            $Count = 1
                                                            foreach($Pool in $RESNames.properties.agentPoolProfiles)
                                                            {
                                                                $Attr1 = ('Node_Pool-'+[string]("{0:d3}" -f $Count)+'-Name')
                                                                $Attr2 = ('Node_Pool-'+[string]("{0:d3}" -f $Count)+'-Count')
                                                                $Attr3 = ('Node_Pool-'+[string]("{0:d3}" -f $Count)+'-Size')
                                                                $Attr4 = ('Node_Pool-'+[string]("{0:d3}" -f $Count)+'-Version')
                                                                $Attr5 = ('Node_Pool-'+[string]("{0:d3}" -f $Count)+'-Mode')
                                                                $Attr6 = ('Node_Pool-'+[string]("{0:d3}" -f $Count)+'-Max_Pods')
                    
                                                                $Global:XmlTempWriter.WriteAttributeString($Attr1, [string]$Pool.name)
                                                                $Global:XmlTempWriter.WriteAttributeString($Attr2, [string]($Pool | Select-Object -Property 'count').count)
                                                                $Global:XmlTempWriter.WriteAttributeString($Attr3, [string]$Pool.vmSize)
                                                                $Global:XmlTempWriter.WriteAttributeString($Attr4, [string]$Pool.orchestratorVersion)
                                                                $Global:XmlTempWriter.WriteAttributeString($Attr5, [string]$Pool.mode)
                                                                $Global:XmlTempWriter.WriteAttributeString($Attr6, [string]$Pool.maxPods)
                    
                                                                $Count ++
                                                            }
                                                            $Global:XmlTempWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
                    
                                                                Icon2 $IconAKS ($subloc+65) ($Alt0+40) "68" "64" $ContainerID
                                            
                                                            $Global:XmlTempWriter.WriteEndElement()
                    
                                                            }
                                                    }
                                'virtualMachineScaleSets' {                                                                                  
                                                    if($RESNames.count -gt 1)
                                                        {
                                                            $Global:XmlTempWriter.WriteStartElement('object')            
                                                            $Global:XmlTempWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' Virtual Machine Scale Sets'))                                        
                                            
                                                            $Count = 1
                                                            foreach ($ResName in $RESNames.Name)
                                                            {
                                                                $Attr1 = ('VMSS-'+[string]("{0:d3}" -f $Count))
                                                                $Global:XmlTempWriter.WriteAttributeString($Attr1, [string]$ResName)
                    
                                                                $Count ++
                                                            }
                                                            $Global:XmlTempWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
                    
                                                                Icon2 $IconVMSS ($subloc+65) ($Alt0+40) "68" "68" $ContainerID
                                            
                                                            $Global:XmlTempWriter.WriteEndElement()
                    
                                                        }
                                                    else
                                                        {
                                                            $Global:XmlTempWriter.WriteStartElement('object')            
                                                            $Global:XmlTempWriter.WriteAttributeString('label', [string]$RESNames.name)                                        
                                            
                                                            $Global:XmlTempWriter.WriteAttributeString('VMSS_Name', [string]$RESNames.name)
                                                            $Global:XmlTempWriter.WriteAttributeString('Instances', [string]$temp[0].Count)
                                                            $Global:XmlTempWriter.WriteAttributeString('VMSS_SKU_Tier', [string]$RESNames.sku.tier)
                                                            $Global:XmlTempWriter.WriteAttributeString('VMSS_Upgrade_Policy', [string]$RESNames.Properties.upgradePolicy.mode)
                    
                                                            $Global:XmlTempWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
                    
                                                                Icon2 $IconVMSS ($subloc+65) ($Alt0+40) "68" "68" $ContainerID
                                            
                                                            $Global:XmlTempWriter.WriteEndElement()
                                                        }                                                                        
                                                    } 
                                'loadBalancers' {                                                    
                                                    if($RESNames.count -gt 1)
                                                        {
                                                            $Global:XmlTempWriter.WriteStartElement('object')            
                                                            $Global:XmlTempWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' Load Balancers'))                                        
                                            
                                                            $Count = 1
                                                            foreach ($ResName in $RESNames)
                                                            {
                                                                $Attr1 = ('LB-'+[string]("{0:d3}" -f $Count)+'-Name')
                                                                $Attr2 = ('LB-'+[string]("{0:d3}" -f $Count)+'-SKU')
                                                                $Attr3 = ('LB-'+[string]("{0:d3}" -f $Count)+'-Backends')
                                                                $Attr4 = ('LB-'+[string]("{0:d3}" -f $Count)+'-Frontends')
                                                                $Attr5 = ('LB-'+[string]("{0:d3}" -f $Count)+'-LB_Rules')
                                                                $Attr6 = ('LB-'+[string]("{0:d3}" -f $Count)+'-Probes')
                    
                                                                $Global:XmlTempWriter.WriteAttributeString($Attr1, [string]$ResName.name)
                                                                $Global:XmlTempWriter.WriteAttributeString($Attr2, [string]$ResName.sku.name)
                                                                $Global:XmlTempWriter.WriteAttributeString($Attr3, [string]$ResName.properties.backendAddressPools.properties.backendIPConfigurations.id.count)
                                                                $Global:XmlTempWriter.WriteAttributeString($Attr4, [string]$ResName.properties.frontendIPConfigurations.properties.count)
                                                                $Global:XmlTempWriter.WriteAttributeString($Attr5, [string]$ResName.properties.loadBalancingRules.count)
                                                                $Global:XmlTempWriter.WriteAttributeString($Attr6, [string]$ResName.properties.probes.count)
                    
                                                                $Count ++
                                                            }
                                                            $Global:XmlTempWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
                    
                                                                Icon2 $IconLBs ($subloc+65) ($Alt0+40) "72" "72" $ContainerID
                                            
                                                            $Global:XmlTempWriter.WriteEndElement()
                    
                                                        }
                                                    else 
                                                        {            
                                                            $Global:XmlTempWriter.WriteStartElement('object')            
                                                            $Global:XmlTempWriter.WriteAttributeString('label', [string]$RESNames.Name)                                        
                    
                                                            $Global:XmlTempWriter.WriteAttributeString('Load_Balancer_Name', [string]$ResNames.name)
                                                            $Global:XmlTempWriter.WriteAttributeString('Load_Balancer_SKU', [string]$ResNames.sku.name)
                                                            $Global:XmlTempWriter.WriteAttributeString('Backends', [string]$ResNames.properties.backendAddressPools.properties.backendIPConfigurations.id.count)
                                                            $Global:XmlTempWriter.WriteAttributeString('Frontends', [string]$ResNames.properties.frontendIPConfigurations.properties.count)
                                                            $Global:XmlTempWriter.WriteAttributeString('LB_Rules', [string]$ResNames.properties.loadBalancingRules.count)
                                                            $Global:XmlTempWriter.WriteAttributeString('Probes', [string]$ResNames.properties.probes.count)
                    
                                                            $Global:XmlTempWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
                    
                                                                Icon2 $IconLBs ($subloc+65) ($Alt0+40) "72" "72" $ContainerID
                                            
                                                            $Global:XmlTempWriter.WriteEndElement()
                                                            
                                                        }
                                                    } 
                                'virtualNetworkGateways' {                                                    
                                                    if($RESNames.count -gt 1)
                                                        {
                                                            $Global:XmlTempWriter.WriteStartElement('object')            
                                                            $Global:XmlTempWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' Virtual Network Gateways'))                                        
                                            
                                                            $Count = 1
                                                            foreach ($ResName in $RESNames)
                                                            {
                                                                $Attr1 = ('Network_Gateway-'+[string]("{0:d3}" -f $Count)+'-Name')
                    
                                                                $Global:XmlTempWriter.WriteAttributeString($Attr1, [string]$ResName.name)
                    
                                                                $Count ++
                                                            }
                                                            $Global:XmlTempWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
                    
                                                                Icon2 $IconVGW ($subloc+80) ($Alt0+40) "52" "69" $ContainerID
                                            
                                                            $Global:XmlTempWriter.WriteEndElement()
                    
                                                        }
                                                    else
                                                        {
                                                            $Global:XmlTempWriter.WriteStartElement('object')            
                                                            $Global:XmlTempWriter.WriteAttributeString('label', [string]$RESNames.Name)                                        
                                            
                                                            $Global:XmlTempWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
                    
                                                                Icon2 $IconVGW ($subloc+80) ($Alt0+40) "52" "69" $ContainerID
                                            
                                                            $Global:XmlTempWriter.WriteEndElement()
                                                        }                                                                                                         
                                                    } 
                                'azureFirewalls' {                                                    
                                                    if($RESNames.count -gt 1)
                                                        {
                                                            $Global:XmlTempWriter.WriteStartElement('object')            
                                                            $Global:XmlTempWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' Firewalls'))                                        
                                            
                                                            $Count = 1
                                                            foreach ($ResName in $RESNames)
                                                            {
                                                                $Attr1 = ('Firewall-'+[string]("{0:d3}" -f $Count)+'-Name')
                                                                $Attr2 = ('Firewall-'+[string]("{0:d3}" -f $Count)+'-SKU')
                                                                $Attr3 = ('Firewall-'+[string]("{0:d3}" -f $Count)+'-Threat_Intel_Mode')
                    
                                                                $Global:XmlTempWriter.WriteAttributeString($Attr1, [string]$ResName.name)
                                                                $Global:XmlTempWriter.WriteAttributeString($Attr2, [string]$ResName.properties.sku.tier)
                                                                $Global:XmlTempWriter.WriteAttributeString($Attr3, [string]$ResName.properties.threatIntelMode)
                    
                                                                $Count ++
                                                            }
                                                            $Global:XmlTempWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
                    
                                                                Icon2 $IconFWs ($subloc+65) ($Alt0+40) "71" "60" $ContainerID
                                            
                                                            $Global:XmlTempWriter.WriteEndElement()
                                                        }
                                                    else 
                                                        {
                                                            $Global:XmlTempWriter.WriteStartElement('object')            
                                                            $Global:XmlTempWriter.WriteAttributeString('label', [string]$RESNames.name)      
                                                            
                    
                                                            $Global:XmlTempWriter.WriteAttributeString('Firewall_Name', [string]$ResNames.name)
                                                            $Global:XmlTempWriter.WriteAttributeString('SKU_Tier', [string]$ResNames.properties.sku.tier)
                                                            $Global:XmlTempWriter.WriteAttributeString('Threat_Intel_Mode', [string]$ResNames.properties.threatIntelMode)
                    
                                                            $Global:XmlTempWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
                    
                                                                Icon2 $IconFWs ($subloc+65) ($Alt0+40) "71" "60" $ContainerID
                                            
                                                            $Global:XmlTempWriter.WriteEndElement()
                                                        }                                                                
                                                    } 
                                'privateLinkServices' {                                                    
                                                    if($RESNames.count -gt 1)
                                                        {
                                                            $Global:XmlTempWriter.WriteStartElement('object')            
                                                            $Global:XmlTempWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' Private Endpoints'))                                        
                                            
                                                            $Count = 1
                                                            foreach ($ResName in $RESNames)
                                                            {
                                                                $Attr1 = ('PVE-'+[string]("{0:d3}" -f $Count)+'-Name')
                    
                                                                $Global:XmlTempWriter.WriteAttributeString($Attr1, [string]$ResName.name)
                    
                                                                $Count ++
                                                            }
                                                            $Global:XmlTempWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
                    
                                                                Icon2 $IconPVTs ($subloc+65) ($Alt0+40) "72" "66" $ContainerID
                                            
                                                            $Global:XmlTempWriter.WriteEndElement()
                    
                                                        }
                                                    else
                                                        {
                                                            $Global:XmlTempWriter.WriteStartElement('object')            
                                                            $Global:XmlTempWriter.WriteAttributeString('label', [string]$RESNames.Name)                                        
                                                            $Global:XmlTempWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
                    
                                                                Icon2 $IconPVTs ($subloc+65) ($Alt0+40) "72" "66" $ContainerID
                                            
                                                            $Global:XmlTempWriter.WriteEndElement()
                                                        }                                                                       
                                                    } 
                                'applicationGateways' {                                                    
                                                    if($RESNames.count -gt 1)
                                                        {
                                                            $Global:XmlTempWriter.WriteStartElement('object')            
                                                            $Global:XmlTempWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' Application Gateways'))                                        
                                            
                                                            $Count = 1
                                                            foreach ($ResName in $RESNames)
                                                            {
                                                                $Attr1 = ('App_Gateway-'+[string]("{0:d3}" -f $Count)+'-Name')
                                                                $Attr2 = ('App_Gateway-'+[string]("{0:d3}" -f $Count)+'-SKU')
                                                                $Attr3 = ('App_Gateway-'+[string]("{0:d3}" -f $Count)+'-Min_Capacity')
                                                                $Attr4 = ('App_Gateway-'+[string]("{0:d3}" -f $Count)+'-Max_Capacity')
                    
                                                                $Global:XmlTempWriter.WriteAttributeString($Attr1, [string]$ResName.name)
                                                                $Global:XmlTempWriter.WriteAttributeString($Attr2, [string]$RESName.Properties.sku.tier)
                                                                $Global:XmlTempWriter.WriteAttributeString($Attr3, [string]$RESName.Properties.autoscaleConfiguration.minCapacity)
                                                                $Global:XmlTempWriter.WriteAttributeString($Attr4, [string]$RESName.Properties.autoscaleConfiguration.maxCapacity)
                    
                                                                $Count ++
                                                            }
                                                            $Global:XmlTempWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
                    
                                                                Icon2 $IconAppGWs ($subloc+65) ($Alt0+40) "64" "64" $ContainerID
                                            
                                                            $Global:XmlTempWriter.WriteEndElement()
                    
                                                        }
                                                    else
                                                        {
                                                            $Global:XmlTempWriter.WriteStartElement('object')            
                                                            $Global:XmlTempWriter.WriteAttributeString('label', [string]$RESNames.Name)                                                            
                    
                                                            $Global:XmlTempWriter.WriteAttributeString('App_Gateway_Name', [string]$ResNames.name)
                                                            $Global:XmlTempWriter.WriteAttributeString('App_Gateway_SKU', [string]$RESNames.Properties.sku.tier)
                                                            $Global:XmlTempWriter.WriteAttributeString('Autoscale_Min_Capacity', [string]$RESNames.Properties.autoscaleConfiguration.minCapacity)
                                                            $Global:XmlTempWriter.WriteAttributeString('Autoscale_Max_Capacity', [string]$RESNames.Properties.autoscaleConfiguration.maxCapacity)
                    
                                                            $Global:XmlTempWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
                    
                                                                Icon2 $IconAppGWs ($subloc+65) ($Alt0+40) "64" "64" $ContainerID
                                            
                                                            $Global:XmlTempWriter.WriteEndElement()
                                                        }                                                                                                                                                                             
                                                    }
                                'bastionHosts' {                                                    
                                                    if($RESNames.count -gt 1)
                                                        {
                                                            $Global:XmlTempWriter.WriteStartElement('object')            
                                                            $Global:XmlTempWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' Bastion Hosts'))                                        
                                            
                                                            $Count = 1
                                                            foreach ($ResName in $RESNames)
                                                            {
                                                                $Attr1 = ('Bastion-'+[string]("{0:d3}" -f $Count)+'-Name')
                    
                                                                $Global:XmlTempWriter.WriteAttributeString($Attr1, [string]$ResName.name)
                    
                                                                $Count ++
                                                            }
                                                            $Global:XmlTempWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
                    
                                                                Icon2 $IconBastions ($subloc+65) ($Alt0+40) "68" "67" $ContainerID
                                            
                                                            $Global:XmlTempWriter.WriteEndElement()
                                                        }
                                                    else 
                                                        {
                                                            $Global:XmlTempWriter.WriteStartElement('object')            
                                                            $Global:XmlTempWriter.WriteAttributeString('label', [string]$RESNames.name)                                                            
                                                            $Global:XmlTempWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
                    
                                                                Icon2 $IconBastions ($subloc+65) ($Alt0+40) "68" "67" $ContainerID
                                            
                                                            $Global:XmlTempWriter.WriteEndElement()
                    
                                                        }                                                                        
                                                    } 
                                'APIM' {                                
                                                    $Global:XmlTempWriter.WriteStartElement('object')            
                                                    $Global:XmlTempWriter.WriteAttributeString('label', [string]$RESNames.Name)                                                            
                    
                                                    $APIMHost = [string]($RESNames.properties.hostnameConfigurations | Where-Object {$_.defaultSslBinding -eq $true}).hostname
                    
                                                    $Global:XmlTempWriter.WriteAttributeString('APIM_Name', [string]$ResNames.name)
                                                    $Global:XmlTempWriter.WriteAttributeString('SKU', [string]$RESNames.sku.name)
                                                    $Global:XmlTempWriter.WriteAttributeString('VNET_Type', [string]$RESNames.properties.virtualNetworkType)
                                                    $Global:XmlTempWriter.WriteAttributeString('Default_Hostname', $APIMHost)
                    
                                                    $Global:XmlTempWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
                    
                                                        Icon2 $IconAPIMs ($subloc+65) ($Alt0+40) "65" "60" $ContainerID
                                    
                                                    $Global:XmlTempWriter.WriteEndElement()
                                                
                                                    }
                                'App Service' {
                                                    if($ServiceAppNames)
                                                        {
                                                            if($RESNames.count -gt 1)
                                                                {
                                                                    $Global:XmlTempWriter.WriteStartElement('object')            
                                                                    $Global:XmlTempWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' App Services'))                                        
                                                    
                                                                    $Count = 1
                                                                    foreach ($ResName in $RESNames)
                                                                    {
                                                                        $Attr1 = ('AppService-'+[string]("{0:d3}" -f $Count)+'-Name')
                            
                                                                        $Global:XmlTempWriter.WriteAttributeString($Attr1, [string]$ResName.name)
                            
                                                                        $Count ++
                                                                    }
                                                                    $Global:XmlTempWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
                            
                                                                        Icon2 $IconAPPs ($subloc+65) ($Alt0+40) "64" "64" $ContainerID
                                                    
                                                                    $Global:XmlTempWriter.WriteEndElement()
                                                                }
                                                            else
                                                                {
                                                                    $Global:XmlTempWriter.WriteStartElement('object')            
                                                                    $Global:XmlTempWriter.WriteAttributeString('label', [string]$ResNames.name)                                                                        
                            
                                                                    $Global:XmlTempWriter.WriteAttributeString('App_Name', [string]$ResNames.name)
                                                                    $Global:XmlTempWriter.WriteAttributeString('Default_Hostname', [string]$RESNames.properties.defaultHostName)
                                                                    $Global:XmlTempWriter.WriteAttributeString('Enabled', [string]$RESNames.properties.enabled)
                                                                    $Global:XmlTempWriter.WriteAttributeString('State', [string]$RESNames.properties.state)
                                                                    $Global:XmlTempWriter.WriteAttributeString('Inbound_IP_Address', [string]$RESNames.properties.inboundIpAddress)
                                                                    $Global:XmlTempWriter.WriteAttributeString('Kind', [string]$RESNames.properties.kind)
                                                                    $Global:XmlTempWriter.WriteAttributeString('SKU', [string]$RESNames.properties.sku)
                                                                    $Global:XmlTempWriter.WriteAttributeString('Workers', [string]$RESNames.properties.siteConfig.numberOfWorkers)
                                                                    $Global:XmlTempWriter.WriteAttributeString('Min_Workers', [string]$RESNames.properties.siteConfig.minimumElasticInstanceCount)
                                                                    $Global:XmlTempWriter.WriteAttributeString('Site_Properties', [string]$RESNames.properties.siteProperties.properties.value)
                    
                    
                                                                    $Global:XmlTempWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
                            
                                                                        Icon2 $IconAPPs ($subloc+65) ($Alt0+40) "64" "64" $ContainerID
                                                    
                                                                    $Global:XmlTempWriter.WriteEndElement()
                                                                }
                                                        }                                                                                                                                  
                                                    }
                                'Function App' {    
                                                    if($FuntionAppNames)
                                                        {                                                
                                                            if($RESNames.count -gt 1)
                                                                {
                                                                    $Global:XmlTempWriter.WriteStartElement('object')            
                                                                    $Global:XmlTempWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' Function Apps'))                                        
                                                    
                                                                    $Count = 1
                                                                    foreach ($ResName in $RESNames)
                                                                    {
                                                                        $Attr1 = ('FunctionApp-'+[string]("{0:d3}" -f $Count)+'-Name')
                            
                                                                        $Global:XmlTempWriter.WriteAttributeString($Attr1, [string]$ResName.name)
                            
                                                                        $Count ++
                                                                    }
                                                                    $Global:XmlTempWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
                            
                                                                        Icon2 $IconFunApps ($subloc+65) ($Alt0+40) "68" "60" $ContainerID
                                                    
                                                                    $Global:XmlTempWriter.WriteEndElement()
                                                                }
                                                            else
                                                                {
                                                                    $Global:XmlTempWriter.WriteStartElement('object')            
                                                                    $Global:XmlTempWriter.WriteAttributeString('label', [string]$ResNames.name)                                                                        
                            
                                                                    $Global:XmlTempWriter.WriteAttributeString('App_Name', [string]$ResNames.name)
                                                                    $Global:XmlTempWriter.WriteAttributeString('Default_Hostname', [string]$RESNames.properties.defaultHostName)
                                                                    $Global:XmlTempWriter.WriteAttributeString('Enabled', [string]$RESNames.properties.enabled)
                                                                    $Global:XmlTempWriter.WriteAttributeString('State', [string]$RESNames.properties.state)
                                                                    $Global:XmlTempWriter.WriteAttributeString('Inbound_IP_Address', [string]$RESNames.properties.inboundIpAddress)
                                                                    $Global:XmlTempWriter.WriteAttributeString('Kind', [string]$RESNames.properties.kind)
                                                                    $Global:XmlTempWriter.WriteAttributeString('SKU', [string]$RESNames.properties.sku)
                                                                    $Global:XmlTempWriter.WriteAttributeString('Workers', [string]$RESNames.properties.siteConfig.numberOfWorkers)
                                                                    $Global:XmlTempWriter.WriteAttributeString('Min_Workers', [string]$RESNames.properties.siteConfig.minimumElasticInstanceCount)
                                                                    $Global:XmlTempWriter.WriteAttributeString('Site_Properties', [string]$RESNames.properties.siteProperties.properties.value)
                    
                                                                    $Global:XmlTempWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
                            
                                                                        Icon2 $IconFunApps ($subloc+65) ($Alt0+40) "68" "60" $ContainerID
                                                    
                                                                    $Global:XmlTempWriter.WriteEndElement()
                    
                                                                }
                                                        }
                                                    }
                                'DataBricks' {      
                                                    if($DatabriksNames)
                                                        {                                              
                                                        if($RESNames.count -gt 1)
                                                            {
                                                                $Global:XmlTempWriter.WriteStartElement('object')            
                                                                $Global:XmlTempWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' Databricks'))                                        
                                                
                                                                $Count = 1
                                                                foreach ($ResName in $RESNames)
                                                                {
                                                                    $Attr1 = ('Databrick-'+[string]("{0:d3}" -f $Count)+'-Name')
                        
                                                                    $Global:XmlTempWriter.WriteAttributeString($Attr1, [string]$ResName.name)
                        
                                                                    $Count ++
                                                                }
                                                                $Global:XmlTempWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
                        
                                                                    Icon2 $IconBricks ($subloc+65) ($Alt0+40) "60" "68" $ContainerID
                                                
                                                                $Global:XmlTempWriter.WriteEndElement()
                                                            }
                                                        else
                                                            {
                                                                $Global:XmlTempWriter.WriteStartElement('object')            
                                                                $Global:XmlTempWriter.WriteAttributeString('label', [string]$RESNames.Name)                                                                
                        
                                                                $Global:XmlTempWriter.WriteAttributeString('Databrick_Name', [string]$ResNames.name)
                                                                $Global:XmlTempWriter.WriteAttributeString('Workspace_URL', [string]$RESNames.properties.workspaceUrl )
                                                                $Global:XmlTempWriter.WriteAttributeString('Pricing_Tier', [string]$RESNames.sku.name)
                                                                $Global:XmlTempWriter.WriteAttributeString('Storage_Account', [string]$RESNames.properties.parameters.storageAccountName.value)
                                                                $Global:XmlTempWriter.WriteAttributeString('Storage_Account_SKU', [string]$RESNames.properties.parameters.storageAccountSkuName.value)
                                                                $Global:XmlTempWriter.WriteAttributeString('Relay_Namespace', [string]$RESNames.properties.parameters.relayNamespaceName.value)
                                                                $Global:XmlTempWriter.WriteAttributeString('Require_Infrastructure_Encryption', [string]$RESNames.properties.parameters.requireInfrastructureEncryption.value)
                                                                $Global:XmlTempWriter.WriteAttributeString('Enable_Public_IP', [string]$RESNames.properties.parameters.enableNoPublicIp.value)
                        
                                                                $Global:XmlTempWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
                        
                                                                    Icon2 $IconBricks ($subloc+65) ($Alt0+40) "60" "68" $ContainerID
                                                
                                                                $Global:XmlTempWriter.WriteEndElement()
                                                            }                                                                                               
                                                        }
                                                    }
                                'Open Shift' {        
                                                    if($ARONames)
                                                        {
                                                            if($RESNames.count -gt 1)
                                                                {
                                                                    $Global:XmlTempWriter.WriteStartElement('object')            
                                                                    $Global:XmlTempWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' OpenShift Clusters'))                                        
                                                    
                                                                    $Count = 1
                                                                    foreach ($ResName in $RESNames)
                                                                    {
                                                                        $Attr1 = ('OpenShift_Cluster-'+[string]("{0:d3}" -f $Count)+'-Name')
                            
                                                                        $Global:XmlTempWriter.WriteAttributeString($Attr1, [string]$ResName.name)
                            
                                                                        $Count ++
                                                                    }
                                                                    $Global:XmlTempWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
                            
                                                                        Icon2 $IconARO ($subloc+65) ($Alt0+40) "68" "60" $ContainerID
                    
                                                                    $Global:XmlTempWriter.WriteEndElement()
                    
                                                                }
                                                            else
                                                                {
                                                                    $Global:XmlTempWriter.WriteStartElement('object')            
                                                                    $Global:XmlTempWriter.WriteAttributeString('label', [string]$RESNames.Name)                                                                    
                    
                                                                    $Global:XmlTempWriter.WriteAttributeString('ARO_Name', [string]$ResNames.name)
                                                                    $Global:XmlTempWriter.WriteAttributeString('OpenShift_Version', [string]$RESNames.properties.clusterProfile.version)
                                                                    $Global:XmlTempWriter.WriteAttributeString('OpenShift_Console', [string]$RESNames.properties.consoleProfile.url)
                                                                    $Global:XmlTempWriter.WriteAttributeString('Worker_VM_Count', [string]$RESNames.properties.workerprofiles.Count)
                                                                    $Global:XmlTempWriter.WriteAttributeString('Worker_VM_Size', [string]$RESNames.properties.workerprofiles.vmSize[0])
                    
                                                                    $Global:XmlTempWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
                    
                                                                        Icon2 $IconARO ($subloc+65) ($Alt0+40) "68" "60" $ContainerID
                    
                                                                    $Global:XmlTempWriter.WriteEndElement()
                                                                }
                                                        }                                                                                               
                                                    }
                                'Container Instance'  {
                                                        if($ContainerNames)
                                                            {                                                                                                
                                                                if($RESNames.count -gt 1)
                                                                    {
                                                                        $Global:XmlTempWriter.WriteStartElement('object')            
                                                                        $Global:XmlTempWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' Container Intances'))                                        
                    
                                                                        $Count = 1
                                                                        foreach ($ResName in $RESNames)
                                                                        {
                                                                            $Attr1 = ('Container_Intance-'+[string]("{0:d3}" -f $Count)+'-Name')
                    
                                                                            $Global:XmlTempWriter.WriteAttributeString($Attr1, [string]$ResName.name)
                                
                                                                            $Count ++
                                                                        }
                                                                        $Global:XmlTempWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
                                
                                                                            Icon2 $IconContain ($subloc+65) ($Alt0+40) "64" "68" $ContainerID
                                                        
                                                                        $Global:XmlTempWriter.WriteEndElement()
                                                                    }
                                                                else
                                                                    {
                                                                        $Global:XmlTempWriter.WriteStartElement('object')            
                                                                        $Global:XmlTempWriter.WriteAttributeString('label', [string]$RESNames.Name)                                        
                                                                        $Global:XmlTempWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
                                
                                                                            Icon2 $IconContain ($subloc+65) ($Alt0+40) "64" "68" $ContainerID
                                                        
                                                                        $Global:XmlTempWriter.WriteEndElement()
                                                                    }
                                                            }                                                                                               
                                                    }
                                'NetApp' {          
                                                    if($NetAppNames)
                                                        {                                          
                                                            if($RESNames.count -gt 1)
                                                                {
                                                                    $Global:XmlTempWriter.WriteStartElement('object')            
                                                                    $Global:XmlTempWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' NetApp Volumes'))                                        
                                                    
                                                                    $Count = 1
                                                                    foreach ($ResName in $RESNames)
                                                                    {
                                                                        $Attr1 = ('NetApp_Volume-'+[string]("{0:d3}" -f $Count))
                            
                                                                        $Global:XmlTempWriter.WriteAttributeString($Attr1, [string]$ResName.name)
                            
                                                                        $Count ++
                                                                    }
                                                                    $Global:XmlTempWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
                            
                                                                        Icon2 $IconNetApp ($subloc+65) ($Alt0+40) "65" "52" $ContainerID
                                                    
                                                                    $Global:XmlTempWriter.WriteEndElement()
                                                                }
                                                            else
                                                                {
                                                                    $Global:XmlTempWriter.WriteStartElement('object')            
                                                                    $Global:XmlTempWriter.WriteAttributeString('label', ([string]1+' NetApp Volume'))                                                                        
                                                                    $Global:XmlTempWriter.WriteAttributeString('NetApp_Volume_Name', [string]$ResName.name)
                    
                                                                    $Global:XmlTempWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
                            
                                                                        Icon2 $IconNetApp ($subloc+65) ($Alt0+40) "65" "52" $ContainerID
                                                    
                                                                    $Global:XmlTempWriter.WriteEndElement()
                                                                }
                                                        }                                                                   
                                                    }
                                'Data Explorer Clusters' {  
                                                            if($RESNames.count -gt 1)
                                                                {
                                                                    $Global:XmlTempWriter.WriteStartElement('object')            
                                                                    $Global:XmlTempWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' Data Explorer Clusters'))                                        
                                                    
                                                                    $Count = 1
                                                                    foreach ($ResName in $RESNames)
                                                                    {
                                                                        $Attr1 = ('Data_Cluster-'+[string]("{0:d3}" -f $Count)+'-Name')
                            
                                                                        $Global:XmlTempWriter.WriteAttributeString($Attr1, [string]$ResName.name)
                            
                                                                        $Count ++
                                                                    }
                                                                    $Global:XmlTempWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
                            
                                                                        Icon2 $IconDataExplorer ($subloc+65) ($Alt0+40) "68" "68" $ContainerID
                                                    
                                                                    $Global:XmlTempWriter.WriteEndElement()
                    
                                                                }
                                                            else
                                                                {
                                                                    $Global:XmlTempWriter.WriteStartElement('object')            
                                                                    $Global:XmlTempWriter.WriteAttributeString('label', [string]$RESNames.Name)                                        
                                                                    $Global:XmlTempWriter.WriteAttributeString('Data_Explorer_Cluster_Name', [string]$ResNames.name)
                                                                    $Global:XmlTempWriter.WriteAttributeString('Data_Explorer_Cluster_URI', [string]$ResNames.name)
                                                                    $Global:XmlTempWriter.WriteAttributeString('Data_Explorer_Cluster_State', [string]$ResNames.name)
                                                                    $Global:XmlTempWriter.WriteAttributeString('SKU_Tier', [string]$ResNames.name)
                                                                    $Global:XmlTempWriter.WriteAttributeString('Computer_Specifications', [string]$ResNames.name)
                                                                    $Global:XmlTempWriter.WriteAttributeString('AutoScale_Enabled', [string]$ResNames.name)
                                                                    $Global:XmlTempWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
                            
                                                                        Icon2 $IconDataExplorer ($subloc+65) ($Alt0+40) "68" "68" $ContainerID
                                                    
                                                                    $Global:XmlTempWriter.WriteEndElement()
                                                                }                                                               
                                                    } 
                                'Network Interface' {                                                    
                                                    if($RESNames.count -gt 1)
                                                        {
                                                            $Global:XmlTempWriter.WriteStartElement('object')            
                                                            $Global:XmlTempWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' Network Interfaces'))                                        
                                            
                                                            $Count = 1
                                                            foreach ($ResName in $RESNames)
                                                            {
                                                                $Attr1 = ('NIC-'+[string]("{0:d3}" -f $Count)+'-Name')
                    
                                                                $Global:XmlTempWriter.WriteAttributeString($Attr1, [string]$ResName.name)
                    
                                                                $Count ++
                                                            }
                                                            $Global:XmlTempWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
                    
                                                                Icon2 $IconNIC ($subloc+65) ($Alt0+40) "68" "60" $ContainerID
                                            
                                                            $Global:XmlTempWriter.WriteEndElement()
                    
                                                        }
                                                    else
                                                        {
                                                            $Global:XmlTempWriter.WriteStartElement('object')            
                                                            $Global:XmlTempWriter.WriteAttributeString('label', ([string]1+' Network Interface'))                                        
                                            
                                                            $Attr1 = ('NIC-Name')
                                                            $Global:XmlTempWriter.WriteAttributeString($Attr1, [string]$ResName.name)
                    
                                                            $Global:XmlTempWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
                    
                                                                Icon2 $IconNIC ($subloc+65) ($Alt0+40) "68" "60" $ContainerID
                                            
                                                            $Global:XmlTempWriter.WriteEndElement()
                    
                                                        }                                                                
                                                    }                                                                                                                                                                            
                                '' {}
                                default {}
                            }
                            if($sub.properties.networkSecurityGroup.id)
                                {
                                    $NSG = $sub.properties.networkSecurityGroup.id.split('/')[8]
                                    $Global:XmlTempWriter.WriteStartElement('object')            
                                    $Global:XmlTempWriter.WriteAttributeString('label', '')                                        
                                    $Global:XmlTempWriter.WriteAttributeString('Network_Security_Group', [string]$NSG)
                                    $Global:XmlTempWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
                    
                                        Icon2 $IconNSG ($subloc+160) ($Alt0+15) "26.35" "32" $ContainerID
                    
                                    $Global:XmlTempWriter.WriteEndElement()  
                                }
                            if($sub.properties.routeTable.id)
                                {
                                    $UDR = $sub.properties.routeTable.id.split('/')[8]
                                    $Global:XmlTempWriter.WriteStartElement('object')            
                                    $Global:XmlTempWriter.WriteAttributeString('label', '')                                        
                                    $Global:XmlTempWriter.WriteAttributeString('Route_Table', [string]$UDR)
                                    $Global:XmlTempWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
                    
                                        Icon2 $IconUDR ($subloc+15) ($Alt0+15) "30.97" "30" $ContainerID
                    
                                    $Global:XmlTempWriter.WriteEndElement()
                    
                                }
                            if($sub.properties.ipconfigurations.id)
                                {
                                    Foreach($SubIPs in $sub.properties.ipconfigurations)
                                        {
                                            $Global:VNETPIP += $Global:CleanPIPs | Where-Object {$_.properties.ipConfiguration.id -eq $SubIPs.id}
                                        }
                                }
                    }
        
                ######################################################### ICON #######################################################
        
                Function Icon2 {    
                    Param($Style,$x,$y,$w,$h,$p)
                    
                        $Global:XmlTempWriter.WriteStartElement('mxCell')
                        $Global:XmlTempWriter.WriteAttributeString('style', $Style)
                        $Global:XmlTempWriter.WriteAttributeString('vertex', "1")
                        $Global:XmlTempWriter.WriteAttributeString('parent', $p)
                    
                            $Global:XmlTempWriter.WriteStartElement('mxGeometry')
                            $Global:XmlTempWriter.WriteAttributeString('x', $x)
                            $Global:XmlTempWriter.WriteAttributeString('y', $y)
                            $Global:XmlTempWriter.WriteAttributeString('width', $w)
                            $Global:XmlTempWriter.WriteAttributeString('height', $h)
                            $Global:XmlTempWriter.WriteAttributeString('as', "geometry")
                            $Global:XmlTempWriter.WriteEndElement()
                        
                        $Global:XmlTempWriter.WriteEndElement()
                    }
        
                ######################################################## SUBNET #######################################################
        
                Stensils
        
                $Global:XmlTempWriter = New-Object System.XMl.XmlTextWriter($SubFile,$Null)
        
                $Global:XmlTempWriter.Formatting = 'Indented'
                $Global:XmlTempWriter.Indentation = 2
        
                $Global:XmlTempWriter.WriteStartDocument()
        
                $Global:XmlTempWriter.WriteStartElement('mxfile')
                $Global:XmlTempWriter.WriteAttributeString('host', 'Electron')
                $Global:XmlTempWriter.WriteAttributeString('modified', '2021-10-01T21:45:40.561Z')
                $Global:XmlTempWriter.WriteAttributeString('agent', '5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) draw.io/15.4.0 Chrome/91.0.4472.164 Electron/13.5.0 Safari/537.36')
                $Global:XmlTempWriter.WriteAttributeString('etag', $etag)
                $Global:XmlTempWriter.WriteAttributeString('version', '15.4.0')
                $Global:XmlTempWriter.WriteAttributeString('type', 'device')
        
                    $Global:XmlTempWriter.WriteStartElement('diagram')
                    $Global:XmlTempWriter.WriteAttributeString('id', $DiagID)
                    $Global:XmlTempWriter.WriteAttributeString('name', 'Network Topology')
        
                        $Global:XmlTempWriter.WriteStartElement('mxGraphModel')
                        $Global:XmlTempWriter.WriteAttributeString('dx', "1326")
                        $Global:XmlTempWriter.WriteAttributeString('dy', "798")
                        $Global:XmlTempWriter.WriteAttributeString('grid', "1")
                        $Global:XmlTempWriter.WriteAttributeString('gridSize', "10")
                        $Global:XmlTempWriter.WriteAttributeString('guides', "1")
                        $Global:XmlTempWriter.WriteAttributeString('tooltips', "1")
                        $Global:XmlTempWriter.WriteAttributeString('connect', "1")
                        $Global:XmlTempWriter.WriteAttributeString('arrows', "1")
                        $Global:XmlTempWriter.WriteAttributeString('fold', "1")
                        $Global:XmlTempWriter.WriteAttributeString('page', "1")
                        $Global:XmlTempWriter.WriteAttributeString('pageScale', "1")
                        $Global:XmlTempWriter.WriteAttributeString('pageWidth', "850")
                        $Global:XmlTempWriter.WriteAttributeString('pageHeight', "1100")
                        $Global:XmlTempWriter.WriteAttributeString('math', "0")
                        $Global:XmlTempWriter.WriteAttributeString('shadow', "0")
        
                            $Global:XmlTempWriter.WriteStartElement('root')
        
                                $Global:XmlTempWriter.WriteStartElement('mxCell')
                                $Global:XmlTempWriter.WriteAttributeString('id', "0")
                                $Global:XmlTempWriter.WriteEndElement()
        
                                $Global:XmlTempWriter.WriteStartElement('mxCell')
                                $Global:XmlTempWriter.WriteAttributeString('id', "1")
                                $Global:XmlTempWriter.WriteAttributeString('parent', "0")
                                $Global:XmlTempWriter.WriteEndElement()
                
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
                                            $Global:VNETPIP = @()
                                            foreach($Sub in $VNET.properties.subnets)
                                            {
                                                if ($SubC -eq $sizeC) 
                                                {
                                                    $Alt1 = $Alt1 + 230
                                                    $subloc0 = 20
                                                    $SubC = 0
                                                }
        
                                                $Global:XmlTempWriter.WriteStartElement('object')            
                                                $Global:XmlTempWriter.WriteAttributeString('label', ("`n" + "`n" + "`n" + "`n" + "`n" + "`n" +[string]$sub.Name + "`n" + [string]$sub.properties.addressPrefix))
                                                $Global:XmlTempWriter.WriteAttributeString('id', ($CellID+'-'+($IDNum++)))
        
                                                    Icon2 "rounded=0;whiteSpace=wrap;fontSize=16;html=1;sketch=0;fontFamily=Helvetica;" $subloc0 $Alt1 "200" "200" $ContID
        
                                                $Global:XmlTempWriter.WriteEndElement()      
                                                
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
                                            $Global:VNETPIP = @()
                                            foreach($Sub in $VNET.properties.subnets)
                                            {
                                                $Global:XmlTempWriter.WriteStartElement('object')            
                                                $Global:XmlTempWriter.WriteAttributeString('label', ("`n" + "`n" + "`n" + "`n" + "`n" + "`n" +[string]$sub.Name + "`n" + [string]$sub.properties.addressPrefix))
                                                $Global:XmlTempWriter.WriteAttributeString('id', ($CellID+'-'+($IDNum++)))
        
                                                    Icon2 "rounded=0;whiteSpace=wrap;fontSize=16;html=1;sketch=0;fontFamily=Helvetica;" $subloc0 40 "200" "200" $ContID
        
                                                $Global:XmlTempWriter.WriteEndElement()  
        
                                                    ProcType $sub $subloc0 40 $ContID              
        
                                                $subloc = $subloc + 210
                                                $subloc0 = $subloc0 + 210
                                            }
                                        }
        
                                $Global:XmlTempWriter.WriteEndElement()
        
                            $Global:XmlTempWriter.WriteEndElement()
        
                        $Global:XmlTempWriter.WriteEndElement()
                        $Global:XmlTempWriter.WriteEndElement()
        
                    $Global:XmlTempWriter.WriteEndDocument()
                    $Global:XmlTempWriter.Flush()
                    $Global:XmlTempWriter.Close() 
        
            }).AddArgument($subloc).AddArgument($VNET).AddArgument($IDNum).AddArgument($DiagramCache).AddArgument($ContID).AddArgument($Resources)
        
            New-Variable -Name ('Job_'+$NameString) -Scope Global
        
            Set-Variable -Name ('Job_'+$NameString) -Value ((get-variable -name ('Run_'+$NameString)).Value).BeginInvoke()
        
            $Global:jobs2 += (get-variable -name ('Job_'+$NameString)).Value
        
            $Global:jobs += $NameString
        
            #New-Variable -Name ('End_'+$NameString)
            #Set-Variable -Name ('End_'+$NameString) -Value (((get-variable -name ('Run_'+$NameString)).Value).EndInvoke((get-variable -name ('Job_'+$NameString)).Value))
        
            #((get-variable -name ('Run_'+$NameString)).Value).Dispose()
        
            #while ($Job.Runspace.IsCompleted -contains $false) {}
        
            KillJobs
        
        }
        
        Function KillJobs {
        
            foreach($job in $Global:jobs)
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
            $Global:XmlWriter.WriteStartElement('object')            
            $Global:XmlWriter.WriteAttributeString('label', ('Powered by:'+ "`n" +'Azure Resource Inventory v3.0'+ "`n" +'https://github.com/microsoft/ARI'))
            $Global:XmlWriter.WriteAttributeString('author', 'Claudio Merola')
            $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        }
                
        Function Icon {    
        Param($Style,$x,$y,$w,$h,$p)
        
            $Global:XmlWriter.WriteStartElement('mxCell')
            $Global:XmlWriter.WriteAttributeString('style', $Style)
            $Global:XmlWriter.WriteAttributeString('vertex', "1")
            $Global:XmlWriter.WriteAttributeString('parent', $p)
        
                $Global:XmlWriter.WriteStartElement('mxGeometry')
                $Global:XmlWriter.WriteAttributeString('x', $x)
                $Global:XmlWriter.WriteAttributeString('y', $y)
                $Global:XmlWriter.WriteAttributeString('width', $w)
                $Global:XmlWriter.WriteAttributeString('height', $h)
                $Global:XmlWriter.WriteAttributeString('as', "geometry")
                $Global:XmlWriter.WriteEndElement()
            
            $Global:XmlWriter.WriteEndElement()
        }
        
        Function Container {
            Param($x,$y,$w,$h,$title)
                $Global:ContID = (-join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})+'-'+1)
        
                $Global:XmlWriter.WriteStartElement('mxCell')
                $Global:XmlWriter.WriteAttributeString('id', $Global:ContID)
                $Global:XmlWriter.WriteAttributeString('value', "$title")
                $Global:XmlWriter.WriteAttributeString('style', "swimlane")
                $Global:XmlWriter.WriteAttributeString('vertex', "1")
                $Global:XmlWriter.WriteAttributeString('parent', "1")
            
                    $Global:XmlWriter.WriteStartElement('mxGeometry')
                    $Global:XmlWriter.WriteAttributeString('x', $x)
                    $Global:XmlWriter.WriteAttributeString('y', $y)
                    $Global:XmlWriter.WriteAttributeString('width', $w)
                    $Global:XmlWriter.WriteAttributeString('height', $h)
                    $Global:XmlWriter.WriteAttributeString('as', "geometry")
                    $Global:XmlWriter.WriteEndElement()
                
                $Global:XmlWriter.WriteEndElement()
        }
        
        Function Connect {
        Param($Source,$Target,$Parent)
        
            if($Parent){$Parent = $Parent}else{$Parent = 1}
        
            $Global:XmlWriter.WriteStartElement('mxCell')
            $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
            $Global:XmlWriter.WriteAttributeString('style', "edgeStyle=none;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;endArrow=none;endFill=0;")
            $Global:XmlWriter.WriteAttributeString('edge', "1")
            $Global:XmlWriter.WriteAttributeString('vertex', "1")
            $Global:XmlWriter.WriteAttributeString('parent', $Parent)
            $Global:XmlWriter.WriteAttributeString('source', $Source)
            $Global:XmlWriter.WriteAttributeString('target', $Target)
        
                $Global:XmlWriter.WriteStartElement('mxGeometry')
                $Global:XmlWriter.WriteAttributeString('relative', "1")
                $Global:XmlWriter.WriteAttributeString('as', "geometry")
                $Global:XmlWriter.WriteEndElement()
            
            $Global:XmlWriter.WriteEndElement()
        
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
                
                $jobAZVGWs = $AZVGWs.BeginInvoke()
                $jobAZLGWs = $AZLGWs.BeginInvoke()
                $jobAZVNETs = $AZVNETs.BeginInvoke()
                $jobAZCONs = $AZCONs.BeginInvoke()
                $jobAZEXPROUTEs = $AZEXPROUTEs.BeginInvoke()
                $jobPIPs = $PIPs.BeginInvoke()
                $jobAZVWAN = $AZVWAN.BeginInvoke()
                $jobAZVHUB = $AZVHUB.BeginInvoke()
                $jobAZVPNSITES = $AZVPNSITES.BeginInvoke()
                $jobAZVERs = $AZVERs.BeginInvoke() 
        
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
                        'CleanPIPs' = $CleanPIPs
                    }
        
                $Variables
        
            } -ArgumentList $resources, $null
        
        }
        
        $Subnetfiles = Get-ChildItem -Path $DiagramCache
        
        foreach($SubFile in $Subnetfiles)
            {
                if($SubFile.FullName -notin $XMLFiles)
                        {
                            Remove-Item -Path $SubFile.FullName
                        }
            }
        
        Variables0
        
        Get-Job -Name 'DiagramVariables' | Wait-Job
        
        $Job = Receive-Job -Name 'DiagramVariables'
        
        Get-Job -Name 'DiagramVariables' | Remove-Job
        
        $Global:AZVGWs = $Job.AZVGWs
        $Global:AZLGWs = $Job.AZLGWs
        $Global:AZVNETs = $Job.AZVNETs
        $Global:AZCONs = $Job.AZCONs
        $Global:AZEXPROUTEs = $Job.AZEXPROUTEs
        $Global:PIPs = $Job.PIPs
        $Global:AZVWAN = $Job.AZVWAN
        $Global:AZVHUB = $Job.AZVHUB
        $Global:AZVPNSITES = $Job.AZVPNSITES
        $Global:AZVERs = $Job.AZVERs
        $Global:CleanPIPs = $Job.CleanPIPs

        $Global:etag = -join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})
        $Global:DiagID = -join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})
        $Global:CellID = -join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})

        $Global:IDNum = 0

        $Global:XmlWriter = New-Object System.XMl.XmlTextWriter($DDFile,$Null)

        $Global:XmlWriter.Formatting = 'Indented'
        $Global:XmlWriter.Indentation = 2

        $Global:XmlWriter.WriteStartDocument()

        $Global:XmlWriter.WriteStartElement('mxfile')
        $Global:XmlWriter.WriteAttributeString('host', 'Electron')
        $Global:XmlWriter.WriteAttributeString('modified', '2021-10-01T21:45:40.561Z')
        $Global:XmlWriter.WriteAttributeString('agent', '5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) draw.io/15.4.0 Chrome/91.0.4472.164 Electron/13.5.0 Safari/537.36')
        $Global:XmlWriter.WriteAttributeString('etag', $etag)
        $Global:XmlWriter.WriteAttributeString('version', '15.4.0')
        $Global:XmlWriter.WriteAttributeString('type', 'device')

            $Global:XmlWriter.WriteStartElement('diagram')
            $Global:XmlWriter.WriteAttributeString('id', $DiagID)
            $Global:XmlWriter.WriteAttributeString('name', 'Network Topology')

                $Global:XmlWriter.WriteStartElement('mxGraphModel')
                $Global:XmlWriter.WriteAttributeString('dx', "1326")
                $Global:XmlWriter.WriteAttributeString('dy', "798")
                $Global:XmlWriter.WriteAttributeString('grid', "1")
                $Global:XmlWriter.WriteAttributeString('gridSize', "10")
                $Global:XmlWriter.WriteAttributeString('guides', "1")
                $Global:XmlWriter.WriteAttributeString('tooltips', "1")
                $Global:XmlWriter.WriteAttributeString('connect', "1")
                $Global:XmlWriter.WriteAttributeString('arrows', "1")
                $Global:XmlWriter.WriteAttributeString('fold', "1")
                $Global:XmlWriter.WriteAttributeString('page', "1")
                $Global:XmlWriter.WriteAttributeString('pageScale', "1")
                $Global:XmlWriter.WriteAttributeString('pageWidth', "850")
                $Global:XmlWriter.WriteAttributeString('pageHeight', "1100")
                $Global:XmlWriter.WriteAttributeString('math', "0")
                $Global:XmlWriter.WriteAttributeString('shadow', "0")

                    $Global:XmlWriter.WriteStartElement('root')

                        $Global:XmlWriter.WriteStartElement('mxCell')
                        $Global:XmlWriter.WriteAttributeString('id', "0")
                        $Global:XmlWriter.WriteEndElement()

                        $Global:XmlWriter.WriteStartElement('mxCell')
                        $Global:XmlWriter.WriteAttributeString('id', "1")
                        $Global:XmlWriter.WriteAttributeString('parent', "0")
                        $Global:XmlWriter.WriteEndElement()

                            Stensils

                            if($AZLGWs -or $AZEXPROUTEs -or $AZVERs -or $AZVPNSITES)
                                {
                                    OnPremNet
                                    if($Global:FullEnvironment)
                                        {
                                            FullEnvironment
                                        }
                                }
                            else
                                {
                                    CloudOnly
                                }


                        $Global:XmlWriter.WriteEndElement()

                    $Global:XmlWriter.WriteEndElement()

                $Global:XmlWriter.WriteEndElement()

            $Global:XmlWriter.WriteEndDocument()
            $Global:XmlWriter.Flush()
            $Global:XmlWriter.Close()                

            while ($Global:jobs2.IsCompleted -contains $false) {}

            #$VNetFile = ($DiagramCache+'Network.xml')
            
            $Subnetfiles = Get-ChildItem -Path $DiagramCache

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
    } -ArgumentList $Subscriptions,$Resources,$Advisories,$DiagramCache,$FullEnvironment,$DDFile,$XMLFiles
}

Function Subscription {
    Param($Subscriptions,$Resources,$DiagramCache)

    Start-Job -Name 'Diagram_Subscriptions' -ScriptBlock {
        $Global:Subscriptions = $($args[0])
        $Global:Resources = $($args[1])
        $Global:DiagramCache = $($args[2])        

        Function Icon {    
            Param($Style,$x,$y,$w,$h,$p)
            
                $Global:XmlWriter.WriteStartElement('mxCell')
                $Global:XmlWriter.WriteAttributeString('style', $Style)
                $Global:XmlWriter.WriteAttributeString('vertex', "1")
                $Global:XmlWriter.WriteAttributeString('parent', $p)
            
                    $Global:XmlWriter.WriteStartElement('mxGeometry')
                    $Global:XmlWriter.WriteAttributeString('x', $x)
                    $Global:XmlWriter.WriteAttributeString('y', $y)
                    $Global:XmlWriter.WriteAttributeString('width', $w)
                    $Global:XmlWriter.WriteAttributeString('height', $h)
                    $Global:XmlWriter.WriteAttributeString('as', "geometry")
                    $Global:XmlWriter.WriteEndElement()
                
                $Global:XmlWriter.WriteEndElement()
            }
        
        function variables {
        
        $Global:Ret = "rounded=0;whiteSpace=wrap;fontSize=16;html=1;sketch=0;fontFamily=Helvetica;"
        $Global:RetRound = "rounded=1;whiteSpace=wrap;fontSize=16;html=1;sketch=0;fontFamily=Helvetica;"

        ############# Azure AI
        $Global:AzureBotServices = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/ai_machine_learning/Bot_Services.svg;'
        $Global:AzureMachineLearning = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/ai_machine_learning/Machine_Learning.svg;'
        $Global:AzureCognitive = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/ai_machine_learning/Cognitive_Services.svg;' 
        
        ############# Azure Analytics
        $Global:AzureDatabricks = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/analytics/Azure_Databricks.svg;'
        $Global:AzureAnalysis = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/analytics/Analysis_Services.svg;'
        $Global:AzureSynapses = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/analytics/Azure_Synapse_Analytics.svg;'
        
        ############# Azure App Service
        $Global:IconAPPs = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/containers/App_Services.svg;" #width="64" height="64"
        $Global:AppSvcPlan = 'image;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/app_services/App_Service_Plans.svg;' #width="43.5" height="43.5"
        $Global:AzureAppDomain = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/app_services/App_Service_Domains.svg;' 
        
        
        ############# Azure VMware
        $Global:AzureAVSPrivateCloud = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/azure_vmware_solution/AVS.svg;' 
        
        
        ############# Azure Compute
        $Global:SvcFabric = 'image;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/compute/Service_Fabric_Clusters.svg;' #width="49.47" height="47.25"
        $Global:IconVMSS = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/compute/VM_Scale_Sets.svg;" # width="68" height="68"
        $Global:Disks = 'image;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/compute/Disks.svg;' #width="40.72" height="40"
        $Global:RestorePoint = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/compute/Restore_Points_Collections.svg;'
        $Global:AzureCloudSvc = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/compute/Cloud_Services_Classic.svg;'
        $Global:AvSet = 'image;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/compute/Availability_Sets.svg;' #width="43.5" height="43.5"
        $Global:AzureVMImage = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/compute/Images.svg;'
        $Global:AzureAVDWorkspace = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/compute/Workspaces.svg;'
        $Global:IconVMs = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/compute/Virtual_Machine.svg;" #width="69" height="64"
        
        ############ Azure Container
        $Global:IconAKS = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/containers/Kubernetes_Services.svg;" #width="68" height="60"
        $Global:ContRegis = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/containers/Container_Registries.svg;'
        $Global:AzureContainerInstances = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/containers/Container_Instances.svg;' 
        
        ############ Azure Database
        $Global:AzureSQLDB = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/databases/SQL_Database.svg;'
        $Global:AzureSQLDBServer = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/databases/SQL_Server.svg;'
        $Global:AzureDataExplorer = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/databases/Azure_Data_Explorer_Clusters.svg;'
        $Global:AzureDBforPostgre = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/databases/Azure_Database_PostgreSQL_Server.svg;'
        $Global:AzureDBforPostgreFlex = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/databases/Azure_Database_PostgreSQL_Server_Group.svg;'
        $Global:AzureRedisCa = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/databases/Cache_Redis.svg;'
        $Global:AzureDataFactory = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/devops/Azure_DevOps.svg;'
        $Global:AzureCosmos = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/databases/Azure_Cosmos_DB.svg;'
        $Global:AzureElastic = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/databases/SQL_Elastic_Pools.svg;'
        $Global:AzureElasticJobAgent = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/databases/Elastic_Job_Agents.svg;'
        $Global:AzureDB4MySQL = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/databases/Azure_Database_MySQL_Server.svg;'
        $Global:AzureSQLManagedInstances = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/databases/SQL_Managed_Instance.svg;'
        $Global:AzureSQLManagedInstancesDB = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/databases/Managed_Database.svg;'
        $Global:AzureSQLVM = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/databases/Azure_SQL_VM.svg;'
        $Global:AzureSQLVirtualCluster = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/databases/Virtual_Clusters.svg;'
        $Global:AzureDBMigration = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/databases/Azure_Database_Migration_Services.svg;'
        $Global:AzurePurviewAcc = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/databases/Azure_Purview_Accounts.svg;' 
        $Global:AzureMariaDB = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/databases/Azure_Database_MariaDB_Server.svg;' 
        
        ############ Azure DevOps
        $Global:Insight = 'image;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/devops/Application_Insights.svg;' #width="44" height="63"
        $Global:AzureDevOpsOrg = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/devops/Azure_DevOps.svg;'
        
        ############ Azure General
        $Global:AzureError = 'image;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/general/Error.svg;' #width="50.12" height="48"
        $Global:AzureWebSlot = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/general/Web_Slots.svg;'
        $Global:AzureWorkbooks = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/general/Workbooks.svg;'
        $Global:AzureWebTest = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/general/Web_Test.svg;'
        $Global:IconSubscription = "aspect=fixed;html=1;points=[];align=center;image;fontSize=20;image=img/lib/azure2/general/Subscriptions.svg;" #width="44" height="71"
        $GLobal:IconRG = "image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=12;image=img/lib/mscae/ResourceGroup.svg;" # width="37.5" height="30"
        
        ############ Azure Identity
        $Global:AzureB2C = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/identity/Azure_AD_B2C.svg;'
        
        ########### Azure Integration
        $Global:SvcBus = 'image;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/integration/Service_Bus.svg;' #width="45.05" height="39.75"
        $Global:AzureAPIConnections = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/integration/Logic_Apps_Custom_Connector.svg;'
        $Global:AzureLogicApp = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/integration/Logic_Apps.svg;'
        $Global:AzureDataCatalog = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/integration/Azure_Data_Catalog.svg;'
        $Global:AzureEventGridSymtopics = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/integration/System_Topic.svg;'
        $Global:AzureAppConfiguration = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/integration/App_Configuration.svg;'
        $Global:AzureIntegrationAcc = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/integration/Integration_Accounts.svg;'  
        $Global:AzureEvtGridTopics = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/integration/Event_Grid_Topics.svg;'  
        $Global:AzureAPIMangement = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/integration/API_Management_Services.svg;'
        $Global:AzureEvtGridDomain = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/integration/Event_Grid_Subscriptions.svg;' 
        
        ########### Azure IoT
        $Global:AzureEvtHubs = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/iot/Event_Hubs.svg;'
        $Global:AzureIoTHubs = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/iot/Event_Hubs.svg;' 
        
        ########### Azure Management Governance
        $Global:RecoveryVault = 'image;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/management_governance/Recovery_Services_Vaults.svg;' #width="43.7" height="38"
        $Global:AutAcc = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/management_governance/Automation_Accounts.svg;'
        $Global:AzureArcServer = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/management_governance/MachinesAzureArc.svg;' 
        
        
        ########### Azure Migrate
        $Global:AzureMigration = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/migrate/Azure_Migrate.svg;' 
        
        
        ########### Azure Networking
        $Global:AzureConnections = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/networking/Connections.svg;" #width="68" height="68"
        $Global:AzureExpressRoute = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/networking/ExpressRoute_Circuits.svg;" #width="70" height="64"
        $Global:AzureVGW = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/networking/Virtual_Network_Gateways.svg;" #width="52" height="69"
        $Global:AzureVNET = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/networking/Virtual_Networks.svg;" #width="67" height="40"
        $Global:AzurePIP = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/networking/Public_IP_Addresses.svg;" # width="65" height="52"
        $Global:Azureproximityplacementgroups = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/networking/Proximity_Placement_Groups.svg;'
        $Global:AzureUDRs = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/networking/Route_Tables.svg;'
        $Global:AzureRouteFilters = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/networking/Route_Filters.svg;'
        $Global:AzureBastionHost = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/networking/Bastions.svg;'
        $Global:IconLBs = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/networking/Load_Balancers.svg;" #width="72" height="72"
        $Global:NetWatcher = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/networking/Network_Watcher.svg;'
        $Global:AzurePvtLinks = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/networking/Private_Link_Service.svg;'
        $Global:AzureIPGroups = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/networking/IP_Groups.svg;'
        $Global:AzureFW = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/networking/Firewalls.svg;'
        $Global:AzureLNG = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/networking/Local_Network_Gateways.svg;'
        $Global:AzureFrontDoor = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/networking/Front_Doors.svg;'
        $Global:AzurePIPPrefixes = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/networking/Public_IP_Prefixes.svg;'
        $Global:AzureNATGateways = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/networking/NAT.svg;'
        $Global:AzureCDN = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/networking/CDN_Profiles.svg;'
        $Global:AzureNSG = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/networking/Network_Security_Groups.svg;'
        $Global:AzureSvcEndpointPol = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/networking/Service_Endpoint_Policies.svg;'  
        $Global:AzureVMNIC = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/networking/Network_Interfaces.svg;'   
        $Global:AzureWAFPolicies = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/networking/Web_Application_Firewall_Policies_WAF.svg;'  
        $Global:AzureDNSZone = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/networking/DNS_Zones.svg;'
        $Global:AzureAppGateway = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/networking/Application_Gateways.svg;' 
        $Global:AzureDDOS = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/networking/DDoS_Protection_Plans.svg;' 
        $Global:AzureTrafficManager = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/networking/Traffic_Manager_Profiles.svg;' 
        $Global:AzurePvtLink = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/networking/Private_Link.svg;' 
        $Global:IconPVTs = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/networking/Private_Endpoint.svg;" #width="72" height="66"
        $Global:IconLBs = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/networking/Load_Balancers.svg;" #width="72" height="72"
        
        ########### Azure Other
        $Global:Dashboard = 'image;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/other/Dashboard_Hub.svg;' #width="50.02" height="38.25"
        $Global:TemplSpec = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/other/Template_Specs.svg;'
        $Global:AzureBackupVault = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/other/Azure_Backup_Center.svg;'
        $Global:AzureERDirect = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/other/ExpressRoute_Direct.svg;'
        $Global:AzureAVDSessionHost = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/other/AVS_VM.svg;'
        $Global:AzureAVDHostPool = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/other/Windows_Virtual_Desktop.svg;'
        $Global:AzureGrafana = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/other/Grafana.svg;' 
        $Global:AzureNetworkManager = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/other/Azure_Network_Manager.svg;' 
        
        
        ########### Azure Security
        $Global:KeyVault = 'image;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/security/Key_Vaults.svg;' #width="49.5" height="49.5"
        $Global:AzureAppSecGroup = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/security/Application_Security_Groups.svg;'
        $Global:AzureDefender = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/security/Azure_Defender.svg;' 
        
        
        ########### Azure Storage
        $Global:StorageAcc = 'image;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/storage/Storage_Accounts.svg;' #width="43.75" height="35"
        $Global:AzureNetApp = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/storage/Azure_NetApp_Files.svg;'
        $Global:AzureDatalakeGen1 = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/storage/Data_Lake_Storage_Gen1.svg;' 
        
        
        ########### Azure Web
        $Global:AzureMediaServices = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/azure2/web/Azure_Media_Service.svg;' 
        
        ########### MSCAE
        $Global:Certificate = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/mscae/Certificate.svg;' #width="50" height="42"
        $Global:LogAnalytics = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/mscae/Log_Analytics_Workspaces.svg;' #width="40" height="40"
        $Global:PvtDNS = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/mscae/DNS_Private_Zones.svg;' #width="50" height="50"
        $Global:AzureSaaS = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/mscae/Software_as_a_Service.svg;'
        $Global:AzureRelay = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/mscae/Service_Bus_Relay.svg;'
        $Global:AzureLogAlertRule = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/mscae/Notification.svg;'
        $Global:AzureSignalR = 'image;sketch=0;aspect=fixed;html=1;points=[];align=center;fontSize=14;image=img/lib/mscae/SignalR.svg;' 
        
        
        }
        
        function ResourceTypes {
            Param($TempResourceType,$TempResLeft,$TempResTop) 
        
                switch ($TempResourceType.Name)
                    {
                        <########## AZURE AI  ############>
        
                        'microsoft.botservice/botservices'   
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Bot' + "`n" + 'Services'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureBotServices $TempResLeft $TempResTop "40" "40" 1
        
                                $Global:XmlWriter.WriteEndElement()  
                            }      
                        'microsoft.machinelearningservices/workspaces'   
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Machine' + "`n" + 'Learning'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureMachineLearning $TempResLeft $TempResTop "40" "43" 1
        
                                $Global:XmlWriter.WriteEndElement()  
                            }     
                        'microsoft.cognitiveservices/accounts'   
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Cognitive' + "`n" + 'Services'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureCognitive $TempResLeft $TempResTop "58" "38" 1
        
                                $Global:XmlWriter.WriteEndElement()  
                            }                                 
        
                        <########## AZURE ANALYTICS  ############>
        
                        'microsoft.databricks/workspaces'   
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Databricks'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureDatabricks $TempResLeft $TempResTop "48" "52" 1
        
                                $Global:XmlWriter.WriteEndElement()  
                            } 
                        'microsoft.analysisservices/servers'   
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Analysis' + "`n" + 'Services'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureAnalysis $TempResLeft $TempResTop "53" "41" 1
        
                                $Global:XmlWriter.WriteEndElement()  
                            } 
                        'microsoft.synapse/workspaces'   
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Synapse' + "`n" + 'Analytics'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureSynapses $TempResLeft $TempResTop "45" "54" 1
        
                                $Global:XmlWriter.WriteEndElement()  
                            }                     
        
                        <########## AZURE APP  ############>
        
                        'microsoft.web/sites'   
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Web App'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $IconAPPs $TempResLeft $TempResTop "45" "45" 1
        
                                $Global:XmlWriter.WriteEndElement()  
                            } 
                        'microsoft.web/serverfarms'   
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' App' + "`n" + 'Service Plan'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AppSvcPlan $TempResLeft $TempResTop "43.5" "43.5" 1
        
                                $Global:XmlWriter.WriteEndElement()  
                            }
                        'microsoft.domainregistration/domains'   
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' App Service' + "`n" + 'Domain'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureAppDomain $TempResLeft $TempResTop "50" "38" 1
        
                                $Global:XmlWriter.WriteEndElement()  
                            }                    
        
                        <########## AZURE VMWARE ############>
        
                        'microsoft.avs/privateclouds'   
                        {
                            $Global:XmlWriter.WriteStartElement('object')            
                            $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' VMware' + "`n" + 'Private Cloud'))
                            $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                Icon $AzureAVSPrivateCloud $TempResLeft $TempResTop "60" "46" 1
        
                            $Global:XmlWriter.WriteEndElement()  
                        }                
        
                        <########## AZURE COMPUTE ############>
        
                        'microsoft.desktopvirtualization/workspaces'   
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' AVD' + "`n" + 'Workspaces'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureAVDWorkspace $TempResLeft $TempResTop "48" "42" 1
        
                                $Global:XmlWriter.WriteEndElement()  
                            }
                        'microsoft.compute/virtualmachinescalesets'   
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' VMSS'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $IconVMSS $TempResLeft $TempResTop "45" "45" 1
        
                                $Global:XmlWriter.WriteEndElement()  
                            }
                        'microsoft.servicefabric/clusters'   
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Service' + "`n" + 'Fabric'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $SvcFabric $TempResLeft $TempResTop "49.4" "47.2" 1
        
                                $Global:XmlWriter.WriteEndElement()  
                            }
                        'microsoft.compute/disks'   
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Disk'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $Disks  $TempResLeft $TempResTop "40.72" "40" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }
                        'microsoft.compute/virtualmachines'   
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Virtual' + "`n" + 'Machine'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $IconVMs  $TempResLeft $TempResTop "43" "40" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }
                        'microsoft.compute/availabilitysets'   
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Availability' + "`n" + 'Set'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AvSet  $TempResLeft $TempResTop "43.5" "43.5" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }
                        'microsoft.compute/restorepointcollections'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Restore' + "`n" + 'Point Collection'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $RestorePoint  $TempResLeft $TempResTop "50" "40" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            } 
                        'microsoft.classiccompute/domainnames'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Cloud' + "`n" + 'Services'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureCloudSvc  $TempResLeft $TempResTop "51" "37" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }
                        'microsoft.compute/images'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Images'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureVMImage  $TempResLeft $TempResTop "47" "44" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }
        
        
                        <########## AZURE CONTAINERS ############>
        
                        'microsoft.containerservice/managedclusters'   
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' AKS'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $IconAKS $TempResLeft $TempResTop "51" "45" 1
        
                                $Global:XmlWriter.WriteEndElement()  
                            }
                        'microsoft.containerregistry/registries'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Container' + "`n" + 'Registry'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $ContRegis  $TempResLeft $TempResTop "45" "40" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }
                        'microsoft.kubernetes/connectedclusters'   
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Kubernetes' + "`n" + 'Azure Arc'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $IconAKS $TempResLeft $TempResTop "51" "45" 1
        
                                $Global:XmlWriter.WriteEndElement()  
                            }
                        'microsoft.containerinstance/containergroups'   
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Container' + "`n" + 'Instances'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureContainerInstances $TempResLeft $TempResTop "46" "50" 1
        
                                $Global:XmlWriter.WriteEndElement()  
                            }
        
        
                        <########## AZURE DATABASES ############>
        
                        'microsoft.sql/servers/databases'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' SQL' + "`n" + 'Database'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureSQLDB  $TempResLeft $TempResTop "36" "49" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }  
                        'microsoft.sql/servers'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' SQL' + "`n" + 'Server'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureSQLDBServer  $TempResLeft $TempResTop "49" "49" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }  
                        'microsoft.kusto/clusters'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Data' + "`n" + 'Explorer Cluster'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureDataExplorer  $TempResLeft $TempResTop "41" "41" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }                      
                        'microsoft.dbforpostgresql/servers'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Database' + "`n" + 'PostgreSQL'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureDBforPostgre  $TempResLeft $TempResTop "38" "43" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }  
                        'microsoft.dbforpostgresql/flexibleservers'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' PostgreSQL' + "`n" + 'Flexible Server'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureDBforPostgreFlex  $TempResLeft $TempResTop "37.94" "43" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            } 
                        'microsoft.cache/redis'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Redis' + "`n" + 'Cache'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureRedisCa  $TempResLeft $TempResTop "55" "45" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            } 
                        'microsoft.datafactory/factories'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Data' + "`n" + 'Factory'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureDataFactory  $TempResLeft $TempResTop "44" "44" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }    
                        'microsoft.documentdb/databaseaccounts'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Cosmos' + "`n" + 'Database'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureCosmos  $TempResLeft $TempResTop "51" "51" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }         
                        'microsoft.sql/servers/elasticpools'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' SQL' + "`n" + 'Elastic Pool'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureElastic  $TempResLeft $TempResTop "51" "51" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }      
                        'microsoft.sql/servers/jobagents'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Elastic' + "`n" + 'Job Agent'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureElasticJobAgent  $TempResLeft $TempResTop "50" "50" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }          
                        'microsoft.dbformysql/servers'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' MySQL' + "`n" + 'Database Server'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureDB4MySQL  $TempResLeft $TempResTop "35" "46" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }      
                        'microsoft.dbformysql/flexibleservers'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' MySQL' + "`n" + 'Flexible Server'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureDB4MySQL  $TempResLeft $TempResTop "35" "46" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            } 
                        'microsoft.sql/managedinstances/databases'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Managed Instances' + "`n" + 'Database'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureSQLManagedInstancesDB  $TempResLeft $TempResTop "51" "47" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }                                              
                        'microsoft.sql/managedinstances'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' SQL' + "`n" + 'Managed Instances'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureSQLManagedInstances  $TempResLeft $TempResTop "50" "49" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }     
                        'microsoft.sqlvirtualmachine/sqlvirtualmachines'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' SQL' + "`n" + 'Virtual Machine'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureSQLVM  $TempResLeft $TempResTop "50" "46" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }                     
                        'microsoft.sql/virtualclusters'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' SQL' + "`n" + 'Virtual Cluster'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureSQLVirtualCluster  $TempResLeft $TempResTop "50" "48" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }        
                        'microsoft.datamigration/sqlmigrationservices'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Database' + "`n" + 'Migration Service'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureDBMigration  $TempResLeft $TempResTop "46" "50" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }      
                        'microsoft.datamigration/services'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Database' + "`n" + 'Migration Service'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureDBMigration  $TempResLeft $TempResTop "46" "50" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }  
                        'microsoft.datamigration/services/projects'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Database' + "`n" + 'Migration Project'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureDBMigration  $TempResLeft $TempResTop "46" "50" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }  
                        'microsoft.purview/accounts'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Purview' + "`n" + 'Account'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzurePurviewAcc  $TempResLeft $TempResTop "58" "32" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }     
                        'microsoft.dbformariadb/servers'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' MariaDB' + "`n" + 'Server'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureMariaDB  $TempResLeft $TempResTop "34" "50" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }                                                              
        
                        <########## AZURE DEVOPS ############>
        
                        'microsoft.insights/metricalerts'
                            {
                                $Global:XmlWriter.WriteStartElement('object') 
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Insight' + "`n" + 'Metrics'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $Insight $TempResLeft $TempResTop "33" "42" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }
                        'microsoft.insights/components'   
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' App' + "`n" + 'Insights'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $Insight $TempResLeft $TempResTop "50" "42" 1
        
                                $Global:XmlWriter.WriteEndElement()  
                            }
                        'microsoft.visualstudio/account'   
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' DevOps' + "`n" + 'Organization'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureDevOpsOrg $TempResLeft $TempResTop "41" "41" 1
        
                                $Global:XmlWriter.WriteEndElement()  
                            }                    
        
                        <########## AZURE GENERAL ############>
        
                        'microsoft.web/sites/slots'   
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Web' + "`n" + 'Slots'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureWebSlot $TempResLeft $TempResTop "44" "49" 1
        
                                $Global:XmlWriter.WriteEndElement()  
                            }
                        'microsoft.insights/workbooks'   
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Workbooks'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureWorkbooks $TempResLeft $TempResTop "39" "43" 1
        
                                $Global:XmlWriter.WriteEndElement()  
                            }
                        'microsoft.insights/webtests'   
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Web' + "`n" + 'Test'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureWebTest $TempResLeft $TempResTop "50" "50" 1
        
                                $Global:XmlWriter.WriteEndElement()  
                            }
        
                        <########## AZURE IDENTITY ############>
        
                        'microsoft.azureactivedirectory/b2cdirectories'   
                        {
                            $Global:XmlWriter.WriteStartElement('object')            
                            $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' B2C' + "`n" + 'Directories'))
                            $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                Icon $AzureB2C $TempResLeft $TempResTop "49" "45" 1
        
                            $Global:XmlWriter.WriteEndElement()  
                        }
        
                        <########## AZURE INTEGRATION ############>
        
                        'microsoft.servicebus/namespaces'   
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Service' + "`n" + 'Bus'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $SvcBus $TempResLeft $TempResTop "45.05" "39.75" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }
                        'microsoft.web/connections'   
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' API' + "`n" + 'Connections'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureAPIConnections $TempResLeft $TempResTop "43" "43" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }
                        'microsoft.logic/workflows'   
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Logic' + "`n" + 'Apps'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureLogicApp $TempResLeft $TempResTop "57" "44" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }
                        'microsoft.datacatalog/catalogs'   
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Data' + "`n" + 'Catalog'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureDataCatalog $TempResLeft $TempResTop "46" "52" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }             
                        'microsoft.web/customapis'   
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Logic App' + "`n" + 'Custom Connector'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureAPIConnections $TempResLeft $TempResTop "43" "43" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }   
                        'microsoft.eventgrid/systemtopics'   
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Event Grid' + "`n" + 'System Topics'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureEventGridSymtopics $TempResLeft $TempResTop "44" "40" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }   
                        'microsoft.appconfiguration/configurationstores'   
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' App' + "`n" + 'Configuration'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureAppConfiguration $TempResLeft $TempResTop "46" "50" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }           
                        'microsoft.logic/integrationaccounts'   
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Integration' + "`n" + 'Accounts'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureIntegrationAcc $TempResLeft $TempResTop "50" "50" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }      
                        'microsoft.eventgrid/topics'   
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Event Grid' + "`n" + 'Topics'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureEvtGridTopics $TempResLeft $TempResTop "44" "40" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }     
                        'microsoft.apimanagement/service'   
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' API' + "`n" + 'Management'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureAPIMangement $TempResLeft $TempResTop "50" "45" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }     
                        'microsoft.eventgrid/domains'   
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Event Grid' + "`n" + 'Domain'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureEvtGridDomain $TempResLeft $TempResTop "50" "43" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }                                                                              
        
                        <########## AZURE IOT ############>
        
                        'microsoft.eventhub/namespaces'   
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Event' + "`n" + 'Hubs'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureEvtHubs $TempResLeft $TempResTop "50" "45" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }
                        'microsoft.devices/iothubs'   
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' IoT' + "`n" + 'Hubs'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureIoTHubs $TempResLeft $TempResTop "50" "43" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }
        
        
                        <########## AZURE MANAGEMENT GOVERNANCE ############>
        
                        'microsoft.recoveryservices/vaults'   
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Recovery' + "`n" + 'Services Vault'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $RecoveryVault  $TempResLeft $TempResTop "43.5" "38" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }
                        'microsoft.automation/automationaccounts'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Automation' + "`n" + 'Account'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AutAcc  $TempResLeft $TempResTop "40" "40" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            } 
                        'Microsoft.HybridCompute/machines'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Arc' + "`n" + 'Server'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureArcServer  $TempResLeft $TempResTop "30" "54" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            } 
        
                        <########## AZURE MIGRATE ############>
        
                        'microsoft.migrate/projects'    
                        {
                            $Global:XmlWriter.WriteStartElement('object')            
                            $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Migration' + "`n" + 'Project'))
                            $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                Icon $AzureMigration  $TempResLeft $TempResTop "62" "34" 1
        
                            $Global:XmlWriter.WriteEndElement()
                        } 
                        
                        <########## AZURE NETWORKING ############>
        
                        'microsoft.network/privateendpoints'   
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Private' + "`n" + 'Endpoint'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $IconPVTs $TempResLeft $TempResTop "44" "40" 1
        
                                $Global:XmlWriter.WriteEndElement()  
                            }
                        'microsoft.network/loadbalancers'   
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Load' + "`n" + 'Balancer'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $IconLBs $TempResLeft $TempResTop "41" "41" 1
        
                                $Global:XmlWriter.WriteEndElement()  
                            } 
                        'microsoft.network/publicipaddresses'   
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Public IPs'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzurePIP $TempResLeft $TempResTop "51" "42" 1
        
                                $Global:XmlWriter.WriteEndElement()  
                            }
                        'microsoft.network/virtualnetworks'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Virtual' + "`n" + 'Network'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureVNET  $TempResLeft $TempResTop "62" "42" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }  
                        'microsoft.network/networkwatchers'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Network' + "`n" + 'Watcher'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $NetWatcher  $TempResLeft $TempResTop "44" "44" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }  
                        'microsoft.network/virtualnetworkgateways'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' VPN' + "`n" + 'Gateway'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureVGW  $TempResLeft $TempResTop "36" "40" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            } 
                        'microsoft.network/connections'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Connection'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureConnections  $TempResLeft $TempResTop "44" "44" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            } 
                        'microsoft.network/expressroutecircuits'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Express' + "`n" + 'Route'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureExpressRoute  $TempResLeft $TempResTop "45" "40" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            } 
                        'microsoft.network/networksecuritygroups'   
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Network' + "`n" + 'Security Group'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureNSG  $TempResLeft $TempResTop "37" "46" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }  
                        'microsoft.network/routetables'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' User Defined' + "`n" + 'Route Tables'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureUDRs  $TempResLeft $TempResTop "43" "42" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            } 
                        'microsoft.network/routefilters'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Route' + "`n" + 'Filters'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureRouteFilters  $TempResLeft $TempResTop "54" "34" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            } 
                        'microsoft.network/bastionhosts'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Bastion' + "`n" + 'Host'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureBastionHost  $TempResLeft $TempResTop "31" "37" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            } 
                        'microsoft.compute/proximityplacementgroups'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Proximity' + "`n" + 'Placement Groups'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $Azureproximityplacementgroups  $TempResLeft $TempResTop "47" "45" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            } 
                        'microsoft.network/privatelinkservices'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Private' + "`n" + 'Link Services'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzurePvtLinks  $TempResLeft $TempResTop "56" "33" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            } 
                        'microsoft.network/ipgroups'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' IP' + "`n" + 'Groups'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureIPGroups  $TempResLeft $TempResTop "56" "33" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            } 
                        'microsoft.network/azurefirewalls'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Firewall'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureFW  $TempResLeft $TempResTop "64" "42" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            } 
                        'microsoft.network/localnetworkgateways'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Local' + "`n" + 'Network Gateway'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureLNG  $TempResLeft $TempResTop "50" "50" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            } 
                        'microsoft.network/frontdoors'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Front Door'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureFrontDoor  $TempResLeft $TempResTop "50" "50" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }   
                        'microsoft.network/natgateways'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' NAT' + "`n" + 'Gateways'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureNATGateways  $TempResLeft $TempResTop "50" "50" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            } 
                        'microsoft.network/publicipprefixes'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Public IP' + "`n" + 'Prefixes'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzurePIPPrefixes  $TempResLeft $TempResTop "51" "40" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            } 
                        'microsoft.cdn/profiles'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' CDN' + "`n" + 'Profile'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureCDN  $TempResLeft $TempResTop "64" "36" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }          
                        'microsoft.network/serviceendpointpolicies'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Service' + "`n" + 'Endpoint Polices'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureSvcEndpointPol  $TempResLeft $TempResTop "48" "50" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }       
                        'microsoft.Network/networkInterfaces'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Network' + "`n" + 'Interface'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureVMNIC  $TempResLeft $TempResTop "50" "42" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }                                
                        'microsoft.network/frontdoorwebapplicationfirewallpolicies'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' WAF Policies' + "`n" + '(FrontDoor)'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureWAFPolicies  $TempResLeft $TempResTop "48" "48" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }      
                        'microsoft.cdn/cdnwebapplicationfirewallpolicies'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' WAF Policies' + "`n" + '(CDN)'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureWAFPolicies  $TempResLeft $TempResTop "48" "48" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }       
                        'microsoft.network/applicationgatewaywebapplicationfirewallpolicies'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' WAF Policies' + "`n" + '(App Gateway)'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureWAFPolicies  $TempResLeft $TempResTop "48" "48" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }                
                        'microsoft.network/dnszones'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' DNS' + "`n" + 'Zone'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureDNSZone  $TempResLeft $TempResTop "48" "48" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }     
                        'microsoft.network/applicationgateways'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Application' + "`n" + 'Gateway'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureAppGateway  $TempResLeft $TempResTop "50" "50" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }                    
                        'microsoft.network/ddosprotectionplans'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' DDOS' + "`n" + 'Protection'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureDDOS  $TempResLeft $TempResTop "38" "50" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }   
                        'microsoft.network/trafficmanagerprofiles'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Traffic Manager' + "`n" + 'Profiles'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureTrafficManager  $TempResLeft $TempResTop "50" "50" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }         
                        'microsoft.hybridcompute/privatelinkscopes'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Arc Private' + "`n" + 'Link Scope'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzurePvtLink  $TempResLeft $TempResTop "50" "44" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }    
        
        
                        <########## AZURE OTHER ############>
        
                        'microsoft.portal/dashboards'   
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Shared' + "`n" + 'Dashboard'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $Dashboard $TempResLeft $TempResTop "50.02" "38.25" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }
                        'microsoft.resources/templatespecs'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Template' + "`n" + 'Specs'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $TemplSpec  $TempResLeft $TempResTop "33" "39" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }  
                        'microsoft.dataprotection/backupvaults'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Backup' + "`n" + 'Services Vault'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureBackupVault  $TempResLeft $TempResTop "40" "36" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            } 
                        'microsoft.network/expressrouteports'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' ExpressRoute' + "`n" + 'Direct'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureBackupVault  $TempResLeft $TempResTop "45" "40" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }     
                        'microsoft.desktopvirtualization/hostpools/sessionhosts'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' AVD' + "`n" + 'Session Host'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureAVDSessionHost  $TempResLeft $TempResTop "51" "51" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }       
                        'microsoft.desktopvirtualization/hostpools'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' AVD' + "`n" + 'Host Pool'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureAVDHostPool  $TempResLeft $TempResTop "51" "51" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }   
                        'microsoft.dashboard/grafana'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Grafana'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureGrafana  $TempResLeft $TempResTop "50" "48" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }             
                        'microsoft.network/networkmanagers'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Network' + "`n" + 'Manager'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureNetworkManager  $TempResLeft $TempResTop "46" "50" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }                                                          
        
                        <########## AZURE SECURITY ############>
        
                        'microsoft.keyvault/vaults'   
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Key' + "`n" + 'Vault'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $KeyVault $TempResLeft $TempResTop "40" "40" 1
        
                                $Global:XmlWriter.WriteEndElement()  
                            } 
                        'microsoft.network/applicationsecuritygroups'   
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Application' + "`n" + 'Security Group'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureAppSecGroup $TempResLeft $TempResTop "35" "43" 1
        
                                $Global:XmlWriter.WriteEndElement()  
                            } 
                        'microsoft.easm/workspaces'   
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Defender' + "`n" + 'EASM'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureDefender $TempResLeft $TempResTop "50" "38" 1
        
                                $Global:XmlWriter.WriteEndElement()  
                            }                     
        
                        <########## AZURE STORAGE ############>
        
                        'microsoft.storage/storageaccounts'   
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Storage' + "`n" + 'Account'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $StorageAcc $TempResLeft $TempResTop "49.94" "40" 1
        
                                $Global:XmlWriter.WriteEndElement()  
                            }
                        'microsoft.netapp/netappaccounts'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' NetApp' + "`n" + 'Account'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureNetApp  $TempResLeft $TempResTop "40" "32" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            } 
                        'Microsoft.DataLakeStore/accounts'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Data Lake' + "`n" + 'Storage Gen1'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureDatalakeGen1  $TempResLeft $TempResTop "54" "42" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }                     
        
                        <########## AZURE WEB ############>
        
                        'microsoft.media/mediaservices'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Media' + "`n" + 'Services'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureMediaServices  $TempResLeft $TempResTop "50" "50" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }                     
        
                        <########## MSCAE ############>
        
                        'microsoft.web/certificates'   
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Certificate'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $Certificate $TempResLeft $TempResTop "50" "42" 1
        
                                $Global:XmlWriter.WriteEndElement()  
                            }
                        'microsoft.operationalinsights/workspaces'   
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Log' + "`n" + 'Analytics'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $LogAnalytics  $TempResLeft $TempResTop "40" "40" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }
                        'microsoft.network/privatednszones'   
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Private' + "`n" + 'DNS Zone'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $PvtDNS  $TempResLeft $TempResTop "40" "40" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }
                        'microsoft.saas/resources'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' SaaS' + "`n" + 'Resource'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureSaaS  $TempResLeft $TempResTop "50" "50" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }     
                        'microsoft.relay/namespaces'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Relay'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureRelay  $TempResLeft $TempResTop "50" "50" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }      
                        'microsoft.Insights/ActivityLogAlerts'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Activity Log' + "`n" + 'Alert Rule'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureLogAlertRule  $TempResLeft $TempResTop "48" "48" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }   
                        'Microsoft.AlertsManagement/smartDetectorAlertRules'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Smart Detector' + "`n" + 'Alert Rule'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureLogAlertRule  $TempResLeft $TempResTop "48" "48" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }        
                        'microsoft.insights/scheduledqueryrules'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' Log Search' + "`n" + 'Alert Rule'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureLogAlertRule  $TempResLeft $TempResTop "48" "48" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }    
                        'Microsoft.SignalRService/SignalR'    
                            {
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' SignalR'))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureSignalR  $TempResLeft $TempResTop "48" "48" 1
        
                                $Global:XmlWriter.WriteEndElement()
                            }     
                            
        
                        default
                            {
                                $TempName = [string]$TempResourceType.Name
                                $TempName = $TempName.Replace('microsoft.','')
                                $TempName = $TempName.split('/')
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Count + ' ' + $TempName[0]+ "`n" + $TempName[1]))
                                #$Global:XmlWriter.WriteAttributeString('label', ([string]$TempResourceType.Name))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                    Icon $AzureError $TempResLeft $TempResTop "50" "48" 1
        
                                $Global:XmlWriter.WriteEndElement()  
                            }
                    }
        
        }
        
        
        $Global:NonTypes = ('microsoft.compute/virtualmachines/extensions',
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

        $DDDFile = ($DiagramCache+'Subscriptions.xml')
    
        $XLeft = 100
        $XTop = 100
        $CelNum = 0
    
        $Global:etag = -join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})
        $Global:CellID = -join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})
    
        $Global:IDNum = 0
    
        $Global:XmlWriter = New-Object System.XMl.XmlTextWriter($DDDFile,$Null)
    
        $Global:XmlWriter.Formatting = 'Indented'
        $Global:XmlWriter.Indentation = 2
    
        $Global:XmlWriter.WriteStartDocument()
    
        $Global:XmlWriter.WriteStartElement('mxfile')
        $Global:XmlWriter.WriteAttributeString('host', 'Electron')
        $Global:XmlWriter.WriteAttributeString('modified', '2021-10-01T21:45:40.561Z')
        $Global:XmlWriter.WriteAttributeString('agent', '5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) draw.io/15.4.0 Chrome/91.0.4472.164 Electron/13.5.0 Safari/537.36')
        $Global:XmlWriter.WriteAttributeString('etag', $etag)
        $Global:XmlWriter.WriteAttributeString('version', '15.4.0')
        $Global:XmlWriter.WriteAttributeString('type', 'device')
    
        foreach($Sub in $Subs.Name)
            {
                $RGLeft = $XLeft + 40
                $RGTop = $XTop + 40
                $Resource = $Resources | Where-Object {$_.subscriptionId -eq $Sub}
                $SubName = $Subscriptions | Where-Object {$_.id -eq $Sub}
                $Resource0 = $Resource | Group-Object -Property resourceGroup | Sort-Object -Property Count -Descending   
                $SubName = $SubName.Name             
    
                $DiagID1 = -join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})    
    
                $Global:XmlWriter.WriteStartElement('diagram')
                $Global:XmlWriter.WriteAttributeString('id', $DiagID1)
                $Global:XmlWriter.WriteAttributeString('name', $SubName)
            
                    $Global:XmlWriter.WriteStartElement('mxGraphModel')
                    $Global:XmlWriter.WriteAttributeString('dx', "1326")
                    $Global:XmlWriter.WriteAttributeString('dy', "798")
                    $Global:XmlWriter.WriteAttributeString('grid', "1")
                    $Global:XmlWriter.WriteAttributeString('gridSize', "10")
                    $Global:XmlWriter.WriteAttributeString('guides', "1")
                    $Global:XmlWriter.WriteAttributeString('tooltips', "1")
                    $Global:XmlWriter.WriteAttributeString('connect', "1")
                    $Global:XmlWriter.WriteAttributeString('arrows', "1")
                    $Global:XmlWriter.WriteAttributeString('fold', "1")
                    $Global:XmlWriter.WriteAttributeString('page', "1")
                    $Global:XmlWriter.WriteAttributeString('pageScale', "1")
                    $Global:XmlWriter.WriteAttributeString('pageWidth', "850")
                    $Global:XmlWriter.WriteAttributeString('pageHeight', "1100")
                    $Global:XmlWriter.WriteAttributeString('math', "0")
                    $Global:XmlWriter.WriteAttributeString('shadow', "0")
            
                        $Global:XmlWriter.WriteStartElement('root')
            
                            $Global:XmlWriter.WriteStartElement('mxCell')
                            $Global:XmlWriter.WriteAttributeString('id', "0")
                            $Global:XmlWriter.WriteEndElement()
            
                            $Global:XmlWriter.WriteStartElement('mxCell')
                            $Global:XmlWriter.WriteAttributeString('id', "1")
                            $Global:XmlWriter.WriteAttributeString('parent', "0")
                            $Global:XmlWriter.WriteEndElement()
            
                                variables
    
                                $Global:CellIDRes = -join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})
    
                                $Witd = 2060
    
                                $Counter = 1
                                $ZCounter = 0
                                    foreach($RG in $Resource0.Name)
                                        {
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
    
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', '')
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellIDRes+'-'+($CelNum++)))
    
                                    Icon $Ret $XLeft $XTop $Witd $SubHeight 1
                                
                                $Global:XmlWriter.WriteEndElement()
    
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', $SubName)
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
    
                                    Icon $IconSubscription 30 ($XTop+$SubHeight-20) "67" "40" 1
    
                                $Global:XmlWriter.WriteEndElement()  
    
    
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
    
    
                                            $Global:XmlWriter.WriteStartElement('object')
                                            $Global:XmlWriter.WriteAttributeString('label', '')
                                            $Global:XmlWriter.WriteAttributeString('id', ($Global:CellIDRes+'-'+($CelNum++)))
    
                                                Icon $RetRound $RGLeft $RGTop $RGWitdh ($RGHeigh*120) 1
    
                                            $Global:XmlWriter.WriteEndElement()                        
    
                                            if($Counter -eq 1)
                                                {
                                                    $Global:XmlWriter.WriteStartElement('object')            
                                                    $Global:XmlWriter.WriteAttributeString('label', $RG)
                                                    $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
                            
                                                        Icon $IconRG ($XLeft+20) ($RGTop+($RGHeigh*120)-20) "37.5" "30" 1
                            
                                                    $Global:XmlWriter.WriteEndElement()  
    
                                                    $ResTypeLeft = $RGLeft + 60
                                                    $ResTypeTop = $RGTop + 25
                                                    $YCounter = 1
    
                                                    foreach($res0 in $Resource1)
                                                        {
                                                            ResourceTypes $res0 $ResTypeLeft $ResTypeTop
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
                                                    $Global:XmlWriter.WriteStartElement('object')            
                                                    $Global:XmlWriter.WriteAttributeString('label', $RG)
                                                    $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
                            
                                                        Icon $IconRG ($RGLeft + $RGWitdh - 20) ($RGTop+($RGHeigh*120)-20) "37.5" "30" 1
                            
                                                    $Global:XmlWriter.WriteEndElement()  
    
                                                    $ResTypeLeft = $RGLeft + 60
                                                    $ResTypeTop = $RGTop + 25
                                                    $YCounter = 1
    
                                                    foreach($res0 in $Resource1)
                                                        {
                                                            ResourceTypes $res0 $ResTypeLeft $ResTypeTop
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
    
                            $Global:XmlWriter.WriteEndElement()
    
                        $Global:XmlWriter.WriteEndElement()
                
                    $Global:XmlWriter.WriteEndElement()
            }
    
            $Global:XmlWriter.WriteEndDocument()
            $Global:XmlWriter.Flush()
            $Global:XmlWriter.Close()

    } -ArgumentList $Subscriptions,$Resources,$DiagramCache

}

Function Organization {
    Param($ResourceContainers,$DiagramCache)

    Start-Job -Name 'Diagram_Organization' -ScriptBlock {

    $Global:ResourceContainers = $($args[0])
    $Global:DiagramCache = $($args[1])
    
    Function Icon {    
        Param($Style,$x,$y,$w,$h,$p)
        
            $Global:XmlWriter.WriteStartElement('mxCell')
            $Global:XmlWriter.WriteAttributeString('style', $Style)
            $Global:XmlWriter.WriteAttributeString('vertex', "1")
            $Global:XmlWriter.WriteAttributeString('parent', $p)
        
                $Global:XmlWriter.WriteStartElement('mxGeometry')
                $Global:XmlWriter.WriteAttributeString('x', $x)
                $Global:XmlWriter.WriteAttributeString('y', $y)
                $Global:XmlWriter.WriteAttributeString('width', $w)
                $Global:XmlWriter.WriteAttributeString('height', $h)
                $Global:XmlWriter.WriteAttributeString('as', "geometry")
                $Global:XmlWriter.WriteEndElement()
            
            $Global:XmlWriter.WriteEndElement()
        }

    Function Connect {
        Param($Source,$Target,$Parent)
        
            if($Parent){$Parent = $Parent}else{$Parent = 1}
        
            $Global:XmlWriter.WriteStartElement('mxCell')
            $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
            $Global:XmlWriter.WriteAttributeString('style', "edgeStyle=none;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;endArrow=none;endFill=0;")
            $Global:XmlWriter.WriteAttributeString('edge', "1")
            $Global:XmlWriter.WriteAttributeString('vertex', "1")
            $Global:XmlWriter.WriteAttributeString('parent', $Parent)
            $Global:XmlWriter.WriteAttributeString('source', $Source)
            $Global:XmlWriter.WriteAttributeString('target', $Target)
        
                $Global:XmlWriter.WriteStartElement('mxGeometry')
                $Global:XmlWriter.WriteAttributeString('relative', "1")
                $Global:XmlWriter.WriteAttributeString('as', "geometry")
                $Global:XmlWriter.WriteEndElement()
            
            $Global:XmlWriter.WriteEndElement()
        
        }

    Function Container0 {
        Param($x,$y,$w,$h,$title)
            $Global:ContID0 = (-join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})+'-'+1)
    
            $Global:XmlWriter.WriteStartElement('mxCell')
            $Global:XmlWriter.WriteAttributeString('id', $Global:ContID0)
            $Global:XmlWriter.WriteAttributeString('value', "$title")
            $Global:XmlWriter.WriteAttributeString('style', "swimlane;whiteSpace=wrap;html=1;fillColor=#f5f5f5;fontColor=#333333;strokeColor=#666666;swimlaneFillColor=#F5F5F5;rounded=1;")
            $Global:XmlWriter.WriteAttributeString('vertex', "1")
            $Global:XmlWriter.WriteAttributeString('parent', "1")
        
                $Global:XmlWriter.WriteStartElement('mxGeometry')
                $Global:XmlWriter.WriteAttributeString('x', $x)
                $Global:XmlWriter.WriteAttributeString('y', $y)
                $Global:XmlWriter.WriteAttributeString('width', $w)
                $Global:XmlWriter.WriteAttributeString('height', $h)
                $Global:XmlWriter.WriteAttributeString('as', "geometry")
                $Global:XmlWriter.WriteEndElement()
            
            $Global:XmlWriter.WriteEndElement()
    }

    Function Container1 {
        Param($x,$y,$w,$h,$title)
            $Global:ContID = (-join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})+'-'+1)
    
            $Global:XmlWriter.WriteStartElement('mxCell')
            $Global:XmlWriter.WriteAttributeString('id', $Global:ContID)
            $Global:XmlWriter.WriteAttributeString('value', "$title")
            $Global:XmlWriter.WriteAttributeString('style', "swimlane;whiteSpace=wrap;html=1;fillColor=#d5e8d4;strokeColor=#82b366;swimlaneFillColor=#D5E8D4;rounded=1;")
            $Global:XmlWriter.WriteAttributeString('vertex', "1")
            $Global:XmlWriter.WriteAttributeString('parent', "1")
        
                $Global:XmlWriter.WriteStartElement('mxGeometry')
                $Global:XmlWriter.WriteAttributeString('x', $x)
                $Global:XmlWriter.WriteAttributeString('y', $y)
                $Global:XmlWriter.WriteAttributeString('width', $w)
                $Global:XmlWriter.WriteAttributeString('height', $h)
                $Global:XmlWriter.WriteAttributeString('as', "geometry")
                $Global:XmlWriter.WriteEndElement()
            
            $Global:XmlWriter.WriteEndElement()
    }

    Function Container2 {
        Param($x,$y,$w,$h,$title,$p)
            $Global:ContID2 = (-join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})+'-'+1)
    
            $Global:XmlWriter.WriteStartElement('mxCell')
            $Global:XmlWriter.WriteAttributeString('id', $Global:ContID2)
            $Global:XmlWriter.WriteAttributeString('value', "$title")
            $Global:XmlWriter.WriteAttributeString('style', "swimlane;whiteSpace=wrap;html=1;fillColor=#dae8fc;strokeColor=#6c8ebf;swimlaneFillColor=#DAE8FC;rounded=1;")
            $Global:XmlWriter.WriteAttributeString('vertex', "1")
            $Global:XmlWriter.WriteAttributeString('parent', $p)
        
                $Global:XmlWriter.WriteStartElement('mxGeometry')
                $Global:XmlWriter.WriteAttributeString('x', $x)
                $Global:XmlWriter.WriteAttributeString('y', $y)
                $Global:XmlWriter.WriteAttributeString('width', $w)
                $Global:XmlWriter.WriteAttributeString('height', $h)
                $Global:XmlWriter.WriteAttributeString('as', "geometry")
                $Global:XmlWriter.WriteEndElement()
            
            $Global:XmlWriter.WriteEndElement()
    }

    Function Container3 {
        Param($x,$y,$w,$h,$title,$p)
            $Global:ContID3 = (-join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})+'-'+1)
    
            $Global:XmlWriter.WriteStartElement('mxCell')
            $Global:XmlWriter.WriteAttributeString('id', $Global:ContID3)
            $Global:XmlWriter.WriteAttributeString('value', "$title")
            $Global:XmlWriter.WriteAttributeString('style', "swimlane;whiteSpace=wrap;html=1;fillColor=#ffe6cc;strokeColor=#d79b00;swimlaneFillColor=#FFE6CC;rounded=1;")
            $Global:XmlWriter.WriteAttributeString('vertex', "1")
            $Global:XmlWriter.WriteAttributeString('parent', $p)
        
                $Global:XmlWriter.WriteStartElement('mxGeometry')
                $Global:XmlWriter.WriteAttributeString('x', $x)
                $Global:XmlWriter.WriteAttributeString('y', $y)
                $Global:XmlWriter.WriteAttributeString('width', $w)
                $Global:XmlWriter.WriteAttributeString('height', $h)
                $Global:XmlWriter.WriteAttributeString('as', "geometry")
                $Global:XmlWriter.WriteEndElement()
            
            $Global:XmlWriter.WriteEndElement()
    }

    Function Container4 {
        Param($x,$y,$w,$h,$title,$p)
            $Global:ContID4 = (-join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})+'-'+1)
    
            $Global:XmlWriter.WriteStartElement('mxCell')
            $Global:XmlWriter.WriteAttributeString('id', $Global:ContID4)
            $Global:XmlWriter.WriteAttributeString('value', "$title")
            $Global:XmlWriter.WriteAttributeString('style', "swimlane;whiteSpace=wrap;html=1;fillColor=#ffe6cc;strokeColor=#d79b00;swimlaneFillColor=#FFE6CC;rounded=1;")
            $Global:XmlWriter.WriteAttributeString('vertex', "1")
            $Global:XmlWriter.WriteAttributeString('parent', $p)
        
                $Global:XmlWriter.WriteStartElement('mxGeometry')
                $Global:XmlWriter.WriteAttributeString('x', $x)
                $Global:XmlWriter.WriteAttributeString('y', $y)
                $Global:XmlWriter.WriteAttributeString('width', $w)
                $Global:XmlWriter.WriteAttributeString('height', $h)
                $Global:XmlWriter.WriteAttributeString('as', "geometry")
                $Global:XmlWriter.WriteEndElement()
            
            $Global:XmlWriter.WriteEndElement()
    }

    Function Stencils {
        $Global:IconSubscription = "aspect=fixed;html=1;points=[];align=center;image;fontSize=20;image=img/lib/azure2/general/Subscriptions.svg;" #width="44" height="71"
        $Global:IconMgmtGroup = "aspect=fixed;html=1;points=[];align=center;image;fontSize=20;image=img/lib/azure2/general/Management_Groups.svg;" #width="44" height="71"
        $Global:Ret = "rounded=1;whiteSpace=wrap;fontSize=16;html=1;sketch=0;fontFamily=Helvetica;"
        $Global:Ret1 = "rounded=1;whiteSpace=wrap;fontSize=16;html=1;sketch=0;fontFamily=Helvetica;fillColor=#b0e3e6;strokeColor=#0e8088;"
        $Global:Ret2 = "rounded=1;whiteSpace=wrap;fontSize=16;html=1;sketch=0;fontFamily=Helvetica;fillColor=#b1ddf0;strokeColor=#10739e;"
        $Global:Ret3 = "rounded=1;whiteSpace=wrap;fontSize=16;html=1;sketch=0;fontFamily=Helvetica;fillColor=#fad7ac;strokeColor=#b46504;"
        $Global:Ret4 = "rounded=1;whiteSpace=wrap;fontSize=16;html=1;sketch=0;fontFamily=Helvetica;fillColor=#e1d5e7;strokeColor=#9673a6;"

    }

    Function Org {

            $OrgObjs = $Global:ResourceContainers | Where-Object {$_.Type -eq 'microsoft.resources/subscriptions'} 

            $Global:1stLevel = @()
            $Lvl2 = @()
            $Lvl3 = @()
            $Lvl4 = @()
            foreach($org in $OrgObjs)
                {
                    if($org.properties.managementgroupancestorschain.count -eq 2)
                        {                            
                            $Global:1stLevel += $org.properties.managementgroupancestorschain.displayname[0]
                        }
                    if($org.properties.managementgroupancestorschain.count -eq 3)
                        {
                            $Lvl2 += $org.properties.managementgroupancestorschain.name[0]
                            $Global:1stLevel += $org.properties.managementgroupancestorschain.displayname[1]
                        }
                    if($org.properties.managementgroupancestorschain.count -eq 4)
                        {
                            $Lvl3 += $org.properties.managementgroupancestorschain.name[0]
                            $Lvl2 += $org.properties.managementgroupancestorschain.name[1]
                            $Global:1stLevel += $org.properties.managementgroupancestorschain.displayname[2]
                        }
                    if($org.properties.managementgroupancestorschain.count -eq 5)
                        {
                            $Lvl4 += $org.properties.managementgroupancestorschain.name[0]
                            $Lvl3 += $org.properties.managementgroupancestorschain.name[1]
                            $Lvl2 += $org.properties.managementgroupancestorschain.name[2]
                            $Global:1stLevel += $org.properties.managementgroupancestorschain.displayname[3]
                        }
                }

            $Global:1stLevel = $Global:1stLevel | Select-Object -Unique
            $Lvl2 = $Lvl2 | Select-Object -Unique
            $Lvl3 = $Lvl3 | Select-Object -Unique
            $Lvl4 = $Lvl4 | Select-Object -Unique

            $Global:XLeft = 0
            $Global:XTop = 100
            $XXLeft = 100

            $Global:XTop = $Global:XTop + 200

            $RoundSubs00 = @() 
            foreach($Sub in $OrgObjs)
                    {
                        if($Sub.properties.managementgroupancestorschain[0].displayname -eq 'tenant root group')
                            {
                                $RoundSubs00 += $Sub
                            }
                    }
            
            $MgmtHeight0 = (($RoundSubs00.id.count * 70) + 80)

            Container0 '0' '0' '200' $MgmtHeight0 'tenant root group'

            $Global:XmlWriter.WriteStartElement('object')            
            $Global:XmlWriter.WriteAttributeString('label', '')
            $Global:XmlWriter.WriteAttributeString('ManagementGroup', 'tenant root group')
            $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))                        

                if($RoundSubs00)
                    {
                        icon $Global:IconMgmtGroup '-30' ($MgmtHeight0-15) '50' '50' $Global:ContID0
                    }
                else
                    {
                        icon $Global:IconMgmtGroup '75' '27' '50' '50' $Global:ContID0
                    }

            $Global:XmlWriter.WriteEndElement()

            $LocalTop = 50
            $LocalLeft = 25

            foreach($Sub in $RoundSubs00)
            {
                $RGs = $Global:ResourceContainers | Where-Object {$_.Type -eq 'microsoft.resources/subscriptions/resourcegroups' -and $_.subscriptionid -eq $sub.subscriptionid}

                $Global:XmlWriter.WriteStartElement('object')            
                $Global:XmlWriter.WriteAttributeString('label', $sub.name)
                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellIDRes+'-'+($Global:CelNum++)))

                    Icon $Ret1 $LocalLeft $LocalTop '150' '70' $Global:ContID0
                
                $Global:XmlWriter.WriteEndElement()

                $Global:XmlWriter.WriteStartElement('object')            
                $Global:XmlWriter.WriteAttributeString('label', '')

                $RGNum = 1
                foreach($RG in $RGs)
                    {
                        $Attr = ('ResourceGroup_'+[string]$RGNum)
                        $Global:XmlWriter.WriteAttributeString($Attr, [string]$RG.Name)
                        $RGNum++
                    }
                
                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))                        
    
                    icon $Global:IconSubscription ($LocalLeft+140) ($LocalTop+40) '31' '51' $Global:ContID0
    
                $Global:XmlWriter.WriteEndElement()

                $LocalTop = $LocalTop + 90

            }




            foreach($1stlvl in $Global:1stLevel)
                {
                $RoundSubs0 = @() 
                
                foreach($Sub in $OrgObjs)
                    {
                        if($Sub.properties.managementgroupancestorschain.displayname[0] -eq $1stlvl)
                            {
                                $RoundSubs0 += $Sub
                            }
                    }
    
                $MgmtHeight = (($RoundSubs0.id.count * 70) + 80)

                Container1 $XLeft $XTop '200' $MgmtHeight $1stlvl $Global:ContID0       
                
                $Global:XmlWriter.WriteStartElement('object')            
                $Global:XmlWriter.WriteAttributeString('label', '')
                $Global:XmlWriter.WriteAttributeString('ManagementGroup', [string]$1stlvl)
                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))                        
    
                if($RoundSubs0)
                    {
                        icon $Global:IconMgmtGroup '-30' ($MgmtHeight-15) '50' '50' $Global:ContID
                    }
                else
                    {
                        icon $Global:IconMgmtGroup '75' '27' '50' '50' $Global:ContID
                    }
    
                $Global:XmlWriter.WriteEndElement()

                Connect $Global:ContID0 $Global:ContID

                $LocalTop = 50
                $LocalLeft = 25

                foreach($Sub in $RoundSubs0)
                    {
                        $RGs = $Global:ResourceContainers | Where-Object {$_.Type -eq 'microsoft.resources/subscriptions/resourcegroups' -and $_.subscriptionid -eq $sub.subscriptionid}

                        $Global:XmlWriter.WriteStartElement('object')            
                        $Global:XmlWriter.WriteAttributeString('label', $sub.name)
                        $Global:XmlWriter.WriteAttributeString('id', ($Global:CellIDRes+'-'+($Global:CelNum++)))

                            Icon $Ret1 $LocalLeft $LocalTop '150' '70' $Global:ContID
                        
                        $Global:XmlWriter.WriteEndElement()

                        $Global:XmlWriter.WriteStartElement('object')            
                        $Global:XmlWriter.WriteAttributeString('label', '')

                        $RGNum = 1
                        foreach($RG in $RGs)
                            {
                                $Attr = ('ResourceGroup_'+[string]$RGNum)
                                $Global:XmlWriter.WriteAttributeString($Attr, [string]$RG.Name)
                                $RGNum++
                            }
                        
                        $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))                        
            
                            icon $Global:IconSubscription ($LocalLeft+140) ($LocalTop+40) '31' '51' $Global:ContID
            
                        $Global:XmlWriter.WriteEndElement()

                        $LocalTop = $LocalTop + 90

                    }
                
                ######################################## 2ND LEVEL ##############################################
                
                $2ndLevel = @()
                foreach($sub2nd in $OrgObjs)
                {                 
                    if($sub2nd.properties.managementgroupancestorschain.displayname[1] -eq $1stlvl)
                        {
                            $2ndLevel += $sub2nd.properties.managementgroupancestorschain.name[0]
                        }
                    if($sub2nd.properties.managementgroupancestorschain.displayname[2] -eq $1stlvl)
                        {
                            $2ndLevel += $sub2nd.properties.managementgroupancestorschain.name[1]
                        }
                    if($sub2nd.properties.managementgroupancestorschain.displayname[3] -eq $1stlvl)
                        {
                            $2ndLevel += $sub2nd.properties.managementgroupancestorschain.name[2]
                        }
                }
                $2ndLevel = $2ndLevel | Select-Object -Unique
                
                $XXLeft = 0
                if($2ndLevel.count  % 2 -eq 1 )
                    {
                        $Align = $true
                        $loops = -[Math]::ceiling($2ndLevel.count /2 - 1)
                    }
                else
                    {
                        $Align = $false
                        $loops = [Math]::ceiling($2ndLevel.count / 2)
                        
                    }
                if($2ndLevel.count -eq 1)
                    {
                        $loops = 1
                    }
                $TempSon = 0


                foreach($2nd in $2ndLevel)
                    {
                        $RoundSubs = @() 
                        $Temp3rd = @()
                        $Temp4rd = @()
                        $Temp5th = @()                                        

                        foreach($Sub in $OrgObjs)
                            {
                                if($Sub.properties.managementgroupancestorschain.name[0] -eq $2nd)
                                    {
                                        $RoundSubs += $Sub
                                    }
                                if($Sub.properties.managementgroupancestorschain.name[1] -eq $2nd)
                                    {
                                        $Temp3rd += $Sub.properties.managementgroupancestorschain.name[0]
                                    }
                                if($Sub.properties.managementgroupancestorschain.name[2] -eq $2nd)
                                    {
                                        $Temp4rd += $Sub.properties.managementgroupancestorschain.name[0]
                                        $Temp3rd += $Sub.properties.managementgroupancestorschain.name[1]
                                    }
                                if($Sub.properties.managementgroupancestorschain.name[3] -eq $2nd)
                                    {
                                        $Temp5th += $Sub.properties.managementgroupancestorschain.name[0]
                                        $Temp4rd += $Sub.properties.managementgroupancestorschain.name[1]
                                        $Temp3rd += $Sub.properties.managementgroupancestorschain.name[2]
                                    }
                            }

                        $Temp3rd = $Temp3rd | Select-Object -Unique
                        $Temp4rd = $Temp4rd | Select-Object -Unique
                        $Temp5th = $Temp5th | Select-Object -Unique

                        if($XXLeft -eq 0 -and $Align -eq $true)
                            {
                            }
                        elseif($XXLeft -eq 0 -and $Align -eq $false)
                            {
                                $XXLeft = -150 + -((((($Temp3rd.count)+($Temp4rd.count)+($Temp5th.count)))*300)/2)
                                $loops++
                            }
                        elseif($Align -eq $false -and $loops -eq 0)
                            {
                                $XXLeft = 150 + ((((($Temp3rd.count)+($Temp4rd.count)+($Temp5th.count)))*300)/2)
                                $loops++
                            }
                        elseif($loops -gt 0 -and $XXLeft -eq 0)
                            {
                                $XXLeft = $XXLeft + ($2ndLevel.count*300)/2 + ((((($Temp3rd.count)+($Temp4rd.count)+($Temp5th.count)))*300)/2)
                                $loops++
                            }
                        elseif($XXLeft -le 0 -and $loops -lt 0)
                            {
                                $XXTemp = if(((((($Temp3rd.count)+($Temp4rd.count)+($Temp5th.count)+$TempSon))*150)) -eq 0){300}else{((((($Temp3rd.count)+($Temp4rd.count)+($Temp5th.count)+$TempSon))*150))}
                                $XXLeft = $XXLeft + -$XXTemp
                                $loops++
                            }
                        elseif($XXLeft -gt 0 -and $loops -ge 0)
                            {
                                $XXTemp = if(((((($Temp3rd.count)+($Temp4rd.count)+($Temp5th.count)+$TempSon))*150)) -eq 0){300}else{((((($Temp3rd.count)+($Temp4rd.count)+($Temp5th.count)+$TempSon))*150))}
                                $XXLeft = $XXLeft + $XXTemp
                                $loops++
                            }
                        else
                            {
                                $XXTemp = if(((((($Temp3rd.count)+($Temp4rd.count)+($Temp5th.count)+$TempSon))*300)) -eq 0){300}else{((((($Temp3rd.count)+($Temp4rd.count)+($Temp5th.count)+$TempSon))*300))}
                                $XXLeft = $XXLeft + $XXTemp
                                $loops++
                            }
                        write-host $XXleft

                        $MgmtHeight1 = if((($RoundSubs.id.count * 90) + 50) -eq 50){80}else{(($RoundSubs.id.count * 90) + 50)}
                        
                        $XXTop = $MgmtHeight + 200

                        Container2 $XXLeft $XXTop '200' $MgmtHeight1 $2nd $Global:ContID

                        $Global:XmlWriter.WriteStartElement('object')            
                        $Global:XmlWriter.WriteAttributeString('label', '')
                        $Global:XmlWriter.WriteAttributeString('ManagementGroup', [string]$2nd)
                        $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))                        
            
                        if($RoundSubs)
                            {
                                icon $Global:IconMgmtGroup '-30' ($MgmtHeight1-15) '50' '50' $Global:ContID2
                            }
                        else
                            {
                                icon $Global:IconMgmtGroup '75' '27' '50' '50' $Global:ContID2
                            }
            
                        $Global:XmlWriter.WriteEndElement()

                        Connect $Global:ContID $Global:ContID2

                        $TempSon = (($Temp3rd.count)+($Temp4rd.count)+($Temp5th.count))

                        if($XXLeft -eq 0 -and $loops -lt 0)
                            {
                                $XXLeft = -1
                            }
                        elseif($XXLeft -lt 0 -and $loops -ge 0)
                            {
                                $XXLeft = 1
                            }

                        $LocalTop = 50
                        $LocalLeft = 25
        
                        foreach($Sub in $RoundSubs)
                            {                                
                                $RGs = $Global:ResourceContainers | Where-Object {$_.Type -eq 'microsoft.resources/subscriptions/resourcegroups' -and $_.subscriptionid -eq $sub.subscriptionid}

                                $Global:XmlWriter.WriteStartElement('object')
                                $Global:XmlWriter.WriteAttributeString('label', $sub.name)
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellIDRes+'-'+($Global:CelNum++)))
        
                                    Icon $Ret2 $LocalLeft $LocalTop '150' '70' $Global:ContID2
                                
                                $Global:XmlWriter.WriteEndElement()

                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', '')

                                $RGNum = 1
                                foreach($RG in $RGs)
                                    {
                                        $Attr = ('ResourceGroup_'+[string]$RGNum)
                                        $Global:XmlWriter.WriteAttributeString($Attr, [string]$RG.Name)
                                        $RGNum++
                                    }
                                
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))                        
                    
                                    icon $Global:IconSubscription ($LocalLeft+140) ($LocalTop+40) '31' '51' $Global:ContID2
                    
                                $Global:XmlWriter.WriteEndElement()

                                $LocalTop = $LocalTop + 90
                            }


                        ######################################## 3RD LEVEL ##############################################

                        $3rdLevel = @()
                        foreach($sub3rd in $OrgObjs)
                            {                 
                                if($sub3rd.properties.managementgroupancestorschain.name[1] -eq $2nd)
                                    {
                                        $3rdLevel += $sub3rd.properties.managementgroupancestorschain.name[0]
                                    }
                                if($sub3rd.properties.managementgroupancestorschain.name[2] -eq $2nd)
                                    {
                                        $3rdLevel += $sub3rd.properties.managementgroupancestorschain.name[1]
                                    }
                                if($sub3rd.properties.managementgroupancestorschain.name[3] -eq $2nd)
                                    {
                                        $3rdLevel += $sub3rd.properties.managementgroupancestorschain.name[2]
                                    }
                            }
                            $3rdLevel = $3rdLevel | Select-Object -Unique

                            $XXXLeft = 0
                            if($3rdLevel.count  % 2 -eq 1 )
                                {
                                    $Align3 = $true
                                    $loops3 = -[Math]::ceiling($3rdLevel.count / 2 - 1)
                                }
                            else
                                {
                                    $Align3 = $false
                                    $loops3 = [Math]::ceiling($3rdLevel.count / 2) - 1
                                    
                                }
                            if($3rdLevel.count -eq 1)
                                {
                                    $loops3 = 1
                                }


                        foreach($3rd in $3rdLevel)
                            {   
                                $RoundSubs3 = @() 
                                $Temp4rd3 = @()
                                $Temp5th3 = @()
                        
                                foreach($Sub in $OrgObjs)
                                    {
                                        if($Sub.properties.managementgroupancestorschain.name[0] -eq $3rd)
                                            {
                                                $RoundSubs3 += $Sub
                                            }
                                        if($Sub.properties.managementgroupancestorschain.name[1] -eq $3rd)
                                            {
                                                $Temp4rd3 += $Sub.properties.managementgroupancestorschain.name[0]
                                            }
                                        if($Sub.properties.managementgroupancestorschain.name[2] -eq $3rd)
                                            {
                                                $Temp5th3 += $Sub.properties.managementgroupancestorschain.name[0]
                                                $Temp4rd3 += $Sub.properties.managementgroupancestorschain.name[1]
                                            }
                                    }

                                $Temp4rd3 = $Temp4rd3 | Select-Object -Unique
                                $Temp5th3 = $Temp5th3 | Select-Object -Unique
                            

                                if($XXXLeft -eq 0 -and $Align3 -eq $true)
                                    {
                                    }
                                elseif($XXXLeft -eq 0 -and $Align3 -eq $false)
                                    {
                                        $XXXLeft = -150 + -((((($Temp4rd3.count)+($Temp5th3.count)))*150)/2)
                                        $loops3++
                                    }
                                elseif($Align3 -eq $false -and $loops3 -eq 0)
                                    {
                                        $XXXLeft = 150 + ((((($Temp4rd3.count)+($Temp5th3.count)))*150)/2)
                                        $loops3++
                                    }
                                elseif($loops3 -gt 0 -and $XXXLeft -eq 0)
                                    {
                                        $XXXLeft = $XXXLeft + ($3rdLevel.count*300)/2 + ((((($Temp4rd3.count)+($Temp5th3.count)))*300)/2)
                                        $loops3++
                                    }
                                elseif($XXXLeft -eq 0 -and $loops3 -lt 0)
                                    {
                                        $XXXTemp = if(((((($Temp4rd3.count)+($Temp5th3.count)))*300)) -eq 0){300}else{((((($Temp4rd3.count)+($Temp5th3.count)))*300))}
                                        $XXXLeft = $XXXLeft + -$XXXTemp
                                        $loops3++
                                    }
                                elseif($XXXLeft -lt 0 -and $loops3 -lt 0)
                                    {
                                        $XXXTemp = if(((((($Temp4rd3.count)+($Temp5th3.count)))*300)) -eq 0){300}else{((((($Temp4rd3.count)+($Temp5th3.count)))*300))}
                                        $XXXLeft = $XXXLeft + -$XXXTemp
                                        $loops3++
                                    }
                                elseif($XXXLeft -eq 1 -and $loops3 -gt 0)
                                    {
                                        $XXXLeft = 150 + ((((($Temp4rd3.count)+($Temp5th3.count)))*150))
                                        $loops3++
                                    }
                                else
                                    {
                                        $XXXTemp = if(((((($Temp4rd3.count)+($Temp5th3.count)))*300)) -eq 0){300}else{((((($Temp4rd3.count)+($Temp5th3.count)))*300))}
                                        $XXXLeft = $XXXLeft + $XXXTemp
                                        $loops3++
                                    }
    
                                
                                $MgmtHeight2 = if((($RoundSubs3.id.count * 90) + 50) -eq 50){80}else{(($RoundSubs3.id.count * 90) + 50)}

                                $XXXTop = $MgmtHeight1 + 200

                                Container3 $XXXLeft $XXXTop '200' $MgmtHeight2 $3rd $Global:ContID2

                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', '')
                                $Global:XmlWriter.WriteAttributeString('ManagementGroup', [string]$3rd)
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))                        
                    
                                if($RoundSubs3)
                                    {
                                        icon $Global:IconMgmtGroup '-30' ($MgmtHeight2-15) '50' '50' $Global:ContID3
                                    }
                                else
                                    {
                                        icon $Global:IconMgmtGroup '75' '27' '50' '50' $Global:ContID3
                                    }
                    
                                $Global:XmlWriter.WriteEndElement()

                                Connect $Global:ContID2 $Global:ContID3

                                if($XXXLeft -eq 0 -and $loops3 -lt 0)
                                    {
                                        $XXXLeft = -1
                                    }
                                elseif($XXXLeft -lt 0 -and $loops3 -ge 0)
                                    {
                                        $XXXLeft = 1
                                    }

                                $LocalTop = 50
                                $LocalLeft = 25

                                foreach($Sub in $RoundSubs3)
                                    {                                

                                        $RGs = $Global:ResourceContainers | Where-Object {$_.Type -eq 'microsoft.resources/subscriptions/resourcegroups' -and $_.subscriptionid -eq $sub.subscriptionid}

                                        $Global:XmlWriter.WriteStartElement('object')
                                        $Global:XmlWriter.WriteAttributeString('label', $sub.name)
                                        $Global:XmlWriter.WriteAttributeString('id', ($Global:CellIDRes+'-'+($Global:CelNum++)))
                
                                            Icon $Ret3 $LocalLeft $LocalTop '150' '70' $Global:ContID3
                                        
                                        $Global:XmlWriter.WriteEndElement()

                                        $Global:XmlWriter.WriteStartElement('object')            
                                        $Global:XmlWriter.WriteAttributeString('label', '')

                                        $RGNum = 1
                                        foreach($RG in $RGs)
                                            {
                                                $Attr = ('ResourceGroup_'+[string]$RGNum)
                                                $Global:XmlWriter.WriteAttributeString($Attr, [string]$RG.Name)
                                                $RGNum++
                                            }
                                        
                                        $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))                        
                            
                                            icon $Global:IconSubscription ($LocalLeft+140) ($LocalTop+40) '31' '51' $Global:ContID3
                            
                                        $Global:XmlWriter.WriteEndElement()
                
                                        $LocalTop = $LocalTop + 90
                                    }


                                    ######################################## 4TH LEVEL ##############################################

                                    $4thLevel = @()
                                    foreach($sub4th in $OrgObjs)
                                        {                 
                                            if($sub4th.properties.managementgroupancestorschain.name[1] -eq $3rd)
                                                {
                                                    $4thLevel += $sub4th.properties.managementgroupancestorschain.name[0]
                                                }
                                            if($sub4th.properties.managementgroupancestorschain.name[2] -eq $3rd)
                                                {
                                                    $4thLevel += $sub4th.properties.managementgroupancestorschain.name[1]
                                                }
                                            if($sub4th.properties.managementgroupancestorschain.name[3] -eq $3rd)
                                                {
                                                    $4thLevel += $sub4th.properties.managementgroupancestorschain.name[2]
                                                }
                                        }
                                        $4thLevel = $4thLevel | Select-Object -Unique

                                        $XXXXLeft = 0
                                        if($4thLevel.count  % 2 -eq 1 )
                                            {
                                                $Align4 = $true
                                                $loops4 = -[Math]::ceiling($sub4th.count / 2 - 1)
                                            }
                                        else
                                            {
                                                $Align4 = $false
                                                $loops4 = [Math]::ceiling($sub4th.count / 2) - 1
                                                
                                            }
                                        if($4thLevel.count -eq 1)
                                            {
                                                $loops4 = 1
                                            }


                                    foreach($4th in $4thLevel)
                                        {                              
                                            $RoundSubs4 = @() 
                                            $Temp5th4 = @()
                                    
                                            foreach($Sub in $OrgObjs)
                                                {
                                                    if($Sub.properties.managementgroupancestorschain.name[0] -eq $4th)
                                                        {
                                                            $RoundSubs4 += $Sub
                                                        }
                                                    if($Sub.properties.managementgroupancestorschain.name[1] -eq $4th)
                                                        {
                                                            $Temp5th4 += $Sub.properties.managementgroupancestorschain.name[0]
                                                        }
                                                    if($Sub.properties.managementgroupancestorschain.name[2] -eq $4th)
                                                        {
                                                            $Temp5th4 += $Sub.properties.managementgroupancestorschain.name[0]
                                                        }
                                                }

                                            $Temp5th4 = $Temp5th4 | Select-Object -Unique

                                            if($XXXXLeft -eq 0 -and $Align4 -eq $true)
                                                {
                                                }
                                            elseif($XXXXLeft -eq 0 -and $Align4 -eq $false)
                                                {
                                                    $XXXXLeft = -150 + -((((($Temp4rd4.count)+($Temp5th4.count)))*150)/2)
                                                    $loops4++
                                                }
                                            elseif($Align4 -eq $false -and $loops4 -eq 0)
                                                {
                                                    $XXXXLeft = 150 + ((((($Temp4rd4.count)+($Temp5th4.count)))*150)/2)
                                                    $loops4++
                                                }
                                            elseif($loops4 -gt 0 -and $XXXXLeft -eq 0)
                                                {
                                                    $XXXXLeft = $XXXXLeft + ($4thLevel.count*300)/2 + ((((($Temp5th4.count)))*300)/2)
                                                    $loops4++
                                                }
                                            elseif($XXXXLeft -eq 0 -and $loops4 -lt 0)
                                                {
                                                    $XXXXTemp = if(((((($Temp5th4.count)))*300)) -eq 0){300}else{((((($Temp5th4.count)))*300))}
                                                    $XXXXLeft = $XXXXLeft + -$XXXXTemp
                                                    $loops4++
                                                }
                                            elseif($XXXXLeft -lt 0 -and $loops4 -lt 0)
                                                {
                                                    $XXXXTemp = if(((((($Temp5th4.count)))*300)) -eq 0){300}else{((((($Temp5th4.count)))*300))}
                                                    $XXXXLeft = $XXXXLeft + -$XXXXTemp
                                                    $loops4++
                                                }
                                            elseif($XXXXLeft -eq 1 -and $loops4 -gt 0)
                                                {
                                                    $XXXXLeft = 150 + ((((($Temp5th4.count)))*150))
                                                    $loops4++
                                                }
                                            else
                                                {
                                                    $XXXXTemp = if(((((($Temp5th4.count)))*300)) -eq 0){300}else{((((($Temp5th4.count)))*300))}
                                                    $XXXXLeft = $XXXXLeft + $XXXXTemp
                                                    $loops4++
                                                }
                
                                            
                                            $MgmtHeight3 = if((($RoundSubs4.id.count * 90) + 50) -eq 50){80}else{(($RoundSubs4.id.count * 90) + 50)}

                                            $XXXXTop = $MgmtHeight2 + 200

                                            Container4 $XXXXLeft $XXXXTop '200' $MgmtHeight3 $4th $Global:ContID3

                                            $Global:XmlWriter.WriteStartElement('object')            
                                            $Global:XmlWriter.WriteAttributeString('label', '')
                                            $Global:XmlWriter.WriteAttributeString('ManagementGroup', [string]$4th)
                                            $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))                        
                                
                                            if($RoundSubs4)
                                                {
                                                    icon $Global:IconMgmtGroup '-30' ($MgmtHeight3-15) '50' '50' $Global:ContID4
                                                }
                                            else
                                                {
                                                    icon $Global:IconMgmtGroup '75' '27' '50' '50' $Global:ContID4
                                                }
                                
                                            $Global:XmlWriter.WriteEndElement()

                                            Connect $Global:ContID3 $Global:ContID4

                                            if($XXXXLeft -eq 0 -and $loops4 -lt 0)
                                                {
                                                    $XXXXLeft = -1
                                                }
                                            elseif($XXXXLeft -lt 0 -and $loops4 -ge 0)
                                                {
                                                    $XXXXLeft = 1
                                                }

                                            $LocalTop = 50
                                            $LocalLeft = 25

                                            foreach($Sub in $RoundSubs4)
                                                {                                

                                                    $RGs = $Global:ResourceContainers | Where-Object {$_.Type -eq 'microsoft.resources/subscriptions/resourcegroups' -and $_.subscriptionid -eq $sub.subscriptionid}

                                                    $Global:XmlWriter.WriteStartElement('object')
                                                    $Global:XmlWriter.WriteAttributeString('label', $sub.name)
                                                    $Global:XmlWriter.WriteAttributeString('id', ($Global:CellIDRes+'-'+($Global:CelNum++)))
                            
                                                        Icon $Ret4 $LocalLeft $LocalTop '150' '70' $Global:ContID4
                                                    
                                                    $Global:XmlWriter.WriteEndElement()

                                                    $Global:XmlWriter.WriteStartElement('object')            
                                                    $Global:XmlWriter.WriteAttributeString('label', '')

                                                    $RGNum = 1
                                                    foreach($RG in $RGs)
                                                        {
                                                            $Attr = ('ResourceGroup_'+[string]$RGNum)
                                                            $Global:XmlWriter.WriteAttributeString($Attr, [string]$RG.Name)
                                                            $RGNum++
                                                        }
                                                    
                                                    $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))                        
                                        
                                                        icon $Global:IconSubscription ($LocalLeft+140) ($LocalTop+40) '31' '51' $Global:ContID4

                                                    $Global:XmlWriter.WriteEndElement()

                                                    $LocalTop = $LocalTop + 90
                                                }
                                    
                                        }

                            }

                    }

            }

    }

    Stencils

    $OrgFile = ($DiagramCache+'Organization.xml')

    $Global:etag = -join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})
    $Global:DiagID = -join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})
    $Global:CellID = -join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})

    $Global:IDNum = 0
    $Global:CelNum = 0

    $Global:XmlWriter = New-Object System.XMl.XmlTextWriter($OrgFile,$Null)

    $Global:XmlWriter.Formatting = 'Indented'
    $Global:XmlWriter.Indentation = 2

    $Global:XmlWriter.WriteStartDocument()

        $Global:XmlWriter.WriteStartElement('mxfile')
        $Global:XmlWriter.WriteAttributeString('host', 'Electron')
        $Global:XmlWriter.WriteAttributeString('modified', '2021-10-01T21:45:40.561Z')
        $Global:XmlWriter.WriteAttributeString('agent', '5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) draw.io/15.4.0 Chrome/91.0.4472.164 Electron/13.5.0 Safari/537.36')
        $Global:XmlWriter.WriteAttributeString('etag', $etag)
        $Global:XmlWriter.WriteAttributeString('version', '15.4.0')
        $Global:XmlWriter.WriteAttributeString('type', 'device')

            $Global:XmlWriter.WriteStartElement('diagram')
            $Global:XmlWriter.WriteAttributeString('id', $DiagID)
            $Global:XmlWriter.WriteAttributeString('name', 'Organization')

                $Global:XmlWriter.WriteStartElement('mxGraphModel')
                $Global:XmlWriter.WriteAttributeString('dx', "1326")
                $Global:XmlWriter.WriteAttributeString('dy', "798")
                $Global:XmlWriter.WriteAttributeString('grid', "1")
                $Global:XmlWriter.WriteAttributeString('gridSize', "10")
                $Global:XmlWriter.WriteAttributeString('guides', "1")
                $Global:XmlWriter.WriteAttributeString('tooltips', "1")
                $Global:XmlWriter.WriteAttributeString('connect', "1")
                $Global:XmlWriter.WriteAttributeString('arrows', "1")
                $Global:XmlWriter.WriteAttributeString('fold', "1")
                $Global:XmlWriter.WriteAttributeString('page', "1")
                $Global:XmlWriter.WriteAttributeString('pageScale', "1")
                $Global:XmlWriter.WriteAttributeString('pageWidth', "850")
                $Global:XmlWriter.WriteAttributeString('pageHeight', "1100")
                $Global:XmlWriter.WriteAttributeString('math', "0")
                $Global:XmlWriter.WriteAttributeString('shadow', "0")

                    $Global:XmlWriter.WriteStartElement('root')

                        $Global:XmlWriter.WriteStartElement('mxCell')
                        $Global:XmlWriter.WriteAttributeString('id', "0")
                        $Global:XmlWriter.WriteEndElement()

                        $Global:XmlWriter.WriteStartElement('mxCell')
                        $Global:XmlWriter.WriteAttributeString('id', "1")
                        $Global:XmlWriter.WriteAttributeString('parent', "0")
                        $Global:XmlWriter.WriteEndElement()


                            Org


                    $Global:XmlWriter.WriteEndElement()
                
                $Global:XmlWriter.WriteEndElement()

            $Global:XmlWriter.WriteEndElement()
        
        $Global:XmlWriter.WriteEndElement()

    $Global:XmlWriter.WriteEndDocument()
    $Global:XmlWriter.Flush()
    $Global:XmlWriter.Close()

    } -ArgumentList $ResourceContainers,$DiagramCache

}


$XMLFiles = @()

$XMLFiles += ($DiagramCache+'Organization.xml')
$XMLFiles += ($DiagramCache+'Subscriptions.xml')


foreach($File in $XMLFiles)
    {
        Remove-Item -Path $File -ErrorAction SilentlyContinue
    }


Organization $ResourceContainers $DiagramCache

Network $Subscriptions $Resources $Advisories $DiagramCache $FullEnvironment $DDFile $XMLFiles 

Subscription $Subscriptions $Resources $DiagramCache


(Get-Job | Where-Object {$_.name -like 'Diagram_*'}) | Wait-Job


foreach($File in $XMLFiles)
    {
        $oldxml = New-Object XML
        $oldxml.Load($File)
        
        $newxml = New-Object XML
        $newxml.Load($DDFile)
        
        $oldxml.DocumentElement.InsertAfter($oldxml.ImportNode($newxml.SelectSingleNode('mxfile'), $true), $afternode)
        
        $oldxml.Save($DDFile)

        Remove-Item -Path $File
    }


(Get-Job | Where-Object {$_.name -like 'Diagram_*'}) | Remove-Job
