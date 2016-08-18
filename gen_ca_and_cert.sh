#!/bin/bash

openssl genrsa -out ca.key 2048
openssl req -nodes -new -key ca.key -subj "/CN=bootstrapper" -out ca.csr
openssl x509 -req -sha256 -days 365 -in ca.csr -signkey ca.key -out ca.crt

openssl genrsa -out server.key 2048
openssl req -new -key server.key -out server.csr -subj "/CN=bootstrapper" -config openssl.cnf
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 365 -extensions v3_req -extfile openssl.cnf



