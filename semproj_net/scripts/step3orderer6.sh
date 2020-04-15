#!/bin/bash

ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org1.example.com/orderers/orderer.org1.example.com/tls/server.crt 
CHANNEL_NAME=mychannel

DELAY=3
TIMEOUT=10

setGlobals() {
  CORE_PEER_LOCALMSPID="OrdererMSP$1"
  CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org$1.example.com/orderers/orderer.org$1.example.com/tls/ca.crt
  CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org$1.example.com/users/Admin@org$1.example.com/msp
  PORT=$((7050 + 1000*$(($1 - 1))))
  CORE_PEER_ADDRESS=orderer.org$1.example.com:$PORT
}

setGlobals 1

peer channel fetch config config_block.pb -o orderer.org1.example.com:7050 -c $CHANNEL_NAME --tls --cafile $ORDERER_CA
configtxlator proto_decode --input config_block.pb --type common.Block | jq .data.data[0].payload.data.config > config.json

cat config.json | jq '.channel_group.values.OrdererAddresses.value.addresses += ["orderer.org6.example.com:12050"] ' > modified_config.json

configtxlator proto_encode --input config.json --type common.Config --output config.pb
configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb
configtxlator compute_update --channel_id $CHANNEL_NAME --original config.pb --updated modified_config.pb --output newordorg.pb
configtxlator proto_decode --input newordorg.pb --type common.ConfigUpdate | jq . > newordorg.json
echo '{"payload":{"header":{"channel_header":{"channel_id":"mychannel", "type":2}},"data":{"config_update":'$(cat newordorg.json)'}}}' | jq . > ordorg_update_in_envelope.json
configtxlator proto_encode --input ordorg_update_in_envelope.json --type common.Envelope --output ordorg_update_in_envelope.pb

peer channel signconfigtx -f ordorg_update_in_envelope.pb

setGlobals 6
peer channel signconfigtx -f ordorg_update_in_envelope.pb

setGlobals 2
peer channel signconfigtx -f ordorg_update_in_envelope.pb

setGlobals 3
peer channel update -f ordorg_update_in_envelope.pb -c $CHANNEL_NAME -o orderer.org1.example.com:7050 --tls true --cafile $ORDERER_CA
