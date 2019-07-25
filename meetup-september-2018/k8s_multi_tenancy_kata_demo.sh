# Requirements: 
# Ubuntu server 16.04

# Disable any swap partition also in /etc/fstab
sudo swapoff -a

# install Kata containers
ARCH=$(arch)
BRANCH="${BRANCH:-master}"
sudo sh -c "echo 'deb http://download.opensuse.org/repositories/home:/katacontainers:/release/xUbuntu_$(lsb_release -rs)/ /' > /etc/apt/sources.list.d/kata-containers.list"
sudo curl -sL  http://download.opensuse.org/repositories/home:/katacontainers:/release/xUbuntu_$(lsb_release -rs)/Release.key | sudo apt-key add -
sudo -E apt-get update
sudo -E apt-get -y install kata-runtime kata-proxy kata-shim

# containerd

export VERSION=1.2.6
sudo apt-get update
sudo apt-get install libseccomp2
wget https://storage.googleapis.com/cri-containerd-release/cri-containerd-${VERSION}.linux-amd64.tar.gz
sudo tar --no-overwrite-dir -C / -xzf cri-containerd-${VERSION}.linux-amd64.tar.gz
sudo systemctl start containerd

# make sure containerd works
sudo crictl pods
sudo crictl ps -a

# kubelet kubeadm kubectl
sudo apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat << EOT | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOT
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# init the cluster
sudo kubeadm init --ignore-preflight-errors=all --cri-socket /run/containerd/containerd.sock --pod-network-cidr=10.244.0.0/16

#echo "KUBELET_EXTRA_ARGS=--container-runtime=remote --runtime-request-timeout=15m --container-runtime-endpoint=unix:///run/containerd/containerd.sock" > /etc/default/kubelet
#systemctl daemon-reload
#systemctl restart kubelet

# to reset and start over with kubeadm init:
# kubeadm reset --cri-socket /run/containerd/containerd.sock

# as standard user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# add CNI
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# use kata only for untrusted worloads
sudo mkdir -p /etc/containerd/
cat << EOT | sudo tee /etc/containerd/config.toml
[plugins]
    [plugins.cri.containerd]
      [plugins.cri.containerd.untrusted_workload_runtime]
        runtime_type = "io.containerd.runtime.v1.linux"
        runtime_engine = "/usr/bin/kata-runtime"
EOT

sudo systemctl restart containerd

# Create untrusted pod configuration
cat << EOT | tee nginx-untrusted.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-untrusted
  annotations:
    io.kubernetes.cri.untrusted-workload: "true"
spec:
  containers:
  - name: nginx
    image: nginx

EOT

# unless you add nodes, we need to tell the cluster to use the master as a node 
sudo kubectl taint nodes --all node-role.kubernetes.io/master-

kubectl apply -f nginx-untrusted.yaml

# check that it worked, you'll have a QEMU instance for each untrusted pod
kubectl get pods
ps ax | grep qemu

