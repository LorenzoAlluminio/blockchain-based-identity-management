package main

import (
    "encoding/json"
    "errors"
    "fmt"
    "github.com/hyperledger/fabric-contract-api-go/contractapi"
)

type MoneyContract struct {
    contractapi.Contract
}

type MoneyAccount struct {
	UserId string `json:"userId"`
	AmountOfMoney  int `json:"amountOfMoney"`
  LastPaymentDate string `json:"lastPaymentDate"`
}


func (sc *MoneyContract) NewMoneyAccount(ctx contractapi.TransactionContextInterface, userId string, amountOfMoney int, lastPaymentDate string) error {
  existing, err := ctx.GetStub().GetState(userId)

  if err != nil {
      return errors.New("Unable to interact with world state")
  }

  if existing != nil {
      return fmt.Errorf("Cannot create world state pair with key %s. Already exists", userId)
  }

	ma := new(MoneyAccount)
	ma.UserId = userId
	ma.AmountOfMoney = amountOfMoney
	ma.LastPaymentDate = lastPaymentDate

	maBytes, _ := json.Marshal(ma)

	err = ctx.GetStub().PutState(userId, []byte(maBytes))

	if err != nil {
		return errors.New("Unable to interact with world state")
	}

	return nil
}

func (sc *MoneyContract) AddMoney(ctx contractapi.TransactionContextInterface, userId string, valueAdd int) error {
  existing, err := ctx.GetStub().GetState(userId)

  if err != nil {
      return errors.New("Unable to interact with world state")
  }

  if existing == nil {
      return fmt.Errorf("Cannot update money account with key %s. It doesn't exists", userId)
  }

  if valueAdd < 0 {
    return errors.New("Cannot add negative amount of money")
  }

	ma := new(MoneyAccount)

	err = json.Unmarshal(existing, ma)

	if err != nil {
		return fmt.Errorf("Data retrieved from world state for key %s was not of type MoneyAccount", userId)
	}

	ma.AmountOfMoney += valueAdd

	maBytes, _ := json.Marshal(ma)

	err = ctx.GetStub().PutState(userId, []byte(maBytes))

	if err != nil {
		return errors.New("Unable to interact with world state")
	}

	return nil
}

func (sc *MoneyContract) SubMoney(ctx contractapi.TransactionContextInterface, userId string, valueAdd int) error {
  existing, err := ctx.GetStub().GetState(userId)

  if err != nil {
      return errors.New("Unable to interact with world state")
  }

  if existing == nil {
      return fmt.Errorf("Cannot update money account with key %s. It doesn't exists", userId)
  }

  if valueAdd < 0 {
    return errors.New("Cannot sub negative amount of money")
  }

	ma := new(MoneyAccount)

	err = json.Unmarshal(existing, ma)

	if err != nil {
		return fmt.Errorf("Data retrieved from world state for key %s was not of type MoneyAccount", userId)
	}

	ma.AmountOfMoney -= valueAdd

	maBytes, _ := json.Marshal(ma)

	err = ctx.GetStub().PutState(userId, []byte(maBytes))

	if err != nil {
		return errors.New("Unable to interact with world state")
	}

	return nil
}

func (sc *MoneyContract) UpdateLastPaymentDate(ctx contractapi.TransactionContextInterface, userId string, newDate string) error {
  existing, err := ctx.GetStub().GetState(userId)

  if err != nil {
      return errors.New("Unable to interact with world state")
  }

  if existing == nil {
      return fmt.Errorf("Cannot update money account with key %s. It doesn't exists", userId)
  }

	ma := new(MoneyAccount)

	err = json.Unmarshal(existing, ma)

	if err != nil {
		return fmt.Errorf("Data retrieved from world state for key %s was not of type MoneyAccount", userId)
	}

	ma.LastPaymentDate = newDate

	maBytes, _ := json.Marshal(ma)

	err = ctx.GetStub().PutState(userId, []byte(maBytes))

	if err != nil {
		return errors.New("Unable to interact with world state")
	}

	return nil
}

func (sc *MoneyContract) GetMoneyAccount(ctx contractapi.TransactionContextInterface, userId string) (*MoneyAccount, error) {
  existing, err := ctx.GetStub().GetState(userId)

  if err != nil {
      return nil,errors.New("Unable to interact with world state")
  }

  if existing == nil {
      return nil,fmt.Errorf("Cannot get money account with userId %s. It doesn't exists", userId)
  }

	ma := new(MoneyAccount)

	err = json.Unmarshal(existing, ma)

	if err != nil {
		return nil, fmt.Errorf("Data retrieved from world state for userId %s was not of type MoneyAccount", userId)
	}

	return ma, nil
}

func (sc *MoneyContract) VerifyPaymentForMoney(ctx contractapi.TransactionContextInterface, userId string, pop int, boughtMoney int) error {
  existing, err := ctx.GetStub().GetState(userId)

  if err != nil {
      return errors.New("Unable to interact with world state")
  }

  if existing == nil {
      return fmt.Errorf("Cannot verify payment with userId %s. It doesn't exists", userId)
  }

  // TODO properly check for proof of payment
  if pop != 1 {
    return errors.New("Proof of payment is not valid")
  }

	return AddMoney(ctx,userId,boughtMoney)
}

func (sc *MoneyContract) VerifyPaymentForDate(ctx contractapi.TransactionContextInterface, userId string, pop int, newDate string) error {
  existing, err := ctx.GetStub().GetState(userId)

  if err != nil {
      return errors.New("Unable to interact with world state")
  }

  if existing == nil {
      return fmt.Errorf("Cannot verify payment with userId %s. It doesn't exists", userId)
  }

  // TODO properly check for proof of payment
  if pop != 1 {
    return errors.New("Proof of payment is not valid")
  }

	return UpdateLastPaymentDate(ctx,userId,newDate)
}
