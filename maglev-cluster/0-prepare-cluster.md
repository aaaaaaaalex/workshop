# Prepare a Calico Cluster on AWS EC2

## Requirements

While this workshop won't go into detail on provisioning the cloud
resources, briefly, the requirements of the cloud topology are as follows:

 - A single subnet consisting of 4 EC2 instances.

 - For convenience, each VM in this workshop will have its own public IP,
   and the security groups will be configured to allow SSH access to each.

 - 3 of the nodes must be part of a K8s cluster, with **Calico installed**.

 - The Calico cluster must be configured to use the Calico eBPF Dataplane.

 - The 4th node will act as a cluster-external L3 router, capable of
   forwarding service-IP traffic into the cluster. I'll be making use of
   iptables to configure

 - **DSR must be supported and enabled.** In other words, the nodes of the network,
   as-well-as the fabric between nodes, must be happy with assymmetrical traffic paths
   for cluster traffic.

## A Note on IPs

In the steps to follow, the IPs of the aforementioned nodes will be
referenced in scripts for the purposes of examining traffic, and SSH:

 - `${node_0_pub_ip}`, `${node_1_pub_ip}`, and `${node_2_pub_ip}` for the
   worker node IP's.

 - `${node_0_priv_ip}`, `${node_1_priv_ip}`, and `${node_2_priv_ip}` for the cluster node private IPs.

 - `${node_ext_pub_ip}` for the cluster-external node's public IP.

 - `${node_ext_priv_ip}` for the cluster-external node's private IP.

You may also see the same aliases but in the format `<node_0_pub_ip>`... etc, in command *output*.
