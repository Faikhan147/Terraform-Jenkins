resource "aws_instance" "jenkins" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [var.security_group_id]

  root_block_device {
    volume_size = var.volume_size
    volume_type = var.volume_type
  }

  user_data = file("${path.module}/setup_jenkins.sh")

 provisioner "remote-exec" {
    inline = [
      "sleep 60",  # Wait for Jenkins to initialize
      "sudo cat /var/lib/jenkins/secrets/initialAdminPassword > /tmp/jenkins_password.txt"
    ]
  }

  tags = {
    Name = "Jenkins-Machine"
  }
}
