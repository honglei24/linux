#!/bin/bash

# usage: ./install_etcd.sh 3.2.18 
if [ -z "$1" ]; then
        echo "usage: ./install_etcd.sh <version>"
        exit
fi

version=$1
filename="etcd-v${version}-linux-amd64.tar.gz"
[ -f "${filename}" ] || wget wget https://github.com/coreos/etcd/releases/download/v${version}/etcd-v${version}-linux-amd64.tar.gz

tar -xvf etcd-v${version}-linux-amd64.tar.gz
mv etcd-v${version}-linux-amd64/etcd* /usr/local/bin