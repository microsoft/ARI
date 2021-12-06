<#
.Synopsis
Diagram Module for Draw.io

.DESCRIPTION
This script process and creates a Draw.io Diagram based on resources present in the extraction variable $Resources. 

.Link
https://github.com/azureinventory/ARI/Extras/DrawIODiagram.ps1

.COMPONENT
   This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 2.1.9
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

#>
param($Subscriptions, $Resources, $Advisories, $DDFile)

<# Change this variable to $true to draw the full environment #>
#$Global:FullEnvironment = $true
$Global:FullEnvironment = $false

Function Icon {
Param($Style,$x,$y,$w,$h)

    $Global:XmlWriter.WriteStartElement('mxCell')
    $Global:XmlWriter.WriteAttributeString('style', $Style)
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
Param($Source,$Target)

    $Global:XmlWriter.WriteStartElement('mxCell')
    $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
    $Global:XmlWriter.WriteAttributeString('style', "edgeStyle=none;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;endArrow=none;endFill=0;")
    $Global:XmlWriter.WriteAttributeString('edge', "1")
    $Global:XmlWriter.WriteAttributeString('vertex', "1")
    $Global:XmlWriter.WriteAttributeString('parent', "1")
    $Global:XmlWriter.WriteAttributeString('source', $Source)
    $Global:XmlWriter.WriteAttributeString('target', $Target)

        $Global:XmlWriter.WriteStartElement('mxGeometry')
        $Global:XmlWriter.WriteAttributeString('relative', "1")
        $Global:XmlWriter.WriteAttributeString('as', "geometry")
        $Global:XmlWriter.WriteEndElement()
    
    $Global:XmlWriter.WriteEndElement()

}

Function Variables0 
{

    $Global:AZVGWs = $resources | Where-Object {$_.Type -eq 'microsoft.network/virtualnetworkgateways'} | Select-Object -Property * -Unique
    $Global:AZLGWs = $resources | Where-Object {$_.Type -eq 'microsoft.network/localnetworkgateways'} | Select-Object -Property * -Unique
    $Global:AZVNETs = $resources | Where-Object {$_.Type -eq 'microsoft.network/virtualnetworks'} | Select-Object -Property * -Unique
    $Global:AZCONs = $resources | Where-Object {$_.Type -eq 'microsoft.network/connections'} | Select-Object -Property * -Unique
    $Global:AZEXPROUTEs = $resources | Where-Object {$_.Type -eq 'microsoft.network/expressroutecircuits'} | Select-Object -Property * -Unique    
    $Global:PIPs = $resources | Where-Object {$_.Type -eq 'microsoft.network/publicipaddresses'} | Select-Object -Property * -Unique
    $Global:AZVWAN = $resources | Where-Object {$_.Type -eq 'microsoft.network/virtualwans'} | Select-Object -Property * -Unique     
    
    $Global:CleanPIPs = $Global:PIPs | Where-Object {$_.id -notin $Global:AZVGWs.properties.ipConfigurations.properties.publicIPAddress.id}

}

<# Function to create the Visio document and import each stencil #>
Function Stensils
{
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

            <########################## Azure Generic Stencils #############################>

            $Global:SymError = "sketch=0;aspect=fixed;pointerEvents=1;shadow=0;dashed=0;html=1;strokeColor=none;labelPosition=center;verticalLabelPosition=bottom;verticalAlign=top;align=center;shape=mxgraph.mscae.enterprise.not_allowed;fillColor=#EA1C24;" #width="50" height="50"
            $Global:SymInfo = "aspect=fixed;html=1;points=[];align=center;image;fontSize=12;image=img/lib/azure2/general/Information.svg;" #width="64" height="64"
            $Global:IconSubscription = "aspect=fixed;html=1;points=[];align=center;image;fontSize=20;image=img/lib/azure2/general/Subscriptions.svg;" #width="44" height="71"
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

    foreach($GTW in $AZLGWs)
        {
            if($GTW.properties.provisioningState -ne 'Succeeded')
            {
                $Global:XmlWriter.WriteStartElement('object')            
                $Global:XmlWriter.WriteAttributeString('label', '')
                $Global:XmlWriter.WriteAttributeString('Status', 'This Local Network Gateway has Errors')
                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
    
                    Icon $IconError 40 ($Global:Alt+25) "25" "25"
    
                $Global:XmlWriter.WriteEndElement()
            }
        
            $Con1 = $AZCONs | Where-Object {$_.properties.localNetworkGateway2.id -eq $GTW.id}
            
            if(!$Con1 -and $GTW.properties.provisioningState -eq 'Succeeded')
            {
                $Global:XmlWriter.WriteStartElement('object')            
                $Global:XmlWriter.WriteAttributeString('label', '')
                $Global:XmlWriter.WriteAttributeString('Status', 'No Connections were found in this Local Network Gateway')
                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
    
                    Icon $SymInfo 40 ($Global:Alt+30) "20" "20"
    
                $Global:XmlWriter.WriteEndElement()
            }
            
            $Name = $GTW.name
            $IP = $GTW.properties.gatewayIpAddress

            $Global:XmlWriter.WriteStartElement('object')            
            $Global:XmlWriter.WriteAttributeString('label', ("`n" + [string]$Name + "`n" + [string]$IP))
            $Global:XmlWriter.WriteAttributeString('Local_Address_Space', [string]$GTW.properties.localNetworkAddressSpace.addressPrefixes)
            $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))

                Icon $IconTraffic 50 $Global:Alt "67" "40"

            $Global:XmlWriter.WriteEndElement()            
            #$tt = $tt + 200        

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
    
                    Icon $IconError 51 ($Global:Alt+25) "25" "25"
    
                $Global:XmlWriter.WriteEndElement()
            }       

            $Con1 = $AZCONs | Where-Object {$_.properties.peer.id -eq $ERs.id}
            
            if(!$Con1 -and $ERs.properties.circuitProvisioningState -eq 'Enabled')
            {
                $Global:XmlWriter.WriteStartElement('object')            
                $Global:XmlWriter.WriteAttributeString('label', '')
                $Global:XmlWriter.WriteAttributeString('Status', 'No Connections were found in this Express Route')
                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
    
                    Icon $SymInfo 51 ($Global:Alt+30) "20" "20"
    
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

                Icon $IconExpressRoute "61.5" $Global:Alt "44" "40"

            $Global:XmlWriter.WriteEndElement()    

            OnPrem $Con1

            $Global:Alt = $Global:Alt + 150
               
        }


        Foreach($VWANS in $AZVWAN)
        {
            if($VWANS.properties.provisioningState -ne 'Succeeded')
            {
                $Global:XmlWriter.WriteStartElement('object')            
                $Global:XmlWriter.WriteAttributeString('label', '')
                $Global:XmlWriter.WriteAttributeString('Status', 'This Virtual WAN has Errors')
                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
    
                    Icon $IconError 40 ($Global:Alt+25) "25" "25"
    
                $Global:XmlWriter.WriteEndElement()
            }       

            $Name = $VWANS.name
            $Global:XmlWriter.WriteStartElement('object')            
            $Global:XmlWriter.WriteAttributeString('label', ("`n" +[string]$Name))
            $Global:XmlWriter.WriteAttributeString('Allow_BranchToBranch_Traffic', [string]$VWANS.properties.allowBranchToBranchTraffic)
            $Global:XmlWriter.WriteAttributeString('Allow_VnetToVnet_Traffic', [string]$VWANS.properties.allowVnetToVnetTraffic)
            $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))

                Icon $IconVWAN 50 $Global:Alt "65" "64"

            $Global:XmlWriter.WriteEndElement()  

            $Global:Alt = $Global:Alt + 150
                
        }

        if(!$Global:FullEnvironment)
            {

                $Global:XmlWriter.WriteStartElement('object')            
                $Global:XmlWriter.WriteAttributeString('label', '')
                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
    
                    Icon $Ret -520 -100 "500" ($Global:Alt + 100)
    
                $Global:XmlWriter.WriteEndElement()

                $Global:XmlWriter.WriteStartElement('object')            
                $Global:XmlWriter.WriteAttributeString('label', ('On Premises'+ "`n" +'Environment'))
                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))

                    Icon $OnPrem -351 (($Global:Alt + 100)/2) "168.2" "290"

                $Global:XmlWriter.WriteEndElement()  

                $Global:XmlWriter.WriteStartElement('object')            
                $Global:XmlWriter.WriteAttributeString('label', ('Powered by:'+ "`n" +'Azure Resource Inventory v2.1'+ "`n" +'https://github.com/azureinventory/ARI'))
                $Global:XmlWriter.WriteAttributeString('author1', 'Claudio Merola')
                $Global:XmlWriter.WriteAttributeString('author2', 'Renato Gregio')
                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))

                    Icon $Signature -520 ($Global:Alt + 100) "27.5" "22"

                $Global:XmlWriter.WriteEndElement()  
            }

}


