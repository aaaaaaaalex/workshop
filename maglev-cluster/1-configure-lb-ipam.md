# Configure Calico LoadBalancer IPAM

We will first configure Loadbalancer IPAM according
to the [Calico documentation](https://docs.tigera.io/calico/latest/networking/ipam/service-loadbalancer)


## Verify Calico LoadBalancer controller is enabled

Check the Calico `kubecontrollersconfiguration` resource
to verify the LoadBalancer controller is activated.

We must ensure that: `kubecontrollersconfiguration/default.spec.controllers.loadBalancer.assignIPs`
has the value: `AllServices`.

```sh
kubectl get kubecontrollersconfiguration default -o yaml
```

...and conditionally:

```sh
kubectl patch kubecontrollersconfiguration default  --type=merge --patch '{"spec": {"controllers":{"loadBalancer":{"assignIPs": "AllServices"}}}}'
```

## Create an IPPool for Services of type:LoadBalancer

My cluster is starting out with a Calico IPPool for pods
named `default-ipv4-ippool`, which has the CIDR `192.168.0.0/16`.

I'll create a non-overlapping, smaller pool for loadbalancer IPs (`192.210.123.0/24`):


```sh
kubectl create -f -<<EOF
apiVersion: projectcalico.org/v3
kind: IPPool
metadata:
 name: loadbalancer-ip-pool
spec:
 cidr: 192.210.123.0/24
 blockSize: 24
 natOutgoing: true
 disabled: false
 assignmentMode: Automatic
 allowedUses:
  - LoadBalancer
EOF
```

## Create a Dummy Service to Verify LoadBalancer IPAM

Let's create a service with no backing to pods to verify
Calico can assign a loadbalancer IP from the newly-configured pool:

```sh
kubectl apply -f -<<EOF
apiVersion: v1
kind: Service
metadata:
  name: http-server
spec:
  selector:
    app: http-server
  ports:
    - port: 80
      targetPort: 80
      name: default
  type: LoadBalancer
EOF
```

And check what IP was assigned by running `kubectl get svc -o wide` :

```
NAME          TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)        AGE
http-server   LoadBalancer   10.102.43.188   192.210.123.0   80:32462/TCP   11s
```

The external IP `192.210.123.0` is within the expected CIDR, so
IPAM is working as expected.

## Set an env-var in your shell to store the service IP

Remember to add your own service's external IP here, if it differs from mine:

```sh
service_ip=192.210.123.0
```