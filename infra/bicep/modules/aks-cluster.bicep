param name string
param nodeCount int = 5
param vmSize string = 'Standard_D4_v3'
param location string = resourceGroup().location
@description('The name of the keyvault to grant access')
param keyVaultName string
param cosmosAccountName string
param eventHubNamespaceName string

resource aks 'Microsoft.ContainerService/managedClusters@2021-05-01' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: name
    enableRBAC: true
    agentPoolProfiles: [
      {
        name: 'agentpool1'
        count: nodeCount
        vmSize: vmSize
        osType: 'Linux'
        mode: 'System'
      }
    ]
  }
}

// Give the AKS Cluster access to KeyVault
module clusterKeyVaultAccess './security/keyvault-access.bicep' = if(!empty(keyVaultName)) {
  name: 'cluster-keyvault-access'
  params: {
    keyVaultName: keyVaultName
    principalId: aks.properties.identityProfile.kubeletidentity.objectId
  }
}

// Give the AKS Cluster access to Cosmos
module cosmosRoleAssignment './security/cosmos-access.bicep' = if (!empty(cosmosAccountName)) {
  name: 'cosmos-data-reader-role-assignment'
  params: {
    principalId: aks.properties.identityProfile.kubeletidentity.objectId
    cosmosAccountName: cosmosAccountName
  }
}

// Give the AKS Cluster access to Event Hubs
module eventHubsRoleAssignment './security/eventhubs-access.bicep' = if (!empty(eventHubNamespaceName)) {
  name: 'eventhubs-role-assignment'
  params: {
    principalId: aks.properties.identityProfile.kubeletidentity.objectId
    eventHubsNamespaceName: eventHubNamespaceName
  }
}

output name string = aks.name
