@description('Parameters for the Automation Account PSModules')
param automationAccountName string

@description('Creates Automation Account PSModules - Azure Resource Inventory')
resource azureResourceInventoryModule 'Microsoft.Automation/automationAccounts/modules@2023-11-01' = {
  name: '${automationAccountName}/AzureResourceInventory'
  properties: {
    contentLink: {
      uri: 'https://www.powershellgallery.com/api/v2/package/AzureResourceInventory'
    }
  }
}

@description('Creates Automation Account PSModules - ImportExcel')
resource importExcelModule 'Microsoft.Automation/automationAccounts/modules@2023-11-01' = {
  name: '${automationAccountName}/ImportExcel'
  properties: {
    contentLink: {
      uri: 'https://www.powershellgallery.com/api/v2/package/ImportExcel'
    }
  }
}

@description('Creates Automation Account PSModules - Az.ResourceGraph')
resource azResourceGraphModule 'Microsoft.Automation/automationAccounts/modules@2023-11-01' = {
  name: '${automationAccountName}/Az.ResourceGraph'
  properties: {
    contentLink: {
      uri: 'https://www.powershellgallery.com/api/v2/package/Az.ResourceGraph'
    }
  }
}

@description('Creates Automation Account PSModules - Az.Accounts')
resource azAccountsModule 'Microsoft.Automation/automationAccounts/modules@2023-11-01' = {
  name: '${automationAccountName}/Az.Accounts'
  properties: {
    contentLink: {
      uri: 'https://www.powershellgallery.com/api/v2/package/Az.Accounts'
    }
  }
}

@description('Creates Automation Account PSModules - Az.Compute')
resource azComputeModule 'Microsoft.Automation/automationAccounts/modules@2023-11-01' = {
  name: '${automationAccountName}/Az.Compute'
  properties: {
    contentLink: {
      uri: 'https://www.powershellgallery.com/api/v2/package/Az.Compute'
    }
  }
}

@description('Creates Automation Account PSModules - PowershellGet')
resource powershellGetModule 'Microsoft.Automation/automationAccounts/modules@2023-11-01' = {
  name: '${automationAccountName}/PowershellGet'
  properties: {
    contentLink: {
      uri: 'https://www.powershellgallery.com/api/v2/package/PowershellGet'
    }
  }
}

@description('Creates Automation Account PSModules - ThreadJob')
resource threadJobModule 'Microsoft.Automation/automationAccounts/modules@2023-11-01' = {
  name: '${automationAccountName}/ThreadJob'
  properties: {
    contentLink: {
      uri: 'https://www.powershellgallery.com/api/v2/package/ThreadJob'
    }
  }
}
