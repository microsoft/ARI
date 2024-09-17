function Start-ARIExcelHeaders {
    Param($file, $Debug)
    if ($Debug.IsPresent)
        {
            $DebugPreference = 'Continue'
            $ErrorActionPreference = 'Continue'
        }
    else
        {
            $ErrorActionPreference = "silentlycontinue"
        }

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Adding Header Comments.')
    $excel = Open-ExcelPackage -Path $File -KillExcel

    if($excel.'Event Hubs')
        {
            $null = $excel.'Event Hubs'.Cells["L1"].AddComment("The Auto-inflate feature of Event Hubs automatically scales up by increasing the number of throughput units, to meet usage needs. Increasing throughput units prevents throttling scenarios.", "Azure Resource Inventory")
            $excel.'Event Hubs'.Cells["L1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/event-hubs/event-hubs-auto-inflate'
        }

    <################################################################### RESOURCE ###################################################################>

    if($excel.'CloudServices')
        {
            $null = $excel.'CloudServices'.Cells["F1"].AddComment("It's important to be aware of upcoming Azure services and feature retirements to understand their impact on your workloads and plan migration.")
            $excel.'CloudServices'.Cells["F1"].Hyperlink = 'https://learn.microsoft.com/en-us/azure/advisor/advisor-how-to-plan-migration-workloads-service-retirement'
        }

    <################################################################### RESOURCE ###################################################################>

    if($excel.'Virtual Machines')
        {
            $null = $excel.'Virtual Machines'.Cells["N1"].AddComment("It's important to be aware of upcoming Azure services and feature retirements to understand their impact on your workloads and plan migration.", "Azure Resource Inventory")
            $excel.'Virtual Machines'.Cells["N1"].Hyperlink = 'https://learn.microsoft.com/en-us/azure/advisor/advisor-how-to-plan-migration-workloads-service-retirement'

            $null = $excel.'Virtual Machines'.Cells["R1"].AddComment("Boot diagnostics is a debugging feature for Azure virtual machines (VM) that allows diagnosis of VM boot failures.", "Azure Resource Inventory")
            $excel.'Virtual Machines'.Cells["R1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/virtual-machines/boot-diagnostics'

            $null = $excel.'Virtual Machines'.Cells["S1"].AddComment("Is recommended to install Performance Diagnostics Agent in every Azure Virtual Machine upfront. The agent is only used when triggered by the console and may save time in an event of performance struggling.", "Azure Resource Inventory")
            $excel.'Virtual Machines'.Cells["S1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/virtual-machines/troubleshooting/performance-diagnostics'

            $null = $excel.'Virtual Machines'.Cells["T1"].AddComment("We recommend that you use Azure Monitor to gain visibility into your resource's health.", "Azure Resource Inventory")
            $excel.'Virtual Machines'.Cells["T1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/security/fundamentals/iaas#monitor-vm-performance'

            $null = $excel.'Virtual Machines'.Cells["AF1"].AddComment("Use a network security group to protect against unsolicited traffic into Azure subnets. Network security groups are simple, stateful packet inspection devices that use the 5-tuple approach (source IP, source port, destination IP, destination port, and layer 4 protocol) to create allow/deny rules for network traffic.", "Azure Resource Inventory")
            $excel.'Virtual Machines'.Cells["AF1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/security/fundamentals/network-best-practices#logically-segment-subnets'

            $null = $excel.'Virtual Machines'.Cells["AI1"].AddComment("Accelerated networking enables single root I/O virtualization (SR-IOV) to a VM, greatly improving its networking performance. This high-performance path bypasses the host from the datapath, reducing latency, jitter, and CPU utilization.", "Azure Resource Inventory")
            $excel.'Virtual Machines'.Cells["AI1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/virtual-network/create-vm-accelerated-networking-cli'
        }

    <################################################################### RESOURCE ###################################################################>

    if($excel.'AKS')
        {
            $null = $excel.'AKS'.Cells["E1"].AddComment("Microsoft recommends Free Pricing tier only for non-production workloads", "Azure Resource Inventory")
            $excel.'AKS'.Cells["E1"].Hyperlink = 'https://learn.microsoft.com/en-us/azure/aks/free-standard-pricing-tiers'

            $null = $excel.'AKS'.Cells["F1"].AddComment("AKS follows 12 months of support for a generally available (GA) Kubernetes version. To read more about our support policy for Kubernetes versioning", "Azure Resource Inventory")
            $excel.'AKS'.Cells["F1"].Hyperlink = 'https://learn.microsoft.com/en-us/azure/aks/supported-kubernetes-versions?tabs=azure-cli#aks-kubernetes-release-calendar'

            $null = $excel.'AKS'.Cells["J1"].AddComment("Local accounts are enabled by default. Even when you enable RBAC or Microsoft Entra integration", "Azure Resource Inventory")
            $excel.'AKS'.Cells["J1"].Hyperlink = 'https://learn.microsoft.com/en-us/azure/aks/manage-local-accounts-managed-azure-ad'

            $null = $excel.'AKS'.Cells["T1"].AddComment("By default AKS Control Plane is exposed on a public endpoint accessible over the internet. Organizations who want to disable this public endpoint, can leverage the private cluster feature", "Azure Resource Inventory")
            $excel.'AKS'.Cells["T1"].Hyperlink = 'https://techcommunity.microsoft.com/t5/core-infrastructure-and-security/public-and-private-aks-clusters-demystified/ba-p/3716838'

            $null = $excel.'AKS'.Cells["W1"].AddComment("By enabling auto-upgrade, you can ensure your clusters are up to date and don't miss the latest features or patches from AKS and upstream Kubernetes.", "Azure Resource Inventory")
            $excel.'AKS'.Cells["W1"].Hyperlink = 'https://learn.microsoft.com/en-us/azure/aks/auto-upgrade-cluster?tabs=azure-cli#why-use-cluster-auto-upgrade'

            $null = $excel.'AKS'.Cells["X1"].AddComment("Node-level OS security updates are released at a faster rate than Kubernetes patch or minor version updates. The node OS auto-upgrade channel grants you flexibility and enables a customized strategy for node-level OS security updates.", "Azure Resource Inventory")
            $excel.'AKS'.Cells["X1"].Hyperlink = 'https://learn.microsoft.com/en-us/azure/aks/auto-upgrade-node-os-image?tabs=azure-cli#interactions-between-node-os-auto-upgrade-and-cluster-auto-upgrade'

            $null = $excel.'AKS'.Cells["Y1"].AddComment("Container insights collects metric data from your cluster in addition to logs. This functionality has been replaced by Azure Monitor managed service for Prometheus. You can analyze that data using built-in dashboards in Managed Grafana and alert on them using prebuilt Prometheus alert rules.", "Azure Resource Inventory")
            $excel.'AKS'.Cells["Y1"].Hyperlink = 'https://learn.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-overview'

            $null = $excel.'AKS'.Cells["AH1"].AddComment("System node pools require a VM SKU of at least 2 vCPUs and 4 GB memory. But burstable-VM(B series) isn't recommended", "Azure Resource Inventory")
            $excel.'AKS'.Cells["AH1"].Hyperlink = 'https://learn.microsoft.com/en-us/azure/aks/use-system-pools?tabs=azure-cli#system-and-user-node-pools'

            $null = $excel.'AKS'.Cells["AI1"].AddComment("An AKS cluster distributes resources, such as nodes and storage, across logical sections of underlying Azure infrastructure. Using availability zones physically separates nodes from other nodes deployed to different availability zones. AKS clusters deployed with multiple availability zones configured across a cluster provide a higher level of availability to protect against a hardware failure or a planned maintenance event.", "Azure Resource Inventory")
            $excel.'AKS'.Cells["AI1"].Hyperlink = 'https://learn.microsoft.com/en-us/azure/aks/availability-zones-overview'

            $null = $excel.'AKS'.Cells["AM1"].AddComment("The cluster autoscaler component can watch for pods in your cluster that can't be scheduled because of resource constraints", "Azure Resource Inventory")
            $excel.'AKS'.Cells["AM1"].Hyperlink = 'https://learn.microsoft.com/en-us/azure/aks/cluster-autoscaler'
        }

    <################################################################### RESOURCE ###################################################################>

    if($excel.'MySQL')
        {
            $null = $excel.'MySQL'.Cells["H1"].AddComment("It's important to be aware of upcoming Azure services and feature retirements to understand their impact on your workloads and plan migration.", "Azure Resource Inventory")
            $excel.'MySQL'.Cells["H1"].Hyperlink = 'https://learn.microsoft.com/en-us/azure/advisor/advisor-how-to-plan-migration-workloads-service-retirement'
        }

    <################################################################### RESOURCE ###################################################################>

    if($excel.'PostgreSQL')
        {
            $null = $excel.'PostgreSQL'.Cells["J1"].AddComment("It's important to be aware of upcoming Azure services and feature retirements to understand their impact on your workloads and plan migration.", "Azure Resource Inventory")
            $excel.'PostgreSQL'.Cells["J1"].Hyperlink = 'https://learn.microsoft.com/en-us/azure/advisor/advisor-how-to-plan-migration-workloads-service-retirement'
        }

    <################################################################### RESOURCE ###################################################################>

    if($excel.'Redis Cache')
        {
            $null = $excel.'Redis Cache'.Cells["F1"].AddComment("It's important to be aware of upcoming Azure services and feature retirements to understand their impact on your workloads and plan migration.", "Azure Resource Inventory")
            $excel.'Redis Cache'.Cells["F1"].Hyperlink = 'https://learn.microsoft.com/en-us/azure/advisor/advisor-how-to-plan-migration-workloads-service-retirement'
        }

    <################################################################### RESOURCE ###################################################################>

    if($excel.'App Gateway')
        {
            $null = $excel.'App Gateway'.Cells["K1"].AddComment("It's important to be aware of upcoming Azure services and feature retirements to understand their impact on your workloads and plan migration.", "Azure Resource Inventory")
            $excel.'App Gateway'.Cells["K1"].Hyperlink = 'https://learn.microsoft.com/en-us/azure/advisor/advisor-how-to-plan-migration-workloads-service-retirement'
        }

    <################################################################### RESOURCE ###################################################################>

    if($excel.'Load Balancers')
        {
            $null = $excel.'Load Balancers'.Cells["E1"].AddComment("No SLA is provided for Basic Load Balancer!", "Azure Resource Inventory")
            $excel.'Load Balancers'.Cells["E1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/load-balancer/skus'

            $null = $excel.'Load Balancers'.Cells["F1"].AddComment("It's important to be aware of upcoming Azure services and feature retirements to understand their impact on your workloads and plan migration.", "Azure Resource Inventory")
            $excel.'Load Balancers'.Cells["F1"].Hyperlink = 'https://learn.microsoft.com/en-us/azure/advisor/advisor-how-to-plan-migration-workloads-service-retirement'
        }

    <################################################################### RESOURCE ###################################################################>

    if($excel.'Public IPs')
        {
            $null = $excel.'Public IPs'.Cells["G1"].AddComment("It's important to be aware of upcoming Azure services and feature retirements to understand their impact on your workloads and plan migration.", "Azure Resource Inventory")
            $excel.'Public IPs'.Cells["G1"].Hyperlink = 'https://learn.microsoft.com/en-us/azure/advisor/advisor-how-to-plan-migration-workloads-service-retirement'
        }

    <################################################################### RESOURCE ###################################################################>

    if($excel.VirtualNetwork)
        {
            $null = $excel.VirtualNetwork.Cells["F1"].AddComment("Azure DDoS Protection Standard, combined with application design best practices, provides enhanced DDoS mitigation features to defend against DDoS attacks.", "Azure Resource Inventory")
            $excel.VirtualNetwork.Cells["F1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/ddos-protection/ddos-protection-overview'
        }

    <################################################################### RESOURCE ###################################################################>

    if($excel.'Storage Acc')
        {
            $null = $excel.'Storage Acc'.Cells["K1"].AddComment("Is recommended that you configure your storage account to accept requests from secure connections only by setting the Secure transfer required property for the storage account.", "Azure Resource Inventory")
            $excel.'Storage Acc'.Cells["K1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/storage/common/storage-require-secure-transfer'
            $null = $excel.'Storage Acc'.Cells["L1"].AddComment("When a container is configured for anonymous access, any client can read data in that container. Anonymous access presents a potential security risk, so if your scenario does not require it, we recommend that you remediate anonymous access for the storage account.", "Azure Resource Inventory")
            $excel.'Storage Acc'.Cells["L1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/storage/blobs/anonymous-read-access-configure?tabs=portal'
            $null = $excel.'Storage Acc'.Cells["M1"].AddComment("By default, Azure Storage accounts permit clients to send and receive data with the oldest version of TLS, TLS 1.0, and above. To enforce stricter security measures, you can configure your storage account to require that clients send and receive data with a newer version of TLS", "Azure Resource Inventory")
            $excel.'Storage Acc'.Cells["M1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/storage/common/transport-layer-security-configure-minimum-version?tabs=portal'
            $null = $excel.'Storage Acc'.Cells["I1"].AddComment("It's important to be aware of upcoming Azure services and feature retirements to understand their impact on your workloads and plan migration.", "Azure Resource Inventory")
            $excel.'Storage Acc'.Cells["I1"].Hyperlink = 'https://learn.microsoft.com/en-us/azure/advisor/advisor-how-to-plan-migration-workloads-service-retirement'
        }

    <################################################################### RESOURCE ###################################################################>

    if($excel.Disks)
        {
            $null = $excel.Disks.Cells["D1"].AddComment("When you delete a virtual machine (VM) in Azure, by default, any disks that are attached to the VM aren't deleted. After a VM is deleted, you will continue to pay for unattached disks.", "Azure Resource Inventory")
            $excel.Disks.Cells["D1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/virtual-machines/windows/find-unattached-disks'
        }

    Close-ExcelPackage $excel 
}