terraform {
  backend "s3" {
    bucket         = "terraform-backend-all-environments"
    key            = "jenkins/terraform.tfstate"
    region         = "ap-southeast-2"
    encrypt        = true
    dynamodb_table = "terraform-locks-jenkins"
  }
}
