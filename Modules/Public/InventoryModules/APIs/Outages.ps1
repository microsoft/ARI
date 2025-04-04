<#
.Synopsis
Inventory for Azure Outages

.DESCRIPTION
Excel Sheet Name: Outages

.Link
https://github.com/microsoft/ARI/Modules/APIs/Outages.ps1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 4.0.1
First Release Date: 25th Aug, 2024
Authors: Claudio Merola 

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Retirements, $Task, $File, $SmaResources, $TableStyle, $Unsupported)

If ($Task -eq 'Processing') {

    <######### Insert the resource extraction here ########>

    $Outages = $Resources | Where-Object { $_.TYPE -eq 'Microsoft.ResourceHealth/events' -and $_.properties.description -like '*How can customers make incidents like this less impactful?*' }

    <######### Insert the resource Process here ########>

    if($Outages)
        {
            $tmp = foreach ($1 in $Outages) {
                $ImpactedSubs = $1.properties.impact.impactedRegions.impactedSubscriptions | Select-Object -Unique
                $ResUCount = 1

                $Data = $1.properties

                foreach ($Sub0 in $ImpactedSubs)
                    {
                        $sub1 = $SUB | Where-Object { $_.id -eq $Sub0 }

                        $StartTime = $Data.impactStartTime
                        $StartTime = [datetime]$StartTime
                        $StartTime = $StartTime.ToString("yyyy-MM-dd HH:mm")

                        $Mitigation = $Data.impactMitigationTime
                        $Mitigation = [datetime]$Mitigation
                        $Mitigation = $Mitigation.ToString("yyyy-MM-dd HH:mm")

                        $ImpactedService = if ($1.properties.impact.impactedService.count -gt 1) { $1.properties.impact.impactedService | ForEach-Object { $_ + ' ,' } }else { $1.properties.impact.impactedService}
                        $ImpactedService = [string]$ImpactedService
                        $ImpactedService = if ($ImpactedService -like '* ,*') { $ImpactedService -replace ".$" }else { $ImpactedService }

                        $HTML = New-Object -Com 'HTMLFile'
                        $HTML.write([ref]$1.properties.description)
                        $OutageDescription = $Html.body.innerText
                        $SplitDescription = $OutageDescription.split('How can we make our incident communications more useful?').split('How can customers make incidents like this less impactful?').split('How are we making incidents like this less likely or less impactful?').split('How did we respond?').split('What went wrong and why?').split('What happened?')

                        $obj = @{
                            'ID'                                                                  = $1.id;
                            'Subscription'                                                        = $sub1.name;
                            'Outage ID'                                                           = $1.name;
                            'Event Type'                                                          = $Data.eventType;
                            'Status'                                                              = $Data.status;
                            'Event Level'                                                         = $Data.eventlevel;
                            'Title'                                                               = $Data.title;
                            'Impact Start Time'                                                   = $StartTime;
                            'Impact Mitigation Time'                                              = $Mitigation;
                            'Impacted Services'                                                   = $ImpactedService;
                            'What happened'                                                       = ($SplitDescription[1]).Split([Environment]::NewLine)[1];
                            'What went wrong and why'                                             = ($SplitDescription[2]).Split([Environment]::NewLine)[1];
                            'How did we respond'                                                  = ($SplitDescription[3]).Split([Environment]::NewLine)[1];
                            'How are we making incidents like this less likely or less impactful' = ($SplitDescription[4]).Split([Environment]::NewLine)[1];
                            'How can customers make incidents like this less impactful'           = ($SplitDescription[5]).Split([Environment]::NewLine)[1];
                            'Resource U'                                                          = $ResUCount
                        }
                        $obj
                        if ($ResUCount -eq 1) { $ResUCount = 0 } 
                    }
                }
            $tmp
        }
}

<######## Resource Excel Reporting Begins Here ########>

Else {
    <######## $SmaResources.(RESOURCE FILE NAME) ##########>

    if ($SmaResources) {

        $TableName = ('OutageTab_'+($SmaResources.'Resource U').count)

        $Style = @(
        New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0' -Range 'A:E'
        New-ExcelStyle -HorizontalAlignment Left -NumberFormat '0' -WrapText -Width 55 -Range 'F:F'
        New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0' -Range 'G:I'
        New-ExcelStyle -HorizontalAlignment Left -NumberFormat '0' -WrapText -Width 80 -Range 'J:N'
        )

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Outage ID')
        $Exc.Add('Event Type')       
        $Exc.Add('Status')
        $Exc.Add('Event Level')
        $Exc.Add('Title')
        $Exc.Add('Impact Start Time')
        $Exc.Add('Impact Mitigation Time')
        $Exc.Add('Impacted Services')
        $Exc.Add('What happened')
        $Exc.Add('What went wrong and why')
        $Exc.Add('How did we respond')
        $Exc.Add('How are we making incidents like this less likely or less impactful')
        $Exc.Add('How can customers make incidents like this less impactful')

        [PSCustomObject]$SmaResources | 
        ForEach-Object { $_ } | Select-Object $Exc | 
        Export-Excel -Path $File -WorksheetName 'Outages' -AutoSize -TableName $TableName -MaxAutoSizeRows 100 -TableStyle $tableStyle -Numberformat '0' -Style $Style

    }
}