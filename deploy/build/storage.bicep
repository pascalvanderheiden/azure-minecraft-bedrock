@minLength(3)
@maxLength(11)
param namePrefix string
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GZRS'
  'Standard_RAGZRS'
])
param storageSKU string = 'Standard_LRS'
param location string

var uniqueStorageName = '${namePrefix}${uniqueString(resourceGroup().id)}st01'
var fileShareName = '${namePrefix}-share'

resource stg 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: uniqueStorageName
  location: location
  sku: {
    name: storageSKU
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
  }
}

resource fileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-04-01' = {
  name: '${stg.name}/default/${fileShareName}'
}

output storageAccountName string = stg.name
var StorageAccountKey = listKeys(stg.id, stg.apiVersion).keys[0].value
output storageAccountKey string = StorageAccountKey
output fileShareName string = fileShareName
