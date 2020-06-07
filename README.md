# Blockchain Based Identity Management - Semester project

## Team members

- Edoardo Giordano:   Edoardo.Giordano@eurecom.fr
- Fulvio di Girolamo: Fulvio.Di-Girolamo@eurecom.fr
- Lorenzo Alluminio:  Lorenzo.Alluminio@eurecom.fr

## Why this project

### The idea

The goal of this project is to create an autonomous market of accesses to services by creating an hyperledger network between multiple service providers of different kind (e.g video  & music streaming, e-learning, vpn access, hosting … ).
This network will allow users to rent to other users their access to services and gain in return HyperCash (HC). Then they will be able to rent access to other services belonging to the network using the gained currency. Users will not be able to convert HyperCash into real money.
The service providers will then perform access control on the blockchain to check if a user has access to a determinate service in a determinate period of time. Therefore all this sharing of accesses can be done without the disclosure of the service providers credentials of any user. 

Example: User A has access to service S. user A will put an advertisment on the Hyperledger network where he will specify that he rents his access to S from time X to time Y for the price P. Then user B will be able to pay the required price P in HC and get access to S, without disclosing the credentials of A, for the specified interval of time.

### Key points

How the users will obtain HyperCash?
- They will receive a periodic amount of it when paying the fee that is needed in order to have granted the access to the network.
- Through renting their access to services.
- By explicitly exchanging FIAT money (dollars, euros ...) for HC.

What the service providers should implement?
- 1 HyperLedger peer and 1 Hyperledger ordering node.
- A Certification Authority.
- a different login procedure ("Login with HyperLedger").
- Control over session time to avoid abuse.

How the provider will benefit from this technology?
- A monthly fee will be payed by users to partecipate into the network and they are also able to buy HC if they want to. The total sum of money collected from this 2 revenues will then be divided between all the organizations (equally or proportionally to their "appearances" on the network)
- In each rent transaction there will be a fee payed in Hypercash. This will not directly bring an economic benefit to the providers, but it will lead to a reduction of the amount of HC of the users, that will be "obliged" to buy more if he wants to continue to use the service.
The amount of this fee can be decided by the organizations.

How the access control on users is performed?
- The providers will provide the option to "log in with hyperledger", they will retrieve the id of the user from his certificate and they will check if the user has access to the service by querying the blockchain.

## Design of the project

- [Network architecture & interactions](docs/Design.md)
- [Threshold Certification Authority](docs/TSIntegration.md)

## Usage & Demos

- [Usage of the project & demos](docs/Usage.md)

## Check out this ASCII-art powered user story

- [User story](docs/story.md)
