variable "private_key_path" {
  description = "Path to the SSH private key to be used for authentication"
}

variable "public_key_path" {
  description = <<DESCRIPTION
Path to the SSH public key to be used for authentication.
Ensure this keypair is added to your local SSH agent so provisioners can
connect.

Example: ~/.ssh/terraform.pub
DESCRIPTION
}

variable "key_name" {
  description = "Desired name of AWS key pair"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-east-1"
}

# Standard Ubuntu AMIs
variable "aws_amis" {
  default = {
    eu-west-1 = "ami-405f7226"
    eu-west-2 = "ami-ede2e889"
    us-east-1 = "ami-f4cc1de2"
    us-west-1 = "ami-16efb076"
    us-west-2 = "ami-a58d0dc5"
  }
}

variable "instance_type" {
  default = "t2.micro"
}
