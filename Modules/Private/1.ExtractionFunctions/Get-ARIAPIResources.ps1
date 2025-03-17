function Get-ARIAPIResources {
    Param($Subscriptions, $AzureEnvironment, $SkipPolicy, $Debug )
    if ($Debug.IsPresent)
        {
            $DebugPreference = 'Continue'
            $ErrorActionPreference = 'Continue'
        }
    else
        {
            $ErrorActionPreference = "silentlycontinue"
        }

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Starting API Inventory')

    $Token = Get-AzAccessToken -AsSecureString -InformationAction SilentlyContinue -WarningAction SilentlyContinue

    $TokenData = $Token.Token | ConvertFrom-SecureString -AsPlainText

    $header = @{
        'Authorization' = 'Bearer ' + $TokenData
    }

    if ($AzureEnvironment -eq 'AzureCloud') {
        $AzURL = 'management.azure.com'
    } else {
        $AzURL = 'management.usgovcloudapi.net'
    }
    $ResourceHealthHistoryDate = (Get-Date).AddMonths(-6)
    $APIResults = @()

    foreach ($Subscription in $Subscriptions)
        {
            $ResourceHealth = ""
            $Identities = ""
            $ADVScore = ""
            $ReservationRecon = ""
            $PolicyAssign = ""
            $PolicySetDef = ""
            $PolicyDef = ""

            $SubName = $Subscription.Name
            $Sub = $Subscription.id

            Write-Host 'Running API Inventory at: ' -NoNewline
            Write-Host $SubName -ForegroundColor Cyan

            #ResourceHealth Events
            $url = ('https://' + $AzURL + '/subscriptions/' + $Sub + '/providers/Microsoft.ResourceHealth/events?api-version=2022-10-01&queryStartTime=' + $ResourceHealthHistoryDate)
            try {
                $ResourceHealth = Invoke-RestMethod -Uri $url -Headers $header -Method GET
            }
            catch {
                $ResourceHealth = ""
            }
            
            Start-Sleep -Milliseconds 200

            #Managed Identities
            $url = ('https://' + $AzURL + '/subscriptions/' + $Sub + '/providers/Microsoft.ManagedIdentity/userAssignedIdentities?api-version=2023-01-31')
            try {
                $Identities = Invoke-RestMethod -Uri $url -Headers $header -Method GET
            }
            catch {
                $Identities = ""
            }
            Start-Sleep -Milliseconds 200

            #Advisor Score
            $url = ('https://' + $AzURL + '/subscriptions/' + $Sub + '/providers/Microsoft.Advisor/advisorScore?api-version=2023-01-01')
            try {
                $ADVScore = Invoke-RestMethod -Uri $url -Headers $header -Method GET
            }
            catch {
                $ADVScore = ""
            }
            Start-Sleep -Milliseconds 200

            #VM Reservation Recomentation
            $url = ('https://' + $AzURL + '/subscriptions/' + $Sub + '/providers/Microsoft.Consumption/reservationRecommendations?api-version=2023-05-01')
            try {
                $ReservationRecon = Invoke-RestMethod -Uri $url -Headers $header -Method GET
            }
            catch {
                $ReservationRecon = ""
            }
            Start-Sleep -Milliseconds 200

            if (!$SkipPolicy.isPresent)
                {
                    #Policies
                    try {
                        $url = ('https://'+ $AzURL +'/subscriptions/'+$sub+'/providers/Microsoft.PolicyInsights/policyStates/latest/summarize?api-version=2019-10-01')
                        $PolicyAssign = (Invoke-RestMethod -Uri $url -Headers $header -Method POST).value
                        Start-Sleep -Milliseconds 200
                        $url = ('https://'+ $AzURL +'/subscriptions/'+$sub+'/providers/Microsoft.Authorization/policySetDefinitions?api-version=2023-04-01')
                        $PolicySetDef = (Invoke-RestMethod -Uri $url -Headers $header -Method GET).value
                        Start-Sleep -Milliseconds 200
                        $url = ('https://'+ $AzURL +'/subscriptions/'+$sub+'/providers/Microsoft.Authorization/policyDefinitions?api-version=2023-04-01')
                        $PolicyDef = (Invoke-RestMethod -Uri $url -Headers $header -Method GET).value
                    }
                    catch {
                        $PolicyAssign = ""
                        $PolicySetDef = ""
                        $PolicyDef = ""
                    }
                }

            #Diagnostic Settings
            $url = ('https://' + $AzURL + '/subscriptions/' + $Sub + '/providers/Microsoft.Quota/usages?api-version=2023-02-01')
            /subscriptions/55ff7d2d-5550-4674-924c-e141deb33e68/resourceGroups/rg-shd-network-hub-brazilsouth/providers/Microsoft.Network/azureFirewalls/fw-shd-hub-brazilsouth-001
            try {
                $DiagSet = Invoke-RestMethod -Uri $url -Headers $header -Method GET
            }
            catch {
                $DiagSet = ""
            }

            $DiagSet.value
            
            Start-Sleep 1

            $tmp = @{
                'Subscription'          = $Sub;
                'ResourceHealth'        = $ResourceHealth.value;
                'ManagedIdentities'     = $Identities.value;
                'AdvisorScore'          = $ADVScore.value;
                'ReservationRecomen'    = $ReservationRecon.value;
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

        #>

        return $APIResults
}