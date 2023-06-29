<#
.Synopsis
Inventory for Azure Application Insights

.DESCRIPTION
This script consolidates information for all  resource provider in $Resources variable. 
Excel Sheet Name: AppInsights

.Link
https://github.com/microsoft/ARI/Modules/Integration/AppInsights.ps1

.COMPONENT
    This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.0.1
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Task , $File, $SmaResources, $TableStyle, $Unsupported)

If ($Task -eq 'Processing') {

    <######### Insert the resource extraction here ########>

    $AppInsights = $Resources | Where-Object { $_.TYPE -eq 'microsoft.insights/components' }

    if($AppInsights)
        {
            $tmp = @()
            foreach ($1 in $AppInsights) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $RetDate = ''
                $RetFeature = '' 
                $timecreated = $data.CreationDate
                $timecreated = [datetime]$timecreated
                $timecreated = $timecreated.ToString("yyyy-MM-dd HH:mm")
                $Sampling = if([string]::IsNullOrEmpty($data.SamplingPercentage)){'Disabled'}else{$data.SamplingPercentage}
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                    foreach ($Tag in $Tags) {
                        $obj = @{
                            'ID'                                = $1.id;
                            'Subscription'                      = $sub1.Name;
                            'Resource Group'                    = $1.RESOURCEGROUP;
                            'Name'                              = $1.NAME;
                            'Location'                          = $1.LOCATION;
                            'Application Type'                  = $data.Application_Type;
                            'Retirement Date'                   = [string]$RetDate;
                            'Retirement Feature'                = $RetFeature;
                            'Flow Type'                         = $data.Flow_Type;
                            'Version'                           = $data.Ver;
                            'Request Source'                    = $data.Request_Source;
                            'Data Sampling %'                   = [string]$Sampling;
                            'Retention In Days'                 = $data.RetentionInDays;
                            'Ingestion Mode'                    = $data.IngestionMode;
                            'Public Access For Ingestion'       = $data.publicNetworkAccessForIngestion;
                            'Public Access For Query'           = $data.publicNetworkAccessForQuery;    
                            'Created Time'                      = $timecreated;                            
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

    if ($SmaResources.AppInsights) {

        $TableName = ('AppInsightsTable_'+($SmaResources.AppInsights.id | Select-Object -Unique).count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0

        $condtxt = @()
        $condtxt += New-ConditionalText Disabled -Range K:K
        $condtxt += New-ConditionalText - -Range F:F -ConditionalType ContainsText
        
        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('Application Type')
        $Exc.Add('Retirement Date')
        $Exc.Add('Retirement Feature') 
        $Exc.Add('Flow Type')
        $Exc.Add('Version')
        $Exc.Add('Request Source')
        $Exc.Add('Data Sampling %')
        $Exc.Add('Retention In Days')
        $Exc.Add('Ingestion Mode')
        $Exc.Add('Public Access For Ingestion')
        $Exc.Add('Public Access For Query')
        $Exc.Add('Created Time')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        $ExcelVar = $SmaResources.AppInsights 

        $ExcelVar | 
        ForEach-Object { [PSCustomObject]$_ } | Select-Object -Unique $Exc | 
        Export-Excel -Path $File -WorksheetName 'AppInsights' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -TableStyle $tableStyle -Style $Style -ConditionalText $condtxt

    }
    <######## Insert Column comments and documentations here following this model #########>
}