# Existing Jenkins IAM Role ke liye Instance Profile
resource "aws_iam_instance_profile" "this" {
  name = var.instance_profile_name      # Instance Profile ka name jo EC2 attach hoga
  role = var.jenkins_role_name             # Existing Role ka name
}

# Jenkins Launch Template
resource "aws_launch_template" "this" {
  name_prefix   = var.template_name
  image_id      = var.ami_id
  instance_type = var.instance_type


  iam_instance_profile {
    name = var.instance_profile_name
  }

  network_interfaces {
    subnet_id                   = var.subnet_id
    associate_public_ip_address  = true
    security_groups             = [var.security_group_id]
  }

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size           = var.root_volume_size
      volume_type           = var.root_volume_type
      delete_on_termination = true   # ✅ recommended
      iops                  = var.root_volume_iops
      throughput            = var.root_volume_throughput
      kms_key_id            = var.kms_key_arn   # <- yahan attach karo apni existing KMS key
      encrypted             = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = var.instance_name
    }
  }
}

# EC2 Instance using Jenkins Launch Template
resource "aws_instance" "this" {
  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  user_data = file("${path.module}/${var.user_data_path}") 

  tags = {
    Name = var.instance_name
  }
}
