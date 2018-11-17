provider "aws" {
  version    = "~> 0.1.4"
  region     = "${var.region}"
  profile    = "${var.aws_profile}"
}

# Create a VPC to launch our instances into
resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

# Create a subnet to launch our ELB on to
resource "aws_subnet" "elb" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

# Create a subnet to launch our instances into
resource "aws_subnet" "default" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
}

# Our default security group to access the instances over SSH
resource "aws_security_group" "default" {
  name        = "default-sg"
  description = "Default SG that allows SSH"
  vpc_id      = "${aws_vpc.default.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
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

# Our security group to access the Jenkins master
resource "aws_security_group" "jenkins" {
  name        = "jenkins-sg"
  description = "Jenkins SG that allows SSH and HTTP"
  vpc_id      = "${aws_vpc.default.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from anywhere
  ingress {
    from_port   = 8080
    to_port     = 8080
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

# Our security group to access the ELB
resource "aws_security_group" "elb" {
  name        = "elg-sg"
  description = "ELB SG that allows SSH and HTTP"
  vpc_id      = "${aws_vpc.default.id}"

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

resource "aws_elb" "jenkins" {
  name = "jenkins-elb"

  subnets         = ["${aws_subnet.elb.id}","${aws_subnet.default.id}"]
  security_groups = ["${aws_security_group.elb.id}"]
  instances       = ["${aws_instance.jenkins.id}"]

  listener {
    instance_port     = 8080
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}

resource "aws_key_pair" "insecure_key" {
  key_name   = "${var.key_name}"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key"
}

resource "aws_instance" "jenkins" {
  ami           = "${lookup(var.amis, var.region)}"
  instance_type = "t2.micro"
  key_name      = "${aws_key_pair.insecure_key.id}"
  tags {
    Name = "jenkins"
    Role = "master"
  }
  vpc_security_group_ids = ["${aws_security_group.jenkins.id}"]
  subnet_id = "${aws_subnet.default.id}"
  root_block_device = {
    delete_on_termination = true
  }
}

resource "aws_instance" "slave_01" {
  ami           = "${lookup(var.amis, var.region)}"
  instance_type = "t2.micro"
  key_name      = "${aws_key_pair.insecure_key.id}"
  tags {
    Name = "jenkins-slave_01"
    Role = "slave"
  }
  vpc_security_group_ids = ["${aws_security_group.default.id}"]
  subnet_id = "${aws_subnet.default.id}"
  root_block_device = {
    delete_on_termination = true
  }  
}

resource "aws_instance" "slave_02" {
  ami           = "${lookup(var.amis, var.region)}"
  instance_type = "t2.micro"
  key_name      = "${aws_key_pair.insecure_key.id}"
  tags {
    Name = "jenkins-slave_02"
    Role = "slave"
  }
  vpc_security_group_ids = ["${aws_security_group.default.id}"]
  subnet_id = "${aws_subnet.default.id}"
  root_block_device = {
    delete_on_termination = true
  }  
}

resource "null_resource" "jenkins_cluster" {
  triggers {
    cluster_instance_ids = "${aws_instance.jenkins.id},${aws_instance.slave_01.id},${aws_instance.slave_02.id}"
  }
  provisioner "local-exec" {
    working_dir = "../../ansible"
    command = "ansible-playbook -i inventories/aws -u centos playbooks/site.yml"
  }
}