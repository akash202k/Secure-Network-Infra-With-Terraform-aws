output "VPC_ID" {
  value = aws_vpc.openvpn_vpc.id
}

output "PUBLIC_SUBNET_IDS" {
  value = [for i in range(var.TOTAL_PUBLIC_SUBNETS) : element(aws_subnet.openvpn_public_subnet.*.id, i)]
}

output "PRIVATE_SUBNET_IDS" {
  value = [for i in range(var.TOTAL_PRIVATE_SUBNETS) : element(aws_subnet.openvpn_private_subnet.*.id, i)]
}

output "OPENVPN_SERVER_ID" {
  value = aws_instance.openvpn_server.id
}

output "OPENVPN_SERVER_PUBLIC_IP" {
  value = aws_instance.openvpn_server.public_ip
}

output "OPENVPN_SERVER_SG" {
  value = aws_security_group.openvpn_sg.id
}

output "OPENVPN_KEY" {
  value = var.OPENVPN_KEY
}