function Get-ARIUnsupportedData {
    Param($Debug)
    if ($Debug.IsPresent)
        {
            $DebugPreference = 'Continue'
            $ErrorActionPreference = 'Continue'
        }
    else
        {
            $ErrorActionPreference = "silentlycontinue"
        }

    $SupportedDataPath = (get-item $PSScriptRoot).parent
    $SupportFile = Join-Path $SupportedDataPath '3.ReportingFunctions' 'StyleFunctions' 'Support.json'
    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Validating file: '+$SupportFile)

    $Unsupported = Get-Content -Path $SupportFile | ConvertFrom-Json

    return $Unsupported
}