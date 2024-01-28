const AWS = require("aws-sdk");
const sqs = new AWS.SQS({ apiVersion: "2012-11-05" });
const sns = new AWS.SNS({ apiVersion: "2010-03-31" });

const SQS_QUEUE_URL = process.env.SQS_QUEUE_URL;
const SNS_TOPIC_ARN = process.env.SNS_TOPIC_ARN;

exports.handler = async () => {
  try {
    // Poll the order_queue
    const data = await sqs
      .receiveMessage({
        QueueUrl: SQS_QUEUE_URL,
        MaxNumberOfMessages: 1,
      })
      .promise();

    if (!data.Messages) {
      console.log("No new orders to process");
      return;
    }

    const order = JSON.parse(data.Messages[0].Body);

    // Simulate payment processing
    console.log(`Processing payment for order: ${order.transactionId}`);
    // Add your payment processing logic here

    // On successful payment, push a message to payment_status_topic
    const params = {
      Message: `Payment for order ${order.transactionId} has been processed successfully`,
      TopicArn: SNS_TOPIC_ARN,
    };

    await sns.publish(params).promise();
    console.log(
      `Payment status for order ${order.transactionId} published to SNS topic`
    );

    // Delete the processed message from the queue
    await sqs
      .deleteMessage({
        QueueUrl: SQS_QUEUE_URL,
        ReceiptHandle: data.Messages[0].ReceiptHandle,
      })
      .promise();

    console.log(`Order ${order.transactionId} removed from the queue`);
  } catch (error) {
    console.error(`Error processing payment: ${error}`);
  }
};
