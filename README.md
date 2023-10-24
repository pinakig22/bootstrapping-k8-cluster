# Bootstrapping clusters with `kubeadm`
In this repo, I have covered setting a High Available Kubernetes cluster using `Kubernetes version: v1.27`. `ETCD` is deployed in stacked node, i.e. the `etcd` members and `control plane` nodes are co-located.

Using `kubeadm`, you can create a minimum viable Kubernetes cluster that conforms to best practices.

To achieve **High Availability**, following is the setup:
- **3 Control Plane** nodes (Master node).
  - `ETCD` deployed in **stacked** mode.
- **3 Worker Node**
- Network Load Balancer
  - In a cloud environment you should place your control plane nodes behind a TCP forwarding load balancer.
  - This load balancer distributes traffic to all healthy control plane nodes in its target list.
    - The health check for an `apiserver` is a TCP check on the port the `kube-apiserver` listens on (default value `:6443`). 

## Step by Step Instructions
1. [Infrastructure](1.%20INFRASTRUCTURE)
2. [Preparing Host](2. Node Setup)
