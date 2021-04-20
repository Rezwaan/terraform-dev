#### Instance profiles

resource "aws_iam_instance_profile" "asg" {

  lifecycle {
    create_before_destroy = false
  }

  name = "${terraform.workspace}_asg_profile"
  role = aws_iam_role.asg.name
}

#### Instance roles

resource "aws_iam_role" "asg" {
  name = "${terraform.workspace}_asg_role"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
  EOF
}

#### S3 policies

resource "aws_iam_role_policy" "asg" {
  name = "${terraform.workspace}-globo-primary-rds"
  role = aws_iam_role.asg.id

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "s3:*"
        ],
        "Effect": "Allow",
        "Resource": [
                "arn:aws:s3:::var.bucket_name",
                "arn:aws:s3:::var.bucket_name/*"
            ]
      }
    ]
  }
  EOF
}