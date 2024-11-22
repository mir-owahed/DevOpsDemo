# Automated Infrastructure CI/CD Pipeline Using GitHub Actions to Deploy a Private and Secured Kubernetes Cluster on AWS EKS (v1.30)

## **Overview**

- **Tools Used**: GitHub Actions, Terraform, AWS EKS, EC2 (Bastion Host), AWS S3 for Terraform backend, ArgoCD.
- **Infrastructure Setup**:
  - EKS Cluster in a private subnet.
  - Bastion Host for secure access to the cluster.
  - GitHub Actions CI/CD for automated infrastructure deployment.
  - ArgoCD for managing Kubernetes resources.

## **Step-by-Step Guide**

### **Step 1: Set Up GitHub Repository and Secrets**

1. **Create a GitHub Repository** for your Terraform code.
2. **Add GitHub Secrets** for AWS credentials:
   - `AWS_ACCESS_KEY_ID`: Your AWS access key.
   - `AWS_SECRET_ACCESS_KEY`: Your AWS secret key.
   - Optional: Add `TF_VAR_region` and `TF_VAR_cluster_name` for Terraform variables.

### **Step 2: Create Terraform Configuration Files**

Create the following Terraform files in your repository.

#### **`provider.tf`**: Set up AWS provider and backend.

```hcl
# provider.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}
```

#### **`variables.tf`**: Define variables for reusability.

```hcl
# variables.tf

variable "region" {
  description = "The AWS region to deploy resources."
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
  default     = "my-private-eks-cluster"
}
```

#### **`main.tf`**: EKS cluster, VPC, and Bastion Host configuration.

```hcl
provider "aws" {
  region = "ap-south-1"
}

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

```


### **Step 3: Configure GitHub Actions Workflow**

Create a **`.github/workflows/terraform.yml`** file to automate infrastructure deployment using GitHub Actions.

```yaml
# .github/workflows/terraform.yml

name: 'Terraform CI/CD Pipeline'

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

jobs:
  terraform:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout Code
      uses: actions/checkout@v2

    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v2
      with:
        terraform_version: 1.9.8

    - name: Terraform Init
      env:
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
      run: terraform init

    - name: Terraform Plan
      env:
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
      run: terraform plan

    - name: Terraform Apply
      env:
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
      run: terraform apply -auto-approve
```


3. **Configure `kubectl` to access the EKS Cluster**:
   
   ```bash
   aws eks --region us-east-1 update-kubeconfig --name my-private-eks-cluster
   ```

### **Step 5: Install ArgoCD on the EKS Cluster**

1. **Create the ArgoCD namespace**:
   
   ```bash
   kubectl create namespace argocd
   ```

2. **Install ArgoCD using the official YAML**:
   
   ```bash
   kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
   ```

3. **Change the ArgoCD service to LoadBalancer**:
   
   ```bash
   kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
   ```

4. **Get the initial admin password**:
   
   ```bash
   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
   ```

### **Step 6: Access the ArgoCD UI**

1. **Retrieve the External IP of the ArgoCD Server**:
   
   ```bash
   kubectl get svc -n argocd argocd-server
   ```

   - Note the `EXTERNAL-IP` displayed. This is the address to access the ArgoCD UI.

2. **Access the ArgoCD UI**:
   - Open your web browser and navigate to `http://<EXTERNAL-IP>`.
   - **Username**: `admin`
   - **Password**: Use the password retrieved in the previous step.

## **Conclusion**

This guide sets up a secure infrastructure CI/CD pipeline using GitHub Actions for Terraform deployment on AWS EKS. It includes provisioning an EKS cluster, setting up a Bastion Host, installing ArgoCD, and accessing the ArgoCD UI for Kubernetes resource management. This configuration ensures centralized and automated infrastructure management, enhancing collaboration and security.

--- 
