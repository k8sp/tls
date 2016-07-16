# OpenSSL操作指南

## 生成RSA秘钥对

以下OpenSSL的genrsa<sup>[genrsa](#genrsa)</sup>命令生成一个2048 bit的公钥私
钥对，输出到文件server.key里<sup>[gist](#gist)</sup>：

```
openssl genrsa -out server.key 2048
```

`server.key`是PEM格式<sup>[pem](#pem)</sup>的：

```
-----BEGIN RSA PRIVATE KEY-----
Proc-Type: 4,ENCRYPTED
DEK-Info: DES-EDE3-CBC,DB98A9512DD7CBCF

yKTM+eoxBvptGrkEixhljqHSuE+ucTh3VqYQsgO6+8Wbh1docbFUKzLKHrferJBH
...
-----END RSA PRIVATE KEY-----
```

虽说文件头尾都标注着`RSA PRIVATE KEY`，但实际上这个文件里既包括公钥也
包括私钥<sup>[genrsa](#genrsa)</sup>。


### 生成身份证申请（CSR）

以下OpenSSL的req命令<sup>[req](#req)</sup>以上文中的 `server.key` 为输
入，生成一个 CSR 文件 `server.csr`。

```
openssl req -nodes -new -key server.key -subj "/CN=localhost" -out server.csr
```

这个 CSR 里的域名是 `localhost`，公钥是从 `server.key` 里提取出来的。
`server.csr`文件也是PEM格式的，文件头尾标注为 `CERTIFICATE REQUEST`:

```
-----BEGIN CERTIFICATE REQUEST-----
MIIC0TCCAbkCAQAwgYsxCzAJBgNVBAYTAlVTMQswCQYDVQQIEwJDQTERMA8GA1UE
...
-----END CERTIFICATE REQUEST-----
```


### 签名身份证（Signed Certificate）

以下OpenSSL的x509命令用指定的私钥 `server.key` 签署 `server.csr`，输出身份证 `server.crt`：

```
openssl x509 -req -sha256 -days 365 -in server.csr -signkey server.key -out server.crt
```

在这个例子里，用来签署CSR的私钥和 CSR 里的公钥是一对儿。也就是说这是一
个自签名（self-sign）的例子。

通常情况下，我们会用一个CA的私钥来签署一个CSR。在这个为 Kubernetes
apiserver 签署身份证的例子<sup>[sign](#sign)</sup>里，apiserver 的身份
证是用一个自签署的CA的私钥来签署的：

```
$ openssl genrsa -out ca-key.pem 2048
$ openssl req -x509 -new -nodes -key ca-key.pem -days 10000 -out ca.pem -subj "/CN=kube-ca"

$ openssl genrsa -out apiserver-key.pem 2048
$ openssl req -new -key apiserver-key.pem -out apiserver.csr -subj "/CN=kube-apiserver" -config openssl.cnf
$ openssl x509 -req -in apiserver.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out apiserver.pem -days 365 -extensions v3_req -extfile openssl.cnf
```


[This gist](https://gist.github.com/denji/12b3a568f092ab951456) shows
that we can generate the certificate without the intermediate step of
generating the CSR:

```
openssl req -new -x509 -sha256 -key server.key -out server.crt -days 3650
```

The server.crt file and the server.key file are supposed to be passed
to `http.ListenAndServeTLS` when we run an HTTPS server.  The
server.crt file is also in PEM format:

```
-----BEGIN CERTIFICATE-----
MIIDlDCCAnwCCQDQ1UvQyFD7jDANBgkqhkiG9w0BAQsFADCBizELMAkGA1UEBhMC
...
-----END CERTIFICATE-----
```

I had been long CONFUSED by the very misleading information provided in this 
[document](http://www.techradar.com/us/news/software/how-ssl-and-tls-works-1047412):

> In essence, a digital certificate is the name (usually a domain
> name) and the associated public key encrypted by the CA's private
> key.

In fact, as public keys are "public", they are not suppsoed to be
encrypted.  Instead, the certificate contains the public key in clear
and its *digital signature*.


### PEM File Format

According to this
[namecheap.com's page](https://www.namecheap.com/support/knowledgebase/article.aspx/9474/69/how-do-i-create-a-pem-file-from-the-certificates-i-received-from-you),
PEM file format is defined in X.509.  It is base64 encoded block of
data encapsulated between two lines like:

```
-----BEGIN CERTIFICATE ----- 
-----END CERTIFICATE -----
```

### curl and TLS

`curl -k` allows curl to perform "insecure" SSL connections and transfers.

```
$ sudo go run learn-tls.go
$ /usr/local/Cellar/curl/7.49.1/bin/curl -k https://localhost
hello, world!
```

If we want curl to make secure link, we need to get the cert from the
HTTPS server and use that with curl:

```
$ /usr/local/Cellar/openssl/1.0.2h/bin/openssl s_client -showcerts -connect localhost:443 > cacert.pem
$ curl --cacert cacert.pem https://localhost
hello, world!
```

Two things to note:

1. When we input FQDN in the step
   [Generate Certificate Signing Request](#generate-certificate-signing-request)
   must match the domain name we used to access the server using curl.
   In above case, the FQDN must be `localhost`.

1. Mac OS X comes with an old version `openssl`.  But to work with
   Go's http package, we need to install newer version by using
   Homebrew.


### Root and Additional CAs

This Github Enterprise help
[page](https://help.github.com/enterprise/11.10.340/admin/articles/using-self-signed-ssl-certificates/)
shows that how to create root CA and use it to sign additional CAs.
This CoreOS's Kubernetes Step-by-Step instllation
[guide](https://coreos.com/kubernetes/docs/latest/openssl.html) also
shows how to create a root CA and use it to sign keypairs.


### Using Self-signed Root CA

This excellect Chinese
[post](http://tonybai.com/2015/04/30/go-and-https/) shows how to
program Go HTTPS server and client, both of which use a self-signed CA
to verify each other.

### OpenSSL Essentials

[OpenSSL Essentials](https://www.digitalocean.com/community/tutorials/openssl-essentials-working-with-ssl-certificates-private-keys-and-csrs)
shows various usages of OpenSSL.


### How does "Sign" mean?

This
[article](http://commandlinefanatic.com/cgi-bin/showarticle.cgi?article=art012)
explains that certificate is public key in clear and its digital
signature.

## 参考文献

1. <a name=genrsa>genrsa</a> https://www.openssl.org/docs/manmaster/apps/genrsa.html

1. <a name=gist>gist</a> https://gist.github.com/denji/12b3a568f092ab951456

1. <a name=pem>pem</a> https://www.namecheap.com/support/knowledgebase/article.aspx/9474/69/how-do-i-create-a-pem-file-from-the-certificates-i-received-from-you

1. <a name=req>req</a> https://www.openssl.org/docs/manmaster/apps/req.html

1. <a name=sign>sign</a> https://coreos.com/kubernetes/docs/latest/openssl.html#kubernetes-api-server-keypair
