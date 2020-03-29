#!/bin/bash

if [ "$1" == "down" ]; then
  docker-compose -f docker-compose-cli.yaml -f docker-compose-etcdraft2.yaml down --volumes --remove-orphans
  rm -r channel-artifacts
  rm -r crypto-config
  exit 0
fi

../bin/cryptogen generate --config=./crypto-config.yaml
export FABRIC_CFG_PATH=$PWD
../bin/configtxgen -profile SampleMultiNodeEtcdRaft -channelID byfn-sys-channel -outputBlock ./channel-artifacts/genesis.block
export CHANNEL_NAME=mychannel
../bin/configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID $CHANNEL_NAME

for i in {1..5}; do
  ../bin/configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org${i}MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org${i}MSP
done

docker-compose -f docker-compose-cli.yaml -f docker-compose-etcdraft2.yaml up -d

sleep 15

docker exec cli scripts/script.sh
docker exec cli scripts/appdef.sh
docker exec cli scripts/init_cc.sh
