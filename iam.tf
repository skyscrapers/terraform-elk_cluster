resource "aws_iam_policy" "elk_instances_policy" {
  name        = "elk_instances_policy_${var.name}_${var.project}_${var.environment}"
  description = "Policy for the ELK instances of ${var.name} ${var.project} ${var.environment}"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:DescribeInstances",
        "ec2:DescribeVolume*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }${length(var.snapshot_s3_bucket_arn) == 0 ? "" : format(var.snapshot_s3_bucket_policy, var.snapshot_s3_bucket_arn, var.snapshot_s3_bucket_arn)}
  ]
}
EOF
}

variable "snapshot_s3_bucket_policy" {
  default = <<EOF
,
{
  "Effect": "Allow",
  "Action": [
    "s3:DeleteObject",
    "s3:DeleteObjectVersion",
    "s3:GetBucketAcl",
    "s3:GetBucketCORS",
    "s3:GetBucketLocation",
    "s3:GetObject",
    "s3:GetObjectAcl",
    "s3:GetObjectVersion",
    "s3:GetObjectVersionAcl",
    "s3:ListBucket",
    "s3:PutObject",
    "s3:PutObjectAcl",
    "s3:PutObjectVersionAcl"
  ],
  "Resource": [
    "%s",
    "%s/*"
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "elk_instances_policy_attachment" {
  role       = "${module.elk_instances.role_id}"
  policy_arn = "${aws_iam_policy.elk_instances_policy.arn}"
}
