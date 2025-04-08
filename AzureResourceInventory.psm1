<#
.SYNOPSIS
    Azure Resource Inventory - A powerful tool to create an Excel inventory from Azure resources with minimal effort.

.DESCRIPTION
    This module orchestrates the process of dot sourcing the modules (and functions) that will be triggered by the Invoke-ARI cmdlet.

.AUTHOR
    Claudio Merola

.COMPANYNAME
    Claudio Merola

.COPYRIGHT
    (c) Claudio Merola. All rights reserved.

.VERSION
    3.6.2

#>

foreach ($directory in @('modules\Private', '.\modules\Public\PublicFunctions')) {
    Get-ChildItem -Path "$PSScriptRoot\$directory\*.ps1" -Recurse | ForEach-Object { . $_.FullName }
}


<#
$PrivateFiles = @( Get-ChildItem -Path (Join-Path $PSScriptRoot "Modules" "Private" "*.ps1") -Recurse -ErrorAction SilentlyContinue )
$PublicFiles = @( Get-ChildItem -Path (Join-Path $PSScriptRoot "Modules" "Public" "PublicFunctions" "*.ps1") -Recurse -ErrorAction SilentlyContinue )

Foreach($import in @($PrivateFiles + $PublicFiles))
{
    Try
    {
        . $import.fullname
    }
    Catch
    {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

Export-ModuleMember -Function $PublicFiles.Basename

#>