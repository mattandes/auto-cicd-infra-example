variable "aws_profile" {}

variable "region" {
  default = "us-east-1"
}

variable "key_name" {}

variable "amis" {
  type = "map"
  default = {
    "us-east-1" = "ami-9887c6e7"
    "us-east-2" = "ami-9c0638f9"
    "us-west-1" = "ami-4826c22b"
    "us-west-2" = "ami-3ecc8f46"
  }
}
