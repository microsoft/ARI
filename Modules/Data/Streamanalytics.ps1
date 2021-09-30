<#
.Synopsis
Inventory for Azure Stream Analytics Jobs

.DESCRIPTION
This script consolidates information for all microsoft.streamanalytics/streamingjobs resource provider in $Resources variable. 
Excel Sheet Name: Streamanalytics

.Link
https://github.com/azureinventory/ARI/Modules/Data/Streamanalytics.ps1

.COMPONENT
   This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 2.0.0
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Task , $File, $SmaResources, $TableStyle)

If ($Task -eq 'Processing') {

    <######### Insert the resource extraction here ########>

    $Streamanalytics = $Resources | Where-Object { $_.TYPE -eq 'microsoft.streamanalytics/streamingjobs' }

    if($Streamanalytics)
        {
            $tmp = @()

            foreach ($1 in $Streamanalytics) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $Creadate = (get-date $data.createdDate).ToString("yyyy-MM-dd HH:mm:ss")
                $LastOutput = (get-date $data.lastOutputEventTime).ToString("yyyy-MM-dd HH:mm:ss:ffff")
                $OutputStart = (get-date $data.outputStartTime).ToString("yyyy-MM-dd HH:mm:ss:ffff")
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach ($Tag in $Tags) {
                        $obj = @{
                            'Subscription'                      = $sub1.name;
                            'Resource Group'                    = $1.RESOURCEGROUP;
                            'Name'                              = $1.NAME;
                            'Location'                          = $1.LOCATION;
                            'SKU'                               = $data.sku.name;
                            'Compatibility Level'               = $data.compatibilityLevel;
                            'Content Storage Policy'            = $data.contentStoragePolicy;
                            'Created Date'                      = $Creadate;
                            'Data Locale'                       = $data.dataLocale;
                            'Late Arrival Max Delay in Seconds' = $data.eventsLateArrivalMaxDelayInSeconds;
                            'Out of Order Max Delay in Seconds' = $data.eventsOutOfOrderMaxDelayInSeconds;
                            'Out of Order Policy'               = $data.eventsOutOfOrderPolicy;
                            'Job State'                         = $data.jobState;
                            'Job Type'                          = $data.jobType;
                            'Last Output Event Time'            = $LastOutput;
                            'Output Start Time'                 = $OutputStart;
                            'Output Error Policy'               = $data.outputErrorPolicy;
                            'Tag Name'                          = [string]$Tag.Name;
                            'Tag Value'                         = [string]$Tag.Value
                        }
                        $tmp += $obj
                        if ($ResUCount -eq 1) { $ResUCount = 0 } 
                    }                
            }
            $tmp
        }
}
<######## Resource Excel Reporting Begins Here ########>

Else {
    <######## $SmaResources.(RESOURCE FILE NAME) ##########>

    if ($SmaResources.ExcelStreamanalytics) {
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0
        
        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('SKU')
        $Exc.Add('Compatibility Level')
        $Exc.Add('Content Storage Policy')
        $Exc.Add('Created Date')
        $Exc.Add('Data Locale')
        $Exc.Add('Late Arrival Max Delay in Seconds')
        $Exc.Add('Out of Order Max Delay in Seconds')
        $Exc.Add('Out of Order Policy')
        $Exc.Add('Job State')
        $Exc.Add('Job Type')
        $Exc.Add('Last Output Event Time')
        $Exc.Add('Output Start Time')
        $Exc.Add('Output Error Policy')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $ExcelVar = $SmaResources.ExcelStreamanalytics 

        $ExcelVar | 
        ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        Export-Excel -Path $File -WorksheetName 'Stream Analytics Jobs' -AutoSize -MaxAutoSizeRows 100 -TableName 'AzureStreamAnalyticsJobs' -TableStyle $tableStyle -Style $Style

    }
    <######## Insert Column comments and documentations here following this model #########>
}