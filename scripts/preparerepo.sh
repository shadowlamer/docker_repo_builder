#!/bin/bash

cat > keyopts << EOF
Key-Type: RSA
Key-Length: 4096
Name-Real: ${MNT_NAME}
Name-Comment: Maintainer
Name-Email: ${MNT_EMAIL}
Expire-Date: 0
%no-protection
%commit
EOF

gpg --list-keys ${MNT_EMAIL} || gpg --batch --gen-key keyopts
gpg --yes --output ${REPODIR}/key.asc --armor --export ${MNT_EMAIL}

KEY_ID=$(gpg --with-colons --list-keys ${MNT_EMAIL} | grep pub | cut -d ':' -f 5)

cd ${REPODIR}
mkdir -p conf dists/${REPO}

cat << EOF > ${REPODIR}/conf/distributions
Origin: ${MNT_EMAIL}
Label: ${REPO_LABEL}
Codename: ${REPO}
Architectures: arm64 armhf
Components: contrib
Description: ${REPO_LABEL}
SignWith: ${KEY_ID}
EOF
