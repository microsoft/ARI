function Start-ARIMappingFedRAMP {
    Param($FedResources)

    $FedRampResources = Foreach ($FedResource in $FedResources)
        {
            $MappedResource = [PSCustomObject]@{
                'UNIQUE ASSET IDENTIFIER'                       = $FedResource.FedID
                'IPv4 or IPv6 Address'                          = $FedResource.FedIPAddress
                'Virtual'                                       = $FedResource.FedVirtual
                'Public'                                        = $FedResource.FedPublic
                'DNS Name or URL'                               = $FedResource.FedDNSName
                'NetBIOS Name'                                  = $FedResource.FedNetBIOSName
                'MAC Address'                                   = $FedResource.FedMACAddress
                'Authenticated Scan'                            = $FedResource.FedAuthenticatedScan
                'Baseline Configuration Name'                   = $FedResource.FedBaselineConfigurationName
                'OS Name and Version'                           = $FedResource.FedOSNameAndVersion
                'Location'                                      = $FedResource.FedLocation
                'Asset Type'                                    = $FedResource.FedAssetType
                'Hardware Make/Model'                           = $FedResource.FedHardwareMakeModel
                'In Latest Scan'                                = $FedResource.FedInLatestScan
                'Software/ Database Vendor'                     = $FedResource.FedSoftwareDatabaseVendor
                'Software/ Database Name & Version'             = $FedResource.FedSoftwareDatabaseNameAndVersion
                'Patch Level'                                   = $FedResource.FedPatchLevel
                'Diagram Label'                                 = ''
                'Comments'                                      = $FedResource.FedComments
                'Serial #/Asset Tag#'                           = $FedResource.FedSerialAssetTag
                'VLAN/_x000a_Network ID'                        = $FedResource.FedVLANNetworkID
                'System Administrator/ Owner'                   = $FedResource.FedSystemAdministratorOwner
                'Application Administrator/ Owner'              = $FedResource.FedApplicationAdministratorOwner
                'Function'                                      = $FedResource.FedFunction
                'End-of-Life'                                   = ''
            }
            $MappedResource
        }

    return $FedRampResources
}