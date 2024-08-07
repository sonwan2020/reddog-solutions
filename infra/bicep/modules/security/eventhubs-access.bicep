/* Parameters */
param eventHubsNamespaceName string
param principalId string

/* Variables */
var eventHubsRoleDefinitionsIds = [
  'a638d3c7-ab3a-418d-83e6-5f17a39d4fde' // Event Hubs Data Receiver
  '2b629674-e913-4c01-ae53-ef4638d8f975' // Event Hubs Data Sender
]

/* Existing resource */
resource eventHubs 'Microsoft.EventHub/namespaces@2024-01-01' existing = {
  name: eventHubsNamespaceName
}

/* Resource */
resource eventHubsRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for eventHubsRoleDefinitionId in eventHubsRoleDefinitionsIds: {
  name: guid(eventHubsRoleDefinitionId, eventHubs.name, principalId)
  properties: {
    principalId: principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', eventHubsRoleDefinitionId)
  }
}]
