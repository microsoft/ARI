<#
.Synopsis
Automation Account Script

.DESCRIPTION
This script process and creates the Azure Resource Inventory Excel sheet running on an Azure Automation Account and saving the file to a StorageAccount. 

.Link
https://github.com/azureinventory/ARI/Automation/ARI_Automation.ps1

.COMPONENT
   This powershell Script is part of Azure Resource Inventory (ARI)

.NOTES
Version: 2.0.0
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

Core Steps:
1 ) Create System Identity
2 ) Give Read Permissions to the System Identity
3 ) Create Blob Storage Account
4 ) Create Container
5 ) Give "Storage Blob Data Contributor" Permissions to the System Identity on the Storage Account
6 ) Give Contributor Permissions on the Container*
7 ) Add modules "ImportExcel", "Az.ResourceGraph", "Az.Storage", "Az.Account"

#>

<######################################################### VARIABLES ######################################################################>

#StorageAccount Name
$STGACC = "azureinventorystg"

#Container Name
$STGCTG = 'azureresourceinventory'

#Define if creating Draw.io Diagram File
$Diagram = $false

<######################################################### SCRIPT ######################################################################>

Clear-AzContext -Force

Connect-AzAccount -Identity

$Context = New-AzStorageContext -StorageAccountName $STGACC -UseConnectedAccount

$aristg = $STGCTG

$TableStyle = "Light20"

$Date = get-date -Format "yyyy-MM-dd_HH_mm"
$DateStart = get-date

$File = ("ARI_Automation_Report_"+$Date+".xlsx")
$DDFile = ("ARI_Automation_Diagram_" + $Date + ".xml")


$Resources = @()
$Advisories = @()
$Security = @()
$Subscriptions = ''

$Repo = 'https://github.com/azureinventory/ARI/tree/main/Modules'
$RawRepo = 'https://raw.githubusercontent.com/azureinventory/ARI/main'

<######################################################### ADVISORY EXTRACTION ######################################################################>

Write-Output 'Extracting Advisories'

    $AdvSize = Search-AzGraph -Query "advisorresources | summarize count()"
    $AdvSizeNum = $AdvSize.'count_'

    if ($AdvSizeNum -ge 1) {
        $Loop = $AdvSizeNum / 1000
        $Loop = [math]::ceiling($Loop)
        $Looper = 0
        $Limit = 1

        while ($Looper -lt $Loop) 
            {
                $Looper ++
                $Advisor = Search-AzGraph -Query "advisorresources | order by id asc" -skip $Limit -first 1000
                $Advisories += $Advisor
                Start-Sleep 2
                $Limit = $Limit + 1000
            }
    } 


$Subscriptions = Get-AzContext -ListAvailable | Where-Object {$_.Subscription.State -ne 'Disabled'}
$Subscriptions = $Subscriptions.Subscription

<######################################################### RESOURCE EXTRACTION ######################################################################>

Write-Output 'Extracting Resources'
 
    Foreach ($Subscription in $Subscriptions) {

        $SUBID = $Subscription.id
        Set-AzContext -Subscription $SUBID | Out-Null
                    
        $EnvSize = Search-AzGraph -Query "resources | where subscriptionId == '$SUBID' and strlen(properties) < 123000 | summarize count()"
        $EnvSizeNum = $EnvSize.count_
                        
        if ($EnvSizeNum -ge 1) {
            $Loop = $EnvSizeNum / 1000
            $Loop = [math]::ceiling($Loop)
            $Looper = 0
            $Limit = 1
    
            while ($Looper -lt $Loop) {
                $Resource0 = Search-AzGraph -Query "resources | where subscriptionId == '$SUBID' and strlen(properties) < 123000 | order by id asc" -skip $Limit -first 1000
                $Resources += $Resource0
                Start-Sleep 2
                $Looper ++
                $Limit = $Limit + 1000
            }
        }
    }   
    
$ExtractionRunTime = get-date

$ModuSeq = (New-Object System.Net.WebClient).DownloadString($RawRepo + '/Extras/Support.json')
$Unsupported = $ModuSeq | ConvertFrom-Json

if($Diagram)
{
Write-Output ('Processing Diagram')

$ModuSeq = (New-Object System.Net.WebClient).DownloadString($RawRepo + '/Extras/DrawIODiagram.ps1')               
                    
$ScriptBlock = [Scriptblock]::Create($ModuSeq)
                    
Start-job -Name 'DrawDiagram' -ScriptBlock {$ScriptBlock } -ArgumentList $Subscriptions, $Resources, $Advisories, $DDFile
}

<######################################################### ADVISORY JOB ######################################################################>


Write-Output ('Starting Advisory Job')

$ModuSeq = (New-Object System.Net.WebClient).DownloadString($RawRepo + '/Extras/Advisory.ps1')

$ScriptBlock = [Scriptblock]::Create($ModuSeq)

Start-Job -Name 'Advisory' -ScriptBlock $ScriptBlock -ArgumentList $Advisories, 'Processing' , $File

            
<######################################################### SUBSCRIPTIONS JOB ######################################################################>

