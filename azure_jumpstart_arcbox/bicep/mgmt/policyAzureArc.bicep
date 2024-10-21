@description('Location of your Azure resources')
param azureLocation string

@description('Name of your log analytics workspace')
param logAnalyticsWorkspaceId string

@description('The flavor of ArcBox you want to deploy. Valid values are: \'Full\', \'ITPro\', \'DevOps\'')
param flavor string

@description('Tags to assign for all ArcBox resources')
param resourceTags object = {
  Solution: 'jumpstart_arcbox'
}

@description('Name (GUID) of the Hybrid Windows VMs AMA policy definition')
param amaWindowsHybridVmsPolicyDefinitionId string

@description('Name (GUID) of the Hybrid Linux VMs AMA policy definition')
param amaLinuxHybridVmsPolicyDefinitionId string

@description('Name (GUID) of the Hybrid SQL VMs AMA policy definition')
param amaSqlHybridVmsPolicyDefinitionId string

param sshPostureControlAzurePolicyId string = '/providers/Microsoft.Authorization/policyDefinitions/a8f3e6a6-dcd2-434c-b0f7-6f309ce913b4'
param tagsRoleDefinitionId string = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'


var arcboxClientVm = resourceId('Microsoft.Compute/virtualMachines', 'ArcBox-Client')
var dataCollectionRulesConfig = [
  {
    name: 'Windows'
    dataSources: loadJsonContent('windowsDcr.json', 'dataSources')
    dataFlows: loadJsonContent('windowsDcr.json', 'dataFlows')
  }
  {
    name: 'Linux'
    dataSources: loadJsonContent('linuxDcr.json', 'dataSources')
    dataFlows: loadJsonContent('linuxDcr.json', 'dataFlows')
  }
  {
    name: 'SQL'
    dataSources: loadJsonContent('sqlDcr.json', 'dataSources')
    dataFlows: loadJsonContent('sqlDcr.json', 'dataFlows')
  }
]

var policies = [
  {
    name: '(ArcBox) Deploy Monitoring and Governance for Windows-Arc VMs'
    definitionId: amaWindowsHybridVmsPolicyDefinitionId
    flavors: [
      'Full'
      'ITPro'
    ]
    roleDefinition:  [
      '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293' // Log Analytics Contributor
      '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/cd570a14-e51a-42ad-bac8-bafd67325302' // Connected Machine Admin
      '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa' // Monitoring Contributor
      '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/39bc4728-0917-49c7-9d2c-d95423bc2eb4' // Security Reader
    ]
    notScopes: [
      arcboxClientVm
    ]
    parameters: {
      dcrResourceId: {
        value: dataCollectionRules[0].id
      }
      enableProcessesAndDependencies: {
        value: true
      }
    }
  }
  {
    name: '(ArcBox) Deploy Monitoring and Governance for Linux-Arc VMs'
    definitionId: amaLinuxHybridVmsPolicyDefinitionId
    flavors: [
      'Full'
      'ITPro'
    ]
    roleDefinition:  [
      '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293' // Log Analytics Contributor
      '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/cd570a14-e51a-42ad-bac8-bafd67325302' // Connected Machine Admin
      '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa' // Monitoring Contributor
      '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/39bc4728-0917-49c7-9d2c-d95423bc2eb4' // Security Reader
    ]
    notScopes: []
    parameters: {
      dcrResourceId: {
        value: dataCollectionRules[1].id
      }
    }
  }
  {
    name: '(ArcBox) Deploy Microsoft Defender for Arc-Enabled SQL Servers'
    definitionId: amaSqlHybridVmsPolicyDefinitionId
    flavors: [
      'Full'
      'ITPro'
    ]
    roleDefinition: [      
      '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293' // Log Analytics Contributor
      '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/cd570a14-e51a-42ad-bac8-bafd67325302' // Connected Machine Admin
      '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa' // Monitoring Contributor
      '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/39bc4728-0917-49c7-9d2c-d95423bc2eb4' // Security Reader
    ]
    notScopes: []
    parameters: {
      workspaceRegion: {
        value: azureLocation
      }
      workspaceResourceId: {
        value: logAnalyticsWorkspaceId
      }
      dcrResourceId: {
        value: dataCollectionRules[2].id
      }
    }
  }
  {
    name: '(ArcBox) Enable Microsoft Defender on Kubernetes clusters'
    definitionId: '/providers/Microsoft.Authorization/policyDefinitions/708b60a6-d253-4fe0-9114-4be4c00f012c'
    flavors: [
      'Full'
      'DevOps'
    ]
    roleDefinition: [
      '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293'
    ]
    notScopes: []
    parameters: {}
  }
]

