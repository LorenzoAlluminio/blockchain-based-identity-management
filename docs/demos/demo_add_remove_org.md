# Demo on organization addition and removal of an organization

1. Run the script `./eyfn.sh`, which will add the org's peers to the channel and install the chaincodes on them. If you add the new org, it is recommended to interact with the network using a different cli, Org6cli. To access this cli, run the command `docker exec -it Org6cli bash`.  
You should also add at least one of the new peers to PEER_STRING:  

    ```bash
    PEER_STRING="--peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt --peerAddresses peer0.org3.example.com:11051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt --peerAddresses peer0.org4.example.com:13051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org4.example.com/peers/peer0.org4.example.com/tls/ca.crt --peerAddresses peer0.org5.example.com:15051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org5.example.com/peers/peer0.org5.example.com/tls/ca.crt --peerAddresses peer0.org6.example.com:17051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org6.example.com/peers/peer0.org6.example.com/tls/ca.crt"
    ORD_STRING="--tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org6.example.com/orderers/orderer.org6.example.com/msp/tlscacerts/tlsca.org6.example.com-cert.pem"
    ``` 
    
    The script will add the new peer org and also the corresponding orderer org (OrdererOrg6). A way of verifying that the new ordering node is working is to open its logs (run the command `docker logs orderer.org6.example.com -f`), invoke a chaincode and check that it is actually writing the new blocks to the ledger.
   
2. Impersonate Anna or Bob by setting this variables
```bash
CORE_PEER_LOCALMSPID="GlobalMSP"
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/global.example.com/users/Anna@global.example.com/msp
```

3. Now you can interact with Hyperledger through the order of organization  6:
```bash
peer chaincode <query/invoke> -o orderer.org6.example.com:12050 $ORD_STRING -C mychannel -n <money/offers/subscriptions> $PEER_STRING -c <params> --waitForEvent
```
    
4.  Whether you did step 1 or not, it is possible to test the removal of one of the orgs (org2.example.com) at runtime; just run the command `docker exec cli ./scripts/org2-remove.sh` from the semproj_net folder. This script will also remove the corresponding orderer org (OrdererOrg2) from both the system and the application channel.

5. Now you can verify that the organization has been remove by trying to interact with Hyperledger through the order of organization 2:
```bash
docker exec -it cli bash
 ORD_STRING="--tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org2.example.com/orderers/orderer.org2.example.com/msp/tlscacerts/tlsca.org2.example.com-cert.pem"
peer chaincode <query/invoke> -o orderer.org2.example.com:8050 $ORD_STRING -C mychannel -n <money/offers/subscriptions> $PEER_STRING -c <params> --waitForEvent
```

6.  When finished, exit the CLI and run `./byfn.sh down` to turn off the network and clean everything. You might still need to run the command `docker volume prune` in case some volumes are not deleted.  
