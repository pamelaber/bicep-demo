@description('The location for the Key Vault.')
param location string = 'eastus'

@description('The name of the Key Vault.')
param keyVaultName string

@description('The ID of the subnet for private access.')
param subnetId string

//@description('The permissions for secrets in the Key Vault.')
//param secretPermissions array = [
//  'get'
//]
//@description('The object ID for the Key Vault access policy.')
//param objectId string

resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId 
    accessPolicies: [] 
    publicNetworkAccess: 'Disabled' // Disable public network access
    networkAcls: {
      defaultAction: 'Deny' // Explicitly deny all public access
      bypass: 'None' // No bypass rules for trusted services
      virtualNetworkRules: [
        {
          id: subnetId // Allow access only from the specified subnet
        }
      ]
      ipRules: []
    }
  }
}
/*
resource keyVaultAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2021-10-01' = {
  parent: keyVault
  name: 'add'
  properties: {
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: objectId
        permissions: {
          secrets: secretPermissions 
        }
      }
    ]
  }
}
*/
module privateEndpointModule './privateEndpoint.bicep' = {
  name: '${keyVaultName}-privateEndpoint'
  params: {
    location: location
    privateLinkServiceId: keyVault.id
    subnetId: subnetId
    groupIds: ['vault']
  }
}

output keyVaultId string = keyVault.id
