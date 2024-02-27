<#
.Synopsis
Billing - Consumption and Usage Module

.DESCRIPTION
This script tracks and reports Azure month to date resource usage and costs. 
It's pulls usage and cost data querying the Consumption and Usage API.
It groups results into a detailed breakdown of usage and costs by subscription, resource group, and resource name.

.Link
https://github.com/microsoft/ARI/Extras/Billing.ps1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI) by Claudio Merola and Renato Gregio.

.NOTES
Version: 1.0.0
First Release Date: 12th February, 2024
Authors: Damian Marquez and Manuel Beck 

#>
param($Policies, $Task , $Subscriptions, $File ,$Pol, $TableStyle,
    [string]$Year = (Get-Date).Year.ToString(),
    [string]$Month = (Get-Date).Month.ToString("00"),
    [switch]$RunInPipeline
)

######## Resource extraction starts here here ########

# Authentication using az login --use-device-code needed to retrieve Usage and Consumption API token

if($DeviceLogin.IsPresent)
{
    az login --use-device-code
}
else 
{
    az login --only-show-errors | Out-Null
}

# Pull all subscriptions

$subscriptionIds = @(az account list --query "[].id" -o tsv)

$headers = @{
    authorization = "Bearer $(az account get-access-token --query 'accessToken' -o tsv)"
}

$ErrorActionPreference = "Continue"

# Usage Details API

$Date = (Get-Date).ToUniversalTime().ToString("yyyy-MM-dd-HH.mm.ssZ")
$yearMonth = (Get-Date -Year $Year -Month $Month).ToString("yyyy-MM")
$startDate = $yearMonth + "-01"
$endDate = $yearMonth + "-" + [DateTime]::DaysInMonth($Year, $Month)
$billingPeriod = $Year + $Month
$apiVersion = "2023-03-01"
$usageRows = New-Object System.Collections.ArrayList

foreach ($subId in $subscriptionIds) {
    $usageUri = "https://management.azure.com/subscriptions/$subId/providers/Microsoft.Consumption/usageDetails?%24expand=properties%2FadditionalInfo%2Cproperties%2FmeterDetails&%24filter=properties%2FusageStart+eq+%27$startDate%27+and+properties%2FusageEnd+eq+%27$endDate%27&api-version=$apiVersion"

    $usageResult = $null
    $retryCount = 0
    do {        
        try {
            $usageResult = Invoke-RestMethod $usageUri -Headers $headers -ContentType "application/json"
        } catch {
            Write-Host "Error retrieving information from subscription $subId"
            Write-Host "You might have no permissions over the subscription."
            Write-Host "."
            break
        }

        if ($usageResult -ne $null) {
            foreach ($usageRow in $usageResult.value) {
                $usageRows.Add($usageRow) > $null
            }

            $usageUri = $usageResult.nextLink
        }

        $retryCount++
        if ($retryCount -ge 3) {
            Write-Host "Reached maximum retry count. Exiting..."
            break
        }

        # If there's a continuation, then call API again

    } while ($usageResult -and $usageUri)
}

# Fine tune result

$usageRows = $usageRows | Sort-Object -Property { $_.properties.date }, { $_.properties.tags.project }, { $_.properties.resourceName }, { $_.properties.subscriptionId }

$reportResult = $usageRows | Select-Object @{ N = 'DateTime'; E = { $_.properties.date } }, @{ N = 'ResourceName'; E = { $_.properties.resourceName } }, @{ N = 'ResourceGroup'; E = { $_.properties.resourceGroup } }, `
@{ N = 'CostCenter'; E = { $_.tags."cost-center" } }, @{ N = 'Project'; E = { $_.tags."project" } }, @{ N = 'Environment'; E = { $_.tags."environment" } }, @{ N = 'ResourceLocation'; E = { $_.properties.resourceLocation } }, 
@{ N = 'ConsumedService'; E = { $_.properties.consumedService } }, `
@{ N = 'Product'; E = { $_.properties.product } }, @{ N = 'Quantity'; E = { $_.properties.quantity } }, @{ N = 'UnitOfMeasure'; E = { $_.properties.meterDetails.unitOfMeasure } }, `
@{ N = 'UnitPrice'; E = { $_.properties.UnitPrice } }, @{ N = 'Cost'; E = { $_.properties.Cost } }, @{ N = 'Currency'; E = { $_.properties.billingCurrency } }, `
@{ N = 'PartNumber'; E = { $_.properties.partNumber } }, @{ N = 'MeterId'; E = { $_.properties.meterId } }, @{ N = 'SubscriptionId'; E = { $_.properties.subscriptionId } },  @{ N = 'SubscriptionName'; E = { $_.properties.subscriptionName } },  @{ N = 'BenefitId'; E = { $_.properties.benefitId } },  @{ N = 'BenefitName'; E = { $_.properties.benefitName } }

