
# Fully Automated CI/CD Pipeline using GitHub Actions and Terraform to deploy a private and secured Kubernetes cluster on AWS EKS (v1.30)

## Project Overview
This guide provides step-by-step instructions to set up a **Fully Automated CI/CD Pipeline** using **GitHub Actions and Terraform** to deploy a private and secured Kubernetes cluster on **AWS EKS (v1.30)**. The infrastructure setup uses a remote backend (AWS S3) for centralized state management, ensuring collaboration among team members.

## Prerequisites
- **AWS Account** with proper permissions to manage EKS, IAM, and networking resources.
- **Terraform** installed locally for initial setup (optional).
- **GitHub Account** and repository to hold the Terraform code.
- **AWS CLI** configured with proper access keys.
- **kubectl** installed for Kubernetes management.
- Basic understanding of Terraform and GitHub Actions.

## Step 1: AWS Setup
1. **Create an S3 Bucket** for storing the Terraform state file:
   ```bash
   aws s3api create-bucket --bucket your-s3-bucket-name --region your-region --create-bucket-configuration LocationConstraint=your-region
   ```
   
2. **Enable Versioning** on the S3 bucket:
   ```bash
   aws s3api put-bucket-versioning --bucket your-s3-bucket-name --versioning-configuration Status=Enabled
   ```
   
3. **Create a DynamoDB Table** for state locking:
   ```bash
   aws dynamodb create-table --table-name your-dynamodb-table-name --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
   ```

## Step 2: GitHub Repository Setup
1. **Create a GitHub Repository** to store your Terraform code. Clone it locally if needed:
   ```bash
   git clone https://github.com/your-username/your-repository.git
   cd your-repository
   ```

2. **Add GitHub Secrets** for secure handling of sensitive information:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_REGION`
   - `S3_BUCKET_NAME`
   - `DYNAMODB_TABLE_NAME`

## Step 3: Terraform Configuration
1. **Set Up the Terraform Directory Structure**:
   ```
   ├── main.tf
   ├── variables.tf
   ├── outputs.tf
   ├── provider.tf
   └── backend.tf
   ```

2. **Configure the `provider.tf`** file:
   ```hcl
   provider "aws" {
     region = var.aws_region
   }
   ```

3. **Configure the `backend.tf`** file to use S3 as the remote backend:
   ```hcl
   terraform {
     backend "s3" {
       bucket         = var.s3_bucket_name
       key            = "terraform/state"
       region         = var.aws_region
       dynamodb_table = var.dynamodb_table_name
     }
   }
   ```

4. **Define the Infrastructure (`main.tf`)**:
   - Example for setting up an EKS cluster:
     ```hcl
     module "eks" {
       source          = "terraform-aws-modules/eks/aws"
       cluster_name    = var.cluster_name
       cluster_version = "1.30"
       subnets         = module.vpc.private_subnets
       vpc_id          = module.vpc.vpc_id

       node_groups = {
         eks_nodes = {
           desired_capacity = 3
           max_capacity     = 5
           min_capacity     = 1

           instance_type = "t3.medium"
         }
       }
     }
     ```

## Step 4: GitHub Actions Workflow Setup
1. **Create a GitHub Actions Workflow File** (`.github/workflows/terraform.yml`):
   ```yaml
   name: Terraform CI/CD Pipeline

   on:
     push:
       branches:
         - main
     pull_request:
       branches:
         - main

   jobs:
     terraform:
       name: Apply Terraform
       runs-on: ubuntu-latest

       steps:
       - name: Checkout Code
         uses: actions/checkout@v2

       - name: Setup Terraform
         uses: hashicorp/setup-terraform@v2
         with:
           terraform_version: 1.5.6

       - name: Configure AWS Credentials
         uses: aws-actions/configure-aws-credentials@v2
         with:
           aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
           aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
           aws-region: ${{ secrets.AWS_REGION }}

       - name: Terraform Init
         run: terraform init

       - name: Terraform Plan
         run: terraform plan

       - name: Terraform Apply
         if: github.ref == 'refs/heads/main'
         run: terraform apply -auto-approve
   ```

## Step 5: Write Terraform Variables (`variables.tf`)
Define the variables used in the configuration:
```hcl
variable "aws_region" {
  description = "AWS region to deploy resources"
  default     = "your-region"
}

variable "s3_bucket_name" {
  description = "S3 bucket for Terraform state"
}

variable "dynamodb_table_name" {
  description = "DynamoDB table for state locking"
}

variable "cluster_name" {
  description = "EKS cluster name"
  default     = "my-eks-cluster"
}
```

## Step 6: Initialize and Validate Infrastructure
1. **Push the Code** to the GitHub repository:
   ```bash
   git add .
   git commit -m "Initial Terraform setup for EKS"
   git push origin main
   ```

2. **GitHub Actions** will trigger the pipeline automatically:
   - **Terraform Init** initializes the configuration.
   - **Terraform Plan** provides a preview of changes.
   - **Terraform Apply** deploys the infrastructure if changes are made to the `main` branch.

## Step 7: Access and Secure the EKS Cluster
1. **Get the EKS Cluster Access**:
   ```bash
   aws eks update-kubeconfig --region your-region --name my-eks-cluster
   ```

2. **Deploy Kubernetes Resources** using `kubectl`.

## Step 8: Clean Up and Maintenance
1. To **destroy the infrastructure** using the pipeline:
   - Create a new GitHub Action workflow file, `.github/workflows/terraform-destroy.yml`.
   - Add steps similar to the previous workflow, but replace `terraform apply` with `terraform destroy`.

2. **Monitor Infrastructure** using AWS CloudWatch and other monitoring tools for EKS.

This setup ensures a collaborative environment for teams, allowing all members to work without local Terraform setups and keeping infrastructure consistent across deployments.
