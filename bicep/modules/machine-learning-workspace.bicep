// Creates a machine learning workspace, private endpoints and DNS zones for the azure machine learning workspace

@description('Azure region of the deployment')
param location string

@description('Tags to add to the resources')
param tags object

@description('Machine learning workspace name')
param nameMachineLearning string

@description('Machine learning workspace display name')
param nameMachineLearningFriendly string = nameMachineLearning

@description('Machine learning workspace description')
param descriptionMachineLearning string

@description('Resource ID of the application insights resource')
param applicationInsightsId string

@description('Resource ID of the container registry resource')
param containerRegistryId string

@description('Resource ID of the key vault resource')
param keyVaultId string

@description('Resource ID of the storage account resource')
param storageAccountId string

resource machineLearning 'Microsoft.MachineLearningServices/workspaces@2023-10-01' = {
  name: nameMachineLearning
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    // workspace organization
    friendlyName: nameMachineLearningFriendly
    description: descriptionMachineLearning

    // dependent resources
    applicationInsights: applicationInsightsId
    containerRegistry: containerRegistryId
    keyVault: keyVaultId
    storageAccount: storageAccountId

    publicNetworkAccess: 'Enabled'
  }
}

output nameMachineLearning string = machineLearning.name
output machineLearningId string = machineLearning.id
output machineLearningPrincipalId string = machineLearning.identity.principalId
output usedSuffix string = uniqueString(resourceGroup().id)
