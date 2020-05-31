export FABRIC_CA_CLIENT_HOME=../crypto-config/peerOrganizations/org$1.example.com/

echo
echo "Register user"
echo
set -x
fabric-ca-client register --caname ca-org$1 --id.name User$3 --id.secret User$3pw --id.type client --tls.certfiles ${PWD}/../crypto-config/fabric-ca/org$1/tls-cert.pem
set +x

mkdir -p ../crypto-config/peerOrganizations/org$1.example.com/users/User$3@org$1.example.com

echo
echo "## Generate the user msp"
echo
set -x
fabric-ca-client enroll -u https://User$3:User$3pw@localhost:$2 --caname ca-org$1 -M ${PWD}/../crypto-config/peerOrganizations/org$1.example.com/users/User$3@org$1.example.com/msp --tls.certfiles ${PWD}/../crypto-config/fabric-ca/org$1/tls-cert.pem
set +x

cp ../crypto-config/peerOrganizations/org$1.example.com/msp/config.yaml ../crypto-config/peerOrganizations/org$1.example.com/users/User$3@org$1.example.com/msp/config.yaml
