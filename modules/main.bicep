@description('The location for the resources.')
param location string = 'eastus'

@description('The name of the Key Vault.')
param keyVaultName string

@description('The ID of the subnet for private access.')
param subnetId string
/*
@description('The permissions for secrets in the Key Vault.')
param secretPermissions array = [
  'get'
]

@description('The object ID for the Key Vault access policy.')
param objectId string
*/
@description('The name of the Function App.')
param functionAppName string

@description('The SKU for the App Service Plan.')
param appServicePlanSku string = 'P1v2'

@description('The tier for the App Service Plan.')
param appServicePlanTier string = 'PremiumV2'

@description('The number of instances for the App Service Plan.')
param appServicePlanCapacity int = 1

@description('Set to true for Linux-based App Service Plans.')
param appServicePlanReserved bool = false


module keyVaultModule './keyVault.bicep' = {
  name: 'keyVaultDeployment'
  params: {
    location: location
    keyVaultName: keyVaultName
    subnetId: subnetId
    //secretPermissions: secretPermissions
    //objectId: objectId
  }
}

module functionAppModule 'function.bicep' = {
  name: 'functionAppDeployment'
  params: {
    location: location
    functionName: functionAppName
    subnetId: subnetId
    appServicePlanSku: appServicePlanSku
    appServicePlanTier: appServicePlanTier
    appServicePlanCapacity: appServicePlanCapacity
    appServicePlanReserved: appServicePlanReserved
  }
}

output functionAppId string = functionAppModule.outputs.functionAppResourceId


output keyVaultId string = keyVaultModule.outputs.keyVaultId
