createOrg(){
  echo
	echo "Enroll the CA admin"
  echo
	mkdir -p crypto-config/peerOrganizations/org$1.example.com/

	export FABRIC_CA_CLIENT_HOME=${PWD}/crypto-config/peerOrganizations/org$1.example.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:$2 --caname ca-org$1 --tls.certfiles ${PWD}/crypto-config/fabric-ca/org$1/tls-cert.pem
  set +x

  echo "NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-$2-ca-org$1.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-$2-ca-org$1.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-$2-ca-org$1.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-$2-ca-org$1.pem
    OrganizationalUnitIdentifier: orderer" > ${PWD}/crypto-config/peerOrganizations/org$1.example.com/msp/config.yaml

  echo
	echo "Register peer0"
  echo
  set -x
	fabric-ca-client register --caname ca-org$1 --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/crypto-config/fabric-ca/org$1/tls-cert.pem
  set +x

  echo
  echo "Register peer1"
  echo
  set -x
  fabric-ca-client register --caname ca-org$1 --id.name peer1 --id.secret peer1pw --id.type peer --tls.certfiles ${PWD}/crypto-config/fabric-ca/org$1/tls-cert.pem
  set +x

  echo
  echo "Register user"
  echo
  set -x
  fabric-ca-client register --caname ca-org$1 --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/crypto-config/fabric-ca/org$1/tls-cert.pem
  set +x

  echo
  echo "Register the org admin"
  echo
  set -x
  fabric-ca-client register --caname ca-org$1 --id.name org$1admin --id.secret org$1adminpw --id.type admin --tls.certfiles ${PWD}/crypto-config/fabric-ca/org$1/tls-cert.pem
  set +x

  # peer0 stuff

	mkdir -p crypto-config/peerOrganizations/org$1.example.com/peers
  mkdir -p crypto-config/peerOrganizations/org$1.example.com/peers/peer0.org$1.example.com

  echo
  echo "## Generate the peer0 msp"
  echo
  set -x
	fabric-ca-client enroll -u https://peer0:peer0pw@localhost:$2 --caname ca-org$1 -M ${PWD}/crypto-config/peerOrganizations/org$1.example.com/peers/peer0.org$1.example.com/msp --csr.hosts peer0.org$1.example.com --tls.certfiles ${PWD}/crypto-config/fabric-ca/org$1/tls-cert.pem
  set +x

  cp ${PWD}/crypto-config/peerOrganizations/org$1.example.com/msp/config.yaml ${PWD}/crypto-config/peerOrganizations/org$1.example.com/peers/peer0.org$1.example.com/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:$2 --caname ca-org$1 -M ${PWD}/crypto-config/peerOrganizations/org$1.example.com/peers/peer0.org$1.example.com/tls --enrollment.profile tls --csr.hosts peer0.org$1.example.com --csr.hosts localhost --tls.certfiles ${PWD}/crypto-config/fabric-ca/org$1/tls-cert.pem
  set +x

  cp ${PWD}/crypto-config/peerOrganizations/org$1.example.com/peers/peer0.org$1.example.com/tls/tlscacerts/* ${PWD}/crypto-config/peerOrganizations/org$1.example.com/peers/peer0.org$1.example.com/tls/ca.crt
  cp ${PWD}/crypto-config/peerOrganizations/org$1.example.com/peers/peer0.org$1.example.com/tls/signcerts/* ${PWD}/crypto-config/peerOrganizations/org$1.example.com/peers/peer0.org$1.example.com/tls/server.crt
  cp ${PWD}/crypto-config/peerOrganizations/org$1.example.com/peers/peer0.org$1.example.com/tls/keystore/* ${PWD}/crypto-config/peerOrganizations/org$1.example.com/peers/peer0.org$1.example.com/tls/server.key

  mkdir ${PWD}/crypto-config/peerOrganizations/org$1.example.com/msp/tlscacerts
  cp ${PWD}/crypto-config/peerOrganizations/org$1.example.com/peers/peer0.org$1.example.com/tls/tlscacerts/* ${PWD}/crypto-config/peerOrganizations/org$1.example.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/crypto-config/peerOrganizations/org$1.example.com/tlsca
  cp ${PWD}/crypto-config/peerOrganizations/org$1.example.com/peers/peer0.org$1.example.com/tls/tlscacerts/* ${PWD}/crypto-config/peerOrganizations/org$1.example.com/tlsca/tlsca.org$1.example.com-cert.pem

  mkdir ${PWD}/crypto-config/peerOrganizations/org$1.example.com/ca
  cp ${PWD}/crypto-config/peerOrganizations/org$1.example.com/peers/peer0.org$1.example.com/msp/cacerts/* ${PWD}/crypto-config/peerOrganizations/org$1.example.com/ca/ca.org$1.example.com-cert.pem

  # peer1 stuff

  mkdir -p crypto-config/peerOrganizations/org$1.example.com/peers
  mkdir -p crypto-config/peerOrganizations/org$1.example.com/peers/peer1.org$1.example.com

  echo
  echo "## Generate the peer1 msp"
  echo
  set -x
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:$2 --caname ca-org$1 -M ${PWD}/crypto-config/peerOrganizations/org$1.example.com/peers/peer1.org$1.example.com/msp --csr.hosts peer1.org$1.example.com --tls.certfiles ${PWD}/crypto-config/fabric-ca/org$1/tls-cert.pem
  set +x

  cp ${PWD}/crypto-config/peerOrganizations/org$1.example.com/msp/config.yaml ${PWD}/crypto-config/peerOrganizations/org$1.example.com/peers/peer1.org$1.example.com/msp/config.yaml

  echo
  echo "## Generate the peer1-tls certificates"
  echo
  set -x
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:$2 --caname ca-org$1 -M ${PWD}/crypto-config/peerOrganizations/org$1.example.com/peers/peer1.org$1.example.com/tls --enrollment.profile tls --csr.hosts peer1.org$1.example.com --csr.hosts localhost --tls.certfiles ${PWD}/crypto-config/fabric-ca/org$1/tls-cert.pem
  set +x

  cp ${PWD}/crypto-config/peerOrganizations/org$1.example.com/peers/peer1.org$1.example.com/tls/tlscacerts/* ${PWD}/crypto-config/peerOrganizations/org$1.example.com/peers/peer1.org$1.example.com/tls/ca.crt
  cp ${PWD}/crypto-config/peerOrganizations/org$1.example.com/peers/peer1.org$1.example.com/tls/signcerts/* ${PWD}/crypto-config/peerOrganizations/org$1.example.com/peers/peer1.org$1.example.com/tls/server.crt
  cp ${PWD}/crypto-config/peerOrganizations/org$1.example.com/peers/peer1.org$1.example.com/tls/keystore/* ${PWD}/crypto-config/peerOrganizations/org$1.example.com/peers/peer1.org$1.example.com/tls/server.key

  mkdir ${PWD}/crypto-config/peerOrganizations/org$1.example.com/msp/tlscacerts
  cp ${PWD}/crypto-config/peerOrganizations/org$1.example.com/peers/peer1.org$1.example.com/tls/tlscacerts/* ${PWD}/crypto-config/peerOrganizations/org$1.example.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/crypto-config/peerOrganizations/org$1.example.com/tlsca
  cp ${PWD}/crypto-config/peerOrganizations/org$1.example.com/peers/peer1.org$1.example.com/tls/tlscacerts/* ${PWD}/crypto-config/peerOrganizations/org$1.example.com/tlsca/tlsca.org$1.example.com-cert.pem

  mkdir ${PWD}/crypto-config/peerOrganizations/org$1.example.com/ca
  cp ${PWD}/crypto-config/peerOrganizations/org$1.example.com/peers/peer1.org$1.example.com/msp/cacerts/* ${PWD}/crypto-config/peerOrganizations/org$1.example.com/ca/ca.org$1.example.com-cert.pem

  # user stuff

  mkdir -p crypto-config/peerOrganizations/org$1.example.com/users
  mkdir -p crypto-config/peerOrganizations/org$1.example.com/users/User1@org$1.example.com

  echo
  echo "## Generate the user msp"
  echo
  set -x
	fabric-ca-client enroll -u https://user1:user1pw@localhost:$2 --caname ca-org$1 -M ${PWD}/crypto-config/peerOrganizations/org$1.example.com/users/User1@org$1.example.com/msp --tls.certfiles ${PWD}/crypto-config/fabric-ca/org$1/tls-cert.pem
  set +x

  cp ${PWD}/crypto-config/peerOrganizations/org$1.example.com/msp/config.yaml ${PWD}/crypto-config/peerOrganizations/org$1.example.com/users/User1@org$1.example.com/msp/config.yaml

  mkdir -p crypto-config/peerOrganizations/org$1.example.com/users/Admin@org$1.example.com

  echo
  echo "## Generate the org admin msp"
  echo
  set -x
	fabric-ca-client enroll -u https://org$1admin:org$1adminpw@localhost:$2 --caname ca-org$1 -M ${PWD}/crypto-config/peerOrganizations/org$1.example.com/users/Admin@org$1.example.com/msp --tls.certfiles ${PWD}/crypto-config/fabric-ca/org$1/tls-cert.pem
  set +x

  cp ${PWD}/crypto-config/peerOrganizations/org$1.example.com/msp/config.yaml ${PWD}/crypto-config/peerOrganizations/org$1.example.com/users/Admin@org$1.example.com/msp/config.yaml
}

function createOrderer(){

  echo
	echo "Enroll the CA admin"
  echo
	mkdir -p crypto-config/ordererOrganizations/org$1.example.com

	export FABRIC_CA_CLIENT_HOME=${PWD}/crypto-config/ordererOrganizations/org$1.example.com

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:$2 --caname ca-orderer-org$1 --tls.certfiles ${PWD}/crypto-config/fabric-ca/orderer-org$1/tls-cert.pem
  set +x

  echo "NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-$2-ca-orderer-org$1.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-$2-ca-orderer-org$1.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-$2-ca-orderer-org$1.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-$2-ca-orderer-org$1.pem
    OrganizationalUnitIdentifier: orderer" > ${PWD}/crypto-config/ordererOrganizations/org$1.example.com/msp/config.yaml


  echo
	echo "Register orderer"
  echo
  set -x
	fabric-ca-client register --caname ca-orderer-org$1 --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/crypto-config/fabric-ca/orderer-org$1/tls-cert.pem
  set +x

  echo
  echo "Register the orderer admin"
  echo
  set -x
  fabric-ca-client register --caname ca-orderer-org$1 --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles ${PWD}/crypto-config/fabric-ca/orderer-org$1/tls-cert.pem
  set +x

	mkdir -p crypto-config/ordererOrganizations/org$1.example.com/orderers
  mkdir -p crypto-config/ordererOrganizations/org$1.example.com/orderers/org$1.example.com

  mkdir -p crypto-config/ordererOrganizations/org$1.example.com/orderers/orderer.org$1.example.com

  echo
  echo "## Generate the orderer msp"
  echo
  set -x
	fabric-ca-client enroll -u https://orderer:ordererpw@localhost:$2 --caname ca-orderer-org$1 -M ${PWD}/crypto-config/ordererOrganizations/org$1.example.com/orderers/orderer.org$1.example.com/msp --csr.hosts orderer.org$1.example.com --csr.hosts localhost --tls.certfiles ${PWD}/crypto-config/fabric-ca/orderer-org$1/tls-cert.pem
  set +x

  cp ${PWD}/crypto-config/ordererOrganizations/org$1.example.com/msp/config.yaml ${PWD}/crypto-config/ordererOrganizations/org$1.example.com/orderers/orderer.org$1.example.com/msp/config.yaml

  echo
  echo "## Generate the orderer-tls certificates"
  echo
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:$2 --caname ca-orderer-org$1 -M ${PWD}/crypto-config/ordererOrganizations/org$1.example.com/orderers/orderer.org$1.example.com/tls --enrollment.profile tls --csr.hosts orderer.org$1.example.com --csr.hosts localhost --tls.certfiles ${PWD}/crypto-config/fabric-ca/orderer-org$1/tls-cert.pem
  set +x

  cp ${PWD}/crypto-config/ordererOrganizations/org$1.example.com/orderers/orderer.org$1.example.com/tls/tlscacerts/* ${PWD}/crypto-config/ordererOrganizations/org$1.example.com/orderers/orderer.org$1.example.com/tls/ca.crt
  cp ${PWD}/crypto-config/ordererOrganizations/org$1.example.com/orderers/orderer.org$1.example.com/tls/signcerts/* ${PWD}/crypto-config/ordererOrganizations/org$1.example.com/orderers/orderer.org$1.example.com/tls/server.crt
  cp ${PWD}/crypto-config/ordererOrganizations/org$1.example.com/orderers/orderer.org$1.example.com/tls/keystore/* ${PWD}/crypto-config/ordererOrganizations/org$1.example.com/orderers/orderer.org$1.example.com/tls/server.key

  mkdir ${PWD}/crypto-config/ordererOrganizations/org$1.example.com/orderers/orderer.org$1.example.com/msp/tlscacerts
  cp ${PWD}/crypto-config/ordererOrganizations/org$1.example.com/orderers/orderer.org$1.example.com/tls/tlscacerts/* ${PWD}/crypto-config/ordererOrganizations/org$1.example.com/orderers/orderer.org$1.example.com/msp/tlscacerts/tlsca.org1.example.com-cert.pem

  mkdir ${PWD}/crypto-config/ordererOrganizations/org$1.example.com/msp/tlscacerts
  cp ${PWD}/crypto-config/ordererOrganizations/org$1.example.com/orderers/orderer.org$1.example.com/tls/tlscacerts/* ${PWD}/crypto-config/ordererOrganizations/org$1.example.com/msp/tlscacerts/tlsca.org1.example.com-cert.pem

  mkdir -p crypto-config/ordererOrganizations/org$1.example.com/users
  mkdir -p crypto-config/ordererOrganizations/org$1.example.com/users/Admin@org$1.example.com

  echo
  echo "## Generate the admin msp"
  echo
  set -x
	fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:$2 --caname ca-orderer-org$1 -M ${PWD}/crypto-config/ordererOrganizations/org$1.example.com/users/Admin@org$1.example.com/msp --tls.certfiles ${PWD}/crypto-config/fabric-ca/orderer-org$1/tls-cert.pem
  set +x

  cp ${PWD}/crypto-config/ordererOrganizations/org$1.example.com/msp/config.yaml ${PWD}/crypto-config/ordererOrganizations/org$1.example.com/users/Admin@org$1.example.com/msp/config.yaml


}
