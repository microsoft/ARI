targetScope = 'subscription'

@description('Parameters for the Role Assignment')
param actions array = [
  '*/read'
  'Microsoft.Storage/storageAccounts/blobServices/containers/*'
]
param roleName string

var roleDefName = guid(roleName)

// @description('Contributor Role Assignment for the User-Assigned Managed Identity')
resource customRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' = {
  name: roleDefName
  properties: {
    roleName: roleName
    type: 'customRole'
    permissions: [
      {
        actions: actions
      }
    ]
    assignableScopes: [
      subscription().id
    ]
  }
}

output customRoleDefinitionId string = customRoleDefinition.id
