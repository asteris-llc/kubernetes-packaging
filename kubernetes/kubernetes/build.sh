set -ex

## create an installation
INSTALL={{.BuildRoot}}/out
mkdir $INSTALL

cd {{.BuildRoot}}
mkdir kubernetes && cd kubernetes

# Fetch a branch with working consul-integration
git init
git remote add -t consul-integration -f origin https://github.com/asteris-llc/kubernetes.git
git checkout consul-integration

# Build all components
# If we are running inside vagrant...
if [ -e /home/vagrant/.gvm/scripts/gvm ] ; then
  source /home/vagrant/.gvm/scripts/gvm
  gvm use go1.6 || echo "Using go1.6"
fi

go get github.com/tools/godep
./hack/install-etcd.sh
./build/run.sh hack/build-go.sh
export PATH=$GOPATH/bin:./third_party/etcd:$PATH || echo "Somethings wrong with export" && sleep 1

ls -l _output/dockerized/bin/*
cp _output/dockerized/bin/linux/amd64/kubelet _output/dockerized/bin/linux/amd64/kubectl $INSTALL

# Build hypercube docker image
cd {{.BuildRoot}}
pushd ./cluster/images/hyperkube/
ARCH=amd64 REGISTRY="ciscocloud" make push VERSION=v{{.Version}} || echo "hypercube push failed" && sleep 1
popd
