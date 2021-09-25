#!/bin/bash
set -euo pipefail

# Load values from .env file or create it if it doesn't exists
FILE=".env"
if [[ -f $FILE ]]; then
	echo "Loading from $FILE" 
    export $(egrep "^[^#;]" $FILE | xargs -n1)
else
	cat << EOF > .env
# Azure-Specific Configuration
resourceGroup=""
location=""

# Directus-Specific Configuration
directusAdminEmail='admin@example.com'
directusAdminPassword='directuS_PAzzw0rd!'
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
    directusAdministratorEmail="$directusAdminEmail" \
    directusAdministratorPassword="$directusAdminPassword" \
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

echo "Getting static website address..."
website=`az storage account show -g $resourceGroup -n $storage --query "primaryEndpoints.web" -o tsv`
echo "Website available at: $website"

echo "Waiting for Directus to be fully deployed (it might take a minute)..."
sleep 5
curl -s -X POST "$site/auth/login" -H "Content-Type: application/json" -d "{}" > /dev/null 2>&1

echo "Logging in into Directus..."
payload="{\"email\":\"$directusAdminEmail\", \"password\":\"$directusAdminPassword\"}"
result=`curl -s -X POST "$site/auth/login" -H "Content-Type: application/json" -d "$payload"`
token=`echo $result | jq -r .data.access_token`

echo "Creating Todo collection..."
curl -s -X POST "$site/collections" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $token" \
    -d '{"collection":"todo"}'

echo "Creating Todo fields..."
curl -s -X POST "$site/fields/todo" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $token" \
    -d '{"field":"title", "type":"string", "meta":{"collection":"todo"}}'
curl -s -X POST "$site/fields/todo" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $token" \
    -d '{"field":"completed", "type":"boolean", "meta":{"collection":"todo"}}'

echo "Setting permissions on Todo collection..."
curl -s -X POST "$site/permissions" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $token" \
    -d '{"collection":"todo", "action":"create", "fields":"*"}'
curl -s -X POST "$site/permissions" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $token" \
    -d '{"collection":"todo", "action":"read", "fields":"*"}'
curl -s -X POST "$site/permissions" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $token" \
    -d '{"collection":"todo", "action":"update", "fields":"*"}'
curl -s -X POST "$site/permissions" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $token" \
    -d '{"collection":"todo", "action":"delete", "fields":"*"}'

echo "Creating sample Todo items..."
curl -s -X POST "$site/items/todo" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $token" \
    -d '[{"title": "Hello world item", "completed": true},{"title": "Another item", "completed": false},{"title": "Last one"}]'

echo "Done."

echo "Directus available at: $site"
echo "Sample static website at: $website"
