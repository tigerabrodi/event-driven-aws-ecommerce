const AWS = require("aws-sdk");
const sqs = new AWS.SQS({ apiVersion: "2012-11-05" });
const SQS_QUEUE_URL = process.env.SQS_QUEUE_URL;

exports.handler = async (event) => {
  try {
    console.log("Received event:", JSON.stringify(event, null, 2));

    // Validate the incoming order data
    if (!event.transactionId || !event.customerId) {
      console.error("Invalid order data");
      return { statusCode: 400, body: "Invalid order data" };
    }

    const params = {
      MessageBody: JSON.stringify(event),
      QueueUrl: SQS_QUEUE_URL,
    };

    // Send the message to SQS
    await sqs.sendMessage(params).promise();
    console.log(`Order message sent to SQS: ${event.transactionId}`);

    return { statusCode: 200, body: "Order processed successfully" };
  } catch (error) {
    console.error(`Error processing order: ${error}`);
    return { statusCode: 500, body: "Error processing order" };
  }
};
