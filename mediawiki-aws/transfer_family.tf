resource "aws_transfer_server" "transfer_family" {
  endpoint_type = "VPC"

  endpoint_details {
    subnet_ids = aws_subnet.private[*].id
    vpc_id     = aws_vpc.main.id
  }
  protocols = ["SFTP"]
}
