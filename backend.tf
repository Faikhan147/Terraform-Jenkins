terraform {
  backend "s3" {
    bucket         = "terraform-backend-faisal-khan"
    key            = "jenkins/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
