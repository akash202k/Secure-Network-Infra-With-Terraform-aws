REGION = "ap-southeast-1"
PREFIX = "openvpn"

OPENVPN_VPC_CIDR = "10.0.0.0/16"
OPENVPN_PUBLIC_SUBNET_CIDRS = [
  "10.0.1.0/24",
  "10.0.2.0/24",
  "10.0.3.0/24"
]
OPENVPN_PRIVATE_SUBNET_CIDRS = [
  "10.0.4.0/24",
  "10.0.5.0/24"
]
OPENVPN_AMI           = "ami-075b7d9438177e54d"
OPENVPN_INSTANCE_TYPE = "t2.small"
OPENVPN_KEY           = "openvpn_key"
PUBLIC_KEY_PATH       = "~/.ssh/akash.pub"
VOL_SIZE              = 20
EBS_DEVICE_NAME       = "/dev/sda1"
TOTAL_PUBLIC_SUBNETS  = 3
TOTAL_PRIVATE_SUBNETS = 2
AZ_SUFFIXES           = ["a", "b", "c"]

# Route 53 Record 

ZONE_ID      = "Z07557683VEQHWNO5ZXLF"
SUB_DOMAIN   = "vpn.trames-zeffo.com"
SSL_CERT_ARN = "arn:aws:acm:ap-southeast-1:176862650620:certificate/09287992-9d6a-421b-95b1-d4c8692bbbae"