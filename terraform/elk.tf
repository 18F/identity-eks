
resource "aws_elasticsearch_domain" "es" {
  domain_name           = var.cluster_name
  elasticsearch_version = "7.7"

  node_to_node_encryption {
    enabled = true
  }

  cluster_config {
    instance_type = "m4.large.elasticsearch"
    instance_count = 4
    zone_awareness_enabled = true
    zone_awareness_config {
      availability_zone_count = 2
    }
  }

  encrypt_at_rest {
    enabled = true
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 90
  }
  
  vpc_options {
    security_group_ids = [aws_security_group.eks-cluster.id]
    subnet_ids         = tolist(aws_subnet.eks[*].id)
  }

  domain_endpoint_options {
    enforce_https = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

#   access_policies = <<CONFIG
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Action": "es:*",
#             "Principal": "*",
#             "Effect": "Allow",
#             "Resource": "arn:aws:es:${var.region}:${data.aws_caller_identity.current.account_id}:domain/${var.cluster_name}/*"
#         }
#     ]
# }
# CONFIG

  tags = {
    Domain = var.cluster_name
  }
}

resource "aws_iam_role_policy" "elk" {
  name = "${var.cluster_name}_elk"
  role = aws_iam_role.eks-node.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "es:ESHttp*"
      ],
      "Effect": "Allow",
      "Resource": "${aws_elasticsearch_domain.es.arn}"
    }
  ]
}
EOF
}
