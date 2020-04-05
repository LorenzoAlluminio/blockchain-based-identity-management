#!/bin/bash

setGlobals() {
  CORE_PEER_LOCALMSPID="Org$2MSP"
  CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org$2.example.com/peers/peer$1.org$2.example.com/tls/ca.crt
  CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org$2.example.com/users/Admin@org$2.example.com/msp
  PORT=$((7051 + 1000*$(($(($2-1))*2+$1))))
  CORE_PEER_ADDRESS=peer$1.org$2.example.com:$PORT
}

DELAY=3
TIMEOUT=10

export CHANNEL_NAME=mychannel

for i in {1..5}; do
        for j in 0 1; do
                setGlobals $j $i
                PEER_STRING=$PEER_STRING" --peerAddresses ${CORE_PEER_ADDRESS} --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org${i}.example.com/peers/peer${j}.org${i}.example.com/tls/ca.crt"
        done
done

echo $PEER_STRING

# Initialize the chaincodes
peer chaincode invoke -o orderer.org1.example.com:7050 --isInit --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org1.example.com/orderers/orderer.org1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNEL_NAME -n money ${PEER_STRING} -c '{"Args":[]}' --waitForEvent

peer chaincode invoke -o orderer.org1.example.com:7050 --isInit --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org1.example.com/orderers/orderer.org1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNEL_NAME -n offers ${PEER_STRING} -c '{"Args":[]}' --waitForEvent

peer chaincode invoke -o orderer.org1.example.com:7050 --isInit --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org1.example.com/orderers/orderer.org1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNEL_NAME -n subscriptions ${PEER_STRING} -c '{"Args":[]}' --waitForEvent
