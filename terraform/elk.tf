
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
  
  # XXX If you enable these, it will be in the VPC, but inaccessible without struggle
  # vpc_options {
  #   security_group_ids = [aws_security_group.elk.id]
  #   subnet_ids         = tolist(aws_subnet.eks[*].id)
  # }

  domain_endpoint_options {
    enforce_https = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  access_policies = <<CONFIG
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {"AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/FullAdministrator"},
      "Action": "es:ESHttp*",
      "Condition": {
        "IpAddress": {
          "aws:SourceIp": [ ${join(", ", formatlist("\"%s\"", var.kubecontrolnets))} ]
        }
      },
      "Resource": "arn:aws:es:${var.region}:${data.aws_caller_identity.current.account_id}:domain/${var.cluster_name}/*"
    }
  ]
}
CONFIG

  tags = {
    Domain = var.cluster_name
  }
}

resource "aws_security_group" "elk" {
  description = "Allow elasticsearch/kibana access"

  egress = []

  ingress {
    description = "allow users in to kibana"
    from_port   = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = var.kubecontrolnets
  }

  ingress {
    description = "allow cluster to connect to elasticsearch"
    from_port = 9200
    to_port = 9200
    protocol = "tcp"
    security_groups = [aws_security_group.eks-cluster.id]
  }

  name = "${var.cluster_name}-elk"

  tags = {
    Name = "${var.cluster_name}-elk_security_group"
  }

  vpc_id = aws_vpc.eks.id
}
