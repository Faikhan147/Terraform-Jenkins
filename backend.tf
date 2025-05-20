terraform {
  backend "s3" {
    bucket         = "terraform-backend-faisal-khan"
    key            = "jenkins/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
