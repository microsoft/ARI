<br/>

<br/>

<br/>

# Azure Resource Inventory Automation Account v4

<br/>

<br/>

This section explain how to create an Automation Account to run Azure Resource Inventory automatically.  

<br/>

<br/>

## What is required to run ARI as an Automation Account?

<br/>

<br/>

#### 1) Azure Automation Account
#### 2) Azure Storage Account
#### 3) Azure Blob Container inside the Storage Account

<br/>

<br/>

Once you have created the Automation Account, Storage Account and Blob Container. 

## Those are the steps you have to do:

<br/>

<br/>

### On the Automation Account, enable the System Assigned Identity:

<br/>

<br/>

<p align="center">
<img src="images/ARIAUT_Identity.png">
</p>

<br/>

<br/>

#### This will create an identity in the Entra ID.

### Now we are going to use that identity to give the following permissions to the Automation Account:

#### 1) Reader in the Management Group (for the script to be able to read all resources from Azure):

<br/>

<br/>

<p align="center">
<img src="images/AUTv4Tenant.png">
</p>

<br/>

<br/>

#### 2) Storage Blob Data Contributor to the Storage Account

<br/>

<br/>

<p align="center">
<img src="images/AUTv4STGPerm.png">
</p>

<br/>

<br/>

### Now, back in the Automation Account, the following Modules need to be imported with Runtime __7.2__:

#### 1) "AzureResourceInventory"
#### 2) "ImportExcel"
#### 3) "Az.ResourceGraph"
#### 4) "ThreadJob"

<br/>

<br/>

#### This is done by going to the "Modules" then "Browse gallery":

<br/>

<br/>

<p align="center">
<img src="images/AUTv4Modules.png">
</p>

<br/>

<br/>


#### Now just create a Powershell Runbook:

<br/>

<br/>

<p align="center">
<img src="images/AUTv4Runbook.png">
</p>

<br/>

<br/>

#### Then just add the "Invoke-ARI" command line inside the runbook. 

<br/>

The line must contain the following parameters:

````
-TenantID
-SkipDiagram
-SkipAPIs
-Automation
-StorageAccount
-StorageContainer
````

<br/>

The parameter "StorageAccount" is used to inform the Storage Account where the report will be placed and the "StorageContainer" parameter is used to pass the container within that Storage Account where the report will be placed.

<br/>

<p align="center">
<img src="images/ARIAUT_RunBookScript.png">
</p>


<br/>

#### Hit Save and Publish and you are ready to go.

<br/>

