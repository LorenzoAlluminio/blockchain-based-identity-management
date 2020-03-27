# Semester project

## Usage

1. Clone the repository
```bash
git clone git@github.com:LorenzoAlluminio/semester_project.git
```

2. Check for prerequisites here https://hyperledger-fabric.readthedocs.io/en/release-2.0/prereqs.html

3. Add this line to the shell config file for convenience
```bash
export PATH=<path to semester_project/fabric-samples>/bin:$PATH
```

4. go in the chaincode-docker-devmode folder
```bash
cd semester_project/fabric-samples/chaincode-docker-devmode
```

5. start the network
```bash
docker-compose -f docker-compose-simple.yaml up
```
This command will bring up the hyperledger test network and it will not exit and continue to print stuff onto stdout.
If it gives errors try to run a
```bash
docker-compose -f docker-compose-simple.yaml down
```
to remove the previously created artifacts. Then run again the first command.

6. Open another shell and enter the following command
```bash
docker exec -it chaincode sh
cd semproj/money
go mod vendor
go build
CORE_CHAINCODE_ID_NAME=money:0 CORE_PEER_TLS_ENABLED=false ./money -peer.address peer:7052
```
This commands will run the money chaincode. It should not exit.
If it gives permission error grant permissions recursively to the semproj folder like this:
```bash
chmod +R 777 semproj
```

7. Open another shell and enter the following command
```bash
docker exec -it chaincode sh
cd semproj/subscriptions/
go mod vendor
go build
CORE_CHAINCODE_ID_NAME=subscriptions:0 CORE_PEER_TLS_ENABLED=false ./subscriptions -peer.address peer:7052

```
These commands will run the subscriptions chaincode. It should not exit.

8. Open another shell and enter the following command
```bash
docker exec -it chaincode sh
cd semproj/offers/
go mod vendor
go build
CORE_CHAINCODE_ID_NAME=offers:0 CORE_PEER_TLS_ENABLED=false ./offers -peer.address peer:7052
```
This commands will run the offers chaincode. It should not exit.

9. Open another shell and enter the following command
```bash
docker exec -it cli sh
peer chaincode install -p chaincodedev/chaincode/semproj/money -n money -v 0
peer chaincode install -p chaincodedev/chaincode/semproj/subscriptions -n subscriptions -v 0
peer chaincode install -p chaincodedev/chaincode/semproj/offers -n offers -v 0
peer chaincode instantiate -n money -v 0 -c '{"Args":[]}' -C myc
peer chaincode instantiate -n subscriptions -v 0 -c '{"Args":[]}' -C myc
peer chaincode instantiate -n offers -v 0 -c '{"Args":[]}' -C myc
```
This commands will install & instantiate all the 3 chaincodes.

10. Now from this shell we can call all the functions defined in the 3 chaincodes. Here are some examples. For the full list of functionalities see the chaincodes in the folder /chaincode/semproj.

**N.B. Since the blockchain has to reach consensus and update the world state, to see the results of a command that updates the world state you will have to wait some seconds.**

These commands will populate the Subscription chaincode with some examples subscriptions:
```bash
peer chaincode invoke -n subscriptions -c '{"Args":["IssueSubscription", "U1", "S1", "Net", "2020-01-02T15:04:05Z", "2020-03-02T15:04:04Z"]}' -C myc
peer chaincode invoke -n subscriptions -c '{"Args":["IssueSubscription", "U1", "S1", "Net", "2010-03-02T15:04:05Z", "2010-05-02T15:04:04Z"]}' -C myc
peer chaincode invoke -n subscriptions -c '{"Args":["IssueSubscription", "U1", "S2", "Prime", "2019-12-17T10:00:00Z", "2020-01-17T09:59:59Z"]}' -C myc
peer chaincode invoke -n subscriptions -c '{"Args":["IssueSubscription", "U2", "S3", "vpn", "2019-07-15T15:04:05Z", "2020-07-15T15:04:04Z"]}' -C myc
peer chaincode invoke -n subscriptions -c '{"Args":["IssueSubscription", "U3", "S4", "Net", "2020-01-01T12:00:00Z", "2022-01-01T11:59:59Z"]}' -C myc
```
The format of the command is `peer chaincode invoke -n subscriptions -c '{"Args":["IssueSubscription", "<userId>", "<subscriptionId>", "<Provider>", "<SubscriptionStartDate>", "<SubscriptionEndDate>"]}' -C myc`

These commands will populate the Money chaincode with some example users:
```bash
peer chaincode invoke -n money -c '{"Args":["NewMoneyAccount", "U1", "100", "2010-10-10T15:04:05Z","2015-10-10T15:04:05Z"]}' -C myc
peer chaincode invoke -n money -c '{"Args":["NewMoneyAccount", "U2", "100", "2010-10-10T15:04:05Z","2015-10-10T15:04:05Z"]}' -C myc
peer chaincode invoke -n money -c '{"Args":["NewMoneyAccount", "U3", "100", "2010-10-10T15:04:05Z","2015-10-10T15:04:05Z"]}' -C myc
peer chaincode invoke -n money -c '{"Args":["NewMoneyAccount", "U4", "100", "2010-10-10T15:04:05Z","2015-10-10T15:04:05Z"]}' -C myc
```
The format of the command is `peer chaincode invoke -n money -c '{"Args":["NewMoneyAccount", "<userId>", "<amountOfMoney>", "<startDateOfAccessToNetwork>","<endDateOfAccessToNetwork>"]}' -C myc`

These commands will retrieve the information in the Money chaincode about U1 and U2:
```bash
peer chaincode query -n money -c '{"Args":["GetMoneyAccount", "U1"]}' -C myc
peer chaincode query -n money -c '{"Args":["GetMoneyAccount", "U2"]}' -C myc
```

This command will retrieve the information in the Subscription chaincode about the subscription S1 of U1.
```bash
peer chaincode query -n subscriptions -c '{"Args":["GetInfoUser", "U1", "S1"]}' -C myc
```

Then we can insert an offer with the following command. This one will insert an offer for the subscription S1 of user U1, for the provider Net, renting the period of time between the 2 dates. The price of the rent is the last parameter
```bash
peer chaincode invoke -n offers -c '{"Args":["NewOffer", "U1", "S1", "Net", "2020-01-03T15:04:05Z","2020-01-04T15:04:05Z","10"]}' -C myc
```
The format of the command is `peer chaincode invoke -n offers -c '{"Args":["NewOffer", "<userId>", "<SubscriptionId>", "<Provider>", "<RentingStartDate>","<RentingStartDate>","<price>"]}' -C myc`

Then we can accept the offer with the command:
```bash
peer chaincode invoke -n offers -c '{"Args":["AcceptOffer", "U2", "U1", "S1", "2020-01-03T15:04:05Z"]}' -C myc
```
The format of the command is `peer chaincode invoke -n offers -c '{"Args":["AcceptOffer", "<userAccepting>", "<userRenting>", "<SubscriptionId>", "<RentingStartDate>"]}' -C myc`

Here there are other examples command to check that the modification due to the offer accept are actually performed:
```bash
peer chaincode query -n subscriptions -c '{"Args":["GetInfoUser", "U2", "S1"]}' -C myc
peer chaincode query -n money -c '{"Args":["GetMoneyAccount", "U2"]}' -C myc
peer chaincode query -n money -c '{"Args":["GetMoneyAccount", "U1"]}' -C myc
peer chaincode invoke -n offers -c '{"Args":["QueryAllOffers"]}' -C myc
```
