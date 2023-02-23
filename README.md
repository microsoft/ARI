---
ArtifactType: Excel spreedcheet with the full Azure environment
Language: Powershell
Platform: Windows / Linux / Mac
Tags: Powershell, Azure, Inventory, Excel Report, Customer Engineer
---

![GitHub](https://img.shields.io/github/license/microsoft/ARI) ![GitHub repo size](https://img.shields.io/github/repo-size/microsoft/ARI) [![Azure](https://badgen.net/badge/icon/azure?icon=azure&label)](https://azure.microsoft.com)

![GitHub last commit](https://img.shields.io/github/last-commit/microsoft/ARI)
![GitHub top language](https://img.shields.io/github/languages/top/microsoft/ARI)

<br/>


# Azure Resource Inventory v2.3

Azure Resource inventory (ARI) is a powerful script written in powershell to generate an Excel report of any Azure Environment you have read access. 

This project is intend to help Cloud Admins and anyone that might need an easy and fast way to build a full Excel Report of an Azure Environment.  

<br/>

## What's new ?

<br/>

In Azure Resource Inventory v2.3 we rollback the use of Azure CLI as changing to 100% Powershell based apparently caused more problems than solutions. One of ours initial and main goal was to keep the script as simple and easy to run as possible, and we believe that rollback make sense in that point.


<br/>

<br/>

> ### *1) Dashboard Overview*

---------------------

<br/>

- The main resource index in the dashboard now shows the correct number of resources and is organized accordingly. 

<br/>

![Overview](images/ARIv2-Overview.png)

<br/>

<br/>

> ### *2) Azure Diagram Inventory!*

---------------------

<br/>

- We disabled the Visio Diagram for now. But Draw.io diagram is still present, the two extra modules that creates a Microsoft Visio and a Draw.io Diagram[^1] of the Azure Network Environment are still present, but only the Draw.io will be genarated.

- The diagram now creates the topology in environments where vWAN are used.

We are preparing more improvements in the diagrams, but for now there is no due date yet.

<br/>

You must use the __-Diagram__ parameter for it to be generated!

#### Draw.io Diagram:

<p align="center">
<img src="images/DrawioImage.png">
</p>

<br/>

### Note:

[^1]:The script will create a XML file inside the "C:\AzureResourceInventory\" folder. On Draw.io you must go to File > Import from > Device... And import the XML file that was created by the ARI script.

- For the __Draw.io Diagram__, the script will create a XML file inside the "C:\AzureResourceInventory\" folder. On Draw.io you must go to __File__ > __Import from__ > __Device...__ And import the XML file that was created by the script.

<br/>

<p align="center">
<img src="images/DrawioImport.png">
</p>

<br/>

<br/>

<br/>

> ### *3) Resource types*

---------------------

<br/>

Those are the native modules covered by the script ( there is still the possibility to create your own modules )

#### Resources and Resource Providers:

|Resource Provider|Resource Type|
|-----------------|-------------|
|microsoft.advisor|Advisor|
|microsoft.security|Security Center| 
|microsoft.compute|Virtual Machine|
|microsoft.compute|Availability Set|
|microsoft.compute|Virtual Machine Scale Set|
|microsoft.compute|Managed Disk|
|microsoft.storage|Storage Account|
|microsoft.network|Virtual Network|
|microsoft.network|Virtual Network Peerings|
|microsoft.network|Virtual Network Gateway|
|microsoft.network|Virtual WAN|
|microsoft.network|Public IP Address|
|microsoft.network|Load Balancer|
|microsoft.network|Traffic Manager|
|microsoft.network|Application Gateways|
|microsoft.network|Frontdoor|
|microsoft.network|Route Tables|
|microsoft.network|Public DNS Zones|
|microsoft.network|Private DNS Zones|
|microsoft.network|Bastion Hosts|
|microsoft.network|Azure Firewall|
|microsoft.sqlvirtualmachine|SQL VM|
|microsoft.sql|SQL Servers|
|microsoft.sql|SQL Database|
|microsoft.dbformysql|Azure Database for MySQL|
|microsoft.dbforpostgresql|Azure Database for Postgre|
|microsoft.cache|Azure Cache for Redis|
|microsoft.documentdb|Cosmos DB|
|microsoft.databricks|Databricks|
|microsoft.kusto|Data Explorer|
|microsoft.web|App Service Plan|
|microsoft.web|App Services|
|microsoft.automation|Automation Accounts and runbooks|
|microsoft.eventhub|Event HUB|
|microsoft.servicebus|Service BUS|
|microsoft.operationalinsights|Log Analytics Workspaces|
|microsoft.containerservice|Azure Kubernetes Service|
|microsoft.redhatopenshift|Azure RedHat OpenShift|    
|microsoft.desktopvirtualization|Azure Virtual Desktop|  
|microsoft.containerinstance|Container Instances| 
|microsoft.keyvault|Key Vaults|
|microsoft.recoveryservices|Recovery Services Vault|
|microsoft.devices|IoT Hubs|
|microsoft.apimanagement|API Management|
|microsoft.streamanalytics|Streaming Analytics Jobs|
|microsoft.hybridcompute|machines|

<br/>

<br/>

> ### *4) Other features*

---------------------

<br/>

:heavy_check_mark: Quota Usage (__-QuotaUsage__)  
:heavy_check_mark: Service Principal Authentication (__-appid__)  
:heavy_check_mark: Scan Modules diretly in GitHub ARI Repository (__-Online__)  
:heavy_check_mark: Choose between Azure environments (__-AzureEnvironment__)

<br/>

# Getting Started

<br/>

These instructions will get you a copy of the project up and running on your local machine or CloudShell.

<br/>

### Supportability
|Resource Provider|Results|Draw.io Diagram|Comments|
|-----------------|-------------|-----------------|-------------|
|Windows|Fully successfully tested|Supported|Best Results|
|MAC|Fully successfully tested|Not Supported||
|Linux|Tested on Ubuntu Desktop|Not Supported|No Table auto-fit for columns|
|CloudShell|Tested on Azure CloudShell|Not Supported|No Table auto-fit for columns|

<br/>

### Our Test Environment:   

|Tool |Version|  
|-----------------|-------------|
|Windows|10 21H1| 
|Powershell|5.1.19041.1237|  
|ImportExcel|7.1.3|
|azure-cli|2.38.0|
|AzCLI account|0.2.3|
|AzCLI resource-graph|2.1.0|

<br/>

### Prerequisites

You can use Azure Resource Inventory in both in Cloudshell and Powershell Desktop. 

What things you need to run the script 


1. Install-Module [ImportExcel](https://github.com/dfinke/ImportExcel)
2. Install [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
3. Install Azure CLI [Account](https://docs.microsoft.com/en-us/cli/azure/azure-cli-extensions-list) Extension
4. Install Azure CLI [Resource-Graph](https://docs.microsoft.com/en-us/cli/azure/azure-cli-extensions-list) Extension


By default Azure Resource Inventory will call to install the required Powershell modules and Azure CLI components but you must have administrator privileges during the script execution. 

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

* Its really simple to use Azure Resource Inventory, all that you need to do is to call this script in PowerShell.

* Run "AzureResourceInventory.ps1". In Azure CloudShell you're already authenticated. In PowerShell Desktop you will be redirected to  Azure sign-in page. 

<br/>

![Tenants Menu](images/Execution.png)  


* If you have privileges in multiple tenants you can specify the desired one by using "-TenantID" parameter or Azure Resource will scan all your tenants ID and ask you to choose one.   

<br/>

![Tenants Menu](images/TenantsMenu.png)

* After properly authenticated and with the TENANT selected, the Azure Resource Inventory will perform all the work of extracting and creating the inventory.
* The duration will vary according to the number of subscriptions and resources. In our tests we managed to generate in 5 minutes the inventory of a Tenant with 15 subscriptions and about 12000 resources.

* Azure ResourceInventory uses "*C:\AzureResourceInventory*" as default folder for PowerShell Desktop in Windows and "*$HOME/AzureResourceInventory*" for Azure CloudShell to save the final Excel file. 
* This file will have the name  "*AzureResourceInventory_Report_yyyy-MM-dd_HH_mm.xlsx*"  where "*yyyy-MM-dd_HH_mm*" are the date and time that this inventory was created. 

<br/>

![ARI Final File Desktop](images/FinalReport.png)

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
