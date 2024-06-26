<#
.Synopsis
Automation Account Script

.DESCRIPTION
This script process and creates the Azure Resource Inventory Excel sheet running on an Azure Automation Account and saving the file to a StorageAccount. 

.Link
https://github.com/microsoft/ARI/Automation/ARI_Automation.ps1

.COMPONENT
This powershell Script is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.1.9
Author: Claudio Merola

Core Steps:
1 ) Create System Identity
2 ) Give Read Permissions to the System Identity in the Management Group
3 ) Create Blob Storage Account
4 ) Create Container
5 ) Give "Storage Blob Data Contributor" Permissions to the System Identity on the Storage Account
6 ) Create Runbook Powershell with Runtime 7.2
7 ) Add modules "ImportExcel", "Az.ResourceGraph", "Az.Storage", "Az.Account" and "ThreadJob" (Runtime 7.2)

#>

<######################################################### VARIABLES ######################################################################>

#StorageAccount Name
$Script:STGACC = "azureinventorystg"

#Container Name
$Script:STGCTG = 'ari'

#Include Tags
$Script:InTag = $false

#Lite
$Script:RunLite = $true

#Debug
$Script:RunDebug = $true

#Include Security Center
$Script:IncludeSecurityCenter = $false

<######################################################### SCRIPT ######################################################################>

if($RunDebug)
    {
        Write-Output ('Debugging Enable.')
    }

# Ensures you do not inherit an AzContext in your runbook
$null = Disable-AzContextAutosave -Scope Process

# Connect using a Managed Service Identity
try {
    $Script:AzureConnection = (Connect-AzAccount -Identity).context
}
catch {
    Write-Output "There is no system-assigned user identity. Aborting." 
    exit
}

# set and store context
$Script:AzureContext = Set-AzContext -SubscriptionName $AzureConnection.Subscription -DefaultProfile $AzureConnection

$Script:Context = New-AzStorageContext -StorageAccountName $STGACC -UseConnectedAccount

$Script:aristg = $STGCTG

$Script:TableStyle = "Light19"

$Date = get-date -Format "yyyy-MM-dd_HH_mm"
$Script:DateStart = get-date

$Script:File = ("ARI_Automation_Report_"+$Date+".xlsx")


$Script:Resources = @()
$Script:Advisories = @()
$Script:Policies = @()
$Script:Security = @()
$Script:Subscriptions = ''

$Script:Repo = 'https://api.github.com/repos/microsoft/ari/git/trees/main?recursive=1'
$Script:RawRepo = 'https://raw.githubusercontent.com/microsoft/ARI/main'



<######################################################### EXTRACTION ######################################################################>

function Invoke-Extraction {
    param($kqlQuery, $SubID)
    [System.Collections.Generic.List[string]]$kqlResult

    $Looper = 0
    while ($true) {

        if ($Looper -gt 0) {
            $graphResult = Search-AzGraph -Query $kqlQuery -First 1000 -Subscription $SubID -SkipToken $graphResult.SkipToken
        }
        else {
            $graphResult = Search-AzGraph -Query $kqlQuery -First 1000 -Subscription $SubID
        }

        $kqlResult += $graphResult.data

        if ($graphResult.data.Count -lt 1000) {
            break;
        }
        $Looper += $Looper + 1000
    }
    $kqlResult
}

function LoopExtraction {
    Write-Output 'Extracting Resources'    

    $ExtractionRunTime = get-date

    $ModuSeq = (New-Object System.Net.WebClient).DownloadString($RawRepo + '/Extras/Support.json')
    $Script:Unsupported = $ModuSeq | ConvertFrom-Json

    $Query = "advisorresources | order by id asc"
    $Script:Advisories += Invoke-Extraction -kqlQuery $Query -SubID $Subscriptions

    if($RunDebug)
        {
            Write-Output ('DEBUG - extracting resources')
            Write-Output ('')
        }
    $Query = "resources | where strlen(properties) < 123000 | order by id asc"
    $Script:Resources += Invoke-Extraction -kqlQuery $Query -SubID $Subscriptions

    $Query = "networkresources | order by id asc"
    $Script:Resources += Invoke-Extraction -kqlQuery $Query -SubID $Subscriptions

    $Query = "recoveryservicesresources | where type =~ 'microsoft.recoveryservices/vaults/backupfabrics/protectioncontainers/protecteditems' or type =~ 'microsoft.recoveryservices/vaults/backuppolicies'"
    $Script:Resources += Invoke-Extraction -kqlQuery $Query -SubID $Subscriptions

    $Query = "desktopvirtualizationresources | order by id asc"
    $Script:Resources += Invoke-Extraction -kqlQuery $Query -SubID $Subscriptions

    $Query = "policyresources | where type == 'microsoft.authorization/policyassignments' | order by id asc"
    $Script:Policies += Invoke-Extraction -kqlQuery $Query -SubID $Subscriptions

    if($Script:IncludeSecurityCenter)
        {
            $Query = "securityresources | where type =~ 'microsoft.security/assessments' and properties['status']['code'] == 'Unhealthy' | order by id asc"
            $Script:Security += Invoke-Extraction -kqlQuery $Query -SubID $Subscriptions
        }

}         

