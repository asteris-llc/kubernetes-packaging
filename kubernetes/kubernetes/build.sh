set -ex

## create an installation
REF=a1e79e91b9fb6a75b8e631f91e622781cdb1f63a
INSTALL={{.BuildRoot}}/out
mkdir $INSTALL

cd {{.BuildRoot}}

# Fetch a branch with working consul-integration
git clone -q -b consul-integration --single-branch https://github.com/MustWin/kubernetes.git
cd kubernetes
git reset --hard $REF

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
cd {{.BuildRoot}}/kubernetes
pushd ./cluster/images/hyperkube/

# hack to workaround sed syntax fixed in https://github.com/kubernetes/kubernetes/commit/cb11324cc32ffc58c022daef3278a0810c675778
sed -i "s/sed -i \"\"/sed -i/g" Makefile

ARCH=amd64 REGISTRY="ciscocloud" make VERSION=v{{.Version}} || echo "hypercube build failed" && sleep 1
popd

pushd ./cluster/addons/dns/kube2consul/
# prevent `cannot enable tty mode on non tty input` when running under hammer
sed -i "s/docker run -it/docker run -i/g" Makefile
ARCH=amd64 REGISTRY="ciscocloud" TAG=v{{.Version}} make || echo "kube2consul build failed" && sleep 1
popd

sudo rm -rf _output
