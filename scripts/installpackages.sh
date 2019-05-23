#!/bin/bash

cd ${REPODIR}
find ${OUTDIR} -maxdepth 1 -mindepth 1 -name "*.deb" -printf '%P\n'|\
while read NAME; do 
  reprepro includedeb ${REPO} ${OUTDIR}/${NAME}
done
