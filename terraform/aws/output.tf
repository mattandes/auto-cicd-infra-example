output "jenkins-address" {
  value = "${aws_elb.jenkins.dns_name}"
}
