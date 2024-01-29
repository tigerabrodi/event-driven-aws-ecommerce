const AWS = require("aws-sdk");
const sns = new AWS.SNS({ apiVersion: "2010-03-31" });

const SNS_INVENTORY_TOPIC_ARN = process.env.SNS_INVENTORY_TOPIC_ARN;

exports.handler = async (event) => {
  console.log(`Received event: ${JSON.stringify(event, null, 2)}`); // Added log to understand the shape of event

  try {
    if (!event.Records || event.Records.length === 0) {
      console.log("No new inventory updates to process");
      return;
    }

    for (const record of event.Records) {
      try {
        const order = JSON.parse(record.Sns.Message);

        // Simulate inventory update
        console.log(`Updating inventory for order: ${order.transactionId}`);

        const params = {
          Message: JSON.stringify(order),
          TopicArn: SNS_INVENTORY_TOPIC_ARN,
        };

        await sns.publish(params).promise();
        console.log(
          `Inventory update for order ${order.transactionId} published to SNS topic`
        );
      } catch (error) {
        console.error(`Error parsing message: ${record.Sns.Message}`);
        console.error(`Error: ${error}`);
      }
    }
  } catch (error) {
    console.error(`Error updating inventory: ${error}`);
  }
};
