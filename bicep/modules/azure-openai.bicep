@description('Name of the Azure OpenAI resource')
param nameAOAI string

@description('The Azure Region to deploy the resources into')
param location string

@description('SKU of the Azure OpenAI resource')
param skuAOAI object = {
  name: 'S0'
}

@description('Array of models to deploy to the Azure OpenAI resource')
param deployments array

@description('Environment type')
param environmentType string

// Array containing the models we want to deploy


param tags object = {
  Creator: 'ServiceAccount'
  Service: 'OpenAI'
  Environment: environmentType
}


// Azure OpenAI service
resource azureOpenAI 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: nameAOAI  
  location: location
  kind: 'OpenAI'
  properties: {
    publicNetworkAccess: 'Enabled'
    customSubDomainName: nameAOAI
    networkAcls: {
      defaultAction: 'Allow'
    }
  }
  tags: tags
  sku: skuAOAI
}

@batchSize(1)
resource deployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = [for deployment in deployments: {
  parent: azureOpenAI
  sku: {
    name: 'Standard'
    capacity: 100
  }
  name: deployment.name
  properties: {
    model: deployment.model
  }
}]


output azureOpenAIId string = azureOpenAI.id
output azureOpenAIName string = azureOpenAI.name
