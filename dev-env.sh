#!/bin/bash
set -euo pipefail

# Set required variables
DIR=$(pwd)
DEV_ENV_DIR="/root/contrail-dev-env"
DOCKER=contrail-developer-sandbox
BRANCH=master
BLUE='\033[0;34m'
NC='\033[0m'

function pp(){
  echo ""
  echo -e "${BLUE}$1${NC}"
  echo ""
}

# Get the latest dev sandbox
pp "Fetching and running container opencontrailnightly/developer-sandbox:master"
docker run --privileged --name $DOCKER --restart "always" \
  -w /root/contrail -itd \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $DIR/contrail:/root/contrail \
  -v $DIR/contrail-dev-env:/root/contrail-dev-env \
  -v $HOME/.gitconfig:/root/.gitconfig \
  opencontrailnightly/developer-sandbox:master

# Add a few aliases
pp "Adding a few aliases"
FILE=~/.bash_profile

LINE="alias repo='docker exec $DOCKER repo'"
grep -qF -- "$LINE" "$FILE" || echo "$LINE" >>"$FILE"

LINE="alias scons='docker exec $DOCKER scons'"
grep -qF -- "$LINE" "$FILE" || echo "$LINE" >>"$FILE"

LINE="alias dev-sb='docker exec $DOCKER '"
grep -qF -- "$LINE" "$FILE" || echo "$LINE" >>"$FILE"

function dev_sb() {
  docker exec $DOCKER $@
}

# Clone dev setup repo
if [ ! -d contrail-dev-env/.git ]; then
  pp "Cloning the contrail-dev-env repo"
  git clone https://github.com/Juniper/contrail-dev-env
  cd contrail-dev-env
else
  pp "contrail-dev-env repo already exists. Pulling latest changes."
  cd contrail-dev-env
  git pull
fi

# Start the three required containers
pp "Running script to start containers. Requires entering sudo password"
sudo ./startup.sh -t $BRANCH

# Init and sync the repo
pp "Running repo init"
dev_sb repo init --no-clone-bundle -u https://github.com/Juniper/contrail-vnc -b $BRANCH
pp "Syncing contrail-packages and contrail-third-party"
dev_sb repo sync --no-clone-bundle contrail-packages contrail-third-party

# Start the three required containers
pp "Running script to start containers. Requires entering sudo password"
sudo ./startup.sh -t $BRANCH

# Get the latest code
pp "Fetching latest code"
dev_sb make -f $DEV_ENV_DIR/Makefile sync

# Get third party dependencies
pp "Fetching and patching third party dependencies"
dev_sb make -f $DEV_ENV_DIR/Makefile fetch_packages

# Setup the container
pp "Setting up the docker container"
dev_sb make -f $DEV_ENV_DIR/Makefile setup

# Install build dependencies
pp "Installing build dependencies"
dev_sb make -f $DEV_ENV_DIR/Makefile dep
