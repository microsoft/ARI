function Start-ARIProcessGovRAMP {
    Param($Resources)

    $nics = $Resources | Where-Object {$_.TYPE -eq 'microsoft.network/networkinterfaces'}
    $PrivateEdp = $Resources | Where-Object { $_.TYPE -eq 'microsoft.network/privateendpoints' }
    $PublicIP = $Resources | Where-Object { $_.TYPE -eq 'microsoft.network/publicipaddresses' }
    $FedRampResources = $Resources | Where-Object { $_.TYPE -in (
        'microsoft.compute/virtualmachines',
        'microsoft.sql/servers',
        'Microsoft.DBforPostgreSQL/flexibleServers',
        'microsoft.documentdb/databaseaccounts',
        'microsoft.network/loadbalancers',
        'microsoft.network/publicipaddresses',
        'microsoft.network/privatednszones',
        'microsoft.apimanagement/service',
        'microsoft.network/azurefirewalls',
        'microsoft.keyvault/vaults',
        'microsoft.storage/storageaccounts'

        <#
        'Microsoft.AppConfiguration/configurationStores',
        'microsoft.web/sites',
        'microsoft.network/applicationgateways',
        'microsoft.automation/automationaccounts',
        'microsoft.cache/redis',
        'microsoft.cache/redisenterprise',
        'Microsoft.DBforMySQL/flexibleServers',
        'microsoft.dbformysql/servers',
        'microsoft.databricks/workspaces',
        'microsoft.containerservice/managedclusters',
        'microsoft.insights/components',
        'microsoft.operationalinsights/workspaces',
        'Microsoft.NetApp/netAppAccounts/capacityPools/volumes',
        'microsoft.redhatopenshift/openshiftclusters',
        'microsoft.network/bastionhosts',
        'microsoft.containerregistry/registries',
        'Microsoft.ContainerInstance/containerGroups',
        'microsoft.network/dnszones',
        'microsoft.eventhub/namespaces',
        'microsoft.network/expressroutecircuits',
        'microsoft.network/frontdoors',
        'microsoft.devices/iothubs',
        'microsoft.network/networkwatchers',
        'microsoft.servicebus/namespaces',
        'microsoft.storage/storageaccounts',
        'microsoft.synapse/workspaces',
        'microsoft.network/trafficmanagerprofiles',
        'microsoft.network/virtualnetworks',
        'microsoft.network/virtualnetworkgateways',
        'microsoft.compute/virtualmachinescalesets'
        #>
    ) }

    Class FedResourceObj {
        [string] $FedID
        [string] $FedIPAddress = ''
        [string] $FedVirtual = 'Yes'
        [string] $FedPublic = 'No'
        [string] $FedDNSName = ''
        [string] $FedNetBIOSName = ''
        [string] $FedMACAddress = ''
        [string] $FedAuthenticatedScan = ''
        [string] $FedBaselineConfigurationName = ''
        [string] $FedOSNameAndVersion = ''
        [string] $FedLocation = ''
        [string] $FedAssetType = ''
        [string] $FedHardwareMakeModel = ''
        [string] $FedInLatestScan = ''
        [string] $FedSoftwareDatabaseVendor = ''
        [string] $FedSoftwareDatabaseNameAndVersion = ''
        [string] $FedPatchLevel = ''
        [string] $FedFunction = ''
        [string] $FedComments = ''
        [string] $FedSerialAssetTag = ''
        [string] $FedVLANNetworkID = ''
        [string] $FedSystemAdministratorOwner = ''
        [string] $FedApplicationAdministratorOwner = ''
    }


    $FedResources = foreach ($FedResource in $FedRampResources)
        {

            Switch ($FedResource) {
                {$_.type -eq 'microsoft.compute/virtualmachines'} 
                    {
                        $VM = $FedResource
                        $VMNIC = foreach ($nic in $nics) {
                            if ($nic.id -in $vm.properties.networkProfile.networkInterfaces.id) {
                                $nic
                            }
                        }

                        if ($vm.properties.extended.instanceView.osName) 
                            {
                                if ($vm.properties.extended.instanceView.osName -like '*Windows*') 
                                    {
                                        $VMOS = $vm.properties.extended.instanceView.osName
                                    }
                                else 
                                    {
                                        if($vm.properties.storageProfile.imageReference.publisher -eq 'AzureDatabricks')
                                            {
                                                $VMOS = 'Databricks Worker ' + $vm.properties.storageProfile.imageReference.version
                                            }
                                        elseif ($vm.properties.extended.instanceView.osName -eq 'ubuntu') 
                                            {
                                                if ($vm.properties.storageProfile.imageReference.offer -like '*server*') 
                                                    {
                                                        $VMOS = 'Ubuntu Server ' + $vm.properties.extended.instanceView.osVersion
                                                    } 
                                                else 
                                                    {
                                                        $VMOS = $vm.properties.extended.instanceView.osName + ' ' + $vm.properties.extended.instanceView.osVersion
                                                    }
                                            }
                                        elseif ($vm.properties.extended.instanceView.osName -eq 'redhat') 
                                            {
                                                $VMOS = 'Red Hat Enterprise Linux ' + $vm.properties.extended.instanceView.osVersion
                                            }
                                        else 
                                            {
                                                $VMOS = $vm.properties.storageProfile.imageReference.publisher + ' ' + $vm.properties.storageProfile.imageReference.sku
                                            }
                                    }
                            } 
                        else 
                            {
                                if ($vm.properties.storageProfile.imageReference.offer)
                                    {
                                        $VMOS = $vm.properties.storageProfile.imageReference.publisher + ' ' + $vm.properties.storageProfile.imageReference.sku
                                    }
                            }

                        if ($vm.properties.storageProfile.imageReference.offer -like '*server*' -or $vm.properties.storageProfile.imageReference.publisher -like '*server*' -or $vm.properties.storageProfile.imageReference.sku -like '*server*' -or $vm.properties.storageProfile.imageReference.publisher -eq 'RedHat' -or $vm.properties.storageProfile.imageReference.publisher -like '*databricks*') 
                            {
                                $AssetType = 'Virtual Server'
                            }
                        else
                            {
                                $AssetType = 'Virtual Workstation'
                            }

                        $FedObj = [FedResourceObj]::new()
                        $FedObj.FedID = $VM.id
                        $FedObj.FedIPAddress = if($VMNIC.count -gt 1) { $VMNIC.properties.ipConfigurations.properties.privateIPAddress | ForEach-Object { $_ + '_x000a_' } }else { $VMNIC.properties.ipConfigurations.properties.privateIPAddress}
                        $FedObj.FedNetBIOSName = $VM.properties.osprofile.computerName
                        $FedObj.FedMACAddress = if($VMNIC.count -gt 1) { $VMNIC.properties.macAddress  | ForEach-Object { $_ + '_x000a_' } }else { $VMNIC.properties.macAddress}
                        $FedObj.FedOSNameAndVersion = $VMOS
                        $FedObj.FedLocation = $vm.location
                        $FedObj.FedSystemAdministratorOwner = $vm.properties.osProfile.adminUsername
                        $FedObj.FedAssetType = $AssetType

                    }
                {$_.type -eq 'microsoft.sql/servers'} 
                    {
                    $DB = $FedResource

                    $Pvtedp = foreach ($pvt in $PrivateEdp)
                        {
                            if ($pvt.id -in $DB.properties.privateEndpointConnections.properties.PrivateEndpoint.id)
                                {
                                    $pvt
                                }
                        }
                    $DBNics = foreach ($nic in $nics)
                        {
                            if ($nic.id -in $Pvtedp.properties.networkInterfaces.id)
                                {
                                    $nic
                                }
                        }

                    $FedObj = [FedResourceObj]::new()
                    $FedObj.FedID = $DB.id
                    $FedObj.FedIPAddress = if ($DBNics.count -gt 1) { $DBNics.properties.ipConfigurations.properties.privateIPAddress | ForEach-Object { $_ + '_x000a_' } }else { $DBNics.properties.ipConfigurations.properties.privateIPAddress}
                    $FedObj.FedMACAddress = $DBNics.properties.macAddress
                    $FedObj.FedPublic = if ($DB.properties.publicNetworkAccess -eq 'Enabled') {'Yes'}else{'No'}
                    $FedObj.FedSoftwareDatabaseVendor = 'Microsoft'
                    $FedObj.FedSoftwareDatabaseNameAndVersion = 'Microsoft SQL Server v' + $DB.properties.version
                    $FedObj.FedDNSName = $DB.properties.fullyQualifiedDomainName
                    $FedObj.FedLocation = $DB.location
                    $FedObj.FedSystemAdministratorOwner = $DB.properties.administratorLogin
                    $FedObj.FedApplicationAdministratorOwner = $DB.properties.administrators.login
                    $FedObj.FedAssetType = 'Database'

                    }
                {$_.type -eq 'Microsoft.DBforPostgreSQL/flexibleServers'} 
                    {
                    $DB = $FedResource

                    $Pvtedp = foreach ($pvt in $PrivateEdp)
                        {
                            if ($pvt.id -in $DB.properties.privateEndpointConnections.properties.PrivateEndpoint.id)
                                {
                                    $pvt
                                }
                        }
                    $DBNics = foreach ($nic in $nics)
                        {
                            if ($nic.id -in $Pvtedp.properties.networkInterfaces.id)
                                {
                                    $nic
                                }
                        }
                    $FedObj = [FedResourceObj]::new()
                    $FedObj.FedID = $DB.id
                    $FedObj.FedIPAddress = if ($DBNics.count -gt 1) { $DBNics.properties.ipConfigurations.properties.privateIPAddress | ForEach-Object { $_ + '_x000a_' } }else { $DBNics.properties.ipConfigurations.properties.privateIPAddress}
                    $FedObj.FedMACAddress = $DBNics.properties.macAddress
                    $FedObj.FedPublic = if ($DB.properties.network.publicNetworkAccess -eq 'Enabled') {'Yes'}else{'No'}
                    $FedObj.FedSoftwareDatabaseVendor = 'PostgreSQL'
                    $FedObj.FedSoftwareDatabaseNameAndVersion = 'PostgreSQL v' + $DB.properties.version
                    $FedObj.FedDNSName = $DB.properties.fullyQualifiedDomainName
                    $FedObj.FedLocation = $DB.location
                    $FedObj.FedSystemAdministratorOwner = $DB.properties.administratorLogin
                    $FedObj.FedAssetType = 'Database'

                    }
                {$_.type -eq 'microsoft.documentdb/databaseaccounts'} 
                    {
                        $DB = $FedResource

                        $Pvtedp = foreach ($pvt in $PrivateEdp)
                            {
                                if ($pvt.id -in $DB.properties.privateEndpointConnections.properties.PrivateEndpoint.id)
                                    {
                                        $pvt
                                    }
                            }
                        $DBNics = foreach ($nic in $nics)
                            {
                                if ($nic.id -in $Pvtedp.properties.networkInterfaces.id)
                                    {
                                        $nic
                                    }
                            }
                        $FedObj = [FedResourceObj]::new()
                        $FedObj.FedID = $DB.id
                        $FedObj.FedIPAddress = if ($DBNics.count -gt 1) { $DBNics.properties.ipConfigurations.properties.privateIPAddress | ForEach-Object { $_ + '_x000a_' } }else { $DBNics.properties.ipConfigurations.properties.privateIPAddress}
                        $FedObj.FedMACAddress = $DBNics.properties.macAddress
                        $FedObj.FedPublic = if ($DB.properties.publicNetworkAccess -eq 'Enabled') {'Yes'}else{'No'}
                        $FedObj.FedSoftwareDatabaseVendor = 'Cosmos DB'
                        $FedObj.FedSoftwareDatabaseNameAndVersion = ($FedResource.properties.EnabledApiTypes + ' v' + $FedResource.properties.apiProperties.serverVersion)
                        $FedObj.FedDNSName = $FedResource.properties.sqlEndpoint.replace('https://','').replace(':443/','')
                        $FedObj.FedLocation = $DB.location
                        $FedObj.FedSystemAdministratorOwner = $DB.properties.administratorLogin
                        $FedObj.FedAssetType = 'Database'
                    }
                {$_.type -eq 'microsoft.network/loadbalancers'} 
                    {
                        $LB = $FedResource

                        $FedObj = [FedResourceObj]::new()
                        $FedObj.FedID = $LB.id
                            if(![string]::IsNullOrEmpty($LB.properties.outboundRules))
                                {
                                    $LBPIPs = foreach ($PIP in $PublicIP)
                                        {
                                            if ($PIP.id -in $LB.properties.frontendIPConfigurations.properties.publicIPAddress.id)
                                                {
                                                    $PIP
                                                }
                                        }

                                    $FedObj.FedPublic = 'Yes'
                                    $FedObj.FedIPAddress = if ($LBPIPs.count -gt 1) { $LBPIPs.properties.ipAddress | ForEach-Object { $_ + '_x000a_' } }else { $LBPIPs.properties.ipAddress}
                                }
                            else
                                {
                                    $FedObj.FedPublic  = 'No'
                                    $FedObj.FedIPAddress = if ($LB.properties.frontendIPConfigurations.properties.privateIPAddress.count -gt 1) { $LB.properties.frontendIPConfigurations.properties.privateIPAddress | ForEach-Object { $_ + '_x000a_' } }else { $LB.properties.frontendIPConfigurations.properties.privateIPAddress}
                                }
                        $FedObj.FedLocation = $LB.location
                        $FedObj.FedAssetType = 'Load Balancer'

                    }
                {$_.type -eq 'microsoft.network/publicipaddresses'} 
                    {
                        $PIP = $FedResource
                        $FedObj = [FedResourceObj]::new()
                        $FedObj.FedID = $PIP.id
                        $FedObj.FedIPAddress = $PIP.properties.ipAddress
                        $FedObj.FedAssetType = 'Public IP'
                        $FedObj.FedPublic = 'Yes'
                        $FedObj.FedDNSName = $PIP.properties.dnsSettings.fqdn
                    }
                {$_.type -eq 'microsoft.network/privatednszones'} 
                    {
                    $PvtDNS = $FedResource

                    $FedObj = [FedResourceObj]::new()
                    $FedObj.FedID = $PvtDNS.id
                    $FedObj.FedAssetType = 'Private DNS Zone'
                    $FedObj.FedDNSName = $PvtDNS.name
                    $FedObj.FedPublic = 'No'

                    }
                {$_.type -eq 'microsoft.apimanagement/service'}
                    {
                        $APIM = ($Resources | where {$_.Type -eq 'microsoft.apimanagement/service'})[0]
                        $APIM = $FedResource

                        $FedObj = [FedResourceObj]::new()
                        $FedObj.FedID = $APIM.id
                        $FedObj.FedIPAddress = $APIM.properties.publicIPAddresses
                        $FedObj.FedDNSName = $APIM.properties.gatewayUrl
                        $FedObj.FedLocation = $APIM.location
                        $FedObj.FedAssetType = 'API Management'
                        $FedObj.FedPublic = if ($APIM.properties.virtualNetworkType -eq 'External') {'Yes'}else{'No'}
                        $FedObj.FedSystemAdministratorOwner = $APIM.properties.publisherEmail

                    }
                {$_.type -eq 'microsoft.network/azurefirewalls'}
                    {
                        $Fw = $FedResource

                        $FWPIP = foreach ($PIP in $PublicIP)
                            {
                                if ($PIP.id -in $Fw.properties.ipConfigurations.properties.publicIPAddress.id)
                                    {
                                        $PIP
                                    }
                            }

                        $FedObj = [FedResourceObj]::new()
                        $FedObj.FedID = $Fw.id
                        $FedObj.FedIPAddress = ($Fw.properties.ipConfigurations.properties.privateIPAddress + '_x000a_' + $FWPIP.properties.ipAddress)
                        $FedObj.FedPublic = if (![string]::IsNullOrEmpty($Fw.properties.ipConfigurations.properties.publicIPAddress)) {'Yes'}else{'No'}
                        $FedObj.FedAssetType = 'Firewall'
                        $FedObj.FedLocation = $Fw.location

                    }
                {$_.type -eq 'microsoft.keyvault/vaults'}
                    {
                        $KeyVault = $FedResource

                        $Pvtedp = foreach ($pvt in $PrivateEdp)
                            {
                                if ($pvt.id -in $KeyVault.properties.privateEndpointConnections.properties.PrivateEndpoint.id)
                                    {
                                        $pvt
                                    }
                            }
                        $VaultNics = foreach ($nic in $nics)
                            {
                                if ($nic.id -in $Pvtedp.properties.networkInterfaces.id)
                                    {
                                        $nic
                                    }
                            }

                        $FedObj = [FedResourceObj]::new()
                        $FedObj.FedID = $KeyVault.id
                        $FedObj.FedIPAddress = if ($VaultNics.count -gt 1) { $VaultNics.properties.ipConfigurations.properties.privateIPAddress | ForEach-Object { $_ + '_x000a_' } }else { $VaultNics.properties.ipConfigurations.properties.privateIPAddress}
                        $FedObj.FedMACAddress = $VaultNics.properties.macAddress
                        $FedObj.FedPublic = if ($KeyVault.properties.publicNetworkAccess -eq 'Enabled') {'Yes'}else{'No'}
                        $FedObj.FedAssetType = 'Key Vault'
                        $FedObj.FedLocation = $KeyVault.location
                        $FedObj.FedDNSName = if ([string]::IsNullOrEmpty($KeyVault.properties.vaultUri)){$KeyVault.properties.vaultUri.replace('https://','').replace('/','')}else{''}

                    }
                {$_.type -eq 'microsoft.storage/storageaccounts'}
                    {
                        $STG = $FedResource

                        $Pvtedp = foreach ($pvt in $PrivateEdp)
                            {
                                if ($pvt.id -in $STG.properties.privateEndpointConnections.properties.PrivateEndpoint.id)
                                    {
                                        $pvt
                                    }
                            }
                        $STGNics = foreach ($nic in $nics)
                            {
                                if ($nic.id -in $Pvtedp.properties.networkInterfaces.id)
                                    {
                                        $nic
                                    }
                            }
                        $DNSName = if (![string]::IsNullOrEmpty($STG.properties.primaryEndpoints.blob)) {$STG.properties.primaryEndpoints.blob}
                        elseif (![string]::IsNullOrEmpty($STG.properties.primaryEndpoints.file)) {$STG.properties.primaryEndpoints.file}
                        elseif (![string]::IsNullOrEmpty($STG.properties.primaryEndpoints.queue)) {$STG.properties.primaryEndpoints.queue}
                        elseif (![string]::IsNullOrEmpty($STG.properties.primaryEndpoints.table)) {$STG.properties.primaryEndpoints.table}

                        $FedObj = [FedResourceObj]::new()
                        $FedObj.FedID = $STG.id
                        $FedObj.FedIPAddress = if ($STGNics.count -gt 1) { $STGNics.properties.ipConfigurations.properties.privateIPAddress | ForEach-Object { $_ + '_x000a_' } }else { $STGNics.properties.ipConfigurations.properties.privateIPAddress}
                        $FedObj.FedMACAddress = $STGNics.properties.macAddress
                        $FedObj.FedPublic = if ($STG.properties.allowBlobPublicAccess -eq 'True') {'Yes'}else{'No'}
                        $FedObj.FedAssetType = 'Storage'
                        $FedObj.FedLocation = $STG.location
                        $FedObj.FedDNSName = if (![string]::IsNullOrEmpty($DNSName)) {$DNSName.replace('https://','').replace('/','')}else{''}

                    }
            }

            $FedObj
        }

        return $FedResources
}