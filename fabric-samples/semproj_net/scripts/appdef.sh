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

peer lifecycle chaincode package money.tar.gz --path /opt/gopath/src/github.com/hyperledger/fabric-samples/chaincode/semproj/money --lang golang --label money_1

for i in {1..5}; do
  for j in 0 1; do
    setGlobals $j $i
    peer lifecycle chaincode install money.tar.gz
  done
done

peer lifecycle chaincode queryinstalled >&log.txt
CC_PACKAGE_ID=`sed -n '/Package/{s/^Package ID: //; s/, Label:.*$//; p;}' log.txt | grep money_1`
rm log.txt

PEER_STRING=""

for i in {1..5}; do
	for j in 0 1; do
		setGlobals $j $i
		peer lifecycle chaincode approveformyorg --channelID $CHANNEL_NAME --name money --version 1.0 --init-required --package-id $CC_PACKAGE_ID --sequence 1 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
		PEER_STRING=$PEER_STRING" --peerAddresses ${CORE_PEER_ADDRESS} --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org${i}.example.com/peers/peer${j}.org${i}.example.com/tls/ca.crt"
	done
done

peer lifecycle chaincode commit -o orderer.example.com:7050 --channelID $CHANNEL_NAME --name money --version 1.0 --sequence 1 --init-required --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem $PEER_STRING

peer lifecycle chaincode package offers.tar.gz --path /opt/gopath/src/github.com/hyperledger/fabric-samples/chaincode/semproj/offers --lang golang --label offers_1

for i in {1..5}; do
  for j in 0 1; do
    setGlobals $j $i
    peer lifecycle chaincode install offers.tar.gz
  done
done

peer lifecycle chaincode queryinstalled >&log.txt
CC_PACKAGE_ID=`sed -n '/Package/{s/^Package ID: //; s/, Label:.*$//; p;}' log.txt | grep offers_1`
rm log.txt

PEER_STRING=""

for i in {1..5}; do
	for j in 0 1; do
		setGlobals $j $i
		peer lifecycle chaincode approveformyorg --channelID $CHANNEL_NAME --name offers --version 1.0 --init-required --package-id $CC_PACKAGE_ID --sequence 1 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
		PEER_STRING=$PEER_STRING" --peerAddresses ${CORE_PEER_ADDRESS} --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org${i}.example.com/peers/peer${j}.org${i}.example.com/tls/ca.crt"
	done
done

peer lifecycle chaincode commit -o orderer.example.com:7050 --channelID $CHANNEL_NAME --name offers --version 1.0 --sequence 1 --init-required --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem $PEER_STRING

peer lifecycle chaincode package subscriptions.tar.gz --path /opt/gopath/src/github.com/hyperledger/fabric-samples/chaincode/semproj/subscriptions --lang golang --label subscriptions_1

for i in {1..5}; do
  for j in 0 1; do
    setGlobals $j $i
    peer lifecycle chaincode install subscriptions.tar.gz
  done
done

peer lifecycle chaincode queryinstalled >&log.txt
CC_PACKAGE_ID=`sed -n '/Package/{s/^Package ID: //; s/, Label:.*$//; p;}' log.txt | grep subscriptions_1`
rm log.txt

PEER_STRING=""

for i in {1..5}; do
	for j in 0 1; do
		setGlobals $j $i
		peer lifecycle chaincode approveformyorg --channelID $CHANNEL_NAME --name subscriptions --version 1.0 --init-required --package-id $CC_PACKAGE_ID --sequence 1 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
		PEER_STRING=$PEER_STRING" --peerAddresses ${CORE_PEER_ADDRESS} --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org${i}.example.com/peers/peer${j}.org${i}.example.com/tls/ca.crt"
	done
done

peer lifecycle chaincode commit -o orderer.example.com:7050 --channelID $CHANNEL_NAME --name subscriptions --version 1.0 --sequence 1 --init-required --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem $PEER_STRING

