resource "aws_iam_policy" "policy" {
  name        = "${var.component}-${var.env}-ssm-pm-policy"
  path        = "/"
  description = "${var.component}-${var.env}-ssm-pm-policy"

  policy = jsonencode(
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "VisualEditor0",
          "Effect": "Allow",
          "Action": [
            "ssm:GetParameterHistory",
            "ssm:GetParametersByPath",
            "ssm:GetParameters",
            "ssm:GetParameter"
          ],
          "Resource": "arn:aws:ssm:us-east-1:403215663985:parameter/roboshop.${var.env}.${var.component}.*"
        }
      ]
    })
}

#Role
resource "aws_iam_role" "role" {
name = "${var.component}-${var.env}-ec2-role"

assume_role_policy = jsonencode(
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
})
}

resource "aws_iam_role_policy_attachment" "policy-attach" {
  role      = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_instance_profile" "instance_profile" {
  name =  "${var.component}-${var.env}-ec2-role"
  role = "${aws_iam_role.role.name}"
}
