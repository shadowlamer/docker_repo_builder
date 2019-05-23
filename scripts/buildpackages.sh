#!/bin/bash

find ${PKGDIR} -maxdepth 1 -mindepth 1 -path "./.*" -prune -o -type d -printf '%P\n'|\
while read PACKAGE; do
  [ -f "${PKGDIR}/${PACKAGE}/DEBIAN/control" ] || break

  eval $(while read a b; do ( [ "$a" = "Architecture:" ] && echo -n "ARCH=$b;" ) || ( [ "$a" = "Version:" ] && echo -n "VERSION=$b;" ); done < "${PKGDIR}/${PACKAGE}/DEBIAN/control")

  echo Found package ${PACKAGE} Version: ${VERSION} Arch: ${ARCH}
  echo Preparing md5sums in $PACKAGE/DEBIAN/md5sums

  find "${PKGDIR}/${PACKAGE}" -path '*/DEBIAN' -prune -o -type f -exec md5sum {} \; | awk 'sub(/\.\/[^\/]+/,"",$2){ print $1, $2 }' > ${PKGDIR}/$PACKAGE/DEBIAN/md5sums

  fakeroot dpkg-deb --build ${PKGDIR}/$PACKAGE
  mv "${PKGDIR}/${PACKAGE}.deb" "${OUTDIR}/${PACKAGE}_${VERSION}_${ARCH}.deb"
done
