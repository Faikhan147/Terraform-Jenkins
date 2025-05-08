resource "aws_instance" "jenkins" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name  # SSM profile linked

  root_block_device {
    volume_size = var.volume_size
    volume_type = var.volume_type
  }

  tags = {
    Name = "Jenkins-Machine"
  }

 # User Data Script to install SSM agent only
  user_data = <<-EOF
              #!/bin/bash
              # Install SSM agent (if not already installed)
              if ! command -v amazon-ssm-agent &> /dev/null
              then
                echo "SSM agent not found, installing..."
                sudo snap install amazon-ssm-agent --classic
                sudo systemctl start amazon-ssm-agent
                sudo systemctl enable amazon-ssm-agent
              fi
              EOF

  # Copy setup script
  provisioner "file" {
    source      = "${path.module}/setup_jenkins.sh"
    destination = "/tmp/setup_jenkins.sh"
  }

connection {
      type = "ssm"
    }
  }

  # Copy Slack config
  provisioner "file" {
    source      = "${path.module}/jenkins-casc/slack-credentials.yaml"
    destination = "/tmp/slack-credentials.yaml"
  }

connection {
      type = "ssm"
    }
  }

  # Run setup script
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup_jenkins.sh",
      "bash /tmp/setup_jenkins.sh"
    ]
  }
}

connection {
      type = "ssm"
    }
  }

# IAM Role for EC2 (Allowing SSM access)
resource "aws_iam_role" "ssm_role" {
  name = "jenkins_ssm_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# Attach AmazonSSMManagedInstanceCore policy
resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create IAM Instance Profile
resource "aws_iam_instance_profile" "ssm_profile" {
  name = "jenkins_ssm_profile"
  role = aws_iam_role.ssm_role.name
}
