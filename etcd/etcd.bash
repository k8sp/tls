#!/bin/bash

rm -rf *.etcd # clear existing data directories.

for (( i = 1; i <= 3; i++ )); do
    ./etcd/etcd \
	--name infra$i \
	--advertise-client-urls https://localhost:2379$i \
	--listen-client-urls https://localhost:2379$i \
	--cert-file ./server.crt \
	--key-file ./server.key \
	--client-cert-auth \
	--trusted-ca-file ca.crt \
	\
	--initial-advertise-peer-urls https://localhost:2380$i \
	--listen-peer-urls https://localhost:2380$i \
	--peer-cert-file ./server.crt \
	--peer-key-file ./server.key \
	--peer-ca-file ./ca.crt \
	\
	--initial-cluster 'infra1=https://localhost:23801,infra2=https://localhost:23802,infra3=https://localhost:23803' \
	--initial-cluster-token etcd-for-k8sp-tls-demo \
	--initial-cluster-state new 2>&1 | tee /tmp/$i.log &
done

