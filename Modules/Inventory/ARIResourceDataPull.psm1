<#
.Synopsis
Main module for Resource Extraction

.DESCRIPTION
This module is the main module for the Azure Resource Graphs that will be run against the environment.

.Link
https://github.com/microsoft/ARI/Core/Start-AzureResourceExtraction.psm1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 4.0.1
First Release Date: 15th Oct, 2024
Authors: Claudio Merola

#>
Function Start-AzureResourceDataPull {
    Param($ManagementGroup, $Subscriptions, $SubscriptionID, $ResourceGroup, $SecurityCenter, $SkipAdvisory, $IncludeTags, $QuotaUsage, $TagKey, $TagValue, $Debug)

    if ($Debug.IsPresent)
        {
            $DebugPreference = 'Continue'
            $ErrorActionPreference = 'Continue'
        }
    else
        {
            $ErrorActionPreference = "silentlycontinue"
        }

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

    Write-Progress -activity 'Azure Inventory' -Status "1% Complete." -PercentComplete 2 -CurrentOperation 'Discovering Subscriptions..'

    if (![string]::IsNullOrEmpty($ManagementGroup))
        {
            $Subscriptions = Get-ARIManagementGroups -ManagementGroup $ManagementGroup -Debug $Debug
        }

    $SubCount = [string]$Subscriptions.id.count

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Number of Subscriptions Found: ' + $SubCount)
    Write-Progress -activity 'Azure Inventory' -Status "3% Complete." -PercentComplete 3 -CurrentOperation "$SubCount Subscriptions found.."

    <######################################################## INVENTORY LOOPs #######################################################################>

$ExtractionRuntime = Measure-Command -Expression {

    Write-Progress -Id 1 -activity "Running Inventory Jobs" -Status "1% Complete." -Completed

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
            $Resources += Invoke-ResourceInventoryLoop -GraphQuery $GraphQuery -FSubscri $Subscri -LoopName 'Resources'

            $GraphQuery = "networkresources $RGQueryExtension $TagQueryExtension $MGQueryExtension | project id,name,type,tenantId,kind,location,resourceGroup,subscriptionId,managedBy,sku,plan,properties,identity,zones,extendedLocation$($GraphQueryTags) | order by id asc"

            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Invoking Inventory Loop for Network Resources')
            $Resources += Invoke-ResourceInventoryLoop -GraphQuery $GraphQuery -FSubscri $Subscri -LoopName 'Network Resources'

            $GraphQuery = "recoveryservicesresources $RGQueryExtension $TagQueryExtension | where type =~ 'microsoft.recoveryservices/vaults/backupfabrics/protectioncontainers/protecteditems' or type =~ 'microsoft.recoveryservices/vaults/backuppolicies' $MGQueryExtension  | project id,name,type,tenantId,kind,location,resourceGroup,subscriptionId,managedBy,sku,plan,properties,identity,zones,extendedLocation$($GraphQueryTags) | order by id asc"

            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Invoking Inventory Loop for Backup Resources')
            $Resources += Invoke-ResourceInventoryLoop -GraphQuery $GraphQuery -FSubscri $Subscri -LoopName 'Backup Items'

            $GraphQuery = "desktopvirtualizationresources $RGQueryExtension $MGQueryExtension| project id,name,type,tenantId,kind,location,resourceGroup,subscriptionId,managedBy,sku,plan,properties,identity,zones,extendedLocation$($GraphQueryTags) | order by id asc"

            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Invoking Inventory Loop for AVD Resources')
            $Resources += Invoke-ResourceInventoryLoop -GraphQuery $GraphQuery -FSubscri $Subscri -LoopName 'Virtual Desktop'

            $GraphQuery = "resourcecontainers $RGQueryExtension $TagQueryExtension $MGContainerExtension | project id,name,type,tenantId,kind,location,resourceGroup,subscriptionId,managedBy,sku,plan,properties,identity,zones,extendedLocation$($GraphQueryTags) | order by id asc"

            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Invoking Inventory Loop for Resource Containers')
            $ResourceContainers = Invoke-ResourceInventoryLoop -GraphQuery $GraphQuery -FSubscri $Subscri -LoopName 'Subscriptions and Resource Groups'

            if (!($SkipAdvisory.IsPresent))
                {
                    $GraphQuery = "advisorresources $RGQueryExtension $MGQueryExtension | where properties.impact in~ ('Medium','High') | order by id asc"

                    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Invoking Inventory Loop for Advisories')
                    $Advisories = Invoke-ResourceInventoryLoop -GraphQuery $GraphQuery -FSubscri $Subscri -LoopName 'Advisories'
                }
            if ($SecurityCenter.IsPresent)
                {
                    $GraphQuery = "securityresources $RGQueryExtension | where type =~ 'microsoft.security/assessments' and properties['status']['code'] == 'Unhealthy' $MGQueryExtension | order by id asc"

                    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Invoking Inventory Loop for Security Resources')
                    $Security = Invoke-ResourceInventoryLoop -GraphQuery $GraphQuery -FSubscri $Subscri -LoopName 'Security Center'
                }

    Write-Progress -activity 'Azure Inventory' -Status "4% Complete." -PercentComplete 4 -CurrentOperation "Starting API Extraction.."


    <######################################################### QUOTA JOB ######################################################################>

    if($QuotaUsage.isPresent)
        {
            Start-ARIQuotaJob -Resources $Resources -Subscriptions $Subscriptions
        }

    Write-Progress -activity 'Azure Inventory' -PercentComplete 20

    Write-Progress -Id 1 -activity "Running Inventory Jobs" -Status "100% Complete." -Completed

}
    $tmp = [pscustomobject]@{
        ExtractionRunTime      = $ExtractionRuntime
        Resources              = $Resources
        ResourceContainers     = $ResourceContainers
        Advisories             = $Advisories
        Security               = $Security
    }
    return $tmp
}