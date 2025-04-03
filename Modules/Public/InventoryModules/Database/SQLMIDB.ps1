<#
.Synopsis
Inventory for Azure SQL Server

.DESCRIPTION
This script consolidates information for all microsoft.sql/servers resource provider in $Resources variable. 
Excel Sheet Name: SQL MI DBs

.Link
https://github.com/microsoft/ARI/Modules/Public/InventoryModules/Database/SQLMIDB.ps1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.6.0
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Retirements, $Task ,$File, $SmaResources, $TableStyle, $Unsupported)

if ($Task -eq 'Processing') {

    $SQLSERVERMIDB = $Resources | Where-Object { $_.TYPE -eq 'microsoft.sql/managedinstances/databases' }

    if($SQLSERVERMIDB)
        {
            $tmp = foreach ($1 in $SQLSERVERMIDB) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES

                $Tags = if(!!($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                $Retired = $Retirements | Where-Object { $_.id -eq $1.id }
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
                $pvteps = if(!($data.privateEndpointConnections)) {[pscustomobject]@{id = 'NONE'}} else {$data.privateEndpointConnections | Select-Object @{Name="id";Expression={$_.id.split("/")[10]}}}

                foreach ($pvtep in $pvteps) {
                    foreach ($Tag in $Tags) {
                        $obj = @{
                            'ID'                            = $1.id;
                            'Subscription'                  = $sub1.Name;
                            'MI parent'                     = $1.id.split("/")[8];
                            'Name'                          = $1.NAME;
                            'Retiring Feature'              = $RetiringFeature;
                            'Retiring Date'                 = $RetiringDate;
                            'Collation'                     = $data.collation;
                            'CreationDate'                  = $data.creationDate;
                            'DefaultSecondaryLocation'      = $data.defaultSecondaryLocation;
                            'Status'                        = $data.status;
                            'Resource U'                 = $ResUCount;
                            'Tag Name'                      = [string]$Tag.Name;
                            'Tag Value'                     = [string]$Tag.Value
                        }
                        $obj
                        if ($ResUCount -eq 1) { $ResUCount = 0 } 
                    }     
                }          
            }
            $tmp
        }
}
else {
    if ($SmaResources) {

        $TableName = ('SQLMIDBTable_'+($SmaResources.'Resource U').count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0

        $condtxt = @()
        $condtxt += New-ConditionalText offline -Range I:I
        #Retirement
        $condtxt += New-ConditionalText -Range D2:D100 -ConditionalType ContainsText

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('MI parent')
        $Exc.Add('Name')
        $Exc.Add('Retiring Feature')
        $Exc.Add('Retiring Date')
        $Exc.Add('Collation')
        $Exc.Add('CreationDate')
        $Exc.Add('DefaultSecondaryLocation')
        $Exc.Add('Status')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        [PSCustomObject]$SmaResources | 
        ForEach-Object { $_ } | Select-Object $Exc | 
        Export-Excel -Path $File -WorksheetName 'SQL MI DBs' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -ConditionalText $condtxt -Style $Style

    }
}