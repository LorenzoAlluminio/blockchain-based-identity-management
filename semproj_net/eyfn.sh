#!/bin/bash

# include functions to create crypto material through fabric-ca
. scripts/registerEnroll.sh

# generation of crypto material with cryptogen
#(cd org6-artifacts
#../../bin/cryptogen generate --config=./org6-crypto.yaml
#)

# generation of crypto material with fabric CA
docker-compose -f docker-compose-ca-org6.yaml up -d
sleep 2
cur_uid=$(id -u)
cur_gid=$(id -g)
docker exec ca_org6 sh -c "chown -R $cur_uid:$cur_gid /etc/hyperledger/fabric-ca-server"
docker exec ca_orderer_org6 sh -c "chown -R $cur_uid:$cur_gid /etc/hyperledger/fabric-ca-server"
createOrg 6 12054
createOrderer 6 12055

#cp -r crypto-config/ordererOrganizations org6-artifacts/crypto-config/

(cd org6-artifacts
export FABRIC_CFG_PATH=$PWD
../../bin/configtxgen -printOrg Org6MSP > ../channel-artifacts/org6.json
../../bin/configtxgen -printOrg OrdererOrg6 > ../channel-artifacts/orderer6.json
)

docker exec cli scripts/step1org6.sh

#docker exec cli scripts/add_orderer6.sh

docker-compose -f docker-compose-org6.yaml up -d

sleep 15

docker exec Org6cli ./scripts/step2org6.sh

docker exec Org6cli ./scripts/step1orderer6.sh

docker-compose -f docker-compose-orderer6.yaml up -d

sleep 15

docker exec Org6cli ./scripts/step2orderer6.sh

docker exec Org6cli ./scripts/step3orderer6.sh
