# Semester project

## Why this project

The idea is to create an hyperledger network between multiple service provider that offer different type of services (e.g video streaming, hosting, vpn access ...)

This network will allow users to rent to other users their access to services and gain in return HyperCash (HC). Then they will be able to rent access to other services belonging to the network using the gained currency. So this technology will basically allow the creation of a marketplace of access to services between users. Users will not be able to convert HyperCash into real money.

Example: User A has access to service S. user A will put an advertisment on the Hyperledger network where he will specify that he rents his access to S from time X to time Y for the price P. Then user B will be able to pay the required price in HC and get access to S, without disclosing the credentials of A, for the specified interval of time.

The service providers will then perform access control on the blockchain to check if a user has access to a determinate service in a determinate period of time.

How the customers will obtain HyperCash?

    they will receive a periodic amount of it monthly when paying the monthly fee.
    through renting their access to services.
    by buying it.

What the service providers should implement?

    1 HyperLedger node.
    a different login procedure ("Login with HyperLedger").
    Control over session time to avoid abuse.

How the provider will benefit from this technology?

    a monthly fee will be payed by users to partecipate into the network.
    User will be able to buy HyperCash in order to perform transactions. In each rent transaction there will be a fee payed in Hypercash.

The amount of money collected by this 2 revenues will be shared between the service providers who partecipate into the network.

## Design of the project

## Threshold Certification Authority

## Usage

1. Clone the repository
```bash
git clone git@github.com:LorenzoAlluminio/semester_project.git
```

2. Check for prerequisites here https://hyperledger-fabric.readthedocs.io/en/release-2.0/prereqs.html

3. Add this line to the shell config file for convenience
```bash
export PATH=<path to semester_project>/bin:$PATH
```

4. Run this command to download the docker images needed
```bash
bash bootstrap.sh -sb
```

The chaincodes can be deployed on 2 different networks:
- ~~the `chaincode-docker-devmode` network. It is a test network composed of only 1 peer. The instruction are [here](./chaincode-docker-devmode/README.md).~~ This doensn't work anymore. use the other network.
- the `semproj_net` network. It is a realistic network composed of 5 organization, each one with 2 nodes and 1 orderer node. The instruction are [here](./semproj_net/README.md).

A couple of demos scripts can be found under [demos](docs/demos)
