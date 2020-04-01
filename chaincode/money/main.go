package main

import (
    "github.com/hyperledger/fabric-contract-api-go/contractapi"
)

func main() {
    MoneyContract := new(MoneyContract)

    cc, err := contractapi.NewChaincode(MoneyContract)

    if err != nil {
        panic(err.Error())
    }

    if err := cc.Start(); err != nil {
        panic(err.Error())
    }
}
