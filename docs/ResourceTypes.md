# Azure Resource Inventory - Supported Azure Resource Types

This document provides an overview of the Azure Resource Types supported by the Azure Resource Inventory (ARI). Each section corresponds to a subfolder within the `Modules/Public/InventoryModules` directory, listing the resource types and their respective paths as defined in the `.ps1` files. Each subfolder represents an Azure Resource Provider Category as Microsoft's documentation: [What are the resource providers for Azure services](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/azure-services-resource-providers)

## Supported Providers Categories
- [AI](AI)
- [Analytics](Analytics)
- [Compute](Compute)
- [Container](Container)
- [Database](Database)
- [Hybrid](Hybrid)
- [Integration](Integration)
- [IoT](IoT)
- [Management](Management)
- [Monitoring](Monitoring)
- [Network](Network)
- [Security](Security)
- [Storage](Storage)
- [Web](Web)

---

## AI

| Path                                      | Resource Type          | Kind                   |
|-------------------------------------------|------------------------|------------------------|
| `Modules/Public/InventoryModules/AI/AzureAI.ps1` | `microsoft.cognitiveservices/accounts` | `AIServices` |
| `Modules/Public/InventoryModules/AI/ComputerVision.ps1` | `microsoft.cognitiveservices/accounts` | `ComputerVision` |
| `Modules/Public/InventoryModules/AI/ContentModerator.ps1` | `microsoft.cognitiveservices/accounts` | `ContentModerator` |
| `Modules/Public/InventoryModules/AI/ContentSafety.ps1` | `microsoft.cognitiveservices/accounts` | `ContentSafety` |
| `Modules/Public/InventoryModules/AI/CustomVision.ps1` | `microsoft.cognitiveservices/accounts` | `CustomVision` |
| `Modules/Public/InventoryModules/AI/FaceAPI.ps1` | `microsoft.cognitiveservices/accounts` | `Face` |
| `Modules/Public/InventoryModules/AI/FormRecognizer.ps1` | `microsoft.cognitiveservices/accounts` | `FormRecognizer` |
| `Modules/Public/InventoryModules/AI/HealthInsights.ps1` | `microsoft.cognitiveservices/accounts` | `HealthInsights` |
| `Modules/Public/InventoryModules/AI/ImmersiveReader.ps1` | `microsoft.cognitiveservices/accounts` | `ImmersiveReader` |
| `Modules/Public/InventoryModules/AI/SpeechServices.ps1` | `microsoft.cognitiveservices/accounts` | `SpeechServices` |
| `Modules/Public/InventoryModules/AI/TextAnalytics.ps1` | `microsoft.cognitiveservices/accounts` | `TextAnalytics` |
| `Modules/Public/InventoryModules/AI/Translator.ps1` | `microsoft.cognitiveservices/accounts` | `TextTranslation` |
| `Modules/Public/InventoryModules/AI/MachineLearning.ps1` | `microsoft.machinelearningservices/workspaces` |  |
| `Modules/Public/InventoryModules/AI/SearchServices.ps1` | `microsoft.search/searchservices` | |

---

## Analytics

| Path                                      | Resource Type          |
|-------------------------------------------|------------------------|
| `Modules/Public/InventoryModules/Analytics/Databricks.ps1` | `microsoft.databricks/workspaces` |
| `Modules/Public/InventoryModules/Analytics/DataExplorerCluster.ps1` | `microsoft.kusto/clusters` |
| `Modules/Public/InventoryModules/Analytics/EvtHub.ps1` | `microsoft.eventhub/namespaces` |
| `Modules/Public/InventoryModules/Analytics/Purview.ps1` | `microsoft.purview/accounts` |
| `Modules/Public/InventoryModules/Analytics/Streamanalytics.ps1` | `microsoft.streamanalytics/clusters` |
| `Modules/Public/InventoryModules/Analytics/Streamanalytics.ps1` | `microsoft.streamanalytics/streamingjobs` |
| `Modules/Public/InventoryModules/Analytics/Synapse.ps1` | `microsoft.synapse/workspaces` |

---

## Compute

| Path                                      | Resource Type          |
|-------------------------------------------|------------------------|
| `Modules/Public/InventoryModules/Compute/AvailabilitySets.ps1` | `microsoft.compute/availabilitysets` |
| `Modules/Public/InventoryModules/Compute/AVD.ps1` | `microsoft.desktopvirtualization/hostpools` |
| `Modules/Public/InventoryModules/Compute/AVD.ps1` | `microsoft.desktopvirtualization/hostpools/sessionhosts` |
| `Modules/Public/InventoryModules/Compute/CloudServices.ps1` | `microsoft.classiccompute/domainnames` |
| `Modules/Public/InventoryModules/Compute/VirtualMachine.ps1` | `microsoft.compute/virtualmachines` |
| `Modules/Public/InventoryModules/Compute/VirtualMachine.ps1` | `microsoft.compute/virtualmachines/extensions` |
| `Modules/Public/InventoryModules/Compute/VirtualMachineScaleSet.ps1` | `microsoft.compute/virtualmachinescalesets` |
| `Modules/Public/InventoryModules/Compute/VMDisk.ps1` | `microsoft.compute/disks` |
| `Modules/Public/InventoryModules/Compute/VMWare.ps1` | `Microsoft.AVS/privateClouds` |

