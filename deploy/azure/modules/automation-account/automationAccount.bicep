@description('Parameters for the Automation Account')
param automationAccountName string
param locations string
param runbookName string
param scheduleName string

@description('Creates an Automation Account')
resource automationAccount 'Microsoft.Automation/automationAccounts@2023-11-01' = {
  name: automationAccountName
  location: locations
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    sku: {
      name: 'Free'
    }
  }
}

@description('Creates an Automation Account Runbook')
resource runbook 'Microsoft.Automation/automationAccounts/runbooks@2023-11-01' = {
  name: runbookName
  location: locations
  parent: automationAccount
  properties: {
    runbookType: 'PowerShell'
    logProgress: true
    logVerbose: true
    description: 'Azure Resource Inventory Runbook'
  }
}

@description('Creates an Automation Account Schedule')
resource schedule 'Microsoft.Automation/automationAccounts/schedules@2023-11-01' = {
  name: scheduleName
  parent: automationAccount
  properties: {
    frequency: 'Month'
    interval: 1
    advancedSchedule: {
      monthlyOccurrences: [
        { occurrence: -1, day: 'Friday' }
      ]
    }
    description: 'Schedule for the Runbook - ${runbookName}'
    startTime: '2025-03-28 20:00'
    timeZone: 'UTC'
  }
}

output automationAccountId string = automationAccount.id
output automationAccountPrincipalId string = automationAccount.identity.principalId
output automationAccountName string = automationAccount.name
