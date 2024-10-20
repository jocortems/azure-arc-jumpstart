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
    tags: {
      'hidden-title': dashboard.name
    }
    properties: dashboard.content
  }
]
