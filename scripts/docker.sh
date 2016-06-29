#!/bin/bash

set -ex

cat scripts/images
docker images

while read image; do
    docker images | grep "$image" | awk '{printf "%s:%s\n", $1, $2}' | xargs -r -n1 docker push
done < scripts/images
