#!/bin/bash

### Kubernetes

sudo tee /etc/yum.repos.d/docker.repo <<-'EOF'
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF

sudo yum update -y
sudo yum install -y tar git
sudo yum install -y epel-release
sudo yum update -y systemd
sudo yum install -y docker-engine
sudo groupadd docker
sudo usermod -a -G docker vagrant
sudo usermod -a -G dockerroot vagrant
sudo systemctl enable docker
sudo systemctl start docker

# Install newer go Version
sudo -u vagrant bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer) && \
source /home/vagrant/.gvm/scripts/gvm && \
gvm install go1.4 && \
gvm use go1.4 && \
export GOROOT_BOOTSTRAP=$GOROOT && \
gvm install go1.6

chmod -R +rwx /home/vagrant/.gvm
chown -R vagrant /home/vagrant/.gvm

export GOPATH=/home/vagrant/go/
go get -u github.com/asteris-llc/hammer

sudo sed -i 's/enforcing/disabled/g' /etc/selinux/config /etc/selinux/config
sudo reboot
