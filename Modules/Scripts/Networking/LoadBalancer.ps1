﻿<#
.Synopsis
Inventory for Azure LoadBalancer

.DESCRIPTION
This script consolidates information for all microsoft.network/loadbalancers and  resource provider in $Resources variable. 
Excel Sheet Name: LoadBalancer

.Link
https://github.com/microsoft/ARI/Modules/Networking/LoadBalancer.ps1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.4.1
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Task , $File, $SmaResources, $TableStyle, $Unsupported)
If ($Task -eq 'Processing') {

    $LoadBalancer = $Resources | Where-Object { $_.TYPE -eq 'microsoft.network/loadbalancers' }

    if($LoadBalancer)
        {
            $tmp = @()

            foreach ($1 in $LoadBalancer ) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.Id -eq $1.subscriptionId }
                $FrontEnds = @()
                $Backends = @()
                $Probes = @()
                $data = $1.PROPERTIES
                $Orphaned = if([string]::IsNullOrEmpty($data.backendAddressPools.id)){$true}else{$false}
                $RetDate = ''
                $RetFeature = ''
                if($1.sku.name -eq 'Basic')
                    {
                        $RetDate = ($Unsupported | Where-Object {$_.Id -eq 8}).RetirementDate
                        $RetFeature = ($Unsupported | Where-Object {$_.Id -eq 8}).RetiringFeature
                    }
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                $FrontEnds = foreach ($2 in $data.frontendIPConfigurations) 
                    {
                        if (![string]::IsNullOrEmpty($2.properties.subnet.id)) 
                            {
                                $tmps = [pscustomobject]@{
                                    Name             = $2.name
                                    Fronttarget      = $2.properties.subnet.id.split('/')[8]
                                    FrontType        = 'VNET'
                                    frontsub         = $2.properties.subnet.id.split('/')[10]
                                }
                                $tmps
                            }
                        elseif (![string]::IsNullOrEmpty($2.properties.publicIPAddress.id)) 
                            {
                                $tmps = [pscustomobject]@{
                                    Name              = $2.name
                                    Fronttarget       = $2.properties.publicIPAddress.id.split('/')[8]
                                    FrontType         = 'Public IP'
                                    frontsub          = $null
                                }
                                $tmps
                            }
                    }
                $Backends = foreach ($3 in $data.backendAddressPools) 
                    {
                        if (![string]::IsNullOrEmpty($3.properties.backendIPConfigurations.id)) 
                            {
                                $tmps = [pscustomobject]@{
                                    name         = $3.name
                                    BackTarget   = $3.properties.backendIPConfigurations.id.split('/')[8]
                                    BackType     = $3.properties.backendIPConfigurations.id.split('/')[7]
                                }
                                $tmps
                            }
                    }
                $Probes = foreach ($4 in $data.probes) 
                    {
                        $tmps = [pscustomobject]@{
                            name            = $4.name
                            Interval        = $4.properties.intervalInSeconds
                            Protocol        = $4.properties.protocol
                            Port            = $4.properties.port
                            Threshold       = $4.properties.numberOfProbes
                        }
                        $tmps
                    }

                $TempAr = @()
                $ob = [pscustomobject]@{
                    loop = 'FrontEnd'
                    number = $FrontEnds.Count
                }
                $TempAr += $ob
                $ob = [pscustomobject]@{
                    loop = 'BackEnd'
                    number = $Backends.Count
                }
                $TempAr += $ob
                $ob = [pscustomobject]@{
                    loop = 'Probe'
                    number = $Probes.Count
                }
                $TempAr += $ob
                $Order = $TempAr | Select-Object -Property loop,number | Sort-Object number
                $FrontEnds = if(![string]::IsNullOrEmpty($FrontEnds)){$FrontEnds}else{'0'}
                $Backends = if(![string]::IsNullOrEmpty($Backends)){$Backends}else{'0'}
                $Probes = if(![string]::IsNullOrEmpty($Probes)){$Probes}else{'0'}

                if (($Order.loop | Select-Object -First 1) -eq 'Probe')
                    {
                        if (($Order.loop | Select-Object -First 1 -Skip 1) -eq 'FrontEnd')
                            {
                                foreach ($Probe in $Probes)
                                    {
                                        foreach ($FrontEnd in $FrontEnds)
                                            {
                                                foreach ($Backend in $Backends)
                                                    {
                                                        foreach ($Tag in $Tags) {
                                                            $obj = @{
                                                                'ID'                        = $1.id;
                                                                'Subscription'              = $sub1.Name;
                                                                'Resource Group'            = $1.RESOURCEGROUP;
                                                                'Name'                      = $1.NAME;
                                                                'Location'                  = $1.LOCATION;
                                                                'SKU'                       = $1.sku.name;
                                                                'Retirement Date'           = [string]$RetDate;
                                                                'Retirement Feature'        = $RetFeature;
                                                                'Orphaned'                  = $Orphaned;
                                                                'Frontend Name'             = $FrontEnd.Name;
                                                                'Frontend Target'           = $FrontEnd.Fronttarget;
                                                                'Frontend Type'             = $FrontEnd.FrontType;
                                                                'Frontend Subnet'           = $FrontEnd.frontsub;
                                                                'Backend Pool Name'         = $BackEnd.name;
                                                                'Backend Target'            = $BackEnd.BackTarget;
                                                                'Backend Type'              = $BackEnd.BackType;
                                                                'Probe Name'                = $Probe.name;
                                                                'Probe Interval (sec)'      = $Probe.Interval;
                                                                'Probe Protocol'            = $Probe.Protocol;
                                                                'Probe Port'                = $Probe.Port;
                                                                'Probe Unhealthy threshold' = $Probe.Threshold;
                                                                'Resource U'                = $ResUCount;
                                                                'Tag Name'                  = [string]$Tag.Name;
                                                                'Tag Value'                 = [string]$Tag.Value
                                                            }
                                                            $tmp += $obj
                                                            if ($ResUCount -eq 1) { $ResUCount = 0 } 
                                                        }  
                                                    }
                                            }
                                    }
                            }
                        else
                            {
                                foreach ($Probe in $Probes)
                                    {
                                        foreach ($Backend in $Backends)
                                            {
                                                foreach ($FrontEnd in $FrontEnds)
                                                    {
                                                        foreach ($Tag in $Tags) {
                                                            $obj = @{
                                                                'ID'                        = $1.id;
                                                                'Subscription'              = $sub1.Name;
                                                                'Resource Group'            = $1.RESOURCEGROUP;
                                                                'Name'                      = $1.NAME;
                                                                'Location'                  = $1.LOCATION;
                                                                'SKU'                       = $1.sku.name;
                                                                'Retirement Date'           = [string]$RetDate;
                                                                'Retirement Feature'        = $RetFeature;
                                                                'Orphaned'                  = $Orphaned;
                                                                'Frontend Name'             = $FrontEnd.Name;
                                                                'Frontend Target'           = $FrontEnd.Fronttarget;
                                                                'Frontend Type'             = $FrontEnd.FrontType;
                                                                'Frontend Subnet'           = $FrontEnd.frontsub;
                                                                'Backend Pool Name'         = $BackEnd.name;
                                                                'Backend Target'            = $BackEnd.BackTarget;
                                                                'Backend Type'              = $BackEnd.BackType;
                                                                'Probe Name'                = $Probe.name;
                                                                'Probe Interval (sec)'      = $Probe.Interval;
                                                                'Probe Protocol'            = $Probe.Interval;
                                                                'Probe Port'                = $Probe.Port;
                                                                'Probe Unhealthy threshold' = $Probe.Threshold;
                                                                'Resource U'                = $ResUCount;
                                                                'Tag Name'                  = [string]$Tag.Name;
                                                                'Tag Value'                 = [string]$Tag.Value
                                                            }
                                                            $tmp += $obj
                                                            if ($ResUCount -eq 1) { $ResUCount = 0 } 
                                                        }  
                                                    }
                                            }
                                    }
                            }
                    }
                if (($Order.loop | Select-Object -First 1) -eq 'FrontEnd')
                    {
                        if (($Order.loop | Select-Object -First 1 -Skip 1) -eq 'Probe')
                            {
                                foreach ($FrontEnd in $FrontEnds)
                                    {
                                        foreach ($Probe in $Probes)
                                            {
                                                foreach ($Backend in $Backends)
                                                    {
                                                        foreach ($Tag in $Tags) {
                                                            $obj = @{
                                                                'ID'                        = $1.id;
                                                                'Subscription'              = $sub1.Name;
                                                                'Resource Group'            = $1.RESOURCEGROUP;
                                                                'Name'                      = $1.NAME;
                                                                'Location'                  = $1.LOCATION;
                                                                'SKU'                       = $1.sku.name;
                                                                'Retirement Date'           = [string]$RetDate;
                                                                'Retirement Feature'        = $RetFeature;
                                                                'Orphaned'                  = $Orphaned;
                                                                'Frontend Name'             = $FrontEnd.Name;
                                                                'Frontend Target'           = $FrontEnd.Fronttarget;
                                                                'Frontend Type'             = $FrontEnd.FrontType;
                                                                'Frontend Subnet'           = $FrontEnd.frontsub;
                                                                'Backend Pool Name'         = $BackEnd.name;
                                                                'Backend Target'            = $BackEnd.BackTarget;
                                                                'Backend Type'              = $BackEnd.BackType;
                                                                'Probe Name'                = $Probe.name;
                                                                'Probe Interval (sec)'      = $Probe.Interval;
                                                                'Probe Protocol'            = $Probe.Interval;
                                                                'Probe Port'                = $Probe.Port;
                                                                'Probe Unhealthy threshold' = $Probe.Threshold;
                                                                'Resource U'                = $ResUCount;
                                                                'Tag Name'                  = [string]$Tag.Name;
                                                                'Tag Value'                 = [string]$Tag.Value
                                                            }
                                                            $tmp += $obj
                                                            if ($ResUCount -eq 1) { $ResUCount = 0 } 
                                                        }  
                                                    }
                                            }
                                    }
                            }
                        else
                            {
                                foreach ($FrontEnd in $FrontEnds)
                                    {
                                        foreach ($Backend in $Backends)
                                            {
                                                foreach ($Probe in $Probes)
                                                    {
                                                        foreach ($Tag in $Tags) {
                                                            $obj = @{
                                                                'ID'                        = $1.id;
                                                                'Subscription'              = $sub1.Name;
                                                                'Resource Group'            = $1.RESOURCEGROUP;
                                                                'Name'                      = $1.NAME;
                                                                'Location'                  = $1.LOCATION;
                                                                'SKU'                       = $1.sku.name;
                                                                'Retirement Date'           = [string]$RetDate;
                                                                'Retirement Feature'        = $RetFeature;
                                                                'Orphaned'                  = $Orphaned;
                                                                'Frontend Name'             = $FrontEnd.Name;
                                                                'Frontend Target'           = $FrontEnd.Fronttarget;
                                                                'Frontend Type'             = $FrontEnd.FrontType;
                                                                'Frontend Subnet'           = $FrontEnd.frontsub;
                                                                'Backend Pool Name'         = $BackEnd.name;
                                                                'Backend Target'            = $BackEnd.BackTarget;
                                                                'Backend Type'              = $BackEnd.BackType;
                                                                'Probe Name'                = $Probe.name;
                                                                'Probe Interval (sec)'      = $Probe.Interval;
                                                                'Probe Protocol'            = $Probe.Interval;
                                                                'Probe Port'                = $Probe.Port;
                                                                'Probe Unhealthy threshold' = $Probe.Threshold;
                                                                'Resource U'                = $ResUCount;
                                                                'Tag Name'                  = [string]$Tag.Name;
                                                                'Tag Value'                 = [string]$Tag.Value
                                                            }
                                                            $tmp += $obj
                                                            if ($ResUCount -eq 1) { $ResUCount = 0 } 
                                                        }  
                                                    }
                                            }
                                    }
                            }
                    }
                if (($Order.loop | Select-Object -First 1) -eq 'BackEnd')
                    {
                        if (($Order.loop | Select-Object -First 1 -Skip 1) -eq 'FrontEnd')
                            {
                                foreach ($Backend in $Backends)
                                    {
                                        foreach ($FrontEnd in $FrontEnds)
                                            {
                                                foreach ($Probe in $Probes)
                                                    {
                                                        foreach ($Tag in $Tags) {
                                                            $obj = @{
                                                                'ID'                        = $1.id;
                                                                'Subscription'              = $sub1.Name;
                                                                'Resource Group'            = $1.RESOURCEGROUP;
                                                                'Name'                      = $1.NAME;
                                                                'Location'                  = $1.LOCATION;
                                                                'SKU'                       = $1.sku.name;
                                                                'Retirement Date'           = [string]$RetDate;
                                                                'Retirement Feature'        = $RetFeature;
                                                                'Orphaned'                  = $Orphaned;
                                                                'Frontend Name'             = $FrontEnd.Name;
                                                                'Frontend Target'           = $FrontEnd.Fronttarget;
                                                                'Frontend Type'             = $FrontEnd.FrontType;
                                                                'Frontend Subnet'           = $FrontEnd.frontsub;
                                                                'Backend Pool Name'         = $BackEnd.name;
                                                                'Backend Target'            = $BackEnd.BackTarget;
                                                                'Backend Type'              = $BackEnd.BackType;
                                                                'Probe Name'                = $Probe.name;
                                                                'Probe Interval (sec)'      = $Probe.Interval;
                                                                'Probe Protocol'            = $Probe.Interval;
                                                                'Probe Port'                = $Probe.Port;
                                                                'Probe Unhealthy threshold' = $Probe.Threshold;
                                                                'Resource U'                = $ResUCount;
                                                                'Tag Name'                  = [string]$Tag.Name;
                                                                'Tag Value'                 = [string]$Tag.Value
                                                            }
                                                            $tmp += $obj
                                                            if ($ResUCount -eq 1) { $ResUCount = 0 } 
                                                        }  
                                                    }
                                            }
                                    }
                            }
                        else
                            {
                                foreach ($Backend in $Backends)
                                    {
                                        foreach ($Probe in $Probes)
                                            {
                                                foreach ($FrontEnd in $FrontEnds)
                                                    {
                                                        foreach ($Tag in $Tags) {
                                                            $obj = @{
                                                                'ID'                        = $1.id;
                                                                'Subscription'              = $sub1.Name;
                                                                'Resource Group'            = $1.RESOURCEGROUP;
                                                                'Name'                      = $1.NAME;
                                                                'Location'                  = $1.LOCATION;
                                                                'SKU'                       = $1.sku.name;
                                                                'Retirement Date'           = [string]$RetDate;
                                                                'Retirement Feature'        = $RetFeature;
                                                                'Orphaned'                  = $Orphaned;
                                                                'Frontend Name'             = $FrontEnd.Name;
                                                                'Frontend Target'           = $FrontEnd.Fronttarget;
                                                                'Frontend Type'             = $FrontEnd.FrontType;
                                                                'Frontend Subnet'           = $FrontEnd.frontsub;
                                                                'Backend Pool Name'         = $BackEnd.name;
                                                                'Backend Target'            = $BackEnd.BackTarget;
                                                                'Backend Type'              = $BackEnd.BackType;
                                                                'Probe Name'                = $Probe.name;
                                                                'Probe Interval (sec)'      = $Probe.Interval;
                                                                'Probe Protocol'            = $Probe.Interval;
                                                                'Probe Port'                = $Probe.Port;
                                                                'Probe Unhealthy threshold' = $Probe.Threshold;
                                                                'Resource U'                = $ResUCount;
                                                                'Tag Name'                  = [string]$Tag.Name;
                                                                'Tag Value'                 = [string]$Tag.Value
                                                            }
                                                            $tmp += $obj
                                                            if ($ResUCount -eq 1) { $ResUCount = 0 } 
                                                        }  
                                                    }
                                            }
                                    }
                            }
                    }
            }
            $tmp
        }
}
Else {
    if ($SmaResources.LoadBalancer) {

        $TableName = ('LBTable_'+($SmaResources.LoadBalancer.id | Select-Object -Unique).count)

        $condtxt = @()
        $condtxt += New-ConditionalText - -Range F:F -ConditionalType ContainsText
        $condtxt += New-ConditionalText Basic -Range E:E
        $condtxt += New-ConditionalText TRUE -Range H:H
                        
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('SKU')
        $Exc.Add('Retirement Date')
        $Exc.Add('Retirement Feature')
        $Exc.Add('Orphaned')
        $Exc.Add('Frontend Name')
        $Exc.Add('Frontend Target')
        $Exc.Add('Frontend Type')
        $Exc.Add('Frontend Subnet')
        $Exc.Add('Backend Pool Name')
        $Exc.Add('Backend Target')
        $Exc.Add('Backend Type')
        $Exc.Add('Probe Name')
        $Exc.Add('Probe Interval (sec)')
        $Exc.Add('Probe Protocol')
        $Exc.Add('Probe Port')
        $Exc.Add('Probe Unhealthy threshold')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $ExcelVar = $SmaResources.LoadBalancer 

        $ExcelVar | 
        ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        Export-Excel -Path $File -WorksheetName 'Load Balancers' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -ConditionalText $condtxt -Style $Style
    }
    
}