@description('The type of the environment')
param environmentType string
@description('The name of the key vault to be created.')
param vaultName string = 'kv-${environmentType}-${uniqueString(resourceGroup().id)}'
@description('Location for all resources.')
param location string = resourceGroup().location
@description('The SKU of the vault to be created.')
@allowed([
  'standard'
  'premium'
])
param skuName string = 'standard'
@description('The name of the key vault pep to be created.')


resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: vaultName
  location: location
  properties: {    
    accessPolicies: []
    createMode: 'default'
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enablePurgeProtection: null
    enabledForDeployment: true
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: true
    tenantId: subscription().tenantId
    sku: {
      name: skuName
      family: 'A'
    }
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
}

output keyVaultId string = keyVault.id
output keyVaultName string = keyVault.name
