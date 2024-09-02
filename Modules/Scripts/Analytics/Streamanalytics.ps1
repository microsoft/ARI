<#
.Synopsis
Inventory for Azure Stream Analytics Jobs

.DESCRIPTION
This script consolidates information for all microsoft.streamanalytics/streamingjobs resource provider in $Resources variable. 
Excel Sheet Name: Streamanalytics

.Link
https://github.com/microsoft/ARI/Modules/Data/Streamanalytics.ps1

.COMPONENT
    This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.0.2
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Task , $File, $SmaResources, $TableStyle, $Unsupported)

If ($Task -eq 'Processing') {

    <######### Insert the resource extraction here ########>

    $StreamAnalyticsCluster = $Resources | Where-Object { $_.TYPE -eq 'microsoft.streamanalytics/clusters' }
    $StreamAnalyticsJobs = $Resources | Where-Object { $_.TYPE -eq 'microsoft.streamanalytics/streamingjobs' }

    if($StreamAnalyticsJobs)
        {
            $tmp = @()
            foreach ($1 in $StreamAnalyticsJobs) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $RetDate = ''
                $RetFeature = ''
                $Cluster = ''
                $Cluster = $StreamAnalyticsCluster | Where-Object {$_.id -eq $data.cluster.id}
                $Creadate = if($data.createdDate){[string](get-date $data.createdDate)}else{''}
                $LastOutput = if($data.lastOutputEventTime){[string](get-date $data.lastOutputEventTime)}else{''}
                $OutputStart = if($data.outputStartTime){[string](get-date $data.outputStartTime)}else{''}
                $ClusterDate = if($Cluster.properties.createddate){[string](get-date($Cluster.properties.createddate))}else{''}
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}

                $sub2 = $SUB | Where-Object { $_.id -eq $Cluster.subscriptionid }
                    foreach ($Tag in $Tags) {
                        $obj = @{
                            'ID'                                        = $1.id;
                            'Cluster Subscription'                      = $sub2.Name;
                            'Cluster Resource Group'                    = $Cluster.resourcegroup;
                            'Cluster Name'                              = $Cluster.NAME;
                            'Cluster Location'                          = $Cluster.location;
                            'Cluster SKU'                               = $Cluster.sku.name;
                            'Capacity Allocated'                        = $Cluster.properties.capacityallocated;
                            'Capacity Assigned'                         = $Cluster.properties.capacityassigned;
                            'Cluster Creation Date'                     = $ClusterDate;
                            'Job Subscription'                          = $sub1.Name;
                            'Job Resource Group'                        = $1.RESOURCEGROUP;
                            'Job Name'                                  = $1.NAME;
                            'Job Location'                              = $1.LOCATION;
                            'Job Pricing Plan'                          = $data.sku.name;
                            'Compatibility Level'                       = $data.compatibilityLevel;
                            'Storage Account'                           = $data.jobstorageaccount.accountname;
                            'Storage Account Auth Method'               = $data.jobstorageaccount.authenticationmode;
                            'Content Storage Policy'                    = $data.contentStoragePolicy;
                            'Created Date'                              = $Creadate;
                            'Retirement Date'                           = [string]$RetDate;
                            'Retirement Feature'                        = $RetFeature;
                            'Data Locale'                               = $data.dataLocale;
                            'Late Arrival Max Delay in Seconds'         = $data.eventsLateArrivalMaxDelayInSeconds;
                            'Out of Order Max Delay in Seconds'         = $data.eventsOutOfOrderMaxDelayInSeconds;
                            'Out of Order Policy'                       = $data.eventsOutOfOrderPolicy;
                            'Job State'                                 = $data.jobState;
                            'Job Type'                                  = $data.jobType;
                            'Last Output Event Time'                    = $LastOutput;
                            'Output Start Time'                         = $OutputStart;
                            'Output Error Policy'                       = $data.outputErrorPolicy;
                            'Tag Name'                                  = [string]$Tag.Name;
                            'Tag Value'                                 = [string]$Tag.Value
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

    if ($SmaResources.Streamanalytics) {

        $TableName = ('StreamsATable_'+($SmaResources.Streamanalytics.id | Select-Object -Unique).count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0

        $condtxt = @()
        $condtxt += New-ConditionalText failed -Range N:N

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Cluster Subscription')
        $Exc.Add('Cluster Resource Group')
        $Exc.Add('Cluster Name')
        $Exc.Add('Cluster Location')
        $Exc.Add('Cluster SKU')
        $Exc.Add('Capacity Allocated')
        $Exc.Add('Capacity Assigned')
        $Exc.Add('Cluster Creation Date')
        $Exc.Add('Job Subscription')
        $Exc.Add('Job Resource Group')
        $Exc.Add('Job Name')
        $Exc.Add('Job Location')
        $Exc.Add('Job Pricing Plan')
        $Exc.Add('Job State')
        $Exc.Add('Compatibility Level')
        $Exc.Add('Storage Account')
        $Exc.Add('Storage Account Auth Method')
        $Exc.Add('Content Storage Policy')
        $Exc.Add('Created Date')
        $Exc.Add('Retirement Date')
        $Exc.Add('Retirement Feature')
        $Exc.Add('Data Locale')
        $Exc.Add('Late Arrival Max Delay in Seconds')
        $Exc.Add('Out of Order Max Delay in Seconds')
        $Exc.Add('Out of Order Policy')
        $Exc.Add('Job Type')
        $Exc.Add('Last Output Event Time')
        $Exc.Add('Output Start Time')
        $Exc.Add('Output Error Policy')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $noNumberConversion = @()
        $noNumberConversion += 'Compatibility Level'

        $ExcelVar = $SmaResources.Streamanalytics 

        $ExcelVar | 
        ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        Export-Excel -Path $File -WorksheetName 'Stream Analytics Jobs' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -ConditionalText $condtxt -Style $Style -NoNumberConversion $noNumberConversion

    }
    <######## Insert Column comments and documentations here following this model #########>
}