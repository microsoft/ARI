<#
.Synopsis
Security Center Module

.DESCRIPTION
This script process and creates the Security Center sheet based on securityresources. 

.Link
https://github.com/azureinventory/ARI/Extras/SecurityCenter.ps1

.COMPONENT
   This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 2.0.0
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

#>
param($Subscriptions,$Security, $Task ,$File, $Sec, $TableStyle)
 
If ($Task -eq 'Processing')
{
    $obj = ''
    $tmp = @()

    foreach ($1 in $Security) {
        $data = $1.PROPERTIES

        $sub1 = $($args[1]) | Where-Object { $_.id -eq $1.properties.resourceDetails.Id.Split("/")[2] }

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
else 
{    
    $condtxtsec = $(New-ConditionalText High -Range G:G
    New-ConditionalText High -Range L:L)

    $Sec | 
    ForEach-Object { [PSCustomObject]$_ } | 
    Select-Object 'Subscription',
    'Resource Group',
    'Resource Type',
    'Resource Name',
    'Categories',
    'Control',
    'Severity',
    'Status',
    'Remediation',
    'Remediation Effort',
    'User Impact',
    'Threats' | 
    Export-Excel -Path $File -WorksheetName 'SecurityCenter' -AutoSize -MaxAutoSizeRows 100 -MoveToStart -TableName 'SecurityCenter' -TableStyle $tableStyle -ConditionalText $condtxtsec -KillExcel

}