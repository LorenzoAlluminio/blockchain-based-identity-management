#!/bin/bash

# Turn off the containers and clean everything
if [ "$1" == "down" ]; then
  docker-compose -f docker-compose-cli.yaml -f docker-compose-etcdraft2.yaml down --volumes --remove-orphans
  rm -r channel-artifacts
  rm -r crypto-config
  exit 0
fi

# Generate the cryptographic material based on the configuration in crypto-config.yaml
../bin/cryptogen generate --config=./crypto-config.yaml

# Create orderer genesis block, the channel transaction artifact and define anchor peers on the channel based on the configuration in configtxgen.yaml
export FABRIC_CFG_PATH=$PWD
../bin/configtxgen -profile SampleMultiNodeEtcdRaft -channelID byfn-sys-channel -outputBlock ./channel-artifacts/genesis.block
export CHANNEL_NAME=mychannel
../bin/configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID $CHANNEL_NAME

for i in {1..5}; do
  ../bin/configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org${i}MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org${i}MSP
done

# Start the network
docker-compose -f docker-compose-cli.yaml -f docker-compose-etcdraft2.yaml up -d

# Time to allow docker-compose to setup everything
sleep 15

# Scripts to complete network setup including chaincode installation and initialization
docker exec cli scripts/script.sh
docker exec cli scripts/appdef.sh
docker exec cli scripts/init_cc.sh
