package main

import (
    "github.com/hyperledger/fabric-contract-api-go/contractapi"
)

func main() {
    OffersContract := new(OffersContract)

    cc, err := contractapi.NewChaincode(OffersContract)

    if err != nil {
        panic(err.Error())
    }

    if err := cc.Start(); err != nil {
        panic(err.Error())
    }
}
