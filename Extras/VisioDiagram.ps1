<#
.Synopsis
Diagram Module for Microsoft Visio

.DESCRIPTION
This script process and creates a Visio Diagram based on resources present in the extraction variable $Resources. 

.Link
https://github.com/azureinventory/ARI/Extras/VisioDiagram.ps1

.COMPONENT
   This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 2.0.4
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

#>
param($Subscriptions, $Resources, $Advisories, $DFile)

<# Change this variable to $true to draw the full environment #>
#$Global:FullEnvironment = $true
$Global:FullEnvironment = $false

<# Function to populate the variables that are going to be used in the drawing #>
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
       
    <# Looking for the stencil files in the computer #>
    $Global:Diag = Get-ChildItem -Path "C:\Program Files\" -Name "AZUREDIAGRAMS_M.VSTX"  -Recurse
    if(!$Global:Diag)
    {
        $Global:Diag = Get-ChildItem -Path "C:\Program Files (x86)\" -Name "AZUREDIAGRAMS_M.VSTX" -Recurse
        $Global:Path = ('C:\Program Files (x86)\'+$Diag.Replace("AZUREDIAGRAMS_M.VSTX",""))
    }
    else
    {
        $Global:Path = ('C:\Program Files\'+$Diag.Replace("AZUREDIAGRAMS_M.VSTX",""))
    }

    <########################## Adding Stencils #############################>

    $Global:VSFileAzNet = ($Global:Path+"AZURENETWORKING_M.VSSX")
    $Global:VSFileAzGen = ($Global:Path+"AZUREGENERAL_M.VSSX")
    $Global:VSFileAzCom = ($Global:Path+"AZURECOMPUTE_M.VSSX")
    $Global:VSFileAzOth = ($Global:Path+"AZUREOTHER_M.VSSX")
    $Global:VSFileAzApp = ($Global:Path+"AZUREAPPSERVICES_M.VSSX")
    $Global:VSFileAzBrick = ($Global:Path+"AZUREBLOCKCHAIN_M.VSSX")
    $Global:VSFileAzStorage = ($Global:Path+"AZURESTORAGE_M.VSSX")
    $Global:VSFileSymbol = ($Global:Path+"SYMBOL_M.VSSX")
    $Global:VSFileData = ($Global:Path+"AZUREDATABASES_M.VSSX")
    $Global:AWSVSFileData = ($Global:Path+"AWSMGMTGOV_M.VSSX")
    #$Global:AZMGMTVSFileData = ($Global:Path+"AZUREMANAGEMENTGOVERNANCE_M.VSSX")

}


<# Function to create the Visio document and import each stencil #>
Function Visio 
{
    try
        {            
            <########################## Openning Visio and Creating Page #############################>

            $Global:application = New-Object -ComObject Visio.Application

            <# Variable to hide Visio #>
            $Global:application.Visible=$false

            $Global:documents = $Global:application.Documents
            $Global:document = $Global:documents.Add("")
            $Global:pages = $Global:application.ActiveDocument.Pages
            $Global:page = $Global:pages.Item(1)
            $Global:page.Name = 'Network'

            <########################## Selecting Stencils and Adding to Visio #############################>

            $Global:AzVnetSymbol = $application.Documents.Add($VSFileAzNet)
            $Global:AzGenSymbol = $application.Documents.Add($VSFileAzGen)
            $Global:ComputeSymbol = $application.Documents.Add($VSFileAzCom)
            $Global:OtherSymbol = $application.Documents.Add($VSFileAzOth)
            $Global:AppSymbol = $application.Documents.Add($VSFileAzApp)
            $Global:BrickSymbol = $application.Documents.Add($VSFileAzBrick)
            $Global:StorageSymbol = $application.Documents.Add($VSFileAzStorage)
            $Global:GenericSymbol = $application.Documents.Add($VSFileSymbol)
            $Global:DataSymbol = $application.Documents.Add($VSFileData)
            $Global:AWSMGMTGOVSymbol = $application.Documents.Add($AWSVSFileData)
            #$Global:AZMGMTGOVSymbol = $application.Documents.Add($AZMGMTVSFileData)

            
        }
        catch
        {Exit}

      try
            {
            <########################## Azure Networking Stencils #############################>

            $Global:IconConnections = $Global:AzVnetSymbol.Masters.Item("Connections")
            $Global:IconExpressRoute = $Global:AzVnetSymbol.Masters.Item("ExpressRoute Circuits")
            $Global:IconVGW = $Global:AzVnetSymbol.Masters.Item("Virtual Network Gateways")
            $Global:IconVNET = $Global:AzVnetSymbol.Masters.Item("Virtual Networks")
            $Global:IconTraffic = $Global:AzVnetSymbol.Masters.Item("Traffic Manager profiles")
            $Global:IconNIC = $Global:AzVnetSymbol.Masters.Item("Network Interfaces")
            $Global:IconLBs = $Global:AzVnetSymbol.Masters.Item("Load Balancers")
            $Global:IconPVTs = $Global:AzVnetSymbol.Masters.Item("Private Link")
            $Global:IconNSG = $Global:AzVnetSymbol.Masters.Item("Network Security Groups")
            $Global:IconUDR = $Global:AzVnetSymbol.Masters.Item("Route Filters")
            $Global:IconDDOS = $Global:AzVnetSymbol.Masters.Item("DDoS Protection Plans")
            $Global:IconPIP = $Global:AzVnetSymbol.Masters.Item("Public IP Addresses")            

            <########################## Azure Generic Stencils #############################>

            $Global:SymError = $Global:AzGenSymbol.Masters.Item("Error")
            $Global:SymInfo = $Global:AzGenSymbol.Masters.Item("Information")
            $Global:IconSubscription = $Global:AzGenSymbol.Masters.Item("Subscriptions")
            $Global:IconBastions = $Global:AzGenSymbol.Masters.Item("Launch Portal")
            $Global:IconContain = $Global:AzGenSymbol.Masters.Item("TFS VC Repository")
            $Global:IconVWAN = $Global:AzGenSymbol.Masters.Item("Branch")
            $Global:IconCostMGMT = $Global:AzGenSymbol.Masters.Item("Cost Analysis")

            <########################## Azure Computing Stencils #############################>

            $Global:IconVMs = $Global:ComputeSymbol.Masters.Item("Virtual Machine")
            $Global:IconAKS = $Global:ComputeSymbol.Masters.Item("Kubernetes Services")
            $Global:IconVMSS = $Global:ComputeSymbol.Masters.Item("VM Scale Sets")                                                         
            $Global:IconARO = $Global:ComputeSymbol.Masters.Item("Service Fabric Clusters")
            $Global:IconFunApps = $Global:ComputeSymbol.Masters.Item("Function Apps")

            <########################## Azure Service Stencils #############################>

            $Global:IconAPIMs = $Global:AppSymbol.Masters.Item("API Management Services")
            $Global:IconAPPs = $Global:AppSymbol.Masters.Item("App Services")                        

            <########################## Azure Storage Stencils #############################>

            $Global:IconNetApp = $Global:StorageSymbol.Masters.Item("Azure NetApp Files")

            <########################## Azure Storage Stencils #############################>

            $Global:IconDataExplorer = $Global:DataSymbol.Masters.Item("Azure Data Explorer Clusters")

            <########################## Other Stencils #############################>
            
            $Global:IconFWs = $Global:OtherSymbol.Masters.Item("Firewalls")
            $Global:IconDet = $Global:OtherSymbol.Masters.Item("Detonation")  
            $Global:IconAppGWs = $Global:OtherSymbol.Masters.Item("Application Gateways")
            #$Global:IconBricks = $Global:BrickSymbol.Masters.Item("Azure Blockchain Service")
            $Global:IconBricks = $Global:AWSMGMTGOVSymbol.Masters.Item("Stack")       
            $Global:IconError = $Global:GenericSymbol.Masters.Item('"NO" sign')
            #$Global:IconAdvisor = $Global:AZMGMTGOVSymbol.Masters.Item('Advisor')

        }
    catch
    {Exit}

}

<# Function to begin OnPrem environment drawing. Will begin by Local network Gateway, then Express Route.#>
Function OnPremNet {

    $Global:RoutsW = $AZVNETs | Select-Object -Property Name, @{N="Subnets";E={$_.properties.subnets.properties.addressPrefix.count}} | Sort-Object -Property Subnets -Descending

    Start-Sleep 1

    $Global:Alt = 2
    $charsize = "11"

    foreach($GTW in $AZLGWs)
        {
            $vvnet = $page.Drop($IconTraffic, 4.5, $Global:Alt) 
            if($GTW.properties.provisioningState -ne 'Succeeded')
            {
                $ErrorLC = $page.Drop($IconError, 5.35, ($Global:Alt+0.6))
                $ErrorLC.Characters.Text = ''
                $ErrorLC.Resize(1,-1.25,-1.25)
                $vvnet.Comments.Add([string]'This Local Network Gateway has Errors') | Out-Null
            }
        
            $Con1 = $AZCONs | Where-Object {$_.properties.localNetworkGateway2.id -eq $GTW.id}
            OnPrem $Con1
            if(!$Con1 -and $GTW.properties.provisioningState -eq 'Succeeded')
            {
                $InfoLC = $page.Drop($SymInfo, 4.3, ($Global:Alt-0.02))
                $InfoLC.Characters.Text = ''
                $InfoLC.Resize(1,-0.15,-0.15)
                $vvnet.Comments.Add([string]'No Connections were found in this Local Network Gateway') | Out-Null
            }
            $Global:Alt = $Global:Alt + 2
            $Name = $GTW.name
            $IP = $GTW.properties.gatewayIpAddress
            $vvnet.Characters.Text = ([string]$Name + "`n" + [string]$IP)
            $vvnet.Characters.CharProps(7) = $charsize
            $vvnet.Comments.Add('Local Network Address Space: '+[string]$GTW.properties.localNetworkAddressSpace.addressPrefixes) | Out-Null        
        }


    ##################################### ERS #############################################


    Foreach($ERs in $AZEXPROUTEs)
        {
            $vvnet = $page.Drop($IconExpressRoute, 4.5, $Global:Alt) 
            if($ERs.properties.provisioningState -ne 'Succeeded')
            {
                $ErrorLC = $page.Drop($IconError, 5.35, ($Global:Alt+0.6))
                $ErrorLC.Characters.Text = ''
                $ErrorLC.Resize(1,-1.25,-1.25)
                $vvnet.Comments.Add('This Express Route has Errors') | Out-Null
            }       

            $Con1 = $AZCONs | Where-Object {$_.properties.peer.id -eq $ERs.id}
            OnPrem $Con1
            if(!$Con1 -and $ERs.properties.circuitProvisioningState -eq 'Enabled')
            {
                $InfoLC = $page.Drop($SymInfo, 4.3, ($Global:Alt-0.02))
                $InfoLC.Characters.Text = ''
                $InfoLC.Resize(1,-0.15,-0.15)
                $vvnet.Comments.Add('No Connections were found in this Express Route') | Out-Null
            }
            $Global:Alt = $Global:Alt + 2
            $Name = $ERs.name
            $vvnet.Characters.Text = [string]$Name
            $vvnet.Characters.CharProps(7) = $charsize
            $vvnet.Comments.Add('Provider: '+[string]$ERs.properties.serviceProviderProperties.serviceProviderName + "`n" +
                                'Peering location: '+[string]$ERs.properties.serviceProviderProperties.peeringLocation + "`n" +
                                'Bandwidth: '+[string]$ERs.properties.serviceProviderProperties.bandwidthInMbps + "`n" +
                                'SKU: '+[string]$ERs.sku.tier + "`n" +
                                'Billing model: '+$ERs.sku.family) | Out-Null                   
        }


        Foreach($VWANS in $AZVWAN)
        {
            $vwan = $page.Drop($IconVWAN, 4.5, $Global:Alt) 
            if($VWANS.properties.provisioningState -ne 'Succeeded')
            {
                $ErrorLC = $page.Drop($IconError, 5.35, ($Global:Alt+0.6))
                $ErrorLC.Characters.Text = ''
                $ErrorLC.Resize(1,-1.25,-1.25)
                $vvnet.Comments.Add('This Virtual WAN has Errors') | Out-Null
            }       

            <#
            $Con1 = $AZCONs | Where-Object {$_.properties.peer.id -eq $ERs.id}
            OnPrem $Con1
            if(!$Con1 -and $ERs.properties.circuitProvisioningState -eq 'Enabled')
            {
                $InfoLC = $page.Drop($SymInfo, 4.3, ($Global:Alt-0.02))
                $InfoLC.Characters.Text = ''
                $InfoLC.Resize(1,-0.15,-0.15)
                $vvnet.Comments.Add('No Connections were found in this Express Route') | Out-Null
            }
            #>
            $Global:Alt = $Global:Alt + 2
            $Name = $VWANS.name
            $vwan.Characters.Text = [string]$Name
            $vwan.Characters.CharProps(7) = $charsize
            $vwan.Comments.Add('Allow BranchToBranch Traffic: '+[string]$VWANS.properties.allowBranchToBranchTraffic + "`n" +
                                'Allow VnetToVnet Traffic: '+[string]$VWANS.properties.allowVnetToVnetTraffic) | Out-Null                   
        }

        if(!$Global:FullEnvironment)
            {
                $Background = $global:page.DrawRectangle(-15,-15, (($RoutsW.Subnets[0]*1.5) +30), (($Global:Alt)+20))
                $Background.SendToBack()

                $OnPrem = $page.DrawRectangle(-2, 1, 5, $Global:Alt)
                $OnPrem.SendToBack()
                $OnPrem.BringForward() 
                $OnPrem.Characters.Text = 'On-Premises Environment'
                #$OnPrem.Characters.CharProps(1) = 2
                $OnPrem.Characters.CharProps(2) = "&H1"
                $OnPrem.Characters.CharProps(7) = "60"
            }

}


<# Function for drawing OnPrem Environments for each connection. if using this function, not every single VNET will be present. #>
Function OnPrem 
{
Param($Con1)
$charsize = "11"
foreach ($Con2 in $Con1)
        {
            $Global:vnetLoc = 10.3
            $VGT = $AZVGWs | Where-Object {$_.id -eq $Con2.properties.virtualNetworkGateway1.id}
            $VGTPIP = $PIPs | Where-Object {$_.properties.ipConfiguration.id -eq $VGT.properties.ipConfigurations.id}
            $Conn = $page.Drop($IconConnections, 6, $Global:Alt)
            $Name2 = $Con2.Name
            $Conn.Characters.Text = [string]$Name2
            $Conn.Characters.CharProps(7) = $charsize
            $Conn.Comments.Add('Connection Type: '+[string]$Con2.properties.connectionType  + "`n" +
                                'Use Azure Private IP Address: '+[string]$Con2.properties.useLocalAzureIpAddress + "`n" +
                                'Routing Weight: '+[string]$Con2.properties.routingWeight + "`n" +
                                'Connection Protocol: '+[string]$Con2.properties.connectionProtocol + "`n" +
                                'Connection Type: '+[string]$Con2.properties.connectionType) | Out-Null
            $vvnet.AutoConnect($Conn,0)

            $vpngt = $page.Drop($IconVGW, 8, $Global:Alt)
            $vpngt.Characters.Text = ([string]$VGT.Name + "`n" + [string]$VGTPIP.properties.ipAddress)
            $vpngt.Characters.CharProps(7) = $charsize
            $vpngt.Comments.Add('VPN Type: '+[string]$VGT.properties.vpnType + "`n" +
                                'Generation: '+[string]$VGT.properties.vpnGatewayGeneration + "`n" +
                                'SKU: '+[string]$VGT.properties.sku.name + "`n" +
                                'Gateway Type: '+[string]$VGT.properties.gatewayType + "`n" +
                                'Active-active mode: '+[string]$VGT.properties.activeActive + "`n" +
                                'Gateway Private IPs: '+[string]$VGT.properties.enablePrivateIpAddress) | Out-Null
            $Conn.AutoConnect($vpngt,0)

            foreach($AZVNETs2 in $AZVNETs)
            {
                foreach($VNETTEMP in $AZVNETs2.properties.subnets.properties.ipconfigurations.id)
                {
                    $VV4 = $VNETTEMP.Split("/")
                    $VNETTEMP1 = ($VV4[0] + '/' + $VV4[1] + '/' + $VV4[2] + '/' + $VV4[3] + '/' + $VV4[4] + '/' + $VV4[5] + '/' + $VV4[6] + '/' + $VV4[7]+ '/' + $VV4[8])
                    if($VNETTEMP1 -eq $VGT.id)
                    {
                        $Global:VNET2 = $AZVNETs2

                        $Global:VNETsD = $page.Shapes | Where-Object {$_.name -like 'Virtual Networks*'}
                        $Global:Alt0 = $Global:Alt
                        if(($VNET2.name + "`n" + $VNET2.properties.addressSpace.addressPrefixes) -notin $VNETsD.text)
                            {
                                $Global:vpnnet = $page.Drop($IconVNET, 10, $Global:Alt)
                                if($VNET2.properties.addressSpace.addressPrefixes.count -ge 10){$AddSpace = ($VNET2.properties.addressSpace.addressPrefixes | Select-Object -First 20)+ "`n" +'...'}Else{$AddSpace = $VNET2.properties.addressSpace.addressPrefixes}
                                $Global:vpnnet.Characters.Text = ([string]$VNET2.Name + "`n" + $AddSpace)
                                $Global:vpnnet.Characters.CharProps(7) = $charsize
                                if($VNET2.properties.enableDdosProtection -eq $true)
                                    {
                                        $ddos = $page.Drop($IconDDOS, 9.9, $Global:Alt)
                                        $ddos.Characters.Text = ''
                                        $ddos.Resize(1,-0.3,-0.3)
                                    }
                                if($VNET2.properties.dhcpoptions.dnsServers)
                                    {
                                        $Global:vpnnet.Comments.Add('Custom DNS Servers: '+[string]$VNET2.properties.dhcpoptions.dnsServers + "`n" +
                                                            'DDOS Protection: '+[string]$VNET2.properties.enableDdosProtection) | Out-Null
                                    }
                                else
                                    {
                                        $Global:vpnnet.Comments.Add('DDOS Protection: '+[string]$VNET2.properties.enableDdosProtection) | Out-Null
                                    }

                                $vpngt.AutoConnect($vpnnet,0)
                                                    
                                if($VNET2.properties.virtualNetworkPeerings.properties.remoteVirtualNetwork.id)
                                    {
                                        PeerCreator $Global:VNET2
                                    }                                
                            VNETCreator $Global:VNET2
                            }
                        else
                            {
                                $VNETDID = $VNETsD | Where-Object {$_.Characters.Text -eq ($Global:VNET2.name + "`n" + $Global:VNET2.properties.addressSpace.addressPrefixes)}
                                $vpngt.AutoConnect($VNETDID,0)
                                $Global:Conn2.Cells('BeginArrow')=4
                                $Global:Conn2.Cells('EndArrow')=4
                            }
                    }
                }
            }
            if($Con1.count -gt 1)
            {
               $Global:Alt ++
            }
        }

}



<# Function for Cloud Only Environments #>
Function CloudOnly 
{
$Global:RoutsW = $AZVNETs | Select-Object -Property Name, @{N="Subnets";E={$_.properties.subnets.properties.addressPrefix.count}} | Sort-Object -Property Subnets -Descending

$Global:vnetLoc = 10.3
$Global:Alt = 2
$charsize = "11"
    foreach($AZVNETs2 in $AZVNETs)
        {             
            $Global:VNET2 = $AZVNETs2

            $VNETsD = $page.Shapes | Where-Object {$_.name -like 'Virtual Networks*'}
            $Global:Alt0 = $Global:Alt
            if(($VNET2.name + "`n" + $VNET2.properties.addressSpace.addressPrefixes) -notin $VNETsD.text)
                {
                    $vpnnet = $page.Drop($IconVNET, 10, $Global:Alt)
                    if($VNET2.properties.addressSpace.addressPrefixes.count -ge 10){$AddSpace = ($VNET2.properties.addressSpace.addressPrefixes | Select-Object -First 20)+ "`n" +'...'}Else{$AddSpace = $VNET2.properties.addressSpace.addressPrefixes}
                    $vpnnet.Characters.Text = ([string]$VNET2.Name + "`n" + $AddSpace)
                    $vpnnet.Characters.CharProps(7) = $charsize
                    if($VNET2.properties.enableDdosProtection -eq $true)
                        {
                            $ddos = $page.Drop($IconDDOS, 9.9, $Global:Alt)
                            $ddos.Characters.Text = ''
                            $ddos.Resize(1,-0.3,-0.3)
                        }
                    if($VNET2.properties.dhcpoptions.dnsServers)
                        {
                            $vpnnet.Comments.Add('Custom DNS Servers: '+[string]$VNET2.properties.dhcpoptions.dnsServers + "`n" +
                                                'DDOS Protection: '+[string]$VNET2.properties.enableDdosProtection) | Out-Null
                        }
                    else
                        {
                            $vpnnet.Comments.Add('DDOS Protection: '+[string]$VNET2.properties.enableDdosProtection) | Out-Null
                        }
                                                    
                    if($VNET2.properties.virtualNetworkPeerings.properties.remoteVirtualNetwork.id)
                        {
                            PeerCreator $Global:VNET2
                        }                                
                VNETCreator $Global:VNET2
                }
                $Global:Alt ++
                $Global:Alt ++
            }

    $Background = $global:page.DrawRectangle(-15,-15, (($RoutsW.Subnets[0]*1.5) +30), (($Global:Alt)+20))
    $Background.SendToBack()

}


Function FullEnvironment 
{

$charsize = "11"
    foreach($AZVNETs2 in $AZVNETs)
        {             
            $Global:VNET2 = $AZVNETs2

            $VNETsD = $page.Shapes | Where-Object {$_.name -like 'Virtual Networks*'}
            $Global:Alt0 = $Global:Alt
            if(($VNET2.name + "`n" + $VNET2.properties.addressSpace.addressPrefixes) -notin $VNETsD.text)
                {
                    $vpnnet = $page.Drop($IconVNET, 10, $Global:Alt)
                    if($VNET2.properties.addressSpace.addressPrefixes.count -ge 10){$AddSpace = ($VNET2.properties.addressSpace.addressPrefixes | Select-Object -First 20)+ "`n" +'...'}Else{$AddSpace = $VNET2.properties.addressSpace.addressPrefixes}
                    $vpnnet.Characters.Text = ([string]$VNET2.Name + "`n" + $AddSpace)
                    $vpnnet.Characters.CharProps(7) = $charsize
                    if($VNET2.properties.enableDdosProtection -eq $true)
                        {
                            $ddos = $page.Drop($IconDDOS, 9.9, $Global:Alt)
                            $ddos.Characters.Text = ''
                            $ddos.Resize(1,-0.3,-0.3)
                        }
                    if($VNET2.properties.dhcpoptions.dnsServers)
                        {
                            $vpnnet.Comments.Add('Custom DNS Servers: '+[string]$VNET2.properties.dhcpoptions.dnsServers + "`n" +
                                                'DDOS Protection: '+[string]$VNET2.properties.enableDdosProtection) | Out-Null
                        }
                    else
                        {
                            $vpnnet.Comments.Add('DDOS Protection: '+[string]$VNET2.properties.enableDdosProtection) | Out-Null
                        }
                                                    
                    if($VNET2.properties.virtualNetworkPeerings.properties.remoteVirtualNetwork.id)
                        {
                            PeerCreator $Global:VNET2
                        }                                
                VNETCreator $Global:VNET2
                }
                $Global:Alt ++
                $Global:Alt ++
            }

            $Background = $global:page.DrawRectangle(-15,-15, (($RoutsW.Subnets[0]*1.5) +30), (($Global:Alt)+20))
            $Background.SendToBack()

            $OnPrem = $page.DrawRectangle(-2, 1, 5, $Global:Alt)
            $OnPrem.SendToBack()
            $OnPrem.BringForward() 
            $OnPrem.Characters.Text = 'On-Premises Environment'
            #$OnPrem.Characters.CharProps(1) = 2
            $OnPrem.Characters.CharProps(2) = "&H1"
            $OnPrem.Characters.CharProps(7) = "60"

}


<# Function for create peered VNETs #>
Function PeerCreator
{
Param($VNET2)
    $charsize = "10"
    $PeerCount = ($VNET2.properties.virtualNetworkPeerings.properties.remoteVirtualNetwork.id.count + 10.3)
    $Global:vnetLoc1 = $Global:Alt
                                       
    if($VNET2.properties.subnets.properties.addressPrefix.count -gt 5)
        {
            $Global:vnetLoc1 = $Global:vnetLoc1 + 5
        }
        else
        {
            $Global:vnetLoc1 = $Global:vnetLoc1 + 3
        }

    Foreach ($Peer in $VNET2.properties.virtualNetworkPeerings)
        {
            $VNETSUB = $AZVNETs | Where-Object {$_.id -eq $Peer.properties.remoteVirtualNetwork.id}                                                

            if(($VNETSUB.name + "`n" + $VNETSUB.properties.addressSpace.addressPrefixes) -in $VNETsD.text)
                {
                    $VNETDID = $VNETsD | Where-Object {$_.Characters.Text -eq ($VNETSUB.name + "`n" + $VNETSUB.properties.addressSpace.addressPrefixes)}
                    $vpnnet.AutoConnect($VNETDID,0)
                    $Global:Conn2 = $page.Shapes | Where-Object {$_.name -like 'Dynamic connector*'} | select-object -Last 1
                    $Global:Conn2.Characters.Text = $Peer.name
                    $Global:Conn2.Characters.CharProps(7) = $charsize
                    $Global:Conn2.Characters.CharProps(17) = "50"
                    $Global:Conn2.Cells('BeginArrow')=4
                    $Global:Conn2.Cells('EndArrow')=4
                }
            else
            {
                $Global:sizeL =  $VNETSUB.properties.subnets.properties.addressPrefix.count   
                                                                                                                                    
                $Global:vnetLoc = 12
                                                     
                $netpeer = $page.Drop($IconVNET, $Global:vnetLoc, $Global:vnetLoc1)                                            
                $netpeer.AutoConnect($vpnnet,0)
                $Conn1 = $page.Shapes | Where-Object {$_.name -like 'Dynamic connector*'} | select-object -Last 1
                $Conn1.Characters.Text = $Peer.name
                $Conn1.Characters.CharProps(7) = $charsize
                $Conn1.Characters.CharProps(17) = "50"
                $Conn1.Cells('BeginArrow')=4
                $Conn1.Cells('EndArrow')=4                                    
                                            
                $netpeer.Characters.Text = ($VNETSUB.name + "`n" + $VNETSUB.properties.addressSpace.addressPrefixes)
                $netpeer.Characters.CharProps(7) = $charsize

                if($VNETSUB.properties.enableDdosProtection -eq $true)
                    {
                        $ddos = $page.Drop($IconDDOS, ($Global:vnetLoc-0.1), $Global:vnetLoc1)
                        $ddos.Characters.Text = ''
                        $ddos.Resize(1,-0.3,-0.3)
                    }
                if($VNETSUB.properties.dhcpoptions.dnsServers)
                    {
                        $netpeer.Comments.Add('Custom DNS Servers: '+[string]$VNETSUB.properties.dhcpoptions.dnsServers + "`n" +
                                            'DDOS Protection: '+[string]$VNETSUB.properties.enableDdosProtection) | Out-Null
                    }
                else
                    {
                        $netpeer.Comments.Add('DDOS Protection: '+[string]$VNETSUB.properties.enableDdosProtection) | Out-Null
                    }
                                                            
                                                
                if ($Global:sizeL -gt 5)
                    {
                        $Global:sizeL = $Global:sizeL / 2
                        $Global:sizeL = [math]::ceiling($Global:sizeL)
                        $Global:sizeC = $Global:sizeL
                        $Global:sizeL = ($Global:sizeL*1.5)+(12+0.7)
                        $vnetbox = $page.DrawRectangle((12+0.5), ($Global:vnetLoc1 - 0.5), $Global:sizeL, ($Global:vnetLoc1 + 3.3))                                                                                                                      

                        $SubIcon = $page.Drop($IconSubscription, ($Global:sizeL), ($Global:vnetLoc1-0.6))
                        $SubName = $Subscriptions | Where-Object {$_.id -eq $VNETSUB.subscriptionId}
                        $SubIcon.Characters.Text = $SubName.name
                        $SubIcon.Characters.CharProps(7) = $charsize
                                                
                        $Global:subloc0 = (12+0.6)
                        $Global:SubC = 0
                        $Global:VNETPIP = @()
                        foreach($Sub in $VNETSUB.properties.subnets)
                            {
                                if ($Global:SubC -eq $Global:sizeC) 
                                    {
                                        $Global:vnetLoc1 = $Global:vnetLoc1 + 1.7                                         
                                        $Global:subloc0 = (12+0.6)
                                        $Global:SubC = 0
                                    }
                                $vsubnetbox = $page.DrawRectangle($Global:subloc0, ($Global:vnetLoc1 - 0.3), ($Global:subloc0 + 1.5), ($Global:vnetLoc1 + 1.3))
                                $vsubnetbox.Characters.Text = ("`n" + "`n" +"`n" + "`n" + "`n" + "`n" + "`n" + [string]$sub.Name + "`n" + [string]$sub.properties.addressPrefix)
                                $vsubnetbox.Characters.CharProps(7) = $charsize
                                                                    
                                ProcType $sub $Global:subloc0 $Global:vnetLoc1
                                                                    
                                $Global:subloc0 = $Global:subloc0 + 1.5
                                $Global:SubC ++

                            }
                        
                        if($Global:VNETPIP)
                            {
                                $SubIcon = $page.Drop($IconDet, ($subloc0+5), ($vnetLoc1-0.5))
                                $SubIcon.Characters.Text = ''
                                $SubIcon.Comments.Add('Public IPs: '+([string]$Global:VNETPIP.Name | ForEach-Object {$_ + ', '})) | Out-Null
                                $SubIcon.AutoConnect($vnetbox,0)
                            }                            
                                                                                            
                    }
                else
                    {
                        $Global:sizeL = ($Global:sizeL*1.5)+(12+0.7)
                        $vnetbox = $page.DrawRectangle((12+0.5), ($Global:vnetLoc1 - 0.5), $Global:sizeL, ($Global:vnetLoc1 + 1.6))

                        $SubIcon = $page.Drop($IconSubscription, ($Global:sizeL), ($Global:vnetLoc1-0.6))
                        $SubName = $Subscriptions | Where-Object {$_.id -eq $VNETSUB.subscriptionId}
                        $SubIcon.Characters.Text = $SubName.name
                        $SubIcon.Characters.CharProps(7) = $charsize

                        $Global:subloc0 = (12+0.6)
                        $Global:VNETPIP = @()
                        foreach($sub in $VNETSUB.properties.subnets)
                            {
                                $vsubnetbox = $page.DrawRectangle($Global:subloc0, ($Global:vnetLoc1 - 0.3), ($Global:subloc0 + 1.5), ($Global:vnetLoc1 + 1.3))
                                $vsubnetbox.Characters.Text = ("`n" + "`n" + "`n" + "`n" + "`n" + "`n" + "`n" +[string]$sub.Name + "`n" + [string]$sub.properties.addressPrefix)
                                $vsubnetbox.Characters.CharProps(7) = $charsize

                                ProcType $sub $Global:subloc0 $Global:vnetLoc1

                                $Global:subloc0 = $Global:subloc0 + 1.5
                            }

                        if($Global:VNETPIP)
                            {
                                $SubIcon = $page.Drop($IconDet, ($subloc0+5), ($vnetLoc1+0.7))
                                $SubIcon.Characters.Text = ''
                                $SubIcon.Comments.Add('Public IPs: '+([string]$Global:VNETPIP.Name | ForEach-Object {$_ + ', '})) | Out-Null
                                $SubIcon.AutoConnect($vnetbox,0)
                            }

                    }
                $Global:vnetLoc1 = $Global:vnetLoc1 + 3                                          
            }
        }
    $Global:Alt = $Global:vnetLoc1
}


<# Function for VNET creation #>
Function VNETCreator
{
Param($VNET2)
        $charsize = "10"
        $Global:sizeL =  $VNET2.properties.subnets.properties.addressPrefix.count
        $Global:VNETsD = $page.Shapes | Where-Object {$_.name -like 'Virtual Networks*'}
        if(($VNET2.name + "`n" + $VNET2.properties.addressSpace.addressPrefixes) -in $VNETsD.text)
            {
                $VNETDID = $VNETsD | Where-Object {$_.Characters.Text -eq ($VNET2.name + "`n" + $VNET2.properties.addressSpace.addressPrefixes)}
                $Global:vpnnet.AutoConnect($VNETDID,0)
                $ConnTemp = $page.Shapes | Where-Object {$_.name -like 'Dynamic connector*'} | select-object -Last 1
                $ConnTemp.Characters.Text = $Peer.name
                $ConnTemp.Characters.CharProps(7) = $charsize
                $ConnTemp.Characters.CharProps(17) = "50"
                $ConnTemp.Cells('BeginArrow')=4
                $ConnTemp.Cells('EndArrow')=4
            }
            else 
            {                            
                if ($Global:sizeL -gt 5)
                {
                    $Global:sizeL = $Global:sizeL / 2
                    $Global:sizeL = [math]::ceiling($Global:sizeL)
                    $Global:sizeC = $Global:sizeL
                    $Global:sizeL = ($Global:sizeL*1.5)+($Global:vnetLoc + 0.7)
                    $vnetbox = $page.DrawRectangle(($Global:vnetLoc+0.5), ($Global:Alt0 - 0.5), $Global:sizeL, ($Global:Alt0 + 3.3))

                    $SubIcon = $page.Drop($IconSubscription, ($Global:sizeL), ($Global:Alt0-0.6))
                    $SubName = $Subscriptions | Where-Object {$_.id -eq $VNET2.subscriptionId}
                    $SubIcon.Characters.Text = $SubName.name
                    $SubIcon.Characters.CharProps(7) = $charsize

                    $ADVS = ''
                    $ADVS = $Advisories | Where-Object {$_.Properties.Category -eq 'Cost' -and $_.Properties.resourceMetadata.resourceId -eq ('/subscriptions/'+$SubName.id)}
                    If($ADVS)
                        {
                            $SubIcon = $page.Drop($IconCostMGMT, ($Global:sizeL+0.5), ($Global:Alt0-0.6))
                            $SubIcon.Resize(1,-0.25,-0.25)
                            $SubIcon.Characters.Text = ''
                            foreach ($ADV in $ADVS)
                                {
                                    $SubIcon.Comments.Add('Recommendation: '+ [string]$ADV.Properties.shortDescription.solution + "`n" + 
                                                        'Resources: '+ [string]$ADV.Properties.extendedProperties.targetResourceCount + "`n" + 
                                                        'Currency: '+ [string]$ADV.properties.extendedProperties.savingsCurrency+ "`n" + 
                                                        'Annual Savings: '+[string]$ADV.properties.extendedProperties.annualSavingsAmount) | Out-Null
                                } 
                        }

                    $Global:subloc = ($Global:vnetLoc+0.6)
                    $Global:SubC = 0
                    $Global:VNETPIP = @()
                    foreach($Sub in $VNET2.properties.subnets)
                    {
                        if ($Global:SubC -eq $Global:sizeC) 
                        {
                            $Global:Alt0 = $Global:Alt0 + 1.7
                            $Global:subloc = ($Global:vnetLoc+0.6)
                            $Global:SubC = 0
                        }
                        $vsubnetbox = $page.DrawRectangle($Global:subloc, ($Global:Alt0 - 0.3), ($Global:subloc + 1.5), ($Global:Alt0 + 1.3))
                        $vsubnetbox.Characters.Text = ("`n" + "`n" + "`n" + "`n" + "`n" + "`n" + "`n" + [string]$sub.Name + "`n" + [string]$sub.properties.addressPrefix)
                        $vsubnetbox.Characters.CharProps(7) = $charsize
                        
                        ProcType $sub $Global:subloc $Global:Alt0                

                        $Global:subloc = $Global:subloc + 1.5
                        $Global:SubC ++
                    }

                    if($Global:VNETPIP)
                        {
                            $SubIcon = $page.Drop($IconDet, ($subloc+5), ($Alt0-0.5))
                            $SubIcon.Characters.Text = ''
                            $SubIcon.Comments.Add('Public IPs: '+([string]$Global:VNETPIP.Name | ForEach-Object {$_ + ', '})) | Out-Null
                            $SubIcon.AutoConnect($vnetbox,0)
                        }

                }
                else
                {
                    $Global:sizeL = ($Global:sizeL*1.5)+($Global:vnetLoc + 0.7)
                    $vnetbox = $page.DrawRectangle(($Global:vnetLoc+0.5), ($Global:Alt0 - 0.5), $Global:sizeL, ($Global:Alt0 + 1.6))

                    $SubIcon = $page.Drop($IconSubscription, ($Global:sizeL), ($Global:Alt0-0.6))
                    $SubName = $Subscriptions | Where-Object {$_.id -eq $VNET2.subscriptionId}
                    $SubIcon.Characters.Text = $SubName.name
                    $SubIcon.Characters.CharProps(7) = $charsize

                    $ADVS = ''
                    $ADVS = $Advisories | Where-Object {$_.Properties.Category -eq 'Cost' -and $_.Properties.resourceMetadata.resourceId -eq ('/subscriptions/'+$SubName.id)}
                    If($ADVS)
                        {
                            $SubIcon = $page.Drop($IconCostMGMT, ($Global:sizeL+0.5), ($Global:Alt0-0.6))
                            $SubIcon.Resize(1,-0.25,-0.25)
                            $SubIcon.Characters.Text = ''
                            foreach ($ADV in $ADVS)
                                {
                                    $SubIcon.Comments.Add('Recommendation: '+ [string]$ADV.Properties.shortDescription.solution + "`n" + 
                                                        'Resources: '+ [string]$ADV.Properties.extendedProperties.targetResourceCount + "`n" + 
                                                        'Currency: '+ [string]$ADV.properties.extendedProperties.savingsCurrency+ "`n" + 
                                                        'Annual Savings: '+[string]$ADV.properties.extendedProperties.annualSavingsAmount) | Out-Null
                                } 
                        }

                    $Global:subloc = ($Global:vnetLoc+0.6)
                    $Global:VNETPIP = @()
                    foreach($Sub in $VNET2.properties.subnets)
                    {
                        $vsubnetbox = $page.DrawRectangle($Global:subloc, ($Global:Alt0 - 0.3), ($Global:subloc + 1.5), ($Global:Alt0 + 1.3))
                        $vsubnetbox.Characters.Text = ("`n" + "`n" + "`n" + "`n" + "`n" + "`n" + "`n" +[string]$sub.Name + "`n" + [string]$sub.properties.addressPrefix)
                        $vsubnetbox.Characters.CharProps(7) = $charsize
                        
                        ProcType $sub $Global:subloc $Global:Alt0                

                        $Global:subloc = $Global:subloc + 1.5
                    }

                    if($Global:VNETPIP)
                        {
                            $SubIcon = $page.Drop($IconDet, ($subloc+5), ($Alt0+0.7))
                            $SubIcon.Characters.Text = ''
                            $SubIcon.Comments.Add('Public IPs: '+([string]$Global:VNETPIP.Name | ForEach-Object {$_ + ', '})) | Out-Null
                            $SubIcon.AutoConnect($vnetbox,0)
                        }
                }
            }
        $Global:Alt ++
}


Function ProcType 
{
Param($sub,$subloc,$Alt0)
    $charsize = "9"    
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
                                $SubIcon = $page.Drop($IconVMs, ($subloc+0.75), ($Alt0+0.8))
                                if($RESNames.count -gt 1)
                                    {
                                        $SubIcon.Characters.Text = ([string]$RESNames.Count + ' VMs')
                                        $SubIcon.Characters.CharProps(7) = $charsize
                                        $SubIcon.Comments.Add(($RESNames.Name | ForEach-Object {$_ + ', '})) | Out-Null
                                    }
                                else
                                    {
                                        $SubIcon.Characters.Text = ([string]$RESNames.Name)
                                        $SubIcon.Characters.CharProps(7) = $charsize
                                        $SubIcon.Comments.Add('VM Size: '+ [string]$RESNames.properties.hardwareProfile.vmSize + "`n" + 
                                                              'O.S: '+ [string]$RESNames.properties.storageProfile.osDisk.osType + "`n" + 
                                                              'O.S Disk Size (GB): '+ [string]$RESNames.properties.storageProfile.osDisk.diskSizeGB + "`n" + 
                                                              'Image Publisher: '+ [string]$RESNames.properties.storageProfile.imageReference.publisher + "`n" + 
                                                              'Image SKU: '+ [string]$RESNames.properties.storageProfile.imageReference.sku) | Out-Null
                                    }                                                                                                                                    
                                }
            'AKS' {                                                
                                $SubIcon = $page.Drop($IconAKS, ($subloc+0.75), ($Alt0+0.8))
                                if($RESNames.count -gt 1)
                                    {
                                        $SubIcon.Characters.Text = ([string]$RESNames.count + ' AKS Clusters') 
                                        $SubIcon.Characters.CharProps(7) = $charsize
                                        $SubIcon.Comments.Add(($RESNames.name | ForEach-Object {$_ + ', '})) | Out-Null
                                    }
                                else 
                                    {
                                        $SubIcon.Characters.Text = ([string]$RESNames.name) 
                                        $SubIcon.Characters.CharProps(7) = $charsize
                                        foreach($Pool in $RESNames.properties.agentPoolProfiles)
                                            {
                                                $SubIcon.Comments.Add('Node Pool Name: '+ [string]$Pool.name + "`n" + 
                                                                      'Nodes: '+ [string]($Pool | Select-Object -Property 'count').count + "`n" + 
                                                                      'Node Size: '+[string]$Pool.vmSize + "`n" + 
                                                                      'Node Pool Version: '+[string]$Pool.orchestratorVersion + "`n" + 
                                                                      'Node Pool Mode: '+[string]$Pool.mode + "`n" + 
                                                                      'Node Pool Max Pods: '+[string]$Pool.maxPods) | Out-Null
                                            }
                                        }
                                }
            'virtualMachineScaleSets' {                                                    
                                $SubIcon = $page.Drop($IconVMSS, ($subloc+0.75), ($Alt0+0.8))                                
                                if($RESNames -gt 1)
                                    {
                                        $SubIcon.Characters.Text = ([string]$RESNames.count+ 'Virtual Machine Scale Sets')
                                        $SubIcon.Characters.CharProps(7) = $charsize
                                        $SubIcon.Comments.Add(($RESNames.Name | ForEach-Object {$_ + ', '})) | Out-Null
                                    }
                                else
                                    {
                                        $SubIcon.Characters.Text = ([string]$RESNames.name)
                                        $SubIcon.Characters.CharProps(7) = $charsize
                                        $SubIcon.Comments.Add('VMSS Name: '+ [string]$RESNames.name + "`n" +
                                                              'Instances: '+ [string]$temp[0].Count + "`n" + 
                                                              'VMSS SKU Tier: '+ [string]$RESNames.sku.tier + "`n" + 
                                                              'VMSS Upgrade Policy: '+ [string]$RESNames.Properties.upgradePolicy.mode) | Out-Null 
                                    }                                                                        
                                } 
            'loadBalancers' {                                                    
                                $SubIcon = $page.Drop($IconLBs, ($subloc+0.75), ($Alt0+0.8))
                                if($RESNames.count -gt 1)
                                    {
                                        $SubIcon.Characters.Text = ([string]$RESNames.count + ' Load Balancers')
                                        $SubIcon.Characters.CharProps(7) = $charsize
                                        foreach($LB in $RESNames)
                                            {
                                                $SubIcon.Comments.Add('Load Balancer Name: '+ [string]$LB.name + "`n" + 
                                                                      'Load Balancer SKU: '+ [string]$LB.sku.name + "`n" + 
                                                                      'Backends: '+ [string]$LB.properties.backendAddressPools.properties.backendIPConfigurations.id.count + "`n" + 
                                                                      'Frontends: '+ [string]$LB.properties.frontendIPConfigurations.properties.count + "`n" + 
                                                                      'LB Rules: '+ [string]$LB.properties.loadBalancingRules.count + "`n" + 
                                                                      'Probes: '+ [string]$LB.properties.probes.count) | Out-Null
                                            }
                                    }
                                else 
                                    {                                    
                                        $SubIcon.Characters.Text = ([string]$RESNames.Name)
                                        $SubIcon.Characters.CharProps(7) = $charsize
                                        $SubIcon.Comments.Add('Load Balancer Name: '+ [string]$RESNames.Name + "`n" +
                                                              'Load Balancer SKU: '+ [string]$RESNames.sku.name + "`n" + 
                                                              'Backends: '+ [string]$RESNames.properties.backendAddressPools.properties.backendIPConfigurations.id.count + "`n" + 
                                                              'Frontends: '+ [string]$RESNames.properties.frontendIPConfigurations.properties.count + "`n" + 
                                                              'LB Rules: '+ [string]$RESNames.properties.loadBalancingRules.count + "`n" + 
                                                              'Probes: '+ [string]$RESNames.properties.probes.count) | Out-Null
                                    }
                                } 
            'virtualNetworkGateways' {                                                    
                                $SubIcon = $page.Drop($IconVGW, ($subloc+0.75), ($Alt0+0.8))
                                if($RESNames.count -gt 1)
                                    {
                                        $SubIcon.Characters.Text = ([string]$RESNames.Count + ' Virtual Network Gateways')
                                        $SubIcon.Characters.CharProps(7) = $charsize
                                        $SubIcon.Comments.Add(($RESNames.Name | ForEach-Object {$_ + ', '})) | Out-Null
                                    }
                                else
                                    {
                                        $SubIcon.Characters.Text = ([string]$RESNames.Name)
                                        $SubIcon.Characters.CharProps(7) = $charsize
                                    }                                                                                                         
                                } 
            'azureFirewalls' {                                                    
                                $SubIcon = $page.Drop($IconFWs, ($subloc+0.75), ($Alt0+0.8))
                                if($RESNames.count -gt 1)
                                    {
                                        $SubIcon.Characters.Text = ([string]$RESNames.count + ' Firewalls')
                                        $SubIcon.Characters.CharProps(7) = $charsize
                                        foreach($FW in $RESNames)
                                            {
                                                $SubIcon.Comments.Add('Firewall Name: '+ [string]$FW.Name + "`n" + 
                                                                    'SKU Tier: '+ [string]$FW.properties.sku.tier + "`n" + 
                                                                    'Threat Intel Mode: '+ [string]$FW.properties.threatIntelMode + "`n" + 
                                                                    'Firewall Policy: '+ [string]$FW.properties.firewallPolicy.id.split('/')[8]) | Out-Null
                                            }
                                    }
                                else 
                                    {
                                        $SubIcon.Characters.Text = ([string]$RESNames.name)
                                        $SubIcon.Characters.CharProps(7) = $charsize
                                        $SubIcon.Comments.Add('Firewall Name: '+ [string]$RESNames.name+ "`n" + 
                                                              'SKU Tier: '+ [string]$RESNames.properties.sku.tier + "`n" + 
                                                              'Threat Intel Mode: '+ [string]$RESNames.properties.threatIntelMode + "`n" + 
                                                              'Firewall Policy: '+ [string]$RESNames.properties.firewallPolicy.id.split('/')[8]) | Out-Null
                                    }                                                                
                                } 
            'privateLinkServices' {                                                    
                                $SubIcon = $page.Drop($IconPVTs, ($subloc+0.75), ($Alt0+0.8))
                                if($RESNames.count -gt 1)
                                    {
                                        $SubIcon.Characters.Text = ([string]$RESNames.count + ' Private Endpoints')
                                        $SubIcon.Characters.CharProps(7) = $charsize
                                        $SubIcon.Comments.Add(($RESNames.Name | ForEach-Object {$_ + ', '})) | Out-Null
                                    }
                                else
                                    {
                                        $SubIcon.Characters.Text = ([string]$RESNames.Name)
                                        $SubIcon.Characters.CharProps(7) = $charsize
                                    }                                                                       
                                } 
            'applicationGateways' {                                                    
                                $SubIcon = $page.Drop($IconAppGWs, ($subloc+0.75), ($Alt0+0.8))
                                if($RESNames.count -gt 1)
                                    {
                                        $SubIcon.Characters.Text = ([string]$RESNames.count + ' Application Gateways')
                                        $SubIcon.Characters.CharProps(7) = $charsize
                                        $SubIcon.Comments.Add(($RESNames.Name | ForEach-Object {$_ + ', '})) | Out-Null
                                    }
                                else
                                    {
                                        $SubIcon.Characters.Text = ([string]$RESNames.Name)
                                        $SubIcon.Characters.CharProps(7) = $charsize
                                        $SubIcon.Comments.Add('App Gateway Name: '+ [string]$RESNames.Name + "`n" + 
                                                              'App Gateway SKU: '+ [string]$RESNames.Properties.sku.tier + "`n" + 
                                                              'Autoscale Min Capacity: '+ [string]$RESNames.Properties.autoscaleConfiguration.minCapacity + "`n" + 
                                                              'Autoscale Max Capacity: '+ [string]$RESNames.Properties.autoscaleConfiguration.maxCapacity) | Out-Null
                                    }                                                                                                                                                                             
                                }
            'bastionHosts' {                                                    
                                $SubIcon = $page.Drop($IconBastions, ($subloc+0.75), ($Alt0+0.8))
                                if($RESNames.count -gt 1)
                                    {
                                        $SubIcon.Characters.Text = ([string]$RESNames.count + ' Bastion Hosts')
                                        $SubIcon.Characters.CharProps(7) = $charsize
                                        $SubIcon.Comments.Add(($RESNames.Name | ForEach-Object {$_ + ', '})) | Out-Null
                                    }
                                else 
                                    {
                                        $SubIcon.Characters.Text = ([string]$RESNames.name)
                                        $SubIcon.Characters.CharProps(7) = $charsize
                                    }                                                                        
                                } 
            'APIM' {                                                    
                                $SubIcon = $page.Drop($IconAPIMs, ($subloc+0.75), ($Alt0+0.8))
                                $SubIcon.Characters.Text = ([string]$RESNames.name)
                                $SubIcon.Characters.CharProps(7) = $charsize
                                $SubIcon.Comments.Add('APIM Name: '+ [string]$RESNames.name + "`n" + 
                                                      'SKU: '+ [string]$RESNames.sku.name + "`n" + 
                                                      'VNET Type: '+ [string]$RESNames.properties.virtualNetworkType + "`n" +
                                                      'Default Hostname: '+ [string]($RESNames.properties.hostnameConfigurations | Where-Object {$_.defaultSslBinding -eq $true}).hostname) | Out-Null
                                }
            'App Service' {
                                if($ServiceAppNames)
                                    {
                                        $SubIcon = $page.Drop($IconAPPs, ($subloc+0.75), ($Alt0+0.8))
                                        if($RESNames.count -gt 1)
                                            {
                                                $SubIcon.Characters.Text = ([string]$RESNames.count + ' App Services')
                                                $SubIcon.Characters.CharProps(7) = $charsize
                                                $SubIcon.Comments.Add(($RESNames.Name | ForEach-Object {$_ + ', '})) | Out-Null
                                            }
                                        else
                                            {
                                                $SubIcon.Characters.Text = ([string]$RESNames.Name)
                                                $SubIcon.Characters.CharProps(7) = $charsize
                                                $SubIcon.Comments.Add('App Name: '+ [string]$RESNames.Name + "`n" + 
                                                                      'Default Hostname: '+ [string]$RESNames.properties.defaultHostName + "`n" + 
                                                                      'Enabled: '+ [string]$RESNames.properties.enabled + "`n" + 
                                                                      'State: '+ [string]$RESNames.properties.state+ "`n" + 
                                                                      'Inbound IP Address: '+ [string]$RESNames.properties.inboundIpAddress+ "`n" + 
                                                                      'Kind: '+ [string]$RESNames.properties.kind+ "`n" + 
                                                                      'SKU: '+ [string]$RESNames.properties.sku+ "`n" + 
                                                                      'Workers: '+ [string]$RESNames.properties.siteConfig.numberOfWorkers + "`n" +
                                                                      'Min Workers: '+ [string]$RESNames.properties.siteConfig.minimumElasticInstanceCount + "`n" +
                                                                      'Site Properties: '+ [string]$RESNames.properties.siteProperties.properties.value) | Out-Null
                                            }
                                    }                                                                                                                                  
                                }
            'Function App' {    
                                if($FuntionAppNames)
                                    {                                                
                                        $SubIcon = $page.Drop($IconFunApps, ($subloc+0.75), ($Alt0+0.8))
                                        if($RESNames.count -gt 1)
                                            {
                                                $SubIcon.Characters.Text = ([string]$RESNames.count+' Function Apps')
                                                $SubIcon.Characters.CharProps(7) = $charsize
                                                $SubIcon.Comments.Add(($RESNames.Name | ForEach-Object {$_ + ', '})) | Out-Null
                                            }
                                        else
                                            {
                                                $SubIcon.Characters.Text = ([string]$RESNames.Name)
                                                $SubIcon.Characters.CharProps(7) = $charsize
                                                $SubIcon.Comments.Add('Function App Name: '+ [string]$RESNames.Name + "`n" + 
                                                                      'Default Hostname: '+ [string]$RESNames.properties.defaultHostName + "`n" + 
                                                                      'Enabled: '+ [string]$RESNames.properties.enabled + "`n" + 
                                                                      'State: '+ [string]$RESNames.properties.state+ "`n" + 
                                                                      'Inbound IP Address: '+ [string]$RESNames.properties.inboundIpAddress+ "`n" + 
                                                                      'Kind: '+ [string]$RESNames.properties.kind+ "`n" + 
                                                                      'SKU: '+ [string]$RESNames.properties.sku+ "`n" + 
                                                                      'Workers: '+ [string]$RESNames.properties.siteConfig.numberOfWorkers + "`n" +
                                                                      'Min Workers: '+ [string]$RESNames.properties.siteConfig.minimumElasticInstanceCount + "`n" +
                                                                      'Site Properties: '+ [string]$RESNames.properties.siteProperties.properties.value) | Out-Null
                                            }
                                    }
                                }
            'DataBricks' {      
                                if($DatabriksNames)
                                    {                                              
                                    $SubIcon = $page.Drop($IconBricks, ($subloc+0.75), ($Alt0+0.8))
                                    if($RESNames.count -gt 1)
                                        {
                                            $SubIcon.Characters.Text = ([string]$RESNames.count+' Databricks')
                                            $SubIcon.Characters.CharProps(7) = $charsize
                                            $SubIcon.Comments.Add(($RESNames.Name | ForEach-Object {$_ + ', '})) | Out-Null
                                        }
                                    else
                                        {
                                            $SubIcon.Characters.Text = ([string]$RESNames.Name)
                                            $SubIcon.Characters.CharProps(7) = $charsize
                                            $SubIcon.Comments.Add('Databrick Name: '+ [string]$RESNames.Name + "`n" + 
                                                                  'Workspace URL: '+ [string]$RESNames.properties.workspaceUrl + "`n" + 
                                                                  'Pricing Tier: '+[string]$RESNames.sku.name + "`n" + 
                                                                  'Storage Account: '+ [string]$RESNames.properties.parameters.storageAccountName.value + "`n" + 
                                                                  'Storage Account SKU: '+ [string]$RESNames.properties.parameters.storageAccountSkuName.value + "`n" +
                                                                  'Relay Namespace: '+ [string]$RESNames.properties.parameters.relayNamespaceName.value + "`n" +
                                                                  'Require Infrastructure Encryption: '+ [string]$RESNames.properties.parameters.requireInfrastructureEncryption.value + "`n" +
                                                                  'Enable Public IP: '+ [string]$RESNames.properties.parameters.enableNoPublicIp.value) | Out-Null
                                        }                                                                                               
                                    }
                                }
            'Open Shift' {        
                                if($ARONames)
                                    {                                            
                                        $SubIcon = $page.Drop($IconARO, ($subloc+0.75), ($Alt0+0.8))
                                        if($RESNames.count -gt 1)
                                            {
                                                $SubIcon.Characters.Text = ([string]$RESNames.count+' OpenShift Clusters')
                                                $SubIcon.Characters.CharProps(7) = $charsize
                                                $SubIcon.Comments.Add(($RESNames.Name | ForEach-Object {$_ + ', '})) | Out-Null
                                            }
                                        else
                                            {
                                                $SubIcon.Characters.Text = ([string]$RESNames.Name)
                                                $SubIcon.Characters.CharProps(7) = $charsize
                                                $SubIcon.Comments.Add('OpenShift version: '+ [string]$RESNames.properties.clusterProfile.version + "`n" + 
                                                                      'OpenShift console: '+ [string]$RESNames.properties.consoleProfile.url + "`n" + 
                                                                      'Worker VM count: '+ [string]$RESNames.properties.workerprofiles.Count + "`n" +   
                                                                      'Workers VM Size: '+ [string]$RESNames.properties.workerprofiles.vmSize[0]) | Out-Null
                                            }
                                    }                                                                                               
                                }
            'Container Instance'  {
                                    if($ContainerNames)
                                        {                                                    
                                            $SubIcon = $page.Drop($IconContain, ($subloc+0.75), ($Alt0+0.8))
                                            if($RESNames.count -gt 1)
                                                {
                                                    $SubIcon.Characters.Text = ([string]$RESNames.count+' Container Intances')
                                                    $SubIcon.Characters.CharProps(7) = $charsize
                                                    $SubIcon.Comments.Add(($RESNames.Name | ForEach-Object {$_ + ', '})) | Out-Null
                                                }
                                            else
                                                {
                                                    $SubIcon.Characters.Text = ([string]$RESNames.Name)
                                                    $SubIcon.Characters.CharProps(7) = $charsize
                                                }
                                        }                                                                                               
                                }
            'NetApp' {          
                                if($NetAppNames)
                                    {                                          
                                        $SubIcon = $page.Drop($IconNetApp, ($subloc+0.75), ($Alt0+0.8))
                                        if($RESNames.count -gt 1)
                                            {
                                                $SubIcon.Characters.Text = ([string]$RESNames.count+' NetApp Volumes')
                                                $SubIcon.Characters.CharProps(7) = $charsize
                                                $SubIcon.Comments.Add(($RESNames.Name | ForEach-Object {$_ + ', '})) | Out-Null
                                            }
                                        else
                                            {
                                                $SubIcon.Characters.Text = ([string]1+' NetApp Volume')
                                                $SubIcon.Characters.CharProps(7) = $charsize
                                                $SubIcon.Comments.Add($RESNames.Name) | Out-Null
                                            }
                                    }                                                                   
                                }
            'Data Explorer Clusters' {  
                                        $SubIcon = $page.Drop($IconDataExplorer, ($subloc+0.75), ($Alt0+0.8))
                                        if($RESNames.count -gt 1)
                                            {
                                                $SubIcon.Characters.Text = ([string]$RESNames.count+' Data Explorer Clusters')
                                                $SubIcon.Characters.CharProps(7) = $charsize
                                                $SubIcon.Comments.Add(($RESNames.Name | ForEach-Object {$_ + ', '})) | Out-Null
                                            }
                                        else
                                            {
                                                $SubIcon.Characters.Text = ([string]$RESNames.Name)
                                                $SubIcon.Characters.CharProps(7) = $charsize
                                                $SubIcon.Comments.Add('Data Explorer Cluster Name: '+ [string]$RESNames.Name + "`n" + 
                                                                      'Data Explorer Cluster URI: '+ [string]$RESNames.properties.uri + "`n" + 
                                                                      'Data Explorer Cluster State: '+ [string]$RESNames.properties.state + "`n" + 
                                                                      'SKU Tier: '+ [string]$RESNames.sku.tier + "`n" +  
                                                                      'Computer specifications: '+ [string]$RESNames.sku.name + "`n" +
                                                                      'AutoScale Enabled: '+ [string]$RESNames.properties.optimizedAutoscale.isEnabled) | Out-Null
                                            }                                                               
                                } 
            'Network Interface' {                                                    
                                $SubIcon = $page.Drop($IconNIC, ($subloc+0.75), ($Alt0+0.8))
                                if($RESNames.count -gt 1)
                                    {
                                        $SubIcon.Characters.Text = ([string]$RESNames.count+' Network Interfaces')
                                        $SubIcon.Characters.CharProps(7) = $charsize
                                        $SubIcon.Comments.Add(($RESNames.Name | ForEach-Object {$_ + ', '})) | Out-Null
                                    }
                                else
                                    {
                                        $SubIcon.Characters.Text = ([string]1+' Network Interface')
                                        $SubIcon.Characters.CharProps(7) = $charsize
                                        $SubIcon.Comments.Add($RESNames.Name) | Out-Null
                                    }                                                                
                                }                                                                                                                                                                            
            '' {}
            default {}
        }
        if($sub.properties.networkSecurityGroup.id)
            {
                $NSG = $sub.properties.networkSecurityGroup.id.split('/')[8]
                $SubIcon = $page.Drop($IconNSG, ($subloc+1.4), ($Alt0+1.2))
                $SubIcon.Resize(1,-0.25,-0.25)
                $SubIcon.Characters.Text = ''
                $SubIcon.Comments.Add('Network Security Group: '+[string]$NSG) | Out-Null
            }
        if($sub.properties.routeTable.id)
            {
                $UDR = $sub.properties.routeTable.id.split('/')[8]
                $SubIcon = $page.Drop($IconUDR, ($subloc+0.4), ($Alt0+1.22))
                $SubIcon.Resize(1,-0.35,-0.35)
                $SubIcon.Characters.Text = ''
                $SubIcon.Comments.Add('Route Table: '+[string]$UDR) | Out-Null
            }
        <#    
        if($RESNames.count -gt 1)
            {
                $ADVSS = @()
                foreach ($Res in $RESNames) 
                    {
                        $ADVSS += ($Advisories | Where-Object {$_.Properties.resourceMetadata.resourceId -eq $Res.id} | Select-Object -Unique)
                    }                    
                if($ADVSS)
                    {
                        if('Cost' -in $ADVSS.Properties.Category)
                            {
                                $SubIcon = $page.Drop($IconCostMGMT, ($subloc+0.865), ($Alt0+1.22))
                                $SubIcon.Resize(1,-0.25,-0.25)
                                $SubIcon.Characters.Text = ''
                                foreach ($ADV in $ADVSS)
                                    {
                                        $SubIcon.Comments.Add('Resource Name: '+ [string]$ADV.properties.impactedValue + "`n" + 
                                                                'Current SKU: '+ [string]$ADV.properties.extendedProperties.currentSku + "`n" + 
                                                                'Target SKU: '+ [string]$ADV.properties.extendedProperties.TargetSKU + "`n" + 
                                                                'Annual Savings: '+[string]$ADV.properties.extendedProperties.annualSavingsAmount) | Out-Null
                                    }                                        
                            }
                        else 
                            {
                                $SubIcon = $page.Drop($IconAdvisor, ($subloc+0.865), ($Alt0+1.22))
                                $SubIcon.Resize(1,-0.25,-0.25)
                                $SubIcon.Characters.Text = ''
                                        $SubIcon.Comments.Add('Advisories: '+ [string]$ADVSS.count) | Out-Null
                            }
                    }                                        
            }
        else    
            {
                $ADVS = ''
                $ADVS = ($Advisories | Where-Object {$_.Properties.resourceMetadata.resourceId -eq $RESNames.id} | Select-Object -Unique)
                    {
                        if($ADVS)
                            {
                                if($ADVS.Properties.Category -eq 'Cost')
                                    {
                                        $SubIcon = $page.Drop($IconCostMGMT, ($subloc+0.865), ($Alt0+1.22))
                                        $SubIcon.Resize(1,-0.25,-0.25)
                                        $SubIcon.Characters.Text = ''
                                        foreach ($ADV in $ADVS)
                                            {
                                                $SubIcon.Comments.Add('Resource Name: '+ [string]$ADV.properties.impactedValue + "`n" + 
                                                                      'Current SKU: '+ [string]$ADV.properties.extendedProperties.currentSku + "`n" + 
                                                                      'Target SKU: '+ [string]$ADV.properties.extendedProperties.TargetSKU + "`n" + 
                                                                      'Annual Savings: '+[string]$ADV.properties.extendedProperties.annualSavingsAmount) | Out-Null
                                            }                                        
                                    }
                                else 
                                    {
                                        $SubIcon = $page.Drop($IconAdvisor, ($subloc+0.865), ($Alt0+1.22))
                                        $SubIcon.Resize(1,-0.25,-0.25)
                                        $SubIcon.Characters.Text = ''
                                                $SubIcon.Comments.Add('Advisories: '+ [string]$ADV.count) | Out-Null
                                    }
                            }
                    }
            }
            #>
        if($sub.properties.ipconfigurations.id)
            {
                Foreach($SubIPs in $sub.properties.ipconfigurations)
                    {
                        $Global:VNETPIP += $Global:CleanPIPs | Where-Object {$_.properties.ipConfiguration.id -eq $SubIPs.id}
                    }
            }
}




Variables0
Visio

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


$document.SaveAs($DFile) | Out-Null
$application.Quit() 
