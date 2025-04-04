<#
.Synopsis
Inventory for Azure Managed Identities

.DESCRIPTION
Excel Sheet Name: ManagedIdentities

.Link
https://github.com/microsoft/ARI/Modules/APIs/ManagedIdentities.ps1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 4.0.1
First Release Date: 25th Aug, 2024
Authors: Claudio Merola 

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Retirements, $Task, $File, $SmaResources, $TableStyle, $Unsupported)

If ($Task -eq 'Processing') {

    <######### Insert the resource extraction here ########>

    $ManagedIdentities = $Resources | Where-Object { $_.TYPE -eq 'Microsoft.ManagedIdentity/userAssignedIdentities' }

    <######### Insert the resource Process here ########>

    if($ManagedIdentities)
        {
            $tmp = foreach ($1 in $ManagedIdentities) {
                $ResUCount = 1
                $SubId = $1.id.split('/')[2]
                $sub1 = $SUB | Where-Object { $_.id -eq $SubId }
                $data = $1.PROPERTIES
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                foreach ($Tag in $Tags) {
                    $obj = @{
                        'ID'                        = $1.id;
                        'Subscription'              = $sub1.Name;
                        'Name'                      = $1.Name;
                        'Location'                  = $1.location;
                        'Principal ID'              = $data.principalId;
                        'Client ID'                 = $data.clientId;
                        'Resource U'                = $ResUCount;
                        'Tag Name'                  = [string]$Tag.Name;
                        'Tag Value'                 = [string]$Tag.Value
                    }
                    $obj
                    if ($ResUCount -eq 1) { $ResUCount = 0 } 
                }
            }
            $tmp
        }
}

<######## Resource Excel Reporting Begins Here ########>

Else {
    <######## $SmaResources.(RESOURCE FILE NAME) ##########>

    if ($SmaResources) {

        $TableName = ('ManIdTable_'+($SmaResources.'Resource U').count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Name')
        $Exc.Add('Location')         
        $Exc.Add('Principal ID')
        $Exc.Add('Client ID')
        if($InTag)
        {
            $Exc.Add('Tag Name')
            $Exc.Add('Tag Value') 
        }

        [PSCustomObject]$SmaResources | 
        ForEach-Object { $_ } | Select-Object $Exc | 
        Export-Excel -Path $File -WorksheetName 'Managed Identity' -AutoSize -TableName $TableName -MaxAutoSizeRows 100 -TableStyle $tableStyle -Numberformat '0' -Style $Style

    }
}