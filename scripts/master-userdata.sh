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