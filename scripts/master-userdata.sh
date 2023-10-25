#!/bin/bash
#############################
# Script to update hostname #
#############################
set -euo pipefail
IFS=$'\n\t'

AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone/)

# Replace existing localhost4 entry
sed -i 's/localhost4 localhost4.localdomain4//g' /etc/hosts

#Set hostname name
if [[ ${AZ: -1} == a ]]; then
  echo -e "This is node1\n"
  sudo hostnamectl set-hostname master-1a
elif [[ ${AZ: -1} == b ]]; then
  echo -e "This is node2\n"
  sudo hostnamectl set-hostname master-1b
else
  echo -e "This is node3\n"
  sudo hostnamectl set-hostname master-1c
fi

# disable swap
sudo swapoff -a

# keeps the swaf off during reboot
(crontab -l 2>/dev/null; echo "@reboot /sbin/swapoff -a") | crontab - || true
sudo apt-get update -y

## Create the .conf file to load the modules at startup ##
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

## Apply sysctl params without reboot ##
sudo sysctl --system

######################################
# Install packaged versions of CRI-O #
######################################
## This is Operating system version as per above instruction ##
export OS="xUbuntu_22.04"

## This is kubernetes version for which CRI-O will be installed ##
export VERSION="1.27"

cat <<EOF | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
deb [signed-by=/usr/share/keyrings/libcontainers-archive-keyring.gpg] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /
EOF

cat <<EOF | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.list
deb [signed-by=/usr/share/keyrings/libcontainers-crio-archive-keyring.gpg] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/ /
EOF

sudo mkdir -p /usr/share/keyrings

sudo curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | gpg --dearmor -o /usr/share/keyrings/libcontainers-archive-keyring.gpg
sudo curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/Release.key | gpg --dearmor -o /usr/share/keyrings/libcontainers-crio-archive-keyring.gpg

sudo apt-get update
sudo apt-get install cri-o cri-o-runc -y

## Reload systemd manager configuration ##
sudo systemctl daemon-reload

## Enable to start at boot ##
sudo systemctl enable crio --now

## Start crio service ##
systemctl start crio.service

echo "CRI runtime installed successfully"