// Module to deploy an Azure Function with VNet integration and no public access

param location string = 'eastus' // Azure region
param functionName string = 'function${uniqueString(resourceGroup().id)}'param subnetId string // Subnet ID for VNet integration
param appServicePlanSku string = 'EP1' // SKU for the App Service Plan
param appServicePlanTier string = 'PremiumV2' // Tier for the App Service Plan
param appServicePlanCapacity int = 1 // Number of instances for the App Service Plan
param appServicePlanReserved bool = false // Set to true for Linux-based plans
param subnetId string // Subnet ID for VNet integration

// Deploy the App Service Plan (Premium Tier for vnet integration)
resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
name: '${functionName}-asp' 
location: location
kind: 'functionapp'
sku: {
name: appServicePlanSku
tier: appServicePlanTier
capacity: appServicePlanCapacity
}
properties: {
reserved: appServicePlanReserved
}
}

// Deploy the Azure Function
resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
name: functionName
location: location
kind: 'functionapp'
identity: {
type: 'SystemAssigned'
}
properties: {
serverFarmId: appServicePlan.id // Reference the Premium App Service Plan
siteConfig: {
vnetRouteAllEnabled: true 
scmIpSecurityRestrictionsUseMain: false
ipSecurityRestrictions: []
}
publicNetworkAccess: 'Disabled' // Disable public network access
}
}

// Configure site settings
resource functionAppConfig 'Microsoft.Web/sites/config@2024-04-01' = {
name: 'web'
parent: functionApp
properties: {
publicNetworkAccess: 'Disabled' // Disable public network access
ipSecurityRestrictionsDefaultAction: 'Allow' // Allow IP restrictions by default
}
}

// Use the private endpoint module
module privateEndpointModule './privateEndpoint.bicep' = {
name: '${functionName}-privateEndpoint'
params: {
location: location
subnetId: subnetId // Ensure subnetId is passed correctly
targetResourceId: functionApp.id
groupIds: ['sites'] // Group ID for Azure Function private endpoint
}
}

// Output for the Azure Function's resource ID
output functionAppResourceId string = resourceId('Microsoft.Web/sites', functionName)
