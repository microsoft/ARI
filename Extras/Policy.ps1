<#
.Synopsis
Policy Module

.DESCRIPTION
This script process and creates the Policy sheet based on advisorresources. 

.Link
https://github.com/microsoft/ARI/Extras/Policy.ps1

.COMPONENT
    This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.0.1
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

#>
param($Policies, $Task , $Subscriptions, $File ,$Pol, $TableStyle)

If ($Task -eq 'Processing')
{
    $obj = ''
    $tmp = @()

    foreach ($1 in $Policies) 
        {
                    $data = $1.PROPERTIES
                    if($data.policyDefinitionId -like '/providers/microsoft.management/managementgroups/*')
                        {
                            $Definition = $data.policyDefinitionId.split('/')[8]
                        }
                    else
                        {
                            $Definition = $data.policyDefinitionId.split('/')[4]
                        }
                    $timecreated = [datetime]$data.metadata.createdon
                    $timecreated = $timecreated.ToString("yyyy-MM-dd HH:mm")
                    if($data.scope -like '/subscriptions/*')
                        {
                            $ScopeType = 'Subscription'
                            $Scope = ($Subscriptions | Where-Object {$_.id -eq $data.scope.split('/')[2]}).name
                        }
                    else
                        {
                            $ScopeType = 'Management Group'
                            $Scope = $data.scope.split('/')[4]
                        }

                    $obj = @{
                        'ID'                     = $1.id;
                        'Definition Id'          = $Definition;
                        'Name'                   = $data.displayName;
                        'Description'            = $data.description;
                        'Location'               = $1.location;
                        'Enforcement Mode'       = $data.enforcementmode;
                        'Created On'             = $timecreated;
                        'Assigned By'            = $data.metadata.assignedby;
                        'Scope Type'             = $ScopeType;
                        'Scope'                  = $Scope;
                        'Identity Type'          = $1.identity.type;
                        'Principal Id'           = $1.identity.principalId
                    }    
                    $tmp += $obj
        }
    $tmp
}
Else
{

    $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0.0
    $StyleExt = New-ExcelStyle -HorizontalAlignment Left -Range B:C -Width 70 -WrapText 

    $Pol |
    ForEach-Object { [PSCustomObject]$_ } | 
    Select-Object 'Definition Id',
    'Name',
    'Description',
    'Location',
    'Enforcement Mode',
    'Created On',
    'Assigned By',
    'Scope Type',
    'Scope',
    'Identity Type',
    'Principal Id' |
    Export-Excel -Path $File -WorksheetName 'Policy' -AutoSize -MaxAutoSizeRows 100 -TableName 'AzurePolicy' -MoveToStart -TableStyle $tableStyle -Style $Style,$StyleExt -KillExcel 

}
