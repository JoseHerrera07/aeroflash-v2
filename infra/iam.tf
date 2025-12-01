resource "aws_iam_role" "ec2_role" {
  name = "aeroflash_ec2_role_v2"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}


resource "aws_iam_policy" "secrets_policy" {
  name        = "aeroflash-secrets-policy"
  description = "Permite leer secretos de AeroFlash"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = "secretsmanager:GetSecretValue"
      Effect   = "Allow"
      Resource = aws_secretsmanager_secret.db_creds.arn
    }]
  })
}


resource "aws_iam_role_policy_attachment" "attach_secrets" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.secrets_policy.arn
}


resource "aws_iam_instance_profile" "ec2_profile" {
  name = "aeroflash_ec2_profile_v2"
  role = aws_iam_role.ec2_role.name
}
