<#
.Synopsis
Runs a set of REST requests in parallel with retry.

.DESCRIPTION
Takes request objects (Key, Uri, optional Method) and sends them with a bounded
number of threads. Throttled (429) and transient (5xx) responses are retried,
honouring Retry-After. Returns a hashtable of Key -> response; failed requests map
to $null and their errors are written to the debug stream.

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

        for ($Attempt = 1; $Attempt -le $MaxAttempts; $Attempt++) {
            try {
                $Response = Invoke-RestMethod -Uri $Request.Uri -Headers $using:Header -Method $Method -Debug:$false
                $ErrorText = $null
                break
            }
            catch {
                $ErrorText = $_.Exception.Message
                $Status = [int]$_.Exception.Response.StatusCode
                if (($Status -ne 429 -and $Status -lt 500) -or $Attempt -eq $MaxAttempts) { break }
                $RetryAfter = $_.Exception.Response.Headers.RetryAfter.Delta.TotalSeconds
                $Wait = if ($RetryAfter) { [math]::Min($RetryAfter, 60) } else { [math]::Pow(2, $Attempt) }
                Start-Sleep -Seconds $Wait
            }
        }

        [PSCustomObject]@{ Key = $Request.Key; Response = $Response; Error = $ErrorText; Uri = $Request.Uri }
    }

    foreach ($Item in $Responses) {
        if ($Item.Error) {
            Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Error: ' + $Item.Error + ' (' + ($Item.Uri -replace '\?.*$', '') + ')')
        }
        $Results[$Item.Key] = $Item.Response
    }

    return $Results
}
