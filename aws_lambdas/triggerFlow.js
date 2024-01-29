require("dotenv").config();
const AWS = require("aws-sdk");
AWS.config.update({ region: process.env.AWS_REGION });

const lambda = new AWS.Lambda();

const customerData = {
  transactionId: "b4a356f9-603d-4c66-88f5-b9349dc3c7da",
  customerId: 952,
  customerEmail: "customer952@example.com",
  productId: 14,
  quantity: 5,
  price: 453.0,
  transactionTime: "1995-02-22T19:50:08.805746",
  shippingAddress: "54016 Aguilar Terrace\nBellton, OH 37464",
  paymentMethod: "Debit Card",
};

const params = {
  FunctionName: process.env.LAMBDA_FUNCTION_NAME,
  InvocationType: "RequestResponse",
  Payload: JSON.stringify(customerData),
};

lambda.invoke(params, function (err, data) {
  if (err) {
    console.error(err);
  } else {
    console.log("Lambda function invoked successfully");
    console.log("Response:", data);
  }
});
