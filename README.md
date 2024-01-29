# Event Driven Microservices Orchestrator for Ecommerce orders

I built this project to get my hands familiar with both [SQS](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/welcome.html) and [SNS](https://docs.aws.amazon.com/de_de/mobile/sdkforxamarin/developerguide/sns.html).

# Flow

1. A customer completes an order.
2. `OrderManagementLambda` receives the order details and sends them to `OrderQueueSQS`.
3. `PaymentProcessingLambda` retrieves the order from `OrderQueueSQS` and processes the payment.
4. The result of the payment is published to `PaymentStatusSNS`.
5. `InventoryManagementLambda`, subscribed to `PaymentStatusSNS`, updates the inventory and publishes to `InventoryStatusSNS`.
6. `NotificationServiceLambda`, subscribed to `InventoryStatusSNS`, sends an **email to the customer confirming the order**.

# Visualization

![image](https://github.com/narutosstudent/event-driven-aws-ecommerce/assets/49603590/96c84a34-a5c1-4f9a-aaf1-6f2635442f09)

# AWS SES

I also had to setup AWS SES in order to send emails.

This could also be done via Terraform.

After provisioning the resources, I got a confirmation email.

## AWS SES Sandbox

I was using the Sandbox, so to send emails to anyone I would have to [get out of it](https://docs.aws.amazon.com/ses/latest/dg/request-production-access.html).

I would send emails to my personal email using different variations with the [plus sign](https://support.google.com/a/users/answer/9282734?hl=en#)https://support.google.com/a/users/answer/9282734?hl=en#.
