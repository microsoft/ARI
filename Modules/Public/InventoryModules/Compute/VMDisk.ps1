<#
.Synopsis
Inventory for Azure Disk

.DESCRIPTION
This script consolidates information for all microsoft.compute/disks resource provider in $Resources variable. 
Excel Sheet Name: VMDISK

.Link
https://github.com/microsoft/ARI/Modules/Public/InventoryModules/Compute/VMDisk.ps1

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

        $disk = $Resources | Where-Object {$_.TYPE -eq 'microsoft.compute/disks'}

    <######### Insert the resource Process here ########>

    if($disk)
        {
            $tmp = foreach ($1 in $disk) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.Id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $timecreated = $data.timeCreated
                $timecreated = [datetime]$timecreated
                $timecreated = $timecreated.ToString("yyyy-MM-dd HH:mm")
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
                $SKU = $1.SKU
                $Hibernation = if (![string]::IsNullOrEmpty($data.supportsHibernation)) { $data.supportsHibernation }else { $false }
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach ($Tag in $Tags) {
                        $obj = @{
                            'ID'                     = $1.id;
                            'Subscription'           = $sub1.Name;
                            'Resource Group'         = $1.RESOURCEGROUP;
                            'Disk Name'              = $1.NAME;
                            'Retiring Feature'       = $RetiringFeature;
                            'Retiring Date'          = $RetiringDate;
                            'Disk State'             = $data.diskState;
                            'Associated Resource'    = $1.MANAGEDBY.split('/')[8];
                            'Location'               = $1.LOCATION;
                            'Zone'                   = [string]$1.ZONES;
                            'SKU'                    = $SKU.Name;
                            'Disk Size'              = $data.diskSizeGB;
                            'Performance Tier'       = $data.tier;
                            'Disk IOPS Read / Write' = $data.diskIOPSReadWrite;
                            'Disk MBps Read / Write' = $data.diskMBpsReadWrite;
                            'Public Network Access'  = $data.publicNetworkAccess;
                            'Connection Type'        = $data.networkAccessPolicy;
                            'Hibernation Supported'  = $Hibernation;
                            'Encryption'             = $data.encryption.type;
                            'OS Type'                = $data.osType;
                            'Max Shares'             = $data.maxShares;
                            'Data Access Auth Mode'  = $data.dataAccessAuthMode;   
                            'HyperV Generation'      = $data.hyperVGeneration;
                            'Created Time'           = $timecreated;   
                            'Resource U'             = $ResUCount;
                            'Tag Name'               = [string]$Tag.Name;
                            'Tag Value'              = [string]$Tag.Value
                        }
                        $obj
                        if ($ResUCount -eq 1) { $ResUCount = 0}
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

        $SheetName = 'Disks'

        $TableName = ('VMDiskT_'+($SmaResources.'Resource U').count)

        $condtxt = @()
        $condtxt += New-ConditionalText Unattached -Range F:F
        #Retirement
        $condtxt += New-ConditionalText -Range D2:D100 -ConditionalType ContainsText

        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Disk Name')
        $Exc.Add('Retiring Feature')
        $Exc.Add('Retiring Date')
        $Exc.Add('Disk State')
        $Exc.Add('Associated Resource')
        $Exc.Add('Location')  
        $Exc.Add('Zone')
        $Exc.Add('SKU')
        $Exc.Add('Disk Size')
        $Exc.Add('Performance Tier')
        $Exc.Add('Disk IOPS Read / Write')
        $Exc.Add('Disk MBps Read / Write')
        $Exc.Add('Public Network Access')
        $Exc.Add('Connection Type')
        $Exc.Add('Hibernation Supported')
        $Exc.Add('Encryption')
        $Exc.Add('OS Type')
        $Exc.Add('Max Shares')
        $Exc.Add('Data Access Auth Mode')
        $Exc.Add('HyperV Generation')
        $Exc.Add('Created Time')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        [PSCustomObject]$SmaResources | 
        ForEach-Object { $_ } | Select-Object $Exc | 
        Export-Excel -Path $File -WorksheetName $SheetName -TableName $TableName -MaxAutoSizeRows 100 -TableStyle $tableStyle -ConditionalText $condtxt -Style $Style

    }
}