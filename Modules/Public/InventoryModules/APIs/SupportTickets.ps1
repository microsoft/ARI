<#
.Synopsis
Inventory for Azure Support Tickets

.DESCRIPTION
Excel Sheet Name: SupportTickets

.Link
https://github.com/microsoft/ARI/Modules/APIs/SupportTickets.ps1

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

    $Tickets = $Resources | Where-Object { $_.TYPE -eq 'Microsoft.Support/supportTickets' }

    <######### Insert the resource Process here ########>

    if($Tickets)
        {
            $tmp = foreach ($1 in $Tickets) {
                $ResUCount = 1
                $data = $1.PROPERTIES

                $timecreated = $data.createdDate
                $timecreated = [datetime]$timecreated
                $timecreated = $timecreated.ToString("yyyy-MM-dd HH:mm")

                $ProblemDate = $data.problemStartTime
                $ProblemDate = [datetime]$ProblemDate
                $ProblemDate = $ProblemDate.ToString("yyyy-MM-dd HH:mm")

                $ModDate = $data.modifiedDate
                $ModDate = [datetime]$ModDate
                $ModDate = $ModDate.ToString("yyyy-MM-dd HH:mm")

                $obj = @{
                    'ID'                        = $1.id;
                    'Support Ticket'            = $data.supportTicketId;
                    'Title'                     = $data.title;
                    'Support Plan'              = $data.supportPlanType;
                    'Service'                   = $data.serviceDisplayName;
                    'Current Severity'          = $data.severity;
                    'Status'                    = $data.status;
                    'Creation Date'             = $timecreated;
                    '24/7 Response'             = $data.require24X7Response;
                    'Ticket SLA (minutes)'      = $data.serviceLevelAgreement.slaMinutes;
                    'Problem Start Date'        = $ProblemDate;
                    'Last Modified Date'        = $ModDate;
                    'Support Engineer'          = $data.supportEngineer.emailAddress;
                    'Ticket Contact Name'       = ($data.contactDetails.firstName + ' ' + $data.contactDetails.lastName);
                    'Ticket Contact Email'      = $data.contactDetails.primaryEmailAddress;
                    'Ticket Contact Country'    = $data.contactDetails.country;
                    'Resource U'                = $ResUCount
                }
                $obj
            }
            $tmp
        }
}

<######## Resource Excel Reporting Begins Here ########>

Else {
    <######## $SmaResources.(RESOURCE FILE NAME) ##########>

    if ($SmaResources) {

        $TableName = ('TicketsTable_'+($SmaResources.'Resource U').count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

        $cond = @()
        $cond += New-ConditionalText Open -Range F:F

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Support Ticket')
        $Exc.Add('Title')
        $Exc.Add('Support Plan')         
        $Exc.Add('Service')
        $Exc.Add('Current Severity')
        $Exc.Add('Status')
        $Exc.Add('Creation Date')
        $Exc.Add('24/7 Response')
        $Exc.Add('Ticket SLA (minutes)')
        $Exc.Add('Support Engineer')
        $Exc.Add('Problem Start Date')
        $Exc.Add('Last Modified Date')
        $Exc.Add('Ticket Contact Name')
        $Exc.Add('Ticket Contact Email')
        $Exc.Add('Ticket Contact Country')

        [PSCustomObject]$SmaResources | 
        ForEach-Object { $_ } | Select-Object $Exc | 
        Export-Excel -Path $File -WorksheetName 'Support Tickets' -TableName $TableName -MaxAutoSizeRows 100 -TableStyle $tableStyle -ConditionalText $cond -Style $Style

    }
}