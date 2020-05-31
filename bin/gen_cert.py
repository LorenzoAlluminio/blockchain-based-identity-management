from pyasn1_modules import pem, rfc2437, rfc2459
from pyasn1.codec.der import decoder, encoder
from hashlib import sha256
import os
import binascii
import argparse
import sys
import base64

#Usage: name_certificate.pem [key_filename]

root = False
if(len(sys.argv) > 2):
    root = True

#Extract the certificate
substrate = pem.readPemFromFile(open(sys.argv[1]))
certType = rfc2459.Certificate()
cert = decoder.decode(substrate, asn1Spec = certType)[0]
tbs = cert.getComponentByName("tbsCertificate") # Dump the TBS

if(root):
    # If the root certificate we have to change the public key with the one prodused by dkg funcionality
    f = open(sys.argv[2],"r")
    x = int(f.readline())
    y = int(f.readline())
    tbs['subjectPublicKeyInfo']['subjectPublicKey'] = format("0x%02x" % 0x04) + format("%064x" %  x) + format("%064x" %  y)
    f = open(sys.argv[1][:-4]+".der", "wb")
    cert.setComponentByName("tbsCertificate",tbs)
    f.write(encoder.encode(cert))
    f.close()

hash = sha256(encoder.encode(tbs))
res = hash.digest()
f = open("signer/msg","w")
f.write("msg: \"" + base64.b64encode(res).decode()+ "\"")
f.close()
