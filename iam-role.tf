# Role creation of jenkins-s3-ssm-access

resource "aws_iam_role" "jenkins_s3_ssm_role" {
  name = var.jenkins_s3_ssm_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# Policy creation of s3-kms-decrypt

resource "aws_iam_policy" "kms_decrypt_policy" {
  name        = var.kms_key_name
  description = "Allow KMS decrypt for a specific key"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid: "AllowKMSDecrypt",
      Effect = "Allow",
      Action = ["kms:Decrypt"],
      Resource = var.kms_key_arn
    }]
  })
}

# Default policy AmazonS3FullAccess attached to Role  jenkins-s3-ssm-access

resource "aws_iam_role_policy_attachment" "attach_s3_full_access" {
  role       = aws_iam_role.jenkins_s3_role.name
  policy_arn = var.AmazonS3FullAccess_arn
}

# Policy s3-kms-decrypt attached to Role  jenkins-s3-ssm-access

resource "aws_iam_role_policy_attachment" "attach_kms_decrypt" {
  role       = aws_iam_role.jenkins_s3_role.name
  policy_arn = aws_iam_policy.kms_decrypt_policy.arn
}

# Default policy AmazonSSMManagedInstanceCore attached to Role  jenkins-s3-ssm-access

resource "aws_iam_role_policy_attachment" "attach_ssm_access" {
  role       = aws_iam_role.jenkins_ssm_role.name
  policy_arn = var.AmazonSSMManagedInstanceCore_arn
}

# Instance profile creation for  jenkins-s3-ssm-access attach to Jenkins EC2

resource "aws_iam_instance_profile" "jenkins_s3_ssm_profile" {
  name = var.jenkins_s3_ssm_role_name
  role = aws_iam_role.jenkins_s3_ssm_role.name
}
