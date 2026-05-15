<#
.Synopsis
Retrieve unsupported data for Azure Resource Inventory

.DESCRIPTION
This module retrieves unsupported data from a predefined JSON file for Azure Resource Inventory.

.Link
https://github.com/microsoft/ARI/Modules/Private/0.MainFunctions/Get-ARIUnsupportedData.ps1

.COMPONENT
This PowerShell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.6.12
First Release Date: 15th Oct, 2024
Authors: Claudio Merola

#>
function Get-ARIUnsupportedData {
    try
        {
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Acquiring Token to retrieve list of retirements from Azure Advisor.')
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
    $AdvisorMetadataUrl = "https://management.azure.com/providers/Microsoft.Advisor/metadata?api-version=2025-01-01&%24filter=recommendationCategory%20eq%20'HighAvailability'%20and%20recommendationSubCategory%20eq%20'ServiceUpgradeAndRetirement'%20and%20retirementDate%20ge%20'2024-01-01'&%24expand=ibiza"
    
    try
        {
            $AdvisorMetadata = Invoke-RestMethod -Uri $AdvisorMetadataUrl -Headers $header -Method Get -ErrorAction SilentlyContinue -WarningAction SilentlyContinue -InformationAction SilentlyContinue -Debug:$false
        }
    catch
        {
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Error: ' + $_.Exception.Message)
            return
        }
    
    $AdvisorRetirementData = foreach ($advisor in $AdvisorMetadata.value[0].properties.supportedValues)
        {
            $obj = [PSCustomObject] @{
                "id" = $advisor.id
                "ServiceName" = $advisor.resourceMetadata.singular
                "RetiringFeature" = $advisor.sourceProperties.serviceRetirement.retirementFeatureName
                "RetirementDate" = $advisor.sourceProperties.serviceRetirement.retirementDate
                "Link" = $advisor.learnMoreLink
            }
            $obj
        }

    return $AdvisorRetirementData
}