<#
.Synopsis
Inventory for Azure Container App instance

.DESCRIPTION
This script consolidates information for all microsoft.app/containerapps resource provider in $Resources variable. 
Excel Sheet Name: Container App

.Link
https://github.com/microsoft/ARI/Modules/Public/InventoryModules/Container/ContainerApp.ps1

.COMPONENT
This powershell Module is part of Azure Resource Inventory (ARI)

.NOTES
Version: 3.6.0
First Release Date: 19th November, 2020
Authors: Claudio Merola and Renato Gregio 

#>

<######## Default Parameters. Don't modify this ########>

param($SCPath, $Sub, $Intag, $Resources, $Retirements, $Task ,$File, $SmaResources, $TableStyle, $Unsupported)

If ($Task -eq 'Processing')
{

    <######### Insert the resource extraction here ########>

        $CONTAINER = $Resources | Where-Object {$_.TYPE -eq 'microsoft.app/containerapps'}

    <######### Insert the resource Process here ########>

    if($CONTAINER)
        {
            $tmp = foreach ($1 in $CONTAINER) {
                $ResUCount = 1
                $sub1 = $SUB | Where-Object { $_.id -eq $1.subscriptionId }
                $data = $1.PROPERTIES
                $Retired = $Retirements | Where-Object { $_.id -eq $1.id }
                if ($Retired) 
                    {
                        $RetiredFeature = foreach ($Retire in $Retired)
                            {
                                $RetiredServiceID = $Unsupported | Where-Object {$_.Id -eq $Retired.ServiceID}
                                $tmp0 = [pscustomobject]@{
                                        'RetiredFeature'            = $RetiredServiceID.RetiringFeature
                                        'RetiredDate'               = $RetiredServiceID.RetirementDate 
                                    }
                                $tmp0
                            }
                        $RetiringFeature = if ($RetiredFeature.RetiredFeature.count -gt 1) { $RetiredFeature.RetiredFeature | ForEach-Object { $_ + ' ,' } }else { $RetiredFeature.RetiredFeature}
                        $RetiringFeature = [string]$RetiringFeature
                        $RetiringFeature = if ($RetiringFeature -like '* ,*') { $RetiringFeature -replace ".$" }else { $RetiringFeature }

                        $RetiringDate = if ($RetiredFeature.RetiredDate.count -gt 1) { $RetiredFeature.RetiredDate | ForEach-Object { $_ + ' ,' } }else { $RetiredFeature.RetiredDate}
                        $RetiringDate = [string]$RetiringDate
                        $RetiringDate = if ($RetiringDate -like '* ,*') { $RetiringDate -replace ".$" }else { $RetiringDate }
                    }
                else 
                    {
                        $RetiringFeature = $null
                        $RetiringDate = $null
                    }
                $Tags = if(![string]::IsNullOrEmpty($1.tags.psobject.properties)){$1.tags.psobject.properties}else{'0'}
                $ingress = if(![string]::IsNullOrEmpty($data.configuration.ingress)){$true}else{$false}
                $dapr = if(![string]::IsNullOrEmpty($data.configuration.dapr)){$true}else{$false}
                $secrets = if(![string]::IsNullOrEmpty($data.configuration.secrets)){$data.configuration.secrets.count}else{0}
                $Env = $data.environmentId.split('/')[8]
                $data
                foreach ($2 in $data.template) {
                        foreach ($Tag in $Tags) {
                            $obj = @{
                                'ID'                        = $1.id;
                                'Subscription'              = $sub1.Name;
                                'Resource Group'            = $1.RESOURCEGROUP;
                                'Name'                      = $1.NAME;
                                'Location'                  = $1.LOCATION;
                                'Retiring Feature'          = $RetiringFeature;
                                'Retiring Date'             = $RetiringDate;
                                'Running Status'            = $data.runningStatus;
                                'Container App Environment' = $Env;
                                'Workload Profile'          = $data.workloadProfileName;  
                                'Ingress'                   = $ingress;
                                'Ingress Port'              = $data.configuration.ingress.targetPort; 
                                'External Ingress'          = $data.configuration.ingress.external;
                                'Insecure Connections'      = $data.configuration.ingress.allowInsecure;
                                'Ingress Transport'         = $data.configuration.ingress.transport;
                                'Dapr'                      = $dapr;
                                'Secrets'                   = [string]$secrets;
                                'Container'                 = $2.containers.name;
                                'CPU Cores'                 = $2.containers.resources.cpu;
                                'Memory Size (Gi)'          = $2.containers.resources.memory;
                                'Ephemeral Storage (Gi)'    = $2.containers.resources.ephemeralStorage;
                                'Container Image'           = $2.containers.image;
                                'Resource U'                = $ResUCount;
                                'Tag Name'                  = [string]$Tag.Name;
                                'Tag Value'                 = [string]$Tag.Value
                            }
                            $obj
                            if ($ResUCount -eq 1) { $ResUCount = 0 } 
                        }                    
                }
            }
            $tmp
        }
}

<######## Resource Excel Reporting Begins Here ########>

Else
{
    <######## $SmaResources.(RESOURCE FILE NAME) ##########>

    if($SmaResources)
    {
        $TableName = ('ContsTb_'+($SmaResources.'Resource U').count)
        $Style = New-ExcelStyle -HorizontalAlignment Center -AutoSize -NumberFormat '0'

        $condtxt = @()
        #Retirement
        $condtxt += New-ConditionalText -Range E2:E100 -ConditionalType ContainsText
        #External Ingress
        $condtxt += New-ConditionalText true -Range L:L -ConditionalType ContainsText
        #Allow Insecure
        $condtxt += New-ConditionalText true -Range M:M -ConditionalType ContainsText

        $Exc = New-Object System.Collections.Generic.List[System.Object]
        $Exc.Add('Subscription')
        $Exc.Add('Resource Group')
        $Exc.Add('Name')
        $Exc.Add('Location')
        $Exc.Add('Retiring Feature')
        $Exc.Add('Retiring Date')
        $Exc.Add('Running Status')
        $Exc.Add('Container App Environment')
        $Exc.Add('Workload Profile')
        $Exc.Add('Ingress')
        $Exc.Add('Ingress Port')
        $Exc.Add('External Ingress')
        $Exc.Add('Insecure Connections')
        $Exc.Add('Ingress Transport')
        $Exc.Add('Dapr')
        $Exc.Add('Secrets')
        $Exc.Add('Container')
        $Exc.Add('CPU Cores')
        $Exc.Add('Memory Size (Gi)')
        $Exc.Add('Ephemeral Storage (Gi)')
        $Exc.Add('Container Image')
        if($InTag)
            {
                $Exc.Add('Tag Name')
                $Exc.Add('Tag Value') 
            }

        [PSCustomObject]$SmaResources | 
        ForEach-Object { $_ } | Select-Object $Exc | 
        Export-Excel -Path $File -WorksheetName 'Container Apps' -AutoSize -MaxAutoSizeRows 100 -TableName $TableName -ConditionalText $condtxt -TableStyle $tableStyle -Style $Style

    }
}