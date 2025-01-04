# Deploying a Web Application Using Helm in Kubernetes

## Table of Contents

1. **Introduction**
   - Overview
   - Prerequisites

2. **Step 1: Install Helm**
   - For Linux and macOS Users
   - For Windows Users

3. **Step 2: Create a New Helm Chart**

4. **Step 3: Customize Your Helm Chart**
   - Understanding Helm Charts, Values, and Templates

5. **Step 4: Deploying Your Application**

6. **Step 5: Integrating Helm with CI/CD (Jenkins)**

7. **Step 6: Update Helm Chart and Trigger Jenkins Pipeline**

---

## Introduction

### Overview
Helm is a package manager for Kubernetes applications. It simplifies the deployment and management of applications on Kubernetes by providing a way to define, install, and upgrade even the most complex Kubernetes applications. This practical exercise offers a hands-on experience with Helm, creating, configuring, and deploying a simple web application. By utilizing Helm, you will streamline Kubernetes application management, gaining insights into its efficiencies.

Imagine you're a chef in a busy kitchen. Kubernetes is the kitchen, Helm is the recipe book, and each chart is a recipe. Using Helm allows you to efficiently prepare multiple dishes (applications) while maintaining consistency and quality. This project will guide you through becoming an efficient "chef" in the Kubernetes kitchen.

### Prerequisites
- A working Kubernetes cluster
- kubectl installed and configured
- Basic knowledge of Kubernetes concepts
- Administrative access to install Helm

---

## Step 1: Install Helm

### For Linux and macOS Users

1. **Download Helm:**
   ```bash
   curl -L https://get.helm.sh/helm-v3.5.0-linux-amd64.tar.gz -o helm.tar.gz
   ```
   For macOS:
   ```bash
   curl -L https://get.helm.sh/helm-v3.5.0-darwin-amd64.tar.gz -o helm.tar.gz
   ```

2. **Extract the Downloaded File:**
   ```bash
   tar -zxvf helm.tar.gz
   ```

3. **Move the Helm Binary:**
   For Linux:
   ```bash
   mv linux-amd64/helm /usr/local/bin/helm
   ```
   For macOS:
   ```bash
   mv darwin-amd64/helm /usr/local/bin/helm
   ```

4. **Verify Installation:**
   ```
   helm version
   ```

5. **Clean Up:**
   ```bash
   rm helm.tar.gz && rm -r linux-amd64
   ```

### For Windows Users

1. **Install Helm Using Chocolatey:**
   ```bash
   choco install kubernetes-helm
   ```
   Note: Install Chocolatey if it’s not already installed.

2. **Verify Installation:**
   ```bash
   helm version
   ```

---

## Step 2: Create a New Helm Chart

1. **Create Project Directory:**
   ```bash
   mkdir helm-web-app
   cd helm-web-app
   ```

2. **Create a New Chart:**
   ```bash
   helm create webapp
   ```

3. **Initialize a Git Repository:**
   ```bash
   git init
   git add .
   git commit -m "Initial Helm webapp chart"
   ```

4. **Push to Remote Repository:**
   - Create a new repository on your Git hosting service.
   - Push your local repository to the remote:
     ```bash
     git remote add origin <REMOTE_REPOSITORY_URL>
     git push -u origin master
     ```

---

## Step 3: Customize Your Helm Chart

### Understanding Helm Charts, Values, and Templates

#### Why Helm Charts Are Needed:
- Helm charts bundle pre-configured Kubernetes resources.
- Simplify deployment and management of applications.
- Promote reusability and consistency.

#### What Are Charts, Values, and Templates:
- **Charts:** Directories containing resource definitions for an application.
- **Values:** `values.yaml` provides configurable values for templates.
- **Templates:** Files in the `templates/` directory generate Kubernetes manifests, referencing values from `values.yaml`.

1. **Explore the `webapp` Directory:**
   - **Chart.yaml:** Metadata about the chart.
   - **values.yaml:** Default configuration values.
   - **templates/:** Template files for Kubernetes resources.

2. **Modify `values.yaml`:**
   Update the following:
   ```yaml
   replicaCount: 2
   image:
     repository: nginx
     tag: stable
     pullPolicy: IfNotPresent
   ```

3. **Customize `templates/deployment.yaml`:**
   - Remove:
     ```yaml
     {{- toYaml .Values.resources | nindent 12 }}
     ```
   - Add:
     ```yaml
     resources:
       requests:
         memory: "128Mi"
         cpu: "100m"
       limits:
         memory: "256Mi"
         cpu: "200m"
     ```

4. **Commit and Push Changes:**
   ```bash
   git add .
   git commit -m "Customized Helm chart"
   git push
   ```

---

## Step 4: Deploying Your Application

1. **Deploy with Helm:**
   Navigate to the root of your project directory:
   ```bash
   helm install my-webapp webapp
   ```

2. **Check Deployment:**
   ```bash
   kubectl get deployments
   ```

3. **Visit Application URL:**
   - Get the application URL:
     ```bash
     export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=webapp,app.kubernetes.io/instance=my-webapp" -o jsonpath="{.items[0].metadata.name}")
     export CONTAINER_PORT=$(kubectl get pod --namespace default $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
     kubectl --namespace default port-forward $POD_NAME 8081:$CONTAINER_PORT
     ```
   - Visit:
     ```
     http://127.0.0.1:8081
     ```

