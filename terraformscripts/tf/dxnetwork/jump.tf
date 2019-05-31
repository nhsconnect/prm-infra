data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.????????-x86_64-gp2"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

data "external" "whatismyip" {
 program = ["${path.module}/whatsmyip.sh"]
}

resource "aws_instance" "jump" {
  count = "${var.provision_jump}"

  ami           = "${data.aws_ami.amazon-linux-2.id}"
  instance_type = "t3.micro"
  subnet_id     = "${element(aws_subnet.public.*.id, 0)}"
  key_name      = "${aws_key_pair.jump.key_name}"

  tags = {
    Name = "Jump box for DX VPC"
  }

  vpc_security_group_ids = ["${aws_security_group.jump.id}"]
}

resource "aws_security_group" "jump" {
  name        = "${module.jump_label.id}"
  description = "${module.jump_label.id} security group"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = ["${data.external.whatismyip.result["internet_ip"]}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${module.jump_label.tags}"
}

data "aws_ssm_parameter" "jump" {
  name = "/NHS/${var.stage}-${data.aws_caller_identity.current.account_id}/tf/opentest/ec2_keypair"
}

resource "aws_key_pair" "jump" {
  public_key = "${data.aws_ssm_parameter.jump.value}"
  key_name   = "jump"
}
