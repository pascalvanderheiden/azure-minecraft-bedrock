// set the target scope for this file
targetScope = 'subscription'

@minLength(3)
@maxLength(11)
param namePrefix string
param location string = deployment().location
// Set start and end time for Minecraft Server (ex. after school only)
param timeZone string = 'W. Europe Standard Time'
param startTime string = '03:00PM'
param endTime string = '10:00PM'
// Set Minecraft Bedrock Environement variables
param gameMode string = 'survival'
param gameDifficulty string = 'normal'
param gameAllowCheats string = 'true'

var resourceGroup = '${namePrefix}-rg'
var aciName = '${namePrefix}-aci'

// Create a Resource Group
resource newRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroup
  location: location
}

// Create a Storage Account
module stgModule '../build/storage.bicep' = {
  name: 'storageDeploy'
  scope: newRG
  params: {
    namePrefix: namePrefix
    location: location
  }
}

// Create Azure Automation Account and Workbooks
module autoAccModule '../build/automation.bicep' = {
  name: 'automationAccountDeploy'
  scope: newRG
  params: {
    namePrefix: namePrefix
    location: location
    modules: [
      {
        name: 'Az.Accounts'
        version: 'latest'
        uri: 'https://www.powershellgallery.com/api/v2/package'
      }
      {
        name: 'Az.ContainerInstance'
        version: 'latest'
        uri: 'https://www.powershellgallery.com/api/v2/package'
      }
    ]
    runbooks: [
      {
        runbookName: 'Start-ACI'
        runbookUri: 'https://raw.githubusercontent.com//pascalvanderheiden/azure-minecraft-bedrock/main/deploy/build/start-aci.ps1'
        runbookType: 'PowerShell'
        logProgress: true
        logVerbose: false
        scheduleName: 'start-aci-schedule'
        scheduleJobName: 'start-aci-schedule'
        startTime: startTime
        timeZone: timeZone
        parameters: {
          resourceGroup: resourceGroup
          aciName: aciName
        }
      }
      {
        runbookName: 'Stop-ACI'
        runbookUri: 'https://raw.githubusercontent.com//pascalvanderheiden/azure-minecraft-bedrock/main/deploy/build/stop-aci.ps1'
        runbookType: 'PowerShell'
        logProgress: true
        logVerbose: false
        scheduleName: 'stop-aci-schedule'
        scheduleJobName: 'stop-aci-schedule'
        startTime: endTime
        timeZone: timeZone
      }
    ]        
  }
}

// Create Azure Container Instance
module aciModule '../build/aci.bicep' = {
  name: 'aciDeploy'
  scope: newRG
  params: {
    namePrefix: namePrefix
    aciName: aciName
    location: location
    storageAccountName: stgModule.outputs.storageAccountName
    storageAccountKey: stgModule.outputs.storageAccountKey
    fileShareName: stgModule.outputs.fileShareName
    gameMode: gameMode
    gameDifficulty: gameDifficulty
    gameAllowCheats: gameAllowCheats
    autoAccPrincipalId: autoAccModule.outputs.principalId
  }
  dependsOn:[
    stgModule
    autoAccModule
  ]
}
