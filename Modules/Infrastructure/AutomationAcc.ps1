<#
.Synopsis
Inventory for Azure Automation Account

.DESCRIPTION
This script consolidates information for all microsoft.automation/automationaccounts and  resource provider in $Resources variable. 
Excel Sheet Name: AutomationAcc

.Link
https://github.com/azureinventory/ARI/Modules/Infrastructure/AutomationAcc.ps1

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

        $runbook = $Resources | Where-Object {$_.TYPE -eq 'microsoft.automation/automationaccounts/runbooks'}
        $autacc = $Resources | Where-Object {$_.TYPE -eq 'microsoft.automation/automationaccounts'}

    <######### Insert the resource Process here ########>

    if($autacc)
        {
            $tmp = @()

            foreach ($0 in $autacc) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $0.subscriptionId }
                                    
                $rbs = $runbook | Where-Object { $_.id.split('/')[8] -eq $0.name }
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                if ($null -ne $rbs) {
                    foreach ($1 in $rbs) {
                            foreach ($Tag in $Tags) {    
                                $data = $1.PROPERTIES
                                $obj = @{
                                    'Subscription'             = $sub1.name;
                                    'Resource Group'           = $0.RESOURCEGROUP;
                                    'Automation Account Name'  = $0.NAME;
                                    'Automation Account State' = $0.properties.State;
                                    'Automation Account SKU'   = $0.properties.sku.name;
                                    'Location'                 = $0.LOCATION;
                                    'Runbook Name'             = $1.Name;
                                    'Last Modified Time'       = ([datetime]$data.lastModifiedTime).tostring('MM/dd/yyyy hh:mm') ;
                                    'Runbook State'            = $data.state;
                                    'Runbook Type'             = $data.runbookType;
                                    'Runbook Description'      = $data.description;
                                    'Job Count'                = $data.jobCount;
                                    'Resource U'               = $ResUCount;
                                    'Tag Name'                 = [string]$Tag.Name;
                                    'Tag Value'                = [string]$Tag.Value
                                }
                                $tmp += $obj
                                if ($ResUCount -eq 1) { $ResUCount = 0 } 
                            }                        
                    }
                }
                else {
                        foreach ($Tag in $Tags) {  
                            $obj = @{
                                'Subscription'             = $sub1.name;
                                'Resource Group'           = $0.RESOURCEGROUP;
                                'Automation Account Name'  = $0.NAME;
                                'Automation Account State' = $0.properties.State;
                                'Automation Account SKU'   = $0.properties.sku.name;
                                'Location'                 = $0.LOCATION;
                                'Runbook Name'             = $null;
                                'Last Modified Time'       = $null;
                                'Runbook State'            = $null;
                                'Runbook Type'             = $null;
                                'Runbook Description'      = $null;
                                'Job Count'                = $null;
                                'Resource U'               = $ResUCount;
                                'Tag Name'                 = [string]$Tag.Name;
                                'Tag Value'                = [string]$Tag.Value
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

    if($SmaResources.AutomationAcc)
    {

        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'
        $StyleExt = New-ExcelStyle -HorizontalAlignment Left -Range K:K -Width 80 -WrapText 

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Automation Account Name')
        $Exc.Add('Automation Account State')
        $Exc.Add('Automation Account SKU')
        $Exc.Add('Location')
        $Exc.Add('Runbook Name')
        $Exc.Add('Last Modified Time')
        $Exc.Add('Runbook State')
        $Exc.Add('Runbook Type')
        $Exc.Add('Runbook Description')
        $Exc.Add('Job Count')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $ExcelVar = $SmaResources.AutomationAcc  
            
        $ExcelVar | 
        ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        Export-Excel -Path $File -WorksheetName 'Runbooks' -AutoSize -MaxAutoSizeRows 100 -TableName 'AzureRunbooks' -TableStyle $tableStyle -Style $Style, $StyleExt

        <######## Insert Column comments and documentations here following this model #########>


        #$excel = Open-ExcelPackage -Path $File -KillExcel


        #Close-ExcelPackage $excel 

    }
}