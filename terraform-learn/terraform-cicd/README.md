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

provider "aws" {
  region = var.region
}

# Remote backend configuration (using S3 and DynamoDB for state locking)
terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "eks-cluster/terraform.tfstate"
    region         = var.region
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
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
# main.tf

# VPC Configuration
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "my-eks-vpc"
  }
}

# Create Private Subnets
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index}.0/24"
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = false
  tags = {
    Name = "my-private-subnet-${count.index}"
  }
}

# Create Internet Gateway for NAT Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "my-eks-igw"
  }
}

# Create EKS Cluster
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.cluster_name
  cluster_version = "1.30"
  subnets         = aws_subnet.private[*].id
  vpc_id          = aws_vpc.main.id
  tags = {
    Name = var.cluster_name
  }
}

# EC2 Bastion Host Configuration
resource "aws_key_pair" "bastion_key" {
  key_name   = "bastion-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "bastion" {
  ami                    = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 AMI
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private[0].id
  associate_public_ip_address = true
  key_name               = aws_key_pair.bastion_key.key_name

  tags = {
    Name = "bastion-host"
  }
}
```

#### **`outputs.tf`**: Outputs for Bastion Host and SSH Key.

```hcl
# outputs.tf

output "bastion_public_ip" {
  description = "Public IP of the Bastion Host"
  value       = aws_instance.bastion.public_ip
}

output "bastion_ssh_key" {
  description = "SSH Key for the Bastion Host"
  value       = aws_key_pair.bastion_key.key_name
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

### **Step 4: Access EKS Using the Bastion Host**

1. **Connect to the Bastion Host**:
   
   ```bash
   ssh -i ~/.ssh/id_rsa ec2-user@<Bastion_Public_IP>
   ```

2. **Install `kubectl` on the Bastion Host**:
   
   ```bash
   curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.24.0/2022-06-23/bin/linux/amd64/kubectl
   chmod +x ./kubectl
   sudo mv ./kubectl /usr/local/bin
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

This Markdown file is now formatted for easy reading and step-by-step execution. Feel free to modify as needed!
