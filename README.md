# AWS SageMaker sentiment analysis

## Introduction

This repo contains the terraform files needed to expose an endpoint for sentiment analysis using AWS SageMaker.

> The model used is a pre-trained model from HuggingFace. [Here](https://huggingface.co/SamLowe/roberta-base-go_emotions) is the link, all credits to the author. I am not responsible for any costs incurred by using this repo, please read the terraform files and understand what resources are being created before running them.

This is a demonstration of how to:
- use the API Gateway to expose a REST API
- use Lambda functions to process the requests and send them to SageMaker
- use SageMaker to deploy a model as an inference endpoint
- use DynamoDB to store the results of the requests
- use S3 to store the Lambda functions code
- use GitHub Actions to implement a CI/CD pipeline to deploy the infrastructure (see the Additional steps section)

### Project structure:
- `terraform/`: contains the terraform files to provision the resources
- `code/lambda/`: contains the code for the Lambda function

## Final result

Screenshot of the endpoint in action using Hoppscotch:

## Installation

### Prerequisites

You have the permissions in AWS to create the following resources:
- IAM roles
- S3 buckets
- SageMaker endpoint
- API Gateway
- Lambda functions
- DynamoDB tables

You (obviously) have terraform installed in your machine.

### Clone the repo and provision the resources

```bash
git clone https://github.com/fedeztk/aws-sagemaker-sentiment-analysis
cd aws-sagemaker-sentiment-analysis/terraform
# adjust the variables in the variables.tf file
terraform init
terraform apply # check the output and type yes when prompted
```

The terraform script will output the following:
- The API Gateway endpoint
- The API Gateway path to use
- The id of the key to use in the request header

### How to use the endpoint

Get the API key from the AWS console, under API Gateway -> API Keys  (check that the id of the key is the same as the one outputted by terraform). Use the key in the request header as follows:

```bash
curl -X POST -H "x-api-key: $YOUR_API_KEY" $YOUR_API_GATEWAY_ENDPOINT/$YOUR_API_GATEWAY_PATH/sentiment/?data=$YOUR_TEXT
```

Or use whatever tool you want to make the request (Postman, Hoppscotch, etc.).

## Additional steps

If you want to implement a CI/CD pipeline using GitHub Actions that deploys the infrastructure automatically when you push to the master branch, follow these steps:

- create a `.github/workflows` folder in the root of the repo
- create the 2 AWS secrets `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` in the repo settings, under Secrets
- create a `terraform.yml` file in the `.github/workflows` folder with the following content

```yaml
name: 'Terraform CI/CD'

on:
  push:
    branches:
    - master
  pull_request:

jobs:
  terraform:
    name: 'Terraform'
    runs-on: ubuntu-latest
    
    env:
      AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
      AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY}}
    
    steps:
    - name: Checkout
      uses: actions/checkout@v2

    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v1
      with:
        terraform_version: 0.11.13

    - name: Terraform Init
      run: terraform init

    - name: Terraform Format
      run: terraform fmt -check

    - name: Terraform Plan
      run: terraform plan

    - name: Terraform Apply
      if: github.ref == 'refs/heads/master' && github.event_name == 'push'
      run: terraform apply -auto-approve
```