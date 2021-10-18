<br/>

<br/>

<br/>


# Azure Resource Inventory Automation Account v2.1

<br/>

This section explain how to create an Automation Account to run Azure Resource Inventory automatically.  

<br/>

## What is required to run ARI as an Automation Account?

<br/>

#### 1) Azure Automation Account
#### 2) Azure Storage Account
#### 3) Azure Blob Container inside the Storage Account

<br/>

Once you have created the Automation Account, Storage Account and Blob Container. 

## Those are the steps you have to do:

<br/>

### On the Automation Account, enable the System Assigned Identity:

<br/>

<p align="center">
<img src="images/ARIAUT_Identity.png">
</p>

<br/>

#### This will create an identity in the Azure AD.

### Now we are going to use that identity to give the following permissions to the Automation Account:

#### 1) Reader in the Management Group (for the script to be able to read all resources from Azure):

<br/>

<p align="center">
<img src="images/ARIAUT_TenantRole.png">
</p>

<br/>

#### 2) Contributor to the Storage Account Container (for the script to be able to copy the Excel file to the container)

<br/>

<p align="center">
<img src="images/ARIAUT_StgRole.png">
</p>

<br/>

#### 3) Storage Blob Data Contributor to the Storage Account

<br/>

<p align="center">
<img src="images/ARIAUT_StgBlobRole.png">
</p>

<br/>

### Now, back in the Automation Account, the following Modules need to be imported:

#### 1) "ImportExcel" 
#### 2) "Az.ResourceGraph" 
#### 3) "Az.Storage" 
#### 4) "Az.Account"

<br/>

#### This is done by going to the "Modules" then "Browse gallery":

<br/>

<p align="center">
<img src="images/ARIAUT_Modules.png">
</p>

<br/>

#### Then search for the modules, click them and click "Import" (wait for the confirmation as it might take some time):

<br/>

<p align="center">
<img src="images/ARIAUT_ModuleImport.png">
</p>

<br/>

#### Now just create a Powershell Runbook:

<br/>

<p align="center">
<img src="images/ARIAUT_RunBook.png">
</p>

<br/>

#### Then just copy the script content from __ARI_Automation.ps1__

<br/>

<p align="center">
<img src="images/ARIAUT_RunBookScript.png">
</p>

<br/>

#### Hit Save and Publish and you are ready to go.

<br/>

