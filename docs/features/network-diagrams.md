# Network Diagrams

Azure Resource Inventory (ARI) creates interactive network topology diagrams that provide a visual representation of your Azure networking environment. This page explains the diagram types, features, and usage.

## Diagram Overview

ARI generates network diagrams in Draw.io format, offering visual insights into your Azure network architecture. These diagrams are designed to be:

- **Interactive**: Clickable elements with detailed information on hover
- **Comprehensive**: Complete view of network resources and their relationships
- **Exportable**: Easy to export to various formats for documentation
- **Customizable**: Editable in Draw.io for further refinement

<div align="center">
<img src="../../images/DrawioImage.png" width="800">
</div>

## Diagram Types

### Network Topology View

The main network diagram displays all virtual networks, subnets, peerings, gateways, and connections between resources:

<div align="center">
<img src="../../images/DrawioImage.png" width="700">
</div>

Interactive features show resource details on hover:

<div align="center">
<img src="../../images/ARIv3DrawioHover.png" width="400">
<img src="../../images/ARIv3DrawioPeer.png" width="400">
</div>

### Organization View

The organization view displays your Azure hierarchy from management groups down to resource groups:

<div align="center">
<img src="../../images/DrawioOrganization.png" width="700">
</div>

### Resources View

The resources view presents subscriptions with their contained resources:

<div align="center">
<img src="../../images/drawiosubs.png" width="700">
</div>

## Diagram Generation

By default, ARI creates network diagrams when you run `Invoke-ARI`. You can control diagram generation with these parameters:

### Skip Diagram Creation

If you're only interested in the Excel report or want faster execution, you can skip diagram generation:

```powershell
Invoke-ARI -SkipDiagram
```

### Generate Full Environment Diagram

For a more comprehensive diagram that includes all network components:

```powershell
Invoke-ARI -DiagramFullEnvironment
```

This option includes additional details such as:
- All interconnections between resources
- Load balancers and their backend pools
- Application gateways and their configurations
- Additional network security details

## Working with Diagrams

### Viewing Diagrams

The generated `.drawio` files can be opened with:
- [Draw.io desktop application](https://github.com/jgraph/drawio-desktop/releases)
- [Draw.io web interface](https://app.diagrams.net/)
- [VS Code with Draw.io extension](https://marketplace.visualstudio.com/items?itemName=hediet.vscode-drawio)

### Interactive Features

When viewing the diagram, you can:
- Click on resources to select them
- Hover over resources to see detailed information
- Zoom in/out for different levels of detail
- Drag resources to rearrange the layout
- Export to various formats (PNG, PDF, SVG, etc.)

### Diagram Customization

After opening in Draw.io, you can customize the diagrams:
- Change colors and styles
- Add additional information or annotations
- Rearrange elements for better presentation
- Add or remove elements as needed

## Diagram Outputs

The diagrams are saved in the same directory as the Excel report, or to the location specified with the `-ReportDir` parameter.

Three separate files are created:
1. Network topology diagram (Subnet-level details)
2. Organization hierarchy diagram
3. Subscription resources diagram

## Diagram Limitations

- Very large environments with many networks may result in complex diagrams
- Some resource properties may be abbreviated or simplified in the visualization
- Custom routes and complex networking patterns may require manual adjustments for clarity
- When using ARI with `-Automation`, diagrams are still generated but stored in blob storage 