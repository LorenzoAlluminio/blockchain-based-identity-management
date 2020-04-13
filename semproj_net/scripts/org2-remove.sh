#!/bin/bash

setGlobals() {
  CORE_PEER_LOCALMSPID="Org$2MSP"
  CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org$2.example.com/peers/peer$1.org$2.example.com/tls/ca.crt
  CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org$2.example.com/users/Admin@org$2.example.com/msp
  PORT=$((7051 + 1000*$(($(($2-1))*2+$1))))
  CORE_PEER_ADDRESS=peer$1.org$2.example.com:$PORT
}

CHANNEL_NAME=mychannel
DELAY=3
TIMEOUT=10

ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org1.example.com/orderers/orderer.org1.example.com/msp/tlscacerts/tlsca.org1.example.com-cert.pem


# Extract the latest configuration block from the blockchain
peer channel fetch config config_block.pb -o orderer.org1.example.com:7050 -c $CHANNEL_NAME --tls --cafile $ORDERER_CA

# Decode from protobuf to json and extract relevant data
configtxlator proto_decode --input config_block.pb --type common.Block | jq .data.data[0].payload.data.config > config.json

# Remove data regarding Org2 from the configuration
jq 'del(.channel_group.groups.Application.groups.Org2MSP)' config.json > modified_config.json

# Encode original and modified configuration to protobuf format, then compute the diff
configtxlator proto_encode --input config.json --type common.Config --output config.pb
configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb
configtxlator compute_update --channel_id mychannel --original config.pb --updated modified_config.pb --output update.pb

# Decode the configuration update file to json, add transaction wrapper and encode back to protobuf
configtxlator proto_decode --input update.pb --type common.ConfigUpdate | jq . > update.json
echo '{"payload":{"header":{"channel_header":{"channel_id":"mychannel", "type":2}},"data":{"config_update":'$(cat update.json)'}}}' | jq . > update_in_envelope.json
configtxlator proto_encode --input update_in_envelope.json --type common.Envelope --output update_in_envelope.pb

# Sign the update (majority of organizations is needed)

setGlobals 0 1
peer channel signconfigtx -f update_in_envelope.pb

setGlobals 0 3 
peer channel signconfigtx -f update_in_envelope.pb

setGlobals 0 4
peer channel signconfigtx -f update_in_envelope.pb

# From peer0@org5 send update transaction (and automatically sign)
setGlobals 0 5
peer channel update -f update_in_envelope.pb -c $CHANNEL_NAME -o orderer.org1.example.com:7050 --tls --cafile $ORDERER_CA
