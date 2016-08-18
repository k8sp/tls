package main

import (
	"crypto/tls"
	"crypto/x509"
	"flag"
	"io"
	"io/ioutil"
	"log"
	"net/http"
	"os"
)

func main() {
	flagCrt := flag.String("cert", "server.crt", "TLS certificate file.")
	flagUrl := flag.String("url", "https://localhost", "URL to be accessed.")
	flag.Parse()

	c := &http.Client{
		Transport: &http.Transport{
			TLSClientConfig: &tls.Config{RootCAs: loadCA(*flagCrt)},
		}}

	if resp, e := c.Get(*flagUrl); e != nil {
		log.Fatal("http.Client.Get: ", e)
	} else {
		defer resp.Body.Close()
		io.Copy(os.Stdout, resp.Body)
	}
}

func loadCA(caFile string) *x509.CertPool {
	pool := x509.NewCertPool()

	if ca, e := ioutil.ReadFile(caFile); e != nil {
		log.Fatal("ReadFile: ", e)
	} else {
		pool.AppendCertsFromPEM(ca)
	}
	return pool
}
