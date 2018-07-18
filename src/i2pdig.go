package main

import (
	"crypto/sha256"
	"encoding/base32"
	"encoding/base64"
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"strings"

	"github.com/cryptix/goSam"
)

var verbose bool = false

type digger struct {
	samclient *goSam.Client
	transport *http.Transport
	client    *http.Client

	address string
	samaddr string
	jump    string

	result []byte

	err error
    debug bool
}

func (d *digger) mkUrl() string {
	url := d.jump + "/jump/" + d.address
	Log("i2pdig.go URL", url)
	return url
}

func (d *digger) run() {
	Log("i2pdig.go Querying jump service")
	resp, err := d.client.Get(d.mkUrl())
	if Error(err, "Sent request.") {
	}
	defer resp.Body.Close()
	Log("i2pdig.go Reading response body")
	d.result, d.err = ioutil.ReadAll(resp.Body)
	if Error(d.err, "Read response.") {
	}
	//log.Printf(string(d.result))
	if location := string(resp.Header.Get("Location")); location != "" {
		contents := strings.SplitN(location, "=", 2)
		if len(contents) == 2 {
			hostname := strings.Replace(strings.Replace(strings.Replace(contents[0], "http://", "", -1), "?i2paddresshelper", "", -1), "/", "", -1)
			b64 := contents[1]                                                                                                     //
			raw64, err := base64.NewEncoding("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-~").DecodeString(b64) //.DecodeString(b64)
			if Error(err, "i2pdig.go Base64 Conversion", string(raw64)) {
				hash := sha256.New()
				_, err := hash.Write([]byte(raw64)) //sha256.Sum256(raw64)
				if Error(err, "i2pdig.go Base32 Conversion") {
					b32 := strings.ToLower(strings.Replace(base32.StdEncoding.EncodeToString(hash.Sum(nil)), "=", "", -1)) + ".b32.i2p"
					os.Stderr.WriteString("#i2p Address information for: " + hostname)
					fmt.Println("host=\"" + hostname + "\"")
					fmt.Println("base32=\"" + b32 + "\"")
					fmt.Println("base64=\"" + b64 + "\"")
				}
			}
		} else {
			Log("i2pdig.go Malformed response from jump service.")
		}
	} else {
		Log("i2pdig.go Host not found at this jump service.")
	}
}

func newDigger(samaddr, address, jump string, debug bool) *digger {
	var d digger
	d.address = strings.TrimRight(address, "/")
	Log("i2pdig.go URL:", d.address)
	d.samaddr = strings.TrimRight(samaddr, "/")
	Log("i2pdig.go SAM connection:", d.samaddr)
	d.jump = strings.TrimRight(jump, "/")
	Log("i2pdig.go Jump Service:", d.jump)
	d.samclient, d.err = goSam.NewClientFromOptions(goSam.SetAddr(samaddr), goSam.SetDebug(debug))
	Log("i2pdig.go Setting up transports")
	d.transport = &http.Transport{
		Dial: d.samclient.Dial,
	}
	Log("i2pdig.go Setting up Client")
	d.client = &http.Client{
		CheckRedirect: func(req *http.Request, via []*http.Request) error {
			return http.ErrUseLastResponse
		},
		Transport: d.transport,
	}
	Log("i2pdig.go Client initialized.")
	return &d
}

func main() {
	samString := flag.String("sam", "127.0.0.1:7656",
		"host:port of the SAM bridge")
	samAddrString := flag.String("bridge-addr", "127.0.0.1",
		"host: of the SAM bridge")
	samPortString := flag.String("bridge-port", "7656",
		":port of the SAM bridge")
	debugConnection := flag.Bool("debug", false,
		"Print connection debug info")
	verboseLogging := flag.Bool("verbose", false,
		"Print connection debug info")
	jumpAddress := flag.String("jump", "http://lxik2bjgdl7462opwmkzkxsx5gvvptjbtl35rawytkndf2z7okqq.b32.i2p",
		"i2p jump service you want to ask for info")
	getAddress := flag.String("url", "",
		"i2p URL you want to get info about")
	fileOutput := flag.String("file", "",
		"output to file")
	flag.Parse()
	samaddr := *samString
	samhost := *samAddrString
	samport := *samPortString
	address := *getAddress
	if flag.NArg() > 0 {
		if address == "" {
			address = flag.Arg(0)
		}
	}
	if address == "" {
		return
	}
	output := *fileOutput
	jump := *jumpAddress
	var s []string
	if samaddr != "" {
		s = strings.SplitN(samaddr, ":", 2)
		if s[0] != "" {
			samhost = s[0]
		}
		if s[1] != "" {
			samport = s[1]
		}
	}
	samaddr = samhost + ":" + samport
	if output == "" {
		log.SetOutput(os.Stdout)
	} else {
		file, err := os.OpenFile(output, os.O_RDWR|os.O_CREATE, 0755)
		if err != nil {
			log.Fatal("File i/o error", err)
		}
		log.SetOutput(file)
	}
	verbose = *verboseLogging
	shovel := newDigger(samaddr, address, jump, *debugConnection)
	shovel.run()
}

func Log(inp ...string) bool {
	if verbose {
		for _, i := range inp {
			os.Stderr.WriteString(i)
		}
	}
	return true
}

func Error(err error, inp ...string) bool {
	if verbose {
		for _, i := range inp {
			os.Stderr.WriteString(i)
		}
	}
	if err != nil {
		log.Println(inp)
		log.Fatal(err)
		return false
	}
	return true
}
