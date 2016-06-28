# Mantl Packaging

This repository contains [Hammer](https://github.com/asteris-llc/hammer) specs
for building generic Mantl utilities.

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-generate-toc again -->
**Table of Contents**

- [Mantl Packaging](#mantl-packaging)
    - [Packages](#packages)
        - [Kubernetes](#kubernetes)
    - [Building](#building)

<!-- markdown-toc end -->

## Packages


### Kubernetes

A script to generate certificates with a number of sensible defaults set.

## Building

If you're on linux, run `hammer` to build all of the packages, which will end up
in `out`. If you're on another platform, run `./build.sh` to fire up a Vagrant
VM that will provision itself with hammer and do the same.

If you add a new package, be sure to run `make scripts/paths` so that it will be
picked up by CI.
