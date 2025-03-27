<#
.Synopsis
Inventory for Azure Kubernetes Service (AKS)

.DESCRIPTION
This script consolidates information for all microsoft.containerservice/managedclusters resource provider in $Resources variable. 
Excel Sheet Name: AKS

.Link
https://github.com/microsoft/ARI/Modules/Public/InventoryModules/Container/AKS.ps1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.6.0
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Retirements, $Task ,$File, $SmaResources, $TableStyle, $Unsupported)

If ($Task -eq 'Processing')
{
    <######### Insert the resource extraction here ########>

        $AKS = $Resources | Where-Object {$_.TYPE -eq 'microsoft.containerservice/managedclusters'}
        $VMExtraDetails = $Resources | Where-Object { $_.TYPE -eq 'ARI/VM/SKU' }
        $VMQuotas = $Resources | Where-Object { $_.TYPE -eq 'ARI/VM/Quotas' }

    <######### Insert the resource Process here ########>

    if($AKS)
        {
            $tmp = foreach ($1 in $AKS) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $Retired = Foreach ($Retirement in $Retirements)
                    {
                        if ($Retirement.id -eq $1.id) { $Retirement }
                    }
                if ($Retired) 
                    {
                        $RetiredFeature = foreach ($Retire in $Retired)
                            {
                                $RetiredServiceID = $Unsupported | Where-Object {$_.Id -eq $Retired.ServiceID}
                                $tmp0 = [pscustomobject]@{
                                        'RetiredFeature'            = $RetiredServiceID.RetiringFeature
                                        'RetiredDate'               = $RetiredServiceID.RetirementDate 
                                    }
                                $tmp0
                            }
                        $RetiringFeature = if ($RetiredFeature.RetiredFeature.count -gt 1) { $RetiredFeature.RetiredFeature | ForEach-Object { $_ + ' ,' } }else { $RetiredFeature.RetiredFeature}
                        $RetiringFeature = [string]$RetiringFeature
                        $RetiringFeature = if ($RetiringFeature -like '* ,*') { $RetiringFeature -replace ".$" }else { $RetiringFeature }

                        $RetiringDate = if ($RetiredFeature.RetiredDate.count -gt 1) { $RetiredFeature.RetiredDate | ForEach-Object { $_ + ' ,' } }else { $RetiredFeature.RetiredDate}
                        $RetiringDate = [string]$RetiringDate
                        $RetiringDate = if ($RetiringDate -like '* ,*') { $RetiringDate -replace ".$" }else { $RetiringDate }
                    }
                else 
                    {
                        $RetiringFeature = $null
                        $RetiringDate = $null
                    }
                if([string]::IsNullOrEmpty($data.addonProfiles.omsagent.config.logAnalyticsWorkspaceResourceID)){$Insights = $false}else{$Insights = $data.addonProfiles.omsagent.config.logAnalyticsWorkspaceResourceID.split('/')[8]}
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                $NetworkPlugin = if($data.networkprofile.networkplugin -eq 'azure'){'Azure CNI'}else{$data.networkprofile.networkplugin}
                $LocalAccounts = if($data.disablelocalaccounts -eq $true){$false}else{$true}
                $GroupsChosen = if($data.aadprofile.admingroupobjectids){[string]$data.aadprofile.admingroupobjectids.count}else{'0'}
                $GroupsChosen = ($GroupsChosen+' groups chosen')
                $NodeChannel = if([string]::IsNullOrEmpty($data.autoupgradeprofile.nodeosupgradechannel)){'None'}else{$data.autoupgradeprofile.nodeosupgradechannel}
                $UpgradeChannel = if([string]::IsNullOrEmpty($data.autoUpgradeProfile.upgradeChannel)){'Disabled'}else{$data.autoUpgradeProfile.upgradeChannel}
                $NetPolicy = if(![string]::IsNullOrEmpty($data.networkProfile.networkPolicy)){$data.networkProfile.networkPolicy}else{'None'}
                $PubliAccess = if([string]::IsNullOrEmpty($data.publicNetworkAccess)){'Enabled'}else{if($data.publicNetworkAccess -eq 'Disabled'){'Disabled'}else{'Enabled'}}
                $Identity = if(![string]::IsNullOrEmpty($data.identityprofile.kubeletidentity.resourceid)){$data.identityprofile.kubeletidentity.resourceid.split('/')[8]}else{''}
                $Ingress = if([string]::IsNullOrEmpty($data.addonProfiles.ingressApplicationGateway.config.applicationGatewayName)){'Not enabled'}else{$data.addonProfiles.ingressApplicationGateway.config.applicationGatewayName}
                $PrivateCluster = if([string]::IsNullOrEmpty($data.apiServerAccessProfile.enablePrivateCluster)){$false}else{$data.apiServerAccessProfile.enablePrivateCluster}
                foreach ($2 in $data.agentPoolProfiles) {
                        $AutoScale = if([string]::IsNullOrEmpty($2.enableAutoScaling)){$false}else{if($2.enableautoscaling -eq $true){$true}else{$false}}
                        $AVZone = if([string]::IsNullOrEmpty($2.availabilityZones)){'None'}else{[string]$2.availabilityZones}

                        $Taints = if ($2.nodetaints.count -gt 1) { $2.nodetaints | ForEach-Object { $_ + ' ,' } }else { $2.nodetaints }
                        $Taints = [string]$Taints
                        $Taints = if ($Taints -like '* ,*') { $Taints -replace ".$" }else { $Taints }

                        $Labels = if ($2.nodelabels.count -gt 1) { $2.nodelabels | ForEach-Object { $_ + ' ,' } }else { $2.nodelabels }
                        $Labels = [string]$Labels
                        $Labels = if ($Labels -like '* ,*') { $Labels -replace ".$" }else { $Labels }

                        # Extra VM Details
                        $VMExtraDetail = $VMExtraDetails.properties | Where-Object {$_.Location -eq $1.location}
                        $VMExtraDetail = $VMExtraDetail.SKUs | Where-Object {$_.Name -eq $2.vmSize}

                        foreach ($Capability in $VMExtraDetail.Capabilities) {
                            if ($Capability.Name -eq 'vCPUs') {$vCPUs = $Capability.Value}
                            if ($Capability.Name -eq 'vCPUsPerCore') {$vCPUsPerCore = $Capability.Value}
                            if ($Capability.Name -eq 'MemoryGB') {$RAM = $Capability.Value}
                        }

                        # Quotas
                        $Size = $VMExtraDetail.Family
                        $Quota = $VMQuotas.properties | Where-Object {$_.SubId -eq $1.subscriptionId}
                        $Quota = $Quota | Where-Object {$_.Location -eq $1.location}
                        $RemainingQuota = (($Quota.Data | Where-Object {$_.Name.Value -eq $Size}).Limit - ($Quota.Data | Where-Object {$_.Name.Value -eq $Size}).CurrentValue)


                        foreach ($Tag in $Tags) {
                            $obj = @{
                                'ID'                                            = $1.id;
                                'Subscription'                                  = $sub1.Name;
                                'Resource Group'                                = $1.RESOURCEGROUP;
                                'Clusters'                                      = $1.NAME;
                                'Location'                                      = $1.LOCATION;
                                'Retiring Feature'                              = $RetiringFeature;
                                'Retiring Date'                                 = $RetiringDate;
                                'AKS Pricing Tier'                              = $1.sku.tier;
                                'Kubernetes Version'                            = [string]$data.kubernetesVersion;
                                'Cluster Power State'                           = $data.powerstate.code;
                                'Role-Based Access Control'                     = $data.enableRBAC;
                                'AAD Enabled'                                   = if ($data.aadProfile) { $true }else { $false };
                                'Kubernetes Local Accounts'                     = $LocalAccounts;
                                'Cluster Admin ClusterRoleBinding'              = $GroupsChosen;
                                'Network Type (Plugin)'                         = $NetworkPlugin;
                                'Plugin Mode'                                   = $data.networkprofile.networkpluginmode;
                                'Pod CIDR'                                      = $data.networkProfile.podCidr;
                                'Network Policy'                                = $NetPolicy;
                                'Outbound Type'                                 = $data.networkProfile.outboundType;
                                'Infrastructure Resource Group'                 = $data.noderesourcegroup;
                                'Cluster Managed Identity'                      = $Identity;
                                'App Gateway Ingress Controller'                = $Ingress;                        
                                'Private Cluster'                               = $PrivateCluster;
                                'Private Cluster FQDN'                          = $data.privatefqdn;
                                'Public Network Access'                         = $PubliAccess;
                                'Automatic Upgrade Type'                        = $UpgradeChannel;
                                'Node Security Channel Type'                    = $NodeChannel;
                                'Container Insights'                            = $Insights;                    
                                'API Server Address'                            = $data.fqdn
                                'Node Pool Name'                                = $2.name;
                                'Node Pool Power State'                         = $2.powerstate.code;
                                'Node Pool Version'                             = [string]$2.orchestratorVersion;
                                'Node Pool Mode'                                = $2.mode;
                                'Node Pool OS Type'                             = $2.osType;
                                'Node Pool OS'                                  = $2.ossku;
                                'Node Pool Image'                               = $2.nodeimageversion;
                                'Node Pool Size'                                = $2.vmSize;
                                'vCPUs (Per Node)'                              = $vCPUs;
                                'vCPUs Per Core (Per Node)'                     = $vCPUsPerCore;
                                'RAM (GB) Per Node'                             = $RAM;
                                'Remaining Quota'                               = $RemainingQuota;
                                'OS Disk Size (GB)'                             = $2.osDiskSizeGB;
                                'Target Nodes'                                  = $2.count;
                                'Availability Zones'                            = $AVZone;
                                'Zones Available in the Region'                 = [string]$VMExtraDetail.LocationInfo.ZoneDetails.Name;
                                'Autoscale'                                     = $AutoScale;
                                'Autoscale Minimum Node Count'                  = $2.minCount;
                                'Autoscale Maximum Node Count'                  = $2.maxCount;
                                'Max Pods Per Node'                             = $2.maxPods;
                                'Virtual Network'                               = if($2.vnetSubnetID){$2.vnetSubnetID.split('/')[8]}else{$false}
                                'Subnet'                                        = if($2.vnetSubnetID){$2.vnetSubnetID.split('/')[10]}else{$false}
                                'Enable Node Public IP'                         = $2.enableNodePublicIP;
                                'Taints'                                        = $Taints;
                                'Labels'                                        = $Labels;
                                'Resource U'                                    = $ResUCount;
                                'Tag Name'                                      = [string]$Tag.Name;
                                'Tag Value'                                     = [string]$Tag.Value
                            }
                            $obj
                            if ($ResUCount -eq 1) { $ResUCount = 0 } 
                        }                   
                }
            }
            $tmp
        }
}