Function OnPrem 
{
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

                Icon $IconConnections 250 $Global:Alt "40" "40"

            $Global:XmlWriter.WriteEndElement()

            $Global:Target = ($Global:CellID+'-'+($Global:IDNum-1))

                Connect $Global:Source $Global:Target

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

                Icon $IconVGW2 425 ($Global:Alt-4) "31.34" "48"

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

                                    Icon $IconVNET 600 $Global:Alt "65" "39"

                                $Global:XmlWriter.WriteEndElement()      
                                
                                $Global:VNETDrawID = ($Global:CellID+'-'+($Global:IDNum-1))
                                                    
                                $Global:Target = ($Global:CellID+'-'+($Global:IDNum-1))

                                    Connect $Global:Source $Global:Target
                    
                                if($VNET2.properties.enableDdosProtection -eq $true)
                                {
                                    $Global:XmlWriter.WriteStartElement('object')            
                                    $Global:XmlWriter.WriteAttributeString('label', '')
                                    $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
                        
                                        Icon $IconDDOS 580 ($Global:Alt + 15) "23" "28"
                        
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


<# Function for Cloud Only Environments #>
Function CloudOnly 
{
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

                        Icon $IconVNET 600 $Global:Alt "65" "39"

                    $Global:XmlWriter.WriteEndElement()      
                    
                    $Global:VNETDrawID = ($Global:CellID+'-'+($Global:IDNum-1))
                                        
                    $Global:Target = ($Global:CellID+'-'+($Global:IDNum-1))
        
                    if($VNET2.properties.enableDdosProtection -eq $true)
                    {
                        $Global:XmlWriter.WriteStartElement('object')            
                        $Global:XmlWriter.WriteAttributeString('label', '')
                        $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
            
                            Icon $IconDDOS 580 ($Global:Alt + 15) "23" "28"
            
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

                Icon $Ret -520 -100 "500" ($Global:Alt + 100)

            $Global:XmlWriter.WriteEndElement()

            $Global:XmlWriter.WriteStartElement('object')            
            $Global:XmlWriter.WriteAttributeString('label', ('Cloud Only'+ "`n" +'Environment'))
            $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))

                Icon $Global:CloudOnly -460 (($Global:Alt + 100)/2) "380" "275"

            $Global:XmlWriter.WriteEndElement()  

            $Global:XmlWriter.WriteStartElement('object')            
            $Global:XmlWriter.WriteAttributeString('label', ('Powered by:'+ "`n" +'Azure Resource Inventory v2.1'+ "`n" +'https://github.com/azureinventory/ARI'))
            $Global:XmlWriter.WriteAttributeString('author1', 'Claudio Merola')
            $Global:XmlWriter.WriteAttributeString('author2', 'Renato Gregio')
            $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))

                Icon $Signature -520 ($Global:Alt + 100) "27.5" "22"

            $Global:XmlWriter.WriteEndElement()  

}


Function FullEnvironment 
{

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

                        Icon $IconVNET 600 $Global:Alt "65" "39"

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

                Icon $Ret -520 -100 "500" ($Global:Alt + 100)

            $Global:XmlWriter.WriteEndElement()

            $Global:XmlWriter.WriteStartElement('object')            
            $Global:XmlWriter.WriteAttributeString('label', ('On Premises'+ "`n" +'Environment'))
            $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))

                Icon $OnPrem -351 (($Global:Alt + 100)/2) "168.2" "290"

            $Global:XmlWriter.WriteEndElement()  

            $Global:XmlWriter.WriteStartElement('object')            
            $Global:XmlWriter.WriteAttributeString('label', ('Powered by:'+ "`n" +'Azure Resource Inventory v2'+ "`n" +'https://github.com/azureinventory/ARI'))
            $Global:XmlWriter.WriteAttributeString('author1', 'Claudio Merola')
            $Global:XmlWriter.WriteAttributeString('author2', 'Renato Gregio')
            $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))

                Icon $Signature -520 ($Global:Alt + 100) "27.5" "22"

            $Global:XmlWriter.WriteEndElement()  

}


