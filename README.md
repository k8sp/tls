# TLS完全指南

## 目录

1. [TLS和安全通信](./tls.md)
1. [OpenSSL操作指南](./openssl.md)
1. 用 Go 语言写 HTTPS 程序

## 参考文献

- http://www.techradar.com/us/news/software/how-ssl-and-tls-works-1047412
- http://tonybai.com/2015/04/30/go-and-https/
- https://www.ibm.com/support/knowledgecenter/SSB23S_1.1.0.13/gtps7/s7cont.html
- https://coreos.com/kubernetes/docs/latest/openssl.html
- https://devcenter.heroku.com/articles/ssl-certificate-self
- https://devcenter.heroku.com/articles/ssl-endpoint#acquire-ssl-certificate
- https://gist.github.com/denji/12b3a568f092ab951456
- https://help.github.com/enterprise/11.10.340/admin/articles/using-self-signed-ssl-certificates/
- https://www.namecheap.com/support/knowledgebase/article.aspx/9474/69/how-do-i-create-a-pem-file-from-the-certificates-i-received-from-you
- https://www.sslshopper.com/what-is-a-csr-certificate-signing-request.html

## 为什么要写这篇文章

### TLS很有用

一般来说，大家会觉得 TLS 是典型的系统工程问题，通常只有要写 HTTPS
server 的人才会关注。可实际上 TLS 设置和公司的域名相关，和公司打算提供
的 Web 服务相关，是 CEO 或者至少 CTO 应该了解的。

我曾经以为干机器学习的研究员们一辈子也不需要碰 HTTPS —— 写 demo 的话写
一个 HTTP 服务就好了。可是最近二十年来机器学习技术的发展，大都是围绕着
越来越强大的计算能力展开的。当我们开始琢磨用 Kubernetes 搭建能支持公司
各种业务的通用计算机群的时候，发现机群的安全性是一个关键要素。为了理解
安全性，我发现必须深入理解 TLS。

### 现有文章说不明白

我以为应该很容易找到 TLS 的资料，因为那么多大大小小的公司都需要配置
HTTPS 服务。可是我从2016年7月11日到15日，找到和阅读了数十篇相关文章
（部分见[参考文献](#参考文献)），却没有一篇全面覆盖了以下几个方面：

1. TLS 解决的问题和利用的密码学原理，
2. 实践操作，比如用openssl生成秘钥和CSR、签署certificate。配置根证书和
   信任链，
3. 如何写一个 HTTP server 和对应的client。

绝大多数文章针对某个具体（配置或者编程或者商业规划）问题，一开口就是专
家的语气给建议，缺少逻辑推导过程，令人不知其所以然，也就不敢信其然。更
要命的是，有很多文章里有错误信息，令人迷惑。

剩下的有用的文章里，往往对上述三方面问题有所侧重，而不全面。相对全面的
是[这篇中文文章](http://tonybai.com/2015/04/30/go-and-https/)，但也是
偏重于用Go语言写 HTTPS server 和 client。所以我想写一篇三部分的全面指
南，总结这段时间的探索和学习过程。

