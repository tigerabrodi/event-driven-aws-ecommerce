resource "aws_sns_topic" "payment_status_topic" {
  name         = "payment_status_topic"
  display_name = "Payment Status Topic"
}

resource "aws_sns_topic" "inventory_status_topic" {
  name         = "inventory_status_topic"
  display_name = "Inventory Status Topic"
}
