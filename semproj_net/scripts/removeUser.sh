export FABRIC_CA_CLIENT_HOME=../crypto-config/peerOrganizations/org$1.example.com/

echo
echo "Revoke user certificate"
echo
set -x
fabric-ca-client revoke --caname ca-org$1 -e User$2  --tls.certfiles ${PWD}/../crypto-config/fabric-ca/org$1/tls-cert.pem
set +x
