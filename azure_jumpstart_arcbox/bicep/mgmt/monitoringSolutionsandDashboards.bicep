@description('Log Analytics Workspace Id')
param logAnalyticsWorkspaceId string

@description('Azure Location')
param azureLocation string

@description('Resource Tags')
param resourceTags object

var workspaceName = substring(logAnalyticsWorkspaceId, (lastIndexOf(logAnalyticsWorkspaceId, '/') + 1), (length(logAnalyticsWorkspaceId) - (lastIndexOf(logAnalyticsWorkspaceId, '/') + 1)))

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

resource SQLVulnerabilityAssessment 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  name: 'SQLVulnerabilityAssessment(${workspaceName})'
  location: azureLocation
  tags: resourceTags
  properties: {
    workspaceResourceId: logAnalyticsWorkspaceId
  }
  plan: {
    name: 'SQLVulnerabilityAssessment(${workspaceName})'
    product: 'OMSGallery/SQLVulnerabilityAssessment'
    promotionCode: ''
    publisher: 'Microsoft'
  }
}

resource SQLAdvancedThreatProtection 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  name: 'SQLAdvancedThreatProtection(${workspaceName})'
  location: azureLocation
  tags: resourceTags
  properties: {
    workspaceResourceId: logAnalyticsWorkspaceId
  }
  plan: {
    name: 'SQLAdvancedThreatProtection(${workspaceName})'
    product: 'OMSGallery/SQLAdvancedThreatProtection'
    promotionCode: ''
    publisher: 'Microsoft'
  }
}



@description('List of JSON Files containing the dashboards to be deployed')
var dashboards = [
  {
    name: 'Arc - Deployment Progress'
    content: loadJsonContent('Arc - Deployment Progress.json')
  }
  {
    name: 'Arc - Estate Profile'
    content: loadJsonContent('Arc - Estate Profile.json')
  }
  {
    name: 'Arc - ESU'
    content: loadJsonContent('Arc - ESU.json')
  }
  {
    name: 'Arc - Server Deployment'
    content: loadJsonContent('Arc - Server Deployment.json')
  }
  {
    name: 'Arc - SQL Server Inventory'
    content: loadJsonContent('Arc - SQL Server Inventory.json')
  }
  {
    name: 'SQL Server Estate Health'
    content: loadJsonContent('SQL Server Estate Health.json')
  }
  {
    name: 'SQL Server Instances'
    content: loadJsonContent('SQL Server Instances.json')
  }
]


resource arcSqlDashboards 'Microsoft.Portal/dashboards@2022-12-01-preview' = [
  for dashboard in dashboards: {
    name: replace(dashboard.name, ' ', '')
    location: resourceGroup().location
    tags: union({
      'hidden-title': dashboard.name
    }, resourceTags)
    properties: dashboard.content
  }
]

