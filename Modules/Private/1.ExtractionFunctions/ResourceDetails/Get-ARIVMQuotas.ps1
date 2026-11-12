<#
.Synopsis
Module responsible for retrieving Azure VM quotas.

.DESCRIPTION
This module retrieves Azure VM quotas for specific subscriptions and locations.

.Link
https://github.com/microsoft/ARI/Modules/Private/1.ExtractionFunctions/ResourceDetails/Get-ARIVMQuotas.ps1

.COMPONENT
This PowerShell Module is part of Azure Resource Inventory (ARI).

.NOTES
Version: 3.6.16
First Release Date: 15th Oct, 2024
Authors: Claudio Merola
#>
function Get-AriVMQuotas {
    Param ($Subscriptions, $Resources)

    try
        {
            $Token = Get-AzAccessToken -AsSecureString -InformationAction SilentlyContinue -WarningAction SilentlyContinue -Debug:$false
            $Header = @{ 'Authorization' = 'Bearer ' + ($Token.Token | ConvertFrom-SecureString -AsPlainText) }
            $ArmUrl = (Get-AzContext -Debug:$false).Environment.ResourceManagerUrl.TrimEnd('/')
        }
    catch
        {
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Error: ' + $_.Exception.Message)
            return
        }

    # One usage request per subscription and VM region, sent in parallel
    $Targets = Foreach($Sub in $Subscriptions)
        {
            $Locs = ($Resources | Where-Object {$_.subscriptionId -eq $Sub.id -and $_.Type -in 'microsoft.compute/virtualmachines','microsoft.compute/virtualmachinescalesets'} | Group-Object -Property Location).name
            Foreach($Loc in $Locs)
                {
                    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Getting VM Quota Details: '+$Sub.name+' / '+$Loc)
                    [PSCustomObject]@{
                        Key = ($Sub.id + '|' + $Loc)
                        Uri = ($ArmUrl + '/subscriptions/' + $Sub.id + '/providers/Microsoft.Compute/locations/' + $Loc + '/usages?api-version=2024-07-01')
                        Sub = $Sub
                        Location = $Loc
                    }
                }
        }

    $Responses = Invoke-ARIRestParallel -Requests $Targets -Header $Header

    $Quotas = Foreach($Target in $Targets)
        {
            [PSCustomObject]@{
                Location = $Target.Location
                SubId = $Target.Sub.id
                Subscription = $Target.Sub.name
                Data = $Responses[$Target.Key].value | Where-Object {$_.CurrentValue -ge 1}
            }
        }

    $VMQuotas = [PSCustomObject]@{
        'type'          = 'ARI/VM/Quotas'
        'properties'    = $Quotas
    }

    return $VMQuotas
}