---

## Container

| Path                                      | Resource Type          |
|-------------------------------------------|------------------------|
| `Modules/Public/InventoryModules/Container/AKS.ps1` | `microsoft.containerservice/managedclusters` |
| `Modules/Public/InventoryModules/Container/ARO.ps1` | `microsoft.redhatopenshift/openshiftclusters` |
| `Modules/Public/InventoryModules/Container/ContainerApp.ps1` | `microsoft.app/containerapps` |
| `Modules/Public/InventoryModules/Container/ContainerAppEnv.ps1` | `microsoft.app/managedenvironments` |
| `Modules/Public/InventoryModules/Container/ContainerGroups.ps1` | `microsoft.containerinstance/containergroups` |
| `Modules/Public/InventoryModules/Container/ContainerRegistries.ps1` | `microsoft.containerregistry/registries` |




---

## Database

| Path                                      | Resource Type          |
|-------------------------------------------|------------------------|
| `Modules/Public/InventoryModules/Database/CosmosDB.ps1` | `microsoft.documentdb/databaseaccounts` |
| `Modules/Public/InventoryModules/Database/MariaDB.ps1` | `microsoft.dbformariadb/servers` |
| `Modules/Public/InventoryModules/Database/MySQL.ps1` | `microsoft.dbformysql/servers` |
| `Modules/Public/InventoryModules/Database/MySQLFlexible.ps1` | `microsoft.DBforMySQL/flexibleServers` |
| `Modules/Public/InventoryModules/Database/POSTGRE.ps1` | `microsoft.dbforpostgresql/servers` |
| `Modules/Public/InventoryModules/Database/POSTGREFlexible.ps1` | `microsoft.DBforPostgreSQL/flexibleServers` |
| `Modules/Public/InventoryModules/Database/RedisCache.ps1` | `microsoft.cache/redis` |
| `Modules/Public/InventoryModules/Database/RedisCache.ps1` | `microsoft.cache/redisenterprise` |
| `Modules/Public/InventoryModules/Database/SQLDB.ps1` | `microsoft.sql/servers/databases` |
| `Modules/Public/InventoryModules/Database/SQLMI.ps1` | `microsoft.sql/managedInstances` |
| `Modules/Public/InventoryModules/Database/SQLMIDB.ps1` | `microsoft.sql/managedinstances/databases` |
| `Modules/Public/InventoryModules/Database/SQLPOOL.ps1` | `microsoft.sql/servers/elasticPools` |
| `Modules/Public/InventoryModules/Database/SQLSERVER.ps1` | `microsoft.sql/servers` |
| `Modules/Public/InventoryModules/Database/SQLVM.ps1` | `microsoft.sqlvirtualmachine/sqlvirtualmachines` |

---

## Hybrid

| Path                                      | Resource Type          |
|-------------------------------------------|------------------------|
| `Modules/Public/InventoryModules/Hybrid/ARCServers.ps1` | `microsoft.hybridcompute/machines` |

---

## Integration

| Path                                      | Resource Type          |
|-------------------------------------------|------------------------|
| `Modules/Public/InventoryModules/Integration/APIM.ps1` | `microsoft.apimanagement/service` |
| `Modules/Public/InventoryModules/Integration/ServiceBUS.ps1` | `microsoft.servicebus/namespaces` |

---

## IoT

| Path                                      | Resource Type          |
|-------------------------------------------|------------------------|
| `Modules/Public/InventoryModules/IoT/IOTHubs.ps1` | `microsoft.devices/iothubs` |

---

## Management

| Path                                      | Resource Type          |
|-------------------------------------------|------------------------|
| `Modules/Public/InventoryModules/Management/AutomationAccounts.ps1` | `microsoft.automation/automationaccounts` |
| `Modules/Public/InventoryModules/Management/AutomationAccounts.ps1` | `microsoft.automation/automationaccounts/runbooks` |
| `Modules/Public/InventoryModules/Management/Backup.ps1` | `microsoft.recoveryservices/vaults/backuppolicies` |
| `Modules/Public/InventoryModules/Management/Backup.ps1` | `microsoft.recoveryservices/vaults/backupfabrics/protectioncontainers/protecteditems` |
| `Modules/Public/InventoryModules/Management/RecoveryVault.ps1` | `microsoft.recoveryservices/vaults` |

---

## Monitoring

