const AWS = require("aws-sdk");
const sqs = new AWS.SQS({ apiVersion: "2012-11-05" });
const sns = new AWS.SNS({ apiVersion: "2010-03-31" });

const SQS_QUEUE_URL = process.env.SQS_QUEUE_URL;
const SNS_TOPIC_ARN = process.env.SNS_TOPIC_ARN;

exports.handler = async (event) => {
  try {
    if (!event.Records) {
      console.log("No new orders to process");
      return;
    }

    for (const record of event.Records) {
      const order = JSON.parse(record.body);

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

      console.log(`Order ${order.transactionId} processed successfully`);
    }
  } catch (error) {
    console.error(`Error processing payment: ${error}`);
  }
};
