# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
}

# Create a VPC to launch our instances into
resource "aws_vpc" "tryout" {
  cidr_block = "10.0.0.0/16"
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "tryout" {
  vpc_id = "${aws_vpc.tryout.id}"
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.tryout.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.tryout.id}"
}

# Create a subnet to launch our instances into
resource "aws_subnet" "tryout" {
  vpc_id                  = "${aws_vpc.tryout.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

# A security group for the ELB so it is accessible via the web
resource "aws_security_group" "elb" {
  name        = "terraform_example_elb"
  description = "Used in the terraform"
  vpc_id      = "${aws_vpc.tryout.id}"

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "tryout" {
  name        = "terraform_example"
  description = "Used in the terraform"
  vpc_id      = "${aws_vpc.tryout.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "elb" {
  name = "terraform-example-elb"

  subnets         = ["${aws_subnet.tryout.id}"]
  security_groups = ["${aws_security_group.elb.id}"]
  instances       = ["${aws_instance.cluster.*.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}

resource "aws_key_pair" "auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_instance" "cluster" {

  count = 1

  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    # The default username for our AMI
    user = "ubuntu"
    type = "ssh"
    private_key = "${file(var.private_key_path)}"

    # The connection will use the local SSH agent for authentication.
  }

  instance_type = "${var.instance_type}"

  # Lookup the correct AMI based on the region
  # we specified
  ami = "${lookup(var.aws_amis, var.aws_region)}"

  # The name of our SSH keypair we created above.
  key_name = "${aws_key_pair.auth.id}"

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${aws_security_group.tryout.id}"]

  # We're going to launch into the same subnet as our ELB. In a production
  # environment it's more common to have a separate private subnet for
  # backend instances.
  subnet_id = "${aws_subnet.tryout.id}"

  # Upload the webpage I want to display
  provisioner "file" {
     source = "index.html"
     destination = "/home/ubuntu/index.html"
  }
  provisioner "file" {
     source = "whereami.sh"
     destination = "/home/ubuntu/whereami.sh"
  }

  # Install nginx webserver and launch
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "sudo apt-get -y install nginx",
      "sudo apt-get -y install php",
      "sudo service nginx start",
      "sudo rm /var/www/html/index.nginx-debian.html",
      "sudo cp /home/ubuntu/index.html /home/ubuntu/whereami.sh /var/www/html/"
    ]
  }
}

