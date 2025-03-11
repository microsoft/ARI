# Variables
$resourceGroupName = 'plat-prod-weu-ari-rg'
$automationAccountName = 'plat-prod-weu-ari-aa'
$subscriptionId = 'c2862439-f7c2-4c48-b830-beac83fc1888'
$runbookPath = '.\invoke-ari.ps1'
$runbookName = 'plat-prod-weu-ari-rb'
$scheduleName = 'plat-prod-weu-ari-sch'

# Connect to Azure and Set subscription
Connect-AzAccount -SubscriptionId $subscriptionId

# Replace the content of the already created runbook
az automation runbook replace-content `
  --subscription $subscriptionId `
  --resource-group $resourceGroupName `
  --automation-account-name $automationAccountName `
  --name $runbookName `
  --content @$runbookPath `

# Publish the already created runbook
az automation runbook publish `
  --subscription $subscriptionId `
  --resource-group $resourceGroupName `
  --automation-account-name $automationAccountName `
  --name $runbookName `

# Register the already created Runbook with the already created Schedule
Register-AzAutomationScheduledRunbook `
    -ResourceGroupName $resourceGroupName `
    -AutomationAccountName $automationAccountName `
    -RunbookName $runbookName `
    -ScheduleName $scheduleName `

Write-Host "Runbook '$runbookName' has been successfully registered with the schedule '$scheduleName'."