# Group by subscription + project tag + month

$projectGroup = $reportresult | Select-Object Project, Cost, subscriptionId, subscriptionName |  Group-Object SubscriptionId | ForEach-Object {
    New-Object -Type PSObject -Property @{
        'BillingPeriod' = $billingPeriod
        'Project'       = $_.Group | Select-Object -Expand Project -First 1
        'EURO'           = ($_.Group | Measure-Object Cost -Sum).Sum
        'SubscriptionId' = $_.Group | Select-Object -Expand SubscriptionId -First 1
        'SubscriptionName' = $_.Group | Select-Object -Expand SubscriptionName -First 1
    }
}  | Sort-Object SubscriptionName, EURO -Descending

# Group by rg + month

$rgGroup = $reportresult | Select-Object resourceGroup, Cost, ResourceLocation, subscriptionName |  Group-Object resourceGroup | ForEach-Object {
    New-Object -Type PSObject -Property @{
        'BillingPeriod'    = $billingPeriod
        'ResourceGroup'    = $_.Group | Select-Object -Expand ResourceGroup -First 1
        'EURO'             = ($_.Group | Measure-Object Cost -Sum).Sum
        'ResourceLocation' = $_.Group | Select-Object -Expand ResourceLocation -First 1
        'SubscriptionName' = $_.Group | Select-Object -Expand SubscriptionName -First 1
    }
}  | Sort-Object SubscriptionName, EURO -Descending

# Group by resourceName + month

$resGrouping = $reportresult | Select-Object ResourceName, ResourceGroup, ResourceLocation, ConsumedService, Cost, Product, subscriptionName, BenefitId, BenefitName | Group-Object ResourceName | ForEach-Object {
    $objectProperties = @{
        'BillingPeriod'    = $billingPeriod
        'ResourceName'     = $_.Group | Select-Object -Expand ResourceName -First 1
        'EURO'              = ($_.Group | Measure-Object Cost -Sum).Sum
        'ServiceName' = $_.Group  | Select-Object -Expand ConsumedService -First 1
        'ResourceLocation' = $_.Group  | Select-Object -Expand ResourceLocation -First 1
        'ResourceGroup'    = $_.Group  | Select-Object -Expand ResourceGroup -First 1
        'ProductName'    = $_.Group  | Select-Object -Expand Product -First 1
        'SubscriptionName' = $_.Group | Select-Object -Expand SubscriptionName -First 1
    }

    $benefitName = $_.Group | Select-Object -Expand BenefitName -First 1
    if ($benefitName) {
        $objectProperties['BenefitName'] = $benefitName
    }

    $benefitId = $_.Group | Select-Object -Expand BenefitId -First 1
    if ($benefitId) {
        $objectProperties['BenefitId'] = $benefitId
    }

    New-Object -Type PSObject -Property $objectProperties
} | Sort-Object ServiceName, SubscriptionName, EURO -Descending

<######## Resource Excel Reporting Begins Here ########>

$ExcelFile = $File
$groupingSheet = "Usage by Subscription"
$groupingSheet2 = "Usage by Resource Group"
$groupingSheet3 = "Usage by Resource Name"

$excel2 = $projectGroup | Export-Excel -WorksheetName $groupingSheet -Path $ExcelFile -AutoSize -TableName Table1 -StartRow 2 -PassThru
$ws = $excel2.Workbook.Worksheets[$groupingSheet]
Set-Format -Range G1  -Value "Script run at: $($Date)" -Worksheet $ws
Set-Format -Range G2  -Value "The script covers all subscriptions" -Worksheet $ws
Set-Format -Range A1  -Value "Usage by Subscription" -Worksheet $ws
Close-ExcelPackage $excel2

$excel0 = $rgGroup | Export-Excel -WorksheetName $groupingSheet2 -Path $ExcelFile -AutoSize -TableName Table2 -StartRow 2 -PassThru
$ws = $excel0.Workbook.Worksheets[$groupingSheet2]
Set-Format -Range A1  -Value "Usage by Resource Group" -Worksheet $ws
Close-ExcelPackage $excel0

$excel3 = $resGrouping | Export-Excel -WorksheetName $groupingSheet3 -Path $ExcelFile -AutoSize -TableName Table3 -StartRow 2 -PassThru 
$ws = $excel3.Workbook.Worksheets[$groupingSheet3]
Set-Format -Range A1  -Value "Usage by Resource Name" -Worksheet $ws
Close-ExcelPackage $excel3

Write-Host "Usage report done"