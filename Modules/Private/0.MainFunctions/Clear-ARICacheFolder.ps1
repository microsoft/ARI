function Clear-ARICacheFolder {
    Param($ReportCache, $Debug)
    if ($Debug.IsPresent)
        {
            $DebugPreference = 'Continue'
            $ErrorActionPreference = 'Continue'
        }
    else
        {
            $ErrorActionPreference = "silentlycontinue"
        }

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Clearing Cache Folder.')
    $CacheFiles = Get-ChildItem -Path $ReportCache -Recurse
    Foreach ($CacheFile in $CacheFiles)
        {
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Removing Cache File: '+$CacheFile.FullName)
            Remove-Item -Path $CacheFile.FullName -Force
        }
}