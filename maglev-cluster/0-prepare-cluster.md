# Prepare a Calico Cluster on AWS EC2

## Requirements

While this workshop won't go into detail on provisioning the cloud
resources, briefly, the requirements of the cloud topology are as follows:

 - A single subnet consisting of 4 EC2 instances.

 - For convenience, each VM in this workshop will have its own public IP,
   and the security groups will be configured to allow SSH access to each.

 - 3 of the nodes must be part of a K8s cluster, with **Calico installed**.

 - The cluster must be configured to use Calico with the Calico eBPF Dataplane.

 - The 4th node will act as a cluster-external L3 router, capable of
   routing service-IP traffic into the cluster. This workshop will make use of
   iptables to configure it.

 - **DSR must be supported and enabled.** In other words, the nodes of the
   network, as-well-as the fabric between nodes, must be happy with
   assymmetrical traffic paths for cluster traffic. It may be necessary to
   disable source & destination checks in AWS to allow for this.


## A Note on IPs

In the steps to follow, the IPs of the aforementioned nodes will be
referenced in scripts for the purposes of examining traffic, and SSH:

 - `${node_0_pub_ip}`, `${node_1_pub_ip}`, and `${node_2_pub_ip}` for the
   worker node IP's.

 - `${node_0_priv_ip}`, `${node_1_priv_ip}`, and `${node_2_priv_ip}` for the
   cluster node private IPs.

 - `${node_ext_pub_ip}` for the cluster-external node's public IP.

 - `${node_ext_priv_ip}` for the cluster-external node's private IP.

It will be useful to have these values set in a file so that we can
easily declare them in new shells:

```sh
# Add relevant instance IPs to a file.
cat - <<EOF >nodeips.source
node_0_priv_ip=x.x.x.x
node_1_priv_ip=x.x.x.x
node_2_priv_ip=x.x.x.x
node_0_pub_ip=x.x.x.x
node_1_pub_ip=x.x.x.x
node_2_pub_ip=x.x.x.x
node_ext_pub_ip=x.x.x.x
node_ext_priv_ip=x.x.x.x
EOF

# Initialise the values in the file as variables in the current shell.
source ./nodeips.source
```

You may also see this workshop replace those IPs' values with those
same variable names in the format `<node_0_pub_ip>`... etc. This
will hopefully make command output more meaningful.
