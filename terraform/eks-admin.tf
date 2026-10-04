resource "aws_eks_access_entry" "admin_entry" {
  cluster_name  = module.eks.cluster_name # Replace with your actual cluster name
  principal_arn = var.eks_admin_user
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "admin_policy" {
  cluster_name  = module.eks.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = var.eks_admin_user

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.admin_entry]
}
