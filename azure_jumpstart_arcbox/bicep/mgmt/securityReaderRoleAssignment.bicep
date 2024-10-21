targetScope = 'subscription'

@description('Managed Identity Applied to ArcBox Policy Assignments')
param policies_managed_identity string

var roleDefinitionId = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/39bc4728-0917-49c7-9d2c-d95423bc2eb4'


resource arcboxIdentitySecurityReaderSubscriptionRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid('subscription-security-reader', '39bc4728-0917-49c7-9d2c-d95423bc2eb4', subscription().subscriptionId)
  properties: {
    description: 'All Policy Assignments Created as part of this deployment will use the same Managed Identity'
    roleDefinitionId: roleDefinitionId
    principalId: policies_managed_identity
    principalType: 'ServicePrincipal'
  }
}
