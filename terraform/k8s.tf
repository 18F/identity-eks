
resource "kubernetes_namespace" "idp" {
  metadata {
    name = "idp"
    labels = {
      istio-injection = "enabled"
    }
  }
}

resource "kubernetes_namespace" "elk" {
  metadata {
    name = "elk"
  }
}

resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = <<EOF
- rolearn: ${aws_iam_role.eks-node.arn}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
- rolearn: arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/FullAdministrator
  username: admin
  groups:
    - system:masters
- rolearn: arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/SOCAdministrator
  username: soc
  groups:
    - view
EOF
  }
}

resource "kubernetes_config_map" "idp-config" {
  metadata {
    name = "idp-config"
    namespace = "idp"
    labels = {
      name = "idp-config"
    }
  }

  data = {
    db_hostname = aws_db_instance.idp.address
    db_port = aws_db_instance.idp.port
    domain_name = var.idp_hostname
    mailer_domain_name = var.idp_hostname
  }
}

resource "kubernetes_service" "idp-redis" {
  metadata {
    name = "idp-redis"
    namespace = "idp"
    labels = {
      name = "idp-redis"
    }
  }

  spec {
    type = "ExternalName"
    external_name = aws_elasticache_replication_group.idp.primary_endpoint_address
    port {
      port = 6379
      protocol = "TCP"
      target_port = 6379
    }
  }
}

resource "kubernetes_ingress" "idp-ingress" {
  depends_on = [
    helm_release.alb-ingress-controller,
  ]
  metadata {
    name = "idp-ingress"
    namespace = "istio-system"
    annotations = {
      "kubernetes.io/ingress.class" = "alb"
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"
      "alb.ingress.kubernetes.io/certificate-arn" = module.acm-cert-idp.cert_arn
      "alb.ingress.kubernetes.io/backend-protocol" = "HTTPS"
      "alb.ingress.kubernetes.io/healthcheck-protocol" = "HTTPS"
      # XXX These are here for the future when we enable WAF
      # alb.ingress.kubernetes.io/waf-acl-id" = "XXX"
      # alb.ingress.kubernetes.io/wafv2-acl-arn" = "XXX"
      "alb.ingress.kubernetes.io/load-balancer-attributes" = "access_logs.s3.enabled=true,access_logs.s3.bucket=login-gov.elb-logs.${data.aws_caller_identity.current.account_id}-${var.region},access_logs.s3.prefix=${var.cluster_name}/idp"
      # limit access
      "alb.ingress.kubernetes.io/inbound-cidrs" = join(", ", var.kubecontrolnets)
    }
  }

  spec {
    rule {
      http {
        path {
          path = "/*"
          backend {
            service_name = "istio-ingressgateway"
            service_port = 443
          }
        }
      }
    }
  }
}

# resource "kubernetes_manifest" "idp_gateway" {
#   provider = kubernetes-alpha

#   manifest = {
#     apiVersion = "networking.istio.io/v1alpha3"
#     kind = "Gateway"
#     "metadata" = {
#       "name" = "idp-gateway"
#       "namespace" = "idp"
#     }
#     "spec" = {
#       "selector" = {
#         "app" = "idp"
#       }
#       "servers" = [
#         {
#           "port" = {
#             "number" = 443
#             "name" = "https"
#             "protocol" = "HTTPS"
#           }
#           # XXX why doesn't this work?
#           # "hosts" = [var.idp_hostname]
#           "hosts" = ["*"]
#           "tls" = {
#             # enables HTTPS on this port with self signed certs, I hope
#             "mode" = "ISTIO_MUTUAL"
#           }
#         }
#       ]
#     }
#   }
# }

resource "helm_release" "eksclusterautoscaler" {
  name       = "eksclusterautoscaler"
  repository = "https://kubernetes.github.io/autoscaler" 
  chart      = "cluster-autoscaler-chart"
  version    = "1.0.3"
  namespace  = "kube-system"

  set {
    name  = "awsRegion"
    value = var.region
  }

  set {
    name  = "extraArgs.skip-nodes-with-system-pods"
    value = "true"
  }

  set {
    name  = "autoDiscovery.clusterName"
    value = var.cluster_name
  }
}
