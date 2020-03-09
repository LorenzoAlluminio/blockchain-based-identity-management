#Design

Legenda:
SP = Service Provider
U = User / customer / client

## Application Design

- Register to the network / Link account (on each SP). Add user to channel MSP?
- Login with Hyperledger to access the Service  (on each SP).
- Webapp local to client to login to the network itself and see the offers. (gateway)
This webapp will also contain the wallet for the client (the certificate)

## Network design

- at least 1 peer for each SP. Each peer on the same channel.
- 1 ordering node for each SP

## Chaincode design
- subscription world state

UserId | Provider | SubscriptionId|startTime|endTime
---- | ---- | ---- | ---- | ---- |
A|Netflick|001|01/01/2020 00.00 | 31/12/2020 12.59

- money world state

UserId | amountOfMoney |
---- | ---- |
A|100|

- offers world state

UserId | Provider | SubscriptionId|startTime|endTime | price
---- | ---- | ---- | ---- | ---- | ----
A|Netflick|001|07/07/2020 13.00 |07/07/2020 14.00 | 50 HC

- Insert subscription smart contract
Smart contract used by SP to certify a subscription of a user. Modifies the subscription world state. Endorsement policy: SP related to the subscription

- Offers smart contract
Smart contract triggered by user to insert/acquire advertisments. modifies offers world state. Endorsement policy: majority vote.
- money smart contract
add or sub money to user. Endorsement policy: majority vote

## Improvements
- enable cross device auth (crypted key on sp solution)
- make only necessary data public
- bidding system
- signing of offer from user
- common payments with ethereum?
