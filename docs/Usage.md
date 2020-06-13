# Usage of the project

1. Clone the repository
```bash
git clone git@github.com:LorenzoAlluminio/semester_project.git
```

2. Check for prerequisites here https://hyperledger-fabric.readthedocs.io/en/release-2.0/prereqs.html

3. Add this line to the shell config file
```bash
export PATH=<path to semester_project>/bin:$PATH
```

4. Run this command to download the docker images needed
```bash
bash bootstrap.sh -sb
```

Now you can launch the `semproj_net` network. It is a realistic network composed of 5 organization, each one with 2 peer nodes, 1 orderer node and a CA.

5.  Launch the network with `./byfn.sh up`.  The script will load the chaincodes and perform all the setup operations.
If it gives permissions error grant permissions recursively to the chaincode folder like this:
    ```bash
    chmod +R 777 chaincode
    ```   

6.  Enter the CLI with  `docker exec -it cli bash`
7.  Inside the cli, define these two environment variables, which are necessary
    to reach the orderer and the organization peers:
    ```bash
    ORD_STRING="--tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/org1.example.com/orderers/orderer.org1.example.com/msp/tlscacerts/tlsca.org1.example.com-cert.pem"
    ```

    ```bash  
    PEER_STRING="--peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt --peerAddresses peer0.org3.example.com:11051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt --peerAddresses peer0.org4.example.com:13051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org4.example.com/peers/peer0.org4.example.com/tls/ca.crt --peerAddresses peer0.org5.example.com:15051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org5.example.com/peers/peer0.org5.example.com/tls/ca.crt"
    ```
8. Impersonate Anna or Bob by setting this variables
```bash
CORE_PEER_LOCALMSPID="GlobalMSP"
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/global.example.com/users/Anna@global.example.com/msp
```

9.  Now you can perform query and invoke operations on the ledger with commands of the type:  
    ```bash
    peer chaincode <query/invoke> -o orderer.org1.example.com:7050 $ORD_STRING -C mychannel -n <money/offers/subscriptions> $PEER_STRING -c <params> --waitForEvent
    ```

Demos scripts:
- [Demo on certificate-based access control](demos/demo_access_control.md)
- [Demo on organization addition and removal of an organization](demos/demo_add_remove_org.md)
- [Demo on user story](demos/Anna_&_BOB.md)
