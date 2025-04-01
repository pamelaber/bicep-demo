param location string // Location of the private endpoint
param subnetId string // Subnet ID for the private endpoint
param targetResourceId string // ID of the target resource for the private endpoint
param groupIds array // Group IDs for the private endpoint

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
name: '${uniqueString(targetResourceId)}-pe'
location: location
properties: {
subnet: {
id: subnetId
}
privateLinkServiceConnections: [
{
name: '${uniqueString(targetResourceId)}-connection'
properties: {
privateLinkServiceId: targetResourceId
groupIds: groupIds
}
}
]
}
}
