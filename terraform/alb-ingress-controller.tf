
resource "aws_iam_role_policy" "alb_ingress_controller" {
  name = "${var.cluster_name}-alb-ingress-controller"
  role = aws_iam_role.eks-node.id

  policy = file("../base/alb-ingress-controller/alb-ingress-controller-iam-policy.json")
}

