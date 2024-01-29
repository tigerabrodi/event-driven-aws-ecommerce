const AWS = require("aws-sdk");
const ses = new AWS.SES({ apiVersion: "2010-12-01" });

const SENDER_EMAIL = process.env.SENDER_EMAIL;

exports.handler = async (event) => {
  try {
    if (!event.Records) {
      console.log("No new inventory updates to process");
      return;
    }

    for (const record of event.Records) {
      try {
        const order = JSON.parse(record.Sns.Message);
        console.log(`Received order: ${JSON.stringify(order)}`);

        if (!order.customerEmail) {
          console.error("Customer email is null or undefined");
          return;
        }

        const params = {
          Source: SENDER_EMAIL,
          Destination: {
            ToAddresses: [order.customerEmail], // Use customerEmail from order data
          },
          Message: {
            Subject: {
              Data: "Inventory Update",
            },
            Body: {
              Text: {
                Data: `Dear Customer, your order with transaction ID: ${order.transactionId} has been received and processed. Thank you for shopping with us.`,
              },
            },
          },
        };

        const data = await ses.sendEmail(params).promise();
        console.log(`Email sent: ${data.MessageId}`);
      } catch (error) {
        console.error(`Error sending email: ${error}`);
      }
    }
  } catch (error) {
    console.error(`Error processing event: ${error}`);
  }
};
