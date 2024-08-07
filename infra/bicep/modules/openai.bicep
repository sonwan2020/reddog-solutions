param openAIServiceName string
param location string = resourceGroup().location
param sku string = 'S0'

resource openAIService 'Microsoft.CognitiveServices/accounts@2022-12-01' = {
  name: openAIServiceName
  location: location
  sku: {
    name: sku
  }
  kind: 'OpenAI'
  properties: {
    publicNetworkAccess: 'Enabled'
    apiProperties: {
      statisticsEnabled: false
    }
  }
}

resource openAIGPT35TurboInstructModel 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
  name: 'gpt-35-turbo'
  parent: openAIService
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-35-turbo'
      version: '0613'
    }
  }
  sku: {
    name: 'Standard'
    capacity: 30
  }
}

output openAIName string = openAIServiceName
