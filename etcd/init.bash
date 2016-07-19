#!/bin/bash

#
# Download and unpack etcd.
#
if [[ $(uname) == "Linux" ]]; then
    if [[ ! -f etcd-v3.0.3-linux-amd64.tar.gz ]]; then
	echo "Downloading etcd for Linux ..."
	curl -L https://github.com/coreos/etcd/releases/download/v3.0.3/etcd-v3.0.3-linux-amd64.tar.gz
    fi
    tar xzvf etcd-v3.0.3-linux-amd64.tar.gz
    rm etcd && ln -s etcd-v3.0.3-linux-amd64 etcd
elif [[ $(uname) == "Darwin" ]]; then
    if [[ ! -f etcd-v3.0.3-darwin-amd64.zip ]]; then
	echo "Downloading etcd for Mac OS X ..."
	curl -L https://github.com/coreos/etcd/releases/download/v3.0.3/etcd-v3.0.3-darwin-amd64.zip
    fi
    unzip etcd-v3.0.3-darwin-amd64.zip 
    rm etcd && ln -s etcd-v3.0.3-darwin-amd64 etcd
else
    echo "Unknow OS: " $(uanme)
    exit 1
fi

# 
# Create TLS assets
# 
../bidirectional/create_tls_asserts.bash
