#!/bin/bash

setGlobals() {
  CORE_PEER_LOCALMSPID="Org$2MSP"
  CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org$2.example.com/peers/peer$1.org$2.example.com/tls/ca.crt
  CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org$2.example.com/users/Admin@org$2.example.com/msp
  PORT=$((7051 + 1000*$(($(($2-1))*2+$1))))
  CORE_PEER_ADDRESS=peer$1.org$2.example.com:$PORT
}

setGlobalsOrderer() {
  CORE_PEER_LOCALMSPID="OrdererMSP$1"
  CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org$1.example.com/orderers/orderer.org$1.example.com/tls/ca.crt
  CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org$1.example.com/users/Admin@org$1.example.com/msp
  PORT=$((7050 + 1000*$(($1 - 1))))
  CORE_PEER_ADDRESS=orderer.org$1.example.com:$PORT
}

CHANNEL_NAME=mychannel
DELAY=3
TIMEOUT=10

ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org1.example.com/orderers/orderer.org1.example.com/msp/tlscacerts/tlsca.org1.example.com-cert.pem

#################################
# Remove peer organization Org2 #
#################################

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

###############################################
# Remove the orderer organization OrdererOrg2 #
###############################################

setGlobalsOrderer 1

peer channel fetch config config_block.pb -o orderer.org1.example.com:7050 -c $CHANNEL_NAME --tls --cafile $ORDERER_CA
configtxlator proto_decode --input config_block.pb --type common.Block | jq .data.data[0].payload.data.config > config.json

cat config.json | jq 'del(.channel_group.values.OrdererAddresses.value.addresses[.channel_group.values.OrdererAddresses.value.addresses | index("orderer.org2.example.com:8050")])' > modified_config.json

configtxlator proto_encode --input config.json --type common.Config --output config.pb
configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb
configtxlator compute_update --channel_id mychannel --original config.pb --updated modified_config.pb --output update.pb
configtxlator proto_decode --input update.pb --type common.ConfigUpdate | jq . > update.json
echo '{"payload":{"header":{"channel_header":{"channel_id":"mychannel", "type":2}},"data":{"config_update":'$(cat update.json)'}}}' | jq . > update_in_envelope.json
configtxlator proto_encode --input update_in_envelope.json --type common.Envelope --output update_in_envelope.pb

peer channel signconfigtx -f update_in_envelope.pb

setGlobalsOrderer 3 
peer channel signconfigtx -f update_in_envelope.pb

setGlobalsOrderer 4
peer channel signconfigtx -f update_in_envelope.pb

setGlobalsOrderer 5
peer channel update -f update_in_envelope.pb -c $CHANNEL_NAME -o orderer.org1.example.com:7050 --tls --cafile $ORDERER_CA


setGlobalsOrderer 1

peer channel fetch config config_block.pb -o orderer.org1.example.com:7050 -c $CHANNEL_NAME --tls --cafile $ORDERER_CA
configtxlator proto_decode --input config_block.pb --type common.Block | jq .data.data[0].payload.data.config > config.json

cat config.json | jq 'del(.channel_group.groups.Orderer.groups.OrdererOrg2)' > config1.json
cert=`base64 ./crypto/ordererOrganizations/org2.example.com/orderers/orderer.org2.example.com/tls/server.crt | sed ':a;N;$!ba;s/\n//g'`
cat config1.json | jq 'del(.channel_group.groups.Orderer.values.ConsensusType.value.metadata.consenters[.channel_group.groups.Orderer.values.ConsensusType.value.metadata.consenters | index({"client_tls_cert": "'$cert'", "host": "orderer.org2.example.com", "port": 8050, "server_tls_cert": "'$cert'"})])' > modified_config.json

configtxlator proto_encode --input config.json --type common.Config --output config.pb
configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb
configtxlator compute_update --channel_id $CHANNEL_NAME --original config.pb --updated modified_config.pb --output newordorg.pb
configtxlator proto_decode --input newordorg.pb --type common.ConfigUpdate | jq . > newordorg.json
echo '{"payload":{"header":{"channel_header":{"channel_id":"mychannel", "type":2}},"data":{"config_update":'$(cat newordorg.json)'}}}' | jq . > ordorg_update_in_envelope.json
configtxlator proto_encode --input ordorg_update_in_envelope.json --type common.Envelope --output ordorg_update_in_envelope.pb