<######################################################### JOBs ######################################################################>

function AdvisoryJob {
    Write-Output ('Starting Advisory Job')

    $ModuSeq = (New-Object System.Net.WebClient).DownloadString($RawRepo + '/Extras/Advisory.ps1')

    $ScriptBlock = [Scriptblock]::Create($ModuSeq)

    Start-ThreadJob -Name 'Advisory' -ScriptBlock $ScriptBlock -ArgumentList $Script:Advisories, 'Processing' , $File
}

function PolicyJob {
    Write-Output ('Starting Policy Job')

    $ModuSeq = (New-Object System.Net.WebClient).DownloadString($RawRepo + '/Extras/Policy.ps1')

    $ScriptBlock = [Scriptblock]::Create($ModuSeq)

    Start-ThreadJob -Name 'Policy' -ScriptBlock $ScriptBlock -ArgumentList $Script:Policies, 'Processing' , $Script:File
}

function SecurityCenterJob {
    if($Script:IncludeSecurityCenter)
        {
            Write-Output ('Starting SecurityCenter Job')

            $ModuSeq = (New-Object System.Net.WebClient).DownloadString($RawRepo + '/Extras/SecurityCenter.ps1')

            $ScriptBlock = [Scriptblock]::Create($ModuSeq)

            Start-ThreadJob -Name 'SecurityCenter' -ScriptBlock $ScriptBlock -ArgumentList $Script:Security, 'Processing' , $Script:File
        }
}

function SubscriptionJob {
    Write-Output ('Starting Subscription Job')

    $ModuSeq = (New-Object System.Net.WebClient).DownloadString($RawRepo + '/Extras/Subscriptions.ps1')

    $ScriptBlock = [Scriptblock]::Create($ModuSeq)

    Start-ThreadJob -Name 'Subscriptions' -ScriptBlock $ScriptBlock -ArgumentList $Script:Subscriptions, $Script:Resources, 'Processing' , $Script:File
}

<######################################################### Reporting ######################################################################>

function Resources {
    Write-Output ('Starting Resources Processes')
    Write-Output ('Total Resources Being Analyzed: '+$Script:Resources.count)

    $OnlineRepo = Invoke-WebRequest -Uri $Repo
    $RepoContent = $OnlineRepo | ConvertFrom-Json
    $Modules = ($RepoContent.tree | Where-Object {$_.path -like '*.ps1' -and $_.path -notlike 'Extras/*' -and $_.path -ne 'AzureResourceInventory.ps1' -and $_.path -notlike 'Automation/*'}).path

    foreach ($Module in $Modules) 
        {
            $SmaResources = @{}

            if($RunDebug)
                {
                    Write-Output ''
                    Write-Output ('DEBUG - Running Module: '+$Module)
                }

            $Modul = $Module.split('/')
            $ModName = $Modul[2].Substring(0, $Modul[2].length - ".ps1".length)
            $ModuSeq = (New-Object System.Net.WebClient).DownloadString($RawRepo + '/' + $Module)

            $ScriptBlock = [Scriptblock]::Create($ModuSeq)

            $SmaResources[$ModName] = Invoke-Command -ScriptBlock $ScriptBlock -ArgumentList $PSScriptRoot, $Script:Subscriptions, $Script:InTag, $Script:Resources, 'Processing', $null, $null, $null, $Script:Unsupported

            Start-Sleep -Milliseconds 100

            Write-Output ('Resources ('+$ModName+'): '+$SmaResources[$ModName].count)

            Invoke-Command -ScriptBlock $ScriptBlock -ArgumentList $PSScriptRoot,$null,$InTag,$null,'Reporting',$File,$SmaResources,$TableStyle,$Unsupported | Out-Null

            Start-Sleep -Milliseconds 100

        }
}

