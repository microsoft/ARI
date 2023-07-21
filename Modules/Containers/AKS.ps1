<#
.Synopsis
Inventory for Azure Kubernetes Service (AKS)

.DESCRIPTION
This script consolidates information for all microsoft.containerservice/managedclusters resource provider in $Resources variable. 
Excel Sheet Name: AKS

.Link
https://github.com/microsoft/ARI/Modules/Compute/AKS.ps1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.1.1
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Task ,$File, $SmaResources, $TableStyle,$Unsupported)

If ($Task -eq 'Processing')
{
    <######### Insert the resource extraction here ########>

        $AKS = $Resources | Where-Object {$_.TYPE -eq 'microsoft.containerservice/managedclusters'}

    <######### Insert the resource Process here ########>

    if($AKS)
        {
            $tmp = @()

            foreach ($1 in $AKS) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                if([string]::IsNullOrEmpty($data.addonProfiles.omsagent.config.logAnalyticsWorkspaceResourceID)){$Insights = $false}else{$Insights = $data.addonProfiles.omsagent.config.logAnalyticsWorkspaceResourceID.split('/')[8]}
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                foreach ($2 in $data.agentPoolProfiles) {
                        $AutoScale = if([string]::IsNullOrEmpty($2.enableAutoScaling)){$false}else{$true}
                        foreach ($Tag in $Tags) {
                            $obj = @{
                                'ID'                         = $1.id;
                                'Subscription'               = $sub1.Name;
                                'Resource Group'             = $1.RESOURCEGROUP;
                                'Clusters'                   = $1.NAME;
                                'Location'                   = $1.LOCATION;
                                'Kubernetes Version'         = $data.kubernetesVersion;
                                'Role-Based Access Control'  = $data.enableRBAC;
                                'AAD Enabled'                = if ($data.aadProfile) { $true }else { $false };
                                'Network Type'               = $data.networkProfile.networkPlugin;
                                'Ingress Controller'         = $data.addonProfiles.ingressApplicationGateway.config.applicationGatewayName;                        
                                'Private Cluster'            = $data.apiServerAccessProfile.enablePrivateCluster;
                                'Container Insights'         = $Insights;                    
                                'Outbound Type'              = $data.networkProfile.outboundType;
                                'LoadBalancer Sku'           = $data.networkProfile.loadBalancerSku;
                                'Docker Pod Cidr'            = $data.networkProfile.podCidr;
                                'Service Cidr'               = $data.networkProfile.serviceCidr;
                                'Docker Bridge Cidr'         = $data.networkProfile.dockerBridgeCidr;                   
                                'Network DNS Service IP'     = $data.networkProfile.dnsServiceIP;
                                'FQDN'                       = $data.fqdn
                                'HTTP Application Routing'   = if ($data.addonProfiles.httpapplicationrouting.enabled) { $true }else { $false };
                                'Node Pool Name'             = $2.name;
                                'Pool Profile Type'          = $2.type;
                                'Pool Mode'                  = $2.mode;
                                'Pool OS'                    = $2.osType;
                                'Node Size'                  = $2.vmSize;
                                'OS Disk Size (GB)'          = $2.osDiskSizeGB;
                                'Nodes'                      = $2.count;
                                'Zones'                      = [string]$2.availabilityZones;
                                'Autoscale'                  = $AutoScale;
                                'Autoscale Max'              = $2.maxCount;
                                'Autoscale Min'              = $2.minCount;
                                'Max Pods Per Node'          = $2.maxPods;
                                'Virtual Network'            = if($2.vnetSubnetID){$2.vnetSubnetID.split('/')[8]}else{$false}
                                'VNET Subnet'                = if($2.vnetSubnetID){$2.vnetSubnetID.split('/')[10]}else{$false}
                                'Orchestrator Version'       = $2.orchestratorVersion;
                                'Enable Node Public IP'      = $2.enableNodePublicIP;
                                'Resource U'                 = $ResUCount;
                                'Tag Name'                   = [string]$Tag.Name;
                                'Tag Value'                  = [string]$Tag.Value
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

Else
{
    <######## $SmaResources.(RESOURCE FILE NAME) ##########>

    if($SmaResources.AKS)
    {

        $TableName = ('AKSTable_'+($SmaResources.AKS.id | Select-Object -Unique).count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'   

        $condtxt = @()
        #AKS
        $condtxt += New-ConditionalText 1.24 -Range E:E
        $condtxt += New-ConditionalText 1.23 -Range E:E
        $condtxt += New-ConditionalText 1.22 -Range E:E
        $condtxt += New-ConditionalText 1.21 -Range E:E
        #Orchestrator
        $condtxt += New-ConditionalText 1.24 -Range AH:AH
        $condtxt += New-ConditionalText 1.23 -Range AH:AH
        $condtxt += New-ConditionalText 1.22 -Range AH:AH
        $condtxt += New-ConditionalText 1.21 -Range AH:AH
        #NodeSize
        $condtxt += New-ConditionalText _b -Range X:X
        #AutoScale
        $condtxt += New-ConditionalText false -Range AB:AB

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Clusters')
        $Exc.Add('Location')
        $Exc.Add('Kubernetes Version')
        $Exc.Add('Role-Based Access Control')
        $Exc.Add('AAD Enabled')
        $Exc.Add('Network Type')
        $Exc.Add('Ingress Controller')
        $Exc.Add('Private Cluster')
        $Exc.Add('Container Insights')
        $Exc.Add('Outbound Type')
        $Exc.Add('LoadBalancer Sku')
        $Exc.Add('Docker Pod Cidr')
        $Exc.Add('Service Cidr')
        $Exc.Add('Docker Bridge Cidr')   
        $Exc.Add('Network DNS Service IP')
        $Exc.Add('FQDN')
        $Exc.Add('HTTP Application Routing')
        $Exc.Add('Node Pool Name')
        $Exc.Add('Pool Profile Type')
        $Exc.Add('Pool Mode')
        $Exc.Add('Pool OS')
        $Exc.Add('Node Size')
        $Exc.Add('OS Disk Size (GB)')
        $Exc.Add('Nodes')
        $Exc.Add('Zones')
        $Exc.Add('Autoscale')
        $Exc.Add('Autoscale Max')
        $Exc.Add('Autoscale Min')
        $Exc.Add('Max Pods Per Node')
        $Exc.Add('Virtual Network')
        $Exc.Add('VNET Subnet')
        $Exc.Add('Orchestrator Version')
        $Exc.Add('Enable Node Public IP')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $ExcelVar = $SmaResources.AKS 

        $ExcelVar | 
        ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        Export-Excel -Path $File -WorksheetName 'AKS' -AutoSize -TableName $TableName -MaxAutoSizeRows 50 -TableStyle $tableStyle -ConditionalText $condtxt -Numberformat '0' -Style $Style   
        
        $excel = Open-ExcelPackage -Path $File -KillExcel

        $null = $excel.'AKS'.Cells["E1"].AddComment("AKS follows 12 months of support for a generally available (GA) Kubernetes version. To read more about our support policy for Kubernetes versioning", "Azure Resource Inventory")
        $excel.'AKS'.Cells["E1"].Hyperlink = 'https://learn.microsoft.com/en-us/azure/aks/supported-kubernetes-versions?tabs=azure-cli#aks-kubernetes-release-calendar'
        $null = $excel.'AKS'.Cells["X1"].AddComment("System node pools require a VM SKU of at least 2 vCPUs and 4 GB memory. But burstable-VM(B series) isn't recommended", "Azure Resource Inventory")
        $excel.'AKS'.Cells["X1"].Hyperlink = 'https://learn.microsoft.com/en-us/azure/aks/use-system-pools?tabs=azure-cli#system-and-user-node-pools'
        $null = $excel.'AKS'.Cells["AB1"].AddComment("The cluster autoscaler component can watch for pods in your cluster that can't be scheduled because of resource constraints", "Azure Resource Inventory")
        $excel.'AKS'.Cells["AB1"].Hyperlink = 'https://learn.microsoft.com/en-us/azure/aks/cluster-autoscaler'

        Close-ExcelPackage $excel
    }
}