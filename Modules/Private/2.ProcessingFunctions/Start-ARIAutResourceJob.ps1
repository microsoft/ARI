function Start-ARIAutResourceJob {
    Param($Resources,$Subscriptions,$InTag,$Unsupported)
    Write-Output ('Starting Resources Processes')
    Write-Output ('Total Resources Being Analyzed: '+$Resources.count)

    $ParentPath = (get-item $PSScriptRoot).parent.parent

    $InventoryModulesPath = Join-Path $ParentPath 'Public' 'InventoryModules' '*.ps1'

    $Modules = Get-ChildItem -Path $InventoryModulesPath -Recurse

    $SmaResources = @{}

    foreach ($Module in $Modules) 
        {

            if($RunDebug)
                {
                    Write-Output ''
                    Write-Output ('DEBUG - Running Module: '+$Module)
                }

            $ModName = $Module.Name.replace(".ps1","")
            $ModuSeq0 = New-Object System.IO.StreamReader($Module.FullName)
            $ModuSeq = $ModuSeq0.ReadToEnd()
            $ModuSeq0.Dispose()

            $ScriptBlock = [Scriptblock]::Create($ModuSeq)

            $SmaResources[$ModName] = Invoke-Command -ScriptBlock $ScriptBlock -ArgumentList $PSScriptRoot, $Subscriptions, $InTag, $Resources, $null,'Processing', $null, $null, $null, $Unsupported

            Start-Sleep -Milliseconds 100

        }
    return $SmaResources
}