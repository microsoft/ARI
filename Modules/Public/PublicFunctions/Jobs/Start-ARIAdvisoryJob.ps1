<#
.Synopsis
Public Advisory Job Module

.DESCRIPTION
This script creates the job to process the Advisory data.

.Link
https://github.com/microsoft/ARI/Modules/Public/PublicFunctions/Jobs/Start-ARIAdvisoryJob.ps1

.COMPONENT
    This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.6.9
First Release Date: 15th Oct, 2024
Authors: Claudio Merola

#>
function Start-ARIAdvisoryJob {
    param($Advisories)

    $tmp = foreach ($1 in $Advisories)
        {
            $data = $1.PROPERTIES

            if ($data.resourceMetadata.resourceId)
                {
                    $Savings = if([string]::IsNullOrEmpty($data.extendedProperties.annualSavingsAmount)){0}Else{$data.extendedProperties.annualSavingsAmount}
                    $SavingsCurrency = if([string]::IsNullOrEmpty($data.extendedProperties.savingsCurrency)){'USD'}Else{$data.extendedProperties.savingsCurrency}
                    $Resource = $data.resourceMetadata.resourceId.split('/')

                    if ($Resource.Count -lt 4) {
                        $ResourceType = $data.impactedField
                        $ResourceName = $data.impactedValue
                    }
                    else {
                        $ResourceType = ($Resource[6] + '/' + $Resource[7])
                        $ResourceName = $Resource[8]
                    }

                    if ($data.impactedField -eq $ResourceType) {
                            $ImpactedField = ''
                    }
                    else {
                            $ImpactedField = $data.impactedField
                    }

                    if ($data.impactedValue -eq $ResourceName) {
                            $ImpactedValue = ''
                    }
                    else {
                            $ImpactedValue = $data.impactedValue
                        }

                    $obj = @{
                        'Subscription'           = $Resource[2];
                        'Resource Group'         = $Resource[4];
                        'Resource Type'          = $ResourceType;
                        'Name'                   = $ResourceName;
                        'Detailed Type'          = $ImpactedField;
                        'Detailed Name'          = $ImpactedValue;
                        'Category'               = $data.category;
                        'Impact'                 = $data.impact;
                        'Description'            = $data.shortDescription.problem;
                        'SKU'                    = $data.extendedProperties.sku;
                        'Term'                   = $data.extendedProperties.term;
                        'Look-back Period'       = $data.extendedProperties.lookbackPeriod;
                        'Quantity'               = $data.extendedProperties.qty;
                        'Savings Currency'       = $SavingsCurrency;
                        'Annual Savings'         = "=$Savings";
                        'Savings Region'         = $data.extendedProperties.region
                    }
                    $obj
                }
        }
    $tmp
}

