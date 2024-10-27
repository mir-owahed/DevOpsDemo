# How to Create a Secured Kubernetes Cluster on AWS EKS Using AWS Console

![eks](https://github.com/user-attachments/assets/f427e4a8-83eb-4f78-addd-566220053dd7)


In this guide, you'll learn how to set up a secure Kubernetes cluster on AWS Elastic Kubernetes Service (EKS) using the AWS Management Console. We’ll configure a bastion host in the public subnet, deploy your Kubernetes cluster and node group in private subnets, and deploy a sample application to ensure everything is functioning correctly.

## Prerequisites

Before getting started, ensure you have the following:
- An **AWS account** with sufficient permissions.
- **AWS CLI** (optional, but recommended for easier cluster management).
- **kubectl** installed and configured on your local machine.

---
## Watch the Tutorial

[![Create a secured Kubernetes cluster on AWS EKS](https://img.youtube.com/vi/XWaLU0alrvY/0.jpg)](https://youtu.be/XWaLU0alrvY)

[Watch the full tutorial on YouTube](https://youtu.be/XWaLU0alrvY) to follow along with step-by-step instructions.

---
## Step 1: Create a VPC with Public and Private Subnets

To begin, you’ll need a VPC to host your cluster.

1. Navigate to the **VPC Console** in AWS.
2. Click on **Create VPC** and configure the following:
   - **VPC CIDR Block**: e.g., `10.0.0.0/16`.
   - **Subnets**: Create both public and private subnets across multiple availability zones for redundancy.
   - **Internet Gateway**: Attach this to the public subnet to allow external access.
   - **Route Tables**: Ensure you configure routing between the subnets properly, with the public subnet routing to the internet gateway.

You can use AWS-provided EKS VPC templates to automate some of this configuration.

---

## Step 2: Create a Bastion Host in the Public Subnet

To securely access your private Kubernetes cluster, you'll need a bastion host in the public subnet.

1. Go to the **EC2 Console** and click **Launch Instance**.
2. Choose an instance type, e.g., **t2.micro** for small workloads.
3. Select your **public subnet** in the **Network** section.
4. Create or select an existing key pair for SSH access.
5. Configure **Security Groups** to allow SSH access (port 22) from your IP address.
6. Launch the instance.

---

## Step 3: Create an EKS Cluster

1. Go to the **Amazon EKS Console** and click **Create Cluster**.
2. Fill out the following details:
   - **Cluster Name**: Give your cluster a name.
   - **Kubernetes Version**: Choose the latest stable version.
   - **Role**: Select an appropriate IAM role with the `AmazonEKSClusterPolicy` attached.
   - **VPC and Subnets**: Select the VPC and **private subnets** created earlier.
   - **Security Group**: Ensure the security group allows communication between the control plane and worker nodes.

3. Click **Create** and wait for the cluster to be provisioned.

---

## Step 4: Create an IAM Role for Worker Nodes

Now we’ll create an IAM role for your worker nodes.

1. Go to the **IAM Console** and create a new role.
2. Choose **EC2** as the trusted entity.
3. Attach the following managed policies:
   - `AmazonEKSWorkerNodePolicy`
   - `AmazonEKS_CNI_Policy`
   - `AmazonEC2ContainerRegistryReadOnly`
4. Name the role (e.g., `eks-node-role`) and create it.

---

## Step 5: Create a Node Group in the Private Subnets

1. In the **EKS Console**, select your cluster and navigate to the **Compute** tab.
2. Click **Add Node Group**.
3. Fill out the following details:
   - **Node Group Name**: Choose a name (e.g., `private-node-group`).
   - **IAM Role**: Select the IAM role you created earlier.
   - **Subnets**: Select the **private subnets** for the worker nodes.
   - **Instance Type**: Choose an instance type such as **t3.medium**.
   - **Scaling Configuration**: Set desired, minimum, and maximum nodes.
4. Click **Create** and wait for the node group to be ready.

---

## Step 6: Configure kubectl to Access the Cluster

Once your cluster is running, you'll need to configure `kubectl` to interact with it.

1. Open your terminal and run the following command:
   ```bash
   aws eks --region <region-code> update-kubeconfig --name <cluster-name>
   ```
2. Now, you can verify the configuration:
   ```bash
   kubectl get svc
   ```

---

## Step 7: Deploy a Sample Application

Now that your Kubernetes cluster is set up, you can deploy a sample application.

1. Create a file named `sample-app.yaml` with the following content:
```
   
  apiVersion: apps/v1
kind: Deployment # Kubernetes resource kind we are creating
metadata:
  name: boardgame-deployment
spec:
  selector:
    matchLabels:
      app: boardgame
  replicas: 2 # Number of replicas that will be created for this deployment
  template:
    metadata:
      labels:
        app: boardgame
    spec:
      containers:
        - name: boardgame
          image: owahed1/go-lang-app:0.0.2 # Image that will be used to containers in the cluster
          imagePullPolicy: Always
          ports:
            - containerPort: 8000 # The port that the container is running on in the cluster


---

apiVersion: v1 # Kubernetes API version
kind: Service # Kubernetes resource kind we are creating
metadata: # Metadata of the resource kind we are creating
  name: boardgame-service
spec:
  selector:
    app: boardgame
  ports:
    - protocol: "TCP"
      port: 80
      targetPort: 8000 
  type: LoadBalancer # type of the service.

```
2. Deploy the application with:
   ```bash
   kubectl apply -f sample-app.yaml
   ```

3. Check if the application is running:
   ```bash
   kubectl get pods
   ```

4. The application will create an external LoadBalancer, which you can access to test your deployment.

---

## Step 8: Access the Application 

---