function Advisories {
    if($RunDebug)
        {
            Write-Output ('DEBUG - Reporting Advisories.')
        }

    get-job -Name 'Advisory' | Wait-Job | Out-Null

    $Adv = Receive-Job -Name 'Advisory'

    $ModuSeq = (New-Object System.Net.WebClient).DownloadString($RawRepo + '/Extras/Advisory.ps1')

    $ScriptBlock = [Scriptblock]::Create($ModuSeq)

    Invoke-Command -ScriptBlock $ScriptBlock -ArgumentList $null,'Reporting',$file,$Adv,$TableStyle
}

function Policies {
    if($RunDebug)
        {
            Write-Output ('DEBUG - Reporting Policies.')
        }

    get-job -Name 'Policy' | Wait-Job | Out-Null

    $Pol = Receive-Job -Name 'Policy'

    $ModuSeq = (New-Object System.Net.WebClient).DownloadString($RawRepo + '/Extras/Policy.ps1')

    $ScriptBlock = [Scriptblock]::Create($ModuSeq)

    Invoke-Command -ScriptBlock $ScriptBlock -ArgumentList $null,'Reporting',$Script:file,$Pol,$Script:TableStyle
}

function SecurityCenter {
    if($Script:IncludeSecurityCenter)
        {
            if($RunDebug)
                {
                    Write-Output ('DEBUG - Reporting SecurityCenter.')
                }

            get-job -Name 'SecurityCenter' | Wait-Job | Out-Null

            $Sec = Receive-Job -Name 'SecurityCenter'

            $ModuSeq = (New-Object System.Net.WebClient).DownloadString($RawRepo + '/Extras/SecurityCenter.ps1')

            $ScriptBlock = [Scriptblock]::Create($ModuSeq)

            Invoke-Command -ScriptBlock $ScriptBlock -ArgumentList $null,'Reporting',$Script:file,$Sec,$Script:TableStyle
        }
}

function Subscriptions {
    if($RunDebug)
        {
            Write-Output ('DEBUG - Reporting Subscription .')
        }

    get-job -Name 'Subscriptions' | Wait-Job | Out-Null

    $AzSubs = Receive-Job -Name 'Subscriptions'

    $ModuSeq = (New-Object System.Net.WebClient).DownloadString($RawRepo + '/Extras/Subscriptions.ps1')

    $ScriptBlock = [Scriptblock]::Create($ModuSeq)

    Invoke-Command -ScriptBlock $ScriptBlock -ArgumentList $null,$null,'Reporting',$file,$AzSubs,$TableStyle
}

<######################################################### CHARTS ######################################################################>

function Charts {
    if($RunDebug)
        {
            Write-Output ('DEBUG - Reporting Charts.')
        }

    $ReportingRunTime = get-date

    $ExtractionRunTime = (($ExtractionRunTime) - ($DateStart))

    $ReportingRunTime = (($ReportingRunTime) - ($DateStart))

    $ModuSeq = (New-Object System.Net.WebClient).DownloadString($RawRepo + '/Extras/Charts.ps1')

    $ScriptBlock = [Scriptblock]::Create($ModuSeq)

    $FileFull = ((Get-Location).Path+'\'+$File)

    Invoke-Command -ScriptBlock $ScriptBlock -ArgumentList $FileFull,$Script:TableStyle,'Azure Automation',$Subscriptions,$Resources.Count,$ExtractionRunTime,$ReportingRunTime,$RunLite
}

<######################################################### Starting Script ######################################################################>

$Script:Subscriptions = Get-AzSubscription | Where-Object {$_.State -ne 'Disabled'}
if($RunDebug)
{
    $Subcount = $Subscriptions.count
    Write-Output ("Subscriptions found: $Subcount")
}

LoopExtraction
AdvisoryJob
PolicyJob
SecurityCenterJob
SubscriptionJob
Resources
Advisories
Policies
SecurityCenter
Subscriptions
Charts


<######################################################### UPLOAD FILE ######################################################################>

Write-Output 'Uploading Excel File to Storage Account'

Set-AzStorageBlobContent -File $Script:File -Container $Script:aristg -Context $Script:Context | Out-Null
if($Diagram){Set-AzStorageBlobContent -File $DDFile -Container $Script:aristg -Context $Script:Context | Out-Null}

Write-Output 'Completed'
