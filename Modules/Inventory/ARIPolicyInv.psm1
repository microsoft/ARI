<#
.Synopsis
Policy Module

.DESCRIPTION
This script process and creates the Policy sheet based on advisorresources.

.Link
https://github.com/microsoft/ARI/Extras/ARIPolicyInv.psm1

.COMPONENT
    This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 4.0.2
First Release Date: 15th Oct, 2024
Authors: Claudio Merola

#>
function Invoke-ARIPolicyProcessing {
    param($Subscriptions, $PolicySetDef, $PolicyAssign, $PolicyDef)

    $poltmp = $PolicyDef | Select-Object -Property id,properties -Unique

    $tmp = foreach ($1 in $PolicyAssign.policyAssignments)
        {
            if(![string]::IsNullOrEmpty($1.policySetDefinitionId))
                {
                    $Initiative = (($PolicySetDef | Where-Object {$_.id -eq $1.policySetDefinitionId}).properties.displayName | Select-Object -Unique )
                    $InitNonCompRes = $1.results.nonCompliantResources
                    $InitNonCompPol = $1.results.nonCompliantPolicies
                }
            else
                {
                    $Initiative = ''
                    $InitNonCompRes = ''
                    $InitNonCompPol = ''
                }

            foreach ($2 in $1.policyDefinitions)
                {
                    $Pol = (($poltmp | Where-Object {$_.id -eq $2.policyDefinitionId}).properties)
                    if(![string]::IsNullOrEmpty($Pol))
                        {
                            $PolMode
                            $PolResUnkown = ($2.results.resourceDetails | Where-Object {$_.complianceState -eq 'unknown'} | Select-Object -ExpandProperty Count)
                            $PolResUnkown = if (![string]::IsNullOrEmpty($PolResUnkown)){$PolResUnkown}else{'0'}
                            $PolResCompl = ($2.results.resourceDetails | Where-Object {$_.complianceState -eq 'compliant'} | Select-Object -ExpandProperty Count)
                            $PolResCompl = if (![string]::IsNullOrEmpty($PolResCompl)){$PolResCompl}else{'0'}
                            $PolResNonCompl = ($2.results.resourceDetails | Where-Object {$_.complianceState -eq 'noncompliant'} | Select-Object -ExpandProperty Count)
                            $PolResNonCompl = if (![string]::IsNullOrEmpty($PolResNonCompl)){$PolResNonCompl}else{'0'}
                            $PolResExemp = ($2.results.resourceDetails | Where-Object {$_.complianceState -eq 'exempt'} | Select-Object -ExpandProperty Count)
                            $PolResExemp = if (![string]::IsNullOrEmpty($PolResExemp)){$PolResExemp}else{'0'}

                            $obj = @{
                                'Initiative'                            = $Initiative;
                                'Initiative Non Compliance Resources'   = $InitNonCompRes;
                                'Initiative Non Compliance Policies'    = $InitNonCompPol;
                                'Policy'                                = $Pol.displayName;
                                'Policy Type'                           = $Pol.policyType;
                                'Effect'                                = $2.effect;
                                'Compliance Resources'                  = $PolResCompl;
                                'Non Compliance Resources'              = $PolResNonCompl;
                                'Unknown Resources'                     = $PolResUnkown;
                                'Exempt Resources'                      = $PolResExemp
                                'Policy Mode'                           = $Pol.mode;
                                'Policy Version'                        = $Pol.version;
                                'Policy Deprecated'                     = $Pol.metadata.deprecated;
                                'Policy Category'                       = $Pol.metadata.category
                            }
                            $obj
                        }
                }
        }
    $tmp
}

function Build-ARIPolicyReport {
    param($File ,$Pol, $TableStyle)
    $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat 0

    $condtxt = @()
    $condtxt += New-ConditionalText -Range B2:B500 -ConditionalType GreaterThan 0
    $condtxt += New-ConditionalText -Range C2:C500 -ConditionalType GreaterThan 0
    $condtxt += New-ConditionalText -Range H2:H500 -ConditionalType GreaterThan 0

    $Pol |
    ForEach-Object { [PSCustomObject]$_ } |
    Select-Object 'Initiative',
    'Initiative Non Compliance Resources',
    'Initiative Non Compliance Policies',
    'Policy',
    'Policy Type',
    'Effect',
    'Compliance Resources',
    'Non Compliance Resources',
    'Unknown Resources',
    'Exempt Resources',
    'Policy Mode',
    'Policy Version',
    'Policy Deprecated',
    'Policy Category' | Export-Excel -Path $File -WorksheetName 'Policy' -AutoSize -MaxAutoSizeRows 100 -TableName 'AzurePolicy' -MoveToStart -ConditionalText $condtxt -TableStyle $tableStyle -Style $Style
}

