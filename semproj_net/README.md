# Using the network

1.  Launch the network with `./byfn.sh up`.  The script will load the chaincodes and perform all the setup operations.
If it gives permissions error grant permissions recursively to the chaincode folder like this:
    ```bash
    chmod +R 777 chaincode
    ```   

2.  Enter the CLI with  `docker exec -it cli bash`
3.  Inside the cli, define these two environment variables, which are necessary
    to reach the orderer and the organization peers:
    ```bash
    ORD_STRING="--tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org1.example.com/orderers/orderer.org1.example.com/msp/tlscacerts/tlsca.org1.example.com-cert.pem"
    ```

    ```bash  
    PEER_STRING="--peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt --peerAddresses peer0.org3.example.com:11051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt --peerAddresses peer0.org4.example.com:13051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org4.example.com/peers/peer0.org4.example.com/tls/ca.crt --peerAddresses peer0.org5.example.com:15051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org5.example.com/peers/peer0.org5.example.com/tls/ca.crt"
    ```

4.  Now you can perform query and invoke operations on the ledger with commands of the type:  
    ```bash
    peer chaincode <query/invoke> -o orderer.org1.example.com:7050 $ORD_STRING -C mychannel -n <money/offers/subscriptions> $PEER_STRING -c <params> --waitForEvent
    ```
5.  It is also possible to add a new org org6.example.com at runtime; run the script `./eyfn.sh`, which will add the org's peers to the channel and install the chaincodes on them. If you add the new org, it is recommended to interact with the network using a different cli, Org6cli. To access this cli, run the command `docker exec -it Org6cli bash`.  
You should also add at least one of the new peers to PEER_STRING:  

    ```bash
    PEER_STRING="--peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt --peerAddresses peer0.org3.example.com:11051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt --peerAddresses peer0.org4.example.com:13051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org4.example.com/peers/peer0.org4.example.com/tls/ca.crt --peerAddresses peer0.org5.example.com:15051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org5.example.com/peers/peer0.org5.example.com/tls/ca.crt --peerAddresses peer0.org6.example.com:17051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org6.example.com/peers/peer0.org6.example.com/tls/ca.crt"
    ``` 
    The script will add the new peer org and also the corresponding orderer org (OrdererOrg6). A way of verifying that the new ordering node is working is to open its logs (run the command `docker logs orderer.org6.example.com -f`), invoke a chaincode and check that it is actually writing the new blocks to the ledger.
    
6.  Whether you did step 5 or not, it is possible to test the removal of one of the orgs (org2.example.com) at runtime; just run the command `docker exec cli ./scripts/org2-remove.sh` from the folder containing this file. This script will also remove the corresponding orderer org (OrdererOrg2) from both the system and the application channel.
7.  When finished, exit the CLI and run `./byfn.sh down` to turn off the network and clean everything. You might still need to run the command `docker volume prune` in case some volumes are not deleted.  
