package main

import (
    "github.com/hyperledger/fabric-contract-api-go/contractapi"
)

func main() {
    subscriptionContract := new(SubscriptionContract)

    cc, err := contractapi.NewChaincode(subscriptionContract)

    if err != nil {
        panic(err.Error())
    }

    if err := cc.Start(); err != nil {
        panic(err.Error())
    }
}