| Path                                      | Resource Type          |
|-------------------------------------------|------------------------|
| `Modules/Public/InventoryModules/Monitoring/AppInsights.ps1` | `microsoft.insights/components` |
| `Modules/Public/InventoryModules/Monitoring/Workspaces.ps1` | `microsoft.operationalinsights/workspaces` |

---

## Network

| Path                                      | Resource Type          |
|-------------------------------------------|------------------------|
| `Modules/Public/InventoryModules/Network_1/BastionHosts.ps1` | `microsoft.network/bastionhosts` |
| `Modules/Public/InventoryModules/Network_1/Connections.ps1` | `microsoft.network/connections` |
| `Modules/Public/InventoryModules/Network_1/ExpressRoute.ps1` | `microsoft.network/expressroutecircuits` |
| `Modules/Public/InventoryModules/Network_1/LoadBalancer.ps1` | `microsoft.network/loadbalancers` |
| `Modules/Public/InventoryModules/Network_1/NATGateway.ps1` | `microsoft.network/natgateways` |
| `Modules/Public/InventoryModules/Network_1/PublicDNS.ps1` | `microsoft.network/dnszones` |
| `Modules/Public/InventoryModules/Network_1/RouteTables.ps1` | `microsoft.network/routetables` |
| `Modules/Public/InventoryModules/Network_1/TrafficManager.ps1` | `microsoft.network/trafficmanagerprofiles` |
| `Modules/Public/InventoryModules/Network_1/VirtualNetwork.ps1` | `microsoft.network/virtualnetworks` |
| `Modules/Public/InventoryModules/Network_2/ApplicationGateways.ps1` | `microsoft.network/applicationgateways` |
| `Modules/Public/InventoryModules/Network_2/ApplicationGateways.ps1` | `microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies` |
| `Modules/Public/InventoryModules/Network_2/AzureFirewall.ps1` | `microsoft.network/azurefirewalls` |
| `Modules/Public/InventoryModules/Network_2/AzureFirewall.ps1` | `microsoft.network/firewallpolicies` |
| `Modules/Public/InventoryModules/Network_2/AzureFirewall.ps1` | `microsoft.network/firewallpolicies/rulecollectiongroups` |
| `Modules/Public/InventoryModules/Network_2/Frontdoor.ps1` | `microsoft.network/frontdoors` |
| `Modules/Public/InventoryModules/Network_2/NetworkInterface.ps1` | `microsoft.network/networkinterfaces` |
| `Modules/Public/InventoryModules/Network_2/NetworkSecurityGroup.ps1` | `microsoft.network/networksecuritygroups` |
| `Modules/Public/InventoryModules/Network_2/NetworkSecurityGroup.ps1` | `microsoft.network/networkwatchers/flowlogs` |
| `Modules/Public/InventoryModules/Network_2/PrivateDNS.ps1` | `microsoft.network/privatednszones` |
| `Modules/Public/InventoryModules/Network_2/PrivateDNS.ps1` | `microsoft.network/privatednszones/virtualnetworklinks` |
| `Modules/Public/InventoryModules/Network_2/PrivateEndpoint.ps1` | `microsoft.network/privateendpoints` |
| `Modules/Public/InventoryModules/Network_2/PublicIP.ps1` | `microsoft.network/publicipaddresses` |
| `Modules/Public/InventoryModules/Network_2/VirtualNetworkGateways.ps1` | `microsoft.network/virtualnetworkgateways` |
| `Modules/Public/InventoryModules/Network_2/VirtualWAN.ps1` | `microsoft.network/virtualwans` |
| `Modules/Public/InventoryModules/Network_2/VirtualWAN.ps1` | `microsoft.network/virtualhubs` |
| `Modules/Public/InventoryModules/Network_2/VirtualWAN.ps1` | `microsoft.network/vpnsites` |

---

## Security

| Path                                      | Resource Type          |
|-------------------------------------------|------------------------|
| `Modules/Public/InventoryModules/Security/Vault.ps1` | `microsoft.keyvault/vaults` |

---

## Storage

| Path                                      | Resource Type          |
|-------------------------------------------|------------------------|
| `Modules/Public/InventoryModules/Storage/NetApp.ps1` | `Microsoft.NetApp/netAppAccounts/capacityPools/volumes` |
| `Modules/Public/InventoryModules/Storage/StorageAccounts.ps1` | `microsoft.storage/storageaccounts` |

---

## Web

| Path                                      | Resource Type          |
|-------------------------------------------|------------------------|
| `Modules/Public/InventoryModules/Web/APPServicePlan.ps1` | `microsoft.web/serverfarms` |
| `Modules/Public/InventoryModules/Web/APPServices.ps1` | `microsoft.web/sites` |

---

> **Note:** The resource types listed above are extracted from the `.ps1` files within the respective subfolders. We work hard to ensure the data present in this document is up to date, but is possible some resource types were added to the inventory and are still pending to be added in here.
