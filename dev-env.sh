#!/bin/bash -ex

DOCKER=contrail-developer-sandbox
BRANCH=master
USER=
DIR=

docker run --privileged --name $DOCKER --restart "always" \
      -w /root/contrail -itd \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -v /Users/$USER$DIR/contrail:/root/contrail \
      -v /Users/$USER$DIR/contrail-dev-env:/root/contrail-dev-env \
      -v /Users/$USER/.gitconfig:/root/.gitconfig \
      opencontrailnightly/developer-sandbox:master


FILE=~/.bash_profile

LINE="alias repo='docker exec $DOCKER repo'"
grep -qF -- "$LINE" "$FILE" || echo "$LINE" >> "$FILE"

LINE="alias scons='docker exec $DOCKER scons'"
grep -qF -- "$LINE" "$FILE" || echo "$LINE" >> "$FILE"

LINE="alias dev-sb='docker exec $DOCKER '"
grep -qF -- "$LINE" "$FILE" || echo "$LINE" >> "$FILE"

function dev_sb() {
  docker exec $DOCKER $@
}
dev_sb repo init --no-clone-bundle -u https://github.com/Juniper/contrail-vnc -b $BRANCH
dev_sb repo sync --no-clone-bundle contrail-packages contrail-third-party
dev_sb make -f tools/packages/Makefile dep
dev_sb python3 third_party/fetch_packages.py
