Param(
 [string]$resourceGroup,
 [string]$aciName
)

# Ensures you do not inherit an AzContext in your runbook
Disable-AzContextAutosave -Scope Process | Out-Null

# Connect using a Managed Service Identity
try {
        $AzureContext = (Connect-AzAccount -Identity).context
    }
catch{
        Write-Output "There is no system-assigned user identity. Aborting."; 
        exit
    }

# set context
$AzureContext = Set-AzContext -SubscriptionName $AzureContext.Subscription -DefaultProfile $AzureContext

# Get current state of ACI
$state = (Get-AzContainerGroup -Name $aciName -ResourceGroupName $resourceGroup -DefaultProfile $AzureContext).InstanceViewState
Write-Output "`r`n Beginning ACI status: $state `r`n"

# Stop ACI when started
if($state -eq "Running")
    {
        Stop-AzContainerGroup -Name $aciName -ResourceGroupName $resourceGroup -DefaultProfile $AzureContext
    }
elseif ($state -eq "Stopped")
    {
        Write-Output "ACI already stopped. Aborting."; 
        exit
    }

# Get new state of ACI
$state = (Get-AzContainerGroup -Name $aciName -ResourceGroupName $resourceGroup -DefaultProfile $AzureContext).InstanceViewState 
Write-Output "`r`n Ending ACI state: $state `r`n `r`n"
Write-Output "Account ID of current context: " $AzureContext.Account.Id