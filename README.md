---
ArtifactType: Excel spreadsheet with the full Azure environment
Language: Powershell
Platform: Windows / Linux / Mac
Tags: Powershell, Azure, Inventory, Excel Report, Customer Engineer
---

![GitHub](https://img.shields.io/github/license/microsoft/ARI) ![GitHub repo size](https://img.shields.io/github/repo-size/microsoft/ARI) [![Azure](https://badgen.net/badge/icon/azure?icon=azure&label)](https://azure.microsoft.com)

![GitHub last commit](https://img.shields.io/github/last-commit/microsoft/ARI)
![GitHub top language](https://img.shields.io/github/languages/top/microsoft/ARI)

<br/>

<p align="center">
<img src="images/ARI_Logo.png">
</p>

# Azure Resource Inventory

Azure Resource inventory (ARI) is a powerful powershell module that generates an Excel report of any Azure Environment you have read access. 

This project is intend to help Cloud Admins and anyone that might need an easy and fast way to build a full Excel Report of an Azure Environment.  

<br/>

### What's new ?

<br/>

- Version 3.5 is here:
  - ARI Powershell Module
  - New Automation Account
  - Azure Rest API

<br/>

## Azure Resource Inventory Overview

<br/>

<p align="center">
<img src="images/ARIv35-Overview.png">
</p>

<br/>

<p align="center">
<img src="images/ARIv3ExcelExample.png">
</p>

#### Network Topology View

<br/>

<p align="center">
<img src="images/DrawioImage.png">
</p>

<br/>

- An extra detail is that if you hover the mouse cursor over any resource in the Network Topology you get the resource details:

<br/>

<p align="center">
<img src="images/ARIv3DrawioHover.png">
</p>

<br/>

- This feature is available for any resource and even peering lines:

<br/>

<p align="center">
<img src="images/ARIv3DrawioPeer.png">
</p>

<br/>

<br/>

#### Organization View

<br/>

<p align="center">
<img src="images/DrawioOrganization.png">
</p>

<br/>

#### Resources View

<br/>

<p align="center">
<img src="images/drawiosubs.png">
</p>

<br/>

## Version 3.5

<br/>

Among the many improvements, there are two that will considerable change the way we use the script and type of data we are reporting:

<br/>

#### 1) Azure Resource Inventory (Powershell Module)

<br/>

We expect this change will positively change the experience of installing and executing ARI:

<br/>

Installing ARI:

```
Install-Module -Name AzureResourceInventory
```

<br/>

<p align="center">
<img src="images/InstallARI.gif">
</p>

<br/>

Now to run the script just execute "Invoke-ARI" with the regular parameters:

```
Invoke-ARI 
```

<br/>

<p align="center">
<img src="images/RunningARI.gif">
</p>

<br/>

#### 2) Automation is now fully integrated within the ARI Module

<br/>

The process to run Azure Resource Inventory using Automation Accounts was changed to fully integrate with the new ARI Module


<br/>

<p align="center">
<img src="images/Automation.png">
</p>

<br/>


The required steps are present in the: [Automation Guide](https://github.com/microsoft/ARI/blob/main/Automation/README.md).

<br/>

<br/>

#### 3) Azure Rest API

<br/>

We are finally incorporating Azure REST API data into ARI. 

At this time we are only including:

  - Azure Support Tickets
  - Azure Health Incidents
  - Azure Advisor Score Data
  - Reservation Recommendations

We expect this will open doors for extra types of data to be included in the script in the future.


<br/>


<br/>

> ### *3) Parameters*

| Parameter              | Description                                                                                                                                     |                            |
|------------------------|-------------------------------------------------------------------------------------------------------------------|----------------------------|
| TenantID               | Specify the tenant ID you want to create a Resource Inventory.                                                    | `-TenantID <ID>`           |
| SubscriptionID         | Specifies Subscription(s) to be inventoried.                                                                      | `-SubscriptionID <ID>`     |
| ManagementGroup        | Specifies the Management Group to be inventoried(all Subscriptions on it)                                         | `-ManagementGroup <ID>`    |  
| Lite                   | Specifies to use only the Import-Excel module and don't create the charts (using Excel's API)                     | `-Lite`                    |
| SecurityCenter         | Include Security Center Data.                                                                                     | `-SecurityCenter`          |
| SkipAdvisory           | Do not collect Azure Advisory.                                                                                    | `-SkipAdvisory`            |
| Automation             | Required when running the script with Automation Account                                                          | `-Automation`              |
| Overview               | Used to change the Overview Sheet Charts (Available values are: 1 and 2)                                          | `-Overview`                |
| StorageAccount         | Storage Account Name (Required when running the script with Automation Account)                                   | `-StorageAccount`          |
| StorageContainer       | Storage Account Container Name (Required when running the script with Automation Account)                         | `-StorageContainer`        |
| IncludeTags            | Include Resource Tags.                                                                                            | `-IncludeTags`             |
| Debug                  | Run in a Debug mode.                                                                                              | `-Debug`                   |
| DiagramFullEnvironment | Network Diagram of the entire environment                                                                         | `-DiagramFullEnvironment`  |
| Diagram                | Create a Draw.IO Diagram.                                                                                         | `-Diagram`                 |
| SkipDiagram            | To skip the diagrams creation                                                                                     | `-SkipDiagram`             |
| DeviceLogin            | Authenticating on Azure using the Device login approach                                                           | `-DeviceLogin`             |
| AzureEnvironment       | Choose between Azure environments <br> > Registered Azure Clouds. Use `az cloud list` to get the list             | `-AzureEnvironment <NAME>` |
| ReportName             | Change the Default Name of the report. `Default name: AzureResourceInventory`                                     | `-ReportName <NAME>`       |
| ReportDir              | Change the Default path of the report.                                                                            | `-ReportDir "<Path>"`      |
| Online                 | Use Online Modules. Scan Modules diretly in GitHub ARI Repository                                                 | `-Online`                  |
| ResourceGroup          | Specifies one unique Resource Group to be inventoried, This parameter requires the -SubscriptionID to work.       | `-ResourceGroup <NAME>`    |
| AppId                  | Specifies the ApplicationID that is used to connect to Azure as service principal.                                | `-AppId <ID>`              |
|                        |  This parameter requires the -TenantID and -Secret to work.                                                       |                            |
| Secret                 | Specifies the Secret that is used with the Application ID to connect to Azure as service principal.               | `-Secret <VALUE>`          |
|                        |  This parameter requires the -TenantID and -AppId to work.                                                        |                            | 
|                        |  If -CertificatePath is also used the Secret value is not the Application secret but is the Certifcate password.  |                            |
| CertificatePath        | Specifies the Certificate path that is used with the Application ID to connect to Azure as service principal.     | `-CertificatePath <PATH>`  |
|                        |  This parameter requires the -TenantID, -AppId and -Secret to work. The required certificate format is pkcs#12.   |                            | 
| TagKey                 | Specifies the tag key to be inventoried, This parameter requires the `-SubscriptionID` to work.                   | `-TagKey <NAME>`           |
| TagValue               | Specifies the tag value be inventoried, This parameter requires the `-SubscriptionID` to work.                    | `-TagValue <NAME>`         |
| QuotaUsage             | Quota Usage                                                                                                       | `-QuotaUsage`              |

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

# Getting Started

<br/>

These instructions will get you a copy of the project up and running on your local machine or CloudShell.

<br/>

### Supportability

Even the script might work in almost all environments. Some components (i.e the Topology Diagram) use some APIs and components only present in Windows environment. 

<br/>

### Our Test Environment:   

|Tool |Version|  
|-----------------|-------------|
|Windows|11 22H2| 
|Powershell|7.4.4|  


<br/>

### Prerequisites

Since the script is a Powershell Module, and we fully migrated az cli to powershell. No extra requirements are needed. 

Just install the AzureResourceInventory Module and all the required modules will be automatically installed as well.

By default Azure Resource Inventory will call to install the required Powershell modules but you must have administrator privileges during the script execution. 

Special Thanks for __Doug Finke__, the Author of Powershell [ImportExcel](https://github.com/dfinke/ImportExcel) Module.    

<br/>

<br/>

## :warning: Warnings

<br/>

<span style="color:red">**Very Important:**</span> Azure Resource Inventory will not upgrade the current version of the Powershell modules.

<br/>

<span style="color:red">**Important:**</span> If you're running the script inside Azure CloudShell the final Excel will not have Auto-fit columns and you will see warnings during the script execution (but the results of your inventory will not be changed :)

![CloudShell Warnings](images/cloudshell-warning-lib.png)

<br/>

## Running the script

<br/>

* Its really simple to use Azure Resource Inventory, all that you need to do is to invoke this cmdlet in PowerShell.

* Run "Invoke-ARI". In Azure CloudShell you're already authenticated. In PowerShell Desktop you will be redirected to  Azure sign-in page. 

<br/>

![RunningARI](images/RunningARI.gif)  


* If you have privileges in multiple tenants you can specify the desired one by using "-TenantID" parameter or Azure Resource will scan all your tenants ID and ask you to choose one.   

<br/>

![Tenants Menu](images/TenantsMenu.png)

* After properly authenticated and with the TENANT selected, the Azure Resource Inventory will perform all the work of extracting and creating the inventory.
* The duration will vary according to the number of subscriptions and resources. In our tests we managed to generate in 5 minutes the inventory of a Tenant with 15 subscriptions and about 12000 resources.

* Azure ResourceInventory uses "*C:\AzureResourceInventory*" as default folder for PowerShell Desktop in Windows and "*$HOME/AzureResourceInventory*" for Azure CloudShell to save the final Excel file. 
* This file will have the name  "*AzureResourceInventory_Report_yyyy-MM-dd_HH_mm.xlsx*"  where "*yyyy-MM-dd_HH_mm*" are the date and time that this inventory was created. 


<br/>

## Versioning and changelog

<br/>

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](link-to-tags-or-other-release-location).

We also keep the `CHANGELOG.md` file in repository to Document version changes and updates.

<br/>

## Authors

The main authors of this project are:

1. Claudio Merola (claudio.merola@microsoft.com)
2. Renato Gregio

<br/>

<br/>

## Contributing

Please read our [CONTRIBUTING.md](CONTRIBUTING.md) which outlines all of our policies, procedures, and requirements for contributing to this project.

<br/>

<br/>

----------------------------------------------------------------------

<br/>

## About the tool

<br/>

Copyright (c) 2018 Microsoft Corporation. All rights reserved.

<br/>

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.


<br/>

----------------------------------------------------------------------

<br/>

## Trademarks

<br/>

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft trademarks or logos is subject to and must follow [Microsoft’s Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks). Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship. Any use of third-party trademarks or logos are subject to those third-party’s policies.

<br/>
