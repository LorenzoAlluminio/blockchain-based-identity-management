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

# Extract latest configuration block from the blockchain
peer channel fetch config config_block.pb -o orderer.org1.example.com:7050 -c $CHANNEL_NAME --tls --cafile $ORDERER_CA

# Decode from protobuf format to json and extract the portion which is relevant for the update
configtxlator proto_decode --input config_block.pb --type common.Block | jq .data.data[0].payload.data.config > config.json

# Include Org6 into the configuration
jq -s '.[0] * {"channel_group":{"groups":{"Application":{"groups": {"Org6MSP":.[1]}}}}}' config.json ./channel-artifacts/org6.json > modified_config.json

# Convert original configuration and updated configuration to protobuf format and compute the diff
configtxlator proto_encode --input config.json --type common.Config --output config.pb
configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb
configtxlator compute_update --channel_id $CHANNEL_NAME --original config.pb --updated modified_config.pb --output org6_update.pb

# Reconvert to json in order to add wrapper structure necessary for the update transaction, then convert back to protobuf
configtxlator proto_decode --input org6_update.pb --type common.ConfigUpdate | jq . > org6_update.json
echo '{"payload":{"header":{"channel_header":{"channel_id":"mychannel", "type":2}},"data":{"config_update":'$(cat org6_update.json)'}}}' | jq . > org6_update_in_envelope.json
configtxlator proto_encode --input org6_update_in_envelope.json --type common.Envelope --output org6_update_in_envelope.pb

# Sign the update (majority of organizations must accept it)
for i in {1..4}; do
    setGlobals 0 $i
    peer channel signconfigtx -f org6_update_in_envelope.pb
done

# From peer0@org5 send update transaction (and automatically sign)
setGlobals 0 5
peer channel update -f org6_update_in_envelope.pb -c $CHANNEL_NAME -o orderer.org1.example.com:7050 --tls --cafile $ORDERER_CA
