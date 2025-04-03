<#
.Synopsis
Network Module for Draw.io Diagram

.DESCRIPTION
This module is use for the Network topology in the Draw.io Diagram.

.Link
https://github.com/microsoft/ARI/Modules/Public/PublicFunctions/Diagram/Start-ARIDiagramNetwork.ps1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.6.0
First Release Date: 15th Oct, 2024
Authors: Claudio Merola

#>
Function Start-ARIDiagramNetwork {
    Param($Subscriptions,$Job,$Advisories,$DiagramCache,$FullEnvironment,$DDFile,$XMLFiles,$LogFile,$Automation,$ARIModule)

    Write-Output ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Starting Network Diagram Job...')

        $Script:jobs = @()
        $Script:jobs2 = @()

        Function New-ARIDiagramIcon {    
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
        
        Function New-ARIDiagramVNETContainer {
            Param($x,$y,$w,$h,$title)

                $Script:ContID = (-join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})+'-'+1)

                Write-Output ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Adding VNET: ' + $title + '. ID: ' + $Script:ContID + '. Position X: ' + $x + ' Position Y: ' + $y)

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

        Function New-ARIDiagramHubContainer {
            Param($x,$y,$w,$h,$title)
                $Script:ContID = (-join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})+'-'+1)
                Write-Output ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Adding HUB: ' + $title + '. ID: ' + $Script:ContID + '. Position X: ' + $x + ' Position Y: ' + $y)

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

        Function New-ARIDiagramBrokenContainer {
            Param($x,$y,$w,$h,$title)
                $Script:ContID = (-join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})+'-'+1)

                Write-Output ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Adding Broken Container: ' + $title + '. ID: ' + $Script:ContID + '. Position X: ' + $x + ' Position Y: ' + $y)

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

        Function New-ARIDiagramConnection {
        Param($Source,$Target,$Parent)
        
            if($Parent){$Parent = $Parent}else{$Parent = 1}
        
            Write-Output ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Connecting: ' + $Source + ' to: ' + $Target + '. Parent ID: ' + $Parent)

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
        Function Publish-ARIDiagramStensils {
            $Script:Ret = "rounded=0;whiteSpace=wrap;fontSize=16;html=1;sketch=0;fontFamily=Helvetica;"
        
            $Script:IconConnections = "aspect=fixed;html=1;points=[];align=center;image;fontSize=18;image=img/lib/azure2/networking/Connections.svg;" #width="68" height="68"
            $Script:IconExpressRoute = "aspect=fixed;html=1;points=[];align=center;image;fontSize=18;image=img/lib/azure2/networking/ExpressRoute_Circuits.svg;" #width="70" height="64"
            $Script:IconVGW = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/networking/Virtual_Network_Gateways.svg;" #width="52" height="69"
            $Script:IconVGW2 = "aspect=fixed;html=1;points=[];align=center;image;fontSize=18;image=img/lib/azure2/networking/Virtual_Network_Gateways.svg;" #width="52" height="69"
            $Script:IconVNET = "aspect=fixed;html=1;points=[];align=center;image;fontSize=18;image=img/lib/azure2/networking/Virtual_Networks.svg;" #width="67" height="40"
            $Script:IconTraffic = "aspect=fixed;html=1;points=[];align=center;image;fontSize=18;image=img/lib/azure2/networking/Local_Network_Gateways.svg;" #width="68" height="68"
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
            $Script:IconContain = "aspect=fixed;html=1;points=[];align=center;image;fontSize=14;image=img/lib/azure2/compute/Container_Instances.svg;" #width="64" height="68"
            $Script:IconVWAN = "aspect=fixed;html=1;points=[];align=center;image;fontSize=18;image=img/lib/azure2/networking/Virtual_WANs.svg;" #width="65" height="64"
            $Script:IconCostMGMT = "aspect=fixed;html=1;points=[];align=center;image;fontSize=12;image=img/lib/azure2/general/Cost_Analysis.svg;" #width="60" height="70"

            <########################## Other Stencils #############################>

            $Script:IconDet =  "aspect=fixed;html=1;points=[];align=center;image;fontSize=12;image=img/lib/azure2/other/Detonation.svg;" #width="42.63" height="44"
            $Script:IconError = "sketch=0;aspect=fixed;pointerEvents=1;shadow=0;dashed=0;html=1;strokeColor=none;labelPosition=center;verticalLabelPosition=bottom;verticalAlign=top;align=center;shape=mxgraph.mscae.enterprise.not_allowed;fillColor=#EA1C24;" #width="30" height="30"
            $Script:OnPrem = "sketch=0;aspect=fixed;html=1;points=[];align=center;image;fontSize=56;image=img/lib/mscae/Exchange_On_premises_Access.svg;" #width="168.2" height="290"
            $Script:Signature = "aspect=fixed;html=1;points=[];align=left;image;fontSize=22;image=img/lib/azure2/general/Dev_Console.svg;" #width="27.5" height="22"
            $Script:CloudOnly = "aspect=fixed;html=1;points=[];align=center;image;fontSize=56;image=img/lib/azure2/compute/Cloud_Services_Classic.svg;" #width="380.77" height="275"
        
        }

        <# Function to begin OnPrem environment drawing. Will begin by Local network Gateway, then Express Route.#>
        Function Invoke-ARIDiagramOnPremNetwork {
            $Script:VNETHistory = @()
            $Script:RoutsW = $Job.AZVNETs | Select-Object -Property Name, @{N="Subnets";E={$_.properties.subnets.properties.addressPrefix.count}} | Sort-Object -Property Subnets -Descending
        
            $Script:Alt = 0
        
            ##################################### Local Network Gateway #############################################
        
            foreach($GTW in $Job.AZLGWs)
            {
                if($GTW.properties.provisioningState -ne 'Succeeded')
                {
                    $Script:XmlWriter.WriteStartElement('object')            
                    $Script:XmlWriter.WriteAttributeString('label', '')
                    $Script:XmlWriter.WriteAttributeString('Status', 'This Local Network Gateway has Errors')
                    $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                        New-ARIDiagramIcon $IconError 40 ($Script:Alt+25) "25" "25" 1

                    $Script:XmlWriter.WriteEndElement()
                }

                $Con1 = $Job.AZCONs | Where-Object {$_.properties.localNetworkGateway2.id -eq $GTW.id}
                
                if(!$Con1 -and $GTW.properties.provisioningState -eq 'Succeeded')
                {
                    $Script:XmlWriter.WriteStartElement('object')            
                    $Script:XmlWriter.WriteAttributeString('label', '')
                    $Script:XmlWriter.WriteAttributeString('Status', 'No Connections were found in this Local Network Gateway')
                    $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                        New-ARIDiagramIcon $SymInfo 40 ($Script:Alt+30) "20" "20" 1

                    $Script:XmlWriter.WriteEndElement()
                }

                $Name = $GTW.name
                $IP = $GTW.properties.gatewayIpAddress

                $Script:XmlWriter.WriteStartElement('object')            
                $Script:XmlWriter.WriteAttributeString('label', ("`n" + [string]$Name + "`n" + [string]$IP))
                $Script:XmlWriter.WriteAttributeString('Local_Address_Space', [string]$GTW.properties.localNetworkAddressSpace.addressPrefixes)
                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                    New-ARIDiagramIcon $IconTraffic 50 $Script:Alt "67" "40" 1

                $Script:XmlWriter.WriteEndElement()                  

                $Script:GTWAddress = ($Script:CellID+'-'+($Script:IDNum-1))
                $Script:ConnSourceResource = 'GTW'

                    Start-ARIDiagramOnPremInfra $Con1

                $Script:Alt = $Script:Alt + 150
            }

            ##################################### ERS #############################################

            Foreach($ERs in $Job.AZEXPROUTEs)
            {
                if($ERs.properties.provisioningState -ne 'Succeeded')
                {
                    $Script:XmlWriter.WriteStartElement('object')            
                    $Script:XmlWriter.WriteAttributeString('label', '')
                    $Script:XmlWriter.WriteAttributeString('Status', 'This Express Route has Errors')
                    $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                        New-ARIDiagramIcon $IconError 51 ($Script:Alt+25) "25" "25" 1

                    $Script:XmlWriter.WriteEndElement()
                }       

                $Con1 = $Job.AZCONs | Where-Object {$_.properties.peer.id -eq $ERs.id}
                
                if(!$Con1 -and $ERs.properties.circuitProvisioningState -eq 'Enabled')
                {
                    $Script:XmlWriter.WriteStartElement('object')            
                    $Script:XmlWriter.WriteAttributeString('label', '')
                    $Script:XmlWriter.WriteAttributeString('Status', 'No Connections were found in this Express Route')
                    $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                        New-ARIDiagramIcon $SymInfo 51 ($Script:Alt+30) "20" "20" 1

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

                    New-ARIDiagramIcon $IconExpressRoute "61.5" $Script:Alt "44" "40" 1

                $Script:XmlWriter.WriteEndElement()

                $Script:ERAddress = ($Script:CellID+'-'+($Script:IDNum-1))
                $Script:ConnSourceResource = 'ER'

                    Start-ARIDiagramOnPremInfra $Con1

                $Script:Alt = $Script:Alt + 150

            }

            ##################################### VWAN VPNSITES #############################################

            foreach($GTW in $Job.AZVPNSITES)
            {
                if($GTW.properties.provisioningState -ne 'Succeeded')
                {
                    $Script:XmlWriter.WriteStartElement('object')            
                    $Script:XmlWriter.WriteAttributeString('label', '')
                    $Script:XmlWriter.WriteAttributeString('Status', 'This VPN Site has Errors')
                    $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                        New-ARIDiagramIcon $IconError 40 ($Script:Alt+25) "25" "25" 1

                    $Script:XmlWriter.WriteEndElement()
                }

                $wan1 = $Job.AZVWAN | Where-Object {$_.properties.vpnSites.id -eq $GTW.id}

                if(!$wan1 -and $GTW.properties.provisioningState -eq 'Succeeded')
                {
                    $Script:XmlWriter.WriteStartElement('object')            
                    $Script:XmlWriter.WriteAttributeString('label', '')
                    $Script:XmlWriter.WriteAttributeString('Status', 'No vWANs were found in this VPN Site')
                    $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                        New-ARIDiagramIcon $SymInfo 40 ($Script:Alt+30) "20" "20" 1

                    $Script:XmlWriter.WriteEndElement()
                }

                $Name = $GTW.name

                $Script:XmlWriter.WriteStartElement('object')            
                $Script:XmlWriter.WriteAttributeString('label', ("`n" + [string]$Name))
                $Script:XmlWriter.WriteAttributeString('Address_Space', [string]$GTW.properties.addressSpace.addressPrefixes)
                $Script:XmlWriter.WriteAttributeString('Link_Speed_In_Mbps', [string]$GTW.properties.deviceProperties.linkSpeedInMbps)
                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                    New-ARIDiagramIcon $IconNAT 50 $Script:Alt "67" "40" 1

                $Script:XmlWriter.WriteEndElement()   

                    Start-ARIDiagramvWanInfra $wan1

                $Script:Alt = $Script:Alt + 150
            }

            ##################################### VWAN ERs #############################################

            foreach($GTW in $Job.AZVERs)
            {
                if($GTW.properties.provisioningState -ne 'Succeeded')
                {
                    $Script:XmlWriter.WriteStartElement('object')            
                    $Script:XmlWriter.WriteAttributeString('label', '')
                    $Script:XmlWriter.WriteAttributeString('Status', 'This Express Route Circuit has Errors')
                    $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                        New-ARIDiagramIcon $IconError 40 ($Script:Alt+25) "25" "25" 1

                    $Script:XmlWriter.WriteEndElement()
                }

                $wan1 = $Job.AZVWAN | Where-Object {$_.properties.vpnSites.id -eq $GTW.id}

                if(!$wan1 -and $GTW.properties.provisioningState -eq 'Succeeded')
                {
                    $Script:XmlWriter.WriteStartElement('object')            
                    $Script:XmlWriter.WriteAttributeString('label', '')
                    $Script:XmlWriter.WriteAttributeString('Status', 'No vWANs were found in this Express Route Circuit')
                    $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                        New-ARIDiagramIcon $SymInfo 40 ($Script:Alt+30) "20" "20" 1

                    $Script:XmlWriter.WriteEndElement()
                }

                $Name = $GTW.name

                $Script:XmlWriter.WriteStartElement('object')            
                $Script:XmlWriter.WriteAttributeString('label', ("`n" + [string]$Name))
                $Script:XmlWriter.WriteAttributeString('Address_Space', [string]$GTW.properties.addressSpace.addressPrefixes)
                $Script:XmlWriter.WriteAttributeString('LinkSpeed_In_Mbps', [string]$GTW.properties.deviceProperties.linkSpeedInMbps)
                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                    New-ARIDiagramIcon $IconNAT 50 $Script:Alt "67" "40" 1

                $Script:XmlWriter.WriteEndElement()     

                    Start-ARIDiagramvWanInfra $wan1

                $Script:Alt = $Script:Alt + 150
            }

            ##################################### LABELs #############################################

            if(!$FullEnvironment)
                {

                    $Script:XmlWriter.WriteStartElement('object')            
                    $Script:XmlWriter.WriteAttributeString('label', '')
                    $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                        New-ARIDiagramIcon $Ret -520 -100 "500" ($Script:Alt + 100) 1

                    $Script:XmlWriter.WriteEndElement()

                    $Script:XmlWriter.WriteStartElement('object')            
                    $Script:XmlWriter.WriteAttributeString('label', ('On Premises'+ "`n" +'Environment'))
                    $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                        New-ARIDiagramIcon $OnPrem -351 (($Script:Alt + 100)/2) "168.2" "290" 1

                    $Script:XmlWriter.WriteEndElement()  

                    Set-ARIDiagramLabel

                    New-ARIDiagramIcon $Signature -520 ($Script:Alt + 100) "27.5" "22" 1

                    $Script:XmlWriter.WriteEndElement()  
                }

        }

        Function Start-ARIDiagramOnPremInfra {
        Param($Con1)
        foreach ($Con2 in $Con1)
                {
                    if([string]::IsNullOrEmpty($Script:vnetLoc))
                    {
                        $Script:vnetLoc = 700
                    }
                    $VGT = $Job.AZVGWs | Where-Object {$_.id -eq $Con2.properties.virtualNetworkGateway1.id}
                    $VGTPIP = $Job.PIPs | Where-Object {$_.properties.ipConfiguration.id -eq $VGT.properties.ipConfigurations.id}

                    $Name2 = $Con2.Name

                    $Script:XmlWriter.WriteStartElement('object')            
                    $Script:XmlWriter.WriteAttributeString('label', [string]$Name2)
                    $Script:XmlWriter.WriteAttributeString('Connection_Type', [string]$Con2.properties.connectionType)
                    $Script:XmlWriter.WriteAttributeString('Use_Azure_Private_IP_Address', [string]$Con2.properties.useLocalAzureIpAddress)
                    $Script:XmlWriter.WriteAttributeString('Routing_Weight', [string]$Con2.properties.routingWeight)
                    $Script:XmlWriter.WriteAttributeString('Connection_Protocol', [string]$Con2.properties.connectionProtocol)
                    $Script:Source = ($Script:CellID+'-'+($Script:IDNum-1))
                    $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                        $LogResName = [string]$Name2
                        Write-Output ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Adding Icon ($LogResName): " + $Script:CellID+'-'+($Script:IDNum))
                        New-ARIDiagramIcon $IconConnections 250 $Script:Alt "40" "40" 1

                    $Script:XmlWriter.WriteEndElement()

                    $Script:Target = ($Script:CellID+'-'+($Script:IDNum-1))

                    if($Script:ConnSourceResource -eq 'ER')
                        {
                            New-ARIDiagramConnection $Script:ERAddress $Script:Target
                        }
                    elseif($Script:ConnSourceResource -eq 'GTW')
                        {
                            New-ARIDiagramConnection $Script:GTWAddress $Script:Target
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

                        $LogResName = [string]$VGT.Name
                        Write-Output ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Adding Icon ($LogResName): " + $Script:CellID+'-'+($Script:IDNum))
                        New-ARIDiagramIcon $IconVGW2 425 ($Script:Alt-4) "31.34" "48" 1

                    $Script:XmlWriter.WriteEndElement()

                    $Script:Target = ($Script:CellID+'-'+($Script:IDNum-1))

                    New-ARIDiagramConnection $Script:Source $Script:Target

                    $Script:Source = $Script:Target

                    foreach($AZVNETs2 in $Job.AZVNETs)
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
                                            
                                            $LogResName = [string]$VNET2.Name
                                            Write-Output ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Adding Icon ($LogResName): " + $Script:CellID+'-'+($Script:IDNum))
                                            New-ARIDiagramIcon $IconVNET 600 $Script:Alt "65" "39" 1

                                        $Script:XmlWriter.WriteEndElement()      

                                        $Script:VNETDrawID = ($Script:CellID+'-'+($Script:IDNum-1))

                                        $Script:Target = ($Script:CellID+'-'+($Script:IDNum-1))

                                            New-ARIDiagramConnection $Script:Source $Script:Target

                                        if($VNET2.properties.enableDdosProtection -eq $true)
                                        {
                                            $Script:XmlWriter.WriteStartElement('object')            
                                            $Script:XmlWriter.WriteAttributeString('label', '')
                                            $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                                New-ARIDiagramIcon $IconDDOS 580 ($Script:Alt + 15) "23" "28" 1

                                            $Script:XmlWriter.WriteEndElement()
                                        }

                                        $Script:Source = $Script:Target

                                            New-ARIDiagramVNET $Script:VNET2

                                        if($VNET2.properties.virtualNetworkPeerings.properties.remoteVirtualNetwork.id)
                                            {
                                                New-ARIDiagramPeerVNET $Script:VNET2
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

                                        New-ARIDiagramConnection $Script:Source $VNETDID.VNETid 

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

        Function Start-ARIDiagramvWanInfra {
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

                New-ARIDiagramIcon $IconVWAN 250 $Script:Alt "40" "40" 1

            $Script:XmlWriter.WriteEndElement()

            $Script:Target = ($Script:CellID+'-'+($Script:IDNum-1))

                New-ARIDiagramConnection $Script:Source $Script:Target

            $Script:Source1 = $Script:Target

            foreach ($Con2 in $wan1.properties.virtualHubs.id)
                {
                    $VHUB = $Job.AZVHUB | Where-Object {$_.id -eq $Con2}           

                    $Script:XmlWriter.WriteStartElement('object')            
                    $Script:XmlWriter.WriteAttributeString('label', ("`n" +[string]$VHUB.Name))
                    $Script:XmlWriter.WriteAttributeString('Address_Prefix', [string]$VHUB.properties.addressPrefix)
                    $Script:XmlWriter.WriteAttributeString('Preferred_Routing_Gateway', [string]$VHUB.properties.preferredRoutingGateway)
                    $Script:XmlWriter.WriteAttributeString('Virtual_Router_Asn', [string]$VHUB.properties.virtualRouterAsn)
                    $Script:XmlWriter.WriteAttributeString('Allow_BranchToBranch_Traffic', [string]$VHUB.properties.allowBranchToBranchTraffic)
                    $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                        New-ARIDiagramIcon $IconVWAN 425 $Script:Alt "40" "40" 1

                    $Script:XmlWriter.WriteEndElement()

                    $Script:Target = ($Script:CellID+'-'+($Script:IDNum-1))

                        New-ARIDiagramConnection $Script:Source1 $Script:Target

                    $Script:Source = $Script:Target

                    foreach($AZVNETs2 in $Job.AZVNETs)
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

                                            $LogResName = [string]$VNET2.Name
                                            Write-Output ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Adding VNET ($LogResName): " + $Script:CellID+'-'+($Script:IDNum))
                                            New-ARIDiagramIcon $IconVNET 600 $Script:Alt "65" "39" 1

                                        $Script:XmlWriter.WriteEndElement()      
                                        
                                        $Script:VNETDrawID = ($Script:CellID+'-'+($Script:IDNum-1))
                                                            
                                        $Script:Target = ($Script:CellID+'-'+($Script:IDNum-1))

                                            Write-Output ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Connecting: " + $Script:Source+' to: '+$Script:Target)
                                            New-ARIDiagramConnection $Script:Source $Script:Target

                                        if($VNET2.properties.enableDdosProtection -eq $true)
                                        {
                                            $Script:XmlWriter.WriteStartElement('object')            
                                            $Script:XmlWriter.WriteAttributeString('label', '')
                                            $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                                New-ARIDiagramIcon $IconDDOS 580 ($Script:Alt + 15) "23" "28" 1

                                            $Script:XmlWriter.WriteEndElement()
                                        }

                                            New-ARIDiagramVNET $Script:VNET2

                                        if($VNET2.properties.virtualNetworkPeerings.properties.remoteVirtualNetwork.id -and $VNET2.properties.virtualNetworkPeerings.properties.remoteVirtualNetwork.id -notlike ('*/HV_'+$VHUB.name+'_*'))
                                            {
                                                New-ARIDiagramPeerVNET $Script:VNET2
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

                                        Write-Output ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Connecting: " + $Script:Source+' to: '+$VNETDID.VNETid )
                                        New-ARIDiagramConnection $Script:Source $VNETDID.VNETid 
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
        Function Invoke-ARIDiagramCloudOnly {
        $Script:RoutsW = $Job.AZVNETs | Select-Object -Property Name, @{N="Subnets";E={$_.properties.subnets.properties.addressPrefix.count}} | Sort-Object -Property Subnets -Descending
        
        $Script:VNETHistory = @()
        if([string]::IsNullOrEmpty($Script:vnetLoc))
            {
                $Script:vnetLoc = 700
            }
        $Script:Alt = 2
        
            foreach($AZVNETs2 in $Job.AZVNETs)
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

                                $LogResName = [string]$VNET2.Name
                                Write-Output ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Adding VNET ($LogResName): " + $Script:CellID+'-'+($Script:IDNum))
                                New-ARIDiagramIcon $IconVNET 600 $Script:Alt "65" "39" 1

                            $Script:XmlWriter.WriteEndElement()      
                            
                            $Script:VNETDrawID = ($Script:CellID+'-'+($Script:IDNum-1))
                                                
                            $Script:Target = ($Script:CellID+'-'+($Script:IDNum-1))

                            if($VNET2.properties.enableDdosProtection -eq $true)
                            {
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', '')
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    New-ARIDiagramIcon $IconDDOS 580 ($Script:Alt + 15) "23" "28" 1

                                $Script:XmlWriter.WriteEndElement()
                            }

                            $Script:Source = $Script:Target

                                New-ARIDiagramVNET $Script:VNET2

                            if($VNET2.properties.virtualNetworkPeerings.properties.remoteVirtualNetwork.id)
                                {
                                    New-ARIDiagramPeerVNET $Script:VNET2
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

                        Write-Output ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Adding Icon: " + $Script:CellID+'-'+($Script:IDNum))
                        New-ARIDiagramIcon $Ret -520 -100 "500" ($Script:Alt + 100) 1

                    $Script:XmlWriter.WriteEndElement()

                    $Script:XmlWriter.WriteStartElement('object')            
                    $Script:XmlWriter.WriteAttributeString('label', ('Cloud Only'+ "`n" +'Environment'))
                    $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                        New-ARIDiagramIcon $Script:CloudOnly -460 (($Script:Alt + 100)/2) "380" "275" 1

                    $Script:XmlWriter.WriteEndElement()  

                    Set-ARIDiagramLabel

                    New-ARIDiagramIcon $Signature -520 ($Script:Alt + 100) "27.5" "22" 1

                    $Script:XmlWriter.WriteEndElement()  

        }

        Function Invoke-ARIDiagramFullEnvironment {
            foreach($AZVNETs2 in $Job.AZVNETs)
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

                                $LogResName = [string]$VNET2.Name
                                Write-Output ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+" - Adding VNET ($LogResName): " + $Script:CellID+'-'+($Script:IDNum))
                                New-ARIDiagramIcon $IconVNET 600 $Script:Alt "65" "39" 1

                            $Script:XmlWriter.WriteEndElement()

                            New-ARIDiagramVNET $Script:VNET2

                            if($VNET2.properties.virtualNetworkPeerings.properties.remoteVirtualNetwork.id)
                                {
                                    New-ARIDiagramPeerVNET $Script:VNET2
                                }  
                        }
                    }

                    $Script:XmlWriter.WriteStartElement('object')            
                    $Script:XmlWriter.WriteAttributeString('label', '')
                    $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                        New-ARIDiagramIcon $Ret -520 -100 "500" ($Script:Alt + 100) 1

                    $Script:XmlWriter.WriteEndElement()

                    $Script:XmlWriter.WriteStartElement('object')            
                    $Script:XmlWriter.WriteAttributeString('label', ('On Premises'+ "`n" +'Environment'))
                    $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                        New-ARIDiagramIcon $OnPrem -351 (($Script:Alt + 100)/2) "168.2" "290" 1

                    $Script:XmlWriter.WriteEndElement()  

                    Set-ARIDiagramLabel

                    New-ARIDiagramIcon $Signature -520 ($Script:Alt + 100) "27.5" "22" 1

                    $Script:XmlWriter.WriteEndElement()  

        }

        <# Function for VNET creation #>
        Function New-ARIDiagramVNET {
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
                                New-ARIDiagramHubContainer ($Script:vnetLoc) ($Script:Alt0 - 20) $Script:sizeL "490" $VNET2.Name
                            }
                        else
                            {
                                New-ARIDiagramVNETContainer ($Script:vnetLoc) ($Script:Alt0 - 20) $Script:sizeL "490" $VNET2.Name
                            }

                        $Script:VNETSquare = ($Script:CellID+'-'+($Script:IDNum-1))

                        $SubName = $Subscriptions | Where-Object {$_.id -eq $VNET2.subscriptionId}

                        $Script:XmlWriter.WriteStartElement('object')            
                        $Script:XmlWriter.WriteAttributeString('label', $SubName.name)
                        $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                            New-ARIDiagramIcon $IconSubscription $Script:sizeL 460 "67" "40" $Script:ContID

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

                                New-ARIDiagramIcon $IconCostMGMT ($Script:sizeL + 150) 460 "30" "35" $Script:ContID

                            $Script:XmlWriter.WriteEndElement()
                            
                        }

                        New-ARIDiagramSubnet ($Script:vnetLoc + 15) $VNET2 $Script:IDNum $DiagramCache $Script:ContID $LogFile

                        Start-Sleep -Milliseconds 100

                        $Script:Alt = $Script:Alt + 650
                    }
                else
                    {
                        $Script:sizeL = (($Script:sizeL * 210) + 30)

                        if('gatewaysubnet' -in $VNET2.properties.subnets.name)
                            {
                                New-ARIDiagramHubContainer ($Script:vnetLoc) ($Script:Alt0 - 15) $Script:sizeL "260" $VNET2.Name
                            }
                        else
                            {
                                New-ARIDiagramVNETContainer ($Script:vnetLoc) ($Script:Alt0 - 15) $Script:sizeL "260" $VNET2.Name
                            }

                        $Script:VNETSquare = ($Script:CellID+'-'+($Script:IDNum-1))

                        $SubName = $Subscriptions | Where-Object {$_.id -eq $VNET2.subscriptionId}

                        $Script:XmlWriter.WriteStartElement('object')            
                        $Script:XmlWriter.WriteAttributeString('label', $SubName.name)
                        $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                            New-ARIDiagramIcon $IconSubscription $Script:sizeL 225 "67" "40" $Script:ContID

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

                                New-ARIDiagramIcon $IconCostMGMT ($Script:sizeL + 150) 225 "30" "35" $Script:ContID

                            $Script:XmlWriter.WriteEndElement()

                        }

                        New-ARIDiagramSubnet ($Script:vnetLoc + 15) $VNET2 $Script:IDNum $DiagramCache $Script:ContID $LogFile

                        Start-Sleep -Milliseconds 100

                        $Script:Alt = $Script:Alt + 350 
                    }
                }

                [System.GC]::GetTotalMemory($true) | out-null
        }

        <# Function for create peered VNETs #>
        Function New-ARIDiagramPeerVNET {
        Param($VNET2)

            $Script:vnetLoc1 = $Script:Alt                                    

            Foreach ($Peer in $VNET2.properties.virtualNetworkPeerings)
                {
                    $VNETSUB = $Job.AZVNETs | Where-Object {$_.id -eq $Peer.properties.remoteVirtualNetwork.id}                                                

                    if($VNETSUB.id -in $VNETHistory.VNET)
                        {        
                            $VNETDID = $VNETHistory | Where-Object {$_.VNET -eq $VNETSUB.id}

                            $Script:XmlWriter.WriteStartElement('object')
                            $Script:XmlWriter.WriteAttributeString('label', '')
                            $Script:XmlWriter.WriteAttributeString('Peering_Name', $Peer.name)
                            $Script:XmlWriter.WriteAttributeString('Peering_State', $Peer.properties.peeringState)
                            $Script:XmlWriter.WriteAttributeString('Gateway_Transit', $Peer.properties.allowGatewayTransit)
                            $Script:XmlWriter.WriteAttributeString('Forwarded_Traffic', $Peer.properties.allowForwardedTraffic)
                            $Script:XmlWriter.WriteAttributeString('VNET_Access', $Peer.properties.allowVirtualNetworkAccess)
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

                            New-ARIDiagramIcon $IconVNET $Script:vnetLoc $Script:vnetLoc1 "67" "40" 1

                        $Script:XmlWriter.WriteEndElement()

                        $TwoTarget = ($Script:CellID+'-'+($Script:IDNum-1))

                        $Script:XmlWriter.WriteStartElement('object')            
                        $Script:XmlWriter.WriteAttributeString('label', '')
                        $Script:XmlWriter.WriteAttributeString('Peering_Name', $Peer.name)
                        $Script:XmlWriter.WriteAttributeString('Peering_State', $Peer.properties.peeringState)
                        $Script:XmlWriter.WriteAttributeString('Gateway_Transit', $Peer.properties.allowGatewayTransit)
                        $Script:XmlWriter.WriteAttributeString('Forwarded_Traffic', $Peer.properties.allowForwardedTraffic)
                        $Script:XmlWriter.WriteAttributeString('VNET_Access', $Peer.properties.allowVirtualNetworkAccess)
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

                                    New-ARIDiagramIcon $IconDDOS ($Script:vnetLoc - 20) ($Script:vnetLoc1 + 15) "23" "28" 1

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
                                        New-ARIDiagramHubContainer ($Script:vnetLoc + 100) ($Script:vnetLoc1 - 20) $Script:sizeL "490" $VNETSUB.name
                                    }
                                else
                                    {
                                        New-ARIDiagramVNETContainer ($Script:vnetLoc + 100) ($Script:vnetLoc1 - 20) $Script:sizeL "490" $VNETSUB.name
                                    }

                                $Script:VNETSquare = ($Script:CellID+'-'+($Script:IDNum-1))

                                $SubName = $Subscriptions | Where-Object {$_.id -eq $VNETSUB.subscriptionId}
                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', $SubName.name)
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    New-ARIDiagramIcon $IconSubscription $Script:sizeL 460 "67" "40" $Script:ContID

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

                                            New-ARIDiagramIcon $IconCostMGMT ($Script:sizeL + 150) 460 "30" "35" $Script:ContID

                                        $Script:XmlWriter.WriteEndElement()
                                        
                                    }

                                    New-ARIDiagramSubnet ($Script:vnetLoc + 120) $VNETSUB $Script:IDNum $DiagramCache $Script:ContID $LogFile

                                    Start-Sleep -Milliseconds 100

                                    $Script:vnetLoc1 = $Script:vnetLoc1 + 230 

                                $Script:Alt = $Script:Alt + 650                                                                         
                            }
                        else
                            {
                                $Script:sizeL = (($Script:sizeL * 210) + 30)

                                if($BrokenVNET -eq 'Not Broken')
                                    {                                        
                                        if('gatewaysubnet' -in $VNETSUB.properties.subnets.name)
                                            {
                                                New-ARIDiagramHubContainer ($Script:vnetLoc + 100) ($Script:vnetLoc1 - 20) $Script:sizeL "260" $VNETSUB.name
                                            }
                                        else
                                            {
                                                New-ARIDiagramVNETContainer ($Script:vnetLoc + 100) ($Script:vnetLoc1 - 20) $Script:sizeL "260" $VNETSUB.name
                                            }
                                    }
                                else
                                    {
                                        New-ARIDiagramBrokenContainer ($Script:vnetLoc + 100) ($Script:vnetLoc1 - 20) "250" "260" 'Broken Peering'
                                        $Script:sizeL = '250'
                                    }

                                $Script:VNETSquare = ($Script:CellID+'-'+($Script:IDNum-1))

                                $SubName = $Subscriptions | Where-Object {$_.id -eq $VNETSUB.subscriptionId}

                                $Script:XmlWriter.WriteStartElement('object')            
                                $Script:XmlWriter.WriteAttributeString('label', $SubName.name)
                                $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))

                                    New-ARIDiagramIcon $IconSubscription $Script:sizeL 225 "67" "40" $Script:ContID

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

                                            New-ARIDiagramIcon $IconCostMGMT ($Script:sizeL + 150) 225 "30" "35" $Script:ContID

                                        $Script:XmlWriter.WriteEndElement()
                                        
                                    }

                                    New-ARIDiagramSubnet ($Script:vnetLoc + 120) $VNETSUB $Script:IDNum $DiagramCache $Script:ContID $LogFile

                                    Start-Sleep -Milliseconds 100

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

        Function New-ARIDiagramSubnet {
            Param($subloc,$VNET,$IDNum,$DiagramCache,$ContID,$LogFile)

            try
                {
                    if($Automation.IsPresent)
                    {
                        Write-Output ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Creating Subnet in Automation')

                        Build-ARIDiagramSubnet -SubnetLocation $subloc -VNET $VNET -IDNum $IDNum -DiagramCache $DiagramCache -ContainerID $ContID -Job $Job -LogFile $LogFile
                    }
                else
                    {
                        Write-Output ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Creating Subnet in Thread')

                        $NameString = -join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})

                        Start-ThreadJob -Name ('Job_'+$NameString) -ScriptBlock {
                            Write-Output ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Calling Subnet function')

                            Import-Module $($args[7])

                            Build-ARIDiagramSubnet -SubnetLocation $($args[0]) -VNET $($args[1]) -IDNum $($args[2]) -DiagramCache $($args[3]) -ContainerID $($args[4]) -Job $($args[5])-LogFile $($args[6])
                        } -ArgumentList $subloc,$VNET,$IDNum,$DiagramCache,$ContID,$Job,$LogFile,$ARIModule | Out-Null

                        $Script:jobs += ('Job_'+$NameString)

                        <#
                        New-Variable -Name ('Run_'+$NameString) -Scope Script

                        Set-Variable -name ('Run_'+$NameString) -Value ([PowerShell]::Create()).AddScript({param($subloc,$VNET,$IDNum,$DiagramCache,$ContID,$LogFile,$ARIModule)
                            try
                                {
                                    Write-Output ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Calling Subnet function')

                                    Import-Module $ARIModule

                                    Build-ARIDiagramSubnet -SubnetLocation $subloc -VNET $VNET -IDNum $IDNum -DiagramCache $DiagramCache -ContainerID $ContID -Job $Job -LogFile $LogFile
                                }
                            catch
                                {
                                    Write-Output ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Error: ' + $_.Exception.Message)
                                }

                        }).AddArgument($subloc).AddArgument($VNET).AddArgument($IDNum).AddArgument($DiagramCache).AddArgument($ContID).AddArgument($LogFile).AddArgument($ARIModule)

                        New-Variable -Name ('Job_'+$NameString) -Scope Script

                        Set-Variable -Name ('Job_'+$NameString) -Value ((get-variable -name ('Run_'+$NameString)).Value).BeginInvoke()

                        $Script:jobs2 += (get-variable -name ('Job_'+$NameString)).Value

                        $Script:jobs += $NameString

                        #New-Variable -Name ('End_'+$NameString) -Scope Script
                        #Set-Variable -Name ('End_'+$NameString) -Value (((get-variable -name ('Run_'+$NameString)).Value).EndInvoke((get-variable -name ('Job_'+$NameString)).Value))

                        #((get-variable -name ('Run_'+$NameString)).Value).Dispose()

                        #while ($Job.Runspace.IsCompleted -contains $false) {}
                        #>

                    }
                }
            catch
                {
                    Write-Output ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Error: ' + $_.Exception.Message)
                }
        }

        Function Remove-ARIDiagramJob {
            foreach($job in $Script:jobs)
            {
                if((get-variable -name ('Job_'+$job) -Scope Script).Value.IsCompleted -eq $true)
                    {
                        #((get-variable -name ('Run_'+$job)).Value).EndInvoke((get-variable -name ('Job_'+$job)).Value)
                        ((get-variable -name ('Run_'+$job)).Value).Dispose()
                        Remove-Variable -Name ('Run_'+$job) -Scope Script -Force
                        Remove-Variable -Name ('Job_'+$job) -Scope Script -Force
                    }
            }
        }
        <# Function to create the Label of Version #>
        Function Set-ARIDiagramLabel {
            $Date = get-date -Format "yyyy-MM-dd_HH_mm"
            $Script:XmlWriter.WriteStartElement('object')            
            $Script:XmlWriter.WriteAttributeString('label', ('Powered by:'+ "`n" +'Azure Resource Inventory v3.6'+ "`n" +'https://github.com/microsoft/ARI' + "`n" +'Date:' + "`n" + $Date))
            $Script:XmlWriter.WriteAttributeString('author', 'Claudio Merola')
            $Script:XmlWriter.WriteAttributeString('id', ($Script:CellID+'-'+($Script:IDNum++)))
        }

        Function Get-ARIDiagramJobLog {
            Param($JobNames)

            Foreach ($JobName in $JobNames)
                {
                    $LogEntries = Receive-Job -Name $JobName
                    Foreach ($LogEntry in $LogEntries)
                        {
                            Write-Output $LogEntry
                        }
                }
        }

        try
            {

                Write-Output ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Setting Subnet files')

                $Subnetfiles = Get-ChildItem -Path $DiagramCache

                $Subnetfiles = $Subnetfiles | Where-Object {$_.Name -notlike '*Organization.xml' -and $_.Name -notlike '*Subscriptions.xml'}

                foreach($SubFile in $Subnetfiles)
                    {
                        $LogSubFile = $SubFile.FullName
                        Write-Output ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Removing File: ' + $LogSubFile)
                        Remove-Item -Path $SubFile.FullName
                    }

                Write-Output ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Setting Variables')

                $Script:etag = -join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})
                $Script:DiagID = -join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})
                $Script:CellID = -join ((65..90) + (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_})

                $Script:IDNum = 0

                Write-Output ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Defining XML file')

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

                                Write-Output ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Calling Stensils')

                                    Publish-ARIDiagramStensils

                                    if($Job.AZLGWs -or $Job.AZEXPROUTEs -or $Job.AZVERs -or $Job.AZVPNSITES)
                                        {
                                            Write-Output ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Calling OnPremNet')

                                            Invoke-ARIDiagramOnPremNetwork
                                            if($FullEnvironment)
                                                {
                                                    Write-Output ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Calling as FullEnvironment')

                                                    Invoke-ARIDiagramFullEnvironment
                                                }
                                        }
                                    else
                                        {
                                            Write-Output ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Calling CloudOnly Function')
                                            Invoke-ARIDiagramCloudOnly
                                        }


                                $Script:XmlWriter.WriteEndElement()

                            $Script:XmlWriter.WriteEndElement()

                        $Script:XmlWriter.WriteEndElement()

                    $Script:XmlWriter.WriteEndDocument()
                    $Script:XmlWriter.Flush()
                    $Script:XmlWriter.Close()                

                    if (!$Automation.IsPresent)
                        {
                            Write-Output ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Waiting Job2 to complete')

                            Get-job -Name $Script:jobs | Wait-Job | Out-Null

                            Write-Output ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Getting Subnet Job Logs')

                            Get-ARIDiagramJobLog -JobNames $Script:jobs

                            Write-Output ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Removing Jobs')

                            Remove-ARIDiagramJob
                        }

                    $Subnetfiles = Get-ChildItem -Path $DiagramCache

                    $Subnetfiles = $Subnetfiles | Where-Object {$_.Name -notlike '*Organization.xml' -and $_.Name -notlike '*Subscriptions.xml'}

                    Write-Output ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Processing Subnet files')

                    foreach($SubFile in $Subnetfiles)
                        {
                            $newxml = [XML]::new()
                            $newxml.Load($SubFile.FullName)

                            $LogSubFile = $SubFile.FullName
                            Write-Output ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Processing Subnet File: ' + $LogSubFile)

                            $Innerxml = $newxml.mxfile.diagram.mxGraphModel.root.InnerXml

                            $Innerxml2 = $Innerxml.Replace('<mxCell id="0" /><mxCell id="1" parent="0" />','')

                            #force the config into an XML
                            $xml = [xml](get-content $DDFile)

                            $xmlFrag=$xml.CreateDocumentFragment()
                            $xmlFrag.InnerXml=$Innerxml2

                            $xml.mxfile.diagram.mxGraphModel.root.AppendChild($xmlFrag) | Out-Null

                            #save file
                            $xml.Save($DDFile)

                            Start-Sleep -Milliseconds 100

                            Write-Output ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Deleting Subnet File: ' + $LogSubFile)
                            Remove-Item -Path $SubFile.FullName

                            Start-Sleep -Milliseconds 100
                        }

                        Write-Output ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - End of Network Diagram')
            }
        catch
            {
                Write-Output ('DrawIONetwork - '+(get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - Error: ' + $_.Exception.Message)
            }
}