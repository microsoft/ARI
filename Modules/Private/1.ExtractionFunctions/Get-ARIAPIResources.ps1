<#
.Synopsis
Module responsible for retrieving Azure API resources.

.DESCRIPTION
This module retrieves Azure API resources, including Resource Health, Managed Identities, Advisor Scores, and Policies.

.Link
https://github.com/microsoft/ARI/Modules/Private/1.ExtractionFunctions/Get-ARIAPIResources.ps1

.COMPONENT
This PowerShell Module is part of Azure Resource Inventory (ARI).

.NOTES
Version: 3.6.13
First Release Date: 15th Oct, 2024
Authors: Claudio Merola
#>
function Get-ARIAPIResources {
    Param($Subscriptions, $AzureEnvironment, $SkipPolicy)

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Starting API Inventory')

    try
        {
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Acquiring Token')
            $Token = Get-AzAccessToken -AsSecureString -InformationAction SilentlyContinue -WarningAction SilentlyContinue -Debug:$false

            $TokenData = $Token.Token | ConvertFrom-SecureString -AsPlainText

            $header = @{
                'Authorization' = 'Bearer ' + $TokenData
            }
        }
    catch
        {
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Error: ' + $_.Exception.Message)
            return
        }
    

    if ($AzureEnvironment -eq 'AzureCloud') {
        $AzURL = 'management.azure.com'
    } 
    elseif ($AzureEnvironment -eq 'AzureUSGovernment') {
        $AzURL = 'management.usgovcloudapi.net'
    }
    elseif ($AzureEnvironment -eq 'AzureChinaCloud') {
        $AzURL = 'management.chinacloudapi.cn'
    }
    else {
        Write-Host ('Invalid Azure Environment for API Rest Inventory: ' + $AzureEnvironment) -ForegroundColor Red
        return
    }
    $ResourceHealthHistoryDate = (Get-Date).AddMonths(-6)
    $APIResults = @()

    Write-Host 'Running API Inventory for ' -NoNewline
    Write-Host ([string]@($Subscriptions).Count + ' subscriptions') -ForegroundColor Cyan

    # One request per subscription and API; all of them run in parallel
    $Requests = foreach ($Subscription in $Subscriptions)
        {
            $Sub = $Subscription.id
            $Base = ('https://' + $AzURL + '/subscriptions/' + $Sub + '/providers/')
            [PSCustomObject]@{ Key = "$Sub|ResourceHealth"; Uri = ($Base + 'Microsoft.ResourceHealth/events?api-version=2022-10-01&queryStartTime=' + $ResourceHealthHistoryDate) }
            [PSCustomObject]@{ Key = "$Sub|Identities"; Uri = ($Base + 'Microsoft.ManagedIdentity/userAssignedIdentities?api-version=2023-01-31') }
            [PSCustomObject]@{ Key = "$Sub|AdvisorScore"; Uri = ($Base + 'Microsoft.Advisor/advisorScore?api-version=2023-01-01') }
            [PSCustomObject]@{ Key = "$Sub|Reservation"; Uri = ($Base + 'Microsoft.Consumption/reservationRecommendations?api-version=2023-05-01') }
            if (!$SkipPolicy.isPresent)
                {
                    [PSCustomObject]@{ Key = "$Sub|PolicyAssign"; Uri = ($Base + 'Microsoft.PolicyInsights/policyStates/latest/summarize?api-version=2019-10-01'); Method = 'POST' }
                    [PSCustomObject]@{ Key = "$Sub|PolicySetDef"; Uri = ($Base + 'Microsoft.Authorization/policySetDefinitions?api-version=2023-04-01') }
                    [PSCustomObject]@{ Key = "$Sub|PolicyDef"; Uri = ($Base + 'Microsoft.Authorization/policyDefinitions?api-version=2023-04-01') }
                }
        }

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Sending ' + @($Requests).Count + ' API requests in parallel')
    $Responses = Invoke-ARIRestParallel -Requests $Requests -Header $header

    foreach ($Subscription in $Subscriptions)
        {
            $Sub = $Subscription.id

            $PolicyAssign = ""
            $PolicySetDef = ""
            $PolicyDef = ""
            if (!$SkipPolicy.isPresent)
                {
                    # As before: if any policy call failed, report no policy data for the subscription
                    if ($Responses["$Sub|PolicyAssign"] -and $Responses["$Sub|PolicySetDef"] -and $Responses["$Sub|PolicyDef"])
                        {
                            $PolicyAssign = $Responses["$Sub|PolicyAssign"].value
                            $PolicySetDef = $Responses["$Sub|PolicySetDef"].value
                            $PolicyDef = $Responses["$Sub|PolicyDef"].value
                        }
                }

            $tmp = @{
                'Subscription'          = $Sub;
                'ResourceHealth'        = $Responses["$Sub|ResourceHealth"].value;
                'ManagedIdentities'     = $Responses["$Sub|Identities"].value;
                'AdvisorScore'          = $Responses["$Sub|AdvisorScore"].value;
                'ReservationRecomen'    = $Responses["$Sub|Reservation"].value;
                'PolicyAssign'          = $PolicyAssign;
                'PolicyDef'             = $PolicyDef;
                'PolicySetDef'          = $PolicySetDef
            }
            $APIResults += $tmp

        }

        <#
        $Body = @{
            reportType = "OverallSummaryReport"
            subscriptionList = @($Subscri)
            carbonScopeList = @("Scope1")
            dateRange = @{
                start = "2024-06-01"
                end = "2024-06-30"
            }
        }
        $url = 'https://management.azure.com/providers/Microsoft.Carbon/carbonEmissionReports?api-version=2023-04-01-preview'
        #$url = 'https://management.azure.com/providers/Microsoft.Carbon/queryCarbonEmissionDataAvailableDateRange?api-version=2023-04-01-preview'

        $Carbon = Invoke-RestMethod -Uri $url -Headers $header -Body ($Body | ConvertTo-Json) -Method POST -ContentType 'application/json'

        

        $Today = Get-Date
        $EndDate = Get-Date -Year $Today.Year -Month $Today.Month -Day $Today.Day -Hour 23 -Minute 59 -Second 59 -Millisecond 0
        $Days = 60
        $StartDate = ($EndDate).AddDays(-$Days)

        $Hash = @{name="PreTaxCost";function="Sum"}
        $MHash = @{totalCost=$Hash}
        $Granularity = 'Monthly'

        $Grouping = @()
        $GTemp = @{Name='ResourceType';Type='Dimension'}
        $Grouping += $GTemp
        $GTemp = @{Name='ResourceGroup';Type='Dimension'}
        $Grouping += $GTemp

        $Body = @{
                type = "ActualCost"
                timeframe = "Custom"
                dataset = @{
                    granularity = $Granularity
                    aggregation = @($MHash)
                    }
                grouping = $Grouping
                timePeriod = @{
                    startDate = $StartDate
                    endDate = $EndDate
                }
        }

        $url = 'https://management.azure.com/subscriptions/$sub/providers/Microsoft.CostManagement/query?api-version=2019-11-01'

        $Cost = Invoke-RestMethod -Uri $url -Headers $header -Body ($Body | ConvertTo-Json -Depth 10) -Method POST -ContentType 'application/json'

        #>

        return $APIResults
}