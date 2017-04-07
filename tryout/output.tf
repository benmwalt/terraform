output "address" {
  value = "${aws_elb.elb.dns_name}"
}

output "private_ip" {
  value = ["${aws_instance.cluster.*.private_ip}"]
}

output "public_ip" {
  value = ["${aws_instance.cluster.*.public_ip}"]
}
