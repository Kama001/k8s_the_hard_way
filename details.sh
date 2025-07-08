cd /home/ubuntu

git clone --depth 1 \
  https://github.com/kelseyhightower/kubernetes-the-hard-way.git

cp kubernetes-the-hard-way/downloads-$(dpkg --print-architecture).txt ./

ARCH=$(dpkg --print-architecture)
cwd=$(pwd)


# download all kubernetes components
mkdir $cwd/downloads
wget -q --show-progress \
  --https-only \
  --timestamping \
  -P $cwd/downloads \
  -i downloads-$(dpkg --print-architecture).txt


# separate downlads into their respective component folders
mkdir -p $cwd/downloads/{client,cni-plugins,controller,worker}
tar -xvf $cwd/downloads/crictl-v1.32.0-linux-${ARCH}.tar.gz \
  -C $cwd/downloads/worker/
tar -xvf $cwd/downloads/containerd-2.1.0-beta.0-linux-${ARCH}.tar.gz \
  --strip-components 1 \
  -C $cwd/downloads/worker/
tar -xvf $cwd/downloads/cni-plugins-linux-${ARCH}-v1.6.2.tgz \
  -C $cwd/downloads/cni-plugins/
tar -xvf $cwd/downloads/etcd-v3.6.0-rc.3-linux-${ARCH}.tar.gz \
  -C $cwd/downloads/ \
  --strip-components 1 \
  etcd-v3.6.0-rc.3-linux-${ARCH}/etcdctl \
  etcd-v3.6.0-rc.3-linux-${ARCH}/etcd
mv $cwd/downloads/{etcdctl,kubectl} $cwd/downloads/client/
mv $cwd/downloads/{etcd,kube-apiserver,kube-controller-manager,kube-scheduler} \
  $cwd/downloads/controller/
mv $cwd/downloads/{kubelet,kube-proxy} $cwd/downloads/worker/
mv $cwd/downloads/runc.${ARCH} $cwd/downloads/worker/runc

rm -rf $cwd/downloads/*gz

# make files executable 
chmod +x $cwd/downloads/{client,cni-plugins,controller,worker}/*

# add kubectl to path
cp $cwd/downloads/client/kubectl /usr/local/bin/

# add cluster details
touch machines.txt

# add following contents. ip should be ec2 ip's
IPV4_ADDRESS FQDN HOSTNAME POD_SUBNET
# XXX.XXX.XXX.XXX server.kubernetes.local server
# XXX.XXX.XXX.XXX node-0.kubernetes.local node-0 10.200.0.0/24
# XXX.XXX.XXX.XXX node-1.kubernetes.local node-1 10.200.1.0/24

####################################
# ssh part didn't worked so skipping
####################################
# permit ssh login as root, so that jump server can execute necessary commands
#execute this in all k8s machines
# sed -i \
#   's/^#*PermitRootLogin.*/PermitRootLogin yes/' \
#   /etc/ssh/sshd_config

# # in ec2 sshd is not running
# systemctl restart ssh

# # generate ssh keys in jumpbox and share pub key to all k8s nodes

# # will generate pub, private key in required dir with req names
# ssh-keygen
# while read IP FQDN HOST SUBNET; do
#   ssh-copy-id -i $(pwd)/k8s.pub root@${IP}  #k8s.pub is given by me
# done < machines.txt

# while read IP FQDN HOST SUBNET; do
#   ssh-copy-id -i $(pwd)/k8s root@${IP}
# done < machines.txt




