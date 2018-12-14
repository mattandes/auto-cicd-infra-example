output "jenkins-address" {
  value = "${aws_elb.jenkins.dns_name}"
}

output "artifactory-address" {
  value = "${aws_elb.artifactory.dns_name}"
}
