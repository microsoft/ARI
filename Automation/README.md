<br/>

<br/>

<br/>

# Azure Resource Inventory Automation Account v3

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

#### This will create an identity in the Azure AD.

### Now we are going to use that identity to give the following permissions to the Automation Account:

#### 1) Reader in the Management Group (for the script to be able to read all resources from Azure):

<br/>

<br/>

<p align="center">
<img src="images/AUTv3Tenant.png">
</p>

<br/>

<br/>

#### 2) Storage Blob Data Contributor to the Storage Account

<br/>

<br/>

<p align="center">
<img src="images/AUTv3STGPerm.png">
</p>

<br/>

<br/>

### Now, back in the Automation Account, the following Modules need to be imported with Runtime __7.2__:

#### 1) "ImportExcel" 
#### 2) "Az.ResourceGraph" 
#### 3) "Az.Storage" 
#### 4) "Az.Account"
#### 5) "ThreadJob"

<br/>

<br/>

#### This is done by going to the "Modules" then "Browse gallery":

<br/>

<br/>

<p align="center">
<img src="images/AUTv3Modules.png">
</p>

<br/>

<br/>


#### Now just create a Powershell Runbook:

<br/>

<br/>

<p align="center">
<img src="images/AUTv3Runbook.png">
</p>

<br/>

<br/>

#### Then just copy the script content from __ARI_Automation.ps1__

<br/>

<br/>

<p align="center">
<img src="images/ARIAUT_RunBookScript.png">
</p>

<br/>

<br/>

Remember to change the lines 33 and 36 with your Storage Account and Container name:

<br/>

<br/>

<p align="center">
<img src="images/AUTv3StorageName.png">
</p>


<br/>

#### Hit Save and Publish and you are ready to go.

<br/>

