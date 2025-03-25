function Start-ARIAutProcessJob {
    Param($Resources, $Retirements, $Subscriptions, $InTag, $Unsupported, $Debug)
    if ($Debug.IsPresent)
        {
            $DebugPreference = 'Continue'
            $ErrorActionPreference = 'Continue'
        }
    else
        {
            $ErrorActionPreference = "silentlycontinue"
        }

    $ParentPath = (get-item $PSScriptRoot).parent.parent
    $InventoryModulesPath = Join-Path $ParentPath 'Public' 'InventoryModules'
    $Modules = Get-ChildItem -Path $InventoryModulesPath -Directory

    Foreach ($ModuleFolder in $Modules)
        {
            $ModulePath = Join-Path $ModuleFolder.FullName '*.ps1'
            $ModuleName = $ModuleFolder.Name
            $ModuleFiles = Get-ChildItem -Path $ModulePath

            Start-ThreadJob -Name ('ResourceJob_'+$ModuleName) -ScriptBlock {

                $ModuleFiles = $($args[0])
                $Subscriptions = $($args[2])
                $InTag = $($args[3])
                $Resources = $($args[4]) | ConvertFrom-Json
                $Retirements = $($args[5])
                $Unsupported = $($args[10])


                Foreach ($Module in $ModuleFiles)
                    {
                        $ModuleFileContent = New-Object System.IO.StreamReader($Module.FullName)
                        $ModuleData = $ModuleFileContent.ReadToEnd()
                        $ModuleFileContent.Dispose()
                        $ModName = $Module.Name.replace(".ps1","")

                        $ScriptBlock = [Scriptblock]::Create($ModuleData)

                        $SmaResources[$ModName] = Invoke-Command -ScriptBlock $ScriptBlock -ArgumentList $PSScriptRoot, $Subscriptions, $InTag, $Resources, $Retirements,'Processing', $null, $null, $null, $Unsupported

                        Start-Sleep -Milliseconds 100

                    }

                $SmaResources

            } -ArgumentList $ModuleFiles, $PSScriptRoot, $Subscriptions, $InTag, ($Resources | ConvertTo-Json -Depth 100), $Retirements, 'Processing', $null, $null, $null, $Unsupported | Out-Null
        }
}