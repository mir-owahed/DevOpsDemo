
# GitLab CI Pipeline for Java Applications | DevSecOps Tutorial with SonarQube, Docker, and AWS Setup

In this guide, we’ll walk through the process of building a complete GitLab-CI pipeline for **Java-based applications**, focusing on **DevSecOps** best practices. We’ll cover everything from setting up infrastructure to running essential pipeline jobs like testing, code quality checks with SonarQube, building the application, and containerizing it with Docker.

## Watch the Tutorial

[![GitLab CI Pipeline Project | DevSecOps Tutorial with SonarQube, Docker, and AWS Setup](https://img.youtube.com/vi/7UZodcpyiNA/0.jpg)](https://youtu.be/7UZodcpyiNA)

[Watch the full tutorial on YouTube](https://youtu.be/7UZodcpyiNA) to follow along with step-by-step instructions.

## Code Repository

You can find the complete code repository for this tutorial here: [GitLab Boardgame Repository](https://gitlab.com/mir-owahed/Boardgame).

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Step 1: Setting Up GitLab Runner on AWS](#step-1-setting-up-gitlab-runner-on-aws)
3. [Step 2: Setting Up SonarQube Server on AWS](#step-2-setting-up-sonarqube-server-on-aws)
4. [Step 3: Writing the GitLab CI Pipeline Script](#step-3-writing-the-gitlab-ci-pipeline-script)
   - Test Job
   - SonarQube Code Quality Check Job
   - Build/Package the Application Job
   - Containerize and Push to Docker Hub Job
5. [Step 4: Running the Pipeline](#step-4-running-the-pipeline)
6. [Conclusion](#conclusion)

---

## Prerequisites

Before starting, ensure you have the following ready:
- A **GitLab** project for your Java application.
- AWS account with proper access to create resources (EC2 instances for the runner and SonarQube server).
- Docker installed locally or on your target servers.
- **Docker Hub** account for pushing containerized images.
- Basic understanding of **Java**, **Docker**, and **GitLab CI/CD** pipelines.

---

## Step 1: Setting Up GitLab Runner on AWS

The **GitLab Runner** is responsible for executing the jobs defined in your `.gitlab-ci.yml` file. In this step, we will set up a runner on an AWS EC2 instance.

### Instructions:
1. Launch an **EC2 instance** on AWS (Ubuntu preferred).
2. SSH into the instance and install Docker:
   ```bash
   sudo apt update
   sudo apt install docker.io -y
   ```
3. Install GitLab Runner:
   
4. Register the runner with your GitLab project:
  
   - Use Docker as the executor.
  

The runner is now set up and ready to execute jobs!

---

## Step 2: Setting Up SonarQube Server on AWS

For code quality checks, we’ll deploy a **SonarQube** server using Docker on another AWS EC2 instance.

### Instructions:
1. Launch another **EC2 instance** (Ubuntu preferred) for SonarQube.
2. SSH into the instance and install Docker.
3. Pull the **SonarQube** image from Docker Hub:
   
4. Run the SonarQube container:
   ```bash
   docker run -d -p 9000:9000 sonarqube:lts-community
   ```
5. Access the SonarQube web interface by navigating to `http://<EC2-IP>:9000`.

Now you have your SonarQube server running and ready to perform code quality analysis on your Java application.

---

## Step 3: Writing the GitLab CI Pipeline Script

Next, let’s write the pipeline script to automate the testing, building, code quality analysis, and containerizing of your Java application.

Create a file `.gitlab-ci.yml` in your GitLab project with the following structure:

```yaml
# GitLab CI configuration for a Java project using Maven, SonarQube, and Docker

# Use Maven image with OpenJDK 17
image: maven:3.8.4-openjdk-17

stages:
  - test
  - sonarqube
  - build
  - containerize

# Define global variables for Docker image name and tag
variables:
  IMAGE_NAME: owahed1/demo-app
  IMAGE_TAG: boardgame-0.0.1

# Test Job: Runs unit tests using Maven
test-job:
  stage: test
  script:
    - echo "Running Maven tests..."
    - mvn test
  tags:
    - self-runner

# SonarQube Job: Performs code quality checks using SonarQube
sonarqube-check:
  stage: sonarqube
  image:
    name: sonarsource/sonar-scanner-cli:latest    
  variables:
    SONAR_USER_HOME: "${CI_PROJECT_DIR}/.sonar"  # Defines location for SonarQube cache
    GIT_DEPTH: "0"  # Fetches full project history, required for accurate analysis
  cache:
    key: "${CI_JOB_NAME}"
    paths:
      - .sonar/cache
  script:
    - echo "Running SonarQube analysis..."
    - sonar-scanner
  allow_failure: true  # Allows pipeline to continue even if SonarQube fails
  only:
    - main  # Only run on the main branch

# Build Job: Compiles and packages the Java application using Maven
build-job:
  stage: build
  script:
    - echo "Packaging the application..."
    - mvn package
  artifacts:
    paths:
      - target/*.jar  # Store the packaged JAR file as an artifact
  tags:
    - self-runner

# Containerization Job: Builds Docker image and pushes it to Docker Hub
build_image_push-job:
  image: docker:27.1.1  # Use Docker image
  services:
    - docker:27.1.1-dind  # Docker-in-Docker service to enable Docker commands in the pipeline
  variables:
    DOCKER_TLS_CERTDIR: ""  # Disable Docker TLS for communication within the container
  stage: containerize
  before_script:
    - echo "Logging in to Docker Hub..."
    - docker login -u $DOCKER_USER -p $DOCKER_PASS
  script:
    - echo "Building Docker image..."
    - docker build -t $IMAGE_NAME:$IMAGE_TAG .
    - echo "Pushing Docker image to Docker Hub..."
    - docker push $IMAGE_NAME:$IMAGE_TAG

```
#### Setup the SonarQube Job in Gitlab CI pipeline
- Access the SonarQube web interface by navigating to http://<EC2-IP>:9000
- Log into server
- Choose Devops platform (i.e.- Gitlab)
- Setup configuration
- Create Personal Access Token in Gitlab (Gitlab project > settings > Access Token
- Edit sonar-project.properties in code (copy from the sonar server)
- Add environmental variables in Gitlab (Gitlab project > settings > CICD > Variables > add variable
- Copy the script from SonarQube server and Paste it on GitLab CI Pipeline script
  
### Explanation of the Pipeline:
- **Test Job:** Runs Java tests using Maven on the Project Runner.
- **Code Quality Job:** Performs a SonarQube scan on the Java code.
- **Build Job:** Packages the Java application using Maven.
- **Containerize Job:** Builds a Docker image of the application and pushes it to Docker Hub.

---

## Conclusion

With this setup, you have a robust **GitLab CI pipeline** for a **Java-based application**, integrating **DevSecOps** practices, **SonarQube** for code quality, and **Docker** for containerization. This pipeline provides a complete DevSecOps approach, from testing and building to code quality analysis and Docker image deployment.


---

## Step 4: Running the Pipeline

Once your `.gitlab-ci.yml` file is committed to your GitLab repository, the pipeline will trigger automatically.
