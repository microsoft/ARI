targetScope = 'subscription'

@description('Name of the Automation Account')
param resourceGroupName string

@description('Location for the resources')
param locations string

@description('Create a resource group for the automation account')
resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: resourceGroupName
  location: locations
}

output resourceGroup string = resourceGroup.name
