from pyasn1_modules import pem, rfc2437, rfc2459
from pyasn1.codec.der import decoder, encoder
from hashlib import sha256
import os
import binascii
import argparse
import sys


#Usage: name_certificate.pem [key_filename]

root = False
if(sys.argc > 2):
    root = True

#Extract the certificate
substrate = pem.readPemFromFile(open(argv[1]))
certType = rfc2459.Certificate()
cert = decoder.decode(substrate, asn1Spec = certType)[0]
tbs = cert.getComponentByName("tbsCertificate") # Dump the TBS

if(root):
    # If the root certificate we have to change the public key with the one prodused by dkg funcionality
    f = open("dkg/pk","r")
    x = atoi(f.readline())
    y = atoi(f.readline())
    tbs['subjectPublicKeyInfo']['subjectPublicKey'] = format("0x%02x" % 0x04) + format("0x%064x" %  hex(x)) + format("0x%064x" %  hex(y))
    f = open("root.der", "wb")
    f.write(encoder.encode(tbs))
    f.close()

hash = hashlib.sha256()
hash.update(tbs)
res = hash.digest()
f = open("signer/msg","w")
f.write("msg: \"" + base64.b64encode(res)+ "\"")
f.close()
