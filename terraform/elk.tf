
resource "aws_iam_service_linked_role" "es" {
  aws_service_name = "es.amazonaws.com"
}

resource "aws_elasticsearch_domain" "es" {
  domain_name           = var.cluster_name
  elasticsearch_version = "7.7"

  node_to_node_encryption {
    enabled = true
  }

  cluster_config {
    instance_type = "m3.large.elasticsearch"
    instance_count = 3
  }

  encrypt_at_rest {
    enabled = true
  }

  vpc_options {
    security_group_ids = [aws_security_group.eks-cluster.id]
    subnet_ids         = aws_subnet.eks[*].id
  }

  domain_endpoint_options {
    enforce_https = true
  }

  access_policies = <<CONFIG
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "es:*",
            "Principal": "*",
            "Effect": "Allow",
            "Resource": "arn:aws:es:${var.region}:${data.aws_caller_identity.current.account_id}:domain/${var.cluster_name}/*"
        }
    ]
}
CONFIG

  tags = {
    Domain = var.cluster_name
  }

  depends_on = [aws_iam_service_linked_role.es]
}
