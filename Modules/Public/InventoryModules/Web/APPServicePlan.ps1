<#
.Synopsis
Inventory for Azure App Service Plan

.DESCRIPTION
This script consolidates information for all microsoft.web/serverfarms resource provider in $Resources variable. 
Excel Sheet Name: APPSERVICEPLAN

.Link
https://github.com/microsoft/ARI/Modules/Public/InventoryModules/Web/APPServicePlan.ps1

.COMPONENT
    This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.6.0
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Retirements, $Task ,$File, $SmaResources, $TableStyle, $Unsupported)

If ($Task -eq 'Processing')
{

    <######### Insert the resource extraction here ########>

        $APPSvcPlan = $Resources | Where-Object {$_.TYPE -eq 'microsoft.web/serverfarms'}
        $APPAutoScale = $Resources | Where-Object {$_.TYPE -eq "microsoft.insights/autoscalesettings" -and $_.Properties.enabled -eq 'true'}
        
    <######### Insert the resource Process here ########>

    if($APPSvcPlan)
        {
            $tmp = foreach ($1 in $APPSvcPlan) {
                $ResUCount = 1
                Remove-Variable AutoScale -ErrorAction SilentlyContinue
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $sku = $1.SKU
                $Orphaned = if([string]::IsNullOrEmpty($data.numberOfSites) -or $data.numberOfSites -eq 0){$true}else{$false}
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
                $AutoScale = ($APPAutoScale | Where-Object {$_.Properties.targetResourceUri -eq $1.id})
                if([string]::IsNullOrEmpty($AutoScale)){$AutoSc = $false}else{$AutoSc = $true}
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach ($Tag in $Tags) {
                        $obj = @{
                            'ID'                  = $1.id;
                            'Subscription'        = $sub1.Name;
                            'Resource Group'      = $1.RESOURCEGROUP;
                            'Name'                = $1.NAME;
                            'Location'            = $1.LOCATION;
                            'Retiring Feature'    = $RetiringFeature;
                            'Retiring Date'       = $RetiringDate;
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
                            'Orphaned'            = $Orphaned;
                            'Resource U'          = $ResUCount;
                            'Tag Name'            = [string]$Tag.Name;
                            'Tag Value'           = [string]$Tag.Value
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
        $TableName = ('AppSvcPlanTable_'+($SmaResources.'Resource U').count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

        $condtxt = @()
        $condtxt += New-ConditionalText FALSE -Range K:K
        $condtxt += New-ConditionalText FALSE -Range O:O
        $condtxt += New-ConditionalText Free -Range G:G
        $condtxt += New-ConditionalText Basic -Range G:G
        #Retirement
        $condtxt += New-ConditionalText -Range E2:E100 -ConditionalType ContainsText
        $condtxt += New-ConditionalText TRUE -Range H:H
        

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('Retiring Feature')
        $Exc.Add('Retiring Date')
        $Exc.Add('Pricing Tier')
        $Exc.Add('Orphaned')
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

        [PSCustomObject]$SmaResources | 
        ForEach-Object { $_ } | Select-Object $Exc | 
        Export-Excel -Path $File -WorksheetName 'App Service Plan' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -ConditionalText $condtxt -Style $Style

    }
}