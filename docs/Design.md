#Design

Legenda:
SP = Service Provider
U = User / customer / client

## Application Design

- Register to the network / Link account (on each SP).
- Login with Hyperledger to access the Service  (on each SP).
- Webapp local to client to login to the network itself and see the offers. (gateway)
This webapp will also contain the wallet for the client (the certificate)

## Network design

- at least 1 peer for each SP. Each peer on the same channel.
- 1 ordering node for each SP

## Chaincode design
- world state
| UserId | SubscriptionId|startTime|endTime| Type |
| --- | --- | --- | --- | --- |
|A|001|01/01/2020|31/12/2020|S|
|A|001|01/10/2020|02/10/2020|O|

## Improvments
- enable cross device auth
- make only necessary data public
