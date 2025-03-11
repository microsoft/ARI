@description('Parameters for the Storage Account and Role Assignment')
param storageAccountName string
param automationAccountName string
param automationAccountPrincipalId string
param locations string
param storageBlobDataContributorID string

@description('Creates a Storage Account')
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: locations
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: true
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
      ipRules: []
      virtualNetworkRules: []
    }
  }
}

@description('Assigns the Storage Blob Data Contributor role to the Automation Account against the Storage Account')
resource roleAssignmentStorage 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(automationAccountName, 'StorageBlobDataContributor')
  scope: storageAccount
  properties: {
    roleDefinitionId: storageBlobDataContributorID
    principalId: automationAccountPrincipalId
    principalType: 'ServicePrincipal'
  }
}

@description('Creates a Blob Service within the Storage Account')
resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  parent: storageAccount
  name: 'default'
}

@description('Creates a Blob Container within the Blob Service')
resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: blobService
  name: 'reports'
  properties: {
    publicAccess: 'Blob'
  }
}

output storageAccountId string = storageAccount.id
