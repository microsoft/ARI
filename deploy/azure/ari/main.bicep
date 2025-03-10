targetScope = 'subscription'

@description('parameters from parameters.bicepparam')
param abbr string
param abbrsa string
param locations string
param resourceGroupName string
param automationAccountName string
param storageAccountName string
param runbookName string
param scheduleName string
param roleName string

module resourceGroupModule '../modules/resource-group/resourceGroup.bicep' = {
  name: 'resourceGroupModule'
  params: {
    resourceGroupName: resourceGroupName
    locations: locations
  }
}

module automationAccountModule '../modules/automation-account/automationAccount.bicep' = {
  name: 'automationAccountModule'
  scope: resourceGroup(resourceGroupName)
  params: {
      locations: locations
      automationAccountName: automationAccountName
      runbookName: runbookName
      scheduleName: scheduleName
  }
  dependsOn: [
    resourceGroupModule
  ]
}

module automationAccountPSModules '../modules/automation-account/automationAccountPSModules.bicep' = {
  name: 'automationAccountPSModules'
  scope: resourceGroup(resourceGroupName)
  params: {
    automationAccountName: automationAccountName
  }
  dependsOn: [
    resourceGroupModule
  ]
}

module customRoleModule '../modules/automation-account/customRole.bicep' = {
  name: 'customRoleModule'
  params: {
    roleName: roleName
  }
}

module roleAssignmentModule '../modules/automation-account/roleAssignment.bicep' = {
  name: 'roleAssignmentModule'
  params: {
    automationAccountId: automationAccountModule.outputs.automationAccountId
    automationAccountPrincipalId: automationAccountModule.outputs.automationAccountPrincipalId
    customRoleDefinitionId: customRoleModule.outputs.customRoleDefinitionId
  }
}

module storageAccountModule '../modules/storage-account/storageAccount.bicep' = {
  name: 'storageAccountModule'
  scope: resourceGroup(resourceGroupName)
  params: {
    storageAccountName: storageAccountName
    locations: locations
  }
  dependsOn: [
    resourceGroupModule
  ]
}
