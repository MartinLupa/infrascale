# InfraScale

This project deploys a scalable web application infrastructure on AWS using Terraform. It includes key AWS services and uses [LocalStack](https://localstack.cloud/) for local testing to avoid AWS costs during development. A GitHub Actions pipeline automates deployment to **dev**, **staging**, and **prod** environments.

## Project Overview
The project sets up:
- **VPC**: Custom network with public and private subnets.
- **EC2 Instances**: Run NGINX web servers (using Docker NGINX image).
- **Application Load Balancer (ALB)**: Distributes traffic to EC2 instances.
- **Auto Scaling Group**: Scales EC2 instances based on CPU utilization.
- **SQS**: Queues messages for asynchronous processing.
- **Lambda**: Processes SQS messages, e.g., writing to DynamoDB.
- **DynamoDB**: Stores data processed by Lambda.
- **SNS**: Sends notifications for scaling events or errors.
- **IAM Roles/Policies**: Secures service access.

## AWS Services Covered
This project covers DVA-C02 exam topics, including:
- EC2, ALB, Auto Scaling
- SQS, Lambda, DynamoDB, SNS
- IAM, VPC
- Infrastructure as Code with Terraform
- CI/CD with GitHub Actions

## Prerequisites
- **Terraform** (>= 1.5.0)
- **AWS CLI** (>= 2.0)
- **LocalStack** (for local testing)
- **awslocal** (Wrapper around AWS CLI for local testing with LocalStack)
- **Docker** (for LocalStack and NGINX)
- **Node.js** (for Lambda function packaging)
- **GitHub Account** (for CI/CD pipeline)
- **AWS Account** (for staging/prod deployment)

## Setup Instructions

### 1. Install Dependencies

### 2. Clone the Repository
```bash
git clone https://github.com/MartinLupa/infrascale.git
cd infrascale
```

### 3. Project Structure
```
infrascale/
├── terraform/
│   ├── main.tf           # Core infrastructure
│   ├── variables.tf      # Environment variables
│   ├── outputs.tf        # Output values
│   ├── dev.tfvars        # Dev environment config
│   ├── staging.tfvars    # Staging environment config
│   ├── prod.tfvars       # Prod environment config
├── lambda/
│   ├── index.js          # Lambda function code
├── .github/
│   ├── workflows/
│   │   ├── deploy.yml    # GitHub Actions pipeline
├── README.md
```

### 4. Configure LocalStack
Ensure LocalStack is running:
```bash
localstack status
```
Set environment variables for Terraform to use LocalStack:
```bash
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1
export TF_VAR_localstack_enabled=true
```

### 5. Initialize Terraform
```bash
cd terraform
terraform init
```

### 6. Deploy Locally with LocalStack
```bash
terraform apply -var-file=dev.tfvars
```
Access the NGINX web server at `http://localhost:4566` (LocalStack endpoint).

### 7. Deploy to AWS
Update `dev.tfvars`, `staging.tfvars`, or `prod.tfvars` with your AWS account details. Disable LocalStack:
```bash
export TF_VAR_localstack_enabled=false
```
Apply for a specific environment:
```bash
terraform apply -var-file=staging.tfvars
```

### 8. GitHub Actions Pipeline
The pipeline (`deploy.yml`) automates deployment to dev, staging, and prod based on branch pushes:
- **dev**: `dev` branch
- **staging**: `staging` branch
- **prod**: `main` branch

**Setup**:
1. Add AWS credentials to GitHub Secrets:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
2. Push changes to trigger the pipeline:
   ```bash
   git push origin dev
   ```

**Pipeline Snippet**:
```yaml
name: Deploy Infrastructure
on:
  push:
    branches:
      - dev
      - staging
      - main
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: hashicorp/setup-terraform@v2
      - run: terraform init
      - run: terraform apply -var-file=${{ github.ref_name }}.tfvars -auto-approve
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

### 9. Testing
- **LocalStack**: Check NGINX at `http://localhost:4566`.
- **AWS**: Get ALB DNS from Terraform outputs:
  ```bash
  terraform output alb_dns_name
  ```
- **SQS/Lambda**: Send a message to SQS and verify Lambda updates DynamoDB.

### 10. Cleanup
Destroy resources to avoid AWS charges:
```bash
terraform destroy -var-file=dev.tfvars
```

## Example Terraform Code
**main.tf** (simplified):
```hcl
provider "aws" {
  region = var.region
  endpoints {
    ec2 = var.localstack_enabled ? "http://localhost:4566" : null
  }
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_instance" "web" {
  ami           = "ami-12345678" # Update with valid AMI
  instance_type = "t2.micro"
  user_data     = <<-EOF
                  #!/bin/bash
                  docker run -d -p 80:80 nginx
                  EOF
}
```

## Notes
- Replace placeholder AMIs and configurations in `.tfvars` files.
- Ensure LocalStack is running for local testing.
- Monitor AWS costs for staging/prod environments.
- Refer to [DVA-C02 Exam Guide](https://d1.awsstatic.com/training-and-certification/docs-dev-associate/AWS-Certified-Developer-Associate_Exam-Guide.pdf) for additional topics.

For issues, open a GitHub issue or check [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs).