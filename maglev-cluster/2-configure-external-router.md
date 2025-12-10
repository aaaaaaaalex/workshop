# Configure Routing on Cluster-External Router

We will now configure our cluster-external instance
to act like a primitive L3 router. For now, we will keep it
simple, and statically program routes with Iptables
commands.

For this step, all commands are executed via SSH or similar,
on the cluster-external instance (`ssh ${node_ext_pub_ip}`).

## Add ECMP Routing to the Cluster IP

Since all Calico Nodes are capable of handling the
service traffic, I'll craft an ECMP route on our router
that will distribute connections to each of them.

Since we have allocated an IPPool specially ford
loadbalancer IPs, we can program a single route
to the CIDR `192.210.123.0/24`.

Note that my external node's main interface is `ens5`.
Also note the snippet below uses the variable names
described in a previous step to reference my node IPs,
since the actual addresses will differ between environments.

```sh
ip route add 192.210.123.0/24 \
  nexthop via ${node_0_priv_ip} dev ens5 \
  nexthop via ${node_1_priv_ip} dev ens5 \
  nexthop via ${node_2_priv_ip} dev ens5
```

This should lead to the following route appearing
in the output of `ip route`:

```
192.210.123.0/24 
        nexthop via <node_0_priv_ip> dev ens5 weight 1 
        nexthop via <node_1_priv_ip> dev ens5 weight 1 
        nexthop via <node_2_priv_ip> dev ens5 weight 1 
```

Your nexthop IP's should appear in-place of `<node_0_priv_ip>`,
`<node_1_priv_ip>`, and `<node_2_priv_ip>`.

## Verify Traffic to LoadBalancer Service

Since we have a test service with http-serving backends
deployed to K8s, we should now be able to make a request
to it from our primitive router:

```sh
service_ip=<your service IP here>
curl ${service_ip}
```

Insert your own service IP into the script.

Our router will decide which hop to send the traffic to.
So, everytime we create a new connection to the service,
the backend responding to us might change:

First `curl` response:

```
WBITT Network MultiTool (with NGINX) - http-server-6644s - 192.168.226.200 - HTTP: 80 , HTTPS: 443 . (Formerly praqma/network-multitool)
```

Second `curl` response:

```
WBITT Network MultiTool (with NGINX) - http-server-vq2h4 - 192.168.86.200 - HTTP: 80 , HTTPS: 443 . (Formerly praqma/network-multitool)
```

And so on.
