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
7.  Issue `NETFLIX="Org1MSP"`

Start Demo:

8.  Issue a Subscription for ANNA
```bash
peer chaincode invoke -o orderer.org1.example.com:7050 $ORD_STRING -C mychannel -n subscriptions $PEER_STRING -c '{"Args":["IssueSubscription", '"\"$ANNA\""', "Sub1", "2020-06-02T15:00:00Z", "2020-08-02T15:00:00Z"]}' --waitForEvent 2>&1 | grep "invoke successful"
```
and show that Anna now owns that subscription over this time interval.
```
peer chaincode invoke -o orderer.org1.example.com:7050 $ORD_STRING -C mychannel -n subscriptions $PEER_STRING -c '{"Args":["GetInfoUser", '"\"$ANNA\""', '"\"$NETFLIX\""']}' 2>&1 | tr "{" "\n" | grep -E "\"2020|SubID"  | tr -d "\\\"{}[]" | awk -F "," 'NR==1 {print $1;print $2} NR!=1 {print}'
```
9. Go back to ANNA
```bash
CORE_PEER_LOCALMSPID="GlobalMSP"
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/global.example.com/users/Anna@global.example.com/msp

```  
10a. Wallet status of Anna
```bash
peer chaincode invoke -o orderer.org1.example.com:7050 $ORD_STRING -C mychannel -n money $PEER_STRING -c '{"Args":["GetMoneyAccount"]}' 2>&1 | sed -r 's/.*payload:"\{//g' | sed -r 's/.{3}$//g' | tr -d "\\\"\{\}" | tr "," "\n" | sed 's/Key://' | sed 's/Data://'
```
10. Anna create its offer
```bash
peer chaincode invoke -o orderer.org1.example.com:7050 $ORD_STRING -C mychannel -n offers $PEER_STRING -c '{"Args":["NewOffer", "Sub1", '"\"$NETFLIX\""' , "2020-06-25T10:00:00Z", "2020-06-25T23:59:59Z", "30"]}' --waitForEvent 2>&1 | grep "invoke successful"
```
11. Bob is added to the blockchain 
```bash 
cd scripts
./addUser_th.sh Bob 2>&1 | awk 'END{print}'
```
12. Impersonate Bob
```bash
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/global.example.com/users/Bob@global.example.com/msp
```  
13. Get the UserID
```bash
peer chaincode invoke -o orderer.org1.example.com:7050 $ORD_STRING -C mychannel -n offers $PEER_STRING -c '{"Args":["GetUserId"]}' --waitForEvent 2>&1 | grep "invoke successful"
```  
and copy it to the env var BOB

