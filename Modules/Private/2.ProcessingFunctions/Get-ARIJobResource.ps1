<#
.Synopsis
Selects the resources one processing job needs.

.DESCRIPTION
Inventory modules only read $Resources through literal type filters
($_.TYPE -eq '<type>'). This function collects those types from a job's module
files and returns, as JSON, just the resources of those types in their original
order. Each job then receives and parses a slice instead of every resource.

.Link
https://github.com/microsoft/ARI/Modules/Private/2.ProcessingFunctions/Get-ARIJobResource.ps1

.COMPONENT
This PowerShell Module is part of Azure Resource Inventory (ARI).

.NOTES
Version: 3.6.16
First Release Date: 9th Oct, 2026
Authors: Robin Pieterse
#>

function Get-ARIJobResource {
    Param($Resources, $ModuleFiles)

    $Types = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($Module in $ModuleFiles)
        {
            $Content = [System.IO.File]::ReadAllText($Module.FullName)
            foreach ($Match in [regex]::Matches($Content, '\$_\.TYPE\s+-eq\s+[''"]([^''"]+)[''"]', 'IgnoreCase'))
                {
                    $null = $Types.Add($Match.Groups[1].Value)
                }
        }

    $Selected = [System.Collections.Generic.List[object]]::new()
    foreach ($Resource in $Resources)
        {
            if ($Resource.TYPE -is [string] -and $Types.Contains($Resource.TYPE)) { $Selected.Add($Resource) }
        }

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Job resources: '+$Selected.Count+' of '+@($Resources).Count+' ('+$Types.Count+' types)')

    # Always an array, as the full resource list was
    return (ConvertTo-Json -InputObject $Selected.ToArray() -Depth 40 -Compress)
}
