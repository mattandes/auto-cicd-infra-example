output "jenkins-address" {
  value = "${aws_elb.jenkins.dns_name}"
}

output "nexus-address" {
  value = "${aws_elb.nexus.dns_name}"
}
