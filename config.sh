#!/bin/bash

#$1 - param name
#$2 - description
#$3 - default value
function read_param() {
  [ -z "${!1}" ] && echo -n "$2, (\"$3\"): " && read $1 && export $1="${!1:-$3}" && ( echo "export $1=\"${!1}\"" >>  ${SETTINGS} )
}

SETTINGS="./.settings"
PACKAGE="ubuntu_packages"
BUILD_SCRIPT="./build.sh"

[ -f ${SETTINGS} ] && . ${SETTINGS}

read_param REPO             "Название дистрибутива Ubuntu"               "xenial"
read_param REPO_URL         "Имя хоста, где будет развернут репозиторий" "localhost"
read_param REPO_USER        "Логин для защиты репозитория"               "3voda"
read_param REPO_PASSWD      "Пароль для защиты репозитория"              ""
read_param REPO_LABEL       "Описание репозитория"                       "Private repo"
read_param MAINTAINER_NAME  "Имя для генерации GPG ключа"                "maintainer"
read_param MAINTAINER_EMAIL "Email для генерации GPG ключа"              "${MAINTAINER_NAME}@${REPO_URL}"
read_param GIT_USER         "Логин для Git-репозитория"                  ""
read_param GIT_PASSWD       "Пароль для Git-репозитория"                 ""

#make build script
echo docker build '$@' \
--build-arg maintainer_name=\"${MAINTAINER_NAME}\" \
--build-arg maintainer_email=\"${MAINTAINER_EMAIL}\" \
--build-arg git_user=\"${GIT_USER}\" \
--build-arg git_passwd=\"${GIT_PASSWD}\" \
--build-arg repo=\"${REPO}\" \
--build-arg repo_label=\"${REPO_LABEL}\" \
--build-arg repo_url=\"${REPO_URL}\" \
--build-arg repo_user=\"${REPO_USER}\" \
--build-arg repo_passwd=\"${REPO_PASSWD}\" \
-t ${PACKAGE} . > ${BUILD_SCRIPT}
chmod a+x ${BUILD_SCRIPT}

#make app.yml
cat << EOF > ${PACKAGE}.yml
version: '2'
services:
    ubuntu-packages:
        image: ${PACKAGE}
        volumes:
        - /etc/letsencrypt/live/${REPO_URL}/fullchain.pem:/sslcerts/certificate.pem
        - /etc/letsencrypt/live/${REPO_URL}/privkey.pem:/sslcerts/privkey.pem
        ports:
        - 80:80
        - 443:443
EOF

#make certbot.yml
cat << EOF > certbot.yml
version: '2'
services:
    certbot:
        image: certbot/certbot
        ports:
            - 80:80
        volumes:
            - /etc/letsencrypt:/etc/letsencrypt
            - /tmp/certbot-root:/tmp/certbot-root
        command:  certonly --standalone -d ${REPO_URL} -m ${MAINTAINER_EMAIL} --agree-tos --non-interactive
EOF
