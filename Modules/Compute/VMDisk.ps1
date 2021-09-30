<#
.Synopsis
Inventory for Azure Disk

.DESCRIPTION
This script consolidates information for all microsoft.compute/disks resource provider in $Resources variable. 
Excel Sheet Name: VMDISK

.Link
https://github.com/azureinventory/ARI/Modules/Compute/VMDISK.ps1

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

        $disk = $Resources | Where-Object {$_.TYPE -eq 'microsoft.compute/disks'}

    <######### Insert the resource Process here ########>

    if($disk)
        {
            $tmp = @()

            foreach ($1 in $disk) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $SKU = $1.SKU 
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach ($Tag in $Tags) {
                        $obj = @{
                            'Subscription'           = $sub1.name;
                            'Resource Group'         = $1.RESOURCEGROUP;                            
                            'Disk Name'              = $1.NAME;
                            'Disk State'             = $data.diskState;
                            'Associated Resource'    = $1.MANAGEDBY.split('/')[8];
                            'Location'               = $1.LOCATION;
                            'Zone'                   = [string]$1.ZONES;
                            'SKU'                    = $SKU.Name;
                            'Disk Size'              = $data.diskSizeGB;
                            'Encryption'             = $data.encryption.type;
                            'OS Type'                = $data.osType;
                            'Disk IOPS Read / Write' = $data.diskIOPSReadWrite;
                            'Disk MBps Read / Write' = $data.diskMBpsReadWrite;                            
                            'HyperV Generation'      = $data.hyperVGeneration;
                            'Resource U'             = $ResUCount;
                            'Tag Name'               = [string]$Tag.Name;
                            'Tag Value'              = [string]$Tag.Value
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

    if($SmaResources.VMDisk)
    {

        $condtxt = New-ConditionalText Unattached -Range D:D
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'
         
        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Disk Name')
        $Exc.Add('Disk State')
        $Exc.Add('Associated Resource')        
        $Exc.Add('Zone')
        $Exc.Add('SKU')
        $Exc.Add('Disk Size')
        $Exc.Add('Location')
        $Exc.Add('Encryption')
        $Exc.Add('OS Type')        
        $Exc.Add('Disk IOPS Read / Write')
        $Exc.Add('Disk MBps Read / Write')
        $Exc.Add('HyperV Generation')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $ExcelVar = $SmaResources.VMDisk

        $ExcelVar | 
        ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        Export-Excel -Path $File -WorksheetName 'Disks' -TableName 'AzureDisks' -MaxAutoSizeRows 100 -TableStyle $tableStyle -ConditionalText $condtxt -Style $Style


        <######## Insert Column comments and documentations here following this model #########>

        $excel = Open-ExcelPackage -Path $File -KillExcel

        $null = $excel.Disks.Cells["D1"].AddComment("When you delete a virtual machine (VM) in Azure, by default, any disks that are attached to the VM aren't deleted. After a VM is deleted, you will continue to pay for unattached disks.", "Azure Resource Inventory")
        $excel.Disks.Cells["D1"].Hyperlink = 'https://docs.microsoft.com/en-us/azure/virtual-machines/windows/find-unattached-disks'

        Close-ExcelPackage $excel 

    }
}