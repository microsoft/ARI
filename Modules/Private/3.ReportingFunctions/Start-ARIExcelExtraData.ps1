<#
.Synopsis
Module for Extra Excel Details

.DESCRIPTION
This script open the Excel file after it has all the Resource sheets and adds extra details.

.Link
https://github.com/microsoft/ARI/Modules/Private/3.ReportingFunctions/Start-ARIExcelExtraData.ps1

.COMPONENT
This PowerShell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.6.0
First Release Date: 15th Oct, 2024
Authors: Claudio Merola
#>
function Start-ARIExcelExtraData {
    Param($File)

    $excel = Open-ExcelPackage -Path $File

    foreach ($SheetName in $excel.Workbook.Worksheets.Name) {

        if($SheetName -eq 'Event Hubs')
            {
                $null = $excel.$SheetName.Cells["L1"].AddComment("The Auto-inflate feature of Event Hubs automatically scales up by increasing the number of throughput units, to meet usage needs. Increasing throughput units prevents throttling scenarios.", "Azure Resource Inventory")
                $excel.$SheetName.Cells["L1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/event-hubs/event-hubs-auto-inflate'
            }

        <################################################################### RESOURCE ###################################################################>

        if($SheetName -eq 'Virtual Machines')
            {
                $sheet = $excel.Workbook.Worksheets[$SheetName]

                Add-ConditionalFormatting -WorkSheet $sheet -RuleType Between -ConditionValue 50 -ConditionValue2 100 -Address E:E -BackgroundColor "Yellow"
                Add-ConditionalFormatting -WorkSheet $sheet -RuleType Between -ConditionValue 1 -ConditionValue2 50 -Address E:E -BackgroundColor 'LightPink' -ForegroundColor 'DarkRed'

                $null = $excel.$SheetName.Cells["AA1"].AddComment("Boot diagnostics is a debugging feature for Azure virtual machines (VM) that allows diagnosis of VM boot failures.", "Azure Resource Inventory")
                $excel.$SheetName.Cells["AA1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/virtual-machines/boot-diagnostics'

                $null = $excel.$SheetName.Cells["AB1"].AddComment("Is recommended to install Performance Diagnostics Agent in every Azure Virtual Machine upfront. The agent is only used when triggered by the console and may save time in an event of performance struggling.", "Azure Resource Inventory")
                $excel.$SheetName.Cells["AB1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/virtual-machines/troubleshooting/performance-diagnostics'

                $null = $excel.$SheetName.Cells["AC1"].AddComment("We recommend that you use Azure Monitor to gain visibility into your resource's health.", "Azure Resource Inventory")
                $excel.$SheetName.Cells["AC1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/security/fundamentals/iaas#monitor-vm-performance'

                $null = $excel.$SheetName.Cells["AN1"].AddComment("Use a network security group to protect against unsolicited traffic into Azure subnets. Network security groups are simple, stateful packet inspection devices that use the 5-tuple approach (source IP, source port, destination IP, destination port, and layer 4 protocol) to create allow/deny rules for network traffic.", "Azure Resource Inventory")
                $excel.$SheetName.Cells["AN1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/security/fundamentals/network-best-practices#logically-segment-subnets'

                $null = $excel.$SheetName.Cells["AQ1"].AddComment("Accelerated networking enables single root I/O virtualization (SR-IOV) to a VM, greatly improving its networking performance. This high-performance path bypasses the host from the datapath, reducing latency, jitter, and CPU utilization.", "Azure Resource Inventory")
                $excel.$SheetName.Cells["AQ1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/virtual-network/create-vm-accelerated-networking-cli'
            }

        <################################################################### RESOURCE ###################################################################>

        if($SheetName -eq 'AKS')
            {
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
            }

        <################################################################### RESOURCE ###################################################################>

        if($SheetName -eq 'MySQL')
            {
                $null = $excel.$SheetName.Cells["H1"].AddComment("It's important to be aware of upcoming Azure services and feature retirements to understand their impact on your workloads and plan migration.", "Azure Resource Inventory")
                $excel.$SheetName.Cells["H1"].Hyperlink = 'https://learn.microsoft.com/en-us/azure/advisor/advisor-how-to-plan-migration-workloads-service-retirement'
            }

        <################################################################### RESOURCE ###################################################################>

        if($SheetName -eq 'PostgreSQL')
            {
                $null = $excel.$SheetName.Cells["J1"].AddComment("It's important to be aware of upcoming Azure services and feature retirements to understand their impact on your workloads and plan migration.", "Azure Resource Inventory")
                $excel.$SheetName.Cells["J1"].Hyperlink = 'https://learn.microsoft.com/en-us/azure/advisor/advisor-how-to-plan-migration-workloads-service-retirement'
            }

        <################################################################### RESOURCE ###################################################################>

        if($SheetName -eq 'Redis Cache')
            {
                $null = $excel.$SheetName.Cells["F1"].AddComment("It's important to be aware of upcoming Azure services and feature retirements to understand their impact on your workloads and plan migration.", "Azure Resource Inventory")
                $excel.$SheetName.Cells["F1"].Hyperlink = 'https://learn.microsoft.com/en-us/azure/advisor/advisor-how-to-plan-migration-workloads-service-retirement'
            }

        <################################################################### RESOURCE ###################################################################>

        if($SheetName -eq 'App Gateway')
            {
                $null = $excel.$SheetName.Cells["F1"].AddComment("It's important to be aware of upcoming Azure services and feature retirements to understand their impact on your workloads and plan migration.", "Azure Resource Inventory")
                $excel.$SheetName.Cells["F1"].Hyperlink = 'https://learn.microsoft.com/en-us/azure/advisor/advisor-how-to-plan-migration-workloads-service-retirement'
            }

        <################################################################### RESOURCE ###################################################################>

        if($SheetName -eq 'Load Balancers')
            {
                $null = $excel.$SheetName.Cells["E1"].AddComment("No SLA is provided for Basic Load Balancer!", "Azure Resource Inventory")
                $excel.$SheetName.Cells["E1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/load-balancer/skus'

                $null = $excel.$SheetName.Cells["F1"].AddComment("It's important to be aware of upcoming Azure services and feature retirements to understand their impact on your workloads and plan migration.", "Azure Resource Inventory")
                $excel.$SheetName.Cells["F1"].Hyperlink = 'https://learn.microsoft.com/en-us/azure/advisor/advisor-how-to-plan-migration-workloads-service-retirement'

                $null = $excel.$SheetName.Cells["H1"].AddComment("Orphaned Load Balancer is when there is no Backend Pool at all associated with the Load Balancer and the Load Balancer may be deleted to save costs.", "Azure Resource Inventory")
                $excel.$SheetName.Cells["H1"].Hyperlink = 'https://learn.microsoft.com/en-us/azure/load-balancer/backend-pool-management'

                $null = $excel.$SheetName.Cells["I1"].AddComment("'Not In Use' Load Balancer is when there is a Backend Pool in the Load Balancer but no IP Address or Resources are associated with the Backend Pools and the Load Balancer should be investigated to be deleted to save costs.", "Azure Resource Inventory")
                $excel.$SheetName.Cells["I1"].Hyperlink = 'https://learn.microsoft.com/en-us/azure/load-balancer/backend-pool-management'
            }

        <################################################################### RESOURCE ###################################################################>

        if($SheetName -eq 'Public IPs')
            {
                $null = $excel.$SheetName.Cells["G1"].AddComment("It's important to be aware of upcoming Azure services and feature retirements to understand their impact on your workloads and plan migration.", "Azure Resource Inventory")
                $excel.$SheetName.Cells["G1"].Hyperlink = 'https://learn.microsoft.com/en-us/azure/advisor/advisor-how-to-plan-migration-workloads-service-retirement'
            }

        <################################################################### RESOURCE ###################################################################>

        if($SheetName -eq 'Virtual Networks')
            {
                $sheet = $excel.Workbook.Worksheets[$SheetName]

                Add-ConditionalFormatting -WorkSheet $sheet -RuleType Between -ConditionValue 20 -ConditionValue2 40 -Address N:N -BackgroundColor "Yellow"
                Add-ConditionalFormatting -WorkSheet $sheet -RuleType Between -ConditionValue 1 -ConditionValue2 20 -Address N:N -BackgroundColor 'LightPink' -ForegroundColor 'DarkRed'

                $null = $excel.$SheetName.Cells["F1"].AddComment("Azure DDoS Protection Standard, combined with application design best practices, provides enhanced DDoS mitigation features to defend against DDoS attacks.", "Azure Resource Inventory")
                $excel.$SheetName.Cells["F1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/ddos-protection/ddos-protection-overview'
            }

        <################################################################### RESOURCE ###################################################################>

        if($SheetName -eq 'Storage Accounts')
            {
                $null = $excel.$SheetName.Cells["K1"].AddComment("Is recommended that you configure your storage account to accept requests from secure connections only by setting the Secure transfer required property for the storage account.", "Azure Resource Inventory")
                $excel.$SheetName.Cells["K1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/storage/common/storage-require-secure-transfer'

                $null = $excel.$SheetName.Cells["L1"].AddComment("When a container is configured for anonymous access, any client can read data in that container. Anonymous access presents a potential security risk, so if your scenario does not require it, we recommend that you remediate anonymous access for the storage account.", "Azure Resource Inventory")
                $excel.$SheetName.Cells["L1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/storage/blobs/anonymous-read-access-configure?tabs=portal'

                $null = $excel.$SheetName.Cells["M1"].AddComment("By default, Azure Storage accounts permit clients to send and receive data with the oldest version of TLS, TLS 1.0, and above. To enforce stricter security measures, you can configure your storage account to require that clients send and receive data with a newer version of TLS", "Azure Resource Inventory")
                $excel.$SheetName.Cells["M1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/storage/common/transport-layer-security-configure-minimum-version?tabs=portal'

                $null = $excel.$SheetName.Cells["I1"].AddComment("It's important to be aware of upcoming Azure services and feature retirements to understand their impact on your workloads and plan migration.", "Azure Resource Inventory")
                $excel.$SheetName.Cells["I1"].Hyperlink = 'https://learn.microsoft.com/en-us/azure/advisor/advisor-how-to-plan-migration-workloads-service-retirement'
            }

        <################################################################### RESOURCE ###################################################################>

        if($SheetName -eq 'Disks')
            {
                $null = $excel.$SheetName.Cells["F1"].AddComment("When you delete a virtual machine (VM) in Azure, by default, any disks that are attached to the VM aren't deleted. After a VM is deleted, you will continue to pay for unattached disks.", "Azure Resource Inventory")
                $excel.$SheetName.Cells["F1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/virtual-machines/windows/find-unattached-disks'
            }


        <################################################################### RESOURCE ###################################################################>

        if($SheetName -eq 'AdvisorScore')
            {
                $sheet = $excel.Workbook.Worksheets[$SheetName]

                Add-ConditionalFormatting -WorkSheet $sheet -RuleType Between -ConditionValue 1 -ConditionValue2 80 -Address C:C -BackgroundColor 'LightPink' -ForegroundColor 'DarkRed'
                Add-ConditionalFormatting -WorkSheet $sheet -RuleType Between -ConditionValue 1 -ConditionValue2 70 -Address F:F -BackgroundColor 'LightPink' -ForegroundColor 'DarkRed'
            }

        }


    Close-ExcelPackage $excel

}