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
### Install `CRI-O` Container Runtime 
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
apt update -y

## Disable swap &  turn off during reboots ##
swapoff -a
(crontab -l 2>/dev/null; echo "@reboot /sbin/swapoff -a") | crontab - || true

## This is Operating system version as per above instruction ##
export OS="xUbuntu_22.04"  

## This is kubernetes version for which CRI-O will be installed ##
export VERSION="1.27"

## Create the .conf file to load the modules at bootup ##
cat <<EOF | sudo tee /etc/modules-load.d/crio.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

## Set up required sysctl params, these persist across reboots. ##

cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

### verify systctl params ###
sysctl --system|grep net.bridge.
sysctl --system|grep net.ipv4.ip_forward

echo "deb [signed-by=/usr/share/keyrings/libcontainers-archive-keyring.gpg] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /" > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
echo "deb [signed-by=/usr/share/keyrings/libcontainers-crio-archive-keyring.gpg] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/ /" > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.list

mkdir -p /usr/share/keyrings

curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | gpg --dearmor -o /usr/share/keyrings/libcontainers-archive-keyring.gpg
curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/Release.key | gpg --dearmor -o /usr/share/keyrings/libcontainers-crio-archive-keyring.gpg

apt-get update
apt-get install cri-o cri-o-runc

## Reload systemd manager configuration ##
systemctl daemon-reload

## Enable to start at boot ##
systemctl enable crio --now

## Start crio service and verify status ##
systemctl start crio.service
systemctl status crio.service
```


 

References: 
- [Creating a cluster with kubeadm](https://v1-27.docs.kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/)
- [CRI-O Installation Instructions - Ubuntu](https://github.com/cri-o/cri-o/blob/main/install.md#apt-based-operating-systems)