var roleDefintion = [for roledef in policies: roledef.roleDefinition]
var uniqueRoleDefintion = union(flatten([roleDefintion]), [])
var rd = union(flatten(uniqueRoleDefintion), [])


resource userIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: 'arcbox-policies-identity'
  tags: resourceTags
  location: azureLocation
}

resource arcboxIdentityRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = [for (role, i) in rd: {
  name: guid('arcbox-policies-identity', '${rd[i]}', subscription().subscriptionId)
  properties: {
    description: 'All Policy Assignments Created as part of this deployment will use the same Managed Identity'
    roleDefinitionId: '${rd[i]}'
    principalId: userIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}]

resource policies_name 'Microsoft.Authorization/policyAssignments@2021-06-01' = [for item in policies: if (contains(item.flavors, flavor)) {
  dependsOn: [arcboxIdentityRoleAssignment]
  name: item.name
  location: azureLocation
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userIdentity.id}': {}
    }
  }
  properties: {
    policyDefinitionId: any(item.definitionId)
    parameters: item.parameters
    notScopes: item.notScopes 
  }
}]

resource applyCustomTags 'Microsoft.Authorization/policyAssignments@2021-06-01' = [for (tag,i) in items(resourceTags): {
  name: '(ArcBox) Tag resources-${tag.key}'
  location: azureLocation
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    policyDefinitionId: any('/providers/Microsoft.Authorization/policyDefinitions/4f9dc7db-30c1-420c-b61a-e1d640128d26')
    parameters:{
      tagName: {
        value: tag.key
      }
      tagValue: {
        value: tag.value
      }
    }
  }
}]

resource policy_tagging_resources 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = [for (tag,i) in items(resourceTags): {
  name: guid(applyCustomTags[i].name, tagsRoleDefinitionId,resourceGroup().id)
  properties: {
    roleDefinitionId: tagsRoleDefinitionId
    principalId: applyCustomTags[i].identity.principalId
    principalType: 'ServicePrincipal'
  }
}]

resource sshPostureControlAudit  'Microsoft.Authorization/policyAssignments@2024-04-01' = {
  name: '(ArcBox) Enable SSH Posture Control audit'
  location: azureLocation
  scope: resourceGroup()
  properties:{
    displayName: '(ArcBox) Enable SSH Posture Control audit'
    description: 'Enable SSH Posture Control in audit mode'
    policyDefinitionId: sshPostureControlAzurePolicyId
    parameters: {
      IncludeArcMachines: {
        value: 'true'
      }
    }
  }
}

resource dataCollectionRules 'Microsoft.Insights/dataCollectionRules@2023-03-11' = [for os in dataCollectionRulesConfig: if (flavor == 'ITPro' || flavor == 'Full') {
  name: os.name
  location: azureLocation
  tags: resourceTags
  properties: {
    dataSources: os.dataSources
    destinations: {
      logAnalytics: [
        {
          name: '${os.name}-Dest'
          workspaceResourceId: logAnalyticsWorkspaceId
        }
      ]
    }
    dataFlows: os.dataFlows
  }
}]


output policies_managed_identity string = userIdentity.properties.principalId
