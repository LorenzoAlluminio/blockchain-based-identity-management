# Demo on certificate-based access control

After completing the setup described in the readme:
1.  Select User1@org1 by setting the env var 
    ```CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/User1@org1.example.com/msp```
2.  Print the user's id with
    ```peer chaincode invoke -o orderer.example.com:7050 $ORD_STRING -C mychannel -n offers $PEER_STRING -c '{"Args":["PrintCert"]}' --waitForEvent```
    and copy it to the env var USR1ORG1
3.  Create the money account for User1@org1 with
    ```peer chaincode invoke -o orderer.example.com:7050 $ORD_STRING -C mychannel -n money $PEER_STRING -c '{"Args":["NewMoneyAccount", '"\"$USR1ORG1\""', "0", "2020-04-01T15:00:00Z", "2020-06-01T15:00:00Z"]}' --waitForEvent```
4.  Issue a subscription for User1@org1 with
    ```peer chaincode invoke -o orderer.example.com:7050 $ORD_STRING -C mychannel -n subscriptions $PEER_STRING -c '{"Args":["IssueSubscription", '"\"$USR1ORG1\""', "Prov1", "Prov1", "2020-04-02T15:00:00Z", "2020-07-02T15:00:00Z"]}' --waitForEvent```
5.  Now select User1@org2 by setting
    ```CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/User1@org2.example.com/msp```
    and
    ```CORE_PEER_LOCALMSPID="Org2MSP"```
6.  Print the user's id with
    ```peer chaincode invoke -o orderer.example.com:7050 $ORD_STRING -C mychannel -n offers $PEER_STRING -c '{"Args":["PrintCert"]}' --waitForEvent```
    and copy it to the env var USR1ORG2
7.  Create the money account for User1@org2 with
    ```peer chaincode invoke -o orderer.example.com:7050 $ORD_STRING -C mychannel -n money $PEER_STRING -c '{"Args":["NewMoneyAccount", '"\"$USR1ORG2\""', "100", "2020-04-01T15:00:00Z", "2020-06-01T15:00:00Z"]}' --waitForEvent```
8.  Try to create a new offer with the subscription of User1@org1 while using User1@org2 and see the failure
    ```peer chaincode invoke -o orderer.example.com:7050 $ORD_STRING -C mychannel -n offers $PEER_STRING -c '{"Args":["NewOffer", "Prov1", "Prov1", "2020-04-02T15:00:00Z", "2020-05-02T15:00:00Z", "30"]}' --waitForEvent```
9.  Now switch to User1@org1:
    ```CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/User1@org1.example.com/msp"
    and
    ```CORE_PEER_LOCALMSPID="Org1MSP"```
10. Using the same command at point 8 create the offer
11. Create another offer with price that User1@org2 cannot pay:
    ```peer chaincode invoke -o orderer.example.com:7050 $ORD_STRING -C mychannel -n offers $PEER_STRING -c '{"Args":["NewOffer", "Prov1", "Prov1", "2020-05-03T15:00:00Z", "2020-05-04T15:00:00Z", "120"]}' --waitForEvent```
12. Select User1@org2 again as in point 5
13. Try to accept the second offer and see it fail with
    ```peer chaincode invoke -o orderer.example.com:7050 $ORD_STRING -C mychannel -n offers $PEER_STRING -c '{"Args":["AcceptOffer", '"\"$USR1ORG1\""', "Prov1", "2020-05-03T15:00:00Z"]}' --waitForEvent```
14. Accept the first offer with
    ```peer chaincode invoke -o orderer.example.com:7050 $ORD_STRING -C mychannel -n offers $PEER_STRING -c '{"Args":["AcceptOffer", '"\"$USR1ORG1\""', "Prov1", "2020-04-02T15:00:00Z"]}' --waitForEvent```
15. Show that Usr1@org2 has spent money and has acquired the subscription with
    ```peer chaincode query -o orderer.example.com:7050 $ORD_STRING -C mychannel -n money -c '{"Args":["GetMoneyAccount", '"\"$USR1ORG2\""']}'```
    and
    ```peer chaincode query -o orderer.example.com:7050 $ORD_STRING -C mychannel -n subscriptions -c '{"Args":["GetInfoUser", '"\"$USR1ORG2\""', "Prov1"]}'```
