# Blockchain Based Identity Management - Semester project

## Team members

- Edoardo Giordano:   Edoardo.Giordano@eurecom.fr
- Fulvio di Girolamo: Fulvio.Di-Girolamo@eurecom.fr
- Lorenzo Alluminio:  Lorenzo.Alluminio@eurecom.fr

## Why this project

### The idea

The goal of this project is to create an autonomous market of access to services by creating hyperledger network between multiple service providers of different kind (e.g video streaming, hosting, vpn access ...).
This network will allow users to rent to other users their access to services and gain in return HyperCash (HC). Then they will be able to rent access to other services belonging to the network using the gained currency. Therefore this technology will basically allow the creation of an autonomous marketplace of access to services between users. Users will not be able to convert HyperCash into real money.
The service providers will then perform access control on the blockchain to check if a user has access to a determinate service in a determinate period of time.

Example: User A has access to service S. user A will put an advertisment on the Hyperledger network where he will specify that he rents his access to S from time X to time Y for the price P. Then user B will be able to pay the required price P in HC and get access to S, without disclosing the credentials of A, for the specified interval of time.

### Key questions

How the users will obtain HyperCash?
- They will receive a periodic amount of it monthly when paying the monthly fee that is needed in order to have granted the access to the network.
- Through renting their access to services.
- By buying it.

What the service providers should implement?
- 1 HyperLedger peer and 1 Hyperledger ordering node.
- A Certification Authority.
- a different login procedure ("Login with HyperLedger").
- Control over session time to avoid abuse.

How the provider will benefit from this technology?
- A monthly fee will be payed by users to partecipate into the network and they are also able to buy HC if they want to. The total sum of money collected from this 2 revenues will be then divided between all the organizations (equally or proportionally to their "usage" on the network)
- User will be able to buy HyperCash in order to perform transactions. In each rent transaction there will be a fee payed in Hypercash. This will not directly bring an economic benefit to the providers, but it will lead to a reduction of the amount of HC of the user, that will be "obliged" to buy more in order to gain back HC.
The amount of this fee can be decided by the organizations.

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
