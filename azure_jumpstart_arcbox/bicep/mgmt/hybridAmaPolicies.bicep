targetScope = 'subscription'

var windowsHybridVmsAmaPolicy = loadJsonContent('policyWindowsHybridAma.json')
var linuxHybridVmsAmaPolicy = loadJsonContent('policyLinuxHybridAma.json')

resource amaWindowsHybridVmsPolicyDefinition 'Microsoft.Authorization/policySetDefinitions@2023-04-01' = {
  name: guid('amaWindowsHybridVmsPolicy', subscription().subscriptionId)
  properties: windowsHybridVmsAmaPolicy
}

resource amaLinuxHybridVmsPolicyDefinition 'Microsoft.Authorization/policySetDefinitions@2023-04-01' = {
  name: guid('amaLinuxHybridVmsPolicy', subscription().subscriptionId)
  properties: linuxHybridVmsAmaPolicy
}

output amaWindowsHybridVmsPolicyDefinitionId string = amaWindowsHybridVmsPolicyDefinition.id
output amaLinuxHybridVmsPolicyDefinitionId string = amaLinuxHybridVmsPolicyDefinition.id
