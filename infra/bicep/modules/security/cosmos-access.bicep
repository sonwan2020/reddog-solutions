metadata description = 'Creates a cosmos role assignment for a service principal.'
param principalId string

@description('Friendly name for the SQL Role Definition')
param roleDefinitionName string = 'My Read Write Role'

@description('Data actions permitted by the Role Definition')
param dataActions array = [
  'Microsoft.DocumentDB/databaseAccounts/readMetadata'
  'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/*'
  'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/*'
]

param cosmosAccountName string

resource cosmos 'Microsoft.DocumentDB/databaseAccounts@2022-08-15' existing = if (!empty(cosmosAccountName)) {
  name: cosmosAccountName
}

var roleDefinitionId = guid('sql-role-definition-', principalId, cosmos.id)
var roleAssignmentId = guid(roleDefinitionId, principalId, cosmos.id)

resource sqlRoleDefinition 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2021-04-15' = {
  parent: cosmos
  name: roleDefinitionId
  properties: {
    roleName: roleDefinitionName
    type: 'CustomRole'
    assignableScopes: [
      cosmos.id
    ]
    permissions: [
      {
        dataActions: dataActions
      }
    ]
  }
}

resource sqlRoleAssignment 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2021-04-15' = {
  name: roleAssignmentId
  parent: cosmos
  properties: {
    roleDefinitionId: sqlRoleDefinition.id
    principalId: principalId
    scope: cosmos.id
  }
}