Write-Output ('Starting Subscription Job')

$ModuSeq = (New-Object System.Net.WebClient).DownloadString($RawRepo + '/Extras/Subscriptions.ps1')

$ScriptBlock = [Scriptblock]::Create($ModuSeq)

Start-Job -Name 'Subscriptions' -ScriptBlock $ScriptBlock -ArgumentList $Subscriptions, $Resources, 'Processing' , $File


<######################################################### RESOURCES ######################################################################>


Write-Output ('Starting Resources Processes')

$Modules = @()
Write-Output ('Running Online, Gethering List Of Modules for Compute.')
$OnlineRepoComp = Invoke-WebRequest -Uri ($Repo + '/Compute') -UseBasicParsing
$RepoComp = $OnlineRepoComp.Links | Where-Object { $_.href -like '*.ps1' }
$Modules += $RepoComp.href
Write-Output ('Running Online, Gethering List Of Modules for Networking.')
$OnlineRepoNetworking = Invoke-WebRequest -Uri ($Repo + '/Networking') -UseBasicParsing
$RepoNetwork = $OnlineRepoNetworking.Links | Where-Object { $_.href -like '*.ps1' }
$Modules += $RepoNetwork.href
Write-Output ('Running Online, Gethering List Of Modules for Database.')
$OnlineRepoDB = Invoke-WebRequest -Uri ($Repo + '/Data') -UseBasicParsing
$RepoData = $OnlineRepoDB.Links | Where-Object { $_.href -like '*.ps1' }
$Modules += $RepoData.href
Write-Output ('Running Online, Gethering List Of Modules for Infrastructure.')
$OnlineRepoInfra = Invoke-WebRequest -Uri ($Repo + '/Infrastructure') -UseBasicParsing
$RepoInfra = $OnlineRepoInfra.Links | Where-Object { $_.href -like '*.ps1' }
$Modules += $RepoInfra.href

foreach ($Module in $Modules) 
    {
        $SmaResources = @{}

        $Modul = $Module.split('/')
        $ModName = $Modul[7].Substring(0, $Modul[7].length - ".ps1".length)
        $ModuSeq = (New-Object System.Net.WebClient).DownloadString($RawRepo + '/Modules/' + $Modul[6] + '/' + $Modul[7])

        $ScriptBlock = [Scriptblock]::Create($ModuSeq)

        $SmaResources[$ModName] = Invoke-Command -ScriptBlock $ScriptBlock -ArgumentList $PSScriptRoot, $Subscriptions, $InTag, $Resources, 'Processing'

        Write-Output ('Resources ('+$ModName+'): '+$SmaResources[$ModName].count)

        Invoke-Command -ScriptBlock $ScriptBlock -ArgumentList $PSScriptRoot,$null,$InTag,$null,'Reporting',$File,$SmaResources,$TableStyle,$Unsupported | Out-Null

    }


<######################################################### ADVISORY REPORTING ######################################################################>

get-job -Name 'Advisory' | Wait-Job | Out-Null

$Adv = Receive-Job -Name 'Advisory'

$ModuSeq = (New-Object System.Net.WebClient).DownloadString($RawRepo + '/Extras/Advisory.ps1')

$ScriptBlock = [Scriptblock]::Create($ModuSeq)

Invoke-Command -ScriptBlock $ScriptBlock -ArgumentList $null,'Reporting',$file,$Adv,$TableStyle

<######################################################### SUBSCRIPTIONS REPORTING ######################################################################>

get-job -Name 'Subscriptions' | Wait-Job | Out-Null

$AzSubs = Receive-Job -Name 'Subscriptions'

$ModuSeq = (New-Object System.Net.WebClient).DownloadString($RawRepo + '/Extras/Subscriptions.ps1')

$ScriptBlock = [Scriptblock]::Create($ModuSeq)

Invoke-Command -ScriptBlock $ScriptBlock -ArgumentList $null,$null,'Reporting',$file,$AzSubs,$TableStyle

<######################################################### CHARTS ######################################################################>

$ReportingRunTime = get-date

$ExtractionRunTime = (($ExtractionRunTime) - ($DateStart))

$ReportingRunTime = (($ReportingRunTime) - ($DateStart))

$ModuSeq = (New-Object System.Net.WebClient).DownloadString($RawRepo + '/Extras/Charts.ps1')

$ScriptBlock = [Scriptblock]::Create($ModuSeq)

$FileFull = ((Get-Location).Path+'\'+$File)

Invoke-Command -ScriptBlock $ScriptBlock -ArgumentList $FileFull,'Light20','Azure Automation',$Subscriptions,$Resources.Count,$ExtractionRunTime,$ReportingRunTime

<######################################################### UPLOAD FILE ######################################################################>

Write-Output 'Uploading Excel File to Storage Account'

Set-AzStorageBlobContent -File $File -Container $aristg -Context $Context | Out-Null
if($Diagram){Set-AzStorageBlobContent -File $DDFile -Container $aristg -Context $Context | Out-Null}

Write-Output 'Completed'