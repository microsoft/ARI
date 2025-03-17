function Start-ARILargeEnvOrderFiles {
    Param($DefaultPath,$Debug)
    if ($Debug.IsPresent)
        {
            $DebugPreference = 'Continue'
            $ErrorActionPreference = 'Continue'
        }
    else
        {
            $ErrorActionPreference = "silentlycontinue"
        }

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Ordering Cached Files.')

    $ParentPath = (get-item $PSScriptRoot).parent.parent
    $InventoryModulesPath = Join-Path $ParentPath 'Public' 'InventoryModules' '*.ps1'
    $Modules = Get-ChildItem -Path $InventoryModulesPath -Recurse
    $ModFolder = ($DefaultPath+'\ReportCache\ResourceCache\')
    if ((Test-Path -Path $ModFolder -PathType Container) -eq $false) {
        New-Item -Type Directory -Force -Path $ModFolder | Out-Null
    }

    foreach ($Module in $Modules)
        {
            $ModuleName = $Module.name.replace('.ps1','')
            if (Test-Path -Path ($DefaultPath+'\ReportCache\ResourceJob_*\'+$ModuleName+'.json') -PathType Leaf)
                {
                    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Merging Cached File for: '+$ModuleName)
                    $ModContent = Get-ChildItem -Path ($DefaultPath+'\ReportCache\ResourceJob_*\'+$ModuleName+'.json') | ForEach-Object {Get-Content -Path $_ | ConvertFrom-Json}
                    $ModContent | ConvertTo-Json -Depth 40 | Out-File -FilePath ($ModFolder+'\'+$ModuleName+'.json')
                }
        }
}