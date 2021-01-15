
resource "aws_iam_role_policy" "alb_ingress_controller" {
  name = "${var.cluster_name}-alb-ingress-controller"
  role = aws_iam_role.eks-node.id

  policy = file("../base/alb-ingress-controller/alb-ingress-controller-iam-policy.json")
}

resource "helm_release" "alb-ingress-controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts" 
  chart      = "aws-load-balancer-controller"
  version    = "1.1.2"
  namespace  = "kube-system"

  set {
    name  = "autoDiscoverAwsRegion"
    value = "true"
  }

  set {
    name  = "autoDiscoverAwsVpcID"
    value = "true"
  }

  set {
    name  = "clusterName"
    value = var.cluster_name
  }
}
