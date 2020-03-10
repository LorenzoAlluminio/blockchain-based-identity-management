#Design

SP = Service Provider
U = User

## Summary of the requirements

The idea is to create an hyperledger network between multiple service provider that offer different type of services (e.g video streaming, hosting, vpn access ...)

This network will allow users to rent to other users their access to services and gain in return HyperCash (HC).
Then they will be able to rent access to other services belonging to the network using the gained currency. So this technology will basically allow the creation of a marketplace of access to services between users.
Users will not be able to convert HyperCash into real money.

## Network design
The network is composed by one application channel on which are deployed three chaincodes (one related to subscriptions, one related to money and one which controls the rent offers). Each service provider will have a peer which executes the three smart contracts (SCS, SCM and SCO respectively) and keeps an updated version of the three world states (WS, WM and WO). The endorsement policies are different based on the type of the transaction. Each provider will have also 1 ordering nodes, and they will reach consensus through Raft.
The user will connect to the network through a web app which is store in the customer device. Then he can check the state of its own wallet, issue a new offer, read the offer world state or rent a subscription.

Example network with 2 SP and 2 users:
![general schema](../img/general_schema.png "General schema of the network")

Example of insertion of subscription by the user:
![Subscription insertion](../img/subscription_schema.png "Subscription insertion")

When a user subscribes to a new service, if it chooses to share the subscription within the network, the Service Provider will issue the new subscription to the channel.
All the other peer in the network will add it to their ledger, if the data is valid.

Example of insertion of offer by the user:
![Offer insertion](../img/offer_schema.png "Offer insertion")

When a user wants to add an offer to the ledger it requests a write to the ledger, if the offer is legitimate the service providers approves it and adds it to LO (Ledger of Offers)





## Application Design

- Register to the network / Link account (on each SP). Add user to channel MSP?
- Login with Hyperledger to access the Service  (on each SP).
- Webapp local to client to login to the network itself and see the offers. (gateway)
This webapp will also contain the wallet for the client (the certificate)

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
methods: new sub, split sub, query

- Offers smart contract
Smart contract triggered by user to insert/acquire advertisments. modifies offers world state. Endorsement policy: majority vote.
methods: sell,buy,query
- money smart contract
add or sub money to user. Endorsement policy: majority vote
methods: add,sub,query

## Improvements
- enable cross device auth (crypted key on sp solution)
- make only necessary data public
- bidding system
- signing of offer from user
- common payments with ethereum?
