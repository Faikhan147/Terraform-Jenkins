output "jenkins_public_ip" {
  description = "Public IP of the Jenkins EC2 instance"
  value       = aws_instance.jenkins.public_ip
}

output "jenkins_instance_id" {
  description = "Instance ID of the Jenkins EC2"
  value       = aws_instance.jenkins.id
}
