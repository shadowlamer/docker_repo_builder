#!/bin/bash

cat << EOF > ${CERTDIR}/config
[req]
distinguished_name = req_distinguished_name
prompt = no
[req_distinguished_name]
C = RU
CN = ${REPO_URL}
emailAddress = ${MNT_EMAIL}
EOF

openssl req -batch -x509 -nodes -days 365 -newkey rsa:2048 -keyout ${CERTDIR}/privkey.pem -out ${CERTDIR}/certificate.pem -config ${CERTDIR}/config

cat << EOF > /etc/nginx/sites-available/default
server {
    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;
    server_name ${REPO_URL};
    location / {
        try_files \$uri \$uri/ =404;
        auth_basic "${REPO_LABEL}";
        auth_basic_user_file /etc/nginx/.httppassword;
	autoindex on;
    }
    listen [::]:443 ssl ipv6only=on;
    listen 443 ssl;
    ssl_certificate ${CERTDIR}/certificate.pem;
    ssl_certificate_key ${CERTDIR}/privkey.pem;
}
EOF
