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
New-AzSubscriptionDeployment -name $deploymentNameBuild -namePrefix $namePrefix -location $location -timeZone $timeZone -startTime $startTime -endTime $endtime -gameMode $gameMode -gameDifficulty $gameDifficulty -gameAllowCheats $gameAllowCheats -TemplateFile $buildBicepPath

Function Sleep-Progress($seconds) {
    $s = 0;
    Do {
        $p = [math]::Round(100 - (($seconds - $s) / $seconds * 100));
        Write-Progress -Activity "Waiting..." -Status "$p% Complete:" -SecondsRemaining ($seconds - $s) -PercentComplete $p;
        [System.Threading.Thread]::Sleep(1000)
        $s++;
    }
    While($s -lt $seconds);
    
}

# need to wait for the minecraft server to populate the folder structure in the file share.
Sleep-Progress (600)

Write-Host "Release"
.\deploy\release\deploy-custom-world-to-azure.ps1 -subscriptionId $subscriptionId -resourceGroup $resourceGroup -fileShare $fileShare -aciName $aciName -folderNameWorld $folderNameWorld

Write-Host "Finished deployment"