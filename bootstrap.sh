#!/bin/bash

set -e

if [[ "$OSTYPE" == *darwin* ]]
then
  readonly DIR="$(cd "$(dirname $0)" && pwd -P)"
else
  readonly DIR=$(readlink -m $(dirname $0))
fi


main() {
    echo "[bootstrap] link Vagrantfile to project root" && \
        ln -si vagrant/Vagrantfile $DIR/../Vagrantfile
    echo "[bootstrap] link .vagrant to project root" && \
        ln -si vagrant/.vagrant $DIR/../.vagrant &&
        (mkdir vagrant/.vagrant 2>/dev/null || true)
    echo "[bootstrap] create configs and basic hierarchy" && \
        cp -Ri $DIR/vagrant-cfg.dist $DIR/../vagrant-cfg
}

main
