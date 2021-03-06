# azure-minecraft-bedrock

## Build Status

| GitHub Action | Status |
| ----------- | ----------- |
| Build | [![Build](https://github.com/pascalvanderheiden/azure-minecraft-bedrock/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/pascalvanderheiden/azure-minecraft-bedrock/actions/workflows/build.yml) |
| Release | [![Release](https://github.com/pascalvanderheiden/azure-minecraft-bedrock/actions/workflows/release.yml/badge.svg)](https://github.com/pascalvanderheiden/azure-minecraft-bedrock/actions/workflows/release.yml) |

## About

![azure-minecraft-bedrock](docs/images/bedrock.png)

This repository deploys [itzg/minecraft-bedrock-server](https://hub.docker.com/r/itzg/minecraft-bedrock-server) to Azure Container Instance. You can deploy it manually or by GitHub Actions, already prepared for you in this repo. The Build pipeline will deploy the infrastructure in Azure and a release pipeline is used for deploying custom worlds to this server. The custom worlds are created in [WorldPainter](https://www.worldpainter.net/).

My colleague created this [repo](https://github.com/geekzter/azure-minecraft-docker) for deploying Minecraft Java servers to Azure Container Instance. I really like the idea of a docker image that can be used to deploy a minecraft server, and that it can be deployment via an automated process. So I tried it out, but the image he used is for the Minecraft Java edition only. And my son, and his friends only play on consoles. 

I than stumbled upon this [Minecraft Bedrock Server Build](https://www.minecraft.net/en-us/download/server/bedrock) which is still in Alpha, but will do the job. I discovered that the image is also available on Docker Hub. I deployed this manually, and it worked with my Windows version of Minecraft, but not on my XBox One or a PS4. 

Than I found this App for [iOS](https://apps.apple.com/us/app/bedrocktogether/id1534593376) and [Android](https://play.google.com/store/apps/details?id=pl.extollite.bedrocktogetherapp&hl=en_US&gl=US), which basically acts as a local proxy to the Bedrock Server. The server will than popup in your Friends List as a local LAN server. And this works!

My son happy, his friends happy and I'm happy. But it doesn't stop there. My son learned about [WorldPainter](https://www.worldpainter.net/), an application where you can create custom worlds. How cool would it be to create a custom world for our Bedrock Server? I thought so, but it didn't work. Java Only.

But, than I found this Windows Store App [je2be](https://apps.microsoft.com/store/detail/je2be/9PC9MFX9QCXS?hl=en-ca&gl=CA). It can convert Java exported worlds to Bedrock. And this really works!

I hope you enjoy this project as much as I do.

## Architecture

![azure-minecraft-bedrock](docs/images/arch.png)

Next to the Azure Container Instance for the Bedrock Server and the Azure Storage Account for the File Share, I've also added two Azure Automation Runbooks, for starting and stopping the Bedrock Server on a schedule for cost saving and limiting game time. For releasing new worlds to the Bedrock Server I use GitHub Actions in this repo for automated deployment.

## Prerequisites

* Install [Visual Studio Code](https://code.visualstudio.com/download)
* Install [Java runtime](https://www.oracle.com/java/technologies/downloads/), needed for WorldPainter
* Install [WorldPainter](https://www.worldpainter.net/), is optional, only if you want to create custom worlds.
* Install [je2be](https://apps.microsoft.com/store/detail/je2be/9PC9MFX9QCXS?hl=en-ca&gl=CA), also optional.
* Install Bedrock Together for [iOS](https://apps.apple.com/us/app/bedrocktogether/id1534593376) and [Android](https://play.google.com/store/apps/details?id=pl.extollite.bedrocktogetherapp&hl=en_US&gl=US)
* Install Chocolatey (package manager), needed for manual deployment

```ps1
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

* Install Bicep CLI, needed for manual deployment

```ps1
choco install bicep
```

* Install Az Module in PowerShell, needed for manual deployment

```ps1
Install-Module -Name Az -AllowClobber -Scope CurrentUser
```

## Deploy Manually

* Git Clone the repository

```ps1
git clone https://github.com/pascalvanderheiden/azure-minecraft-bedrock.git
```

* Open the folder with Visual Studio Code, and execute commands more easily via the integrated terminal

* Deploy it all by one script

I've included all the steps in 1 Powershell script. This will create all the needed resources. Keep in mind that this will take a while to deploy.

I've used these variables:

```ps1
$subscriptionId = "<subscription_id>"
$namePrefix = "<project_prefix>"
# Set start and end time for Minecraft Server (ex. after school only)
$timeZone = "Europe/Amsterdam"
$startTime = "15:00"
$endTime = "22:00"
# Set Minecraft Bedrock Environement variables (you can check the properties on Docker Hub)
$gameMode = "survival"
$gameDifficulty = "normal"
$gameAllowCheats = "true"
$deploymentNameBuild = "deployMinecraftBedrock"
$folderNameWorld = "Bedrock level" 
```

```ps1
.\deploy\manual-deploy.ps1 -subscriptionId $subscriptionId -namePrefix $namePrefix -timeZone $timeZone -startTime $startTime -endTime $endTime -gameMode $gameMode -gameDifficulty $gameDifficulty -gameAllowCheats $gameAllowCheats -deploymentNameBuild $deploymentNameBuild -folderNameWorld $folderNameWorld
```

## Deploy with Github Actions

* Fork this repository

* Generate a Service Principal (role Owner is needed to be able to do the role assignment)

```ps1
az ad sp create-for-rbac -n <name_sp> --role Owner --sdk-auth --scopes /subscriptions/<subscription_id>
```

Copy the json output of this command.

* Update GitHub Secrets for customizing your deployment

In the repository go to 'Settings', on the left 'Secrets', 'Actions'.
And pass the json output in the command used above into the secret 'AZURE_CREDENTIALS'.

The following secrets need to be created:

* AZURE_CREDENTIALS
* AZURE_SUBSCRIPTION_ID
* LOCATION
* PREFIX

### Trigger
You can trigger the Build Pipeline from the Actions tab in GitHub. The Release Pipeline is automatically triggered when a updated is made to the release/worlds folder.

## Customize & upload a new world

Important note is that the default server.properties of the Bedrock server are already pointing to the Bedrock level world. Because we can't run multiple worlds in one server, the most easy way to update is to release all files in the current Bedrock Level folder. You can upload backups to the storage account of course, but the server isn't aware of it.

* Create a new world in WorldPainter

Install and open Worldpainter. Create your world and export it.

![azure-minecraft-bedrock](docs/images/worldpainter_export_1.png)

Choose how you want to export it.

![azure-minecraft-bedrock](docs/images/worldpainter_export_2.png)

And choose Export.

* Convert the export to Bedrock with je2be

Install and open je2be.

![azure-minecraft-bedrock](docs/images/je2be_convert_1.png)

Pick Java to Bedrock. Point to the folder where you exported your world. And start converting.

![azure-minecraft-bedrock](docs/images/je2be_convert_2.png)

And now save it into an empty custom folder.

Now replace all the files in the Bedrock level folder of this repo with the new files.

Commit the changes and the GitHub Action Release pipeline will deploy it automatically to your server.
Or just run the manual deployment script again, and it will release the new world to the server as well.

## Connect to the Minecraft Server from a console

You can connect to the Bedrock Server on a Windows version of Minecraft relatively easy. But for a console, you need to proxy it to a local LAN server, in order to be able to connect to it.

Bedrock Together does this for you.

![azure-minecraft-bedrock](docs/images/bedrocktogether.png)

Just fill in the ip address of the Azure Container Instance, and it will popup in Minecraft under the Friends Tab as a local server.

![azure-minecraft-bedrock](docs/images/minecraft_lan.png)

Keep in mind that the ip address will change after a restart. I gave my son access to the Azure Portal, with read rights on the Azure Container Instance, so he could see the ip address. You could also create a Logic App for starting and stopping the Azure Container Instance instead of the Automation Account Runbooks, where you can email or sms the ip after restart.
