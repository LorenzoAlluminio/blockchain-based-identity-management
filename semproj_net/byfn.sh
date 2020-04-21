#!/bin/bash

# include functions to create crypto material through fabric-ca
. scripts/registerEnroll.sh

# Turn off the containers and clean everything
if [ "$1" == "down" ]; then
  if [ -d  org6-artifacts/crypto-config ]; then
    docker-compose -f docker-compose-org6.yaml down --volumes
    rm -rf org6-artifacts/crypto-config
  fi
  docker-compose -f docker-compose-cli.yaml -f docker-compose-etcdraft2.yaml down --volumes --remove-orphans
  docker rm $(docker ps -aq)
  docker volume prune -f
  rm -rf channel-artifacts
  rm -rf crypto-config
  exit 0
fi

# Generate the cryptographic material based on the configuration in crypto-config.yaml
#../bin/cryptogen generate --config=./crypto-config.yaml

# Create dockers for CAs and fix permissions
cur_uid=$(id -u)
cur_gid=$(id -g)
mkdir -p crypto-config/fabric-ca/
docker-compose -f docker-compose-ca.yaml up -d
sleep 10
docker exec ca_org1 sh -c "chown -R $cur_uid:$cur_gid /etc/hyperledger/fabric-ca-server"
docker exec ca_org2 sh -c "chown -R $cur_uid:$cur_gid /etc/hyperledger/fabric-ca-server"
docker exec ca_org3 sh -c "chown -R $cur_uid:$cur_gid /etc/hyperledger/fabric-ca-server"
docker exec ca_org4 sh -c "chown -R $cur_uid:$cur_gid /etc/hyperledger/fabric-ca-server"
docker exec ca_org5 sh -c "chown -R $cur_uid:$cur_gid /etc/hyperledger/fabric-ca-server"
docker exec ca_orderer_org1 sh -c "chown -R $cur_uid:$cur_gid /etc/hyperledger/fabric-ca-server"
docker exec ca_orderer_org2 sh -c "chown -R $cur_uid:$cur_gid /etc/hyperledger/fabric-ca-server"
docker exec ca_orderer_org3 sh -c "chown -R $cur_uid:$cur_gid /etc/hyperledger/fabric-ca-server"
docker exec ca_orderer_org4 sh -c "chown -R $cur_uid:$cur_gid /etc/hyperledger/fabric-ca-server"
docker exec ca_orderer_org5 sh -c "chown -R $cur_uid:$cur_gid /etc/hyperledger/fabric-ca-server"

# Create the crypto material for the 5 organizations
createOrg 1 7054
createOrg 2 8054
createOrg 3 9054
createOrg 4 10054
createOrg 5 11054
createOrderer 1 7055
createOrderer 2 8055
createOrderer 3 9055
createOrderer 4 10055
createOrderer 5 11055

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
