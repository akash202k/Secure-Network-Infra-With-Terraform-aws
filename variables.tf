variable "REGION" { type = string }
variable "PREFIX" { type = string }

variable "OPENVPN_VPC_CIDR" { type = string }
variable "OPENVPN_PUBLIC_SUBNET_CIDRS" { type = list(string) }
variable "OPENVPN_PRIVATE_SUBNET_CIDRS" { type = list(string) }

variable "OPENVPN_AMI" { type = string }
variable "OPENVPN_INSTANCE_TYPE" { type = string }
variable "OPENVPN_KEY" { type = string }
variable "PUBLIC_KEY_PATH" { type = string }
variable "VOL_SIZE" { type = number }
variable "EBS_DEVICE_NAME" { type = string }
variable "TOTAL_PUBLIC_SUBNETS" { type = number }
variable "TOTAL_PRIVATE_SUBNETS" { type = number }
# variable "AVAILABILITY_ZONES" { type = list(string) }
# variable "AZ_SUFFIXES" {
#   type    = list(string)
#   default = ["a", "b", "c"]
# }


locals {
  AZ_SUFFIXES        = ["a", "b", "c"]
  AVAILABILITY_ZONES = [for suffix in local.AZ_SUFFIXES : "${var.REGION}${suffix}"]
}

# Route53 records

variable "SUB_DOMAIN" { type = string }
variable "ZONE_ID" { type = string }
variable "SSL_CERT_ARN" { type = string }