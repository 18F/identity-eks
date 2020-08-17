#
# Outputs
#

locals {
  config_map_aws_auth = <<CONFIGMAPAWSAUTH
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
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
  # XXX this should work, but it's not?  Maybe because it's an assumed role?
  # mapUsers: |
  #   - userarn: arn:aws:sts::${data.aws_caller_identity.current.account_id}:assumed-role/FullAdministrator/timothy.spencer
  #     username: admin
  #     groups:
  #       - system:masters
CONFIGMAPAWSAUTH

  idp_db_configmap = <<DBCONFIGMAP
apiVersion: v1
kind: ConfigMap
metadata:
  name: idp-postgres
  namespace: idp
  labels:
    name: idp-postgres
data:
  hostname: "${aws_db_instance.idp.address}"
  port: "${aws_db_instance.idp.port}"
DBCONFIGMAP

  idp_redis_service = <<REDISSERVICE
apiVersion: v1
kind: Service
metadata: 
  labels: 
    name: idp-redis
  name: idp-redis
spec: 
  type: ExternalName
  externalName: ${aws_elasticache_replication_group.idp.primary_endpoint_address}
  ports: 
    - port: 6379
      protocol: TCP
      targetPort: 6379
REDISSERVICE

  idp_ingress = <<EOF
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: idp-ingress
  namespace: istio-system
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/certificate-arn: ${module.acm-cert-idp.cert_arn}
    alb.ingress.kubernetes.io/backend-protocol: HTTPS
spec:
  rules:
  - host: secure.${var.cluster_name}.v2.identitysandbox.gov
    http:
      paths:
      - path: /*
        backend:
          serviceName: istio-ingressgateway
          servicePort: 443
EOF

}

output "config_map_aws_auth" {
  value = local.config_map_aws_auth
}

output "cluster_arn" {
  value = aws_eks_cluster.eks.arn
}

output "idp_db_configmap" {
  value = local.idp_db_configmap
}

output "idp_redis_service" {
  value = local.idp_redis_service
}

output "idp_ingress" {
  value = local.idp_ingress
}

