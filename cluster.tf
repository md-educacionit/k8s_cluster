data "aws_eks_cluster" "cluster" {
  name = module.my-cluster.cluster_id
  }

data "aws_eks_cluster_auth" "cluster" {
  name = module.my-cluster.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  
}

module "my-cluster" {
  
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "k8s"
  cluster_version = "1.17"
  subnets         = module.vpc.public_subnets
  vpc_id          = module.vpc.vpc_id
  cluster_create_security_group = true

  worker_groups = [
    {
      instance_type = "t2.micro"
      asg_desired_capacity  = 5
      asg_max_size  = 5
    }
  ]
}





resource "aws_security_group_rule" "allow_all" {

  #Allow HTTP from anywhere
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = module.my-cluster.worker_security_group_id
  cidr_blocks = ["${var.my_public_ip}/32"]
  description              = "allow all"
}