<# Function for create peered VNETs #>
Function PeerCreator
{
Param($VNET2)
    $PeerCount = ($VNET2.properties.virtualNetworkPeerings.properties.remoteVirtualNetwork.id.count + 10.3)
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

                    Icon $IconVNET $Global:vnetLoc $Global:vnetLoc1 "67" "40"

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
            
                            Icon $IconDDOS ($Global:vnetLoc - 20) ($Global:vnetLoc1 + 15) "23" "28"
            
                        $Global:XmlWriter.WriteEndElement()
                    }


                if ($Global:sizeL -gt 5)
                    {
                        $Global:sizeL = $Global:sizeL / 2
                        $Global:sizeL = [math]::ceiling($Global:sizeL)
                        $Global:sizeC = $Global:sizeL
                        $Global:sizeL = (($Global:sizeL * 210) + 30)


                        $Global:XmlWriter.WriteStartElement('object')            
                        $Global:XmlWriter.WriteAttributeString('label', '')
                        $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))

                            Icon $Global:Ret ($Global:vnetLoc + 100) ($Global:vnetLoc1 - 20) $Global:sizeL "470"

                        $Global:XmlWriter.WriteEndElement()  

                        $Global:VNETSquare = ($Global:CellID+'-'+($Global:IDNum-1))

                        $SubName = $Subscriptions | Where-Object {$_.id -eq $VNETSUB.subscriptionId}
                        $Global:XmlWriter.WriteStartElement('object')            
                        $Global:XmlWriter.WriteAttributeString('label', $SubName.name)
                        $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))

                            Icon $IconSubscription ($Global:sizeL + $Global:vnetLoc + 100) ($Global:vnetLoc1 + 420) "67" "40"

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

                                    Icon $IconCostMGMT ($Global:sizeL + $Global:vnetLoc + 170) ($Global:vnetLoc1 + 420) "30" "35"

                                $Global:XmlWriter.WriteEndElement()
                                
                            }


                        $Global:subloc0 = ($Global:vnetLoc + 120)
                        $Global:SubC = 0
                        $Global:VNETPIP = @()
                        
                        foreach($Sub in $VNETSUB.properties.subnets)
                            {
                                if ($Global:SubC -eq $Global:sizeC) 
                                    {
                                        $Global:vnetLoc1 = $Global:vnetLoc1 + 230                                        
                                        $Global:subloc0 = ($Global:vnetLoc + 120)
                                        $Global:SubC = 0
                                    }

                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ("`n" + "`n" + "`n" + "`n" + "`n" + "`n" + "`n" +[string]$sub.Name + "`n" + [string]$sub.properties.addressPrefix))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))

                                    Icon $Global:Ret $Global:subloc0 $Global:vnetLoc1 "200" "200"

                                $Global:XmlWriter.WriteEndElement()     
                       
                                ProcType $sub $Global:subloc0 $Global:vnetLoc1
                                                                    
                                $Global:subloc0 = $Global:subloc0 + 210
                                $Global:SubC ++

                            }
                        
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
            
                                    Icon $IconDet ($Global:subloc0 + 500) ($vnetLoc1 - 40) "42.63" "44"
            
                                $Global:XmlWriter.WriteEndElement()
                                
                                Connect ($Global:CellID+'-'+($Global:IDNum-1)) $Global:VNETSquare 
                            }  
                                                      
                        $Global:Alt = $Global:Alt + 600                                                                         
                    }
                else
                    {
                        $Global:sizeL = (($Global:sizeL * 210) + 30)

                        $Global:XmlWriter.WriteStartElement('object')            
                        $Global:XmlWriter.WriteAttributeString('label', '')
                        $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
            
                            Icon $Global:Ret ($Global:vnetLoc + 100) ($Global:vnetLoc1 - 20) $Global:sizeL "230"
            
                        $Global:XmlWriter.WriteEndElement()  

                        $Global:VNETSquare = ($Global:CellID+'-'+($Global:IDNum-1))

                        $SubName = $Subscriptions | Where-Object {$_.id -eq $VNETSUB.subscriptionId}

                        $Global:XmlWriter.WriteStartElement('object')            
                        $Global:XmlWriter.WriteAttributeString('label', $SubName.name)
                        $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
            
                            Icon $IconSubscription ($Global:sizeL + $Global:vnetLoc + 100) ($Global:vnetLoc1 + 180) "67" "40"
            
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

                                    Icon $IconCostMGMT ($Global:sizeL + $Global:vnetLoc + 170) ($Global:vnetLoc1 + 180) "30" "35"

                                $Global:XmlWriter.WriteEndElement()
                                
                            }

                        $Global:subloc0 = ($Global:vnetLoc + 120)
                        $Global:VNETPIP = @()
                        
                        foreach($sub in $VNETSUB.properties.subnets)
                            {

                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', ("`n" + "`n" + "`n" + "`n" + "`n" + "`n" + "`n" +[string]$sub.Name + "`n" + [string]$sub.properties.addressPrefix))
                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
                
                                    Icon $Global:Ret $Global:subloc0 $Global:vnetLoc1 "200" "200"
                
                                $Global:XmlWriter.WriteEndElement()  

                                ProcType $sub $Global:subloc0 $Global:vnetLoc1

                                $Global:subloc0 = $Global:subloc0 + 210
                            }

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
            
                                    Icon $IconDet ($Global:subloc0 + 500) ($vnetLoc1 + 75) "42.63" "44"
            
                                $Global:XmlWriter.WriteEndElement()
                                
                                Connect ($Global:CellID+'-'+($Global:IDNum-1)) $Global:VNETSquare 

                            }

                    }
                    
                $tmp =@{
                    'VNETid' = $TwoTarget;
                    'VNET' = $VNETSUB.id
                }    
                $Global:VNETHistory += $tmp 

                $Global:vnetLoc1 = $Global:vnetLoc1 + 300                                         
            }
        }
    $Global:Alt = $Global:vnetLoc1
}


<# Function for VNET creation #>
Function VNETCreator
{
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

                $Global:XmlWriter.WriteStartElement('object')            
                $Global:XmlWriter.WriteAttributeString('label', '')
                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))

                    Icon $Global:Ret ($Global:vnetLoc) ($Global:Alt0 - 20) $Global:sizeL "470"

                $Global:XmlWriter.WriteEndElement()  
                
                $Global:VNETSquare = ($Global:CellID+'-'+($Global:IDNum-1))

                $SubName = $Subscriptions | Where-Object {$_.id -eq $VNET2.subscriptionId}

                $Global:XmlWriter.WriteStartElement('object')            
                $Global:XmlWriter.WriteAttributeString('label', $SubName.name)
                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))

                    Icon $IconSubscription ($Global:sizeL + 710) ($Global:Alt + 420) "67" "40"

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

                        Icon $IconCostMGMT ($Global:sizeL + 780) ($Global:Alt + 420) "30" "35"

                    $Global:XmlWriter.WriteEndElement()
                    
                }

                $Global:subloc = ($Global:vnetLoc + 15)
                $Global:SubC = 0
                $Global:VNETPIP = @()
                foreach($Sub in $VNET2.properties.subnets)
                {
                    if ($Global:SubC -eq $Global:sizeC) 
                    {
                        $Global:Alt0 = $Global:Alt0 + 230
                        $Global:subloc = ($Global:vnetLoc + 15)
                        $Global:SubC = 0
                    }

                    $Global:XmlWriter.WriteStartElement('object')            
                    $Global:XmlWriter.WriteAttributeString('label', ("`n" + "`n" + "`n" + "`n" + "`n" + "`n" +[string]$sub.Name + "`n" + [string]$sub.properties.addressPrefix))
                    $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))

                        Icon $Global:Ret $Global:subloc ($Global:Alt0) "200" "200"

                    $Global:XmlWriter.WriteEndElement()      
                    
                    ProcType $sub $Global:subloc $Global:Alt0                

                    $Global:subloc = $Global:subloc + 210
                    $Global:SubC ++
                }

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

                            Icon $IconDet ($Global:subloc + 500) ($Global:Alt0 - 40) "42.63" "44"

                        $Global:XmlWriter.WriteEndElement()
                        
                        Connect ($Global:CellID+'-'+($Global:IDNum-1)) $Global:VNETSquare   
                    }

                    $Global:Alt = $Global:Alt + 600
            }
        else
            {
                $Global:sizeL = (($Global:sizeL * 210) + 30)

                $Global:XmlWriter.WriteStartElement('object')            
                $Global:XmlWriter.WriteAttributeString('label', '')
                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))

                    Icon $Global:Ret ($Global:vnetLoc) ($Global:Alt0 - 15) $Global:sizeL "230"

                $Global:XmlWriter.WriteEndElement()

                $Global:VNETSquare = ($Global:CellID+'-'+($Global:IDNum-1))

                $SubName = $Subscriptions | Where-Object {$_.id -eq $VNET2.subscriptionId}

                $Global:XmlWriter.WriteStartElement('object')            
                $Global:XmlWriter.WriteAttributeString('label', $SubName.name)
                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))

                    Icon $IconSubscription ($Global:sizeL + 710) ($Global:Alt + 180) "67" "40"

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

                        Icon $IconCostMGMT ($Global:sizeL + 780) ($Global:Alt + 180) "30" "35"

                    $Global:XmlWriter.WriteEndElement()
                    
                }

                $Global:subloc = ($Global:vnetLoc + 15)
                $Global:VNETPIP = @()
                foreach($Sub in $VNET2.properties.subnets)
                {
                    $Global:XmlWriter.WriteStartElement('object')            
                    $Global:XmlWriter.WriteAttributeString('label', ("`n" + "`n" + "`n" + "`n" + "`n" + "`n" +[string]$sub.Name + "`n" + [string]$sub.properties.addressPrefix))
                    $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))

                        Icon $Global:Ret ($Global:subloc + 5) ($Global:Alt0) "200" "200"

                    $Global:XmlWriter.WriteEndElement()  
                    
                    ProcType $sub $Global:subloc $Global:Alt0                

                    $Global:subloc = $Global:subloc + 210
                }

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

                            Icon $IconDet ($Global:subloc + 500) ($Global:Alt0 + 75) "42.63" "44"

                        $Global:XmlWriter.WriteEndElement()
                        
                        Connect ($Global:CellID+'-'+($Global:IDNum-1)) $Global:VNETSquare                    
                    }
                $Global:Alt = $Global:Alt + 300 
            }
        }
}


