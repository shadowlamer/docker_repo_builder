#!/bin/bash

PACKAGE="a3voda-dev"
GITURL="https://github.com/shadowlamer/mqtt-client-boilerplate.git"
DEPENDS="libpoco-dev libmosquitto-dev libmosquittopp-dev"
DEPENDS_NOARCH="rapidjson-dev"

git clone -b xenial ${GITURL} ${GITDIR}/${PACKAGE} || exit 0

cd ${GITDIR}/${PACKAGE}
for DEP in $DEPENDS; do echo "${DEP}:${ARCH}"; done| xargs apt-get install -y
apt-get install -y ${DEPENDS_NOARCH}

cmake -DCMAKE_TOOLCHAIN_FILE=cmake_toolchains/ubuntu-${ARCH}.cmake .
make package

dpkg -i ${GITDIR}/${PACKAGE}/${PACKAGE}_*_${ARCH}.deb
mv ${GITDIR}/${PACKAGE}/${PACKAGE}_*_${ARCH}.deb ${OUTDIR}

