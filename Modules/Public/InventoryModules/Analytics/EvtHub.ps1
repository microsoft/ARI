<#
.Synopsis
Inventory for Azure EventHubs

.DESCRIPTION
This script consolidates information for all microsoft.eventhub/namespaces and resource provider in $Resources variable. 
Excel Sheet Name: EvHub

.Link
https://github.com/microsoft/ARI/Modules/Public/InventoryModules/Analytics/EvtHub.ps1

.COMPONENT
    This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.6.0
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Retirements, $Task, $File, $SmaResources, $TableStyle, $Unsupported)

If ($Task -eq 'Processing')
{

    <######### Insert the resource extraction here ########>

        $evthub = $Resources | Where-Object {$_.TYPE -eq 'microsoft.eventhub/namespaces'}

    <######### Insert the resource Process here ########>

    if($evthub)
        {
            $tmp = foreach ($1 in $evthub) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $timecreated = if($data.createdAt){[string](get-date($data.createdAt))}else{''}
                $sku = $1.SKU
                $Retired = Foreach ($Retirement in $Retirements)
                    {
                        if ($Retirement.id -eq $1.id) { $Retirement }
                    }
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
                $LocalAuth = if($data.disablelocalauth -eq $false){$true}else{$false}
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach ($Tag in $Tags) { 
                        $obj = @{
                            'ID'                   = $1.id;
                            'Subscription'         = $sub1.Name;
                            'Resource Group'       = $1.RESOURCEGROUP;
                            'Name'                 = $1.NAME;
                            'Location'             = $1.LOCATION;
                            'SKU'                  = $sku.name;
                            'Retiring Feature'     = $RetiringFeature;
                            'Retiring Date'        = $RetiringDate;
                            'Status'               = $data.status;
                            'Geo-Replication'      = $data.zoneRedundant;
                            'Throughput Units'     = $1.sku.capacity;
                            'Local Authentication' = $LocalAuth;
                            'Auto-Inflate'         = $data.isAutoInflateEnabled;
                            'Max Throughput Units' = $data.maximumThroughputUnits;
                            'Kafka Enabled'        = $data.kafkaEnabled;
                            'Minimum TLS Version'  = $data.minimumtlsversion;
                            'Endpoint'             = $data.serviceBusEndpoint;
                            'Created Time'         = $timecreated;
                            'Resource U'           = $ResUCount;
                            'Tag Name'             = [string]$Tag.Name;
                            'Tag Value'            = [string]$Tag.Value
                        }
                        $obj
                        if ($ResUCount -eq 1) { $ResUCount = 0 } 
                    }               
            }
            $tmp
        }
}

<######## Resource Excel Reporting Begins Here ########>

Else
{
    <######## $SmaResources.(RESOURCE FILE NAME) ##########>

    if($SmaResources)
    {

        $TableName = ('EvtHubTable_'+($SmaResources.'Resource U').count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

        $SheetName = 'Event Hubs'

        $condtxt = @()
        #Retirement
        $condtxt += New-ConditionalText -Range F2:F100 -ConditionalType ContainsText
        $condtxt += New-ConditionalText false -Range L:L
        $condtxt += New-ConditionalText '1.0' -Range O:O

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('SKU')
        $Exc.Add('Retiring Feature')
        $Exc.Add('Retiring Date')
        $Exc.Add('Status')
        $Exc.Add('Geo-Rep')
        $Exc.Add('Throughput Units')
        $Exc.Add('Local Authentication')
        $Exc.Add('Auto-Inflate')
        $Exc.Add('Max Throughput Units')
        $Exc.Add('Kafka Enabled')
        $Exc.Add('Minimum TLS Version')
        $Exc.Add('Endpoint')
        $Exc.Add('Created Time')  
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $noNumberConversion = @()
        $noNumberConversion += 'Minimum TLS Version'

        [PSCustomObject]$SmaResources | 
        ForEach-Object { $_ } | Select-Object $Exc | 
        Export-Excel -Path $File -WorksheetName $SheetName -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -ConditionalText $condtxt -Style $Style -NoNumberConversion $noNumberConversion
    }
}