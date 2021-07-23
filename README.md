# Directus

![Deploy to Azure](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure-Samples%2Fazure-sql-db-rest-graphql-directus%2F6c44166e41d5f71b38e1e619dc896d2fadfab708%2Fazuredeploy.json%3Ftoken%3DACFXWGMZES3TLF5AYE2ZBZDBARDIG)

Deploy Directus to a production-ready environment on Azure.

## Features

This project framework provides the following features:

- Directus running on a Docker Container powered by App Service
- Azure Cache for Redis powering Cache and Rate Limiting
- Azure Storage Container for file uploads
- Azure SQL for storing the data managed by Directus

## Getting Started

### Installation

Install Directus by using the Deploy button above, or using the Azure CLI:

```
az deployment group create --resource-group [my-resource-group] --template-file ./azuredeploy.json
```

## Demo

A demo app is included to show how to use the project.

To run the demo, follow these steps:

(Add steps to start up the demo)

1.
2.
3.

## Resources

(Any additional resources or related projects)

- Directus Website (https://directus.io)
- Directus GitHub Repo (https://github.com/directus)
