@description('Subscription - Platform Prod')

using '../main.bicep'

param abbr = 'plat-prod-weu-ari'
param abbrsa = 'platprodweuari'

param locations = 'westeurope'

param resourceGroupName = '${abbr}-rg'

param automationAccountName = '${abbr}-aa'

param storageAccountName = '${abbrsa}sa'

param runbookName = '${abbr}-rb'

param scheduleName = '${abbr}-sch'

param roleName = '${abbr}-customRole'
