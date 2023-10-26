#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

cat <<EOF | sudo tee /etc/environment
LANG=en_US.UTF-8
LC_ALL=en_US.UTF-8
EOF

curl -LO "https://dl.k8s.io/release/v.1.27.6/bin/linux/amd64/kubectl.sha256"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >> ~/.bashrc

alias k=kubectl
complete -o default -F __start_kubectl k