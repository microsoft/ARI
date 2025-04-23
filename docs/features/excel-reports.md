# Excel Reports

Azure Resource Inventory generates comprehensive Excel reports that provide detailed information about your Azure environment. This page explains the structure and content of these reports.

## Report Overview

The Excel report is the primary output of Azure Resource Inventory. It contains multiple worksheets, each dedicated to a specific resource type or summary view. The report is designed to be:

- **Comprehensive**: Covering all resource types in your environment
- **Well-formatted**: With consistent styling and visual aids
- **Filterable**: Allowing you to quickly find specific resources
- **Interactive**: Including charts and visual summaries where appropriate

<div align="center">
<img src="../../images/ARIv3ExcelExample.png" width="800">
</div>

## Report Structure

### Overview Sheet

The first sheet provides a high-level summary of your Azure environment, including:

- Total number of resources by type
- Subscription distribution
- Resource group statistics
- Charts visualizing resource distribution

### Resource Type Sheets

Each Azure resource type has its own dedicated worksheet with relevant details. For example:

- **Virtual Machines**: CPU, memory, OS, size, status, etc.
- **Storage Accounts**: Type, tier, replication, access tier, etc.
- **Virtual Networks**: Address space, subnets, peerings, etc.

### Tag-Based Information

When you run ARI with the `-IncludeTags` parameter, resource tags are included in each resource sheet, allowing you to:

- Filter resources by tag values
- Understand resource ownership
- Track environment designations (production, development, etc.)

## Data Visualization

The Excel report includes various visualizations to help you understand your environment:

- **Charts**: Distribution of resources by type, location, etc.
- **Conditional Formatting**: Color-coding for status, size, or configuration concerns
- **Data Tables**: Structured presentation of resource properties

## Report Customization

### Lite Mode

For faster report generation, you can use the `-Lite` parameter, which:

- Skips chart creation
- Uses simplified formatting
- Focuses on core resource information

### Custom Report Naming

You can customize the report name and location:

```powershell
Invoke-ARI -ReportName "MyCustomReport" -ReportDir "C:\Reports"
```

### Filtering Options

The generated Excel report supports standard Excel filtering. You can:

- Filter by any column
- Sort data by any property
- Create pivot tables for advanced analysis

## Using the Report

### Best Practices

1. **Regular Updates**: Generate reports regularly to track changes over time
2. **Version Control**: Save reports with date-based naming for historical tracking
3. **Sharing**: The Excel format makes it easy to share with stakeholders

### Common Analysis Scenarios

1. **Cost Optimization**: Identify unused or oversized resources
2. **Security Review**: Check for open NSG rules or misconfigured resources
3. **Governance Validation**: Ensure resources follow tagging conventions
4. **Migration Planning**: Catalog resources before migration projects

### Limitations

- Cloud Shell reports won't have auto-fit columns due to environment limitations
- Very large environments may have performance impacts in Excel
- Some complex resource properties may be summarized rather than fully expanded

## Automation Output

When using ARI with `-Automation`, the Excel report is saved to the specified Storage Account and container:

```powershell
Invoke-ARI -Automation -StorageAccount "mystorageaccount" -StorageContainer "reports"
``` 