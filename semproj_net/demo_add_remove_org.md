# Demo on organization addition and removal

1.  Run `./byfn.sh` to setup the network and `docker exec -it cli bash`.
2.  Set ORD_STRING and PEER_STRING:
    ```bash
    ORD_STRING="--tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org1.example.com/orderers/orderer.org1.example.com/msp/tlscacerts/tlsca.org1.example.com-cert.pem"
    ```
    ```bash  
    PEER_STRING="--peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt --peerAddresses peer0.org3.example.com:11051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt --peerAddresses peer0.org4.example.com:13051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org4.example.com/peers/peer0.org4.example.com/tls/ca.crt --peerAddresses peer0.org5.example.com:15051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org5.example.com/peers/peer0.org5.example.com/tls/ca.crt"
    ```
3.  Select User1@org1 by setting the env var  
    ```bash
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/User1@org1.example.com/msp
    ```  
4.  Print the user's id with  
    ```bash
    peer chaincode invoke -o orderer.org1.example.com:7050 $ORD_STRING -C mychannel -n offers $PEER_STRING -c '{"Args":["GetUserId"]}' --waitForEvent
    ```  
    and copy it to the env var USR1ORG1
5.  Try to create the money account for User1@org1 with  
    ```bash
    peer chaincode invoke -o orderer.org1.example.com:7050 $ORD_STRING -C mychannel -n money $PEER_STRING -c '{"Args":["NewMoneyAccount", '"\"$USR1ORG1\""', "0", "2020-04-01T15:00:00Z", "2020-06-01T15:00:00Z"]}' --waitForEvent
    ```
    this opeartion will fail since we are logged as a normal user but this operation require admin privileges.
6.  To became admin use
    ```bash
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    ```
    Now repeat operation 5 and then go on.
7.  Issue a subscription for User1@org1 with  
    ```bash
    peer chaincode invoke -o orderer.org1.example.com:7050 $ORD_STRING -C mychannel -n subscriptions $PEER_STRING -c '{"Args":["IssueSubscription", '"\"$USR1ORG1\""', "Prov1", "2020-04-02T15:00:00Z", "2020-07-02T15:00:00Z"]}' --waitForEvent
    ```
8.  Now we select back normal user with:
    ```bash
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/User1@org1.example.com/msp
    ```  
9.  Try to remove a time slot from a target user
    ```bash
    peer chaincode invoke -o orderer.org1.example.com:7050 $ORD_STRING -C mychannel -n subscriptions $PEER_STRING -c '{"Args":["SplitSubscription","U1", "Prov1", "Prov1", "2020-04-02T15:00:00Z", "2020-05-02T15:00:00Z"]}' --waitForEvent
    ```
    this will fail since the SmartContract will be exectued only if is called by another one. Indeed if we can rent our subscription through the NewOffer method (operation that will call the SplitSubscrition method)
    ```bash
    peer chaincode invoke -o orderer.org1.example.com:7050 $ORD_STRING -C mychannel -n offers $PEER_STRING -c '{"Args":["NewOffer", "Prov1", "Org1MSP", "2020-04-02T15:00:00Z", "2020-05-02T15:00:00Z", "30"]}' --waitForEvent
    ```
    it will succed.  
10.  Set ORD_STRING:
```bash
    ORD_STRING="--tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org1.example.com/orderers/orderer.org1.example.com/msp/tlscacerts/tlsca.org1.example.com-cert.pem"
```
11.  Set PEER_STRING to the value below:  
    ```bash
    PEER_STRING="--peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt --peerAddresses peer0.org3.example.com:11051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt"
    ```
    so that the next chaincode invocation will only be validated by 3 organizations out of 5.
12.  Invoke the PrintCert function of the offers chaincode with the command  
    ```bash
    peer chaincode invoke -o orderer.org1.example.com:7050 $ORD_STRING -C mychannel -n offers $PEER_STRING -c '{"Args":["GetUserId"]}' --waitForEvent
    ```  
    and show that as the endorsement policy is by majority the invocation is successful.  
13.  Exit the cli and from the folder containing this file run the command `./eyfn.sh` to add org6 to the network.  
14.  Run the command `docker exec -it Org6cli bash`  
15.  Set ORD_STRING as in step 10, and PEER_STRING as in step 11.  
16.  Try to run the same command as in step 12; this time it will fail, because only 3 organizations out of 6 are validating the             transaction.  
17.  Set PEER_STRING to the value  
    ```bash
    PEER_STRING="--peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt --peerAddresses peer0.org3.example.com:11051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt --peerAddresses peer0.org6.example.com:17051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org6.example.com/peers/peer0.org6.example.com/tls/ca.crt"
    ```  
    so that now also one of the peers belonging to org6 will be performing the validation.  
18. Run again the command from step 12; it will again be successful.  
19. Exit the cli and from the folder containing this file run the command  
    ```bash
    docker exec Org6cli ./scripts/org2-remove.sh
    ```  
    to remove org2 from the network, then reopen the cli with the command in step 14  
20. Set ORD_STRING as in step 10, and PEER_STRING as in step 11.  
21. Run the command as in step 12; it will fail because org2 is no more a part of the network and therefore its peers are no more able to   perform validation. As the cli will be stuck waiting for an answer from org2, kill the command with Ctrl+C.  
22. Set PEER_STRING to the value  
    ```bash
    PEER_STRING="--peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0.org3.example.com:11051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt --peerAddresses peer0.org6.example.com:17051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org6.example.com/peers/peer0.org6.example.com/tls/ca.crt"
    ```  
    so that organizations 1, 3 and 6 will be validating the transaction.  
23. Now the command from step 12 will again work with just 3 organizations performing the validation.  