peer channel signconfigtx -f ordorg_update_in_envelope.pb

setGlobalsOrderer 3
peer channel signconfigtx -f ordorg_update_in_envelope.pb

setGlobalsOrderer 4
peer channel signconfigtx -f ordorg_update_in_envelope.pb

setGlobalsOrderer 5
peer channel update -f ordorg_update_in_envelope.pb -c $CHANNEL_NAME -o orderer.org1.example.com:7050 --tls true --cafile $ORDERER_CA


CHANNEL_NAME=byfn-sys-channel

setGlobalsOrderer 1

peer channel fetch config config_block.pb -o orderer.org1.example.com:7050 -c $CHANNEL_NAME --tls --cafile $ORDERER_CA
configtxlator proto_decode --input config_block.pb --type common.Block | jq .data.data[0].payload.data.config > config.json

cat config.json | jq 'del(.channel_group.values.OrdererAddresses.value.addresses[.channel_group.values.OrdererAddresses.value.addresses | index("orderer.org2.example.com:8050")])' > modified_config.json

configtxlator proto_encode --input config.json --type common.Config --output config.pb
configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb
configtxlator compute_update --channel_id byfn-sys-channel --original config.pb --updated modified_config.pb --output update.pb
configtxlator proto_decode --input update.pb --type common.ConfigUpdate | jq . > update.json
echo '{"payload":{"header":{"channel_header":{"channel_id":"byfn-sys-channel", "type":2}},"data":{"config_update":'$(cat update.json)'}}}' | jq . > update_in_envelope.json
configtxlator proto_encode --input update_in_envelope.json --type common.Envelope --output update_in_envelope.pb

peer channel signconfigtx -f update_in_envelope.pb

setGlobalsOrderer 3
peer channel signconfigtx -f update_in_envelope.pb

setGlobalsOrderer 4
peer channel signconfigtx -f update_in_envelope.pb

setGlobalsOrderer 5
peer channel update -f update_in_envelope.pb -c $CHANNEL_NAME -o orderer.org1.example.com:7050 --tls --cafile $ORDERER_CA


setGlobalsOrderer 1

peer channel fetch config config_block.pb -o orderer.org1.example.com:7050 -c $CHANNEL_NAME --tls --cafile $ORDERER_CA
configtxlator proto_decode --input config_block.pb --type common.Block | jq .data.data[0].payload.data.config > config.json

cat config.json | jq 'del(.channel_group.groups.Orderer.groups.OrdererOrg2)' > config1.json
cat config1.json | jq 'del(.channel_group.groups.Application.groups.OrdererMSP2)' > config2.json
cert=`base64 ./crypto/ordererOrganizations/org2.example.com/orderers/orderer.org2.example.com/tls/server.crt | sed ':a;N;$!ba;s/\n//g'`
cat config2.json | jq 'del(.channel_group.groups.Orderer.values.ConsensusType.value.metadata.consenters[.channel_group.groups.Orderer.values.ConsensusType.value.metadata.consenters | index({"client_tls_cert": "'$cert'", "host": "orderer.org2.example.com", "port": 8050, "server_tls_cert": "'$cert'"})])' > modified_config.json

configtxlator proto_encode --input config.json --type common.Config --output config.pb
configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb
configtxlator compute_update --channel_id $CHANNEL_NAME --original config.pb --updated modified_config.pb --output newordorg.pb
configtxlator proto_decode --input newordorg.pb --type common.ConfigUpdate | jq . > newordorg.json
echo '{"payload":{"header":{"channel_header":{"channel_id":"byfn-sys-channel", "type":2}},"data":{"config_update":'$(cat newordorg.json)'}}}' | jq . > ordorg_update_in_envelope.json
configtxlator proto_encode --input ordorg_update_in_envelope.json --type common.Envelope --output ordorg_update_in_envelope.pb

peer channel signconfigtx -f ordorg_update_in_envelope.pb

setGlobalsOrderer 3
peer channel signconfigtx -f ordorg_update_in_envelope.pb

setGlobalsOrderer 4
peer channel signconfigtx -f ordorg_update_in_envelope.pb

setGlobalsOrderer 5
peer channel update -f ordorg_update_in_envelope.pb -c $CHANNEL_NAME -o orderer.org1.example.com:7050 --tls true --cafile $ORDERER_CA
