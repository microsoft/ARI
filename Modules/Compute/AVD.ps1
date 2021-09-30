<#
.Synopsis
Inventory for Azure Virtual Desktop

.DESCRIPTION
This script consolidates information for all microsoft.desktopvirtualization and  microsoft.desktopvirtualization/hostpools/sessionhosts resource providers in $Resources variable. 
Excel Sheet Name: AVD

.Link
https://github.com/azureinventory/ARI/Modules/Compute/AVD.ps1

.COMPONENT
   This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 2.0.0
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Task , $File, $SmaResources, $TableStyle)

If ($Task -eq 'Processing') {

    <######### Insert the resource extraction here ########>

    $VM =  $Resources | Where-Object {$_.TYPE -eq 'microsoft.compute/virtualmachines'}
    $AVD = $Resources | Where-Object { $_.TYPE -eq 'microsoft.desktopvirtualization/hostpools' }
    $Hosts = $Resources | Where-Object { $_.TYPE -eq 'microsoft.desktopvirtualization/hostpools/sessionhosts' }

    if($AVD)
        {
            $tmp = @()

            foreach ($1 in $AVD) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES

                $sessionhosts = @()
                foreach ($h in $Hosts){
                    $n = $h.ID -split '/sessionhosts/' 
                    if ($n[0] -eq $1.id ) 
                    {
                        $sessionhosts += $h                    
                    }

                }
                
                if ($1.ZONES) { $Zones = $1.ZONES }else { $Zones = 'Not Configured' }
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                foreach ($2 in $sessionhosts)
                {
                    $domain = $2.name.replace(($2.name.split(".")[0]),'')
                    $vmsessionhosts = $VM | where { $_.ID -eq $2.properties.resourceId}
                    foreach ($Tag in $Tags) {
                        $obj = @{
                            'Subscription'       = $sub1.name;
                            'Resource Group'     = $1.RESOURCEGROUP;
                            'Hostpool Name'               = $1.NAME;
                            'Location'           = $1.LOCATION;
                            'Zone'               = $Zones;
                            'HostPool Type'           = $data.hostPoolType;
                            'LoadBalancer'       = $data.loadBalancerType;
                            'maxSessionLimit'    = $data.maxSessionLimit;
                            'preferred AppGroup' = $data.preferredAppGroupType;
                            'AVD Agent Version'  = $2.properties.agentVersion;
                            'Last Assigned User' = $2.properties.assignedUser;
                            'Allow New Session'  = $2.properties.allowNewSession;
                            'Update Status'      = $2.properties.updateState;
                            'Hostname'           = $vmsessionhosts.name;
                            'Domain'             = $domain;
                            'VM Size'            = $vmsessionhosts.properties.hardwareProfile.vmsize;
                            'OS Type'            = $vmsessionhosts.properties.storageProfile.osdisk.ostype;
                            'VM Disk Type'       = $vmsessionhosts.properties.storageProfile.osdisk.managedDisk.storageAccountType;
                            'Sessions'           = $2.properties.sessions;
                            'Host Status'        = $2.properties.status;
                            'OS Version'         = $2.properties.osVersion;
                            'Resource U'         = $ResUCount;
                            'Tag Name'           = [string]$Tag.Name;
                            'Tag Value'          = [string]$Tag.Value
                        }
                        $tmp += $obj
                        if ($ResUCount -eq 1) { $ResUCount = 0 } 
                    }            
            }
        }

            $tmp
        }
}
<######## Resource Excel Reporting Begins Here ########>

Else {
    <######## $SmaResources.(RESOURCE FILE NAME) ##########>

    if ($SmaResources.AVD) {
        $condtxtzone = New-ConditionalText "Not Configured" -Range E:E
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Hostpool Name')             
        $Exc.Add('Location')                
        $Exc.Add('Zone')
        $Exc.Add('HostPool Type')
        $Exc.Add('LoadBalancer')
        $Exc.Add('maxSessionLimit')
        $Exc.Add('preferred AppGroup')
        $Exc.Add('AVD Agent Version')  
        $Exc.Add('Last Assigned User') 
        $Exc.Add('Allow New Session')
        $Exc.Add('Update Status')      
        $Exc.Add('Hostname')           
        $Exc.Add('Domain')             
        $Exc.Add('VM Size')            
        $Exc.Add('OS Type')           
        $Exc.Add('VM Disk Type')
        $Exc.Add('Sessions')       
        $Exc.Add('Host Status')        
        $Exc.Add('OS Version')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $ExcelVar = $SmaResources.AVD

        $ExcelVar | 
        ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        Export-Excel -Path $File -WorksheetName 'AVD' -AutoSize -TableName 'AVD' -MaxAutoSizeRows 100 -TableStyle $tableStyle -ConditionalText $condtxtzone -Style $Style
      
    }
}