# i2pdig

Lookup an i2p hostname, base32, and base64 from the terminal with a user-defined jump service.

This is a simple program which requests a hostname from any existing i2p jump
service(but it's **using my selfhosted one by default for now**, that may
change, I just didn't want to annoy anybody by overusing theirs, and instead of
following the redirect parses the addresshelper URL, derives the base32 address
from the base64 address, and outputs them all to the terminal. Sort of like a
standalone dns resolution program, but for i2p jump hosts.

As an added bonus, you can also do this:

        . <(./bin/i2pdig -url i2pforum.i2p)
        echo "        $base32" | tee -a README.md
        http_proxy="http://127.0.0.1:4444" surf "http://$base32"


and get the output:

        tmipbl5d7ctnz3cib4yd2yivlrssrtpmuuzyqdpqkelzmnqllhda.b32.i2p

and also automatically launch your web browser.

## Installation:

For convenience's sake, the binaries are included in this repository and the
tarball/zip that you can download from Github. In order to install this on most
Unix-Like systems, you can just use:

        make install

or copy the appropriate binary from the bin/ folder for your platform into your
path, or just run it directly from the folder. I built it for a buttload of
platforms because I have a LEDE router that can also run i2pd, who knows what
anybody else has. On that note,

        make native

will attempt to build it for whatever the running platform is.

On Windows, you can just run it from the bin/ folder in the zip, or you can copy
the executable into your path. This is a command-prompt program, so you'll have
to open cmd.exe, then

        dir path\to\unzipped\
        ./bin/i2pdig.exe -url=i2pforum.i2p

Also, there are .debs, or you can make your own with

        make checkinstall

which just runs a pre-configured checkinstall command to generate a deb.
