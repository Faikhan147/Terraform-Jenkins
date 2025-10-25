terraform {
  backend "s3" {
    bucket         = "terraform-backend-all-envs"
    key            = "jenkins/terraform.tfstate"
    region         = "ap-southeast-1"
    encrypt        = true
    dynamodb_table = "terraform-locks-jenkins"
  }
}
