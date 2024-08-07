targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

@description('The name appended to each resource to ensure uniqueness.')
param uniqueServiceName string

param resourceGroupName string
param cosmosDatabaseName string = 'reddog'
param blobContainerName string = 'receipts'
param includeOpenAI string = 'true'
param dbName string = 'reddog'
param adminLogin string = 'reddog'
@secure()
param adminPassword string
param nodeCount int = 5


var abbrs = loadJsonContent('./abbreviations.json')

// tags that should be applied to all resources.
var tags = {
  // Tag all resources with the environment name.
  'azd-env-name': environmentName
}

var resourceToken = replace(uniqueServiceName, '-', '')
var keyVaultName = '${abbrs.keyVaultVaults}${resourceToken}'
// var cognitiveServicesAccountName = '${abbrs.cognitiveServicesAccounts}${resourceToken}'
var cosmosAccountName = '${abbrs.documentDBDatabaseAccounts}${resourceToken}'
var eventHubsNamespaceName = '${abbrs.dBforMySQLServers}${resourceToken}'

// Organize resources in a resource group
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: !empty(resourceGroupName) ? resourceGroupName : '${abbrs.resourcesResourceGroups}${environmentName}'
  location: location
  tags: tags
}

// The Azure Container Registry to hold the images
module acr './modules/acr.bicep' = {
  name: 'container-registry'
  scope: rg
  params: {
    location: location
    name: '${abbrs.containerRegistryRegistries}${resourceToken}'
    tags: tags
    anonymousPullEnabled: true
    sku: {
      name: 'Standard'
    }
  }
}

// Top Level Resources
module keyVault './modules/keyvault.bicep' = {
  name: 'keyvault'
  scope: rg
  params: {
    keyVaultName: keyVaultName
  }
}

module cosmos './modules/cosmos.bicep' = {
  name: 'cosmos'
  scope: rg
  params: {
    cosmosAccountName: cosmosAccountName
    cosmosDatabaseName: cosmosDatabaseName
  }
}

module openAI './modules/openai.bicep' = if (includeOpenAI == 'true') {
  name: 'openai'
  scope: rg
  params: {
    openAIServiceName: '${abbrs.cognitiveServicesAccounts}${resourceToken}'
  }
}

module redis './modules/redis.bicep' = {
  name: 'redis'
  scope: rg
  params: {
    redisName: '${abbrs.cacheRedis}${resourceToken}'
  }
}

module storage './modules/storage.bicep' = {
  name: 'storage'
  scope: rg
  params: {
    storageAccountName: '${abbrs.storageStorageAccounts}${resourceToken}'
    blobContainerName: blobContainerName
  }
}

module mySql './modules/mysql.bicep' = {
  name: 'mysql'
  scope: rg
  params: {
    servername: '${abbrs.dBforMySQLServers}${resourceToken}'
    adminLogin: adminLogin
    adminPassword: adminPassword
    dbName: dbName
  }
}

module eventHub './modules/eventhub.bicep' = {
  name: 'eventhub'
  scope: rg
  params: {
    eventHubNamespaceName: eventHubsNamespaceName
    eventHubName: 'reddog'
  }
}

module serviceBus './modules/servicebus.bicep' = {
  name: 'servicebus'
  scope: rg
  params: {
    serviceBusNamespaceName: '${abbrs.serviceBusNamespaces}${resourceToken}'
  }
}

// get keys from the openAi and cosmosdb
// module getKeys './modules/app/get-keys.bicep' = {
//   name: 'get-keys'
//   scope: rg
//   params:{
//     keyVaultName: keyVaultName
//     openAiName: cognitiveServicesAccountName
//   }
// }

module aks './modules/aks-cluster.bicep' = {
  name: 'aks'
  scope: rg
  params: {
    name: '${abbrs.containerServiceManagedClusters}${resourceToken}'
    nodeCount: nodeCount
    keyVaultName: keyVaultName
    cosmosAccountName: cosmosAccountName
    eventHubNamespaceName: eventHubsNamespaceName
  }
}

// Outputs
// output keyVaultName string = keyVaultName
// output keyVaultUri string = keyVault.outputs.keyVaultUri
// output cosmosAccountName string = cosmos.outputs.cosmosAccountName
// output storageAccountName string = storage.outputs.storageAccountName
// output storageAccountKey string = storage.outputs.accessKey
// output redisHost string = redis.outputs.redisHost
// output redisPassword string = redis.outputs.redisPassword
// output mySqlFQDN string = mySql.outputs.mySqlFQDN
// output eventHubEndPoint string = eventHub.outputs.eventHubEndPoint
// output eventHubNamespaceName string = eventHub.outputs.eventHubNamespaceName
// output sbConnectionString string = serviceBus.outputs.rootConnectionString
output openAIName string = includeOpenAI == 'true' ? openAI.outputs.openAIName : ''
output AZURE_LOCATION string = location
output AZURE_TENANT_ID string = tenant().tenantId
output AZURE_SUBSCRIPTION_ID string = subscription().subscriptionId
output AZURE_RESOURCE_GROUP string = rg.name
output AZURE_AKS_CLUSTER_NAME string = aks.outputs.name
output AZURE_CONTAINER_REGISTRY_ENDPOINT string = acr.outputs.loginServer
output AZURE_CONTAINER_REGISTRY_NAME string = acr.outputs.name
output AZURE_COSMOS_URL string = cosmos.outputs.cosmosUri
output AZURE_COSMOS_DATABASE string = cosmosDatabaseName
output AZURE_COSMOS_ACCOUNT_NAME string = cosmos.outputs.cosmosAccountName
output AZURE_REDIS_HOST string = redis.outputs.redisHost
output AZURE_MYSQL_FQDN string = mySql.outputs.mySqlFQDN
output AZURE_EVENTHUBS_ENDPOINT string = eventHub.outputs.eventHubEndPoint
output AZURE_EVENTHUBS_NAMESPACE_NAME string = eventHub.outputs.eventHubNamespaceName
output AZURE_STORAGE_ACCOUNT_NAME string = storage.outputs.storageAccountName
output AZURE_KEY_VAULT_NAME string = keyVaultName
output AZURE_KEY_VAULT_ENDPOINT string = keyVault.outputs.keyVaultUri
