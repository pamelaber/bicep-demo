// Module to deploy an Azure Function with VNet integration and no public access
@description('Azure region for the Function App.')
param location string = 'eastus'

@description('The name of the Azure Function.')
param functionName string = 'function${uniqueString(resourceGroup().id)}'

@description('The ID of the subnet for VNet integration.')
param subnetId string

@description('The SKU for the App Service Plan.Provide a valid SKU for Vnet integration')
param appServicePlanSku string = 'EP1'

@description('The tier for the App Service Plan.Provide a valid SKU for Vnet integration')
param appServicePlanTier string = 'PremiumV2'

@description('The number of instances for the App Service Plan.')
param appServicePlanCapacity int = 1

@description('Set to true for Linux-based App Service Plans.')
param appServicePlanReserved bool = false

// Deploy the App Service Plan (default Premium Tier for vnet integration)
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
    serverFarmId: appServicePlan.id
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
    ipSecurityRestrictionsDefaultAction: 'Allow' 
  }
}

module privateEndpointModule 'privateEndpoint.bicep' = {
  name: '${functionName}-privateEndpoint'
  params: {
    location: location
    subnetId: subnetId
    privateLinkServiceId: functionApp.id
    groupIds: ['sites']
  }
}

// Output for the Azure Function's resource ID
output functionAppResourceId string = resourceId('Microsoft.Web/sites', functionName)
