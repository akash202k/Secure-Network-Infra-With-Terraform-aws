terraform {
  backend "s3" {
    bucket = "tf-vpn-zeffo"
    key    = "openvpn-server"
    region = "ap-southeast-1"
  }
}
