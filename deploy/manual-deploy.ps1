param ($subscriptionId, $namePrefix, $timeZone, $startTime, $endTime, $gameMode, $gameDifficulty, $gameAllowCheats, $deploymentNameBuild, $folderNameWorld)

Write-Host "Setting the paramaters:"
$location = "westeurope"
$resourceGroup = "$namePrefix-rg"
$fileShare = "${namePrefix}-share"
$aciName = "${namePrefix}-aci"
$buildBicepPath = ".\deploy\build\main.bicep"

Write-Host "Login to Azure:"
az login
Set-AzContext -Subscription $subscriptionId

Write-Host "Build"
New-AzSubscriptionDeployment -name $deploymentNameBuild -namePrefix $namePrefix -location $location -TemplateFile $buildBicepPath

Write-Host "Release"
.\release\deploy-custom-world-to-azure.ps1 -subscriptionId $subscriptionId -resourceGroup $resourceGroup -fileShare $fileShare -aciName $aciName -folderNameWorld $folderNameWorld