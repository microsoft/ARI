@description('Subscription - Platform DevTest')

using '../main.bicep'

param abbr = 'plat-dev-weu-ari'
param abbrsa = 'platdevweuari'

param locations = 'westeurope'

param resourceGroupName = '${abbr}-rg'

param automationAccountName = '${abbr}-aa'

param storageAccountName = '${abbrsa}sa'

param runbookName = '${abbr}-rb'

param scheduleName = '${abbr}-sch'

param roleName = '${abbr}-customRole'
