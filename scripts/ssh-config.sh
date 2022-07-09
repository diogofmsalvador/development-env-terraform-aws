cat << EOF >> ~/.ssh/config

Host ${hostname}
    HostName ${hostname}
    User ${username}
    IdentityFile ${identityfile}
EOF