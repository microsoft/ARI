# Azure Advisor Integration

Azure Resource Inventory integrates with Azure Advisor to include recommendations and best practices in your inventory reports. This page explains how to use and interpret Azure Advisor data in ARI.

## Overview

Azure Advisor is a personalized cloud consultant that provides recommendations to help you optimize your Azure deployments. When you run ARI, it collects Azure Advisor recommendations by default, giving you insights into:

- Cost optimization opportunities
- Performance improvement suggestions
- High availability recommendations
- Security enhancements
- Operational excellence guidance

## Azure Advisor Data Collection

ARI collects Azure Advisor data by default. If you want to skip this collection to make the report generation faster, use the `-SkipAdvisory` parameter:

```powershell
Invoke-ARI -SkipAdvisory
```

## Advisor Information Collected

ARI collects the following information from Azure Advisor:

### Cost Recommendations

- Idle and underutilized resources
- Resources that could benefit from reserved instances
- VM right-sizing opportunities
- Potential savings calculations

### Performance Recommendations

- VM SKU size optimizations
- Premium storage usage opportunities
- Throughput improvements
- Application gateway optimizations

### High Availability Recommendations

- Availability set configurations
- Redundancy settings
- Backup recommendations
- Disaster recovery suggestions

### Security Recommendations

- Endpoint protection
- Security updates
- Vulnerability assessments
- Network security configurations

### Operational Excellence

- Service health tracking
- Resource configuration best practices
- Monitoring and diagnostics settings

## Advisor Data in Reports

Azure Advisor recommendations are integrated into the Excel report in these ways:

1. **Advisor Tab**: A dedicated worksheet with all advisor recommendations
2. **Resource Integration**: Related recommendations are indicated in resource-specific tabs
3. **Overview Summary**: Key recommendations highlighted in the overview tab

## Using Advisor Recommendations

### Identifying Quick Wins

Azure Advisor helps you identify immediate improvements:

```powershell
Invoke-ARI -ReportName "OptimizationOpportunities"
```

Then look for "High" impact recommendations in the Advisor tab.

### Cost Optimization Reviews

Generate a report focused on cost savings:

```powershell
Invoke-ARI -IncludeCosts
```

Review both the Advisor tab and the cost data for complete optimization opportunities.

### Compliance and Best Practices

Use Advisor recommendations to improve your environment's adherence to best practices:

```powershell
Invoke-ARI -TenantID "00000000-0000-0000-0000-000000000000"
```

## Combining with Other Features

### Advisor with Security Center

For a comprehensive view of optimization and security:

```powershell
Invoke-ARI -SecurityCenter
```

### Automated Optimization Reviews

Schedule regular optimization reviews using automation:

```powershell
Invoke-ARI -Automation -StorageAccount "mystorageaccount" -StorageContainer "advisorreports"
```

## Limitations

- Advisor recommendations are point-in-time and may change as your environment evolves
- Some recommendations may require context not available in the report
- Implementation complexity for recommendations isn't always indicated
- Recommendations may not account for business constraints or requirements
- Very recent changes to your environment may not be reflected in recommendations

## Disabling Advisor Data Collection

If you want to generate reports without Azure Advisor data (for faster report generation):

```powershell
Invoke-ARI -SkipAdvisory
```

This can be useful for:
- Quick inventory reports when recommendations aren't needed
- Environments with many resources where Advisor data collection is time-consuming
- Regular operational reports where recommendations are only needed periodically 