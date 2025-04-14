function Start-ARIMappingStateRAMP {
    Param($StateResources)

    $StateRAMP = Foreach ($StateResource in $StateResources)
        {
            $MappedResource = [PSCustomObject]@{
                'UNIQUE ASSET IDENTIFIER'                       = $StateResource.FedID
                'IPv4 or IPv6_x000a_Address'                    = $StateResource.FedIPAddress
                'Virtual'                                       = $StateResource.FedVirtual
                'Public'                                        = $StateResource.FedPublic
                'DNS Name or URL'                               = $StateResource.FedDNSName
                'NetBIOS Name'                                  = $StateResource.FedNetBIOSName
                'MAC Address'                                   = $StateResource.FedMACAddress
                'Authenticated Scan'                            = $StateResource.FedAuthenticatedScan
                'Baseline Configuration Name'                   = $StateResource.FedBaselineConfigurationName
                'OS Name and Version'                           = $StateResource.FedOSNameAndVersion
                'Location'                                      = $StateResource.FedLocation
                'Asset Type'                                    = $StateResource.FedAssetType
                'Hardware Make/Model'                           = $StateResource.FedHardwareMakeModel
                'In Latest Scan'                                = $StateResource.FedInLatestScan
                'Software/ Database Vendor'                     = $StateResource.FedSoftwareDatabaseVendor
                'Software/ Database Name & Version'             = $StateResource.FedSoftwareDatabaseNameAndVersion
                'Patch Level'                                   = $StateResource.FedPatchLevel
                'Function'                                      = $StateResource.FedFunction
                'Comments'                                      = $StateResource.FedComments
                'Serial #/Asset Tag#'                           = $StateResource.FedSerialAssetTag
                'VLAN/_x000a_Network ID'                        = $StateResource.FedVLANNetworkID
                'System Administrator/ Owner'                   = $StateResource.FedSystemAdministratorOwner
                'Application Administrator/ Owner'              = $StateResource.FedApplicationAdministratorOwner
            }
            $MappedResource
        }

    return $StateRAMP
}