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



param azureUpdateManagerArcPolicyId string = '/providers/Microsoft.Authorization/policyDefinitions/bfea026e-043f-4ff4-9d1b-bf301ca7ff46'
param azureUpdateManagerAzurePolicyId string = '/providers/Microsoft.Authorization/policyDefinitions/59efceea-0c96-497e-a4a1-4eb2290dac15'
param sshPostureControlAzurePolicyId string = '/providers/Microsoft.Authorization/policyDefinitions/a8f3e6a6-dcd2-434c-b0f7-6f309ce913b4'
param tagsRoleDefinitionId string = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
param arcboxClientVm string = resourceId('Microsoft.Compute/virtualMachines', 'ArcBox-Client')

var workspaceName = substring(logAnalyticsWorkspaceId, (lastIndexOf(logAnalyticsWorkspaceId, '/') + 1), (length(logAnalyticsWorkspaceId) - (lastIndexOf(logAnalyticsWorkspaceId, '/') + 1)))
var changeTrackingDcrDataSources = loadJsonContent('changeTrackingDcr.json', 'dataSources')
var changeTrackingDcrDataFlows = loadJsonContent('changeTrackingDcr.json', 'dataFlows')

var policies = [
  {
    name: '(ArcBox) Enable Azure Monitor for Windows Hybrid VMs with AMA'
    definitionId: amaWindowsHybridVmsPolicyDefinitionId
    flavors: [
      'Full'
      'ITPro'
    ]
    roleDefinition:  [
      '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293' // Log Analytics Contributor
      '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/cd570a14-e51a-42ad-bac8-bafd67325302' // Connected Machine Admin
      '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa' // Monitoring Contributor
    ]
    notScopes: []
    parameters: {
      dcrResourceId: {
        value: arcWindowsVmsDcr.id
      }
      enableProcessesAndDependencies: {
        value: true
      }
    }
  }
  {
    name: '(ArcBox) Enable Azure Monitor for Linux Hybrid VMs with AMA'
    definitionId: amaLinuxHybridVmsPolicyDefinitionId
    flavors: [
      'Full'
      'ITPro'
    ]
    roleDefinition:  [
      '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293' // Log Analytics Contributor
      '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/cd570a14-e51a-42ad-bac8-bafd67325302' // Connected Machine Admin
      '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa' // Monitoring Contributor
    ]
    notScopes: []
    parameters: {
      dcrResourceId: {
        value: arcLinuxVmsDcr.id
      }
    }
  }
  {
    name: '(ArcBox) Deploy Microsoft Defender for Endpoint Agent'
    definitionId: '/providers/Microsoft.Authorization/policySetDefinitions/e20d08c5-6d64-656d-6465-ce9e37fd0ebc'
    flavors: [
      'Full'
      'ITPro'
    ]
    roleDefinition: [
      '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293' // Log Analytics Contributor
      '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/cd570a14-e51a-42ad-bac8-bafd67325302' // Connected Machine Admin
      '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/39bc4728-0917-49c7-9d2c-d95423bc2eb4' // Security Reader
    ]
    notScopes: [
      arcboxClientVm
    ]
    parameters: {}
  }
  {
    name: '(ArcBox) Deploy Microsoft Defender for Arc-Enabled SQL Servers'
    definitionId: '/providers/Microsoft.Authorization/policyDefinitions/65503269-6a54-4553-8a28-0065a8e6d929'
    flavors: [
      'Full'
      'ITPro'
    ]
    roleDefinition: [      
      '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293' // Log Analytics Contributor
      '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/cd570a14-e51a-42ad-bac8-bafd67325302' // Connected Machine Admin
      '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/39bc4728-0917-49c7-9d2c-d95423bc2eb4' // Security Reader
    ]
    notScopes: []
    parameters: {}
  }
  {
    name: '(ArcBox) ChangeTracking and Inventory for Arc-enabled Servers'
    definitionId: '/providers/Microsoft.Authorization/policySetDefinitions/53448c70-089b-4f52-8f38-89196d7f2de1'
    flavors: [
      'Full'
      'ITPro'
    ]
    roleDefinition:  [
      '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293' // Log Analytics Contributor
      '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/cd570a14-e51a-42ad-bac8-bafd67325302' // Connected Machine Admin
      '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa' // Monitoring Contributor
    ]
    notScopes: []
    parameters: {
      dcrResourceId: {
        value: changeTrackingDcr.id
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

resource policies_name 'Microsoft.Authorization/policyAssignments@2021-06-01' = [for item in policies: if (contains(item.flavors, flavor)) {
  name: item.name
  location: azureLocation
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    policyDefinitionId: any(item.definitionId)
    notScopes: item.notScopes
    parameters: item.parameters
  }
}]

resource policy_Windows_AMA_log_analytics_contributor 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = if (contains(policies[0].flavors, flavor)) {
  name: guid( policies[0].name, policies[0].roleDefinition[0],resourceGroup().id)
  properties: {
    roleDefinitionId: any(policies[0].roleDefinition[0])
    principalId: contains(policies[0].flavors, flavor)?policies_name[0].identity.principalId:guid('policies_name_id${0}')
    principalType: 'ServicePrincipal'
  }
}

resource policy_Windows_AMA_connected_machine_admin 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = if (contains(policies[0].flavors, flavor)) {
  name: guid( policies[0].name, policies[0].roleDefinition[1],resourceGroup().id)
  properties: {
    roleDefinitionId: any(policies[0].roleDefinition[1])
    principalId: contains(policies[0].flavors, flavor)?policies_name[0].identity.principalId:guid('policies_name_id${0}')
    principalType: 'ServicePrincipal'
  }
}

resource policy_Windows_AMA_monitoring_contributor 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = if (contains(policies[0].flavors, flavor)) {
  name: guid( policies[0].name, policies[0].roleDefinition[2],resourceGroup().id)
  properties: {
    roleDefinitionId: any(policies[0].roleDefinition[2])
    principalId: contains(policies[0].flavors, flavor)?policies_name[0].identity.principalId:guid('policies_name_id${0}')
    principalType: 'ServicePrincipal'
  }
}


resource policy_Linux_AMA_log_analytics_contributor 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = if (contains(policies[1].flavors, flavor)) {
  name: guid( policies[1].name, policies[1].roleDefinition[0],resourceGroup().id)
  properties: {
    roleDefinitionId: any(policies[1].roleDefinition[0])
    principalId: contains(policies[1].flavors, flavor)?policies_name[1].identity.principalId:guid('policies_name_id${0}')
    principalType: 'ServicePrincipal'
  }
}

resource policy_Linux_AMA_connected_machine_admin 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = if (contains(policies[1].flavors, flavor)) {
  name: guid( policies[1].name, policies[1].roleDefinition[1],resourceGroup().id)
  properties: {
    roleDefinitionId: any(policies[1].roleDefinition[1])
    principalId: contains(policies[1].flavors, flavor)?policies_name[1].identity.principalId:guid('policies_name_id${0}')
    principalType: 'ServicePrincipal'
  }
}

resource policy_Linux_AMA_monitoring_contributor 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = if (contains(policies[1].flavors, flavor)) {
  name: guid( policies[1].name, policies[1].roleDefinition[2],resourceGroup().id)
  properties: {
    roleDefinitionId: any(policies[1].roleDefinition[2])
    principalId: contains(policies[1].flavors, flavor)?policies_name[1].identity.principalId:guid('policies_name_id${0}')
    principalType: 'ServicePrincipal'
  }
}

resource policy_defender_servers_log_analytics_contributor 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = if (contains(policies[2].flavors, flavor)) {
  name: guid( policies[2].name, policies[2].roleDefinition[0],resourceGroup().id)
  properties: {
    roleDefinitionId: any(policies[2].roleDefinition[0])
    principalId: contains(policies[2].flavors, flavor)?policies_name[2].identity.principalId:guid('policies_name_id${0}')
    principalType: 'ServicePrincipal'
  }
}

resource policy_defender_servers_connected_machine_admin 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = if (contains(policies[2].flavors, flavor)) {
  name: guid( policies[2].name, policies[2].roleDefinition[1],resourceGroup().id)
  properties: {
    roleDefinitionId: any(policies[2].roleDefinition[1])
    principalId: contains(policies[2].flavors, flavor)?policies_name[2].identity.principalId:guid('policies_name_id${0}')
    principalType: 'ServicePrincipal'
  }
}

resource policy_defender_servers_security_reader 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = if (contains(policies[2].flavors, flavor)) {
  name: guid( policies[2].name, policies[2].roleDefinition[2],resourceGroup().id)
  properties: {
    roleDefinitionId: any(policies[2].roleDefinition[2])
    principalId: contains(policies[2].flavors, flavor)?policies_name[2].identity.principalId:guid('policies_name_id${0}')
    principalType: 'ServicePrincipal'
  }
}

resource policy_defender_sql_log_analytics_contributor 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = if (contains(policies[3].flavors, flavor)) {
  name: guid( policies[3].name, policies[3].roleDefinition[0],resourceGroup().id)
  properties: {
    roleDefinitionId: any(policies[3].roleDefinition[0])
    principalId: contains(policies[3].flavors, flavor)?policies_name[3].identity.principalId:guid('policies_name_id${0}')
    principalType: 'ServicePrincipal'
  }
}

resource policy_defender_sql_connected_machine_admin 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = if (contains(policies[3].flavors, flavor)) {
  name: guid( policies[3].name, policies[3].roleDefinition[1],resourceGroup().id)
  properties: {
    roleDefinitionId: any(policies[3].roleDefinition[1])
    principalId: contains(policies[3].flavors, flavor)?policies_name[3].identity.principalId:guid('policies_name_id${0}')
    principalType: 'ServicePrincipal'
  }
}

resource policy_defender_sql_security_reader 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = if (contains(policies[3].flavors, flavor)) {
  name: guid( policies[3].name, policies[3].roleDefinition[2],resourceGroup().id)
  properties: {
    roleDefinitionId: any(policies[3].roleDefinition[2])
    principalId: contains(policies[3].flavors, flavor)?policies_name[3].identity.principalId:guid('policies_name_id${0}')
    principalType: 'ServicePrincipal'
  }
}

resource policy_change_tracking_log_analytics_contributor 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = if (contains(policies[4].flavors, flavor)) {
  name: guid( policies[4].name, policies[4].roleDefinition[0],resourceGroup().id)
  properties: {
    roleDefinitionId: any(policies[4].roleDefinition[0])
    principalId: contains(policies[4].flavors, flavor)?policies_name[4].identity.principalId:guid('policies_name_id${0}')
    principalType: 'ServicePrincipal'
  }
}

resource policy_change_tracking_connected_machine_admin 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = if (contains(policies[4].flavors, flavor)) {
  name: guid( policies[4].name, policies[4].roleDefinition[1],resourceGroup().id)
  properties: {
    roleDefinitionId: any(policies[4].roleDefinition[1])
    principalId: contains(policies[4].flavors, flavor)?policies_name[4].identity.principalId:guid('policies_name_id${0}')
    principalType: 'ServicePrincipal'
  }
}

resource policy_change_tracking_monitoring_contributor 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = if (contains(policies[4].flavors, flavor)) {
  name: guid( policies[4].name, policies[4].roleDefinition[2],resourceGroup().id)
  properties: {
    roleDefinitionId: any(policies[4].roleDefinition[2])
    principalId: contains(policies[4].flavors, flavor)?policies_name[4].identity.principalId:guid('policies_name_id${0}')
    principalType: 'ServicePrincipal'
  }
}


resource policy_defender_kubernetes 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = if (contains(policies[5].flavors, flavor)) {
  name: guid( policies[5].name, policies[5].roleDefinition[0],resourceGroup().id)
  properties: {
    roleDefinitionId: any(policies[5].roleDefinition)
    principalId: contains(policies[5].flavors, flavor)?policies_name[5].identity.principalId:guid('policies_name_id${0}')
    principalType: 'ServicePrincipal'
  }
}


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

resource updateManagerArcPolicyLinux 'Microsoft.Authorization/policyAssignments@2024-04-01' = {
  name: '(ArcBox) Enable Azure Update Manager for Linux hybrid machines'
  location: azureLocation
  scope: resourceGroup()
  identity: {
    type: 'SystemAssigned'
  }
  properties:{
    displayName: '(ArcBox) Enable Azure Update Manager for Arc-enabled Linux machines'
    description: 'Enable Azure Update Manager for Arc-enabled machines'
    policyDefinitionId: azureUpdateManagerArcPolicyId
    parameters: {
      osType: {
        value: 'Linux'
      }
    }
  }
}

resource updateManagerArcPolicyWindows 'Microsoft.Authorization/policyAssignments@2024-04-01' = {
  name: '(ArcBox) Enable Azure Update Manager for Windows hybrid machines'
  location: azureLocation
  scope: resourceGroup()
  identity: {
    type: 'SystemAssigned'
  }
  properties:{
    displayName: '(ArcBox) Enable Azure Update Manager for Arc-enabled Windows machines'
    description: 'Enable Azure Update Manager for Arc-enabled machines'
    policyDefinitionId: azureUpdateManagerArcPolicyId
    parameters: {
      osType: {
        value: 'Windows'
      }
    }
  }
}

resource updateManagerAzurePolicyWindows  'Microsoft.Authorization/policyAssignments@2024-04-01' = {
  name: '(ArcBox) Enable Azure Update Manager for Azure Windows machines'
  location: azureLocation
  scope: resourceGroup()
  identity: {
    type: 'SystemAssigned'
  }
  properties:{
    displayName: '(ArcBox) Enable Azure Update Manager for Azure Windows machines'
    description: 'Enable Azure Update Manager for Azure machines'
    policyDefinitionId: azureUpdateManagerAzurePolicyId
    parameters: {
      osType: {
        value: 'Windows'
      }
    }
  }
}

resource updateManagerAzurePolicyLinux  'Microsoft.Authorization/policyAssignments@2024-04-01' = {
  name: '(ArcBox) Enable Azure Update Manager for Azure Linux machines'
  location: azureLocation
  scope: resourceGroup()
  identity: {
    type: 'SystemAssigned'
  }
  properties:{
    displayName: '(ArcBox) Enable Azure Update Manager for Azure Linux machines'
    description: 'Enable Azure Update Manager for Azure machines'
    policyDefinitionId: azureUpdateManagerAzurePolicyId
    parameters: {
      osType: {
        value: 'Linux'
      }
    }
  }
}

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


resource arcWindowsVmsDcr 'Microsoft.Insights/dataCollectionRules@2023-03-11' = if (flavor == 'ITPro' || flavor == 'Full') {
  name: 'arcWindowsVmsDcr'
  location: azureLocation
  tags: resourceTags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dataSources: {
      performanceCounters: [
        {
          name: 'WindowsPerformanceCounters'
          samplingFrequencyInSeconds: 60
          streams: [
            'Microsoft-Perf'
          ]
          counterSpecifiers: [
            '\\Processor(*)\\*'
            '\\Memory\\*'
            '\\LogicalDisk(*)\\*'
            '\\PhysicalDisk(*)\\*'
            '\\Network Interface(*)\\*'
          ]
        }
      ]
      windowsEventLogs: [
        {
          name: 'WindowsEvents'
          streams: [
            'Microsoft-Event'
          ]
          xPathQueries: [
            'System!*[System[(Level=1  or Level=2 or Level=3)]]'
            'Security!*'
          ]
        }
      ]
    }
    dataFlows: [
      {
        streams: [
          'Microsoft-Event'
          'Microsoft-Perf'
        ]
        destinations: [
          'LogAnalytics'
        ]
      }
    ]
    destinations: {
      logAnalytics: [
        {
          name: 'LogAnalytics'
          workspaceResourceId: logAnalyticsWorkspaceId
        }
      ]
    }
  }
}

resource windows_dcr_log_analytics_contributor 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = if (flavor == 'ITPro' || flavor == 'Full') {
  name: guid( arcWindowsVmsDcr.name, '92aaf0da-9dab-42b6-94a3-d43ce8d16293', resourceGroup().id)
  properties: {
    roleDefinitionId: resourceId(subscription().subscriptionId, 'Microsoft.Authorization/roleDefinitions', '92aaf0da-9dab-42b6-94a3-d43ce8d16293')
    principalId: arcWindowsVmsDcr.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource dcr_connected_machine_admin 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = if (flavor == 'ITPro' || flavor == 'Full') {
  name: guid( arcWindowsVmsDcr.name, 'cd570a14-e51a-42ad-bac8-bafd67325302', resourceGroup().id)
  properties: {
    roleDefinitionId: resourceId(subscription().subscriptionId, 'Microsoft.Authorization/roleDefinitions', 'cd570a14-e51a-42ad-bac8-bafd67325302')
    principalId: arcWindowsVmsDcr.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource dcr_monitoring_contributor 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = if (flavor == 'ITPro' || flavor == 'Full') {
  name: guid( arcWindowsVmsDcr.name, '749f88d5-cbae-40b8-bcfc-e573ddc772fa', resourceGroup().id)
  properties: {
    roleDefinitionId: resourceId(subscription().subscriptionId, 'Microsoft.Authorization/roleDefinitions', '749f88d5-cbae-40b8-bcfc-e573ddc772fa')
    principalId: arcWindowsVmsDcr.identity.principalId
    principalType: 'ServicePrincipal'
  }
}






resource arcLinuxVmsDcr 'Microsoft.Insights/dataCollectionRules@2023-03-11' = if (flavor == 'ITPro' || flavor == 'Full') {
  name: 'arcLinuxVmsDcr'
  location: azureLocation
  tags: resourceTags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dataSources: {
      performanceCounters: [
        {
          name: 'LinuxPerformanceCounters'
          samplingFrequencyInSeconds: 60
          streams: [
            'Microsoft-Perf'
          ]
          counterSpecifiers: [
            'Processor:% Processor Time'
            'Processor:% User Time'
            'Processor:% Privileged Time'
            'Processor:% IO Wait Time'
            'Processor:% Idle Time'
            'Processor:% DPC Time'
            'System:Processes'
            'System:Free Physical Memory'
            'System:Free Virtual Memory'
            'Memory:% Available Memory'
            'Memory:% Used Memory'
            'Memory:Available MBytes Memory'
            'Memory:Used Memory MBytes'
            'LogicalDisk:% Used Space'
            'LogicalDisk:% Free Space'
            'LogicalDisk:Disk Writes/sec'
            'LogicalDisk:Disk Reads/sec'
            'Network:Total Bytes Transmitted'
            'Network:Total Bytes Received'
            'Network:Total Bytes'
          ]
        }
      ]
      syslog: [
        {
          name: 'Syslog'
          streams: [
            'Microsoft-Syslog'
          ]
          facilityNames: [
            'auth'
            'authpriv'
            'audit'
            'syslog'
            'user'
          ]
          logLevels: [
            'Info'
            'Error'            
          ]
        }
      ]
    }
    dataFlows: [
      {
        streams: [
          'Microsoft-Syslog'
          'Microsoft-Perf'
        ]
        destinations: [
          'LogAnalytics'
        ]
      }
    ]
    destinations: {
      logAnalytics: [
        {
          name: 'LogAnalytics'
          workspaceResourceId: logAnalyticsWorkspaceId
        }
      ]
    }
  }
}

resource linux_dcr_log_analytics_contributor 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = if (flavor == 'ITPro' || flavor == 'Full') {
  name: guid( arcLinuxVmsDcr.name, '92aaf0da-9dab-42b6-94a3-d43ce8d16293', resourceGroup().id)
  properties: {
    roleDefinitionId: resourceId(subscription().subscriptionId, 'Microsoft.Authorization/roleDefinitions', '92aaf0da-9dab-42b6-94a3-d43ce8d16293')
    principalId: arcLinuxVmsDcr.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource linux_dcr_connected_machine_admin 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = if (flavor == 'ITPro' || flavor == 'Full') {
  name: guid( arcLinuxVmsDcr.name, 'cd570a14-e51a-42ad-bac8-bafd67325302', resourceGroup().id)
  properties: {
    roleDefinitionId: resourceId(subscription().subscriptionId, 'Microsoft.Authorization/roleDefinitions', 'cd570a14-e51a-42ad-bac8-bafd67325302')
    principalId: arcLinuxVmsDcr.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource linux_dcr_monitoring_contributor 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = if (flavor == 'ITPro' || flavor == 'Full') {
  name: guid( arcLinuxVmsDcr.name, '749f88d5-cbae-40b8-bcfc-e573ddc772fa', resourceGroup().id)
  properties: {
    roleDefinitionId: resourceId(subscription().subscriptionId, 'Microsoft.Authorization/roleDefinitions', '749f88d5-cbae-40b8-bcfc-e573ddc772fa')
    principalId: arcLinuxVmsDcr.identity.principalId
    principalType: 'ServicePrincipal'
  }
}


resource changeTrackingSolution 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  name: 'ChangeTracking(${workspaceName})'
  location: azureLocation
  tags: resourceTags
  properties: {
    workspaceResourceId: logAnalyticsWorkspaceId
  }
  plan: {
    name: 'ChangeTracking(${workspaceName})'
    product: 'OMSGallery/ChangeTracking'
    promotionCode: ''
    publisher: 'Microsoft'
  }
}


resource changeTrackingDcr 'Microsoft.Insights/dataCollectionRules@2023-03-11' = if (flavor == 'ITPro' || flavor == 'Full') {
  dependsOn: [
    changeTrackingSolution
  ]
  name: 'Microsoft-CT-DCR'
  location: azureLocation
  tags: resourceTags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dataSources: changeTrackingDcrDataSources
    destinations: {
      logAnalytics: [
        {
          name: 'Microsoft-CT-Dest'
          workspaceResourceId: logAnalyticsWorkspaceId
        }
      ]
    }
    dataFlows: changeTrackingDcrDataFlows
  }
}
