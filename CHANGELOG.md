# Version Control

## Version 1.4.16 - 08/02/2021

### **Azure Resource Inventory:**
        1. Fixes SecurityCenter function

## Version 1.4.15 - 08/02/2021

### **Azure Resource Inventory:**
        1. Fixes in Public IP Inventory

## Version 1.4.14 - 07/19/2021

### **Azure Resource Inventory:**
        1. Fix CheckPS and LoginSession Function for Azure CloudShell

## Version 1.4.13 - 07/19/2021

### **Azure Resource Inventory:**
        1. Improvments on SQL DB sheet.
        2. Added Private DNS Zones sheet.
        3. Added Bastion Hosts sheet.
        4. Added Stream Analytics Jobs sheet.

---

## Version 1.4.12 - 06/24/2021

### **Azure Resource Inventory:**
        1. Changes in functions core base.

---

## Version 1.4.11 - 06/22/2021

### **Azure Resource Inventory:**
        1. Changes in AvSet Resource Inventory.
        2. Excluding resources when "properties" field sums more than 123000 characters.

---

## Version 1.4.10 - 06/11/2021

### **Azure Resource Inventory:**
        1. Fixes in APIM processing.

---

## Version 1.4.9 - 06/11/2021

### **Azure Resource Inventory:**
        1. Fixes in APIM Inventory.

---

## Version 1.4.8 - 05/28/2021

### **Azure Resource Inventory:**
        1. Added "Use" column in the Public IP tab, to report Public IPs not associated with any resources.

---

## Version 1.4.7 - 05/22/2021

### **Azure Resource Inventory:**
        1. Fixes on APIM Resource Inventory.

---

## Version 1.4.6 - 05/21/2021

### **Azure Resource Inventory:**
        1. Added support for API Management.
        2. Changes in the VMSS Name reference.

---

## Version 1.4.5 - 05/19/2021

### **Azure Resource Inventory:**
        1. Fixes when using oldest versions of Azure Resource Graph Az Cli extension (should work with old and new version of the Extension).

---

## Version 1.4.4 - 05/17/2021

### **Azure Resource Inventory:**
        1. Fixes when using newest versions of Azure Resource Graph Az Cli extension.

---
## Version 1.4.3 - 05/17/2021

### **Azure Resource Inventory:**
        1. Fixes when using PowerShell Core (Following sugestions by Mike-Ling).
        2. Added reporting of unused Public IP.

---

## Version 1.4.2 - 04/30/2021

### **Azure Resource Inventory:**
        1. Fixes in VM NICs reporting.

---

## Version 1.4.1 - 04/06/2021

### **Azure Resource Inventory:**
        1. Fixes in Resource U column regarding duplicated records.

---

## Version 1.4.0 - 03/26/2021

### **Azure Resource Inventory:**
        1. Major improvements in -IncludeTags parameters (when using the parameter, the script might take considerable longer time to run).

---

## Version 1.3.5 - 03/24/2021

### **Azure Resource Inventory:**
        1. Change parameter -SkipSecurityCenter to -SecurityCenter. The parameter is now set to not collect Security Center by default.
        2. Inclusion of the parameter -IncludeTags. This parameter will add the tags column in every resource tab.

---

## Version 1.3.3 - 02/08/2021

### **Azure Resource Inventory:**
        1. Fixed Warning when no AKS exists in the environment.

---

## Version 1.3.1 - 02/01/2021

### **Azure Resource Inventory:**
        1. Fixed Storage Account Public Access bug.

---

## Version 1.3.0 - 01/04/2021

### **Azure Resource Inventory:**
        1. Added FrontDoor Resource.
        2. Added Application Gateway Resource.
        3. Added Route Tables Resource.
        4. Added Key Vault Resource.
        5. Added Recovery Vault Resource.
        6. Added DNS Zones Resource.
        7. Added Iot Hubs Resource.

---

## Version 1.2.2 - 12/28/2020

### **Azure Resource Inventory:**
        1. Added SkipAdvisory parameter.
        2. Fixed some performance issues.

---

## Version 1.2.0 - 12/11/2020

### **Azure Resource Inventory:**
        1. Added extra data for Azure VM.
        2. Added extra data for Disks.
        2. Added notes to relevant issues with official Microsoft link.

---
## Version 1.1.0 - 12/08/2020

### **Azure Resource Inventory:**
        1. Implemented Jobs during Azure extraction (Jobs were used only in the reporting phase).
        2. Fixed an issue with ImportExcel Module.

---
## Version 1.0.7 - 12/07/2020

### **Azure Resource Inventory:**
        1. Added "Running as Admin" validation when installing ImportExcel module.
        2. Fixed a minor issue in the -SkipSecurityCenter parameter.

---
## Version 1.0.5 - 12/06/2020

### **Azure Resource Inventory:**
Grinder will no longer be used in the name. It will only be Azure Resource Inventory.During the development phase in private repository Grinder was used at name with reference to "Meat Grinder" but this name is now retired.

---
## Version 1.0.2 - 12/04/2020

### **AzureGrinder:**
        1. Fix issue on single tenant usage
        2. Added SubscriptionID option

---

## Version 1.0 - 12/03/2020
1.0 - Offical release 

---
## Version 0.5 - 11/25/2020

### **AzureGrinder:**
        1. Removal of XML files generation
        2. InMemory capturing and processing of the Inventory
        3. Split between VNET and VNET Peering
        4. Using Progress bar instead console writing

---
## Version 0.4.0 - 11/25/2020

### **AzureGrinder:**
        1. Merge of Extractor and Grinder in the same file

---
## Version 0.3.6 - 11/23/2020

### **AzureGrinder:**
        1. Debugging mode
        2. Added Network Gateway Resource Type
        3. Improvements made in the Load Balancer sheet
        4. Improvements made in the SQL DB Sheet
        5. Added SQL Servers Resource Type

---
## Version 0.3.5 - 11/19/2020

### **AzureGrinder:**
        1. Improvements in Storage Account analyzes, now including:
            a. Public Access
            b. TLS Version
            c. ADDS
            d. Secondary location

---
## Version 0.3.4 - 11/18/2020

### **AzureGrinder:**
        1. Bugfix on VNET version

---
## Version 0.3.3 - 11/17/2020

### **AzureGrinderExtractor:**
        1. Unified Desktop and Cloudshell version 
### **AzureGrinder:**
        1. Modified version of VNET analyzes

---
## Version 0.3.2 - 11/17/2020

### **AzureGrinder:**
        1. Fixed NSG Validation on VMs Sheet

---
## Version 0.3.1 - 11/15/2020

### **AzureGrinder:**
        1. Added "Performance Diagnostics Agent" column to the VMs sheet 

---
## Version 0.3 - 11/12/2020

### **AzureGrinder:**
        1. Fixed all charts in Overview
        2. Added the Subscriptions chart to the Overview sheet
        3. Added Load Balancer sheet
        4. Added Subscriptions sheet
        5. Added Network Interface details to the VMs sheet
        6. Added NSG details to the VMs sheet
        7. Added VM Extensions to the VMs sheet
        8. Added Excel formatting to:
            a. Accelerated Networking column in VMs sheet
            b. Excel style to the AC column (VM Extensions)
        9. Added Network Gateway details to the Public IP sheet
        10. Added VM Scale Sets sheet