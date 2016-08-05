set -ex

## create an installation
REF=910d00e24093d4dbdf5afd1ef9b696da4c658bbe
BRANCH=consul-1.3.3
INSTALL={{.BuildRoot}}/out
mkdir $INSTALL

cd {{.BuildRoot}}

# Fetch a branch with working consul-integration
git clone -q -b $BRANCH --single-branch https://github.com/MustWin/kubernetes.git
cd kubernetes
git reset --hard $REF

# setup go environment if we are running inside vagrant...
if [ -e /home/vagrant/.gvm/scripts/gvm ] ; then
  source /home/vagrant/.gvm/scripts/gvm
  gvm use go1.6 || echo "Using go1.6"
fi

# generate kube version file
export KUBE_GIT_MAJOR='1'
export KUBE_GIT_MINOR='3'
export KUBE_GIT_PATCH='3'
cat > ./kube-version <<EOF
KUBE_GIT_COMMIT='$REF'
KUBE_GIT_TREE_STATE='clean'
KUBE_GIT_VERSION='v$KUBE_GIT_MAJOR.$KUBE_GIT_MINOR.$KUBE_GIT_PATCH'
KUBE_GIT_MAJOR='$KUBE_GIT_MAJOR'
KUBE_GIT_MINOR='$KUBE_GIT_MINOR'
EOF
export KUBE_GIT_VERSION_FILE=./kube-version

# Build all components
go get github.com/tools/godep
./hack/install-etcd.sh
# dockerized build is broken in this release
# see https://github.com/kubernetes/kubernetes/pull/28903/files
# ./build/run.sh make
# we will build locally and then move binaries so that we can build the
# hyperkube image
make

export PATH=$GOPATH/bin:./third_party/etcd:$PATH

# hyperkube build is hardcoded to look in dockerized
mkdir -p _output/dockerized/bin
cp -R _output/local/bin/linux _output/dockerized/bin

# copy binaries to install directory
cp _output/dockerized/bin/linux/amd64/kubelet _output/dockerized/bin/linux/amd64/kubectl $INSTALL

# Build hypercube docker image
cd {{.BuildRoot}}/kubernetes
pushd ./cluster/images/hyperkube/
ARCH=amd64 REGISTRY="ciscocloud" make VERSION=v{{.Version}} || echo "hypercube build failed" && sleep 1
popd

sudo rm -rf _output
