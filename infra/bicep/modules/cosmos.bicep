param location string = resourceGroup().location
param cosmosAccountName string
param cosmosDatabaseName string

resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2021-06-15' = {
  name: cosmosAccountName
  kind: 'GlobalDocumentDB'
  location: location
  properties: {
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    locations: [
      {
        locationName: location
      }
    ]
    databaseAccountOfferType: 'Standard'
    disableLocalAuth: false
  }
}

resource cosmosDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2021-06-15' = {
  parent: cosmosAccount
  name: cosmosDatabaseName
  properties: {
    resource: {
      id: cosmosDatabaseName
    }
  }
}

output cosmosUri string = 'https://${cosmosAccountName}.documents.azure.com:443/'
output cosmosAccountName string = cosmosAccountName
