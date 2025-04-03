<#
.Synopsis
Job Module for Draw.io Diagram

.DESCRIPTION
This module is used for managing jobs in the Draw.io Diagram.

.Link
https://github.com/microsoft/ARI/Modules/Public/PublicFunctions/Diagram/Start-ARIDiagramJob.ps1

.COMPONENT
This PowerShell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.6.0
First Release Date: 15th Oct, 2024
Authors: Claudio Merola

#>

Function Start-ARIDiagramJob {
    Param($Resources,$Automation)

    if ($Automation.IsPresent) {
        Start-ThreadJob -Name 'DiagramVariables' -ScriptBlock {

            $AZVGWs = $($args[0]) | Where-Object {$_.Type -eq 'microsoft.network/virtualnetworkgateways'}
            $AZLGWs = $($args[0]) | Where-Object {$_.Type -eq 'microsoft.network/localnetworkgateways'}
            $AZVNETs = $($args[0]) | Where-Object {$_.Type -eq 'microsoft.network/virtualnetworks'}
            $AZCONs = $($args[0]) | Where-Object {$_.Type -eq 'microsoft.network/connections'}
            $AZEXPROUTEs = $($args[0]) | Where-Object {$_.Type -eq 'microsoft.network/expressroutecircuits'}
            $PIPs = $($args[0]) | Where-Object {$_.Type -eq 'microsoft.network/publicipaddresses'}
            $AZVWAN = $($args[0]) | Where-Object {$_.Type -eq 'microsoft.network/virtualwans'}
            $AZVHUB = $($args[0]) | Where-Object {$_.Type -eq 'microsoft.network/virtualhubs'}
            $AZVPNSITES = $($args[0]) | Where-Object {$_.Type -eq 'microsoft.network/vpnsites'}
            $AZVERs = $($args[0]) | Where-Object {$_.Type -eq 'microsoft.network/expressroutegateways'}
            $AZAKS = $($args[0]) | Where-Object {$_.Type -eq 'microsoft.containerservice/managedclusters'}
            $AZVMSS = $($args[0]) | Where-Object {$_.Type -eq 'Microsoft.Compute/virtualMachineScaleSets'}
            $AZNIC = $($args[0]) | Where-Object {$_.Type -eq 'microsoft.network/networkinterfaces'}
            $AZPrivEnd = $($args[0]) | Where-Object {$_.Type -eq 'microsoft.network/privateendpoints'}
            $AZVM = $($args[0]) | Where-Object {$_.Type -eq 'microsoft.compute/virtualmachines'}
            $AZARO = $($args[0]) | Where-Object {$_.Type -eq 'microsoft.redhatopenshift/openshiftclusters'}
            $AZKusto = $($args[0]) | Where-Object {$_.Type -eq 'Microsoft.Kusto/clusters'}
            $AZAppGW = $($args[0]) | Where-Object {$_.Type -eq 'microsoft.network/applicationgateways'}
            $AZDW = $($args[0]) | Where-Object {$_.Type -eq 'Microsoft.Databricks/workspaces'}
            $AZAppWeb = $($args[0]) | Where-Object {$_.Type -eq 'microsoft.web/sites'}
            $AZAPIM = $($args[0]) | Where-Object {$_.Type -eq 'Microsoft.ApiManagement/service'}
            $AZLB = $($args[0]) | Where-Object {$_.Type -eq 'microsoft.network/loadbalancers'}
            $AZBastion = $($args[0]) | Where-Object {$_.Type -eq 'microsoft.network/bastionhosts'}
            $AZFW = $($args[0]) | Where-Object {$_.Type -eq 'microsoft.network/azurefirewalls'}
            $AZNetProf = $($args[0]) | Where-Object {$_.Type -eq 'microsoft.network/networkprofiles'}
            $AZCont = $($args[0]) | Where-Object {$_.Type -eq 'Microsoft.ContainerInstance/containerGroups'}
            $AZANF = $($args[0]) | Where-Object {$_.Type -eq 'microsoft.netapp/netappaccounts/capacitypools/volumes'}

            $Variables = @{
                    'AZVGWs' = $AZVGWs;
                    'AZLGWs' = $AZLGWs;
                    'AZVNETs' = $AZVNETs;
                    'AZCONs' = $AZCONs;
                    'AZEXPROUTEs' = $AZEXPROUTEs;
                    'PIPs' = $PIPs;
                    'AZVWAN' = $AZVWAN;
                    'AZVHUB' = $AZVHUB;
                    'AZVPNSITES' = $AZVPNSITES;
                    'AZVERs' = $AZVERs;
                    'AKS' = $AZAKS;
                    'VMSS' = $AZVMSS;
                    'NIC' = $AZNIC;
                    'PrivEnd' = $AZPrivEnd;
                    'VM' = $AZVM;
                    'ARO' = $AZARO;
                    'Kusto' = $AZKusto;
                    'AppGtw' = $AZAppGW;
                    'Databricks' = $AZDW;
                    'AppWeb' = $AZAppWeb;
                    'APIM' = $AZAPIM;
                    'LB' = $AZLB;
                    'Bastion' = $AZBastion;
                    'FW' = $AZFW;
                    'NetProf' = $AZNetProf;
                    'Container' = $AZCont;
                    'ANF' = $AZANF
                }

            $Variables

        } -ArgumentList $resources, $null
    }
    else
    {
        Start-Job -Name 'DiagramVariables' -ScriptBlock {
            $job = @()

            $AZVGWs = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.network/virtualnetworkgateways'}}).AddArgument($($args[0]))
            $AZLGWs = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.network/localnetworkgateways'}}).AddArgument($($args[0]))
            $AZVNETs = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.network/virtualnetworks'}}).AddArgument($($args[0]))
            $AZCONs = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.network/connections'}}).AddArgument($($args[0]))
            $AZEXPROUTEs = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.network/expressroutecircuits'} }).AddArgument($($args[0]))
            $PIPs = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.network/publicipaddresses'}}).AddArgument($($args[0]))
            $AZVWAN = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.network/virtualwans'}}).AddArgument($($args[0]))
            $AZVHUB = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.network/virtualhubs'}}).AddArgument($($args[0]))
            $AZVPNSITES = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.network/vpnsites'}}).AddArgument($($args[0]))
            $AZVERs = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.network/expressroutegateways'}}).AddArgument($($args[0]))

            $AZAKS = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.containerservice/managedclusters'}}).AddArgument($($args[0]))
            $AZVMSS = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'Microsoft.Compute/virtualMachineScaleSets'}}).AddArgument($($args[0]))
            $AZNIC = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.network/networkinterfaces'}}).AddArgument($($args[0]))
            $AZPrivEnd = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.network/privateendpoints'}}).AddArgument($($args[0]))
            $AZVM = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.compute/virtualmachines'}}).AddArgument($($args[0]))
            $AZARO = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.redhatopenshift/openshiftclusters'}}).AddArgument($($args[0]))
            $AZKusto = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'Microsoft.Kusto/clusters'}}).AddArgument($($args[0]))
            $AZAppGW = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.network/applicationgateways'}}).AddArgument($($args[0]))
            $AZDW = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'Microsoft.Databricks/workspaces'}}).AddArgument($($args[0]))
            $AZAppWeb = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.web/sites'}}).AddArgument($($args[0]))
            $AZAPIM = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'Microsoft.ApiManagement/service'}}).AddArgument($($args[0]))
            $AZLB = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.network/loadbalancers'}}).AddArgument($($args[0]))
            $AZBastion = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.network/bastionhosts'}}).AddArgument($($args[0]))
            $AZFW = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.network/azurefirewalls'}}).AddArgument($($args[0]))
            $AZNetProf = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.network/networkprofiles'}}).AddArgument($($args[0]))
            $AZCont = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'Microsoft.ContainerInstance/containerGroups'}}).AddArgument($($args[0]))
            $AZANF = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.netapp/netappaccounts/capacitypools/volumes'}}).AddArgument($($args[0]))

            $jobAZVGWs = $AZVGWs.BeginInvoke()
            $jobAZLGWs = $AZLGWs.BeginInvoke()
            $jobAZVNETs = $AZVNETs.BeginInvoke()
            $jobAZCONs = $AZCONs.BeginInvoke()
            $jobAZEXPROUTEs = $AZEXPROUTEs.BeginInvoke()
            $jobPIPs = $PIPs.BeginInvoke()
            $jobAZVWAN = $AZVWAN.BeginInvoke()
            $jobAZVHUB = $AZVHUB.BeginInvoke()
            $jobAZVERs = $AZVERs.BeginInvoke()
            $jobAZVPNSITES = $AZVPNSITES.BeginInvoke()
            $jobAZAKS = $AZAKS.BeginInvoke()
            $jobAZVMSS = $AZVMSS.BeginInvoke()
            $jobAZNIC = $AZNIC.BeginInvoke()
            $jobAZPrivEnd = $AZPrivEnd.BeginInvoke()
            $jobAZVM = $AZVM.BeginInvoke()
            $jobAZARO = $AZARO.BeginInvoke()
            $jobAZKusto = $AZKusto.BeginInvoke()
            $jobAZAppGW = $AZAppGW.BeginInvoke()
            $jobAZDW = $AZDW.BeginInvoke()
            $jobAZAppWeb = $AZAppWeb.BeginInvoke()
            $jobAZAPIM = $AZAPIM.BeginInvoke()
            $jobAZLB = $AZLB.BeginInvoke()
            $jobAZBastion = $AZBastion.BeginInvoke()
            $jobAZFW = $AZFW.BeginInvoke()
            $jobAZNetProf = $AZNetProf.BeginInvoke()
            $jobAZCont = $AZCont.BeginInvoke()
            $jobAZANF = $AZANF.BeginInvoke()

            $job += $jobAZVGWs
            $job += $jobAZLGWs
            $job += $jobAZVNETs
            $job += $jobAZCONs
            $job += $jobAZEXPROUTEs
            $job += $jobPIPs
            $job += $jobAZVWAN
            $job += $jobAZVHUB
            $job += $jobAZVPNSITES
            $job += $jobAZVERs
            $job += $jobAZAKS
            $job += $jobAZVMSS
            $job += $jobAZNIC
            $job += $jobAZPrivEnd
            $job += $jobAZVM
            $job += $jobAZARO
            $job += $jobAZKusto
            $job += $jobAZAppGW
            $job += $jobAZDW
            $job += $jobAZAppWeb
            $job += $jobAZAPIM
            $job += $jobAZLB
            $job += $jobAZBastion
            $job += $jobAZFW
            $job += $jobAZNetProf
            $job += $jobAZCont
            $job += $jobAZANF

            while ($Job.Runspace.IsCompleted -contains $false) {}

            $AZVGWsS = $AZVGWs.EndInvoke($jobAZVGWs)
            $AZLGWsS = $AZLGWs.EndInvoke($jobAZLGWs)
            $AZVNETsS = $AZVNETs.EndInvoke($jobAZVNETs)
            $AZCONsS = $AZCONs.EndInvoke($jobAZCONs)
            $AZEXPROUTEsS = $AZEXPROUTEs.EndInvoke($jobAZEXPROUTEs)
            $PIPsS = $PIPs.EndInvoke($jobPIPs)
            $AZVWANS = $AZVWAN.EndInvoke($jobAZVWAN)
            $AZVHUBS = $AZVHUB.EndInvoke($jobAZVHUB)
            $AZVPNSITESS = $AZVPNSITES.EndInvoke($jobAZVPNSITES)
            $AZVERsS = $AZVERs.EndInvoke($jobAZVERs)
            $AZAKSs = $AZAKS.EndInvoke($jobAZAKS)
            $AZVMSSs = $AZVMSS.EndInvoke($jobAZVMSS)
            $AZNICs = $AZNIC.EndInvoke($jobAZNIC)
            $AZPrivEnds = $AZPrivEnd.EndInvoke($jobAZPrivEnd)
            $AZVMs = $AZVM.EndInvoke($jobAZVM)
            $AZAROs = $AZARO.EndInvoke($jobAZARO)
            $AZKustos = $AZKusto.EndInvoke($jobAZKusto)
            $AZAppGWs = $AZAppGW.EndInvoke($jobAZAppGW)
            $AZDWs = $AZDW.EndInvoke($jobAZDW)
            $AZAppWebs = $AZAppWeb.EndInvoke($jobAZAppWeb)
            $AZAPIMs = $AZAPIM.EndInvoke($jobAZAPIM)
            $AZLBs = $AZLB.EndInvoke($jobAZLB)
            $AZBastions = $AZBastion.EndInvoke($jobAZBastion)
            $AZFWs = $AZFW.EndInvoke($jobAZFW)
            $AZNetProfs = $AZNetProf.EndInvoke($jobAZNetProf)
            $AZConts = $AZCont.EndInvoke($jobAZCont)
            $AZANFs = $AZANF.EndInvoke($jobAZANF)


            $AZVGWs.Dispose()
            $AZLGWs.Dispose()
            $AZVNETs.Dispose()
            $AZCONs.Dispose()
            $AZEXPROUTEs.Dispose()
            $PIPs.Dispose()
            $AZVWAN.Dispose()
            $AZVHUB.Dispose()
            $AZVPNSITES.Dispose()
            $AZVERs.Dispose()
            $AZAKS.Dispose()
            $AZVMSS.Dispose()
            $AZNIC.Dispose()
            $AZPrivEnd.Dispose()
            $AZVM.Dispose()
            $AZARO.Dispose()
            $AZKusto.Dispose()
            $AZAppGW.Dispose()
            $AZDW.Dispose()
            $AZAppWeb.Dispose()
            $AZAPIM.Dispose()
            $AZLB.Dispose()
            $AZBastion.Dispose()
            $AZFW.Dispose()
            $AZNetProf.Dispose()
            $AZCont.Dispose()
            $AZANF.Dispose()


            $Variables = @{
                    'AZVGWs' = $AZVGWsS;
                    'AZLGWs' = $AZLGWsS;
                    'AZVNETs' = $AZVNETsS;
                    'AZCONs' = $AZCONsS;
                    'AZEXPROUTEs' = $AZEXPROUTEsS;
                    'PIPs' = $PIPsS;
                    'AZVWAN' = $AZVWANS;
                    'AZVHUB' = $AZVHUBS;
                    'AZVPNSITES' = $AZVPNSITESS;
                    'AZVERs' = $AZVERsS;
                    'AKS' = $AZAKSs;
                    'VMSS' = $AZVMSSs;
                    'NIC' = $AZNICs;
                    'PrivEnd' = $AZPrivEnds;
                    'VM' = $AZVMs;
                    'ARO' = $AZAROs;
                    'Kusto' = $AZKustos;
                    'AppGtw' = $AZAppGWs;
                    'Databricks' = $AZDWs;
                    'AppWeb' = $AZAppWebs;
                    'APIM' = $AZAPIMs;
                    'LB' = $AZLBs;
                    'Bastion' = $AZBastions;
                    'FW' = $AZFWs;
                    'NetProf' = $AZNetProfs;
                    'Container' = $AZConts;
                    'ANF' = $AZANFs
                }

            $Variables

        } -ArgumentList $resources, $null
    }
}