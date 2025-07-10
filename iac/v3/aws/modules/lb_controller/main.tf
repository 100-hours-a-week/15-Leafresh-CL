# resource "aws_iam_openid_connect_provider" "oidc" {
#   url             = var.cluster_oidc_url
#   client_id_list  = ["sts.amazonaws.com"]
#   thumbprint_list = [var.cluster_oidc_thumbprint]
# }

# data "aws_iam_policy_document" "assume_role" {
#   statement {
#     effect = "Allow"
#     principals {
#       type        = "Federated"
#       identifiers = [aws_iam_openid_connect_provider.oidc.arn]
#     }
#     actions = ["sts:AssumeRoleWithWebIdentity"]
#     condition {
#       test     = "StringEquals"
#       variable = format("%s:sub", replace(var.cluster_oidc_url, "https://", ""))
#       values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
#     }
#   }
# }

# resource "aws_iam_role" "lb_controller" {
#   name               = "${var.project_name}-lb-controller-role"
#   assume_role_policy = data.aws_iam_policy_document.assume_role.json
# }

# resource "aws_iam_policy_attachment" "attach" {
#   name       = "${var.project_name}-lb-controller-attach"
#   policy_arn = "arn:aws:iam::aws:policy/AWSLoadBalancerControllerIAMPolicy"
#   roles      = [aws_iam_role.lb_controller.name]
# }

resource "helm_release" "aws_lb_controller" {
  provider         = helm
  name             = "aws-load-balancer-controller"
  repository       = "https://aws.github.io/eks-charts"
  chart            = "aws-load-balancer-controller"
  version          = "1.13.0"
  namespace        = "kube-system"
  create_namespace = false

  set = [
    {
      name  = "clusterName"
      value = var.project_name
    },
    {
      name  = "region"
      value = var.region
    },
    {
      name  = "vpcId"
      value = var.vpc_id
    },
    {
      name  = "serviceAccount.create"
      value = "false"
    },
    {
      name  = "serviceAccount.name"
      value = "aws-load-balancer-controller"
    }
  ]

  # depends_on = [
  #   aws_iam_openid_connect_provider.oidc,
  #   aws_iam_role.lb_controller,
  #   aws_iam_policy_attachment.attach,
  # ]
}