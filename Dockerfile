FROM ubuntu:xenial

ARG repo="xenial"
ARG repo_url="localhost"
ARG maintainer_name="maintainer"
ARG maintainer_email="$maintainer_name@$repo_url"
ARG repo_label="Private repo"
ARG git_user=$maintainer_name
ARG git_passwd="12345"
ARG repo_user=$git_user
ARG repo_passwd=$git_passwd

ENV ARCH=arm64
ENV BBUSER=$git_user
ENV BBPASS=$git_passwd
ENV MNT_NAME="$maintainer_name"
ENV MNT_EMAIL="$maintainer_email"
ENV REPO_LABEL="$repo_label"
ENV REPO=$repo
ENV REPO_URL=$repo_url
ENV REPO_USER=$repo_user
ENV REPO_PASS=$repo_passwd

ENV HTMLDIR="/var/www/html"
ENV REPODIR="/srv/reprepro"
ENV CERTDIR="/sslcerts"
ENV GITDIR=/git
ENV PKGDIR=/packages
ENV OUTDIR=/output

ADD sources /etc/apt/sources.list.d/
RUN apt-get update
RUN apt-get install -y apt-utils
RUN dpkg --add-architecture arm64
RUN dpkg --add-architecture armhf
RUN apt-get install -y libc6-arm64-cross libc6-dev-arm64-cross
RUN apt-get install -y binutils-aarch64-linux-gnu gcc-aarch64-linux-gnu g++-aarch64-linux-gnu
RUN apt-get install -y libc6-armhf-cross libc6-dev-armhf-cross
RUN apt-get install -y binutils-arm-linux-gnueabihf gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf
RUN apt-get install -y cmake devscripts gnupg reprepro debhelper
RUN apt-get install -y nginx apache2-utils software-properties-common
RUN apt-get install -y wget git

RUN mkdir -p ${GITDIR}
RUN mkdir -p ${PKGDIR}
RUN mkdir -p ${OUTDIR}
RUN mkdir -p ${REPODIR}
RUN mkdir -p ${CERTDIR}
RUN mkdir -p /scripts/src-packages

ADD scripts/buildpackages.sh /scripts/buildpackages.sh
ADD scripts/installpackages.sh /scripts/installpackages.sh
ADD scripts/preparerepo.sh /scripts/preparerepo.sh
ADD scripts/prepareweb.sh /scripts/prepareweb.sh
ADD scripts/src-packages /scripts/src-packages
ADD packages /packages/

RUN mkdir -p /pgp_keys
ADD pgp_keys /pgp_keys
RUN for KEY in /pgp_keys/*; do gpg --import ${KEY}; done

RUN /scripts/preparerepo.sh
RUN /scripts/prepareweb.sh

RUN [ -d "${HTMLDIR}" ] && rm -r "${HTMLDIR}"
RUN [ -h "${HTMLDIR}" ] || ln -s "${REPODIR}" "${HTMLDIR}"
RUN htpasswd -bc /etc/nginx/.httppassword ${REPO_USER} ${REPO_PASS}

RUN for SCRIPT in /scripts/src-packages/*.sh; do /bin/bash ${SCRIPT}; done
RUN /scripts/buildpackages.sh
RUN /scripts/installpackages.sh

ADD /scripts/entrypoint.sh /entrypoint.sh

ADD /files ${HTMLDIR}/files

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 80
EXPOSE 443
