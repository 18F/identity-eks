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

  idp_configmap = <<CONFIGMAP
apiVersion: v1
kind: ConfigMap
metadata:
  name: idp-config
  namespace: idp
  labels:
    name: idp-config
data:
  db_hostname: "${aws_db_instance.idp.address}"
  db_port: "${aws_db_instance.idp.port}"
  domain_name: ${var.idp_hostname}
  mailer_domain_name: ${var.idp_hostname}
CONFIGMAP

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
    alb.ingress.kubernetes.io/healthcheck-protocol: HTTPS
    # XXX These are here for the future when we enable WAF
    # alb.ingress.kubernetes.io/waf-acl-id: XXX
    # alb.ingress.kubernetes.io/wafv2-acl-arn: XXX
    alb.ingress.kubernetes.io/load-balancer-attributes: access_logs.s3.enabled=true,access_logs.s3.bucket=login-gov.elb-logs.${data.aws_caller_identity.current.account_id}-${var.region},access_logs.s3.prefix=${var.cluster_name}/idp
    # limit to just tspencer and GSA for now
    alb.ingress.kubernetes.io/inbound-cidrs: 98.146.223.15/32, 159.142.0.0/16
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

  idp_gateway = <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: idp-gateway
  namespace: idp
spec:
  selector:
    app: idp
  servers:
  - port:
      number: 443
      name: https
      protocol: HTTPS
    hosts:
    - ${var.idp_hostname}
    tls:
      mode: ISTIO_MUTUAL # enables HTTPS on this port with self signed certs
EOF

}

output "config_map_aws_auth" {
  value = local.config_map_aws_auth
}

output "cluster_arn" {
  value = aws_eks_cluster.eks.arn
}

output "idp_configmap" {
  value = local.idp_configmap
}

output "idp_redis_service" {
  value = local.idp_redis_service
}

output "idp_ingress" {
  value = local.idp_ingress
}

output "idp_gateway" {
  value = local.idp_gateway
}
