# Purpose: Create EKS cluster

module "eks" {
  source             = "terraform-aws-modules/eks/aws"
  version            = "~> 21.0"
  name               = local.cluster_name
  kubernetes_version = var.kubernetes_version
  subnet_ids         = module.vpc.private_subnets

  enable_irsa            = true # IAM roles for service accounts (IRSA) is a feature of Amazon EKS that lets you connect AWS IAM roles to Kubernetes service accounts. This allows applications to use AWS services while running in Kubernetes clusters
  endpoint_public_access = true # Allow public access to the k8s API server

  tags = {
    cluster = "self-hosted-llm"
  }

  vpc_id = module.vpc.vpc_id

  addons = {
    vpc-cni = {
      before_compute = true # Critical: Forces CNI deployment before node groups provision
      most_recent    = true
    }
    kube-proxy = { most_recent = true }
    coredns    = { most_recent = true }
  }

  # Define Node groups
  eks_managed_node_groups = {
    general_node_group_1 = {
      ami_type      = "AL2023_x86_64_STANDARD"
      intance_types = ["t3.medium"]
      # vpc_security_group_ids = [aws_security_group.all_worker_mgmt.id]
      min_size      = 1
      max_size      = 2
      desired_size  = 1
      capacity_type = "SPOT"
    }

    # epp_node_group_1 = {
    #   ami_type      = "AL2023_x86_64_STANDARD"
    #   intance_types = ["t3.large"]
    #   disk_size     = 50
    #   # vpc_security_group_ids = [aws_security_group.all_worker_mgmt.id]
    #   min_size      = 2
    #   max_size      = 4
    #   desired_size  = 2
    #   capacity_type = "SPOT"
    # }

    # gpu_node_group_250 = {
    #   ami_type       = "AL2023_x86_64_NVIDIA"
    #   instance_types = ["g6.xlarge"]
    #   capacity_type  = "SPOT"

    #   min_size     = 1
    #   max_size     = 2
    #   desired_size = 1

    #   # Increase disk space via block device mappings
    #   block_device_mappings = {
    #     xvda = {
    #       device_name = "/dev/xvda"
    #       ebs = {
    #         volume_size           = 100 # Size in GiB
    #         volume_type           = "gp3"
    #         iops                  = 3000
    #         throughput            = 125
    #         encrypted             = true
    #         delete_on_termination = true
    #       }
    #     }
    #   }
    # }
  }
}

