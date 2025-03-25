function Set-ARIFolder {
    Param($DefaultPath, $DiagramCache, $ReportCache, $Debug)
    if ($Debug.IsPresent)
        {
            $DebugPreference = 'Continue'
            $ErrorActionPreference = 'Continue'
        }
    else
        {
            $ErrorActionPreference = "silentlycontinue"
        }
    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Checking report folder: ' + $DefaultPath )
    try {
        if ((Test-Path -Path $DefaultPath -PathType Container) -eq $false) {
            New-Item -Type Directory -Force -Path $DefaultPath | Out-Null
        }
        if ((Test-Path -Path $DiagramCache -PathType Container) -eq $false) {
            New-Item -Type Directory -Force -Path $DiagramCache | Out-Null
        }
        if ((Test-Path -Path $ReportCache -PathType Container) -eq $false) {
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Creating Folder for Cache Files.')
            New-Item -Type Directory -Force -Path $ReportCache | Out-Null
        }
    }
    catch
        {
            Write-Output ($_.Exception.Message)
        }
    
}