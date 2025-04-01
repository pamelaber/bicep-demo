@description('The location for the private endpoint.')
param location string
@description('The ID of the private link service.')
param privateLinkServiceId string
@description('The ID of the subnet for the private endpoint.')
param subnetId string
@description('The group IDs for the private link service connection.')
param groupIds array

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: '${uniqueString(privateLinkServiceId)}-pe'
  location: location
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${uniqueString(privateLinkServiceId)}-connection'
        properties: {
          privateLinkServiceId: privateLinkServiceId
          groupIds: groupIds
        }
      }
    ]
  }
}

output privateEndpointId string = privateEndpoint.id
