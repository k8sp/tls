# OpenSSL操作指南

## 生成RSA秘钥对

According to [this Gist](https://gist.github.com/denji/12b3a568f092ab951456):

```
openssl genrsa -out server.key 2048
```

The output file is in [PEM format](#pem-file-format):

```
-----BEGIN RSA PRIVATE KEY-----
Proc-Type: 4,ENCRYPTED
DEK-Info: DES-EDE3-CBC,DB98A9512DD7CBCF

yKTM+eoxBvptGrkEixhljqHSuE+ucTh3VqYQsgO6+8Wbh1docbFUKzLKHrferJBH
...
-----END RSA PRIVATE KEY-----
```

The `server.key` contains only the private key. Nothing else there
like the paired public key.

Above command doesn't need passphrase.  By
[this Heroku tutorial](https://devcenter.heroku.com/articles/ssl-endpoint#acquire-ssl-certificate),
the following command need passphrase:

```
openssl genrsa -des3 -out server.key 2048
```

But the passphrase can strip off by using this command:

```
openssl rsa -in server.pass.key -out server.key
```

### Generate Certificate Signing Request

By [this Heroku tutorial](https://devcenter.heroku.com/articles/ssl-certificate-self):

```
openssl req -nodes -new -key server.key -out server.csr
```

This requires input of identification information.

The generated server.csr file is also in PEM format:

```
-----BEGIN CERTIFICATE REQUEST-----
MIIC0TCCAbkCAQAwgYsxCzAJBgNVBAYTAlVTMQswCQYDVQQIEwJDQTERMA8GA1UE
...
-----END CERTIFICATE REQUEST-----
```

According to
[sslshoper.com's page](https://www.sslshopper.com/what-is-a-csr-certificate-signing-request.html),
the CSR contains identification information like the FQDN and the
public key automatically created from the given private key.


### Self-Signed Certificate

According to
[this Heroku tutorial](https://devcenter.heroku.com/articles/ssl-certificate-self),
we can generate a self-signed certificate from the CSR and the private
key:

```
openssl x509 -req -sha256 -days 365 -in server.csr -signkey server.key -out server.crt
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

