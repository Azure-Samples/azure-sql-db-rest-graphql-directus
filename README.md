---
page_type: sample
languages:
  - sql
products:
  - azure
  - vs-code
  - azure-sql-database
  - azure-web-apps
description: 'Full Stack TodoMVC Sample app, with REST and GraphQL support, using Directus, Azure Web Apps, Vue.Js and Azure SQL'
urlFragment: 'azure-sql-db-rest-graphql-directus'
---

<!--
Guidelines on README format: https://review.docs.microsoft.com/help/onboard/admin/samples/concepts/readme-template?branch=master

Guidance on onboarding samples to docs.microsoft.com/samples: https://review.docs.microsoft.com/help/onboard/admin/samples/process/onboarding?branch=master

Taxonomies for products and languages: https://review.docs.microsoft.com/new-hope/information-architecture/metadata/taxonomies?branch=master
-->

# REST & GraphQL TodoMVC Sample App Full Stack Implementation with Directus

![License](https://img.shields.io/badge/license-MIT-green.svg)

Serverless Full Stack implementation on Azure of [TodoMVC](http://todomvc.com/) app with support both for REST and GraphQL endpoints via [Directus](https://directus.io/) and Azure SQL.

This sample is a variation of the Full-Stack MVC Todo sample described here: [TodoMVC Full Stack with Azure Static Web Apps, Node and Azure SQL](https://devblogs.microsoft.com/azure-sql/todomvc-full-stack-with-azure-static-web-apps-node-and-azure-sql/). The difference, of course, is the use of Directus to **automatically expose the ToDo table via REST and GraphQL endpoints**.

Yes, that's right. You don't have to write a single line of code to make sure your table is reachable and usable via REST or GraphQL calls. You just have to configure what you want and all the plumbing will be done automatically for you. This way you can focus on creating amazing solution while still having all the power and the feature of Azure SQL at your service. Just like magic!

![Architecture](./assets/architecture.png)
## Azure Web Apps, Azure SQL

The implementation uses

- [Azure Web App](https://docs.microsoft.com/en-us/azure/app-service/tutorial-custom-container?pivots=container-linux/): to run the Directus container 
- [Vue.Js](https://vuejs.org/) as front-end client
- [Directus](https://directus.io/) to provide GraphQL and REST endpoints automatically from the Azure SQL database
- [Azure SQL](https://azure.microsoft.com/en-us/services/sql-database/) as database to store ToDo data


## Sample Deployment 

The script `./azure-deploy.sh` can be used to deploy Directus, create some sample data and also deploy a Static Website that calls the exposed REST and GraphQL using the Vue.js frontend. Make sure to run it from a Linux Shell, or [WSL](https://docs.microsoft.com/en-us/windows/wsl/install) or from the [Azure Cloud Shell](https://docs.microsoft.com/en-us/azure/cloud-shell/overview) if you don't want or can't to install WSL on your machine. 
If you are cloning the repository into on Linux on Azure Cloud shell, make sure to make the script executable:

```sh
chmod +x ./azure-deploy.sh
```

The first time you'll run the script, it will create an empty `.env` file. Edit it in text editor. On the Azure Cloud Shell you can use `nano`:

```
nano .env
```

to configure with your own values. 

Run the script:

```
./azure-deploy.sh
```

Once the script has finished you'll be given the address in which Directus has been installed and also the address of the sample Web App:

```
Directus available at: https://directus-[something].azurewebsites.net
Sample static website at: https://directus-[something].[something].web.core.windows.net/
```

Enjoy!

## Web Client

The sample web client, where you can create and manage your todo list, can be found here:

```
https://directus-[something].[something].web.core.windows.net/
```

There are two clients, one to show how to use the REST endpoints and one to show how to do the same operations, but with GraphQL.

##  Directus

The Directus administrative website is available at:

```
https://directus-[something].azurewebsites.net/admin
```

login with the email and the password you put in the `.env` file. You can manage the exposed entity and their security from here. And do much more. Learn more about Directus here: https://directus.io/.

## REST Endpoint

You can create, update and delete ToDos, that are then in turn stored in Azure SQL, completely via REST using the `/items/todo` endpoint. It support GET, POST, PATCH and DELETE methods. For example using cUrl:

To get all available todos

```
curl -s -X GET https://directus-[something].azurewebsites.net/items/todo
```

To get a specific todo

```
curl -s -X GET https://directus-[something].azurewebsites.net/items/todo/123
```

Create a todo

```
curl -s -H "Content-Type: application/json" -X POST https://directus-[something].azurewebsites.net/items/todo -d '{"title": "Hello world!"}'
```

Update todo

```
curl -s -H "Content-Type: application/json" -X PATCH https://directus-[something].azurewebsites.net/items/todo/123 -d '{"title":"World, hello!", "completed":true}'
```

Delete todo

```
curl -s -X DELETE https://directus-[something].azurewebsites.net/items/todo/123 
```

A sample of REST endpoint usage in a web page is available at `/client-rest.html` page.

## GraphQL Endpoint

The GraphQL endpoint is available at `https://directus-[something].azurewebsites.net/graphql`. It *does not* provide an interactive GraphQL playground, so you may want to use something like https://graphiql-online.com/graphiql to run GraphQL queries. You can create, update and delete ToDos, that are then in turn stored in Azure SQL, completely via GraphQL.

To get all available todos
```
query {
  todo {
    id,
    title,
    completed
  }
}
```

To get a specific todo
```
query {
  todo_by_id(id:1) {
    id,
    title,
    completed
  }
}
```

Create a todo
```
mutation {
  create_todo_item(data: {title:"Hello world!"}) {
    id,
    title,
    completed
  }
}
```

Update todo
```
mutation {
  update_todo_item(id: 123, data: {title:"World, hello!", completed: true}) {
    id,
    title,
    completed
  }
}
```

Delete todo
```
mutation {
  delete_todo_item(id: 123) {
    id
  }
}
```

A sample of GraphQL endpoint usage in a web page is available at `/client-graphql.html` page.

## Directus Only Deployment

You can deploy only Directus (without the additional sample website) by using the "Deploy to Azure" button:

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure-Samples%2Fazure-sql-db-rest-graphql-directus%2Fmain%2Fazuredeploy.json)

## Advanced configuration

You can also add a caching layer to this example in order to make it more realistic and scalable. An example of a full Directus deployment with also a Redis Cache is available using the `azuredeploy-with-redis.json` ARM template.

## Using existing Azure SQL

Directus can work with existing databases to make them immediately reachable via REST and GraphQL calls. You can deploy the `azuredeploy-existing-db.json` ARM template:

```
az deployment group create \
  --name AzureSQL_Directus \
  --resource-group [my-resource-group] \
  --template-file azuredeploy-existing-db.json \
  --parameters \
    location="[my-location]" \
    databaseServer="[my-database-server]" \
    databaseName="[my-database]" \
    databaseUser="[my-database-user]" \
    databasePassword="[my-database-user-password]"     
```

