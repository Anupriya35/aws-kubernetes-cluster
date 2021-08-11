provider aws {
  profile = var.profile
  region  = var.region
  //version = "2.46.0"
}


module "eks_bastion" {
  source             = "./modules/eks_bastion"
  cluster_name       = var.cluster_name
  region             = var.region
  profile            = var.profile
  cidr_block         = var.cidr_block
  external_subnets   = var.external_subnets
  internal_subnets   = var.internal_subnets
  availability_zones = var.availability_zones
  external_ips       = var.external_ips
  tags               = var.tags

}


module "eks_master" {
  source                 = "./modules/eks_master"
  cluster_name           = var.cluster_name
  vpc_id                 = module.eks_bastion.vpc_id
  external_ips           = var.external_ips
  eks_cluster_subnet_ids = concat(module.eks_bastion.internal_subnet, module.eks_bastion.external_subnet)
  tags                   = var.tags

}

module "eks_worker" {
  source                         = "./modules/eks_worker"
  cluster_name                   = var.cluster_name
  eks_cluster_version            = module.eks_master.eks_cluster_version
  eks_cluster_ep                 = module.eks_master.eks_cluster_ep
  eks_certificate_authority_data = module.eks_master.eks_certificate_authority_data
  vpc_id                         = module.eks_bastion.vpc_id
  bastion_sg					 = module.eks_bastion.bastion_sg
  cluster_security_group_id       = module.eks_master.cluster_security_group_id
  private_subnet_ids             = module.eks_bastion.internal_subnet
  instance_type					 = var.worker_node_instance_type
  desired_capacity				 = var.worker_node_desired_capacity
  tags                           = var.tags
}

locals {
  config_map_aws_auth = <<CONFIGMAPAWSAUTH


apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${module.eks_worker.eks_worker_role_arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
CONFIGMAPAWSAUTH

}


// Outputs
output "vpc_id" { value = module.eks_bastion.vpc_id }
output "cidr_block" { value = var.cidr_block }
output "availability_zones" { value = var.availability_zones }
output "config_map_aws_auth" { value = local.config_map_aws_auth }
