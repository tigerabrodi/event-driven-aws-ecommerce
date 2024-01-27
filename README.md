# Event Driven Microservices Orchestrator for Ecommerce

### Step 1: Initialize Terraform and Configure AWS Provider

- **Create Terraform Configuration File**:

  - Create a file named `provider.tf`.
  - Add AWS provider details, specifying the region and optionally, the profile if using AWS CLI profiles.
  - Include Terraform backend configuration for state management, especially if using Terraform Cloud.

- **Initialize Terraform Project**:

  - Open a terminal, navigate to the project directory.
  - Run `terraform init` to initialize the project, which will download necessary plugins and set up the backend.

- **Verify Initialization**:
  - Check for a message in the terminal confirming successful initialization.
  - Ensure `.terraform` directory and `terraform.tfstate` files are created in your project folder.

### Step 2: Provision an SQS Queue for Order Management

- **Write SQS Terraform Configuration**:

  - In `main.tf`, define an SQS queue resource with appropriate attributes like name (`order_queue`), visibility timeout, and message retention period.
  - Include any dead-letter queue configurations if necessary for handling failed message processing.

- **Apply Configuration to Create Queue**:

  - Run `terraform apply` and confirm the action in the prompt to create the queue.
  - Terraform will provide an execution plan before applying changes; review it to ensure correctness.

- **Validate Queue Creation in AWS Console**:
  - Log into the AWS Console.
  - Navigate to the SQS service and verify the `order_queue` is listed with the correct configurations.

### Step 3: Provision SNS Topics for Payment and Inventory Updates

- **Define SNS Topics in Terraform**:

  - Add resources in `main.tf` for two SNS topics: `payment_status_topic` and `inventory_status_topic`, setting attributes like `display_name`.
  - Configure topic policies if necessary, for security and access control.

- **Execute Terraform Apply for SNS Topics**:

  - Run `terraform apply` again to create the SNS topics.
  - Review the execution plan to ensure the correct creation of SNS topics.

- **Check SNS Topics in AWS Console**:
  - After Terraform execution, log in to the AWS Console.
  - Navigate to the SNS dashboard and ensure both `payment_status_topic` and `inventory_status_topic` are present.

### Step 4: Develop Order Management Lambda Function

- **Write Lambda Function Code**:

  - Develop the Node.js code for the Lambda function. This function should handle HTTP requests, validate order data, and then enqueue messages to the SQS queue.
  - Test the function locally using a tool like AWS SAM or mock AWS services.

- **Add Lambda Function to Terraform**:

  - Define the AWS Lambda resource in your `main.tf`, linking to your Node.js code.
  - Include necessary IAM roles and policies for the Lambda to interact with SQS.

- **Deploy Lambda and Verify**:
  - Deploy the function with `terraform apply`.
  - In the AWS Console, under Lambda, check for your function and test it with a test event to ensure it interacts with SQS correctly.

### Step 5: Implement Payment Processing Lambda Function

- **Lambda Function for Payment Processing**:

  - Code the Node.js Lambda function to poll `order_queue`, simulate payment processing, and on successful payment, push a message to `payment_status_topic`.
  - Include error handling for failed payments or issues during processing.

- **Terraform Script for Payment Lambda**:

  - Add the new Lambda function to your Terraform script (`main.tf`). Ensure it has the necessary permissions to interact with both SQS and SNS.
  - Define an IAM role and policy for the Lambda function, specifying actions like `sqs:ReceiveMessage`, `sqs:DeleteMessage`, and `sns:Publish`.

- **Deploy and Test Payment Lambda**:
  - Use `terraform apply` to deploy the function.
  - Test by manually sending a message to `order_queue` and verify that the Lambda function processes it and sends an update to the SNS topic.

### Step 6: Set Up Inventory Management Lambda Function

- **Develop Inventory Lambda Code**:

  - Write Node.js code for the Lambda function that triggers on messages from `payment_status_topic`. This function should update inventory based on the order details.
  - Implement logic to publish a message to `inventory_status_topic` after a successful inventory update.

- **Terraform Configuration for Inventory Lambda**:

  - Define the Lambda function in Terraform, including IAM roles and policies for SNS subscribe and publish permissions.
  - Link the Lambda function to `payment_status_topic` using the `aws_sns_topic_subscription` resource.

- **Deployment and Verification**:
  - Deploy using `terraform apply`.
  - Trigger a test event from `payment_status_topic` and verify the function executes and sends a message to

`inventory_status_topic`.

### Step 7: Create Notification Service Lambda Function with SES

- **Code for Email Notifications**:

  - Write a Node.js Lambda function to send email notifications using SES. This function should be triggered by messages from `inventory_status_topic`.
  - Include logic to construct the email content based on the inventory update information.

- **Terraform Script for Notification Lambda**:

  - Add the Lambda function to your Terraform configuration, ensuring it has permissions for SES (`ses:SendEmail`).
  - Include an SES verified email resource if not already verified.

- **Deploy and Test Email Functionality**:
  - Deploy the function with Terraform.
  - Publish a message to `inventory_status_topic` to test the email functionality. Check your email inbox for the notification.

### Step 8: Test Order Placement with Node.js Script

- **Create Order Placement Script**:

  - Write a Node.js script that simulates placing an order. This script should construct a mock order payload.
  - Ensure the script uses AWS SDK to invoke the Order Management Lambda function, passing the mock order as input.

- **Script Execution and Monitoring**:

  - Run the script in your local environment.
  - Monitor the SQS queue (`order_queue`) to verify that the mock order is enqueued properly.

- **Validate Order Management Processing**:
  - Check AWS CloudWatch logs for the Order Management Lambda to confirm it's triggered and processes the order correctly.
  - Ensure no errors are logged and the expected behavior (order pushed to SQS) occurs.

### Step 9: Conduct End-to-End Workflow Testing

- **Simulate Full Order Processing Workflow**:

  - Use the Node.js script to place an order, triggering the entire workflow.
  - Monitor each step: order management, payment processing, inventory management, and notification service.

- **Check Each Lambda Function and AWS Service**:

  - Verify that each Lambda function is triggered in sequence and performs its expected action.
  - Confirm that messages flow correctly between SQS and SNS, and that SES sends the final email.

- **End-to-End Verification**:
  - The final verification is receiving the order confirmation email.
  - Review logs in AWS CloudWatch for each Lambda function to ensure there are no unseen errors and that the flow completes successfully.

### Step 10: Document the Architecture and Process

- **Detailed Documentation of Each Component**:

  - Document the purpose, functionality, and setup of each microservice (Lambda function).
  - Include descriptions of how each service interacts with SQS and SNS.

- **Terraform Scripts and AWS Configuration**:

  - Provide detailed explanations of your Terraform configuration, including how it sets up Lambda, SQS, SNS, and SES.
  - Explain any IAM roles and policies used in the project.

- **Instructions for Setup and Deployment**:
  - Offer clear, step-by-step instructions for initializing and deploying the system using Terraform.
  - Include guidance for running the Node.js script and testing the system.
