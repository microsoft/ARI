# Frequently Asked Questions

This page answers common questions about Azure Resource Inventory.

## General Questions

### What is Azure Resource Inventory?

Azure Resource Inventory (ARI) is a PowerShell module that generates detailed Excel reports about your Azure resources. It helps you document and inventory your Azure environment with minimal effort.

### Is ARI an official Microsoft product?

ARI is developed by Microsoft engineers and published on the official Microsoft GitHub account, but it's an open-source tool provided as-is without official Microsoft support.

### Does ARI make any changes to my Azure environment?

No, ARI is a read-only tool that only collects information about your Azure resources. It doesn't make any changes to your environment.

### What operating systems does ARI work on?

ARI works on any operating system that supports PowerShell 7, including:
- Windows
- macOS
- Linux
- Azure Cloud Shell

### Is ARI free to use?

Yes, ARI is open source and free to use under the MIT license.

## Technical Questions

### How does ARI collect information?

ARI primarily uses Azure Resource Graph and other Azure PowerShell modules to collect information about your resources efficiently.

### Does ARI require the Azure portal to work?

No, ARI is a PowerShell module that doesn't require the Azure portal. It works directly with the Azure APIs.

### How much time does it take to generate a report?

The time depends on the size of your environment and the options you choose. Small environments might take just a minute or two, while large environments with many subscriptions could take 15-30 minutes or more.

### Can I run ARI on a schedule?

Yes, you can use Azure Automation to run ARI on a schedule. See the [Automation Guide](../advanced/automation.md) for details.

### Does ARI support Azure Stack?

ARI is designed for Azure public cloud. It may work partially with Azure Stack, but full compatibility is not guaranteed.

### What permissions do I need to run ARI?

You need read access (Reader role) to the resources you want to inventory. Additional permissions may be required for certain features:
- Security Center data requires Security Reader access
- Cost data requires Cost Management Reader access

## Report Questions

### Can I customize the Excel report?

The report is generated with standard formatting, but you can modify it after generation using Excel. You can also use parameters like `-Lite` to change the report style.

### Does ARI collect sensitive data?

ARI collects resource configurations but doesn't collect sensitive data like passwords, connection strings, or keys. However, it may collect resource names and other metadata that your organization considers sensitive.

### Can I export the report to other formats?

ARI generates an Excel file, which you can then export to other formats using Excel or other tools.

### How big are the generated Excel files?

File size depends on your environment. Small environments might generate files under 1MB, while large enterprise environments can generate files of 10MB or more.

### Can I share the reports with others?

Yes, the Excel reports can be shared with anyone who needs to see your Azure inventory. No special software is required to view them beyond Microsoft Excel or compatible spreadsheet applications.

## Usage Questions

### What's the difference between `-Lite` and regular mode?

The `-Lite` parameter generates a report without charts and with simplified formatting, which is faster to generate and results in smaller file sizes.

### Should I use the `-SecurityCenter` parameter?

Use `-SecurityCenter` if you want to include security recommendations and alerts in your report. This is useful for security reviews, but it will increase the report generation time.

### How can I speed up report generation?

To speed up report generation:
- Use the `-Lite` parameter
- Use the `-SkipDiagram` parameter
- Use the `-SkipAdvisory` parameter
- Limit the scope to specific subscriptions or resource groups

### What is the `-IncludeTags` parameter for?

The `-IncludeTags` parameter includes all resource tags in the report. This is useful for environments that use tagging extensively for organization or governance.

### Can I run ARI without an internet connection?

No, ARI needs to connect to Azure APIs to collect resource information.

## Troubleshooting Questions

### ARI fails with an authentication error. What should I do?

Make sure you're properly authenticated to Azure by running `Connect-AzAccount` before running ARI, or by using the correct authentication parameters.

### Why are some resources missing from my report?

Resources might be missing if:
- You don't have access to them
- They're in subscriptions you didn't include
- They were created recently and aren't yet visible in Resource Graph
- The resource type isn't supported by ARI

### Why does ARI run slowly in my environment?

ARI's performance depends on:
- The size of your Azure environment
- Your internet connection speed
- Your computer's performance
- The parameters you use (e.g., `-Lite`, `-SkipDiagram`)

See the [Troubleshooting Guide](troubleshooting.md) for ways to improve performance.

### I get an error about ImportExcel. How do I fix it?

Make sure the ImportExcel module is installed and up to date:
```powershell
Install-Module -Name ImportExcel -Force
```

For more troubleshooting help, see the [Troubleshooting Guide](troubleshooting.md). 