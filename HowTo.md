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

| Parameter              | Description                                                                                                       | Usage                      |
|------------------------|-------------------------------------------------------------------------------------------------------------------|----------------------------|
| TenantID               | Specifies the tenant ID you want to create a Resource Inventory for.                                              | `-TenantID <ID>`           |
| SubscriptionID         | Specifies Subscription(s) to be inventoried.                                                                      | `-SubscriptionID <ID>`     |
| ManagementGroup        | Specifies the Management Group to be inventoried(all Subscriptions on it)                                         | `-ManagementGroup <ID>`    |  
| Lite                   | Only use the Import-Excel module and don't create the charts (using Excel's API)                                  | `-Lite`                    |
| SecurityCenter         | Include Security Center Data.                                                                                     | `-SecurityCenter`          |
| SkipAdvisory           | Do not collect Azure Advisory data.                                                                               | `-SkipAdvisory`            |
| Automation             | Required when running the script with an Automation Account                                                       | `-Automation`              |
| Overview               | Used to change the Overview Sheet Charts (Available values are: 1 and 2)                                          | `-Overview`                |
| StorageAccount         | Storage Account Name (Required when running the script with an Automation Account)                                | `-StorageAccount`          |
| StorageContainer       | Storage Account Container Name (Required when running the script with an Automation Account)                      | `-StorageContainer`        |
| IncludeTags            | Include Resource Tags.                                                                                            | `-IncludeTags`             |
| Debug                  | Run in Debug mode.                                                                                                | `-Debug`                   |
| DiagramFullEnvironment | Create a Network Diagram of the entire environment                                                                | `-DiagramFullEnvironment`  |
| Diagram                | Create a Draw.IO Diagram.                                                                                         | `-Diagram`                 |
| SkipDiagram            | Skip diagram creation                                                                                             | `-SkipDiagram`             |
| DeviceLogin            | Authenticate on Azure using the Device Login approach                                                             | `-DeviceLogin`             |
| AzureEnvironment       | Choose between Azure environments <br> > Registered Azure Clouds. Use `az cloud list` to get the list             | `-AzureEnvironment <NAME>` |
| ReportName             | Change the Default Name of the report. `Default name: AzureResourceInventory`                                     | `-ReportName <NAME>`       |
| ReportDir              | Change the Default path of the report.                                                                            | `-ReportDir "<Path>"`      |
| Online                 | Use Online Modules. Scan Modules directly in GitHub ARI Repository                                                | `-Online`                  |
| ResourceGroup          | Specifies one unique Resource Group to be inventoried, This parameter requires the -SubscriptionID parameter to work.       | `-ResourceGroup <NAME>`    |
| AppId                  | Specifies the ApplicationID that is used to connect to Azure as service principal. This parameter requires the -TenantID and -Secret parameters to work. | `-AppId <ID>`              |
| Secret                 | Specifies the Secret that is used with the Application ID to connect to Azure as service principal. This parameter requires the -TenantID and -AppId parameters to work. If -CertificatePath is also used the Secret value should be the Certifcate password instead of the Application secret. | `-Secret <VALUE>`          |
| CertificatePath        | Specifies the Certificate path that is used with the Application ID to connect to Azure as service principal. This parameter requires the -TenantID, -AppId, and -Secret parameters to work. The required certificate format is pkcs#12.   | `-CertificatePath <PATH>`  |
| TagKey                 | Specifies the tag key to be inventoried, This parameter requires the `-SubscriptionID` parameter to work.          | `-TagKey <NAME>`           |
| TagValue               | Specifies the tag value be inventoried, This parameter requires the `-SubscriptionID` parameter to work.           | `-TagValue <NAME>`         |
| QuotaUsage             | Quota Usage                                                                                                        | `-QuotaUsage`              |

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
  > If you do not specify the Subscription, Resource Inventory will be performed on all subscriptions for the selected tenant.
  > To perform the inventory in a specific Tenant and subscription, use the `-TenantID` and `-SubscriptionID` parameters.
  ```bash
    />./Invoke-ARI -TenantID <Azure Tenant ID> -SubscriptionID <Subscription ID>
  ```
- Including Tags:
   ```bash
  />./Invoke-ARI -TenantID <Azure Tenant ID> --IncludeTags
   ```
  > By Default Azure Resource inventory does not include Resource Tags.
- Collecting Security Center Data:
  ```bash
  />./Invoke-ARI -TenantID <Azure Tenant ID> -SubscriptionID <Subscription ID> -SecurityCenter
  ```
  > By Default Azure Resource inventory does not collect Security Center Data.
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

If you have permissions on more than one tenant, the script will prompt for which Tenants you want to run the inventory against:

<br/>

![Tenants](images/multitenant.png)

<br/>

It can also select which Tenant you want to run the inventory against:

<br/>

![TenantID](images/tenantID.png)

<br/>

### Network Topology
---------------------

<br/>


The draw.io .XML file will be placed in the "C:\AzureResourceInventory" folder:

<br/>

![ARI Files](images/ARIFiles.png)

<br/>

Now you just need to open draw.io and open the file:

<br/>

![draw.io Open](images/drawioopen.png)

<br/>