# Version History

This page documents the version history and key changes for Azure Resource Inventory.

## Version 3.6.4 (Current)

### Improvements
- Updated module to support the latest Azure resource providers
- Enhanced performance for large environments
- Improved error handling and messaging
- Updated Azure Security Center integration with Microsoft Defender for Cloud

### Bug Fixes
- Fixed issue with some resource types not being properly collected
- Corrected formatting problems in Excel output
- Addressed errors when collecting VM extension details
- Fixed diagram generation for complex network topologies

## Version 3.6.0

### New Features
- Added `-IncludeCosts` parameter for cost data collection
- Improved Azure Advisor integration
- Enhanced network topology diagrams with more details
- Added support for additional resource types

### Improvements
- Optimized performance for large subscriptions
- Reduced memory usage during report generation
- Enhanced Excel report formatting and readability
- Better error handling and reporting

## Version 3.5.0

### New Features
- Added support for Azure Arc servers
- Enhanced diagram generation with organization view
- Added support for Flex databases (MySQL, PostgreSQL)
- Improved tag collection and reporting

### Improvements
- Faster data collection using Resource Graph
- Better formatting in Excel reports
- Enhanced error handling
- Added more details to virtual machine reporting

## Version 3.0.0

### Major Changes
- Complete rewrite as a PowerShell module
- Published to PowerShell Gallery for easier installation
- Added automation capabilities
- Enhanced reporting format

### New Features
- Diagram generation for network topology
- Security Center integration
- Azure Policy integration
- Support for resource tags

## Version 2.0.0

### Major Changes
- Expanded resource type coverage
- Improved Excel report format
- Added support for multiple subscriptions

### New Features
- Subscription filtering
- Resource group filtering
- Performance improvements
- Enhanced error handling

## Version 1.0.0

### Initial Release
- Basic inventory capabilities
- Support for core Azure resources
- Excel report generation
- Simple filtering options

## Pre-Release History

Early development versions of ARI were used internally at Microsoft before the public release.

## Reporting Issues

If you encounter problems with any version of ARI, please report them on the [GitHub Issues page](https://github.com/microsoft/ARI/issues).

## Contributing

Interested in contributing to future versions? See our [Contributing Guide](../development/contributing.md). 