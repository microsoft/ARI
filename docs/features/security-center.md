# Security Center Integration

Azure Resource Inventory can integrate with Azure Security Center to include security findings in your inventory reports. This page explains how to use this feature and interpret the results.

## Overview

When you run ARI with the `-SecurityCenter` parameter, it collects security recommendations, alerts, and compliance status from Azure Security Center (now part of Microsoft Defender for Cloud). This information is included in the Excel report, providing you with a comprehensive view of your security posture alongside your resource inventory.

## Enabling Security Center Integration

To include Security Center data in your inventory report, use the `-SecurityCenter` parameter:

```powershell
Invoke-ARI -SecurityCenter
```

You can combine this with other parameters as needed:

```powershell
Invoke-ARI -SubscriptionID "00000000-0000-0000-0000-000000000000" -SecurityCenter -ReportName "SecureInventory"
```

## Prerequisites

- Access to Azure Security Center/Microsoft Defender for Cloud
- Appropriate permissions to read security data (Security Reader role or equivalent)
- Security Center must be enabled on the subscriptions you're inventorying

## Security Information Collected

### Security Recommendations

ARI collects security recommendations for resources, including:

- Recommendation name and description
- Resource affected
- Severity (High, Medium, Low)
- Status (Healthy, Unhealthy)
- Remediation steps

### Security Alerts

Active security alerts are collected, including:

- Alert name and description
- Affected resource
- Severity and status
- Detection time

### Regulatory Compliance

If you have regulatory compliance features enabled in Security Center, ARI collects:

- Compliance standards applied (e.g., PCI DSS, ISO 27001, NIST SP 800-53)
- Compliance status for each standard
- Control compliance status

## Report Structure

Security data is integrated into the Excel report in several ways:

1. **Security Tab**: A dedicated worksheet with all security findings
2. **Resource Integration**: Security status indicated in individual resource tabs
3. **Summary View**: Security posture summary in the overview tab

## Interpreting Security Results

### Security Status Indicators

The report uses color coding to highlight security issues:

- **Red**: Critical or high-severity issues
- **Yellow**: Medium-severity issues
- **Green**: Healthy resources with no issues

### Prioritizing Remediation

The security data helps you prioritize remediation efforts based on:

1. Severity of the issue
2. Importance of the affected resource
3. Compliance impact

## Example Use Cases

### Security Audit

Generate a comprehensive security report for compliance auditing:

```powershell
Invoke-ARI -TenantID "00000000-0000-0000-0000-000000000000" -SecurityCenter -ReportName "SecurityAudit"
```

### Regular Security Reviews

Schedule weekly security status reviews using automation:

```powershell
Invoke-ARI -SecurityCenter -Automation -StorageAccount "mystorageaccount" -StorageContainer "securityreports"
```

### Security Baseline for New Projects

Create a security baseline report before beginning a new project:

```powershell
Invoke-ARI -SubscriptionID "00000000-0000-0000-0000-000000000000" -ResourceGroup "ProjectX" -SecurityCenter
```

## Limitations

- Free tier of Security Center provides limited data compared to standard tier
- Some security recommendations may require context not available in the report
- Security data collection may increase the time required to generate the report
- Detailed security logs are not included, only summaries and recommendations 