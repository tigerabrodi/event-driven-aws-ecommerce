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

    console.log(`Processing ${event.Records.length} records`); // Added log to know the number of records being processed

    for (const record of event.Records) {
      console.log(`Processing record: ${JSON.stringify(record, null, 2)}`); // Added log to understand the shape of each record

      try {
        const order = JSON.parse(record.Sns.Message);
        console.log(`Order received: ${JSON.stringify(order, null, 2)}`); // Added log to understand the shape of the order

        // Simulate inventory update
        console.log(`Updating inventory for order: ${order.transactionId}`);

        const params = {
          Message: `Inventory for order ${order.transactionId} has been updated successfully`,
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