<######## Resource Excel Reporting Begins Here ########>

Else
{
    <######## $SmaResources.(RESOURCE FILE NAME) ##########>

    if($SmaResources)
    {
        $SheetName = 'AKS'

        $TableName = ('AKSTable_'+($SmaResources.id | Select-Object -Unique).count)

        $Style = @()
        $Style += New-ExcelStyle -HorizontalAlignment Center -AutoSize
        $Style += New-ExcelStyle -HorizontalAlignment Left -Range AZ:BA -Width 90 -WrapText 

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Clusters')
        $Exc.Add('Location')
        $Exc.Add('Retiring Feature')
        $Exc.Add('Retiring Date')
        $Exc.Add('AKS Pricing Tier')
        $Exc.Add('Kubernetes Version')
        $Exc.Add('Cluster Power State')
        $Exc.Add('Role-Based Access Control')
        $Exc.Add('AAD Enabled')
        $Exc.Add('Kubernetes Local Accounts')
        $Exc.Add('Cluster Admin ClusterRoleBinding')
        $Exc.Add('Network Type (Plugin)')
        $Exc.Add('Plugin Mode')
        $Exc.Add('Pod CIDR')
        $Exc.Add('Network Policy')
        $Exc.Add('Outbound Type')
        $Exc.Add('Infrastructure Resource Group')
        $Exc.Add('Cluster Managed Identity')
        $Exc.Add('App Gateway Ingress Controller')
        $Exc.Add('Private Cluster')
        $Exc.Add('Private Cluster FQDN')
        $Exc.Add('Public Network Access')
        $Exc.Add('Automatic Upgrade Type')
        $Exc.Add('Node Security Channel Type')
        $Exc.Add('Container Insights')
        $Exc.Add('API Server Address')
        $Exc.Add('Node Pool Name')
        $Exc.Add('Node Pool Power State')
        $Exc.Add('Node Pool Version')
        $Exc.Add('Node Pool Mode')
        $Exc.Add('Node Pool OS Type')
        $Exc.Add('Node Pool OS')
        $Exc.Add('Node Pool Image')
        $Exc.Add('Node Pool Size')
        $Exc.Add('Target Nodes')
        $Exc.Add('vCPUs (Per Node)')
        $Exc.Add('vCPUs Per Core (Per Node)')
        $Exc.Add('RAM (GB) Per Node')
        $Exc.Add('Remaining Quota')
        $Exc.Add('Availability Zones')
        $Exc.Add('Zones Available in the Region')
        $Exc.Add('Max Pods Per Node')
        $Exc.Add('OS Disk Size (GB)')
        $Exc.Add('Autoscale')
        $Exc.Add('Autoscale Minimum Node Count')
        $Exc.Add('Autoscale Maximum Node Count')
        $Exc.Add('Virtual Network')
        $Exc.Add('Subnet')
        $Exc.Add('Enable Node Public IP')
        $Exc.Add('Taints')
        $Exc.Add('Labels')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $noNumberConversion = @()
        $noNumberConversion += 'Kubernetes Version'
        $noNumberConversion += 'Node Pool Version'

        $SmaResources | 
        ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        Export-Excel -Path $File -WorksheetName $SheetName -AutoSize -TableName $TableName -MaxAutoSizeRows 50 -TableStyle $tableStyle -ConditionalText $condtxt -Numberformat '0' -Style $Style -NoNumberConversion $noNumberConversion 


        $excel = Open-ExcelPackage -Path $File

        $sheet = $excel.Workbook.Worksheets[$SheetName]

        #AKS Version
        Add-ConditionalFormatting -WorkSheet $sheet -RuleType Between -ConditionValue "1.29.0" -ConditionValue2 "1.31.99" -Address H:H -BackgroundColor "Yellow"
        Add-ConditionalFormatting -WorkSheet $sheet -RuleType Between -ConditionValue "1.20.0" -ConditionValue2 "1.28.99" -Address H:H -BackgroundColor 'LightPink' -ForegroundColor 'DarkRed'

        #NodePool Version
        Add-ConditionalFormatting -WorkSheet $sheet -RuleType Between -ConditionValue "1.29.0" -ConditionValue2 "1.31.99" -Address AE:AE -BackgroundColor "Yellow"
        Add-ConditionalFormatting -WorkSheet $sheet -RuleType Between -ConditionValue "1.20.0" -ConditionValue2 "1.28.99" -Address AE:AE -BackgroundColor 'LightPink' -ForegroundColor 'DarkRed'

        #Remaining Quota
        Add-ConditionalFormatting -WorkSheet $sheet -RuleType Between -ConditionValue 50 -ConditionValue2 100 -Address AO:AO -BackgroundColor "Yellow"
        Add-ConditionalFormatting -WorkSheet $sheet -RuleType Between -ConditionValue 1 -ConditionValue2 50 -Address AO:AO -BackgroundColor 'LightPink' -ForegroundColor 'DarkRed'

        #Pricing Tier
        Add-ConditionalFormatting -WorkSheet $sheet -RuleType ContainsText -ConditionValue 'Free' -Address G:G -BackgroundColor 'Yellow'

        #Local Accounts
        Add-ConditionalFormatting -WorkSheet $sheet -RuleType ContainsText -ConditionValue 'true' -Address L:L -BackgroundColor 'LightPink' -ForegroundColor 'DarkRed'

        #Private Cluster
        Add-ConditionalFormatting -WorkSheet $sheet -RuleType ContainsText -ConditionValue 'false' -Address V:V -BackgroundColor 'LightPink' -ForegroundColor 'DarkRed'

        #Public Network Access
        Add-ConditionalFormatting -WorkSheet $sheet -RuleType ContainsText -ConditionValue 'Enabled' -Address X:X -BackgroundColor 'LightPink' -ForegroundColor 'DarkRed'

        #Automatic Upgrades
        Add-ConditionalFormatting -WorkSheet $sheet -RuleType ContainsText -ConditionValue 'Disabled' -Address Y:Y -BackgroundColor 'Yellow'

        #Node Security Channel
        Add-ConditionalFormatting -WorkSheet $sheet -RuleType ContainsText -ConditionValue 'none' -Address Z:Z -BackgroundColor 'Yellow'

        #Container Insights
        Add-ConditionalFormatting -WorkSheet $sheet -RuleType ContainsText -ConditionValue 'false' -Address AA:AA -BackgroundColor 'LightPink' -ForegroundColor 'DarkRed'

        #NodeSize
        Add-ConditionalFormatting -WorkSheet $sheet -RuleType ContainsText -ConditionValue '_b' -Address AJ:AJ -BackgroundColor 'LightPink' -ForegroundColor 'DarkRed'

        #Av Zone
        Add-ConditionalFormatting -WorkSheet $sheet -RuleType ContainsText -ConditionValue 'None' -Address AP:AP -BackgroundColor 'LightPink' -ForegroundColor 'DarkRed'

        #AutoScale
        Add-ConditionalFormatting -WorkSheet $sheet -RuleType ContainsText -ConditionValue 'false' -Address AT:AT -BackgroundColor 'Yellow'

        $null = $excel.$SheetName.Cells["G1"].AddComment("Microsoft recommends Free Pricing tier only for non-production workloads", "Azure Resource Inventory")
        $excel.$SheetName.Cells["G1"].Hyperlink = 'https://learn.microsoft.com/en-us/azure/aks/free-standard-pricing-tiers'

        $null = $excel.$SheetName.Cells["H1"].AddComment("AKS follows 12 months of support for a generally available (GA) Kubernetes version. To read more about our support policy for Kubernetes versioning", "Azure Resource Inventory")
        $excel.$SheetName.Cells["H1"].Hyperlink = 'https://learn.microsoft.com/en-us/azure/aks/supported-kubernetes-versions?tabs=azure-cli#aks-kubernetes-release-calendar'

        $null = $excel.$SheetName.Cells["L1"].AddComment("Local accounts are enabled by default. Even when you enable RBAC or Microsoft Entra integration", "Azure Resource Inventory")
        $excel.$SheetName.Cells["L1"].Hyperlink = 'https://learn.microsoft.com/en-us/azure/aks/manage-local-accounts-managed-azure-ad'

        $null = $excel.$SheetName.Cells["V1"].AddComment("By default AKS Control Plane is exposed on a public endpoint accessible over the internet. Organizations who want to disable this public endpoint, can leverage the private cluster feature", "Azure Resource Inventory")
        $excel.$SheetName.Cells["V1"].Hyperlink = 'https://techcommunity.microsoft.com/t5/core-infrastructure-and-security/public-and-private-aks-clusters-demystified/ba-p/3716838'

        $null = $excel.$SheetName.Cells["Y1"].AddComment("By enabling auto-upgrade, you can ensure your clusters are up to date and don't miss the latest features or patches from AKS and upstream Kubernetes.", "Azure Resource Inventory")
        $excel.$SheetName.Cells["Y1"].Hyperlink = 'https://learn.microsoft.com/en-us/azure/aks/auto-upgrade-cluster?tabs=azure-cli#why-use-cluster-auto-upgrade'

        $null = $excel.$SheetName.Cells["Z1"].AddComment("Node-level OS security updates are released at a faster rate than Kubernetes patch or minor version updates. The node OS auto-upgrade channel grants you flexibility and enables a customized strategy for node-level OS security updates.", "Azure Resource Inventory")
        $excel.$SheetName.Cells["Z1"].Hyperlink = 'https://learn.microsoft.com/en-us/azure/aks/auto-upgrade-node-os-image?tabs=azure-cli#interactions-between-node-os-auto-upgrade-and-cluster-auto-upgrade'

        $null = $excel.$SheetName.Cells["AA1"].AddComment("Container insights collects metric data from your cluster in addition to logs. This functionality has been replaced by Azure Monitor managed service for Prometheus. You can analyze that data using built-in dashboards in Managed Grafana and alert on them using prebuilt Prometheus alert rules.", "Azure Resource Inventory")
        $excel.$SheetName.Cells["AA1"].Hyperlink = 'https://learn.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-overview'

        $null = $excel.$SheetName.Cells["AJ1"].AddComment("System node pools require a VM SKU of at least 2 vCPUs and 4 GB memory. But burstable-VM(B series) isn't recommended", "Azure Resource Inventory")
        $excel.$SheetName.Cells["AJ1"].Hyperlink = 'https://learn.microsoft.com/en-us/azure/aks/use-system-pools?tabs=azure-cli#system-and-user-node-pools'

        $null = $excel.$SheetName.Cells["AP1"].AddComment("An AKS cluster distributes resources, such as nodes and storage, across logical sections of underlying Azure infrastructure. Using availability zones physically separates nodes from other nodes deployed to different availability zones. AKS clusters deployed with multiple availability zones configured across a cluster provide a higher level of availability to protect against a hardware failure or a planned maintenance event.", "Azure Resource Inventory")
        $excel.$SheetName.Cells["AP1"].Hyperlink = 'https://learn.microsoft.com/en-us/azure/aks/availability-zones-overview'

        $null = $excel.$SheetName.Cells["AT1"].AddComment("The cluster autoscaler component can watch for pods in your cluster that can't be scheduled because of resource constraints", "Azure Resource Inventory")
        $excel.$SheetName.Cells["AT1"].Hyperlink = 'https://learn.microsoft.com/en-us/azure/aks/cluster-autoscaler'

        Close-ExcelPackage $excel

    }
}