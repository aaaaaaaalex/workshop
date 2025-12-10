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
receiving mid-TCP-session packets for unrecognized connections. It
must somehow find out which pod was originally selected to handle
the connection, and forward to that pod like the last node did.

This is where Maglev comes in.

In next step, we will create a backing workload capable of maintaining
long-lived TCP connections, and expose it with a new LoadBalancer IP.
We will then simulate a Calico node outage and observe the connection
breaking.

Finally, we will solve the ECMP problem by enabling Maglev
loadbalancing in Calico.
