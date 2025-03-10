@description('Parameters for the Automation Account PSModules')
param automationAccountName string

@description('Creates Automation Account PSModules')
resource azureResourceInventoryModule 'Microsoft.Automation/automationAccounts/modules@2023-11-01' = {
  name: '${automationAccountName}/AzureResourceInventory'
  properties: {
    contentLink: {
      uri: 'https://www.powershellgallery.com/api/v2/package/AzureResourceInventory'
    }
  }
}

resource importExcelModule 'Microsoft.Automation/automationAccounts/modules@2023-11-01' = {
  name: '${automationAccountName}/ImportExcel'
  properties: {
    contentLink: {
      uri: 'https://www.powershellgallery.com/api/v2/package/ImportExcel'
    }
  }
}

resource azResourceGraphModule 'Microsoft.Automation/automationAccounts/modules@2023-11-01' = {
  name: '${automationAccountName}/Az.ResourceGraph'
  properties: {
    contentLink: {
      uri: 'https://www.powershellgallery.com/api/v2/package/Az.ResourceGraph'
    }
  }
}

resource azAccountsModule 'Microsoft.Automation/automationAccounts/modules@2023-11-01' = {
  name: '${automationAccountName}/Az.Accounts'
  properties: {
    contentLink: {
      uri: 'https://www.powershellgallery.com/api/v2/package/Az.Accounts'
    }
  }
}

resource azComputeModule 'Microsoft.Automation/automationAccounts/modules@2023-11-01' = {
  name: '${automationAccountName}/Az.Compute'
  properties: {
    contentLink: {
      uri: 'https://www.powershellgallery.com/api/v2/package/Az.Compute'
    }
  }
}

resource powershellGetModule 'Microsoft.Automation/automationAccounts/modules@2023-11-01' = {
  name: '${automationAccountName}/PowershellGet'
  properties: {
    contentLink: {
      uri: 'https://www.powershellgallery.com/api/v2/package/PowershellGet'
    }
  }
}

resource threadJobModule 'Microsoft.Automation/automationAccounts/modules@2023-11-01' = {
  name: '${automationAccountName}/ThreadJob'
  properties: {
    contentLink: {
      uri: 'https://www.powershellgallery.com/api/v2/package/ThreadJob'
    }
  }
}
