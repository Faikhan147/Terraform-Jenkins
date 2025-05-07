variable "ami_id" {
  description = "AMI ID for the Jenkins instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "Key pair name"
  type        = string
}

variable "security_group_id" {
  description = "Security Group ID"
  type        = string
}

variable "volume_size" {
  description = "Size of the root EBS volume"
  type        = number
}

variable "volume_type" {
  description = "Type of the root EBS volume"
  type        = string
}
