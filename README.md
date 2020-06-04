# Semester project

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
