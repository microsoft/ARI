targetScope = 'managementGroup'

param automationAccountId string
param automationAccountPrincipalId string
param readerID string

@description('Creates Automation Account Role Assignment for Reader')
resource roleAssignmentReader 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(automationAccountId, 'Reader')
  properties: {
    roleDefinitionId: readerID
    principalId: automationAccountPrincipalId
    principalType: 'ServicePrincipal'
  }
}
