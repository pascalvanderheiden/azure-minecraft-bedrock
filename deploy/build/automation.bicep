@minLength(3)
@maxLength(11)
param namePrefix string
param location string

@description('Modules to import into automation account')
@metadata({
  name: 'Module name'
  version: 'Module version or specify latest to get the latest version'
  uri: 'Module package uri, e.g. https://www.powershellgallery.com/api/v2/package'
})
param modules array = []

@description('Runbooks to import into automation account')
@metadata({
  runbookName: 'Runbook name'
  runbookUri: 'Runbook URI'
  runbookType: 'Runbook type: Graph, Graph PowerShell, Graph PowerShellWorkflow, PowerShell, PowerShell Workflow, Script'
  logProgress: 'Enable progress logs'
  logVerbose: 'Enable verbose logs'
})
param runbooks array = []

@description('Schedules to import into automation account')
@metadata({
  scheduleName: 'Schedule name'
  startTime: 'Start time'
  timeZone: 'Time zone'
})
param schedules array = []

@description('Job Schedules to import into automation account')
@metadata({
  scheduleJobName: 'Job Schedule name'
  runbookName: 'Runbook name'
  scheduleName: 'Schedule name'
  resourceGroup: 'Resource group parameter'
  aciName: 'ACI name parameter'
})
param jobschedules array = []

var automationAccountName = '${namePrefix}-aa'
var sku = 'Free'
var enableDeleteLock = false
var lockName = '${namePrefix}-aa-lck'

resource automationAccount 'Microsoft.Automation/automationAccounts@2020-01-13-preview' = {
  name: automationAccountName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    sku: {
      name: sku
    }
  }
}

resource automationAccountModules 'Microsoft.Automation/automationAccounts/modules@2020-01-13-preview' = [for module in modules: {
  parent: automationAccount
  name: module.name
  properties: {
    contentLink: {
      uri: module.version == 'latest' ? '${module.uri}/${module.name}' : '${module.uri}/${module.name}/${module.version}'
      version: module.version == 'latest' ? null : module.version
    }
  }
}]

resource runbook 'Microsoft.Automation/automationAccounts/runbooks@2019-06-01' = [for runbook in runbooks: {
  parent: automationAccount
  name: runbook.runbookName
  location: location
  properties: {
    runbookType: runbook.runbookType
    logProgress: runbook.logProgress
    logVerbose: runbook.logVerbose
    publishContentLink: {
      uri: runbook.runbookUri
    }
  }
}]

resource lock 'Microsoft.Authorization/locks@2016-09-01' = if (enableDeleteLock) {
  scope: automationAccount
  name: lockName
  properties: {
    level: 'CanNotDelete'
  }
}

resource schedule 'Microsoft.Automation/automationAccounts/schedules@2020-01-13-preview' = [for schedule in schedules: {
  parent: automationAccount
  name: schedule.scheduleName
  properties: {
    frequency: 'Day'
    interval: 1
    startTime: schedule.startTime
    timeZone: schedule.timeZone
  }
}]

resource jobSchedule 'Microsoft.Automation/automationAccounts/jobSchedules@2020-01-13-preview' = [for jobschedule in jobschedules: {
  parent: automationAccount
  name: jobschedule.scheduleJobName
  properties: {
    runbook: {
      name: jobschedule.runbookName
    }
    schedule: {
      name: jobschedule.scheduleName
    }
    parameters: {
      resourceGroup: jobschedule.resourceGroup
      aciName: jobschedule.aciName
    }
  }
}]

output principalId string = automationAccount.identity.principalId
