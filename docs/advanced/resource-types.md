# Supported Azure Resource Types

Azure Resource Inventory (ARI) supports a wide range of Azure resource types. This page provides a comprehensive list of all supported resource types organized by resource provider category.

Each section corresponds to a subfolder within the `Modules/Public/InventoryModules` directory in the ARI codebase, and represents an Azure Resource Provider Category as defined in [Microsoft's documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/azure-services-resource-providers).

## Supported Provider Categories

- [AI](#ai)
- [Analytics](#analytics)
- [Compute](#compute)
- [Container](#container)
- [Database](#database)
- [Hybrid](#hybrid)
- [Integration](#integration)
- [IoT](#iot)
- [Management](#management)
- [Monitoring](#monitoring)
- [Network](#network)
- [Security](#security)
- [Storage](#storage)
- [Web](#web)

## AI

| Resource Type | Kind |
|---------------|------|
| `microsoft.cognitiveservices/accounts` | `AIServices` |
| `microsoft.cognitiveservices/accounts` | `ComputerVision` |
| `microsoft.cognitiveservices/accounts` | `ContentModerator` |
| `microsoft.cognitiveservices/accounts` | `ContentSafety` |
| `microsoft.cognitiveservices/accounts` | `CustomVision` |
| `microsoft.cognitiveservices/accounts` | `Face` |
| `microsoft.cognitiveservices/accounts` | `FormRecognizer` |
| `microsoft.cognitiveservices/accounts` | `HealthInsights` |
| `microsoft.cognitiveservices/accounts` | `ImmersiveReader` |
| `microsoft.cognitiveservices/accounts` | `SpeechServices` |
| `microsoft.cognitiveservices/accounts` | `TextAnalytics` |
| `microsoft.cognitiveservices/accounts` | `TextTranslation` |
| `microsoft.machinelearningservices/workspaces` |  |
| `microsoft.search/searchservices` | |

## Analytics

| Resource Type |
|---------------|
| `microsoft.databricks/workspaces` |
| `microsoft.kusto/clusters` |
| `microsoft.eventhub/namespaces` |
| `microsoft.purview/accounts` |
| `microsoft.streamanalytics/clusters` |
| `microsoft.streamanalytics/streamingjobs` |
| `microsoft.synapse/workspaces` |

## Compute

| Resource Type |
|---------------|
| `microsoft.compute/availabilitysets` |
| `microsoft.desktopvirtualization/hostpools` |
| `microsoft.desktopvirtualization/hostpools/sessionhosts` |
| `microsoft.classiccompute/domainnames` |
| `microsoft.compute/virtualmachines` |
| `microsoft.compute/virtualmachines/extensions` |
| `microsoft.compute/virtualmachinescalesets` |
| `microsoft.compute/disks` |
| `Microsoft.AVS/privateClouds` |

## Container

| Resource Type |
|---------------|
| `microsoft.containerservice/managedclusters` |
| `microsoft.redhatopenshift/openshiftclusters` |
| `microsoft.app/containerapps` |
| `microsoft.app/managedenvironments` |
| `microsoft.containerinstance/containergroups` |
| `microsoft.containerregistry/registries` |

## Database

| Resource Type |
|---------------|
| `microsoft.documentdb/databaseaccounts` |
| `microsoft.dbformariadb/servers` |
| `microsoft.dbformysql/servers` |
| `microsoft.DBforMySQL/flexibleServers` |
| `microsoft.dbforpostgresql/servers` |
| `microsoft.DBforPostgreSQL/flexibleServers` |
| `microsoft.cache/redis` |
| `microsoft.cache/redisenterprise` |
| `microsoft.sql/servers/databases` |
| `microsoft.sql/managedInstances` |
| `microsoft.sql/managedinstances/databases` |
| `microsoft.sql/servers/elasticPools` |
| `microsoft.sql/servers` |
| `microsoft.sqlvirtualmachine/sqlvirtualmachines` |

## Hybrid

| Resource Type |
|---------------|
| `microsoft.hybridcompute/machines` |

## Integration

| Resource Type |
|---------------|
| `microsoft.apimanagement/service` |
| `microsoft.servicebus/namespaces` |

## IoT

| Resource Type |
|---------------|
| `microsoft.devices/iothubs` |

## Management

| Resource Type |
|---------------|
| `microsoft.automation/automationaccounts` |
| `microsoft.automation/automationaccounts/runbooks` |
| `microsoft.recoveryservices/vaults/backuppolicies` |
| `microsoft.recoveryservices/vaults/backupfabrics/protectioncontainers/protecteditems` |
| `microsoft.recoveryservices/vaults` |

## Monitoring

| Resource Type |
|---------------|
| `microsoft.insights/components` |
| `microsoft.operationalinsights/workspaces` |

## Network

| Resource Type |
|---------------|
| `microsoft.network/bastionhosts` |
| `microsoft.network/connections` |
| `microsoft.network/expressroutecircuits` |
| `microsoft.network/loadbalancers` |
| `microsoft.network/natgateways` |
| `microsoft.network/dnszones` |
| `microsoft.network/routetables` |
| `microsoft.network/trafficmanagerprofiles` |
| `microsoft.network/virtualnetworks` |
| `microsoft.network/applicationgateways` |
| `microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies` |
| `microsoft.network/azurefirewalls` |
| `microsoft.network/firewallpolicies` |
| `microsoft.network/firewallpolicies/rulecollectiongroups` |
| `microsoft.network/frontdoors` |
| `microsoft.network/networkinterfaces` |
| `microsoft.network/networksecuritygroups` |
| `microsoft.network/networkwatchers/flowlogs` |
| `microsoft.network/privatednszones` |
| `microsoft.network/privatednszones/virtualnetworklinks` |
| `microsoft.network/privateendpoints` |
| `microsoft.network/publicipaddresses` |
| `microsoft.network/virtualnetworkgateways` |
| `microsoft.network/virtualwans` |
| `microsoft.network/virtualhubs` |
| `microsoft.network/vpnsites` |

## Security

| Resource Type |
|---------------|
| `microsoft.keyvault/vaults` |

## Storage

| Resource Type |
|---------------|
| `microsoft.storage/storageaccounts` |
| `microsoft.storagecache/caches` |
| `microsoft.datacatalog/catalogs` |

## Web

| Resource Type |
|---------------|
| `microsoft.web/sites` |
| `microsoft.web/sites/slots` |
| `microsoft.web/serverfarms` |
| `microsoft.web/hostingenvironments` |
| `microsoft.web/hostingenvironments/workerpools` | 