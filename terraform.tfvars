tags = {
  "provisioned_by" = "devops",
  "env"            = "test",
}
region             = "us-west-1"
profile            = "terraform"
cidr_block         = "10.0.0.0/16"
external_subnets   = ["10.3.0.0/20", "10.4.0.0/20"]
internal_subnets   = ["10.1.0.0/19", "10.2.0.0/19"]
availability_zones = ["us-west-1a", "us-west-1b"]
external_ips       = ["61.16.136.118/32"]
cluster_name       = "eks-cluster"
worker_node_instance_type = "t2.medium"
worker_node_desired_capacity = 3
