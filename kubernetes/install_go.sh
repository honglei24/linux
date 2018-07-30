#!/bin/bash

# usage: ./install_go.sh 1.10.3
if [ -z "$1" ]; then
        echo "usage: ./install_go.sh <version>"
        exit
fi

version=$1
filename="go${version}.linux-amd64.tar.gz"
[ -f "${filename}" ] || wget https://studygolang.com/dl/golang/${filename}

if [ -d "/usr/local/go" ]; then
        echo "Uninstalling old version..."
        sudo rm -rf /usr/local/go
fi
echo "Installing..."
sudo tar -C /usr/local -xzf ${filename}

echo "add the following to the end of /etc/profile"
echo "export GOPATH=/go
export GOROOT=/usr/local/go
export PATH=\$PATH:\$GOROOT/bin:\$GOPATH/bin"
echo "Done"