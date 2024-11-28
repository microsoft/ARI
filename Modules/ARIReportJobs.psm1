function Start-ARIResourceReporting {
    Param($InTag, $file, $SmaResources, $DefaultPath, $TableStyle, $Unsupported, $DebugEnvSize, $DataActive, $Debug)
    if ($Debug.IsPresent)
        {
            $DebugPreference = 'Continue'
            $ErrorActionPreference = 'Continue'
        }
    else
        {
            $ErrorActionPreference = "silentlycontinue"
        }
    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Starting Reporting Phase.')
    Write-Progress -activity $DataActive -Status "Processing Inventory" -PercentComplete 50

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Running Asynchronous, Gathering List Of Modules.')
    if($PSScriptRoot -like '*\*')
        {
            $Modules = Get-ChildItem -Path ($PSScriptRoot + '\Scripts\*.ps1') -Recurse
        }
    else
        {
            $Modules = Get-ChildItem -Path ($PSScriptRoot + '/Scripts/*.ps1') -Recurse
        }

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Modules Found: ' + $Modules.Count)
    $Lops = $Modules.count
    $ReportCounter = 0
    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Large Environment. Looking for Cached Resource Files.')

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Starting to Process Modules.')
    foreach ($Module in $Modules) {

        $c = (($ReportCounter / $Lops) * 100)
        $c = [math]::Round($c)
        Write-Progress -Id 1 -activity "Building Report" -Status "$c% Complete." -PercentComplete $c

        $ModuSeq0 = New-Object System.IO.StreamReader($Module.FullName)
        $ModuSeq = $ModuSeq0.ReadToEnd()
        $ModuSeq0.Dispose()
        $ModuleName = $Module.name.replace('.ps1','')

        if ($DebugEnvSize -eq 'Large')
            {
                $SmaResources = @{}
                if (Test-Path -Path ($DefaultPath+'\ReportCache\ResourceCache\'+$ModuleName+'.json') -PathType Leaf)
                    {
                        $SmaResources["$ModuleName"] = Get-Content -Path ($DefaultPath+'\ReportCache\ResourceCache\'+$ModuleName+'.json') | ConvertFrom-Json
                    }
                else
                    {
                        $SmaResources["$ModuleName"] = 0
                    }
            }

        $ModuleResourceCount = $SmaResources.$ModuleName.count

        if ($ModuleResourceCount -gt 0)
            {
                Start-Sleep -Milliseconds 25
                Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+"Running Module: '$ModuleName'. Lines Count: $ModuleResourceCount")

                $ExcelRun = ([PowerShell]::Create()).AddScript($ModuSeq).AddArgument($PSScriptRoot).AddArgument($null).AddArgument($InTag).AddArgument($null).AddArgument($null).AddArgument('Reporting').AddArgument($file).AddArgument($SmaResources).AddArgument($TableStyle).AddArgument($Unsupported)

                $ExcelJob = $ExcelRun.BeginInvoke()

                while ($ExcelJob.IsCompleted -contains $false) { Start-Sleep -Milliseconds 200 }

                $ExcelRun.EndInvoke($ExcelJob)

                $ExcelRun.Dispose()
                Remove-Variable -Name ExcelRun
                Remove-Variable -Name ExcelJob

            }

        if ($DebugEnvSize -eq 'Large')
            {
                Remove-Variable -Name SmaResources
                [System.GC]::Collect()
                Start-Sleep -Milliseconds 50
            }

        $ReportCounter ++
    }

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Cleaning Variables to Release Memory.')

    if ($DebugEnvSize -eq 'Large')
        {
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Removing Cache Files.')
            Remove-Item -Path ($DefaultPath+'\ReportCache') -Recurse
        }
    else
        {
            Remove-Variable -Name SmaResources
        }

    [System.GC]::GetTotalMemory($true) | out-null
    Start-Sleep -Milliseconds 50
}

function Build-ARILargeReportResources {
    Param($DefaultPath, $Debug)
    if ($Debug.IsPresent)
        {
            $DebugPreference = 'Continue'
            $ErrorActionPreference = 'Continue'
        }
    else
        {
            $ErrorActionPreference = "silentlycontinue"
        }
    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Looking for Cache Files.')
    $LocalCacheFiles = Get-ChildItem -Path ($DefaultPath+'\ReportCache\*.json')

    $Looper = 0

    foreach ($LocalFile in $LocalCacheFiles)
        {
            $Looper ++
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Starting Resource Excel Data Processing Jobs.')
            Start-job -Name ('ExcelJob_'+$Looper) -ScriptBlock {

                $LocalFile = $($args[1])
                $DefaultPath = $($args[2])
                $LocalFolder = $LocalFile.Name.replace(".json","")

                if($($args[0]) -like '*\*')
                    {
                        $Modules = Get-ChildItem -Path ($($args[0]) + '\Scripts\*.ps1') -Recurse

                        $ModFolder = ($DefaultPath+'\ReportCache\'+$LocalFolder+'\')
                        if ((Test-Path -Path $ModFolder -PathType Container) -eq $false) {
                            New-Item -Type Directory -Force -Path $ModFolder | Out-Null
                        }
                    }
                else
                    {
                        $Modules = Get-ChildItem -Path ($($args[0]) + '/Scripts/*.ps1') -Recurse
                        $ModFolder = ($DefaultPath+'/ReportCache/'+$LocalFolder+'/')
                    }

                $TempContent = Get-Content -Path $LocalFile | ConvertFrom-Json

                $job = @()

                $Modules | ForEach-Object {
                    $ModName = $_.Name.replace(".ps1","")
                    if($TempContent.$ModName.count -gt 0)
                        {
                            $TempVal = $TempContent.$ModName
                            $ModNameFile = ($ModName+'.json')
                            Start-Sleep -Milliseconds 100

                            New-Variable -Name ('ModRun' + $ModName)
                            New-Variable -Name ('ModJob' + $ModName)

                            Set-Variable -Name ('ModRun' + $ModName) -Value ([PowerShell]::Create()).AddScript({Param($ModFolder,$TempVal,$ModNameFile)$TempVal | ConvertTo-Json -Depth 50 | Out-File -FilePath ($ModFolder+$ModNameFile)}).AddArgument($ModFolder).AddArgument($TempVal).AddArgument($ModNameFile)

                            Set-Variable -Name ('ModJob' + $ModName) -Value ((get-variable -name ('ModRun' + $ModName)).Value).BeginInvoke()

                            Start-Sleep -Milliseconds 100

                            $job += (get-variable -name ('ModJob' + $ModName)).Value
                            Remove-Variable -Name ModName
                        }
                }

                while ($Job.Runspace.IsCompleted -contains $false) { Start-Sleep -Milliseconds 1000 }

                $Modules | ForEach-Object {
                    $ModName = $_.Name.replace(".ps1","")
                    if($TempContent.$ModName.count -gt 0)
                        {
                            Remove-Variable -Name ('ModRun' + $ModName)
                            Remove-Variable -Name ('ModJob' + $ModName)
                            Remove-Variable -Name ModName
                        }
                }

                [System.GC]::Collect() | out-null
                Start-Sleep -Milliseconds 50

            } -ArgumentList $PSScriptRoot, $LocalFile, $DefaultPath
        }

}

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

    if($PSScriptRoot -like '*\*')
        {
            $Modules = Get-ChildItem -Path ($PSScriptRoot + '\Scripts\*.ps1') -Recurse
            $ModFolder = ($DefaultPath+'\ReportCache\ResourceCache\')
            if ((Test-Path -Path $ModFolder -PathType Container) -eq $false) {
                New-Item -Type Directory -Force -Path $ModFolder | Out-Null
            }
        }
    else
        {
            $Modules = Get-ChildItem -Path ($PSScriptRoot + '/Scripts/*.ps1') -Recurse
            $ModFolder = ($DefaultPath+'/ReportCache/ResourceCache/')
            if ((Test-Path -Path $ModFolder -PathType Container) -eq $false) {
                New-Item -Type Directory -Force -Path $ModFolder | Out-Null
            }
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