14. Became admin and create the money account
```bash
CORE_PEER_LOCALMSPID="Org1MSP"
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
```
and
```bash
peer chaincode invoke -o orderer.org1.example.com:7050 $ORD_STRING -C mychannel -n money $PEER_STRING -c '{"Args":["NewMoneyAccount", '"\"$BOB\""', "30", "2020-06-01T15:00:00Z", "2020-08-01T15:00:00Z"]}' --waitForEvent 2>&1 | grep "invoke successful"
```
16. Return to Bob
```bash
CORE_PEER_LOCALMSPID="GlobalMSP"
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/global.example.com/users/Bob@global.example.com/msp
```  
and print his money account data:
```
peer chaincode invoke -o orderer.org1.example.com:7050 $ORD_STRING -C mychannel -n money $PEER_STRING -c '{"Args":["GetMoneyAccount"]}' 2>&1 | sed -r 's/.*payload:"\{//g' | sed -r 's/.{3}$//g' | tr -d "\\\"\{\}" | tr "," "\n" | sed 's/Key://' | sed 's/Data://'
```
17. Get all the available offerts
```bash
peer chaincode invoke -o orderer.org1.example.com:7050 $ORD_STRING -C mychannel -n offers $PEER_STRING -c '{"Args":["QueryAllOffers"]}' --waitForEvent 2>&1 | grep "invoke successful" | sed -r 's/.*payload:"\[//g' | sed -r 's/.{3}$//g' | tr -d "\\\"\{\}" | tr "," "\n" | sed 's/Key://' | sed 's/Data://' | sed -r 's/Org1MSP/NETFLIX/g'
```
18. Accept one offert with bob
```bash
peer chaincode invoke -o orderer.org1.example.com:7050 $ORD_STRING -C mychannel -n offers $PEER_STRING -c '{"Args":["AcceptOffer", '"\"$ANNA\""', "Sub1", "2020-06-25T10:00:00Z"]}' --waitForEvent  2>&1 | grep "invoke successful"
```
19. show Bob wallet
```bash
peer chaincode invoke -o orderer.org1.example.com:7050 $ORD_STRING -C mychannel -n money $PEER_STRING -c '{"Args":["GetMoneyAccount"]}' 2>&1 | sed -r 's/.*payload:"\{//g' | sed -r 's/.{3}$//g' | tr -d "\\\"\{\}" | tr "," "\n" | sed 's/Key://' | sed 's/Data://'
```
19a. Go to Admin and show access
```bash
CORE_PEER_LOCALMSPID="Org1MSP"
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
peer chaincode query -o orderer.org1.example.com:7050 $ORD_STRING -C mychannel -n subscriptions -c '{"Args":["ServiceAccess", '"\"$BOB\""', '"\"$NETFLIX\""']}'
```
19b. Go back to ANNA
```bash
CORE_PEER_LOCALMSPID="GlobalMSP"
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/global.example.com/users/Anna@global.example.com/msp

```  
19b. Wallet status of Anna
```bash
peer chaincode invoke -o orderer.org1.example.com:7050 $ORD_STRING -C mychannel -n money $PEER_STRING -c '{"Args":["GetMoneyAccount"]}' 2>&1 | sed -r 's/.*payload:"\{//g' | sed -r 's/.{3}$//g' | tr -d "\\\"\{\}" | tr "," "\n" | sed 's/Key://' | sed 's/Data://'
```

20. Become Admin to check Anna subscription state
```bash
CORE_PEER_LOCALMSPID="Org1MSP"
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
peer chaincode invoke -o orderer.org1.example.com:7050 $ORD_STRING -C mychannel -n subscriptions $PEER_STRING -c '{"Args":["GetInfoUser", '"\"$ANNA\""', '"\"$NETFLIX\""']}' 2>&1 | tr "{" "\n" | grep -E "\"2020|SubID"  | tr -d "\\\"{}[]" | awk -F "," 'NR==1 {print $1;print $2} NR!=1 {print}'
```
21. Go back to ANNA
```bash
CORE_PEER_LOCALMSPID="GlobalMSP"
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/global.example.com/users/Anna@global.example.com/msp

```  

21. Anna create its offer
```bash
peer chaincode invoke -o orderer.org1.example.com:7050 $ORD_STRING -C mychannel -n offers $PEER_STRING -c '{"Args":["NewOffer", "Sub1", '"\"$NETFLIX\""' , "2020-06-27T10:00:00Z", "2020-06-27T23:59:59Z", "30"]}' --waitForEvent 2>&1 | grep "invoke successful"
```

22. Return to Bob
```bash
CORE_PEER_LOCALMSPID="GlobalMSP"
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/global.example.com/users/Bob@global.example.com/msp
```  

23. Accept one offert with bob
```bash
peer chaincode invoke -o orderer.org1.example.com:7050 $ORD_STRING -C mychannel -n offers $PEER_STRING -c '{"Args":["AcceptOffer", '"\"$ANNA\""', "Sub1", "2020-06-27T10:00:00Z"]}' --waitForEvent
```

### Removing Org2

25. From a different shell, within the semproj_net folder run 
```bash
docker exec cli ./scripts/org2-remove.sh 
```

25. Again from the cli, run
```bash
peer chaincode invoke -o orderer.org1.example.com:7050 $ORD_STRING -C mychannel -n offers $PEER_STRING -c '{"Args":["GetUserId"]}' 
```

26. Impersonate admin of org2
```bash
CORE_PEER_LOCALMSPID="Org2MSP"
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
```

27. Again run
```bash
peer chaincode invoke -o orderer.org1.example.com:7050 $ORD_STRING -C mychannel -n offers $PEER_STRING -c '{"Args":["GetUserId"]}' 
```
it will fail

