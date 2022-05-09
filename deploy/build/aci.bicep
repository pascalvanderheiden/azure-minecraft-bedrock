@minLength(3)
@maxLength(11)
param namePrefix string
param location string = resourceGroup().location
param storageAccountName string
param storageAccountKey string
param fileShareName string
// Minecraft Server Settings
param gameMode string
param gameDifficulty string
param gameAllowCheats string
param autoAccPrincipalId string
param aciName string

var cpuCores = 1
var memoryInGb = 2
var restartPolicy = 'Always'
var image = 'itzg/minecraft-bedrock-server'
var port = 19132
var protocol = 'UDP'
var containerGroupName = aciName
var ContainerName = '${namePrefix}-con'
var uniqueDnsName = '${namePrefix}${uniqueString(resourceGroup().id)}'

// Setting Role Assignment for ACI so Automation Account can stop and start ACI
var builtInRoleType = 'Contributor'
var role = {
  Owner: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
  Contributor: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
  Reader: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7'
}

resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2021-09-01' = {
  name: containerGroupName
  location: location
  properties: {
    containers: [
      {
        name: ContainerName
        properties: {
          image: image
          ports: [
            {
              port: port
              protocol: protocol
            }
          ]
          environmentVariables: [
            {
              name: 'EULA'
              value: 'true'
            }
            {
              name: 'GAMEMODE'
              value: gameMode
            }
            {
              name: 'DIFFICULTY'
              value: gameDifficulty
            }
            {
              name: 'ALLOW_CHEATS'
              value: gameAllowCheats
            }
          ]
          resources: {
            requests: {
              cpu: cpuCores
              memoryInGB: memoryInGb
            }
          }
          volumeMounts: [
            {
              name: 'azurefile'
              mountPath: '/data'
            }
        ]
        }
      }
    ]
    osType: 'Linux'
    restartPolicy: restartPolicy
    ipAddress: {
      type: 'Public'
      dnsNameLabel: uniqueDnsName
      ports: [
        {
          port: port
          protocol: protocol
        }
      ]
    }
    volumes: [
      {
        name: 'azurefile'
          azureFile: {
              shareName: fileShareName
              storageAccountName: storageAccountName
              storageAccountKey: storageAccountKey
          }
      }
    ]
  }
}

resource roleAssignStorage 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(containerGroup.id, autoAccPrincipalId, role[builtInRoleType])
  properties: {
    roleDefinitionId: role[builtInRoleType]
    principalId: autoAccPrincipalId
  }
  scope: containerGroup
}

output containerIPv4Address string = containerGroup.properties.ipAddress.ip
