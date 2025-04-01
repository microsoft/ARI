<#
.Synopsis
Module responsible for coordinate the extraction of Resource and build the Graph queries

.DESCRIPTION
This module is the main module for the Azure Resource Graphs that will be run against the environment.

.Link
https://github.com/microsoft/ARI/Modules/Private/1.ExtractionFunctions/Start-ARIGraphExtraction.ps1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.6.0
First Release Date: 15th Oct, 2024
Authors: Claudio Merola

#>
Function Start-ARIGraphExtraction {
    Param($ManagementGroup, $Subscriptions, $SubscriptionID, $ResourceGroup, $SecurityCenter, $SkipAdvisory, $IncludeTags, $TagKey, $TagValue)

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Starting Extractor function')

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Powershell Edition: ' + ([string]$psversiontable.psEdition))
    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Powershell Version: ' + ([string]$psversiontable.psVersion))

    #Field for tags
    if ($IncludeTags.IsPresent) {
        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+"Tags will be included")
        $GraphQueryTags = ",tags "
    } else {
        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+"Tags will be ignored")
        $GraphQueryTags = ""
    }

    <###################################################### Subscriptions ######################################################################>

    Write-Progress -activity 'Azure Inventory' -Status "2% Complete." -PercentComplete 2 -CurrentOperation 'Discovering Subscriptions..'

    if (![string]::IsNullOrEmpty($ManagementGroup))
        {
            $Subscriptions = Get-ARIManagementGroups -ManagementGroup $ManagementGroup
        }

    $SubCount = [string]$Subscriptions.id.count

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Number of Subscriptions Found: ' + $SubCount)
    Write-Progress -activity 'Azure Inventory' -Status "3% Complete." -PercentComplete 3 -CurrentOperation "$SubCount Subscriptions found.."

    <######################################################## INVENTORY LOOPs #######################################################################>

    Write-Progress -activity 'Azure Inventory' -Status "4% Complete." -PercentComplete 4 -CurrentOperation "Starting Resources extraction jobs.."

    if(![string]::IsNullOrEmpty($ResourceGroup) -and [string]::IsNullOrEmpty($SubscriptionID))
        {
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Resource Group Name present, but missing Subscription ID.')
            Write-Output ''
            Write-Output 'If Using the -ResourceGroup Parameter, the Subscription ID must be informed'
            Write-Output ''
            Exit
        }
    else
        {
            $Subscri = $Subscriptions.id
            $RGQueryExtension = ''
            $TagQueryExtension = ''
            $MGQueryExtension = ''
            if(![string]::IsNullOrEmpty($ResourceGroup) -and ![string]::IsNullOrEmpty($SubscriptionID))
                {
                    $RGQueryExtension = "| where resourceGroup in~ ('$([String]::Join("','",$ResourceGroup))')"
                }
            elseif(![string]::IsNullOrEmpty($TagKey) -and ![string]::IsNullOrEmpty($TagValue))
                {
                    $TagQueryExtension = "| where isnotempty(tags) | mvexpand tags | extend tagKey = tostring(bag_keys(tags)[0]) | extend tagValue = tostring(tags[tagKey]) | where tagKey =~ '$TagKey' and tagValue =~ '$TagValue'"
                }
            elseif (![string]::IsNullOrEmpty($ManagementGroup))
                {
                    $MGQueryExtension = "| join kind=inner (resourcecontainers | where type == 'microsoft.resources/subscriptions' | mv-expand managementGroupParent = properties.managementGroupAncestorsChain | where managementGroupParent.name =~ '$ManagementGroup' | project subscriptionId, managanagementGroup = managementGroupParent.name) on subscriptionId"
                    $MGContainerExtension = "| mv-expand managementGroupParent = properties.managementGroupAncestorsChain | where managementGroupParent.name =~ '$ManagementGroup'"
                }
        }

            $ExcludedTypes = "| where type !in ('microsoft.logic/workflows')"

            $GraphQuery = "resources $RGQueryExtension $TagQueryExtension $MGQueryExtension $ExcludedTypes | project id,name,type,tenantId,kind,location,resourceGroup,subscriptionId,managedBy,sku,plan,properties,identity,zones,extendedLocation$($GraphQueryTags) | order by id asc"

            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Invoking Inventory Loop for Resources')
            $Resources += Invoke-ARIInventoryLoop -GraphQuery $GraphQuery -FSubscri $Subscri -LoopName 'Resources'

            $GraphQuery = "networkresources $RGQueryExtension $TagQueryExtension $MGQueryExtension | project id,name,type,tenantId,kind,location,resourceGroup,subscriptionId,managedBy,sku,plan,properties,identity,zones,extendedLocation$($GraphQueryTags) | order by id asc"

            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Invoking Inventory Loop for Network Resources')
            $Resources += Invoke-ARIInventoryLoop -GraphQuery $GraphQuery -FSubscri $Subscri -LoopName 'Network Resources'

            $GraphQuery = "SupportResources $RGQueryExtension $TagQueryExtension $MGQueryExtension | project id,name,type,tenantId,kind,location,resourceGroup,subscriptionId,managedBy,sku,plan,properties,identity,zones,extendedLocation$($GraphQueryTags) | order by id asc"

            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Invoking Inventory Loop for Support Tickets')
            $Resources += Invoke-ARIInventoryLoop -GraphQuery $GraphQuery -FSubscri $Subscri -LoopName 'SupportTickets'

            $GraphQuery = "recoveryservicesresources $RGQueryExtension $TagQueryExtension | where type =~ 'microsoft.recoveryservices/vaults/backupfabrics/protectioncontainers/protecteditems' or type =~ 'microsoft.recoveryservices/vaults/backuppolicies' $MGQueryExtension  | project id,name,type,tenantId,kind,location,resourceGroup,subscriptionId,managedBy,sku,plan,properties,identity,zones,extendedLocation$($GraphQueryTags) | order by id asc"

            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Invoking Inventory Loop for Backup Resources')
            $Resources += Invoke-ARIInventoryLoop -GraphQuery $GraphQuery -FSubscri $Subscri -LoopName 'Backup Items'

            $GraphQuery = "desktopvirtualizationresources $RGQueryExtension $MGQueryExtension| project id,name,type,tenantId,kind,location,resourceGroup,subscriptionId,managedBy,sku,plan,properties,identity,zones,extendedLocation$($GraphQueryTags) | order by id asc"

            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Invoking Inventory Loop for AVD Resources')
            $Resources += Invoke-ARIInventoryLoop -GraphQuery $GraphQuery -FSubscri $Subscri -LoopName 'Virtual Desktop'

            $GraphQuery = "resourcecontainers $RGQueryExtension $TagQueryExtension $MGContainerExtension | project id,name,type,tenantId,kind,location,resourceGroup,subscriptionId,managedBy,sku,plan,properties,identity,zones,extendedLocation$($GraphQueryTags) | order by id asc"

            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Invoking Inventory Loop for Resource Containers')
            $ResourceContainers = Invoke-ARIInventoryLoop -GraphQuery $GraphQuery -FSubscri $Subscri -LoopName 'Subscriptions and Resource Groups'

            $ContainerCount = $ResourceContainers.count
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Number of Resource Containers: '+ $ContainerCount)

            if (!($SkipAdvisory.IsPresent))
                {
                    $GraphQuery = "advisorresources $RGQueryExtension $MGQueryExtension | where properties.impact in~ ('Medium','High') | order by id asc"

                    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Invoking Inventory Loop for Advisories')
                    $Advisories = Invoke-ARIInventoryLoop -GraphQuery $GraphQuery -FSubscri $Subscri -LoopName 'Advisories'

                    $AdvisorCount = $Advisories.count
                    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Number of Advisors: '+ $AdvisorCount)
                }
            if ($SecurityCenter.IsPresent)
                {
                    $GraphQuery = "securityresources $RGQueryExtension | where type =~ 'microsoft.security/assessments' and properties['status']['code'] == 'Unhealthy' $MGQueryExtension | order by id asc"

                    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Invoking Inventory Loop for Security Resources')
                    $Security = Invoke-ARIInventoryLoop -GraphQuery $GraphQuery -FSubscri $Subscri -LoopName 'Security Center'

                    $SecurityCount = $Security.count
                    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Number of Security Center Advisors: '+ $SecurityCount)
                }

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Invoking Inventory Loop for Retirements')

    $RootPath = (get-item $PSScriptRoot).parent

    $RetirementPath = Join-Path $RootPath '3.ReportingFunctions' 'StyleFunctions' 'Retirement.kql'

    $RetirementQuery = Get-Content -Path $RetirementPath | Out-String

    $ResourceRetirements = Invoke-ARIInventoryLoop -GraphQuery $RetirementQuery -FSubscri $Subscri -LoopName 'Retirements'

    $RetirementCount = $ResourceRetirements.count

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Number of Retirements: '+ $RetirementCount)

    Write-Progress -activity 'Azure Inventory' -PercentComplete 10

    $tmp = [PSCustomObject]@{
        Resources              = $Resources
        ResourceContainers     = $ResourceContainers
        Advisories             = $Advisories
        Security               = $Security
        Retirements            = $ResourceRetirements
    }
    return $tmp
}