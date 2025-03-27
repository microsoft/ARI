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

            $AZVGWs = $($args[0]) | Where-Object {$_.Type -eq 'microsoft.network/virtualnetworkgateways'} | Select-Object -Property * -Unique
            $AZLGWs = $($args[0]) | Where-Object {$_.Type -eq 'microsoft.network/localnetworkgateways'} | Select-Object -Property * -Unique
            $AZVNETs = $($args[0]) | Where-Object {$_.Type -eq 'microsoft.network/virtualnetworks'} | Select-Object -Property * -Unique
            $AZCONs = $($args[0]) | Where-Object {$_.Type -eq 'microsoft.network/connections'} | Select-Object -Property * -Unique
            $AZEXPROUTEs = $($args[0]) | Where-Object {$_.Type -eq 'microsoft.network/expressroutecircuits'} | Select-Object -Property * -Unique
            $PIPs = $($args[0]) | Where-Object {$_.Type -eq 'microsoft.network/publicipaddresses'} | Select-Object -Property * -Unique
            $AZVWAN = $($args[0]) | Where-Object {$_.Type -eq 'microsoft.network/virtualwans'} | Select-Object -Property * -Unique
            $AZVHUB = $($args[0]) | Where-Object {$_.Type -eq 'microsoft.network/virtualhubs'} | Select-Object -Property * -Unique
            $AZVPNSITES = $($args[0]) | Where-Object {$_.Type -eq 'microsoft.network/vpnsites'} | Select-Object -Property * -Unique
            $AZVERs = $($args[0]) | Where-Object {$_.Type -eq 'microsoft.network/expressroutegateways'} | Select-Object -Property * -Unique
            $AZAKS = $($args[0]) | Where-Object {$_.Type -eq 'microsoft.containerservice/managedclusters'} | Select-Object -Property * -Unique
            $AZVMSS = $($args[0]) | Where-Object {$_.Type -eq 'Microsoft.Compute/virtualMachineScaleSets'} | Select-Object -Property * -Unique
            $AZNIC = $($args[0]) | Where-Object {$_.Type -eq 'microsoft.network/networkinterfaces'} | Select-Object -Property * -Unique
            $AZPrivEnd = $($args[0]) | Where-Object {$_.Type -eq 'microsoft.network/privateendpoints'} | Select-Object -Property * -Unique
            $AZVM = $($args[0]) | Where-Object {$_.Type -eq 'microsoft.compute/virtualmachines'} | Select-Object -Property * -Unique
            $AZARO = $($args[0]) | Where-Object {$_.Type -eq 'microsoft.redhatopenshift/openshiftclusters'} | Select-Object -Property * -Unique
            $AZKusto = $($args[0]) | Where-Object {$_.Type -eq 'Microsoft.Kusto/clusters'} | Select-Object -Property * -Unique
            $AZAppGW = $($args[0]) | Where-Object {$_.Type -eq 'microsoft.network/applicationgateways'} | Select-Object -Property * -Unique
            $AZDW = $($args[0]) | Where-Object {$_.Type -eq 'Microsoft.Databricks/workspaces'} | Select-Object -Property * -Unique
            $AZAppWeb = $($args[0]) | Where-Object {$_.Type -eq 'microsoft.web/sites'} | Select-Object -Property * -Unique
            $AZAPIM = $($args[0]) | Where-Object {$_.Type -eq 'Microsoft.ApiManagement/service'} | Select-Object -Property * -Unique
            $AZLB = $($args[0]) | Where-Object {$_.Type -eq 'microsoft.network/loadbalancers'} | Select-Object -Property * -Unique
            $AZBastion = $($args[0]) | Where-Object {$_.Type -eq 'microsoft.network/bastionhosts'} | Select-Object -Property * -Unique
            $AZFW = $($args[0]) | Where-Object {$_.Type -eq 'microsoft.network/azurefirewalls'} | Select-Object -Property * -Unique
            $AZNetProf = $($args[0]) | Where-Object {$_.Type -eq 'microsoft.network/networkprofiles'} | Select-Object -Property * -Unique
            $AZCont = $($args[0]) | Where-Object {$_.Type -eq 'Microsoft.ContainerInstance/containerGroups'} | Select-Object -Property * -Unique
            $AZANF = $($args[0]) | Where-Object {$_.Type -eq 'microsoft.netapp/netappaccounts/capacitypools/volumes'} | Select-Object -Property * -Unique

            $CleanPIPs = $PIPs | Where-Object {$_.id -notin $AZVGWsS.properties.ipConfigurations.properties.publicIPAddress.id}

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
                    'CleanPIPs' = $CleanPIPs;
                    'AKS' = $AZAKS;
                    'VMSS' = $AZVMSS;
                    'NIC' = $AZNIC;
                    'PrivEnd' = $AZPrivEnd;
                    'VM' = $AZVM;
                    'ARO' = $AZARO;
                    'Kusto' = $AZKusto;
                    'AppGtw' = $AZAppGW;
                    'DW' = $AZDW;
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

            $AZVGWs = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.network/virtualnetworkgateways'} | Select-Object -Property * -Unique}).AddArgument($($args[0]))
            $AZLGWs = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.network/localnetworkgateways'} | Select-Object -Property * -Unique}).AddArgument($($args[0]))
            $AZVNETs = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.network/virtualnetworks'} | Select-Object -Property * -Unique}).AddArgument($($args[0]))
            $AZCONs = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.network/connections'} | Select-Object -Property * -Unique}).AddArgument($($args[0]))
            $AZEXPROUTEs = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.network/expressroutecircuits'} | Select-Object -Property * -Unique }).AddArgument($($args[0]))
            $PIPs = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.network/publicipaddresses'} | Select-Object -Property * -Unique}).AddArgument($($args[0]))
            $AZVWAN = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.network/virtualwans'} | Select-Object -Property * -Unique}).AddArgument($($args[0]))
            $AZVHUB = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.network/virtualhubs'} | Select-Object -Property * -Unique}).AddArgument($($args[0]))
            $AZVPNSITES = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.network/vpnsites'} | Select-Object -Property * -Unique}).AddArgument($($args[0]))
            $AZVERs = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.network/expressroutegateways'} | Select-Object -Property * -Unique}).AddArgument($($args[0]))

            $AZAKS = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.containerservice/managedclusters'} | Select-Object -Property * -Unique}).AddArgument($($args[0]))
            $AZVMSS = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'Microsoft.Compute/virtualMachineScaleSets'} | Select-Object -Property * -Unique}).AddArgument($($args[0]))
            $AZNIC = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.network/networkinterfaces'} | Select-Object -Property * -Unique}).AddArgument($($args[0]))
            $AZPrivEnd = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.network/privateendpoints'} | Select-Object -Property * -Unique}).AddArgument($($args[0]))
            $AZVM = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.compute/virtualmachines'} | Select-Object -Property * -Unique}).AddArgument($($args[0]))
            $AZARO = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.redhatopenshift/openshiftclusters'} | Select-Object -Property * -Unique}).AddArgument($($args[0]))
            $AZKusto = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'Microsoft.Kusto/clusters'} | Select-Object -Property * -Unique}).AddArgument($($args[0]))
            $AZAppGW = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.network/applicationgateways'} | Select-Object -Property * -Unique}).AddArgument($($args[0]))
            $AZDW = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'Microsoft.Databricks/workspaces'} | Select-Object -Property * -Unique}).AddArgument($($args[0]))
            $AZAppWeb = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.web/sites'} | Select-Object -Property * -Unique}).AddArgument($($args[0]))
            $AZAPIM = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'Microsoft.ApiManagement/service'} | Select-Object -Property * -Unique}).AddArgument($($args[0]))
            $AZLB = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.network/loadbalancers'} | Select-Object -Property * -Unique}).AddArgument($($args[0]))
            $AZBastion = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.network/bastionhosts'} | Select-Object -Property * -Unique}).AddArgument($($args[0]))
            $AZFW = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.network/azurefirewalls'} | Select-Object -Property * -Unique}).AddArgument($($args[0]))
            $AZNetProf = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.network/networkprofiles'} | Select-Object -Property * -Unique}).AddArgument($($args[0]))
            $AZCont = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'Microsoft.ContainerInstance/containerGroups'} | Select-Object -Property * -Unique}).AddArgument($($args[0]))
            $AZANF = ([PowerShell]::Create()).AddScript({param($resources)$resources | Where-Object {$_.Type -eq 'microsoft.netapp/netappaccounts/capacitypools/volumes'} | Select-Object -Property * -Unique}).AddArgument($($args[0]))

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

            $CleanPIPs = $PIPsS | Where-Object {$_.id -notin $AZVGWsS.properties.ipConfigurations.properties.publicIPAddress.id}

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
                    'CleanPIPs' = $CleanPIPs;
                    'AKS' = $AZAKSs;
                    'VMSS' = $AZVMSSs;
                    'NIC' = $AZNICs;
                    'PrivEnd' = $AZPrivEnds;
                    'VM' = $AZVMs;
                    'ARO' = $AZAROs;
                    'Kusto' = $AZKustos;
                    'AppGtw' = $AZAppGWs;
                    'DW' = $AZDWs;
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