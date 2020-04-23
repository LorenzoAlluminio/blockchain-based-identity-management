#!/bin/bash

CORE_PEER_ADDRESS=orderer.org1.example.com:7050
CORE_PEER_LOCALMSPID=OrdererMSP1
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org1.example.com/users/Admin@org1.example.com/msp
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org1.example.com/orderers/orderer.org1.example.com/tls/ca.crt
ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org1.example.com/orderers/orderer.org1.example.com/tls/server.crt 
CHANNEL_NAME=byfn-sys-channel

DELAY=3
TIMEOUT=10

# Extract the latest configuration from the system channel and decode to json
peer channel fetch config config_block.pb -o orderer.org1.example.com:7050 -c $CHANNEL_NAME --tls --cafile $ORDERER_CA
configtxlator proto_decode --input config_block.pb --type common.Block | jq .data.data[0].payload.data.config > config.json

# Edit the system channel configuration to include the new orderer organization's MSP
jq -s '.[0] * {"channel_group":{"groups":{"Orderer":{"groups": {"OrdererOrg6":.[1]}}}}}' config.json ./channel-artifacts/orderer6.json > config1.json

jq -s '.[0] * {"channel_group":{"groups":{"Application":{"groups": {"OrdererOrg6":.[1]}}}}}' config1.json ./channel-artifacts/orderer6.json > config2.json
#jq -s '.[0] * {"channel_group":{"groups":{"Consortiums":{"groups":{"SampleConsortium":{"groups": {"Orderer1MSP":.[1]}}}}}}}' config1.json ./channel-artifacts/orderer6.json > config2.json

cert=`base64 ./crypto/ordererOrganizations/org6.example.com/orderers/orderer.org6.example.com/tls/server.crt | sed ':a;N;$!ba;s/\n//g'`

cat config2.json | jq '.channel_group.groups.Orderer.values.ConsensusType.value.metadata.consenters += [{"client_tls_cert": "'$cert'", "host": "orderer.org6.example.com", "port": 12050, "server_tls_cert": "'$cert'"}] ' > modified_config.json

configtxlator proto_encode --input config.json --type common.Config --output config.pb
configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb
configtxlator compute_update --channel_id $CHANNEL_NAME --original config.pb --updated modified_config.pb --output newordorg.pb
configtxlator proto_decode --input newordorg.pb --type common.ConfigUpdate | jq . > newordorg.json
echo '{"payload":{"header":{"channel_header":{"channel_id":"byfn-sys-channel", "type":2}},"data":{"config_update":'$(cat newordorg.json)'}}}' | jq . > ordorg_update_in_envelope.json
configtxlator proto_encode --input ordorg_update_in_envelope.json --type common.Envelope --output ordorg_update_in_envelope.pb

peer channel signconfigtx -f ordorg_update_in_envelope.pb

CORE_PEER_ADDRESS=orderer.org2.example.com:8050
CORE_PEER_LOCALMSPID=OrdererMSP2
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org2.example.com/users/Admin@org2.example.com/msp
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org2.example.com/orderers/orderer.org2.example.com/tls/ca.crt

peer channel signconfigtx -f ordorg_update_in_envelope.pb

CORE_PEER_ADDRESS=orderer.org3.example.com:9050
CORE_PEER_LOCALMSPID=OrdererMSP3
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org3.example.com/users/Admin@org3.example.com/msp
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org3.example.com/orderers/orderer.org3.example.com/tls/ca.crt

peer channel update -f ordorg_update_in_envelope.pb -c $CHANNEL_NAME -o orderer.org1.example.com:7050 --tls true --cafile $ORDERER_CA


CHANNEL_NAME=mychannel

peer channel fetch config config_block.pb -o orderer.org1.example.com:7050 -c $CHANNEL_NAME --tls --cafile $ORDERER_CA
configtxlator proto_decode --input config_block.pb --type common.Block | jq .data.data[0].payload.data.config > config.json

jq -s '.[0] * {"channel_group":{"groups":{"Orderer":{"groups": {"OrdererOrg6":.[1]}}}}}' config.json ./channel-artifacts/orderer6.json > config1.json
cert=`base64 ./crypto/ordererOrganizations/org6.example.com/orderers/orderer.org6.example.com/tls/server.crt | sed ':a;N;$!ba;s/\n//g'`
cat config1.json | jq '.channel_group.groups.Orderer.values.ConsensusType.value.metadata.consenters += [{"client_tls_cert": "'$cert'", "host": "orderer.org6.example.com", "port": 12050, "server_tls_cert": "'$cert'"}] ' > modified_config.json

configtxlator proto_encode --input config.json --type common.Config --output config.pb
configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb
configtxlator compute_update --channel_id $CHANNEL_NAME --original config.pb --updated modified_config.pb --output newordorg.pb
configtxlator proto_decode --input newordorg.pb --type common.ConfigUpdate | jq . > newordorg.json
echo '{"payload":{"header":{"channel_header":{"channel_id":"mychannel", "type":2}},"data":{"config_update":'$(cat newordorg.json)'}}}' | jq . > ordorg_update_in_envelope.json
configtxlator proto_encode --input ordorg_update_in_envelope.json --type common.Envelope --output ordorg_update_in_envelope.pb

peer channel signconfigtx -f ordorg_update_in_envelope.pb

CORE_PEER_ADDRESS=orderer.org2.example.com:8050
CORE_PEER_LOCALMSPID=OrdererMSP2
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org2.example.com/users/Admin@org2.example.com/msp
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org2.example.com/orderers/orderer.org2.example.com/tls/ca.crtbash-5.0# peer channel signconfigtx -f ordorg_update_in_envelope.pb

peer channel signconfigtx -f ordorg_update_in_envelope.pb

CORE_PEER_ADDRESS=orderer.org1.example.com:7050
CORE_PEER_LOCALMSPID=OrdererMSP1
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org1.example.com/users/Admin@org1.example.com/msp
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org1.example.com/orderers/orderer.org1.example.com/tls/ca.crt

peer channel update -f ordorg_update_in_envelope.pb -c $CHANNEL_NAME -o orderer.org1.example.com:7050 --tls true --cafile $ORDERER_CA

# Set latest config block as genesis block for the new orderer, so that it will know of both the system and application channels.
peer channel fetch config ./channel-artifacts/ord6.block -o orderer.org1.example.com:7050 -c byfn-sys-channel --tls --cafile $ORDERER_CA
