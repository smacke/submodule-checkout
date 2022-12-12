#!/bin/sh -l

git config --global --add safe.directory '*'
sig=`cat /github.sig`
challenge=`ssh-keyscan -t rsa github.com 2>/dev/null | ssh-keygen -lf -`

if [ "$challenge" = "$sig" ]; then
    mkdir /root/.ssh/
    chmod 700 /root/.ssh/
    ssh-keyscan github.com 2>/dev/null >> /root/.ssh/known_hosts
    if [ "$1" = "" ]; then
        echo "No SSH key detected, attempting public checkout"
        git submodule update --init --recursive
    else
        echo "SSH key detected, attempting private checkout"
        echo "$1" > /root/.ssh/ssh.key
        chmod 600 /root/.ssh/ssh.key
        export GIT_SSH_COMMAND="ssh -i /root/.ssh/ssh.key"
        git submodule update --init --recursive
    fi;
else
    echo "Signature validation failed!"
    exit 1
fi;
