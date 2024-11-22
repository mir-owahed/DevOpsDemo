# **GitOps Workflow with ArgoCD - Automated Application Deployment on EKS**

## **Table of Contents**
- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Step-by-Step Guide](#step-by-step-guide)
  - [Step 1: Create GitHub Repositories](#step-1-create-github-repositories)
  - [Step 2: Set Up Terraform for EKS](#step-2-set-up-terraform-for-eks)
  - [Step 3: Configure GitHub Actions Workflow for CI/CD](#step-3-configure-github-actions-workflow-for-cicd)
  - [Step 4: Install ArgoCD on EKS](#step-4-install-argocd-on-eks)
  - [Step 5: Access the ArgoCD UI](#step-5-access-the-argocd-ui)
  - [Step 6: Configure ArgoCD for Automated Application Deployment](#step-6-configure-argocd-for-automated-application-deployment)

---

## **Overview**
This guide covers the implementation of a GitOps workflow that automates the deployment of infrastructure and applications using Terraform, GitHub Actions, and ArgoCD. It includes:
- Provisioning an EKS cluster with Terraform.
- Configuring GitHub Actions for CI/CD.
- Installing and setting up ArgoCD to watch your GitHub application repository and automate deployments.

## **Prerequisites**
Make sure you have:
- An **AWS Account** with permissions to manage EKS resources.
- **Terraform** (v1.0+) installed.
- **kubectl** installed and configured.
- **AWS CLI** (v2.0+) installed and configured.
- A **GitHub Account**.
- **ArgoCD CLI** installed.

## **Step-by-Step Guide**

### **Step 1: Create GitHub Repositories**

#### **1.1 Infrastructure Repository**
1. Go to GitHub and create a new repository called **`infrastructure`**. This will store the Terraform configurations.
2. Clone the repository:

   ```bash
   git clone https://github.com/<your-username>/infrastructure.git
   cd infrastructure
   ```

#### **1.2 Application Repository**
1. Create another repository named **`application`** to store the Kubernetes manifest files for your application.
2. Clone the repository:

   ```bash
   git clone https://github.com/<your-username>/application.git
   cd application
   ```

### **Step 2: Set Up Terraform for EKS**

#### **2.1. Terraform Configuration Files**
In the `infrastructure` repository, create a directory called **`terraform`** and add the following files:

##### **main.tf** - VPC and EKS Cluster Configuration

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

##### **provider.tf** - AWS Provider Configuration

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "mir-terraform-s3-bucket"
    key    = "key/terraform.tfstate"
    region = "ap-south-1"
  }
}

provider "aws" {
  region = "ap-south-1"
}
```

#### **2.2. Initialize and Validate Infrastructure**
To deploy the infrastructure, navigate to the `infrastructure` directory and run:

```bash
terraform init
terraform plan
terraform apply
```

### **Step 3: Configure GitHub Actions Workflow for CI/CD**

#### **3.1. GitHub Actions Workflow File**
In the `infrastructure` repository, create a directory named `.github/workflows` and add a file called **`terraform.yml`**:

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

#### **3.2. Store AWS Credentials in GitHub**
1. Go to your GitHub repository settings.
2. Add the following secrets:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_REGION`

### **Step 4: Install ArgoCD on EKS**

#### **4.1. Access Your EKS Cluster**
Configure `kubectl` to connect to your EKS cluster:

```bash
aws eks update-kubeconfig --region ap-south-1 --name my-cluster
```

#### **4.2. Install ArgoCD**
1. Create a namespace for ArgoCD:

   ```bash
   kubectl create namespace argocd
   ```

2. Install ArgoCD using the official manifests:

   ```bash
   kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
   ```

3. Change the ArgoCD server service type to LoadBalancer:

   ```bash
   kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
   ```

4. Retrieve Initial Admin Credentials:

   ```bash
   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{

.data.password}" | base64 -d; echo
   ```

### **Step 5: Access the ArgoCD UI**

#### **5.1. Get the External IP of the ArgoCD Server**
To access the ArgoCD UI, retrieve the external IP:

```bash
kubectl get svc argocd-server -n argocd
```

Navigate to `http://<EXTERNAL-IP>` in your web browser.

#### **5.2. Login to ArgoCD**
- **Username**: `admin`
- **Password**: Retrieved from the previous step.

### **Step 6: Configure ArgoCD for Automated Application Deployment**

1. In the ArgoCD UI, click on **"New App"**.
2. Set the following configurations:
   - **Application Name**: `my-app`
   - **Project**: `default`
   - **Sync Policy**: Set to `Automatic` for automated deployments.
   - **Repository URL**: URL of your **`application`** GitHub repository.
   - **Path**: Specify the path to the Kubernetes manifests.
   - **Cluster URL**: `https://kubernetes.default.svc`
   - **Namespace**: `default`

3. Save the configuration. ArgoCD will now watch the repository for changes and automatically deploy the application to your EKS cluster.

---

That's it! You have now set up a fully automated GitOps workflow with Terraform, GitHub Actions, and ArgoCD on an EKS cluster.
