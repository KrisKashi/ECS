# Gatus End to end Fargate ECS deployment via terraform & Github actions

This project demonstrates a highly available deployment of the GO application Gatus. The app is containerised using Docker, which is pushed to the AWS ECR registry, to then be ran on ECS fargate with traffic behind a load balancer. Infrastructure is managed by Terraform and the full process is handled via a Github Actions CI/CD pipeline from image build to AWS delivery, It is also hosted on a custom cloudflare domain.

## Tech stack

![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazonaws&logoColor=white)
![Amazon ECS](https://img.shields.io/badge/Amazon_ECS-FF9900?style=for-the-badge&logo=amazonecs&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Go](https://img.shields.io/badge/Go-00ADD8?style=for-the-badge&logo=go&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=for-the-badge&logo=githubactions&logoColor=white)
![Cloudflare](https://img.shields.io/badge/Cloudflare-F38020?style=for-the-badge&logo=cloudflare&logoColor=white)

## What is Gatus and why host it?

Gatus is a service dashboard that can monitor things like DNS-Expiration, Service uptime and latency. I wanted to focus on deploying an application that was useful and devops related in order to fully emulate a production environment. I customised the monitoring dashboard to include the expiry of my domain and uptime of essential services such as GitHub and Cloudflare.

## Architecture diagram


<img src="/assets/ECS_DIAGRAM_centered.png" width="800">

## Live demo 

<video src="https://github.com/user-attachments/assets/a94d88b7-2cb4-43cc-bcb5-bd55182e29d1" controls width="600"></video>


## Github Actions Workflow

 1 - Docker Build and Push -

- Creates the Docker image from the application everytime changes are pushed to the Github repo and pushes it to the ECR repo. Images Tagged with Git commit sha

![Docker pipeline](/assets/DOCKER_BUILD_SUCCESS.png)

2 -  Terraform  Deployment

 Runs on successfulcompletion of the docker build, initialises new terraform changes, checks via terraform validate and tflint and then applies the new changes / image to AWS.

![Terraform Deployment workflow](/assets/TF_DEPLOY_SUCCESS.png)

3 - Health Check

![Health Check](/assets/HEALTH_CHECK.png)

Runs a simple curl operation on the custom domain health endpoint, returns 200 upon success to confirm the service is operational.


## Architectural decisions

- Docker is used to containerise the application via a multi-stage build, which reduces the image size for faster deployment and the container is run os-less in scratch as non-root for a reduced attack surface improving security.

- container Images are tagged with the git commit SHA for easy identification

- The domain itself is hosted on Cloudflare which makes ACM more complex, but provides benefits in the DNS remaining cloud agnostic and able utilise cloudflare features.

- The AWS configuration makes use of two availability zones to make sure the application is always accessible

- Https is enforced; http traffic is routed to port 443

- The application is hosted on ECS Fargate removing the need to manually manage server resources, this was the best option for a singular container deployment, as something like EKS would be overkill. 

- Terraform state is hosted remotely via an S3 backend with state locking in order to avoid state conflict from two or more processes editing the file at the same time and also to provide a secure storage option for the state to work on multiple devices.

- Terraform resources are modularised to make the configuration easily reproducable, organised and conistent. 

- OIDC is used in the CI/CD pipeline, providing short term credentials for the repository to access AWS, with the concept of least privledge being applied, the build and deploy workflows have seperate IAM roles, scoped to their function.  

- Secrets are managed within the Repository, with Github providing write only storage for best security practice.


## Project management 

This project was organised using the Github projects kanban board and centered around 3 main stages:

Stage 1 : Clickops - Deploy the infrastructure manually using the AWS console as proof of concept and to gain a clear understanding of how resources interact

Stage 2 : Tear everything down and use IaC via terraform for enhanced management of the infrastructure.

Stage 3: Automate the whole process via a CI/CD pipeline using Github Actions, making integration of new changes easier and allowing linting and health checks.

## Testing

- The gatus application was edited and pushed to the repo, the pipeline successfully ran and updated the changes on the domain showing proof of the automated deployment function.

- The CI/CD pipelines rely on succession of the previous workflow to ensure consistency with the docker image and deployment.

## Future improvments


- Utilise automatic scaling groups for improved horizontal scaling ability

- Seperate Testing branch to keep commit history clearer on the main.

- Host the container in a private subnet and provide  internet access via a nat gateway for improved security.

- Run a seperate pipeline for bootstrapping ( initial ECR creation) so that the infrastructure completes cleanly first time.

## How to Reproduce the Setup


Requirements:

- An AWS account with appropriate IAM permisisons

- Terraform >= 1.15

- A domain managed on cloudflare (or another provider with adjustments to ACM module)

- Docker


## Steps

1: Clone the repository

git clone https://github.com/KrisKashi/ECS.git


2: Setup remote state

Create an s3 bucket to store the terraform state and update the provider block with your bucket details


3: Configure secrets as a github action secrets/variables

- Cloudflare token

- Cloudflare_zone_id

- Terraform_role & ECR_role with relevant permissions
 (IAM setup)


4. Setup OIDC with github actions via AWS

[https://docs.github.com/en/actions/how-tos/secure-your-work/security-harden-deployments/oidc-in-aws]


5. First deployment


- The first deployment must run the terraform workflow first to intialise the ECR repo, without this the push workflow will not have a repo to push to.

6. Health

Verify the health-check pipeline passes and visit your domain to confirm successful setup!
