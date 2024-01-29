const AWS = require("aws-sdk");
const sns = new AWS.SNS({ apiVersion: "2010-03-31" });

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
        Message: JSON.stringify(order),
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
