
# Displaying attributes of favorite Pokemon using AWS Lambda and API Gateway

This project demonstrates how to use AWS Lambda and API Gateway to display the attributes of my five favorite Pokemon using public data from [https://pokeapi.co/](https://pokeapi.co/).

The project consists of two parts: the AWS Lambda function and the API Gateway. The Lambda function is written in Python and retrieves data from the PokeAPI. The API Gateway provides a RESTful API endpoint that can be used to retrieve the Pokemon attributes.

## Prerequisites

To use this project, you will need:

-   An AWS account
-   Terraform installed on your local machine

## Getting Started

To get started, follow these steps. Note that all AWS resources will be created in the environment specified from your existing ~/.aws configuration:

1.  Clone the repository to your local machine.
    
2.  Change into the project directory.
    
3.  Initialize the Terraform configuration.

`terraform init` 

4.  Create a Terraform execution plan.

`terraform plan` 

5.  Apply the Terraform configuration.

`terraform apply` 

6.  After the Terraform configuration is applied successfully, you can retrieve the API Gateway endpoint URL by running:

`terraform output endpoint_url` 

7.  Copy the API Gateway endpoint URL into your browser or use a tool like curl or Postman to make a GET request to the endpoint URL.

## Project Structure

The project is structured as follows:
`.` 

` ├── README.md ` 

` ├── mvp_solution`

 ` │   ├── pokemon_lambda.py` 
 
 ` ├── templates`
 
 ` │   ├── lambda`
 
 ` │   |  ├── pokemon_lambda.py`
 
` ├── main.tf` 

` ├── outputs.tf` 

` ├── variables.tf` 

The `mvp_solution` directory contains the "Minimum Viable Product" for this assignment - the raw Python code for the AWS Lambda function that retrieves data from the PokeAPI.

The rest of the project is a terraform project that contains the configuration for the AWS infrastructure, including the Lambda function, API Gateway, and associated resources.

## Cleaning Up

To clean up the resources created by this project, run the following command:

Copy code

`terraform destroy` 

## Rest Endpoint

**Request**
The endpoint accepts a GET request. No parameters are required.
**Response**
The response is a JSON object with the following structure:

> {
  "pokemon1": {
    "name": "pokemon1",
    "height": (insert height),
    "weight": (insert weight),
    "color": (insert color)
    "moves": [
      (insert move),
      (insert move)
    ],
    "base_happiness": (insert happiness)
  },
  "pokemon2": {
    "name": "pokemon2",
    "height": (insert height),
    "weight": (insert weight),
    "color": (insert color)
    "moves": [
      (insert move),
      (insert move)
    ],
    "base_happiness": (insert happiness)
  },
  .
  .
  .
  "average_base_happiness": (insert average base happiness),
  "median_base_happiness": (insert average median happiness)


## Conclusion + Thought Process

**Terraform Structure**
This project is structured in a manner to facilitate quick and simple standup, test, and destruction using terraform. To this end, a few changes were made in this quick project that would not have been made in any serious project at work, such as:

- Local state vs Remote state: A Terraform best practice is to manage state remotely (such as in an s3 bucket) and to enable state locking (via dynamodb). However, this would require the tester to setup additional AWS resources which would not be deleted in a `terraform destroy` command. The current setup with a simple local state allows the tester to completely setup and destroy the project without any residuals.
- Provider Authentication:  good security practice for terraform projects would be to assume an IAM role in the provider block. However, knowing nothing about the tester's AWS environment, no role is assumed. Instead, this project piggybacks off of the existing configuration in the tester's `~/.aws/credentials` and `~/.aws/config`

**Lambda Code**
The lambda code in simple english does the following:

- Iterates over a list of favorite_pokemon
- Calls the `"https://pokeapi.co/api/v2/pokemon/{name}"` api on each of the pokemon
- Retrieves the `order` of the pokemon in addition to the base stats of `name`,`weight`, etc
- Uses the `order` to call the `"https://pokeapi.co/api/v2/pokemon-species/{order}"` api in order to retrieve the rest of the needed attributes (happiness, color).
- Creates a map of all these attributes, associates it with the pokemon, and adds it to a `results` map
- Adds the pokemon's base happiness to a `happiness` list.
	- Once iteration over all favorite_pokemon has finished, performs math operation on happiness list to determine mean/median happiness of the group
	- Appends mean/median happiness to `results`
- Returns `results`


A thing to note in the python lambda code:

- User-Agent header change: Browsing the code, you may notice a peculiar line `base_req.add_header('User-Agent', 'cheese')`. This is needed because attempting to scrape the pokeapi endpoint with the default python user agent gave me 403 errors. A google search of the problem led me to this comment: https://github.com/PokeAPI/pokeapi/issues/135#issuecomment-198256744 in which user "martinpeck" provides the workaround of altering the user agent.

## Potential Improvement

The primary drawback of the lambda as currently implemented is its reliance on a series of 10 api calls (2 for each favorite pokemon) to the pokeapi - resulting in very long compute durations. An improvement I would make (potentially out of scope) would be to scrape the pokeapi, and then store the attributes for each pokemon in a nosql database such as DynamoDB. Then, the lambda function could query the DynamoDB table rather than the third party endpoint, resulting in much quicker execution and thus large cost savings. 

The DynamoDB table could be kept up to date on a regular schedule via running the scraper on a cronjob or as a scheduled lambda.
