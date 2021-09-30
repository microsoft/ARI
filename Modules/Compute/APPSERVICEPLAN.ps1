<#
.Synopsis
Inventory for Azure App Service Plan

.DESCRIPTION
This script consolidates information for all microsoft.web/serverfarms resource provider in $Resources variable. 
Excel Sheet Name: APPSERVICEPLAN

.Link
https://github.com/azureinventory/ARI/Modules/Compute/APPSERVICEPLAN.ps1

.COMPONENT
   This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 2.0.0
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Task ,$File, $SmaResources, $TableStyle)
 
If ($Task -eq 'Processing')
{
 
    <######### Insert the resource extraction here ########>

        $APPSvcPlan = $Resources | Where-Object {$_.TYPE -eq 'microsoft.web/serverfarms'}
        $APPAutoScale = $Resources | Where-Object {$_.TYPE -eq "microsoft.insights/autoscalesettings" -and $_.Properties.enabled -eq 'true'}
        
    <######### Insert the resource Process here ########>

    if($APPSvcPlan)
        {
            $tmp = @()

            foreach ($1 in $APPSvcPlan) {
                $ResUCount = 1
                Remove-Variable AutoScale -ErrorAction SilentlyContinue
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $sku = $1.SKU
                $AutoScale = ($APPAutoScale | Where-Object {$_.Properties.targetResourceUri -eq $1.id})
                if([string]::IsNullOrEmpty($AutoScale)){$AutoSc = $false}else{$AutoSc = $true}
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach ($Tag in $Tags) {
                        $obj = @{
                            'Subscription'        = $sub1.name;
                            'Resource Group'      = $1.RESOURCEGROUP;
                            'Name'                = $1.NAME;
                            'Location'            = $1.LOCATION;
                            'Pricing Tier'        = ($sku.tier+'('+$sku.name+': '+$data.currentNumberOfWorkers+')');
                            'Compute Mode'        = $data.computeMode;
                            'Intances Size'       = $data.currentWorkerSize;
                            'Current Instances'   = $data.currentNumberOfWorkers;
                            'Autoscale Enabled'   = $AutoSc;
                            'Max Instances'       = $data.maximumNumberOfWorkers;                                                            
                            'App Plan OS'         = if ($data.reserved -eq 'true') { 'Linux' }else { 'Windows' };
                            'Apps Type'           = $data.kind;
                            'Apps'                = $data.numberOfSites;                    
                            'Zone Redundant'      = $data.zoneRedundant;
                            'Resource U'          = $ResUCount;
                            'Tag Name'            = [string]$Tag.Name;
                            'Tag Value'           = [string]$Tag.Value
                        }
                        $tmp += $obj
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

    if($SmaResources.APPSERVICEPLAN)
    {

        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

        $condtxt = @()       
        $condtxt += New-ConditionalText FALSE -Range I:I
        $condtxt += New-ConditionalText FALSO -Range I:I
        $condtxt += New-ConditionalText FALSE -Range M:M
        $condtxt += New-ConditionalText FALSO -Range M:M
        $condtxt += New-ConditionalText Free -Range E:E
        $condtxt += New-ConditionalText Basic -Range E:E

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('Pricing Tier')
        $Exc.Add('Compute Mode')
        $Exc.Add('Intances Size')
        $Exc.Add('Current Instances')
        $Exc.Add('Autoscale Enabled')
        $Exc.Add('Max Instances')
        $Exc.Add('App Plan OS')
        $Exc.Add('Apps Type')
        $Exc.Add('Apps')
        $Exc.Add('Zone Redundant')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $ExcelVar =  $SmaResources.APPSERVICEPLAN 

        $ExcelVar | 
        ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        Export-Excel -Path $File -WorksheetName 'App Service Plan' -AutoSize -MaxAutoSizeRows 100 -TableName 'AppSvcPlan' -TableStyle $tableStyle -ConditionalText $condtxt -Style $Style

    }
}