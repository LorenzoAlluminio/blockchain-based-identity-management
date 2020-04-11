#!/bin/bash

(cd org6-artifacts
../../bin/cryptogen generate --config=./org6-crypto.yaml
)

cp -r crypto-config/ordererOrganizations org6-artifacts/crypto-config/

(cd org6-artifacts
export FABRIC_CFG_PATH=$PWD
../../bin/configtxgen -printOrg Org6MSP > ../channel-artifacts/org6.json
)

docker exec cli scripts/step1org6.sh

docker-compose -f docker-compose-org6.yaml up -d

sleep 15

docker exec Org6cli ./scripts/step2org6.sh
