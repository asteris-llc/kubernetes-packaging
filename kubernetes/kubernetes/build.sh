set -ex

## create an installation
INSTALL={{.BuildRoot}}/out
mkdir $INSTALL

mkdir kubernetes && cd kubernetes

# Fetch a branch with working consul-integration
git init
git remote add -t consul-integration -f origin https://github.com/asteris-llc/kubernetes.git
git checkout consul-integration

# Build all components
go get github.com/tools/godep
./hack/install-etcd.sh
KUBE_OUTPUT_BINPATH={{.BuildRoot}}/out ./hack/build-go.sh
export PATH=$GOPATH/bin:./third_party/etcd:$PATH || echo "Somethings wrong with export" && sleep 1
ls -la {{.BuildRoot}}/out

# Build hypercube docker image
pushd ./cluster/images/hypercube/
ARCH=amd64 REGISTRY="ciscocloud" make push VERSION=v{{.Version}} || echo "hypercube push failed" && sleep 1
popd
