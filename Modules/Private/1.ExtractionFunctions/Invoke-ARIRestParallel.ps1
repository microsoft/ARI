<#
.Synopsis
Runs a set of REST requests in parallel with retry.

.DESCRIPTION
Takes request objects (Key, Uri, optional Method) and sends them with a bounded
number of threads. Throttled and transient responses (429, 503, 504) are retried
up to MaxAttempts and other 5xx once, honouring Retry-After. Returns a hashtable of
Key -> response; failed requests map to $null. Errors, retries and the slowest
request are written to the debug stream.

.Link
https://github.com/microsoft/ARI/Modules/Private/1.ExtractionFunctions/Invoke-ARIRestParallel.ps1

.COMPONENT
This PowerShell Module is part of Azure Resource Inventory (ARI).

.NOTES
Version: 3.6.16
First Release Date: 9th Oct, 2026
Authors: Robin Pieterse
#>

function Invoke-ARIRestParallel {
    Param($Requests, $Header, $ThrottleLimit = 8, $MaxAttempts = 4)

    $Results = @{}
    if (!$Requests) { return $Results }

    $Responses = $Requests | ForEach-Object -ThrottleLimit $ThrottleLimit -Parallel {
        $Request = $_
        $Method = if ($Request.Method) { $Request.Method } else { 'GET' }
        $MaxAttempts = $using:MaxAttempts
        $Response = $null
        $ErrorText = $null
        $Retries = [System.Collections.Generic.List[string]]::new()
        $Timer = [System.Diagnostics.Stopwatch]::StartNew()

        for ($Attempt = 1; $Attempt -le $MaxAttempts; $Attempt++) {
            try {
                $Response = Invoke-RestMethod -Uri $Request.Uri -Headers $using:Header -Method $Method -Debug:$false
                $ErrorText = $null
                break
            }
            catch {
                $ErrorText = $_.Exception.Message
                $Status = [int]$_.Exception.Response.StatusCode
                # 429/503/504 are usually transient; other 5xx (e.g. a 502 that repeats every run) get one retry
                $Transient = $Status -in 429, 503, 504
                if ($Status -lt 500 -and !$Transient) { break }
                if ($Attempt -eq $MaxAttempts -or (!$Transient -and $Attempt -ge 2)) { break }
                $RetryAfter = $_.Exception.Response.Headers.RetryAfter.Delta.TotalSeconds
                $Wait = if ($RetryAfter) { [math]::Min($RetryAfter, 60) } else { [math]::Pow(2, $Attempt) }
                $Retries.Add(([string]$Status + ' wait ' + $Wait + 's'))
                Start-Sleep -Seconds $Wait
            }
        }

        [PSCustomObject]@{ Key = $Request.Key; Response = $Response; Error = $ErrorText; Uri = $Request.Uri; Seconds = $Timer.Elapsed.TotalSeconds; Retries = ($Retries -join ', ') }
    }

    foreach ($Item in $Responses) {
        if ($Item.Retries) {
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Retried: ' + $Item.Retries + ' (' + ($Item.Uri -replace '\?.*$', '') + ')')
        }
        if ($Item.Error) {
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Error: ' + $Item.Error + ' (' + ($Item.Uri -replace '\?.*$', '') + ')')
        }
        $Results[$Item.Key] = $Item.Response
    }

    $Slowest = $Responses | Sort-Object Seconds -Descending | Select-Object -First 1
    if ($Slowest) {
        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Requests: ' + @($Responses).Count + ', retried: ' + @($Responses | Where-Object Retries).Count + ', slowest: ' + [math]::Round($Slowest.Seconds, 1) + 's (' + ($Slowest.Uri -replace '\?.*$', '') + ')')
    }

    return $Results
}
