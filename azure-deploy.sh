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
uid=`az deployment group create \
  --name AzureSQL_Directus \
  --resource-group "$resourceGroup" \
  --template-file azuredeploy.json \
  --parameters \
    location="$location" \
  --query "properties.outputs.uniqueId.value" \
  --output tsv`

echo "Generated Unique Id: $uid"

echo "Writing client/directus-address.json..."
file="./client/directus-address.json"
site="https://directus-${uid}.azurewebsites.net"
rm -f -- $file
cat << EOF >> $file
[
    "$site"
]
EOF

echo "Getting access to created storage account..."
storage="directus${uid}"
AZURE_STORAGE_CONNECTION_STRING=`az storage account show-connection-string -g "$resourceGroup" -n "$storage" --query "connectionString" -o tsv`

echo "Creating container..."
az storage container create \
    --connection-string "$AZURE_STORAGE_CONNECTION_STRING" \
    -n '$web'

echo "Uploading files..."
az storage blob upload-batch \
    --connection-string "$AZURE_STORAGE_CONNECTION_STRING" \
    -d '$web' \
    -s ./client

echo "Enabling static website..."
az storage blob service-properties update \
    --connection-string "$AZURE_STORAGE_CONNECTION_STRING" \
    --account-name $storage \
    --static-website \
    --index-document index.html

website=`az storage account show -g dm-directus-4 -n directusyxxjmrwglmr62 --query "primaryEndpoints.web" -o tsv`

echo "Website available at: $website"

echo "Loggin in into Directus..."
curl -X POST https://directus-yxxjmrwglmr62.azurewebsites.net/auth/login \
    -H "Content-Type: application/json" \
    -d '{"email":"", "password":""}'

echo "Creating Directus 'Todo' collection..."

echo "Creating sample Todo items..."

echo "Done."