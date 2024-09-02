<#
.Synopsis
Inventory for Azure Immersive Reader

.DESCRIPTION
This script consolidates information for all microsoft.operationalinsights/workspaces and  resource provider in $Resources variable. 
Excel Sheet Name: ImmersiveReader

.Link
https://github.com/microsoft/ARI/Modules/Analytics/ImmersiveReader.ps1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.0.2
First Release Date: 19th November, 2020
Authors: Claudio Merola

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Task ,$File, $SmaResources, $TableStyle, $Unsupported)

If ($Task -eq 'Processing')
{

    <######### Insert the resource extraction here ########>

    $ImmersiveReader = $Resources | Where-Object {$_.TYPE -eq 'microsoft.cognitiveservices/accounts' -and $_.Kind -eq 'ImmersiveReader'}

    <######### Insert the resource Process here ########>

    if($ImmersiveReader)
        {
            $tmp = @()

            foreach ($1 in $ImmersiveReader) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $timecreated = $data.datecreated
                $timecreated = [datetime]$timecreated
                $timecreated = $timecreated.ToString("yyyy-MM-dd HH:mm")
                $pvt = if(![string]::IsNullOrEmpty($data.privateendpointconnections)){$data.privateendpointconnections}else{'0'}
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach ($pv in $pvt)
                        {
                            $priv = $pv.split('/')[8]
                            foreach ($Tag in $Tags) {
                                $obj = @{
                                    'ID'                                        = $1.id;
                                    'Subscription'                              = $sub1.Name;
                                    'Resource Group'                            = $1.RESOURCEGROUP;
                                    'Name'                                      = $1.NAME;
                                    'SKU'                                       = $1.sku.name;
                                    'Public Network Access'                     = $data.publicnetworkaccess;
                                    'Creation Time'                             = $timecreated;
                                    'Is Migrated'                               = $data.ismigrated;
                                    'Custom Domain Name'                        = $data.customsubdomainname;
                                    'Endpoint'                                  = $data.endpoint;
                                    'Network Default Action'                    = $data.networkacls.defaultaction;
                                    'IP Rules'                                  = $data.networkacls.iprules.count;
                                    'Virtual Network Rules'                     = $data.networkacls.virtualnetworkrules.count;
                                    'Private Endpoint'                          = $priv;
                                    'Resource U'                                = $ResUCount;
                                    'Tag Name'                                  = [string]$Tag.Name;
                                    'Tag Value'                                 = [string]$Tag.Value
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

    if($SmaResources.ImmersiveReader)
    {

        $TableName = ('ImmersiveRTable_'+($SmaResources.ImmersiveReader.id | Select-Object -Unique).count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

        $condtxt = @()
        $condtxt += New-ConditionalText enabled -Range E:E

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('SKU')
        $Exc.Add('Public Network Access')
        $Exc.Add('Creation Time')
        $Exc.Add('Is Migrated')
        $Exc.Add('Custom Domain Name')
        $Exc.Add('Endpoint')
        $Exc.Add('Network Default Action')
        $Exc.Add('IP Rules')
        $Exc.Add('Virtual Network Rules')
        $Exc.Add('Private Endpoint')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $ExcelVar = $SmaResources.ImmersiveReader 

        $ExcelVar | 
        ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        Export-Excel -Path $File -WorksheetName 'Immersive Reader' -AutoSize -MaxAutoSizeRows 100 -ConditionalText $condtxt -TableName $TableName -TableStyle $tableStyle -Style $Style


        <######## Insert Column comments and documentations here following this model #########>


        #$excel = Open-ExcelPackage -Path $File -KillExcel


        #Close-ExcelPackage $excel 

    }
}