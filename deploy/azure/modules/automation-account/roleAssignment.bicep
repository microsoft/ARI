targetScope = 'subscription'

param automationAccountId string
param automationAccountPrincipalId string
param customRoleDefinitionId string

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(automationAccountId, customRoleDefinitionId)
  properties: {
    roleDefinitionId: customRoleDefinitionId
    principalId: automationAccountPrincipalId
    principalType: 'ServicePrincipal'
  }
}
