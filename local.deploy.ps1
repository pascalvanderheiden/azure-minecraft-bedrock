$subscriptionId = "ec1782b9-afe3-41f7-af5b-b2ca78612b1b"
$namePrefix = "bedrockpvdh"
# Set start and end time for Minecraft Server (ex. after school only)
$timeZone = "W. Europe Standard Time"
$startTime = "03:00PM"
$endTime = "10:00PM"
# Set Minecraft Bedrock Environement variables
$gameMode = "survival"
$gameDifficulty = "normal"
$gameAllowCheats = "true"
$deploymentNameBuild = "Build"
$folderNameWorld = "Bedrock level" 

.\manual-deploy.ps1 -subscriptionId $subscriptionId -namePrefix $namePrefix -timeZone $timeZone -startTime $startTime -endTime $endTime -gameMode $gameMode -gameDifficulty $gameDifficulty -gameAllowCheats $gameAllowCheats -deploymentNameBuild $deploymentNameBuild -folderNameWorld $folderNameWorld