Function ProcType 
{
Param($sub,$subloc,$Alt0)  
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
                                        $Global:XmlWriter.WriteStartElement('object')            
                                        $Global:XmlWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' VMs'))                                        
                        
                                        $Count = 1
                                        foreach ($VMName in $RESNames.Name)
                                        {
                                            $Attr1 = ('VirtualMachine-'+[string]("{0:d3}" -f $Count))
                                            $Global:XmlWriter.WriteAttributeString($Attr1, [string]$VMName)

                                            $Count ++
                                        }
                                        $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))

                                            Icon $IconVMs ($subloc+64) ($Alt0+40) "69" "64"
                        
                                        $Global:XmlWriter.WriteEndElement()  
                                    }
                                else
                                    {

                                        $Global:XmlWriter.WriteStartElement('object')            
                                        $Global:XmlWriter.WriteAttributeString('label', [string]$RESNames.Name)
                                        $Global:XmlWriter.WriteAttributeString('VM_Size', [string]$RESNames.properties.hardwareProfile.vmSize)
                                        $Global:XmlWriter.WriteAttributeString('OS', [string]$RESNames.properties.storageProfile.osDisk.osType)
                                        $Global:XmlWriter.WriteAttributeString('OS_Disk_Size_GB', [string]$RESNames.properties.storageProfile.osDisk.diskSizeGB)
                                        $Global:XmlWriter.WriteAttributeString('Image_Publisher', [string]$RESNames.properties.storageProfile.imageReference.publisher)
                                        $Global:XmlWriter.WriteAttributeString('Image_SKU', [string]$RESNames.properties.storageProfile.imageReference.sku)
                                        $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))                        

                                            Icon $IconVMs ($subloc+64) ($Alt0+40) "69" "64"
                        
                                        $Global:XmlWriter.WriteEndElement() 

                                    }                                                                                                                                    
                                }
            'AKS' {                                                
                                if($RESNames.count -gt 1)
                                    {
                                        $Global:XmlWriter.WriteStartElement('object')            
                                        $Global:XmlWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' AKS Clusters'))                                        
                        
                                        $Count = 1
                                        foreach ($AKSName in $RESNames.Name)
                                        {
                                            $Attr1 = ('Kubernetes_Cluster-'+[string]("{0:d3}" -f $Count))
                                            $Global:XmlWriter.WriteAttributeString($Attr1, [string]$AKSName)

                                            $Count ++
                                        }
                                        $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))

                                            Icon $IconAKS ($subloc+65) ($Alt0+40) "68" "64"
                        
                                        $Global:XmlWriter.WriteEndElement()

                                    }
                                else 
                                    {
                                        $Global:XmlWriter.WriteStartElement('object')            
                                        $Global:XmlWriter.WriteAttributeString('label', [string]$RESNames.name)                                        
                        
                                        $Count = 1
                                        foreach($Pool in $RESNames.properties.agentPoolProfiles)
                                        {
                                            $Attr1 = ('Node_Pool-'+[string]("{0:d3}" -f $Count)+'-Name')
                                            $Attr2 = ('Node_Pool-'+[string]("{0:d3}" -f $Count)+'-Count')
                                            $Attr3 = ('Node_Pool-'+[string]("{0:d3}" -f $Count)+'-Size')
                                            $Attr4 = ('Node_Pool-'+[string]("{0:d3}" -f $Count)+'-Version')
                                            $Attr5 = ('Node_Pool-'+[string]("{0:d3}" -f $Count)+'-Mode')
                                            $Attr6 = ('Node_Pool-'+[string]("{0:d3}" -f $Count)+'-Max_Pods')

                                            $Global:XmlWriter.WriteAttributeString($Attr1, [string]$Pool.name)
                                            $Global:XmlWriter.WriteAttributeString($Attr2, [string]($Pool | Select-Object -Property 'count').count)
                                            $Global:XmlWriter.WriteAttributeString($Attr3, [string]$Pool.vmSize)
                                            $Global:XmlWriter.WriteAttributeString($Attr4, [string]$Pool.orchestratorVersion)
                                            $Global:XmlWriter.WriteAttributeString($Attr5, [string]$Pool.mode)
                                            $Global:XmlWriter.WriteAttributeString($Attr6, [string]$Pool.maxPods)

                                            $Count ++
                                        }
                                        $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))

                                            Icon $IconAKS ($subloc+65) ($Alt0+40) "68" "64"
                        
                                        $Global:XmlWriter.WriteEndElement()

                                        }
                                }
            'virtualMachineScaleSets' {                                                                                  
                                if($RESNames.count -gt 1)
                                    {
                                        $Global:XmlWriter.WriteStartElement('object')            
                                        $Global:XmlWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' Virtual Machine Scale Sets'))                                        
                        
                                        $Count = 1
                                        foreach ($ResName in $RESNames.Name)
                                        {
                                            $Attr1 = ('VMSS-'+[string]("{0:d3}" -f $Count))
                                            $Global:XmlWriter.WriteAttributeString($Attr1, [string]$ResName)

                                            $Count ++
                                        }
                                        $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))

                                            Icon $IconVMSS ($subloc+65) ($Alt0+40) "68" "68"
                        
                                        $Global:XmlWriter.WriteEndElement()

                                    }
                                else
                                    {
                                        $Global:XmlWriter.WriteStartElement('object')            
                                        $Global:XmlWriter.WriteAttributeString('label', [string]$RESNames.name)                                        
                        
                                        $Global:XmlWriter.WriteAttributeString('VMSS_Name', [string]$RESNames.name)
                                        $Global:XmlWriter.WriteAttributeString('Instances', [string]$temp[0].Count)
                                        $Global:XmlWriter.WriteAttributeString('VMSS_SKU_Tier', [string]$RESNames.sku.tier)
                                        $Global:XmlWriter.WriteAttributeString('VMSS_Upgrade_Policy', [string]$RESNames.Properties.upgradePolicy.mode)

                                        $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))

                                            Icon $IconVMSS ($subloc+65) ($Alt0+40) "68" "68"
                        
                                        $Global:XmlWriter.WriteEndElement()
                                    }                                                                        
                                } 
            'loadBalancers' {                                                    
                                if($RESNames.count -gt 1)
                                    {
                                        $Global:XmlWriter.WriteStartElement('object')            
                                        $Global:XmlWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' Load Balancers'))                                        
                        
                                        $Count = 1
                                        foreach ($ResName in $RESNames)
                                        {
                                            $Attr1 = ('LB-'+[string]("{0:d3}" -f $Count)+'-Name')
                                            $Attr2 = ('LB-'+[string]("{0:d3}" -f $Count)+'-SKU')
                                            $Attr3 = ('LB-'+[string]("{0:d3}" -f $Count)+'-Backends')
                                            $Attr4 = ('LB-'+[string]("{0:d3}" -f $Count)+'-Frontends')
                                            $Attr5 = ('LB-'+[string]("{0:d3}" -f $Count)+'-LB_Rules')
                                            $Attr6 = ('LB-'+[string]("{0:d3}" -f $Count)+'-Probes')

                                            $Global:XmlWriter.WriteAttributeString($Attr1, [string]$ResName.name)
                                            $Global:XmlWriter.WriteAttributeString($Attr2, [string]$ResName.sku.name)
                                            $Global:XmlWriter.WriteAttributeString($Attr3, [string]$ResName.properties.backendAddressPools.properties.backendIPConfigurations.id.count)
                                            $Global:XmlWriter.WriteAttributeString($Attr4, [string]$ResName.properties.frontendIPConfigurations.properties.count)
                                            $Global:XmlWriter.WriteAttributeString($Attr5, [string]$ResName.properties.loadBalancingRules.count)
                                            $Global:XmlWriter.WriteAttributeString($Attr6, [string]$ResName.properties.probes.count)

                                            $Count ++
                                        }
                                        $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))

                                            Icon $IconLBs ($subloc+65) ($Alt0+40) "72" "72"
                        
                                        $Global:XmlWriter.WriteEndElement()

                                    }
                                else 
                                    {            
                                        $Global:XmlWriter.WriteStartElement('object')            
                                        $Global:XmlWriter.WriteAttributeString('label', [string]$RESNames.Name)                                        

                                        $Global:XmlWriter.WriteAttributeString('Load_Balancer_Name', [string]$ResNames.name)
                                        $Global:XmlWriter.WriteAttributeString('Load_Balancer_SKU', [string]$ResNames.sku.name)
                                        $Global:XmlWriter.WriteAttributeString('Backends', [string]$ResNames.properties.backendAddressPools.properties.backendIPConfigurations.id.count)
                                        $Global:XmlWriter.WriteAttributeString('Frontends', [string]$ResNames.properties.frontendIPConfigurations.properties.count)
                                        $Global:XmlWriter.WriteAttributeString('LB_Rules', [string]$ResNames.properties.loadBalancingRules.count)
                                        $Global:XmlWriter.WriteAttributeString('Probes', [string]$ResNames.properties.probes.count)

                                        $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))

                                            Icon $IconLBs ($subloc+65) ($Alt0+40) "72" "72"
                        
                                        $Global:XmlWriter.WriteEndElement()
                                        
                                    }
                                } 
            'virtualNetworkGateways' {                                                    
                                if($RESNames.count -gt 1)
                                    {
                                        $Global:XmlWriter.WriteStartElement('object')            
                                        $Global:XmlWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' Virtual Network Gateways'))                                        
                        
                                        $Count = 1
                                        foreach ($ResName in $RESNames)
                                        {
                                            $Attr1 = ('Network_Gateway-'+[string]("{0:d3}" -f $Count)+'-Name')

                                            $Global:XmlWriter.WriteAttributeString($Attr1, [string]$ResName.name)

                                            $Count ++
                                        }
                                        $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))

                                            Icon $IconVGW ($subloc+80) ($Alt0+40) "52" "69"
                        
                                        $Global:XmlWriter.WriteEndElement()

                                    }
                                else
                                    {
                                        $Global:XmlWriter.WriteStartElement('object')            
                                        $Global:XmlWriter.WriteAttributeString('label', [string]$RESNames.Name)                                        
                        
                                        $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))

                                            Icon $IconVGW ($subloc+80) ($Alt0+40) "52" "69"
                        
                                        $Global:XmlWriter.WriteEndElement()
                                    }                                                                                                         
                                } 
            'azureFirewalls' {                                                    
                                if($RESNames.count -gt 1)
                                    {
                                        $Global:XmlWriter.WriteStartElement('object')            
                                        $Global:XmlWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' Firewalls'))                                        
                        
                                        $Count = 1
                                        foreach ($ResName in $RESNames)
                                        {
                                            $Attr1 = ('Firewall-'+[string]("{0:d3}" -f $Count)+'-Name')
                                            $Attr2 = ('Firewall-'+[string]("{0:d3}" -f $Count)+'-SKU')
                                            $Attr3 = ('Firewall-'+[string]("{0:d3}" -f $Count)+'-Threat_Intel_Mode')

                                            $Global:XmlWriter.WriteAttributeString($Attr1, [string]$ResName.name)
                                            $Global:XmlWriter.WriteAttributeString($Attr2, [string]$ResName.properties.sku.tier)
                                            $Global:XmlWriter.WriteAttributeString($Attr3, [string]$ResName.properties.threatIntelMode)

                                            $Count ++
                                        }
                                        $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))

                                            Icon $IconFWs ($subloc+65) ($Alt0+40) "71" "60"
                        
                                        $Global:XmlWriter.WriteEndElement()
                                    }
                                else 
                                    {
                                        $Global:XmlWriter.WriteStartElement('object')            
                                        $Global:XmlWriter.WriteAttributeString('label', [string]$RESNames.name)      
                                        

                                        $Global:XmlWriter.WriteAttributeString('Firewall_Name', [string]$ResNames.name)
                                        $Global:XmlWriter.WriteAttributeString('SKU_Tier', [string]$ResNames.properties.sku.tier)
                                        $Global:XmlWriter.WriteAttributeString('Threat_Intel_Mode', [string]$ResNames.properties.threatIntelMode)

                                        $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))

                                            Icon $IconFWs ($subloc+65) ($Alt0+40) "71" "60"
                        
                                        $Global:XmlWriter.WriteEndElement()
                                    }                                                                
                                } 
            'privateLinkServices' {                                                    
                                if($RESNames.count -gt 1)
                                    {
                                        $Global:XmlWriter.WriteStartElement('object')            
                                        $Global:XmlWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' Private Endpoints'))                                        
                        
                                        $Count = 1
                                        foreach ($ResName in $RESNames)
                                        {
                                            $Attr1 = ('PVE-'+[string]("{0:d3}" -f $Count)+'-Name')

                                            $Global:XmlWriter.WriteAttributeString($Attr1, [string]$ResName.name)

                                            $Count ++
                                        }
                                        $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))

                                            Icon $IconPVTs ($subloc+65) ($Alt0+40) "72" "66"
                        
                                        $Global:XmlWriter.WriteEndElement()

                                    }
                                else
                                    {
                                        $Global:XmlWriter.WriteStartElement('object')            
                                        $Global:XmlWriter.WriteAttributeString('label', [string]$RESNames.Name)                                        
                                        $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))

                                            Icon $IconPVTs ($subloc+65) ($Alt0+40) "72" "66"
                        
                                        $Global:XmlWriter.WriteEndElement()
                                    }                                                                       
                                } 
            'applicationGateways' {                                                    
                                if($RESNames.count -gt 1)
                                    {
                                        $Global:XmlWriter.WriteStartElement('object')            
                                        $Global:XmlWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' Application Gateways'))                                        
                        
                                        $Count = 1
                                        foreach ($ResName in $RESNames)
                                        {
                                            $Attr1 = ('App_Gateway-'+[string]("{0:d3}" -f $Count)+'-Name')
                                            $Attr2 = ('App_Gateway-'+[string]("{0:d3}" -f $Count)+'-SKU')
                                            $Attr3 = ('App_Gateway-'+[string]("{0:d3}" -f $Count)+'-Min_Capacity')
                                            $Attr4 = ('App_Gateway-'+[string]("{0:d3}" -f $Count)+'-Max_Capacity')

                                            $Global:XmlWriter.WriteAttributeString($Attr1, [string]$ResName.name)
                                            $Global:XmlWriter.WriteAttributeString($Attr2, [string]$RESName.Properties.sku.tier)
                                            $Global:XmlWriter.WriteAttributeString($Attr3, [string]$RESName.Properties.autoscaleConfiguration.minCapacity)
                                            $Global:XmlWriter.WriteAttributeString($Attr4, [string]$RESName.Properties.autoscaleConfiguration.maxCapacity)

                                            $Count ++
                                        }
                                        $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))

                                            Icon $IconAppGWs ($subloc+65) ($Alt0+40) "64" "64"
                        
                                        $Global:XmlWriter.WriteEndElement()

                                    }
                                else
                                    {
                                        $Global:XmlWriter.WriteStartElement('object')            
                                        $Global:XmlWriter.WriteAttributeString('label', [string]$RESNames.Name)                                                            

                                        $Global:XmlWriter.WriteAttributeString('App_Gateway_Name', [string]$ResNames.name)
                                        $Global:XmlWriter.WriteAttributeString('App_Gateway_SKU', [string]$RESNames.Properties.sku.tier)
                                        $Global:XmlWriter.WriteAttributeString('Autoscale_Min_Capacity', [string]$RESNames.Properties.autoscaleConfiguration.minCapacity)
                                        $Global:XmlWriter.WriteAttributeString('Autoscale_Max_Capacity', [string]$RESNames.Properties.autoscaleConfiguration.maxCapacity)

                                        $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))

                                            Icon $IconAppGWs ($subloc+65) ($Alt0+40) "64" "64"
                        
                                        $Global:XmlWriter.WriteEndElement()
                                    }                                                                                                                                                                             
                                }
            'bastionHosts' {                                                    
                                if($RESNames.count -gt 1)
                                    {
                                        $Global:XmlWriter.WriteStartElement('object')            
                                        $Global:XmlWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' Bastion Hosts'))                                        
                        
                                        $Count = 1
                                        foreach ($ResName in $RESNames)
                                        {
                                            $Attr1 = ('Bastion-'+[string]("{0:d3}" -f $Count)+'-Name')

                                            $Global:XmlWriter.WriteAttributeString($Attr1, [string]$ResName.name)

                                            $Count ++
                                        }
                                        $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))

                                            Icon $IconBastions ($subloc+65) ($Alt0+40) "68" "67"
                        
                                        $Global:XmlWriter.WriteEndElement()
                                    }
                                else 
                                    {
                                        $Global:XmlWriter.WriteStartElement('object')            
                                        $Global:XmlWriter.WriteAttributeString('label', [string]$RESNames.name)                                                            
                                        $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))

                                            Icon $IconBastions ($subloc+65) ($Alt0+40) "68" "67"
                        
                                        $Global:XmlWriter.WriteEndElement()

                                    }                                                                        
                                } 
            'APIM' {                                
                                $Global:XmlWriter.WriteStartElement('object')            
                                $Global:XmlWriter.WriteAttributeString('label', [string]$RESNames.Name)                                                            

                                $APIMHost = [string]($RESNames.properties.hostnameConfigurations | Where-Object {$_.defaultSslBinding -eq $true}).hostname

                                $Global:XmlWriter.WriteAttributeString('APIM_Name', [string]$ResNames.name)
                                $Global:XmlWriter.WriteAttributeString('SKU', [string]$RESNames.sku.name)
                                $Global:XmlWriter.WriteAttributeString('VNET_Type', [string]$RESNames.properties.virtualNetworkType)
                                $Global:XmlWriter.WriteAttributeString('Default_Hostname', $APIMHost)

                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))

                                    Icon $IconAPIMs ($subloc+65) ($Alt0+40) "65" "60"
                
                                $Global:XmlWriter.WriteEndElement()
                            
                                }
            'App Service' {
                                if($ServiceAppNames)
                                    {
                                        if($RESNames.count -gt 1)
                                            {
                                                $Global:XmlWriter.WriteStartElement('object')            
                                                $Global:XmlWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' App Services'))                                        
                                
                                                $Count = 1
                                                foreach ($ResName in $RESNames)
                                                {
                                                    $Attr1 = ('AppService-'+[string]("{0:d3}" -f $Count)+'-Name')
        
                                                    $Global:XmlWriter.WriteAttributeString($Attr1, [string]$ResName.name)
        
                                                    $Count ++
                                                }
                                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                                    Icon $IconAPPs ($subloc+65) ($Alt0+40) "64" "64"
                                
                                                $Global:XmlWriter.WriteEndElement()
                                            }
                                        else
                                            {
                                                $Global:XmlWriter.WriteStartElement('object')            
                                                $Global:XmlWriter.WriteAttributeString('label', [string]$ResNames.name)                                                                        
        
                                                $Global:XmlWriter.WriteAttributeString('App_Name', [string]$ResNames.name)
                                                $Global:XmlWriter.WriteAttributeString('Default_Hostname', [string]$RESNames.properties.defaultHostName)
                                                $Global:XmlWriter.WriteAttributeString('Enabled', [string]$RESNames.properties.enabled)
                                                $Global:XmlWriter.WriteAttributeString('State', [string]$RESNames.properties.state)
                                                $Global:XmlWriter.WriteAttributeString('Inbound_IP_Address', [string]$RESNames.properties.inboundIpAddress)
                                                $Global:XmlWriter.WriteAttributeString('Kind', [string]$RESNames.properties.kind)
                                                $Global:XmlWriter.WriteAttributeString('SKU', [string]$RESNames.properties.sku)
                                                $Global:XmlWriter.WriteAttributeString('Workers', [string]$RESNames.properties.siteConfig.numberOfWorkers)
                                                $Global:XmlWriter.WriteAttributeString('Min_Workers', [string]$RESNames.properties.siteConfig.minimumElasticInstanceCount)
                                                $Global:XmlWriter.WriteAttributeString('Site_Properties', [string]$RESNames.properties.siteProperties.properties.value)


                                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                                    Icon $IconAPPs ($subloc+65) ($Alt0+40) "64" "64"
                                
                                                $Global:XmlWriter.WriteEndElement()
                                            }
                                    }                                                                                                                                  
                                }
            'Function App' {    
                                if($FuntionAppNames)
                                    {                                                
                                        if($RESNames.count -gt 1)
                                            {
                                                $Global:XmlWriter.WriteStartElement('object')            
                                                $Global:XmlWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' Function Apps'))                                        
                                
                                                $Count = 1
                                                foreach ($ResName in $RESNames)
                                                {
                                                    $Attr1 = ('FunctionApp-'+[string]("{0:d3}" -f $Count)+'-Name')
        
                                                    $Global:XmlWriter.WriteAttributeString($Attr1, [string]$ResName.name)
        
                                                    $Count ++
                                                }
                                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                                    Icon $IconFunApps ($subloc+65) ($Alt0+40) "68" "60"
                                
                                                $Global:XmlWriter.WriteEndElement()
                                            }
                                        else
                                            {
                                                $Global:XmlWriter.WriteStartElement('object')            
                                                $Global:XmlWriter.WriteAttributeString('label', [string]$ResNames.name)                                                                        
        
                                                $Global:XmlWriter.WriteAttributeString('App_Name', [string]$ResNames.name)
                                                $Global:XmlWriter.WriteAttributeString('Default_Hostname', [string]$RESNames.properties.defaultHostName)
                                                $Global:XmlWriter.WriteAttributeString('Enabled', [string]$RESNames.properties.enabled)
                                                $Global:XmlWriter.WriteAttributeString('State', [string]$RESNames.properties.state)
                                                $Global:XmlWriter.WriteAttributeString('Inbound_IP_Address', [string]$RESNames.properties.inboundIpAddress)
                                                $Global:XmlWriter.WriteAttributeString('Kind', [string]$RESNames.properties.kind)
                                                $Global:XmlWriter.WriteAttributeString('SKU', [string]$RESNames.properties.sku)
                                                $Global:XmlWriter.WriteAttributeString('Workers', [string]$RESNames.properties.siteConfig.numberOfWorkers)
                                                $Global:XmlWriter.WriteAttributeString('Min_Workers', [string]$RESNames.properties.siteConfig.minimumElasticInstanceCount)
                                                $Global:XmlWriter.WriteAttributeString('Site_Properties', [string]$RESNames.properties.siteProperties.properties.value)

                                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                                    Icon $IconFunApps ($subloc+65) ($Alt0+40) "68" "60"
                                
                                                $Global:XmlWriter.WriteEndElement()

                                            }
                                    }
                                }
            'DataBricks' {      
                                if($DatabriksNames)
                                    {                                              
                                    if($RESNames.count -gt 1)
                                        {
                                            $Global:XmlWriter.WriteStartElement('object')            
                                            $Global:XmlWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' Databricks'))                                        
                            
                                            $Count = 1
                                            foreach ($ResName in $RESNames)
                                            {
                                                $Attr1 = ('Databrick-'+[string]("{0:d3}" -f $Count)+'-Name')
    
                                                $Global:XmlWriter.WriteAttributeString($Attr1, [string]$ResName.name)
    
                                                $Count ++
                                            }
                                            $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
    
                                                Icon $IconBricks ($subloc+65) ($Alt0+40) "60" "68"
                            
                                            $Global:XmlWriter.WriteEndElement()
                                        }
                                    else
                                        {
                                            $Global:XmlWriter.WriteStartElement('object')            
                                            $Global:XmlWriter.WriteAttributeString('label', [string]$RESNames.Name)                                                                
    
                                            $Global:XmlWriter.WriteAttributeString('Databrick_Name', [string]$ResNames.name)
                                            $Global:XmlWriter.WriteAttributeString('Workspace_URL', [string]$RESNames.properties.workspaceUrl )
                                            $Global:XmlWriter.WriteAttributeString('Pricing_Tier', [string]$RESNames.sku.name)
                                            $Global:XmlWriter.WriteAttributeString('Storage_Account', [string]$RESNames.properties.parameters.storageAccountName.value)
                                            $Global:XmlWriter.WriteAttributeString('Storage_Account_SKU', [string]$RESNames.properties.parameters.storageAccountSkuName.value)
                                            $Global:XmlWriter.WriteAttributeString('Relay_Namespace', [string]$RESNames.properties.parameters.relayNamespaceName.value)
                                            $Global:XmlWriter.WriteAttributeString('Require_Infrastructure_Encryption', [string]$RESNames.properties.parameters.requireInfrastructureEncryption.value)
                                            $Global:XmlWriter.WriteAttributeString('Enable_Public_IP', [string]$RESNames.properties.parameters.enableNoPublicIp.value)
    
                                            $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
    
                                                Icon $IconBricks ($subloc+65) ($Alt0+40) "60" "68"
                            
                                            $Global:XmlWriter.WriteEndElement()
                                        }                                                                                               
                                    }
                                }
            'Open Shift' {        
                                if($ARONames)
                                    {
                                        if($RESNames.count -gt 1)
                                            {
                                                $Global:XmlWriter.WriteStartElement('object')            
                                                $Global:XmlWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' OpenShift Clusters'))                                        
                                
                                                $Count = 1
                                                foreach ($ResName in $RESNames)
                                                {
                                                    $Attr1 = ('OpenShift_Cluster-'+[string]("{0:d3}" -f $Count)+'-Name')
        
                                                    $Global:XmlWriter.WriteAttributeString($Attr1, [string]$ResName.name)
        
                                                    $Count ++
                                                }
                                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                                    Icon $IconARO ($subloc+65) ($Alt0+40) "68" "60"
                                
                                                $Global:XmlWriter.WriteEndElement()

                                            }
                                        else
                                            {
                                                $Global:XmlWriter.WriteStartElement('object')            
                                                $Global:XmlWriter.WriteAttributeString('label', [string]$RESNames.Name)                                                                    
        
                                                $Global:XmlWriter.WriteAttributeString('ARO_Name', [string]$ResNames.name)
                                                $Global:XmlWriter.WriteAttributeString('OpenShift_Version', [string]$RESNames.properties.clusterProfile.version)
                                                $Global:XmlWriter.WriteAttributeString('OpenShift_Console', [string]$RESNames.properties.consoleProfile.url)
                                                $Global:XmlWriter.WriteAttributeString('Worker_VM_Count', [string]$RESNames.properties.workerprofiles.Count)
                                                $Global:XmlWriter.WriteAttributeString('Worker_VM_Size', [string]$RESNames.properties.workerprofiles.vmSize[0])
        
                                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                                    Icon $IconARO ($subloc+65) ($Alt0+40) "68" "60"
                                
                                                $Global:XmlWriter.WriteEndElement()
                                            }
                                    }                                                                                               
                                }
            'Container Instance'  {
                                    if($ContainerNames)
                                        {                                                                                                
                                            if($RESNames.count -gt 1)
                                                {
                                                    $Global:XmlWriter.WriteStartElement('object')            
                                                    $Global:XmlWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' Container Intances'))                                        
                                    
                                                    $Count = 1
                                                    foreach ($ResName in $RESNames)
                                                    {
                                                        $Attr1 = ('Container_Intance-'+[string]("{0:d3}" -f $Count)+'-Name')
            
                                                        $Global:XmlWriter.WriteAttributeString($Attr1, [string]$ResName.name)
            
                                                        $Count ++
                                                    }
                                                    $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
            
                                                        Icon $IconContain ($subloc+65) ($Alt0+40) "64" "68"
                                    
                                                    $Global:XmlWriter.WriteEndElement()
                                                }
                                            else
                                                {
                                                    $Global:XmlWriter.WriteStartElement('object')            
                                                    $Global:XmlWriter.WriteAttributeString('label', [string]$RESNames.Name)                                        
                                                    $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
            
                                                        Icon $IconContain ($subloc+65) ($Alt0+40) "64" "68"
                                    
                                                    $Global:XmlWriter.WriteEndElement()
                                                }
                                        }                                                                                               
                                }
            'NetApp' {          
                                if($NetAppNames)
                                    {                                          
                                        if($RESNames.count -gt 1)
                                            {
                                                $Global:XmlWriter.WriteStartElement('object')            
                                                $Global:XmlWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' NetApp Volumes'))                                        
                                
                                                $Count = 1
                                                foreach ($ResName in $RESNames)
                                                {
                                                    $Attr1 = ('NetApp_Volume-'+[string]("{0:d3}" -f $Count))
        
                                                    $Global:XmlWriter.WriteAttributeString($Attr1, [string]$ResName.name)
        
                                                    $Count ++
                                                }
                                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                                    Icon $IconNetApp ($subloc+65) ($Alt0+40) "65" "52"
                                
                                                $Global:XmlWriter.WriteEndElement()
                                            }
                                        else
                                            {
                                                $Global:XmlWriter.WriteStartElement('object')            
                                                $Global:XmlWriter.WriteAttributeString('label', ([string]1+' NetApp Volume'))                                                                        
                                                $Global:XmlWriter.WriteAttributeString('NetApp_Volume_Name', [string]$ResName.name)

                                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                                    Icon $IconNetApp ($subloc+65) ($Alt0+40) "65" "52"
                                
                                                $Global:XmlWriter.WriteEndElement()
                                            }
                                    }                                                                   
                                }
            'Data Explorer Clusters' {  
                                        if($RESNames.count -gt 1)
                                            {
                                                $Global:XmlWriter.WriteStartElement('object')            
                                                $Global:XmlWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' Data Explorer Clusters'))                                        
                                
                                                $Count = 1
                                                foreach ($ResName in $RESNames)
                                                {
                                                    $Attr1 = ('Data_Cluster-'+[string]("{0:d3}" -f $Count)+'-Name')
        
                                                    $Global:XmlWriter.WriteAttributeString($Attr1, [string]$ResName.name)
        
                                                    $Count ++
                                                }
                                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                                    Icon $IconDataExplorer ($subloc+65) ($Alt0+40) "68" "68"
                                
                                                $Global:XmlWriter.WriteEndElement()

                                            }
                                        else
                                            {
                                                $Global:XmlWriter.WriteStartElement('object')            
                                                $Global:XmlWriter.WriteAttributeString('label', [string]$RESNames.Name)                                        
                                                $Global:XmlWriter.WriteAttributeString('Data_Explorer_Cluster_Name', [string]$ResNames.name)
                                                $Global:XmlWriter.WriteAttributeString('Data_Explorer_Cluster_URI', [string]$ResNames.name)
                                                $Global:XmlWriter.WriteAttributeString('Data_Explorer_Cluster_State', [string]$ResNames.name)
                                                $Global:XmlWriter.WriteAttributeString('SKU_Tier', [string]$ResNames.name)
                                                $Global:XmlWriter.WriteAttributeString('Computer_Specifications', [string]$ResNames.name)
                                                $Global:XmlWriter.WriteAttributeString('AutoScale_Enabled', [string]$ResNames.name)
                                                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))
        
                                                    Icon $IconDataExplorer ($subloc+65) ($Alt0+40) "68" "68"
                                
                                                $Global:XmlWriter.WriteEndElement()
                                            }                                                               
                                } 
            'Network Interface' {                                                    
                                if($RESNames.count -gt 1)
                                    {
                                        $Global:XmlWriter.WriteStartElement('object')            
                                        $Global:XmlWriter.WriteAttributeString('label', ([string]$RESNames.Count + ' Network Interfaces'))                                        
                        
                                        $Count = 1
                                        foreach ($ResName in $RESNames)
                                        {
                                            $Attr1 = ('NIC-'+[string]("{0:d3}" -f $Count)+'-Name')

                                            $Global:XmlWriter.WriteAttributeString($Attr1, [string]$ResName.name)

                                            $Count ++
                                        }
                                        $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))

                                            Icon $IconNIC ($subloc+65) ($Alt0+40) "68" "60"
                        
                                        $Global:XmlWriter.WriteEndElement()

                                    }
                                else
                                    {
                                        $Global:XmlWriter.WriteStartElement('object')            
                                        $Global:XmlWriter.WriteAttributeString('label', ([string]1+' Network Interface'))                                        
                        
                                        $Attr1 = ('NIC-Name')
                                        $Global:XmlWriter.WriteAttributeString($Attr1, [string]$ResName.name)

                                        $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))

                                            Icon $IconNIC ($subloc+65) ($Alt0+40) "68" "60"
                        
                                        $Global:XmlWriter.WriteEndElement()

                                    }                                                                
                                }                                                                                                                                                                            
            '' {}
            default {}
        }
        if($sub.properties.networkSecurityGroup.id)
            {
                $NSG = $sub.properties.networkSecurityGroup.id.split('/')[8]
                $Global:XmlWriter.WriteStartElement('object')            
                $Global:XmlWriter.WriteAttributeString('label', '')                                        
                $Global:XmlWriter.WriteAttributeString('Network_Security_Group', [string]$NSG)
                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))

                    Icon $IconNSG ($subloc+160) ($Alt0+15) "26.35" "32"

                $Global:XmlWriter.WriteEndElement()  
            }
        if($sub.properties.routeTable.id)
            {
                $UDR = $sub.properties.routeTable.id.split('/')[8]
                $Global:XmlWriter.WriteStartElement('object')            
                $Global:XmlWriter.WriteAttributeString('label', '')                                        
                $Global:XmlWriter.WriteAttributeString('Route_Table', [string]$UDR)
                $Global:XmlWriter.WriteAttributeString('id', ($Global:CellID+'-'+($Global:IDNum++)))

                    Icon $IconUDR ($subloc+15) ($Alt0+15) "30.97" "30"

                $Global:XmlWriter.WriteEndElement()

            }
        if($sub.properties.ipconfigurations.id)
            {
                Foreach($SubIPs in $sub.properties.ipconfigurations)
                    {
                        $Global:VNETPIP += $Global:CleanPIPs | Where-Object {$_.properties.ipConfiguration.id -eq $SubIPs.id}
                    }
            }
}




$Global:etag = -join ((65..90) + (97..122) | Get-Random -Count 20 | % {[char]$_})
$Global:DiagID = -join ((65..90) + (97..122) | Get-Random -Count 20 | % {[char]$_})
$Global:CellID = -join ((65..90) + (97..122) | Get-Random -Count 20 | % {[char]$_})

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
    $Global:XmlWriter.WriteAttributeString('name', 'Page-1')

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

Variables0

Stensils

if($AZLGWs -or $AZEXPROUTEs)
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

    $Global:XmlWriter.WriteEndElement()

$Global:XmlWriter.WriteEndDocument()
$Global:XmlWriter.Flush()
$Global:XmlWriter.Close()