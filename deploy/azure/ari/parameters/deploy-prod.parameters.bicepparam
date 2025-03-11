@description('Subscription - Platform Prod')
@description('parameters to pass to main.bicep')

using '../main.bicep'

param abbr = 'plat-prod-weu-ari'

param locations = 'westeurope'

param storageBlobDataContributorID = '/providers/Microsoft.Authorization/roleDefinitions/ba92f5b4-2d11-453d-a403-e96b0029c9fe'
param readerID = '/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7'

// param managementGroupID = 'ac934dd1-86d1-4053-a485-ad39d829abad'
param managementGroupID = 'mg-test'
param subscriptionID = 'c2862439-f7c2-4c48-b830-beac83fc1888'

// Dynamically construct resource names based on `abbr` to match `main.bicep`
param resourceGroupName = '${abbr}-rg'
param automationAccountName = '${abbr}-aa'
param storageAccountName = 'platprodweuarisa'
param runbookName = '${abbr}-rb'
param scheduleName = '${abbr}-sch'
