# How to run Azure Resource Inventory

<br/>

## Installing ARI
---------------------

```
Install-Module -Name AzureResourceInventory
```

<br/>

<p align="center">
<img src="images/InstallARI.gif">
</p>

<br/>

## Running ARI
---------------------

To run the script just execute "Invoke-ARI" with the regular parameters:

```
Invoke-ARI 
```

<br/>

<p align="center">
<img src="images/RunningARI.gif">
</p>

<br/>

### Parameters
---------------------

| Parameter              | Description                                                                                                 |                            |
|------------------------|-------------------------------------------------------------------------------------------------------------|----------------------------|
| TenantID               | Specify the tenant ID you want to create a Resource Inventory.                                              | `-TenantID <ID>`           |
| SubscriptionID         | Specifies Subscription(s) to be inventoried.                                                                | `-SubscriptionID <ID>`     |
| ManagementGroup        | Specifies the Management Group to be inventoried(all Subscriptions on it)                                   | `-ManagementGroup <ID>`    |  
| Lite                   | Specifies to use only the Import-Excel module and don't create the charts (using Excel's API)               | `-Lite`                    |
| SecurityCenter         | Include Security Center Data.                                                                               | `-SecurityCenter`          |
| SkipAdvisory           | Do not collect Azure Advisory.                                                                              | `-SkipAdvisory`            |
| Automation             | Required when running the script with Automation Account                                                    | `-Automation`              |
| StorageAccount         | Storage Account Name (Required when running the script with Automation Account)                             | `-StorageAccount`          |
| StorageContainer       | Storage Account Container Name (Required when running the script with Automation Account)                   | `-StorageContainer`        |
| IncludeTags            | Include Resource Tags.                                                                                      | `-IncludeTags`             |
| Debug                  | Run in a Debug mode.                                                                                        | `-Debug`                   |
| DiagramFullEnvironment | Network Diagram of the entire environment                                                                   | `-DiagramFullEnvironment`  |
| Diagram                | Create a Draw.IO Diagram.                                                                                   | `-Diagram`                 |
| SkipDiagram            | To skip the diagrams creation                                                                               | `-SkipDiagram`             |
| DeviceLogin            | Authenticating on Azure using the Device login approach                                                     | `-DeviceLogin`             |
| AzureEnvironment       | Choose between Azure environments <br> > Registered Azure Clouds. Use `az cloud list` to get the list       | `-AzureEnvironment <NAME>` |
| ReportName             | Change the Default Name of the report. `Default name: AzureResourceInventory`                               | `-ReportName <NAME>`       |
| ReportDir              | Change the Default path of the report.                                                                      | `-ReportDir "<Path>"`      |
| Online                 | Use Online Modules. Scan Modules diretly in GitHub ARI Repository                                           | `-Online`                  |
| ResourceGroup          | Specifies one unique Resource Group to be inventoried, This parameter requires the -SubscriptionID to work. | `-ResourceGroup <NAME>`    |
| TagKey                 | Specifies the tag key to be inventoried, This parameter requires the `-SubscriptionID` to work.             | `-TagKey <NAME>`           |
| TagValue               | Specifies the tag value be inventoried, This parameter requires the `-SubscriptionID` to work.              | `-TagValue <NAME>`         |
| QuotaUsage             | Quota Usage                                                                                                 | `-QuotaUsage`              |

<br/>

#### Examples
- For CloudShell:
  ```bash
  />./Invoke-ARI -Debug
  ```
- Powershell Desktop:
  ```bash
  />./Invoke-ARI -TenantID <Azure Tenant ID> 
  ```
  > If you do not specify the Subscription Resource Inventory will be performed on all subscriptions for the selected tenant.
  > To perform the inventory in a specific Tenant and subscription use `-TenantID` and `-SubscriptionID` parameter
  ```bash
    />./Invoke-ARI -TenantID <Azure Tenant ID> -SubscriptionID <Subscription ID>
  ```
- Including Tags:
   ```bash
  />./Invoke-ARI -TenantID <Azure Tenant ID> --IncludeTags
   ```
  > By Default Azure Resource inventory do not include Resource Tags.
- Collecting Security Center Data:
  ```bash
  />./Invoke-ARI -TenantID <Azure Tenant ID> -SubscriptionID <Subscription ID> -SecurityCenter
  ```
  > By Default Azure Resource inventory do not collect Security Center Data.
- Skipping Azure Advisor:
  ```bash
  />./Invoke-ARI -TenantID <Azure Tenant ID> -SubscriptionID <Subscription ID> -SkipAdvisory
  ```
  > By Default Azure Resource inventory collects Azure Advisor Data.
- Skipping Network Diagram:
  ```bash
  />./Invoke-ARI -TenantID <Azure Tenant ID> -SkipDiagram
  ```

<br/>

### Tenants
---------------------

<br/>

If you have permissions on more than one tenant, the script will prompt which Tenants do you want to run the inventory against:

<br/>

![Tenants](images/multitenant.png)

<br/>

If can also select which Tenant do you want to run the inventory against:

<br/>

![TenantID](images/tenantID.png)

<br/>

### Network Topology
---------------------

<br/>


Draw.io .XML file will be put in the "C:\AzureResourceInventory" folder:

<br/>

![ARI Files](images/ARIFiles.png)

<br/>

Now you just need to open draw.io and open the file:

<br/>

![Draw.Io Open](images/drawioopen.png)

<br/>