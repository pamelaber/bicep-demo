// Module to deploy a Key Vault with private access only
param location string = 'eastus'
param keyVaultName string
param subnetId string // Subnet ID for private access,already exists
//param objectId string // Object ID of the Function App
param secretPermissions array = [
  'get' // Default permission to allow retrieving secrets
]
// Deploy the Key Vault
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

// Add an access policy for the Function App
/*
resource keyVaultAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2021-10-01' = {
  name: '${keyVault.name}/add'
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
module privateEndpointModule 'modules/privateEndpoint.bicep' = {
  name: '${keyVaultName}-privateEndpoint'
  params: {
    zoneName: 'privatelink.vaultcore.azure.net'
    location: location
    privateLinkServiceId: keyVault.id // Target the Key Vault
    subnetId: subnetId // Reference the subnet for the private endpoint
    groupIds: ['vault']
  }
}

output keyVaultId string = keyVault.id // Output the Key Vault ID
