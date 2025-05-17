resource "aws_iam_role" "jenkins_role" {
  name = var.jenkins_role_name

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

resource "aws_iam_role_policy_attachment" "attach_s3_full_access" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "attach_kms_decrypt" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = aws_iam_policy.kms_decrypt_policy.arn
}
