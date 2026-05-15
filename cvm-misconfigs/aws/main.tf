resource "aws_security_group" "cvm-test" {
  name        = "cvm-test-sg"
  description = "Allow SSH inbound and all outbound"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

data "aws_ami" "selected" {
  owners = ["self", "amazon", "099720109477", "aws-marketplace"]

  filter {
    name   = "image-id"
    values = [var.ami]
  }
}

resource "aws_instance" "cvm-test" {
  ami                    = data.aws_ami.selected.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.cvm-test.id]

  cpu_options {
    amd_sev_snp = var.amd_sev_snp
  }

  associate_public_ip_address = true

  tags = var.tags

  lifecycle {
    precondition {
      condition     = data.aws_ami.selected.tpm_support == "v2.0"
      error_message = "AMI must have NitroTPM v2.0 support enabled."
    }
    # precondition {
    #   condition     = data.aws_ami.selected.boot_mode == "uefi" && data.aws_ami.selected.uefi_data != null && data.aws_ami.selected.uefi_data != ""
    #   error_message = "AMI must use UEFI boot mode with Secure Boot keys configured (uefi_data)."
    # }
  }
}
