variable "region" {
  description = "AMI ID for the Jenkins instance"
  type        = string
}


variable "instance_profile_name" {
  description = "Name of the IAM Instance Profile to attach to the EC2 instance"
  type        = string
}

variable "jenkins_role_name" {
  description = "Name of the existing Jenkins IAM Role"
  type        = string
}

variable "template_name" {
  description = "Name prefix for the Jenkins Launch Template"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the Jenkins EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for Jenkins server"
  type        = string
}

variable "security_group_id" {
  description = "VPC Security Group ID to attach to the EC2 instance"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where the EC2 instance will be launched"
  type        = string
}

variable "volume_size" {
  description = "Root EBS volume size in GB"
  type        = number
}

variable "volume_type" {
  description = "Root EBS volume type (e.g., gp3, gp2, io1)"
  type        = string
}

variable "volume_type" {
  description = "Root EBS volume type (e.g., gp3, gp2, io1)"
  type        = string
}

variable "kms_key_arn" {
  description = "Name tag for the EC2 instance"
  type        = string
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
}
