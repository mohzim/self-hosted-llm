# Self Hosted LLM
Repo to demo self-hosting LLM on AWS EKS using llm-d router and vLLM model serving engine.

## Overview

## Cost 

## Prerequisite
* AWS CLI, HF_TOKEN, kubectl, Terraform backend buckets

## Deployment Steps

### Clone repo

1. Clone this GitHub Repo

    `git clone https://github.com/mohzim/self-hosted-llm.git`


### Setup reources on AWS Cloud   

2. Initialize terraform

    `terraform -chdir=terraform init -backend-config="bucket=mohzim-terraform" -backend-config="key=terraform-self-hosted-llm-tfstate" -backend-config="region=ap-south-1" -input=false`

3. Verify resource creation
        
    `terraform -chdir=terraform plan -input=false`

4. Create resources in AWS Cloud
        
    `terraform -chdir=terraform apply -input=false`

### Setup kubectl to connect to AWS Kubernetes Cluster

4. Update your local kubeconfig (Replace with you eks clustername from step 5)
    `aws eks update-kubeconfig --region us-east-2 --name "eks-cluster-name"`

## Clean-up
1. Destroy cloud resources

    `terraform -chdir=terraform destroy -input=false -auto-approve`

## To-do-list
1. Add licensing note for llm-d parser
2. Update terraform init command without any backend prerequisites.   