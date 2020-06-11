Configuration:

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
3.  Select Anna by setting the env var  
    ```bash
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/global.example.com/users/Anna@global.example.com/msp
    ```  
4.  Print the user's id with  
    ```bash
    peer chaincode invoke -o orderer.org1.example.com:7050 $ORD_STRING -C mychannel -n offers $PEER_STRING -c '{"Args":["GetUserId"]}' --waitForEvent 2>&1 | grep "invoke successful"
    ```  
    and copy it to the env var ANNA

5.  To became admin use
    ```bash
    CORE_PEER_LOCALMSPID="Org1MSP"
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    ```
6.  Create ANNA wallet
    ```bash
    peer chaincode invoke -o orderer.org1.example.com:7050 $ORD_STRING -C mychannel -n money $PEER_STRING -c '{"Args":["NewMoneyAccount", '"\"$ANNA\""', "0", "2020-06-01T15:00:00Z", "2030-08-01T15:00:00Z"]}' --waitForEvent 2>&1 | grep "invoke successful"
    ```
7.  Issue `NETFLIX=Org1`
    
Start Demo:

7.  Issue a Subscription for ANNA
    ```bash
    peer chaincode invoke -o orderer.org1.example.com:7050 $ORD_STRING -C mychannel -n subscriptions $PEER_STRING -c '{"Args":["IssueSubscription", '"\"$ANNA\""', "Prov1", "2020-06-02T15:00:00Z", "2020-08-02T15:00:00Z"]}' --waitForEvent 2>&1 | grep "invoke successful"
    ```
8. Go back to ANNA
    ```bash
    CORE_PEER_LOCALMSPID="GlobalMSP"
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/global.example.com/users/Anna@global.example.com/msp
    ```  
9. Anna create its offer
    ```bash
    peer chaincode invoke -o orderer.org1.example.com:7050 $ORD_STRING -C mychannel -n offers $PEER_STRING -c '{"Args":["NewOffer", "Prov1", '"\"$NETFLIX\""' , "2020-06-25T10:00:00Z", "2020-06-25T23:59:59Z", "30"]}' --waitForEvent 2>&1 | grep "invoke successful"
    ```
10. Bob is added to the blockchain 
    ```bash 
    cd scripts
    ./addUser_th.sh Bob 2>&1 | awk 'END{print}'
    ```
11. Impersonate Bob
    ```bash
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/global.example.com/users/Bob@global.example.com/msp
    ```  
12. Get the UserID
    ```bash
    peer chaincode invoke -o orderer.org1.example.com:7050 $ORD_STRING -C mychannel -n offers $PEER_STRING -c '{"Args":["GetUserId"]}' --waitForEvent 2>&1 | grep "invoke successful"
    ```  
    and copy it to the env var BOB
13. Became admin and create the money account
    ```bash
    CORE_PEER_LOCALMSPID="Org1MSP"
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    ```
    and
    ```bash
    peer chaincode invoke -o orderer.org1.example.com:7050 $ORD_STRING -C mychannel -n money $PEER_STRING -c '{"Args":["NewMoneyAccount", '"\"$BOB\""', "30", "2020-06-01T15:00:00Z", "2020-08-01T15:00:00Z"]}' --waitForEvent 2>&1 | grep "invoke successful"
    ```
15. Return to Bob
    ```bash
    CORE_PEER_LOCALMSPID="GlobalMSP"
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/global.example.com/users/Bob@global.example.com/msp
    ```  
15. Get all the available offerts
    ```bash
    peer chaincode invoke -n offers -c '{"Args":["QueryAllOffers"]}' -C myc --waitForEvent 2>&1 | grep "invoke successful"
    ```
16. Accept one offert with bob
    ```bash
    peer chaincode invoke -o orderer.org1.example.com:7050 $ORD_STRING -C mychannel -n offers $PEER_STRING -c '{"Args":["AcceptOffer", '"\"$ANNA\""', "Prov1", "2020-06-25T10:00:00Z"]}' --waitForEvent  2>&1 | grep "invoke successful"
    ```
17. Became Admin to check Bob subscription to access Netflix
    ```bash
    CORE_PEER_LOCALMSPID="Org1MSP"
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    peer chaincode query -o orderer.org1.example.com:7050 $ORD_STRING -C mychannel -n subscriptions -c '{"Args":["ServiceAccess", '"\"$BOB\""', '"\"$NETFLIX\""']}'
    ```

















