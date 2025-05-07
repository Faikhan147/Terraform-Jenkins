output "jenkins_public_ip" {
  description = "Public IP of the Jenkins EC2 instance"
  value       = aws_instance.jenkins.public_ip
}

output "jenkins_instance_id" {
  description = "Instance ID of the Jenkins EC2"
  value       = aws_instance.jenkins.id
}

output "jenkins_password_s3" {
  description = "Jenkins password stored in S3"
  value       = "s3://terraform-backend-faisal-khan/jenkins_password.txt"
  sensitive   = true
}
