# Deployment Guide

## Prerequisites

Before deploying the resources, ensure the following prerequisites are met:

1. **Virtual Network (VNet)**: A Virtual Network must be created in advance.
2. **Subnet**: A Subnet within the VNet must also be created beforehand.
3. **Resource Group**: A Resource Group must exist where the resources will be deployed.

### Overview
The `keyVault.bicep` module deploys an Azure Key Vault with the following features:
- **Private Endpoint Integration**: Ensures secure communication by restricting access to a specific subnet.
- **Public Network Access Disabled**: Enhances security by denying all public access.
- **Access Policies**: Configures access policies for specific object IDs with defined permissions.
- **Virtual Network Rules**: Restricts access to the Key Vault from a specific subnet.

## Function App Module (`function.bicep`)

### Overview
The `function.bicep` module deploys an Azure Function App with the following features:
- **VNet Integration**: Ensures secure communication by integrating the Function App with a virtual network.
- **Public Network Access Disabled**: Enhances security by restricting access to the Function App.
- **App Service Plan**: Deploys a Premium App Service Plan for VNet integration.
- **Key Vault Integration**: Configures the Function App to use the deployed Key Vault.

## Configuration Details for Function

- **Supported SKUs**: The following SKUs are recommended for Function App VNet Integration:
    - **Premium Plan (Elastic Premium)**: EP1, EP2, EP3.
    - **App Service Plan**: P1v2, P2v2, P3v2.
    - Ensure the selected SKU meets the performance and scaling requirements of your application.
- **Linux Plan Parameter**: Set the `linux` parameter to `true` in the deployment configuration if deploying on a Linux-based plan.
- **Windows Plan Parameter**: Set the `linux` parameter to `false` in the deployment configuration if deploying on a Windows-based plan.


## Deployment Command
### Deployment Command
To deploy the `main.bicep` file, which orchestrates the deployment of the Key Vault and Function App, use the following command:

## Using a Parameters File

To deploy the resources with a parameters file, use the following Azure CLI command:

```bash
az deployment group create --resource-group <your-resource-group> --template-file main.bicep --parameters @parameters.json
```



