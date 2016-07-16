# TLS完全指南

## 为什么要写这篇文章

### TLS很有用

一般来说，大家会觉得 TLS 是典型的系统工程问题，因为通常只有要写 HTTPS
server 的人才会关注。即便很多创业公司，需要在生意初期考虑好网络通信基
础的，也会把关于 TLS 的工作交给少数几个“工程师”去考虑。但是实际上，TLS
和公司的域名相关，和公司打算提供哪些Web 服务相关，是 CEO 或者至少 CTO
应该了解的。

我不是 CEO 也不是 CTO，我是一个干机器学习的。我曾经以为干机器学习的研
究员们一辈子也不需要碰 HTTPS —— 我自己写 demo的时候就写一个 HTTP 服务
就好了。但是时代不一样了，最近二十年机器学习技术的发展，都是围绕着我们
拥有更强大的计算能力而展开的。当我开始琢磨用 Google 开源的的分布式操作
系统 Kubernetes 系统搭建能支持公司各种业务的通用计算机群的时候，发现机
群的安全性是一个关键要素。为了理解安全性，我发现必须深入理解 TLS。

### 现有文章说不明白

我以为那么多创业公司都需要配置 HTTPS 服务，所以我应该很容易找到相关资
料。可是我从2016年7月11日到15日，找到和阅读了近百篇文章（文后附上了其
中有用的一些），但是没有一篇全面覆盖了以下几个方面：TLS 解决的问题，解
决方法，利用的原理，实际操作，到写 HTTP server 和client。

绝大多数文章针对某个具体（配置或者编程或者商业规划）问题，一开口就是专
家的语气给建议，缺少逻辑推导过程，令人不知其所以然，也就不敢信其然。更
要命的是，有很多文章里有错误信息，令人迷惑。

剩下的有用的文章里，有些专注于TLS的原理，甚至加密算法；有些专注于如何
使用 openssl 工具；有些专注于如何写一个 HTTPS server或者client —— 除了
[这篇中文文章](http://tonybai.com/2015/04/30/go-and-https/)，都不能同
时覆盖上述几个方面。而这篇中文文章因为三方面交织，所以比较长，也无法面
面俱到，更偏重于用Go语言写 HTTPS server 和 client。

所以我想写一篇三部分的全面指南，大家可以因为自己需要阅读其中一部分。

## 目录

1. [TLS 解决的问题以及理论基础](./tls.md)
1. OpenSSL 操作指南
1. 用 Go 语言写 HTTPS 程序

<!-- http://www.techradar.com/us/news/software/how-ssl-and-tls-works-1047412 -->
<!-- https://coreos.com/kubernetes/docs/latest/openssl.html -->
<!-- https://devcenter.heroku.com/articles/ssl-certificate-self -->
<!-- https://devcenter.heroku.com/articles/ssl-endpoint#acquire-ssl-certificate -->
<!-- https://gist.github.com/denji/12b3a568f092ab951456 -->
<!-- https://help.github.com/enterprise/11.10.340/admin/articles/using-self-signed-ssl-certificates/ -->
<!-- https://localhost -->
<!-- https://www.namecheap.com/support/knowledgebase/article.aspx/9474/69/how-do-i-create-a-pem-file-from-the-certificates-i-received-from-you -->
<!-- https://www.sslshopper.com/what-is-a-csr-certificate-signing-request.html -->
