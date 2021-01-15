
# resource "kubernetes_namespace" "elk" {
#   metadata {
#     name = "elk"
#   }
# }

# # XXX if we are FullAdministrator, I think we don't actually need this?
# resource "kubernetes_config_map" "aws_auth" {
#   metadata {
#     name = "aws-auth"
#     namespace = "kube-system"
#   }

#   data = {
#     mapRoles = <<EOF
# - rolearn: ${aws_iam_role.eks-node.arn}
#   username: system:node:{{EC2PrivateDNSName}}
#   groups:
#     - system:bootstrappers
#     - system:nodes
# - rolearn: arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/FullAdministrator
#   username: admin
#   groups:
#     - system:masters
# - rolearn: arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/SOCAdministrator
#   username: soc
#   groups:
#     - view
# EOF
#   }
# }



# # XXX this is not going to work because istio isn't going yet.  :-(
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
