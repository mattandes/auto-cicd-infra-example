provider "aws" {
  version    = "~> 0.1.4"
  region     = "${var.region}"
  profile    = "${var.aws_profile}"
}

resource "aws_instance" "jenkins" {
  ami           = "${lookup(var.amis, var.region)}"
  instance_type = "t2.micro"
  key_name      = "${var.key_name}"
  tags {
    Name = "Jenkins"
  }
}

resource "aws_eip" "jenkins_ip" {
  instance = "${aws_instance.jenkins.id}"
}
