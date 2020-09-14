
resource "aws_iam_role_policy" "alb_ingress_controller" {
  name = "${var.cluster_name}-alb-ingress-controller"
  role = aws_iam_role.eks-node.id

  policy = file("../base/alb-ingress-controller/alb-ingress-controller-iam-policy.json")
}

resource "helm_release" "alb-ingress-controller" {
  name       = "alb-ingress-controller"
  repository = "http://storage.googleapis.com/kubernetes-charts-incubator" 
  chart      = "aws-alb-ingress-controller"
  version    = "0.1.14"
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
