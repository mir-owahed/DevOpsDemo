# Automated Infrastructure CI/CD Pipeline for EKS Cluster

## **Project Overview**
This project sets up a fully automated CI/CD pipeline for deploying a Kubernetes cluster on AWS EKS (v1.30) using GitHub Actions and Terraform. A remote backend (AWS S3) is used for state management, ensuring centralized infrastructure changes and collaboration without local setups. ArgoCD is also installed for Kubernetes resource management.

## **Prerequisites**
- **AWS Account** with appropriate permissions for managing EKS, IAM, and networking.
- **Terraform** installed locally (initial setup only).
- **GitHub Account** with a repository for storing Terraform code.
- **AWS CLI** installed and configured with proper credentials.
- **kubectl** installed to manage the EKS cluster.
- Basic knowledge of **Terraform** and **GitHub Actions**.

## **Step 1: AWS Setup**
### 1. Create an S3 Bucket for storing the Terraform state file:
   ```bash
   aws s3api create-bucket --bucket your-s3-bucket-name --region your-region --create-bucket-configuration LocationConstraint=your-region
   ```

### 2. Enable Versioning on the S3 bucket:
   ```bash
   aws s3api put-bucket-versioning --bucket your-s3-bucket-name --versioning-configuration Status=Enabled
   ```

### 3. Create a DynamoDB Table for state locking:
   ```bash
   aws dynamodb create-table --table-name your-dynamodb-table-name --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
   ```

## **Step 2: GitHub Repository Setup**
### 1. Create a GitHub Repository to store your Terraform code:
   ```bash
   git clone https://github.com/your-username/your-repository.git
   cd your-repository
   ```

### 2. Add GitHub Secrets for secure credentials:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_REGION`
   - `S3_BUCKET_NAME`
   - `DYNAMODB_TABLE_NAME`

......................
### **1. Check GitHub Secrets Setup**
Ensure that the GitHub Secrets (`AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`) are correctly set up in your GitHub repository.

1. **Go to your GitHub Repository**.
2. **Navigate to `Settings` > `Secrets and variables` > `Actions`**.
3. **Verify** that:
   - You have two secrets: `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`.
   - The values are correctly copied from your AWS IAM user credentials.

### **2. Ensure Correct AWS Region in Workflow**
Make sure that the `aws-region` in the workflow configuration is correctly set to the region you're using for your S3 bucket and DynamoDB table. For example:

```yaml
with:
  aws-region: us-east-1
```

Replace `us-east-1` with your actual region if it's different.
...................................

## **Step 3: Terraform Configuration**
### 1. Set Up the Terraform Directory Structure:
   ```
   ├── main.tf
   ├── variables.tf
   ├── outputs.tf
   ├── provider.tf
   └── backend.tf
   ```

### 2. Configure the Provider (`provider.tf`):
   ```hcl
   provider "aws" {
     region = var.aws_region
   }
   ```

### 3. Configure the Backend (`backend.tf`) to use S3:
   ```hcl
   terraform {
    backend "s3" {
        bucket = "mir-terraform-s3-bucket"
        key    = "key/terraform.tfstate"
        region     = "ap-south-1"        
    }
}
   ```

### 4. Define the Infrastructure (`main.tf`):
   Example setup for an EKS cluster:
   ```hcl
  
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }
}

resource "aws_route_table_association" "subnet_1_association" {
  subnet_id      = aws_subnet.subnet_1.id
  route_table_id = aws_route_table.main.id
}

resource "aws_route_table_association" "subnet_2_association" {
  subnet_id      = aws_subnet.subnet_2.id
  route_table_id = aws_route_table.main.id
}

resource "aws_route_table_association" "subnet_3_association" {
  subnet_id      = aws_subnet.subnet_3.id
  route_table_id = aws_route_table.main.id
}

resource "aws_subnet" "subnet_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "subnet_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "subnet_3" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "ap-south-1c"
  map_public_ip_on_launch = true
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "my-cluster"
  cluster_version = "1.31"

  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  vpc_id                   = aws_vpc.main.id
  subnet_ids               = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id, aws_subnet.subnet_3.id]
  control_plane_subnet_ids = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id, aws_subnet.subnet_3.id]

  eks_managed_node_groups = {
    green = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["m5.xlarge"]

      min_size     = 1
      max_size     = 1
      desired_size = 1
    }
  }
}

   ```

## **Step 4: GitHub Actions Workflow Setup**
### 1. Create a GitHub Actions Workflow File (`.github/workflows/terraform.yml`):
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

## **Step 5: Write Terraform Variables (`variables.tf`)**
Define the variables used in your configuration:
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

## **Step 6: Initialize and Validate Infrastructure**
### 1. Push the Code to the GitHub repository:
   ```bash
   git add .
   git commit -m "Initial Terraform setup for EKS"
   git push origin main
   ```

### 2. GitHub Actions will trigger the pipeline automatically:
   - **Terraform Init** initializes the configuration.
   - **Terraform Plan** previews changes.
   - **Terraform Apply** deploys infrastructure on the `main` branch.

## **Step 7: Install ArgoCD on EKS Cluster**
### 1. Ensure access to your EKS cluster and configure `kubectl`:
   ```bash
   aws eks update-kubeconfig --region your-region --name your-cluster-name
   ```

### 2. Install ArgoCD:
   ```bash
   kubectl create namespace argocd
   kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
   ```

### 3. Change the ArgoCD server service type to LoadBalancer:
   ```bash
   kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
   ```

### 4. Retrieve Initial Admin Credentials:
   ```bash
   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
   ```

## **Step 8: Access the ArgoCD UI**
### 1. Get the External IP of the ArgoCD server:
   ```bash
   kubectl get svc argocd-server -n argocd
   ```
   Navigate to `http://<EXTERNAL-IP>` to access the ArgoCD UI.

### 2. Login to ArgoCD:
   - **Username**: `admin`
   - **Password**: Retrieved from the previous step.

## **Step 9: Clean Up and Maintenance**
### 1. To destroy the infrastructure using the pipeline:
   - Create a GitHub Action workflow file `.github/workflows/terraform-destroy.yml`.
   - Use steps similar to the apply workflow, but replace `terraform apply` with `terraform destroy`.

### 2. Monitor Infrastructure using AWS CloudWatch, Prometheus, or other EKS monitoring tools.
```
