
![gitops-argocd](https://github.com/user-attachments/assets/f86076e1-e38c-49af-bb48-802e23cba6b2)

1. Install Argo CD on Kubernetes

Prerequisites

Install Kubernetes or have access to a cluster. You must have Kubernetes installed.
```
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```
Change the argocd-server service type to LoadBalancer:
```bash
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
```
Get Credentials
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```
---
Access the ArgoCD UI**

1. **Retrieve the External IP of the ArgoCD Server**:
   
   ```bash
   kubectl get svc -n argocd argocd-server
   ```

   - Note the `EXTERNAL-IP` displayed. This is the address to access the ArgoCD UI.

2. **Access the ArgoCD UI**:
   - Open your web browser and navigate to `http://<EXTERNAL-IP>`.
   - **Username**: `admin`
   - **Password**: Use the password retrieved in the previous step.
---
OR. Install Argo CD
1. <https://operatorhub.io/operator/argocd-operator>
2. <https://argocd-operator.readthedocs.io/en/latest/usage/basics/>
   
Install on Kubernetes

    Install Operator Lifecycle Manager (OLM), a tool to help manage the Operators running on your cluster.
    ```
    $ curl -sL https://github.com/operator-framework/operator-lifecycle-manager/releases/download/v0.28.0/install.sh | bash -s v0.28.0
    ```
    Copy to Clipboard

    Install the operator by running the following command:
    What happens when I execute this command?
    ```
    $ kubectl create -f https://operatorhub.io/install/argocd-operator.yaml
    ```
    Copy to Clipboard

    This Operator will be installed in the "operators" namespace and will be usable from all namespaces in the cluster.

    After install, watch your operator come up using next command.
    ```
    $ kubectl get csv -n operators
    ```
    
    Copy to Clipboard

    To use it, checkout the custom resource definitions (CRDs) introduced by this operator to start using it.

Argocd hands-on on minikube
```
minikube start

  303  kubectl get nodes

  304  kubectl get n

  305  kubectl get namespace

  306  kubectl create namespace argocd

  307  kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

  308  minikube status

  309  kubectl get pods -n argocd -w

  310  kubectl get svc

  311  kubectl get svc -n argocd

  312  kubectl edit svc argocd-server -n argocd

  313  minikube service list -n argocd

  314  minikube service argocd-server -n argocd
```
```
308  kubectl get secret -n argocd

  309  kubectl edit secret argocd-initial-admin-secret -n argocd

  310  echo cVVTQlBFNm5DV2xhNVJ3Wg== | base64 --decode

  311  kubectl get deployment

  312  kubectl get deploy

  313  curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64

  314  sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd

  315  rm argocd-linux-amd64

```

References:
1. <https://github.com/argoproj/argocd-example-apps>
2. <https://argo-cd.readthedocs.io/en/stable/getting_started>
3. <https://argo-cd.readthedocs.io/en/stable/user-guide/commands/argocd/>
4. <https://argo-cd.readthedocs.io/en/stable/user-guide/commands/argocd_app_create/>
