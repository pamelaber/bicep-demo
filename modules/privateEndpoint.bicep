param location string
param privateLinkServiceId string
param subnetId string
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
