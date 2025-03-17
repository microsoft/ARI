<#
.Synopsis
Advisory Module

.DESCRIPTION
This script process and creates the Advisory sheet based on advisorresources.

.Link
https://github.com/microsoft/ARI/Extras/ARIAdvisoryInv.psm1

.COMPONENT
    This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 4.0.1
First Release Date: 15th Oct, 2024
Authors: Claudio Merola

#>
function Start-ARIAdvisoryJob {
    param($Advisories)

    $tmp = foreach ($1 in $Advisories)
        {
            $data = $1.PROPERTIES
            $Savings = if([string]::IsNullOrEmpty($data.extendedProperties.annualSavingsAmount)){0}Else{$data.extendedProperties.annualSavingsAmount}
            $SavingsCurrency = if([string]::IsNullOrEmpty($data.extendedProperties.savingsCurrency)){'USD'}Else{$data.extendedProperties.savingsCurrency}
            $obj = @{
                'ResourceGroup'          = $1.RESOURCEGROUP;
                'Affected Resource Type' = $data.impactedField;
                'Name'                   = $data.impactedValue;
                'Category'               = $data.category;
                'Impact'                 = $data.impact;
                #'Score'                  = $data.extendedproperties.score;
                'Problem'                = $data.shortDescription.problem;
                'Savings Currency'       = $SavingsCurrency;
                'Annual Savings'         = "=$Savings";
                'Savings Region'         = $data.extendedProperties.location;
                'Current SKU'            = $data.extendedProperties.currentSku;
                'Target SKU'             = $data.extendedProperties.targetSku
            }
            $obj
        }
    $tmp
}

