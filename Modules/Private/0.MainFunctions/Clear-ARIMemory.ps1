function Clear-ARIMemory {

    $DebugPreference = 'Continue'

    [System.GC]::GetTotalMemory($true) | Out-Null
    Start-Sleep -Milliseconds 100
    [System.GC]::Collect() | Out-Null
    Start-Sleep -Milliseconds 100
}