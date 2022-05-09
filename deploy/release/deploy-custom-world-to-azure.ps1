param ($subscriptionId, $resourceGroup, $fileShare, $aciName, $folderNameWorld)

$customWorldPath = ".\deploy\release\worlds\$folderNameWorld"
$customWorldPathDb = "$customWorldPath\db"

# Enable only when deploying separatly
#Write-Host "Login to Azure:"
#az login
#Set-AzContext -Subscription $subscriptionId

Write-Host "Stop Azure Container Instance:"
az container stop -n $aciName -g $resourceGroup

Write-Host "Retrieve Storage Account Name & Key Name:"
$storageAccountName = az storage account list -g $resourceGroup --subscription $subscriptionId --query "[].{Name:name}" -o tsv
$storageKey = az storage account keys list -g $resourceGroup -n $storageAccountName --query "[0].{Name:value}" -o tsv

Write-Host "Delete all files in default folder (Bedrock level):"
$fileSharePathWorlds = "$fileShare/worlds/Bedrock Level"
$fileSharePathWorldsDb = "$fileSharePathWorlds/db"
az storage file delete-batch --account-key $storageKey --account-name $storageAccountName --source $fileSharePathWorlds
az storage file delete-batch --account-key $storageKey --account-name $storageAccountName --source $fileSharePathWorldsDb

Write-Host "Upload all files in custom folder to Bedrock level folder:"
az storage file upload-batch --destination $fileSharePathWorlds --source $customWorldPath --account-name $storageAccountName --account-key $storageKey
az storage file upload-batch --destination $fileSharePathWorldsDb --source $customWorldPathDb --account-name $storageAccountName --account-key $storageKey

Write-Host "Start Azure Container Instance:"
az container start -n $aciName -g $resourceGroup
