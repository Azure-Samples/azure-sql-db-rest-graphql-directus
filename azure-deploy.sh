#!/bin/bash
set -euo pipefail

# Load values from .env file or create it if it doesn't exists
FILE=".env"
if [[ -f $FILE ]]; then
	echo "Loading from $FILE" 
    export $(egrep "^[^#;]" $FILE | xargs -n1)
else
	cat << EOF > .env
resourceGroup=""
location=""
EOF
	echo "Enviroment file not detected."
	echo "Please configure values for your environment in the created .env file"
	echo "and run the script again."
	exit 1
fi

echo "Creating Resource Group...";
az group create \
    -n $resourceGroup \
    -l $location

echo "Deploying Resources...";
az deployment group create \
  --name AzureSQL_Directus \
  --resource-group $resourceGroup \
  --template-file azuredeploy.json \
  --parameters \
    location=$location 

echo "Done."