provider "aws" {
  access_key = "AKIAIFE4TE6YN6PNZJJQ"
  secret_key = "UqG46wpbNg0N0KHf4wuesuTe2Xsz/YpzKoUUN5vM"
  region     = "us-east-1"
}

resource "aws_instance" "example" {
  ami           = "ami-13be557e"
  instance_type = "t2.micro"
}
