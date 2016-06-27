#!/bin/bash

### Kubernetes

yum install -y tar git
yum install -y epel-release
yum update -y systemd
yum install -y docker
sudo service docker start
sudo groupadd docker
sudo usermod -a -G docker vagrant
sudo usermod -a -G dockerroot vagrant

# Install newer go Version
sudo -u vagrant bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer) && \
source /home/vagrant/.gvm/scripts/gvm && \
gvm install go1.4 && \
gvm use go1.4 && \
export GOROOT_BOOTSTRAP=$GOROOT && \
gvm install go1.6

chmod -R +rwx /home/vagrant/.gvm
chown -R vagrant /home/vagrant/.gvm
