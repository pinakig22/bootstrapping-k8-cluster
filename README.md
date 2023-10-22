# Bootstrapping clusters with `kubeadm`
In this repo, I have covered setting a High Available Kubernetes cluster using `Kubernetes version: v1.27`. `ETCD` is deployed in stacked node, i.e. the `etcd` members and `control plane` nodes are co-located.

Using `kubeadm`, you can create a minimum viable Kubernetes cluster that conforms to best practices.

To achieve High Availability, following is the setup:
- 3 Control Plane nodes (Master node).
  - ETCD deployed in stacked mode.
- 3 Worker Node
- Network Load Balancer
  - In a cloud environment you should place your control plane nodes behind a TCP forwarding load balancer.
  - This load balancer distributes traffic to all healthy control plane nodes in its target list.
    - The health check for an apiserver is a TCP check on the port the kube-apiserver listens on (default value :6443). 

# Hardware Specs
This setup is deployed on AWS Infrastructure. Details as below.

This is in line with, _System Requirements_ defined under "Before You Begin" in "Creating a cluster with kubeadm" 
in the reference.

1. AMI Used: Ubuntu Server 22.04 LTS (HVM), SSD Volume Type (ami-0287a05f0ef0e9d9a) (AMI IDs are different in different AWS region. This is from Mumbai region)
2. Instances:
   1. Bastion Host: Acts as jump host to connect to control and worker nodes.
   2. 3 x Control Nodes: t3a.medium
   3. 3 x Worker Nodes: t3a.small
3. All instances are managed via AutoScaling and Launch Templates.

# Instructions
## Preparing a Host
### Container Runtime Install 
Install a **container runtime: `CRI-O`** and **`kubeadm`** on all the hosts.

> NOTE: I am using `cri-o` instead if `containerd` because, in Kubernetes certification exams, `cri-o` is used as the container runtime in the exam clusters.

To install on the `APT` based operating systems, set the environment variable **`$OS`** to the appropriate value from the following table:

| Operating system   | $OS               |
| ------------------ | ----------------- |
| Debian 12          | `Debian_12`       |
| Debian 11          | `Debian_11`       |
| Debian 10          | `Debian_10`       |
| Raspberry Pi OS 11 | `Raspbian_11`     |
| Raspberry Pi OS 10 | `Raspbian_10`     |
| Ubuntu 22.04       | `xUbuntu_22.04`   |
| Ubuntu 21.10       | `xUbuntu_21.10`   |
| Ubuntu 21.04       | `xUbuntu_21.04`   |
| Ubuntu 20.10       | `xUbuntu_20.10`   |
| Ubuntu 20.04       | `xUbuntu_20.04`   |
| Ubuntu 18.04       | `xUbuntu_18.04`   |

```shell
# Install CRI-O Runtime #

## Run the following as root ##
## Do this on all Control plane nodes ##
yum update

## This is Operating system version as per above instruction ##
export OS="CentOS_8"  

## This is kubernetes version ##
export VERSION="1.27"

curl -L -o /etc/yum.repos.d/devel:kubic:libcontainers:stable.repo https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/devel:kubic:libcontainers:stable.repo
curl -L -o /etc/yum.repos.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.repo https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$VERSION/$OS/devel:kubic:libcontainers:stable:cri-o:$VERSION.repo

or if you are using a subproject release:

curl -L -o /etc/yum.repos.d/devel:kubic:libcontainers:stable:cri-o:${VERSION}.repo https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/${SUBVERSION}:/${VERSION}/$OS/devel:kubic:libcontainers:stable:cri-o:${SUBVERSION}:${VERSION}.repo

yum install cri-o
```


### Install `CRI-O` Container Runtime

 

References: 
- [Creating a cluster with kubeadm](https://v1-27.docs.kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/)
- [CRI-O Installation Instructions - Ubuntu](https://github.com/cri-o/cri-o/blob/main/install.md#apt-based-operating-systems)
