<#
.Synopsis
Start Security Center Job Module

.DESCRIPTION
This script processes and creates the Security Center sheet based on security resources.

.Link
https://github.com/microsoft/ARI/Modules/Public/PublicFunctions/Jobs/Start-ARISecCenterJob.ps1

.COMPONENT
    This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.6.0
First Release Date: 15th Oct, 2024
Authors: Claudio Merola

#>
function Start-ARISecCenterJob {
    param($Subscriptions,$Security)
        $obj = ''
        $tmp = @()

        foreach ($1 in $Security) {
            $data = $1.PROPERTIES

            $sub1 = $Subscriptions | Where-Object { $_.id -eq $1.properties.resourceDetails.Id.Split("/")[2] }

            $obj = @{
                'Subscription'       = $sub1.Name;
                'Resource Group'     = $1.RESOURCEGROUP;
                'Resource Type'      = $data.resourceDetails.Id.Split("/")[7];
                'Resource Name'      = $data.resourceDetails.Id.Split("/")[8];
                'Categories'         = [string]$data.metadata.categories;
                'Control'            = $data.displayName;
                'Severity'           = $data.metadata.severity;
                'Status'             = $data.status.code;
                'Remediation'        = $data.metadata.remediationDescription;
                'Remediation Effort' = $data.metadata.implementationEffort;
                'User Impact'        = $data.metadata.userImpact;
                'Threats'            = [string]$data.metadata.threats
            }
            $tmp += $obj
        }
        $tmp
}