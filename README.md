# 🤖 DalFitBot
DalFitBot is a cloud-native chatbot application designed to provide intelligent, real-time answers to user queries about a facility using internal business data. Leveraging Retrieval-Augmented Generation (RAG) and powered by the LLaMA language model, DalFitBot delivers context-aware, accurate responses by retrieving relevant data chunks and combining them with generative AI capabilities.

## 🔧 Key Features
- RAG Architecture: Combines document retrieval with generation for precise, grounded answers.

- LLaMA-Based NLP: Utilizes Meta's LLaMA model for high-performance, contextual language understanding.

- FastAPI Backend: Built with Python and FastAPI for efficient, scalable, and asynchronous API operations.

- Cloud-Native Design: Fully deployed on AWS with high availability and security in mind.

## ☁️ AWS Cloud Infrastructure
- AWS Cognito – User authentication and secure access control.
- API Gateway – Handles RESTful API requests and routes traffic to backend services.
- Network Load Balancer (NLB) – Distributes traffic across EC2 instances with high throughput.
- EC2 Instances – Host the FastAPI application and inference service.
- NAT Gateway – Enables outbound internet access from private subnets.

## 📦 Tech Stack
- Language: Python
- Framework: FastAPI
- Model: LLaMA (integrated with a RAG pipeline)
- Deployment: AWS (Cognito, API Gateway, NLB, EC2, NAT)

## Cloud Deployment

Prerequsites: [AWS Account](https://aws.amazon.com/), [Terraform](https://developer.hashicorp.com/terraform)

1) Set the aws credentials as the default credentials using `aws configure`. Refer [AWS Docs](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-quickstart.html) if you need help.
2) Go to the root directory where the `main.tf` file is present and run the below command in sequence. 
```
terraform init           # To initialize the project.
terraform validate       # To validate the terraform script and AWS Configuration.
terraform plan           # Displays the resources to be created.
terraform apply          # Start creating the resource in the cloud. 
```

The React Endpoint will be displayed through which the application can be accessed. 
