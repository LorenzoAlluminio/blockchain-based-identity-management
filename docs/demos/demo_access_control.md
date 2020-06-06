# Demo on certificate-based access control

1.  Run `./byfn.sh` to setup the network and `docker exec -it cli bash`.
2.  Set ORD_STRING and PEER_STRING:
    ```bash
    ORD_STRING="--tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org1.example.com/orderers/orderer.org1.example.com/msp/tlscacerts/tlsca.org1.example.com-cert.pem"
    ```
    ```bash  
    PEER_STRING="--peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt --peerAddresses peer0.org3.example.com:11051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt --peerAddresses peer0.org4.example.com:13051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org4.example.com/peers/peer0.org4.example.com/tls/ca.crt --peerAddresses peer0.org5.example.com:15051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org5.example.com/peers/peer0.org5.example.com/tls/ca.crt"
    ```
    ```bash
    CORE_PEER_LOCALMSPID="GlobalMSP"
    ```
3.  Select Bob by setting the env var  
    ```bash
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/global.example.com/users/Bob@global.example.com/msp
    ```  
4.  Print the user's id with  
    ```bash
    peer chaincode invoke -o orderer.org1.example.com:7050 $ORD_STRING -C mychannel -n offers $PEER_STRING -c '{"Args":["GetUserId"]}' --waitForEvent
    ```  
    and copy it to the env var BOB
5.  Try to create the money account for Bob with  
    ```bash
    peer chaincode invoke -o orderer.org1.example.com:7050 $ORD_STRING -C mychannel -n money $PEER_STRING -c '{"Args":["NewMoneyAccount", '"\"$BOB\""', "0", "2020-04-01T15:00:00Z", "2030-06-01T15:00:00Z"]}' --waitForEvent
    ```
    this opeartion will fail since we are logged as a normal user but this operation require admin privileges.
6.  To became admin use
    ```bash
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/global.example.com/users/Admin@global.example.com/msp
    ```
    Now repeat operation 5 and then go on.
7.  Issue a subscription for Bob with  
    ```bash
    peer chaincode invoke -o orderer.org1.example.com:7050 $ORD_STRING -C mychannel -n subscriptions $PEER_STRING -c '{"Args":["IssueSubscription", '"\"$BOB\""', "Prov1", "2021-04-02T15:00:00Z", "2021-07-02T15:00:00Z"]}' --waitForEvent
    ```
8.  Now we select back normal user with:
    ```bash
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/global.example.com/users/Bob@global.example.com/msp
    ```  
9.  Try to remove a time slot from a target user
```bash
    peer chaincode invoke -o orderer.org1.example.com:7050 $ORD_STRING -C mychannel -n subscriptions $PEER_STRING -c '{"Args":["SplitSubscription","U1", "Prov1", "GlobalMSP", "2021-04-02T15:00:00Z", "2021-05-02T15:00:00Z"]}' --waitForEvent
```
    this will fail since the SmartContract will be exectued only if is called by another one. Indeed if we can rent our subscription through the NewOffer method (operation that will call the SplitSubscrition method)
```bash
    peer chaincode invoke -o orderer.org1.example.com:7050 $ORD_STRING -C mychannel -n offers $PEER_STRING -c '{"Args":["NewOffer", "Prov1", "GlobalMSP", "2021-04-02T15:00:00Z", "2021-05-02T15:00:00Z", "30"]}' --waitForEvent
```
    it will succed. 

10.  Now select Anna by setting 
```bash
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/global.example.com/users/Anna@global.example.com/msp
   ```
11.  Print the user's id with  
```bash
    peer chaincode invoke -o orderer.org1.example.com:7050 $ORD_STRING -C mychannel -n offers $PEER_STRING -c '{"Args":["GetUserId"]}' --waitForEvent
```  
    and copy it to the env var ANNA
12.  To create the money account for Anna as we have done with Bob we have to switch to admin with
    ```bash
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/global.example.com/users/Admin@global.example.com/msp
    ```
    
    and then we execute
    
    ```bash
    peer chaincode invoke -o orderer.org1.example.com:7050 $ORD_STRING -C mychannel -n money $PEER_STRING -c '{"Args":["NewMoneyAccount", '"\"$ANNA\""', "100", "2020-04-01T15:00:00Z", "2030-06-01T15:00:00Z"]}' --waitForEvent
   ```
13.  Now switch to Bob:  
    ```bash
    CORE_PEER_MSPCONFIGPATH="/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Bob@global.example.com/msp"
   ```  
14. Create another offer with price that Anna cannot afford to buy:  
    ```bash
    peer chaincode invoke -o orderer.org1.example.com:7050 $ORD_STRING -C mychannel -n offers $PEER_STRING -c '{"Args":["NewOffer", "Prov1", "Prov1", "2021-05-03T15:00:00Z", "2021-05-04T15:00:00Z", "120"]}' --waitForEvent
    ```
15. Select Anna again as in point 10  
16. Try to accept the second offer and see it fail with  
    ```bash
    peer chaincode invoke -o orderer.org1.example.com:7050 $ORD_STRING -C mychannel -n offers $PEER_STRING -c '{"Args":["AcceptOffer", '"\"$BOB\""', "Prov1", "2021-05-03T15:00:00Z"]}' --waitForEvent
    ```
17. Accept the first offer with  
    ```bash
    peer chaincode invoke -o orderer.org1.example.com:7050 $ORD_STRING -C mychannel -n offers $PEER_STRING -c '{"Args":["AcceptOffer", '"\"$BOB\""', "Prov1", "2021-04-02T15:00:00Z"]}' --waitForEvent
    ```
18. Show that Anna has spent money and has acquired the subscription with  
    ```bash
    peer chaincode query -o orderer.org1.example.com:7050 $ORD_STRING -C mychannel -n money -c '{"Args":["GetMoneyAccount", '"\"$ANNA\""']}'
    ```  
    and  
    ```bash
    peer chaincode query -o orderer.org1.example.com:7050 $ORD_STRING -C mychannel -n subscriptions -c '{"Args":["GetInfoUser", '"\"$ANNA\""', "Prov1"]}'
    ```
19. Show that Anna can login with the subscription he bought after loggin into admin
    ```bash
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/global.example.com/users/Admin@global.example.com/msp
    ```
    ```bash
    peer chaincode query -o orderer.org1.example.com:7050 $ORD_STRING -C mychannel -n subscriptions -c '{"Args":["ServiceAccess", '"\"$ANNA\""', "Prov1"]}'
    ```
