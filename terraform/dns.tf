
resource "aws_route53_zone" "eks" {
  name = "${var.cluster_name}.v2.identitysandbox.gov"

  tags = {
    Environment = var.cluster_name
  }
}

resource "aws_route53_record" "eks-ns" {
  zone_id = var.v2_zone_id
  name = "${var.cluster_name}.v2.identitysandbox.gov"
  type    = "NS"
  ttl     = "30"
  records = aws_route53_zone.eks.name_servers
}

resource "aws_iam_role_policy" "eks-ns" {
  name = "${var.cluster_name}AllowExternalDNSUpdates"
  role = aws_iam_role.eks-node.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": [
        "arn:aws:route53:::hostedzone/${aws_route53_zone.eks.zone_id}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

