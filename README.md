# Bootstrapping clusters with `kubeadm`
In this repo, I have covered setting a NON-HA (**single** `control-plane`) & High Available Kubernetes cluster using `Kubernetes version: v1.27`. 

In this HA Setup, `ETCD` is deployed in **stacked** mode, i.e. the `etcd` members and `control plane` nodes are co-located. (`ETCD` can also be deployed in non-stacked node, i.e. on separate machines/nodes.)

## High Level Steps
1. Install Container Runtime
2. Install `kubeadm`, `kubelet` & `kubectl`
3. Install Pod network add-on

## Instructions
1. [Non-HA](Non-HA)
2. [HA](HA)


## Future Task
Once manual setup is done, the next step will be to automate bootstrapping a k8 cluster using Ansible and Terraform.