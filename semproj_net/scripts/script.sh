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

# Create channel from the configuration artifact
peer channel create -o orderer.org1.example.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/channel.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org1.example.com/orderers/orderer.org1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

# For all organizations update channel definition to define anchor peers
for i in {1..5}; do
  for j in 0 1; do
     setGlobals $j $i
     peer channel join -b mychannel.block
  done
  peer channel update -o orderer.org1.example.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/Org${i}MSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org1.example.com/orderers/orderer.org1.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
done
