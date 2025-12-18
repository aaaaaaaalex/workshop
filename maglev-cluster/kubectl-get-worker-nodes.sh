#!/bin/sh
kubectl get no -l node-role.kubernetes.io/control-plane!="" $@
