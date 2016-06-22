set -ex

mkdir kubernetes && cd kubernetes

# Fetch a branch with working consul-integration
git init
git remote add -t consul-integration -f origin https://github.com/asteris-llc/kubernetes.git
git checkout consul-integration

# Build all components
build/run.sh hack/build-cross.sh

# Build hypercube docker image
pushd cluster/images/hypercube
ARCH=amd64 REGISTRY="ciscocloud" make push VERSION=v{{.Version}}
popd

## create an installation
INSTALL={{.BuildRoot}}/out
mkdir $INSTALL
