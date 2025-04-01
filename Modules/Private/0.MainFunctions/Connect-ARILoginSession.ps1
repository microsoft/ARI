<#
.Synopsis
Azure Login Session Module for Azure Resource Inventory

.DESCRIPTION
This module is used to invoke the authentication process that is handle by Azure PowerShell.

.Link
https://github.com/microsoft/ARI/Modules/Private/0.MainFunctions/Connect-LoginSession.ps1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.6.0
First Release Date: 15th Oct, 2024
Authors: Claudio Merola

#>
function Connect-ARILoginSession {
    Param($AzureEnvironment, $TenantID, $SubscriptionID, $DeviceLogin, $AppId, $Secret, $CertificatePath, $Debug)
    $DebugPreference = 'silentlycontinue'
    $ErrorActionPreference = 'Continue'

    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Starting Connect-LoginSession function')
    Write-Host $AzureEnvironment -BackgroundColor Green
    $Context = Get-AzContext -ErrorAction SilentlyContinue
    if (!$TenantID) {
        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Tenant ID not specified')
        write-host "Tenant ID not specified. Use -TenantID parameter if you want to specify directly. "
        write-host "Authenticating Azure"
        write-host ""

        if($DeviceLogin.IsPresent)
            {
                Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Logging with Device Login')
                Connect-AzAccount -UseDeviceAuthentication -Environment $AzureEnvironment | Out-Null
            }
        else
            {
                try 
                    {
                        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Editing Login Experience')
                        $AZConfigNewLogin = Get-AzConfig -LoginExperienceV2 -WarningAction SilentlyContinue -InformationAction SilentlyContinue
                        if ($AZConfigNewLogin.value -eq 'On' )
                            {
                                Update-AzConfig -LoginExperienceV2 Off | Out-Null
                                Connect-AzAccount -Environment $AzureEnvironment | Out-Null
                                Update-AzConfig -LoginExperienceV2 On | Out-Null
                            }
                        else
                            {
                                Connect-AzAccount -Environment $AzureEnvironment | Out-Null
                            }
                    }
                catch
                    {
                        Connect-AzAccount -Environment $AzureEnvironment | Out-Null
                    }
            }
        write-host ""
        write-host ""
        $Tenants = Get-AzTenant -WarningAction SilentlyContinue -InformationAction SilentlyContinue | Sort-Object -Unique
        if ($Tenants.Count -eq 1) {
            write-host "You have privileges only in One Tenant "
            write-host ""
            $TenantID = $Tenants.Id
        }
        else {
            write-host "Select the the Azure Tenant ID that you want to connect : "
            write-host ""
            $SequenceID = 1
            foreach ($Tenant in $Tenants) {
                $TenantName = $Tenant.name
                write-host "$SequenceID)  $TenantName"
                $SequenceID ++
            }
            write-host ""
            [int]$SelectTenant = read-host "Select Tenant ( default 1 )"
            $defaultTenant = --$SelectTenant
            $TenantID = ($Tenants[$defaultTenant]).Id
            if($DeviceLogin.IsPresent)
                {
                    Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Logging with Device Login')
                    Connect-AzAccount -Tenant $TenantID -UseDeviceAuthentication -Environment $AzureEnvironment | Out-Null
                }
            else
                {
                    Connect-AzAccount -Tenant $TenantID -Environment $AzureEnvironment | Out-Null
                }
        }
    }
    else {
        Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Tenant ID was informed.')

        if($Context.Tenant.Id -ne $TenantID)
        {
            Set-AzContext -Tenant $TenantID -ErrorAction SilentlyContinue | Out-Null
            $Context = Get-AzContext -ErrorAction SilentlyContinue
        }
        $Subs = Get-AzSubscription -TenantId $TenantID -ErrorAction SilentlyContinue -WarningAction SilentlyContinue

        if($DeviceLogin.IsPresent)
            {
                Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Logging with Device Login')
                Connect-AzAccount -Tenant $TenantID -UseDeviceAuthentication -Environment $AzureEnvironment | Out-Null
            }
        elseif($AppId -and $Secret -and $CertificatePath -and $TenantID)
            {
                Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Logging with AppID and CertificatePath')
                $SecurePassword = ConvertTo-SecureString -String $Secret -AsPlainText -Force
                Connect-AzAccount -ServicePrincipal -TenantId $TenantId -ApplicationId $AppId -CertificatePath $CertificatePath -CertificatePassword $SecurePassword | Out-Null
            }            
        elseif($AppId -and $Secret -and $TenantID)
            {
                Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Logging with AppID and Secret')
                $SecurePassword = ConvertTo-SecureString -String $Secret -AsPlainText -Force
                $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $AppId, $SecurePassword
                Connect-AzAccount -ServicePrincipal -TenantId $TenantId -Credential $Credential | Out-Null
            }
        else
            {
                if([string]::IsNullOrEmpty($Subs))
                    {
                        try 
                            {
                                Write-Debug ((get-date -Format 'yyyy-MM-dd_HH_mm_ss')+' - '+'Editing Login Experience')
                                $AZConfig = Get-AzConfig -LoginExperienceV2 -WarningAction SilentlyContinue -InformationAction SilentlyContinue
                                if ($AZConfig.value -eq 'On')
                                    {
                                        Update-AzConfig -LoginExperienceV2 Off | Out-Null
                                        Connect-AzAccount -Tenant $TenantID -Environment $AzureEnvironment | Out-Null
                                        Update-AzConfig -LoginExperienceV2 On | Out-Null
                                    }
                                else
                                    {
                                        Connect-AzAccount -Tenant $TenantID -Environment $AzureEnvironment | Out-Null
                                    }
                            }
                        catch
                            {
                                Connect-AzAccount -Tenant $TenantID -Environment $AzureEnvironment | Out-Null
                            }
                    }
                else
                    {
                        Write-Host "Already authenticated in Tenant $TenantID"
                    }
            }
    }
    return $TenantID
}