#!/bin/bash

CHANNEL_NAME=mychannel
DELAY=3
TIMEOUT=10

ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org1.example.com/orderers/orderer.org1.example.com/msp/tlscacerts/tlsca.org1.example.com-cert.pem

setGlobals() {
  CORE_PEER_LOCALMSPID="Org$2MSP"
  CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org$2.example.com/peers/peer$1.org$2.example.com/tls/ca.crt
  CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org$2.example.com/users/Admin@org$2.example.com/msp
  PORT=$((7051 + 1000*$(($(($2-1))*2+$1))))
  CORE_PEER_ADDRESS=peer$1.org$2.example.com:$PORT
}


# Recover the genesis block which is needed to allow peers to join the channel
peer channel fetch 0 $CHANNEL_NAME.block -o orderer.org1.example.com:7050 -c $CHANNEL_NAME --tls --cafile $ORDERER_CA

# join peer0@org6
peer channel join -b mychannel.block

# join peer1@org6
setGlobals 1 6
peer channel join -b mychannel.block

sleep 10

setGlobals 0 6
peer lifecycle chaincode package money.tar.gz --path /opt/gopath/src/github.com/hyperledger/fabric-samples/chaincode/money --lang golang --label money_1
peer lifecycle chaincode install money.tar.gz

setGlobals 1 6
peer lifecycle chaincode install money.tar.gz

peer lifecycle chaincode queryinstalled >&log.txt
CC_PACKAGE_ID=`sed -n '/Package/{s/^Package ID: //; s/, Label:.*$//; p;}' log.txt | grep money_1`
rm log.txt

peer lifecycle chaincode approveformyorg --channelID $CHANNEL_NAME --name money --version 1.0 --init-required --package-id $CC_PACKAGE_ID --sequence 1 --tls true --cafile $ORDERER_CA

setGlobals 0 6
peer lifecycle chaincode package offers.tar.gz --path /opt/gopath/src/github.com/hyperledger/fabric-samples/chaincode/offers --lang golang --label offers_1
peer lifecycle chaincode install offers.tar.gz

setGlobals 1 6
peer lifecycle chaincode install offers.tar.gz

peer lifecycle chaincode queryinstalled >&log.txt
CC_PACKAGE_ID=`sed -n '/Package/{s/^Package ID: //; s/, Label:.*$//; p;}' log.txt | grep offers_1`
rm log.txt

peer lifecycle chaincode approveformyorg --channelID $CHANNEL_NAME --name offers --version 1.0 --init-required --package-id $CC_PACKAGE_ID --sequence 1 --tls true --cafile $ORDERER_CA

setGlobals 0 6
peer lifecycle chaincode package subscriptions.tar.gz --path /opt/gopath/src/github.com/hyperledger/fabric-samples/chaincode/subscriptions --lang golang --label subscriptions_1
peer lifecycle chaincode install subscriptions.tar.gz

setGlobals 1 6
peer lifecycle chaincode install subscriptions.tar.gz

peer lifecycle chaincode queryinstalled >&log.txt
CC_PACKAGE_ID=`sed -n '/Package/{s/^Package ID: //; s/, Label:.*$//; p;}' log.txt | grep subscriptions_1`
rm log.txt

peer lifecycle chaincode approveformyorg --channelID $CHANNEL_NAME --name subscriptions --version 1.0 --init-required --package-id $CC_PACKAGE_ID --sequence 1 --tls true --cafile $ORDERER_CA

