# A Note on Persistent Connections

So far, we have:
 - configured Calico to perform IPAM for services of `type:LoadBalancer`,
 - created a service of `type:LoadBalancer` with an external IP, and created
   backing pods for that service on each cluster node.
 - made short-lived connections to the backends from our primitive router, by
   making requests to the LoadBalancer IP.

However, for long-lived connections, this setup may be insufficient.
That's because of some behaviours that Linux employs for ECMP routes.

Consider our router's possible paths to the service IP:

```
192.210.123.0/24 
        nexthop via 172.16.101.116 dev ens5 weight 1 
        nexthop via 172.16.101.126 dev ens5 weight 1 
        nexthop via 172.16.101.49 dev ens5 weight 1 
```

If one of these hops (nodes) disappears, say, during an outage or
scheduled downtime, the router must pick a different path for the
packets which would have been sent over the disappearing hop.

This is problematic for a surviving Calico node which is suddenly
receiving mid-TCP-session packets for unrecognized connections.
It must somehow find out which pod was originally selected to handle
the connection, and forward to that pod like the last node did.

If we are lucky, the connection will switch onto the Calico node
where the pod is located. Since that Calico node is already accustomed
to forwarding packets for this service connection, it may succeed
in maintaining the connection, but we can't rely on luck! If the
traffic lands on a node which does not have connection information
for that traffic, the packets will be dropped.

Maglev can solve this problem by giving every Calico node the
ability to choose the right backend, even if the connection is
unrecognized. This is done by hashing the packet's 5-tuple (it's
source/dest. IP address, ports, and protocol).

In the next step, we will create a backing workload capable of maintaining
long-lived TCP connections, and expose it with a new LoadBalancer IP.

We will then simulate a node outage while a connection is open,
so that we can see how the connection breaks. Finally, we will solve
the ECMP problem by enabling Maglev loadbalancing for the service,
and verify its operation by watching connections survive past the outage.
