@description('Location for all resources.')
param location string = resourceGroup().location

@description('Type of environment (dev, qa, prod, ...).')
param environmentType string

@description('The SKU for Key Vault.')
param keyVaultSku string = 'premium'


@description('Set of tags to apply to all resources.')
param tags object = {
  environmentType: environmentType
}
// Parameters for the storage account
param storageSku string ='Standard_LRS'



module appInsights 'modules/app-insights.bicep' = {
  name: 'appInsights'
  params: {
    location: location
    environmentType: environmentType
  }
}


module keyVault 'modules/key-vault.bicep' = {
  name: 'keyVault'
  params: {
    location: location
    environmentType: environmentType
    skuName: keyVaultSku
  }
}



// Creating two storage accounts:
// - one for the Azure Machine Learning workspace
module storage 'modules/storage.bicep' = {
  name: 'storagellmops'
  params: {
    location: location
    nameStorage: 'stllmops${uniqueString(resourceGroup().id)}'
    nameStorageSku: storageSku
    tags: tags
  }
}


// Creating the Azure Container registry required by 
// Azure machine Learning to serve as a model registry
module containerRegistry 'modules/container-registry.bicep' = {
  name: 'llmopsContainerRegistry'
  params: {
    location: location
    nameContainerRegistry: 'acr${uniqueString(resourceGroup().id)}'
    tags: tags
  }
}


// Creating the Azure Machine Learning workspace, compute and networking resources
module azuremlWorkspace 'modules/machine-learning-workspace.bicep' = {
  name: 'azuremlWorkspace'
  params: {
    // workspace organization
    nameMachineLearning: 'amlws-${environmentType}-${uniqueString(resourceGroup().id)}'
    nameMachineLearningFriendly: 'Azure ML ${environmentType} workspace'
    descriptionMachineLearning: 'This is an AML workspace for ${environmentType} environment'
    location: location
    tags: tags

    // dependant resources
    applicationInsightsId: appInsights.outputs.id
    containerRegistryId: containerRegistry.outputs.containerRegistryId
    keyVaultId: keyVault.outputs.keyVaultId
    storageAccountId: storage.outputs.storageId
    azureOpenAIId: azureOpenAI.outputs.azureOpenAIId

  }
  dependsOn: [
    keyVault
    containerRegistry
    appInsights
    storage
  ]
}

// Creating all the role assignments required for the end-to-end flow to work
module rolesAssignments 'modules/rolesAssignments.bicep' = {
  name: 'rolesAssignments-${uniqueString(resourceGroup().id)}'
  params: {
    nameStorage: storage.outputs.nameStorage
    azuremlWorkspacePrincipalId: azuremlWorkspace.outputs.machineLearningPrincipalId
  }
}

// Creating the Azure OpenAI resource
module azureOpenAI 'modules/azure-openai.bicep' = {
  name: 'azureOpenAI'
  params: {
    //Azure OpenAI resource
    nameAOAI: 'aoai-${environmentType}-${uniqueString(resourceGroup().id)}'
    location: location
    deployments: [
      {
        name: 'chat-model'
        model: {
          format: 'OpenAI'
          name: 'gpt-35-turbo'
          version: '0613'
        }
        scaleSettings: {
          scaleType: {
            name: 'S0'
          }
        }
      }
      {
        name: 'embeddings-model'
        model: {
          format: 'OpenAI'
          name: 'text-embedding-ada-002'
          version: '2'
        }
        scaleSettings: {
          scaleType: {
            name: 'S0'
          }
        }
      }
      {
        name: 'judge-model'
        model: {
          format: 'OpenAI'
          name: 'gpt-4'
          version: '1106-Preview'
        }
        scaleSettings: {
          scaleType: {
            name: 'S0'
          }
        }
      }
    ]
    environmentType: environmentType
    skuAOAI: {
      name: 'S0'
    }
  }
}

module aiSearch 'modules/ai-search.bicep' = {
  name: 'aiSearch'
  params: {
    location: location
  }
}
