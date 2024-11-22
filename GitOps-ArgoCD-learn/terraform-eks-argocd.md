# GitOps ArgoCD Implementation: Automate Infrastructure Creation with Terraform & GitHub Actions, and Application Deployment on EKS Cluster

This guide provides a comprehensive walkthrough for setting up a GitOps workflow. It uses **Terraform** and **GitHub Actions** to automate infrastructure provisioning on **AWS EKS** and leverages **ArgoCD** for automating application deployments.

## **Table of Contents**
- [Overview](#overview)
- [Pre-requisites](#pre-requisites)
- [Step 1: Create GitHub Repositories](#step-1-create-github-repositories)
  - [1.1. Create Infrastructure Repository](#11-create-infrastructure-repository)
  - [1.2. Create Application Repository](#12-create-application-repository)
- [Step 2: Configure GitHub Secrets](#step-2-configure-github-secrets)
- [Step 3: Configure Terraform for EKS Setup](#step-3-configure-terraform-for-eks-setup)
  - [3.1. Create Terraform Files](#31-create-terraform-files)
  - [3.2. Initialize and Validate Infrastructure](#32-initialize-and-validate-infrastructure)
- [Step 4: Create GitHub Actions Workflow](#step-4-create-github-actions-workflow)
- [Step 5: Install ArgoCD on EKS Cluster](#step-5-install-argocd-on-eks-cluster)
- [Step 6: Access the ArgoCD UI](#step-6-access-the-argocd-ui)
- [Step 7: Configure ArgoCD for Automated Application Deployment](#step-7-configure-argocd-for-automated-application-deployment)

---

## **Overview**
This guide will help you set up an automated GitOps pipeline:
1. **Automate Infrastructure**: Use Terraform and GitHub Actions to provision an EKS cluster.
2. **Automate Application Deployment**: Use ArgoCD to monitor the application repository and deploy updates to the EKS cluster automatically.

---

## **Pre-requisites**
- **GitHub account** to create repositories.
- **AWS account** with permissions to create EKS resources.
- **AWS CLI** installed and configured on your local machine.
- **kubectl** installed for Kubernetes cluster management.
  
---

## **Step 1: Create GitHub Repositories**

### **1.1. Create Infrastructure Repository**
- Create a GitHub repository called `infrastructure` to store Terraform configurations.
- Initialize the repository with a `README.md` file.

### **1.2. Create Application Repository**
- Create a separate GitHub repository called `application` to store Kubernetes manifest files.
- Initialize the repository with a `README.md` file.

---

## **Step 2: Configure GitHub Secrets**

### **2.1. GitHub Secrets Setup**
To authenticate GitHub Actions with AWS for infrastructure deployment:
1. Go to your **Infrastructure Repository** in GitHub.
2. Navigate to `Settings > Secrets and variables > Actions`.
3. Add the following secrets:
   - **AWS_ACCESS_KEY_ID**
   - **AWS_SECRET_ACCESS_KEY**

These secrets are necessary for AWS authentication when GitHub Actions runs the Terraform configuration.

---

## **Step 3: Configure Terraform for EKS Setup**

### **3.1. Create Terraform Files**
In the `infrastructure` repository, create the following Terraform files:

#### **`main.tf`** (Terraform configuration for EKS)
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
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["m5.xlarge"]

      min_size     = 1
      max_size     = 1
      desired_size = 1
    }
  }
}
```

#### **`provider.tf`** (Specifies the AWS provider)
```hcl
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

#### **`backend.tf`** (Configure S3 backend for state management)
```hcl
terraform {
  backend "s3" {
    bucket = "mir-terraform-s3-bucket"
    key    = "key/terraform.tfstate"
    region = "ap-south-1"
  }
}
```

### **3.2. Initialize and Validate Infrastructure**
Push the code to your GitHub `infrastructure` repository:
```bash
git add .
git commit -m "Initial Terraform setup for EKS"
git push origin main
```

---

## **Step 4: Create GitHub Actions Workflow**

Create a GitHub Actions workflow file to automate Terraform deployment.

#### **`.github/workflows/terraform.yml`**
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

GitHub Actions will:
- Initialize Terraform.
- Plan the infrastructure.
- Apply changes to the `main` branch.

---

## **Step 5: Install ArgoCD on EKS Cluster**

1. **Configure `kubectl` to access your EKS cluster**:
   ```bash
   aws eks update-kubeconfig --region ap-south-1 --name my-cluster
   kubectl cluster-info
   kubectl get nodes
   ```
  
2. **Install ArgoCD**:
   ```bash
   kubectl create namespace argocd
   kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
   ```

3. **Change the ArgoCD server service type to LoadBalancer**:
   ```bash


   kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
   ```

4. **Retrieve Initial Admin Credentials**:
   ```bash
   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
   ```

---

## **Step 6: Access the ArgoCD UI**

1. **Get the External IP of the ArgoCD server**:
   ```bash
   kubectl get svc argocd-server -n argocd
   ```

2. **Access the ArgoCD UI** by navigating to `http://<EXTERNAL-IP>` in your browser.
3. **Login to ArgoCD**:
   - **Username**: `admin`
   - **Password**: Retrieved from the previous step.

---

## **Step 7: Configure ArgoCD for Automated Application Deployment**

1. **Log in to ArgoCD UI**.
2. **Add a New Application**:
   - In ArgoCD UI, click on **New App**.
   - Fill in the following details:
     - **Application Name**: `my-app`
     - **Project**: `default`
     - **Sync Policy**: Automatic (if desired)
   - **Source**:
     - **Repository URL**: `https://github.com/your-username/application`
     - **Revision**: `main`
     - **Path**: `/` (or the relevant folder for manifests)
   - **Destination**:
     - **Cluster**: `https://kubernetes.default.svc`
     - **Namespace**: `default` (or any other)

3. **Save** the configuration. ArgoCD will now monitor the application repository for changes and deploy them automatically to the EKS cluster.

---

By following this guide, you now have a fully automated GitOps pipeline using **Terraform**, **GitHub Actions**, and **ArgoCD**. Your EKS infrastructure is provisioned, and application deployments are automated through ArgoCD.
