package main

import (
	"flag"
	"io"
	"log"
	"net/http"
)

func main() {
	flagCrt := flag.String("cert", "server.crt", "TLS certificate file.")
	flagKey := flag.String("key", "server.key", "TLS key file.")
	flag.Parse()

	http.HandleFunc("/", func(w http.ResponseWriter, req *http.Request) {
		io.WriteString(w, "hello, world!\n")
	})
	if e := http.ListenAndServeTLS(":443", *flagCrt, *flagKey, nil); e != nil {
		log.Fatal("ListenAndServe: ", e)
	}
}
