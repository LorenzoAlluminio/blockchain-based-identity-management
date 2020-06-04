# create folder structure
mkdir -p ../crypto-config/peerOrganizations/global.example.com/users/$1@global.example.com/msp/cacerts
mkdir -p ../crypto-config/peerOrganizations/global.example.com/users/$1@global.example.com/msp/keystore
mkdir -p ../crypto-config/peerOrganizations/global.example.com/users/$1@global.example.com/msp/signcerts
mkdir -p ../crypto-config/peerOrganizations/global.example.com/users/$1@global.example.com/msp/user
# copy config file and root certificate
cp ../crypto-config/peerOrganizations/global.example.com/users/Admin@global.example.com/msp/config.yaml ../crypto-config/peerOrganizations/global.example.com/users/$1@global.example.com/msp/
cp ../crypto-config/peerOrganizations/global.example.com/ca/ca.global.example.com-cert.pem ../crypto-config/peerOrganizations/global.example.com/users/$1@global.example.com/msp/cacerts/ca.global.example.com-cert.pem

cd ../../bin
echo "\nGenerate private key:"
set -x
openssl ecparam -name secp256r1 -genkey -noout -out ../semproj_net/crypto-config/peerOrganizations/global.example.com/users/$1@global.example.com/msp/keystore/priv_sk
set +x
echo "\n\ncreates the csr:"
set -x
openssl req -new -key ../semproj_net/crypto-config/peerOrganizations/global.example.com/users/$1@global.example.com/msp/keystore/priv_sk -out ../semproj_net/openssl_stuff/fakeadmincert.csr -subj "/C=US/ST=North Carolina/L=San Francisco/OU=client/CN=$1@global.example.com"
set +x
echo "\n\nsign csr with fake root certificate:"
set -x
openssl x509 -req -in ../semproj_net/openssl_stuff/fakeadmincert.csr -CA ../semproj_net/openssl_stuff/fakerootcert.pem -CAkey ../semproj_net/openssl_perm/privkey_root.pem -CAcreateserial -out ../semproj_net/openssl_stuff/fakeadmincert.pem -days 500 -sha256
set +x
echo "\n\nextract tbs and create message for alice to sign:"
set -x
python3 gen_cert.py ../semproj_net/openssl_stuff/fakeadmincert.pem
set +x

echo "\n\nGenerated fake user certificate:\n"
openssl x509 -in ../semproj_net/openssl_stuff/fakeadmincert.pem -text

echo "\n\nenter to start signing process: "
read stop

# generate input file for signer
cat signer/id-10001-input_base.yaml signer/msg > signer/id-10001-input.yaml
cat signer/id-10002-input_base.yaml signer/msg > signer/id-10002-input.yaml
cat signer/id-10003-input_base.yaml signer/msg > signer/id-10003-input.yaml
cat signer/id-10004-input_base.yaml signer/msg > signer/id-10004-input.yaml
cat signer/id-10005-input_base.yaml signer/msg > signer/id-10005-input.yaml

# sign message
set -x
./alice signer --config signer/id-10001-input.yaml &
set +x
sleep 1
set -x
./alice signer --config signer/id-10002-input.yaml &
set +x
sleep 1
set -x
./alice signer --config signer/id-10003-input.yaml
set +x

sleep 1
echo "\n\nsignature generated. press enter to substitute signature: "
read stop

# parse signature generated by alice
cat signer/id-10001-output.yaml | grep -o "[0-9]*" > signer/signature
# replace signature in root certificate
echo "\n\n signature substitution:\n"
set -x
python3 sign_cert.py ../semproj_net/openssl_stuff/fakeadmincert.pem signer/signature
set +x

cd ../semproj_net/scripts

# convert certificate from der to pem
echo "\n\nconvert certificate from der to pem:"
set -x
openssl x509 -inform der -in ../openssl_stuff/new_cert.der -out ../crypto-config/peerOrganizations/global.example.com/users/$1@global.example.com/msp/signcerts/$1@global.example.com-cert.pem
set +x

echo "\n\nResigned user certificate:\n"
openssl x509 -in ../crypto-config/peerOrganizations/global.example.com/users/$1@global.example.com/msp/signcerts/$1@global.example.com-cert.pem -text