
# DevOps Home Task

This project automates the provisioning of a complete AWS environment using Terraform. The setup includes the creation of a VPC, an EC2 instance running Nginx on port 8080, a Network Load Balancer (NLB), and a Lambda function that manages the NLB's target group based on the state of EC2 instances.

## Prerequisites

Before you begin, ensure you have the following installed and configured:

- **AWS CLI**: [Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
- **Terraform**: [Installation Guide](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- **AWS Account**: You will need access to an AWS account with permissions to create and manage resources.

### AWS CLI Configuration

Ensure that your AWS CLI is configured with the necessary credentials:

```bash
aws configure
```

You'll need to enter:

- **AWS Access Key ID**
- **AWS Secret Access Key**
- **Default region name** (e.g., `us-east-1`)
- **Default output format** (e.g., `json`)

## Project Structure

```
DevOpsHomeTask/
├── README.md
└── aws_vpc_ec2_nginx/
    ├── lambda.tf
    ├── lambda_function.py
    ├── lambda_function.zip
    └── main.tf
```

### Files

- **`main.tf`**: The primary Terraform configuration file that sets up the VPC, Subnet, Security Group, EC2 instance, and NLB.
- **`lambda.tf`**: Contains the configuration for the Lambda function, its IAM role, and the CloudWatch event rule.
- **`lambda_function.py`**: The Python script that the Lambda function runs to manage the NLB target group.
- **`lambda_function.zip`**: The zipped file containing the Python script for the Lambda function.

## Usage

### Step 1: Clone the Repository

Clone the project repository to your local machine:

```bash
git clone git@github.com:Asirush/DevOpsHomeTask.git
cd DevOpsHomeTask/aws_vpc_ec2_nginx
```

### Step 2: Initialize Terraform

Initialize Terraform to download the necessary providers and set up the environment:

```bash
terraform init
```

### Step 3: Apply the Terraform Configuration

Deploy the infrastructure by applying the Terraform configuration:

```bash
terraform apply
```

You will be prompted to confirm the action. Type `yes` and press Enter.

Terraform will now create the VPC, EC2 instance, NLB, and Lambda function as per the configuration.

### Step 4: Verify the Deployment

- **EC2 Instance**: The EC2 instance will be running Nginx on port 8080.
- **Network Load Balancer**: The NLB will be created, though initially without any targets.
- **Lambda Function**: The Lambda function will periodically check the EC2 instances and manage the NLB target group accordingly.

You can access the NLB's DNS name to verify that traffic is being directed to the EC2 instance.

### Step 5: Cleanup

To delete all the resources created by this project, use the `terraform destroy` command:

```bash
terraform destroy
```

Confirm the destruction by typing `yes` when prompted.

## Additional Information

- **AWS Costs**: Ensure that the resources are within the AWS Free Tier limits to avoid incurring charges.
- **Security**: Be cautious with IAM permissions and access keys. Avoid hardcoding sensitive information directly in the Terraform files.
