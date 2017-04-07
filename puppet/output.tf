output "address" {
  value = "${aws_elb.elb.dns_name}"
}

output "private_ip" {
  value = ["${aws_instance.server.*.private_ip}"]
}

output "public_ip" {
  value = ["${aws_instance.server.*.public_ip}"]
}
