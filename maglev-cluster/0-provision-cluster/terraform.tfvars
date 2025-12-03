prefix="aaaaaaaalex-workshop"

aws_region="us-west-2"
aws_zones=["us-west-2a"]
master_instance_type="t3.large"
node_instance_type="t3.large"
infra_node_machine_type="t3.large"

vpc_cidr="172.16.0.0/16"
vpc_subnets=["172.16.101.0/24"]
ip_family="ipv4"

kubernetes_version="v1.33.6"
num_nodes=3
num_infra_nodes=0

enable_cloud_provider=false
enable_hugepages=false

max_pods=0
enable_psp=false

