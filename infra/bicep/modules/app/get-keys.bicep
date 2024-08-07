param openAiName string = ''
param openAiKeyName string = 'AZURE-OPENAI-KEY'
param cosmosAccountName string = ''
param cosmosKeyName string = 'SPRING-CLOUD-AZURE-COSMOS-KEY'
param keyVaultName string

resource account 'Microsoft.CognitiveServices/accounts@2023-05-01' existing = if (!empty(openAiName)) {
  name: openAiName
}

resource cosmos 'Microsoft.DocumentDB/databaseAccounts@2022-08-15' existing = if (!empty(cosmosAccountName)) {
  name: cosmosAccountName
}

// create key vault secrets
module openAiKey '../security/keyvault-secret.bicep' = if (!empty(openAiName)) {
  name: 'openAiKey'
  params: {
    name: openAiKeyName
    keyVaultName: keyVaultName
    secretValue: account.listKeys().key1
  }
}

module cosmosKey '../security/keyvault-secret.bicep' = if (!empty(cosmosAccountName)) {
  name: 'cosmosKey'
  params: {
    name: cosmosKeyName
    keyVaultName: keyVaultName
    secretValue: cosmos.listKeys().primaryMasterKey
  }
}

output openAiKey string = openAiKeyName
output cosmosKey string = cosmosKeyName
