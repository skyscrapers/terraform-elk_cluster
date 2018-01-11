resource "aws_iam_policy" "elk_instances_policy" {
  count       = "${var.cluster_size == "0" ? 0 : 1}"
  name        = "elk_instances_policy_${var.name}_${var.project}_${var.environment}"
  description = "Policy for the ELK instances of ${var.name} ${var.project} ${var.environment}"
  policy = <<EOF
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
  count      = "${var.cluster_size == "0" ? 0 : 1}"
  role       = "${module.elk_instances.role_id}"
  policy_arn = "${aws_iam_policy.elk_instances_policy.arn}"
}

resource "aws_iam_policy" "cloudwatch_policy" {
  count       = "${var.cloudwatch_logs ? 1 : 0}"
  name        = "elk_instances_policy_${var.name}_${var.project}_${var.environment}"
  policy      = "${data.aws_iam_policy_document.cloudwatch_logs_push.json}"
}

data "aws_iam_policy_document" "cloudwatch_logs_push" {
  statement {
      effect = "Allow"
      actions = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      resources = ["*"]
    }
}

resource "aws_iam_role_policy_attachment" "cloudwatch_policy" {
  count       = "${var.cloudwatch_logs ? 1 : 0}"
  role       = "${module.elk_instances.role_id}"
  policy_arn = "${aws_iam_policy.cloudwatch_policy.arn}"
}
