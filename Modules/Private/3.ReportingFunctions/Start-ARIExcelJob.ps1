<#
.Synopsis
Module for Excel Job Processing

.DESCRIPTION
This script processes inventory modules and builds the Excel report.

.Link
https://github.com/microsoft/ARI/Modules/Private/3.ReportingFunctions/Start-ARIExcelJob.ps1

.COMPONENT
This PowerShell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.6.0
First Release Date: 15th Oct, 2024
Authors: Claudio Merola
#>

function Start-ARIExcelJob {
    Param($ReportCache, $File, $TableStyle)

    $ParentPath = (get-item $PSScriptRoot).parent.parent
    $InventoryModulesPath = Join-Path $ParentPath 'Public' 'InventoryModules'
    $ModuleFolders = Get-ChildItem -Path $InventoryModulesPath -Directory

    Write-Progress -activity 'Azure Inventory' -Status "68% Complete." -PercentComplete 68 -CurrentOperation "Starting the Report Loop.."

    $ModulesCount = [string](Get-ChildItem -Path $InventoryModulesPath -Recurse -Filter "*.ps1").count

    Write-Output 'Starting to Build Excel Report.'
    Write-Host 'Supported Resource Types: ' -NoNewline -ForegroundColor Green
    Write-Host $ModulesCount -ForegroundColor Cyan

    $Lops = $ModulesCount
    $ReportCounter = 0

    Foreach ($ModuleFolder in $ModuleFolders)
        {
            $CacheData = $null
            $ModulePath = Join-Path $ModuleFolder.FullName '*.ps1'
            $ModuleFiles = Get-ChildItem -Path $ModulePath

            $CacheFiles = Get-ChildItem -Path $ReportCache -Recurse
            $JSONFileName = ($ModuleFolder.Name + '.json')
            $CacheFile = $CacheFiles | Where-Object { $_.Name -like "*$JSONFileName" }

            if ($CacheFile)
                {
                    $CacheFileContent = New-Object System.IO.StreamReader($CacheFile.FullName)
                    $CacheData = $CacheFileContent.ReadToEnd()
                    $CacheFileContent.Dispose()
                    $CacheData = $CacheData | ConvertFrom-Json
                }

            Foreach ($Module in $ModuleFiles)
                {
                    $c = (($ReportCounter / $Lops) * 100)
                    $c = [math]::Round($c)
                    Write-Progress -Id 1 -activity "Building Report" -Status "$c% Complete." -PercentComplete $c

                    $ModuleFileContent = New-Object System.IO.StreamReader($Module.FullName)
                    $ModuleData = $ModuleFileContent.ReadToEnd()
                    $ModuleFileContent.Dispose()
                    $ModName = $Module.Name.replace(".ps1","")

                    $SmaResources = $CacheData.$ModName

                    $ModuleResourceCount = $SmaResources.count

                    if ($ModuleResourceCount -gt 0)
                    {
                        Start-Sleep -Milliseconds 25
                        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+"Running Module: '$ModName'. Excel Rows: $ModuleResourceCount")

                        $ScriptBlock = [Scriptblock]::Create($ModuleData)

                        Invoke-Command -ScriptBlock $ScriptBlock -ArgumentList $PSScriptRoot, $null, $InTag, $null, $null, 'Reporting', $file, $SmaResources, $TableStyle, $null

                    }

                    $ReportCounter ++

                }
                Remove-Variable -Name CacheData
                Remove-Variable -Name SmaResources
                Clear-ARIMemory
        }
        Write-Progress -Id 1 -activity "Building Report" -Status "100% Complete." -Completed
    }