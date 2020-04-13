# Demo on organization addition and removal

1.  Run `./byfn.sh` to setup the network.
2.  Set ORD_STRING:
    ```bash
    ORD_STRING="--tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org1.example.com/orderers/orderer.org1.example.com/msp/tlscacerts/tlsca.org1.example.com-cert.pem"
    ```  
3.  Set PEER_STRING to the value below:   
    ```bash  
    PEER_STRING="--peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt --peerAddresses peer0.org3.example.com:11051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt"
    ```  
    so that the next chaincode invocation will only be validated by 3 organizations out of 5.
4.  Invoke the PrintCert function of the offers chaincode with the command  
    ```bash
    peer chaincode invoke -o orderer.org1.example.com:7050 $ORD_STRING -C mychannel -n offers $PEER_STRING -c '{"Args":["PrintCert"]}' --waitForEvent
    ```  
    and show that as the endorsement policy is by majority the invocation is successful.  
5.  Exit the cli and from the folder containing this file run the command `.\eyfn.sh` to add org6 to the network.
6.  Run the command `docker exec -it Org6cli bash`
7.  Set ORD_STRING as in step 2, and PEER_STRING as in step 3.
8.  Try to run the same command as in step 4; this time it will fail, because only 3 organizations out of 6 are validating the transaction.
9.  Set PEER_STRING to the value  
    ```bash
    PEER_STRING="--peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt --peerAddresses peer0.org3.example.com:11051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt --peerAddresses peer0.org6.example.com:17051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org6.example.com/peers/peer0.org6.example.com/tls/ca.crt"
    ```  
    so that now also one of the peers belonging to org6 will be performing the validation.
10. Run again the command from step 4; it will again be successful.
11. Exit the cli and from the folder containing this file run the command  
    ```bash
    docker exec Org6cli ./scripts/org2-remove.sh
    ``` 
    to remove org2 from the network, then reopen the cli with the command in step 6
12. Set ORD_STRING as in step 2, and PEER_STRING as in step 3.
13. Run the command as in step 4; it will fail because org2 is no more a part of the network and therefore its peers are no more able to perform validation. As the cli will be stuck waiting for an answer from org2, kill the command with Ctrl+C.
14. Set PEER_STRING to the value
    ```bash
    PEER_STRING="--peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0.org3.example.com:11051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt --peerAddresses peer0.org6.example.com:17051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org6.example.com/peers/peer0.org6.example.com/tls/ca.crt"
    ```  
    so that organizations 1, 3 and 6 will be validating the transaction.
15. Now the command from step 4 will again work with just 3 organizations performing the validation.
