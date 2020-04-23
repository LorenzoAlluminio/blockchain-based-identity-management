package main

import (
    "encoding/json"
    "errors"
    "fmt"
    "time"
    "strings"
    "github.com/hyperledger/fabric-contract-api-go/contractapi"
    "github.com/hyperledger/fabric-chaincode-go/pkg/cid"
)

type MoneyContract struct {
    contractapi.Contract
}

type MoneyAccount struct {
	UserId string `json:"userId"`
	AmountOfMoney  uint `json:"amountOfMoney"`
  StartDate time.Time `json:"startDate"`
  EndDate time.Time `json:"endDate"`
}

func (sc *MoneyContract) GetUserId(ctx contractapi.TransactionContextInterface) (string,error) {
  mspid, err := ctx.GetClientIdentity().GetMSPID()
  if err != nil {
      return "",errors.New("Unable to get the MSPID")
  }
  id, err := ctx.GetClientIdentity().GetID()
  if err != nil {
      return "",errors.New("Unable to get the ID")
  }

  userId := mspid+id
  return userId,nil
}

func (sc *MoneyContract) NewMoneyAccount(ctx contractapi.TransactionContextInterface, userId string, amountOfMoney uint, startDate time.Time, endDate time.Time) error {

  _, err := sc.CheckAdmin(ctx)

  if err != nil{
    return err
  }

  existing, err := ctx.GetStub().GetState(userId)

  if err != nil {
      return errors.New("Unable to interact with world state")
  }

  if existing != nil {
      return fmt.Errorf("Cannot create world state pair with key %s. Already exists", userId)
  }

  if amountOfMoney < 0 {
    return errors.New("Money can't be negative")
  }

  if endDate.Before(startDate) || endDate.Equal(startDate) {
    return errors.New("endDate must be after startDate!")
  }

	ma := new(MoneyAccount)
	ma.UserId = userId
	ma.AmountOfMoney = amountOfMoney
	ma.StartDate = startDate
  ma.EndDate = endDate

	maBytes, _ := json.Marshal(ma)

	err = ctx.GetStub().PutState(userId, []byte(maBytes))

	if err != nil {
		return errors.New("Unable to interact with world state")
	}

	return nil
}

func (sc *MoneyContract) addMoney(ctx contractapi.TransactionContextInterface, userId string, valueAdd uint) error {

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

func (sc *MoneyContract) subMoney(ctx contractapi.TransactionContextInterface, userId string, valueAdd uint) error {
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

  if valueAdd > ma.AmountOfMoney {
    return errors.New("You don't have enough money to perform this operation.")
  }

	ma.AmountOfMoney -= valueAdd

	maBytes, _ := json.Marshal(ma)

	err = ctx.GetStub().PutState(userId, []byte(maBytes))

	if err != nil {
		return errors.New("Unable to interact with world state")
	}

	return nil
}

func (sc *MoneyContract) TransferMoney(ctx contractapi.TransactionContextInterface, userId1 string, userId2 string, value uint) error {

  err := sc.checkCaller(ctx,"TransferMoney")

  if err != nil {
    return err
  }

  if value < 0 {
    return errors.New("Cannot transfer negative amount of money")
  }

  err = sc.subMoney(ctx,userId1,value);
  if err != nil {
    return err;
  }
  err = sc.addMoney(ctx,userId2,value);
  if err != nil {
    return err;
  }
  return nil;
}

func (sc *MoneyContract) updateDates(ctx contractapi.TransactionContextInterface, userId string, startDate time.Time, endDate time.Time) error {


  existing, err := ctx.GetStub().GetState(userId)

  if err != nil {
      return errors.New("Unable to interact with world state")
  }

  if existing == nil {
      return fmt.Errorf("Cannot update money account with key %s. It doesn't exists", userId)
  }

  if endDate.Before(startDate) || endDate.Equal(startDate) {
    return errors.New("endDate must be after startDate!!!")
  }

	ma := new(MoneyAccount)

	err = json.Unmarshal(existing, ma)

	if err != nil {
		return fmt.Errorf("Data retrieved from world state for key %s was not of type MoneyAccount", userId)
	}

	ma.StartDate = startDate
  ma.EndDate = endDate

	maBytes, _ := json.Marshal(ma)

	err = ctx.GetStub().PutState(userId, []byte(maBytes))

	if err != nil {
		return errors.New("Unable to interact with world state")
	}

	return nil
}

func (sc *MoneyContract) GetMoneyAccount(ctx contractapi.TransactionContextInterface) (*MoneyAccount, error) {

  userId,_ := sc.GetUserId(ctx)

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

func (sc *MoneyContract) VerifyPaymentForMoney(ctx contractapi.TransactionContextInterface,  pop int, boughtMoney uint) error {

  userId,_ := sc.GetUserId(ctx)

  existing, err := ctx.GetStub().GetState(userId)

  if err != nil {
      return errors.New("Unable to interact with world state")
  }

  if existing == nil {
      return fmt.Errorf("Cannot verify payment with userId %s. It doesn't exists", userId)
  }

  if boughtMoney < 0 {
    return errors.New("Bought money can't be negative")
  }

  // TODO properly check for proof of payment
  if pop != 1 {
    return errors.New("Proof of payment is not valid")
  }

	return sc.addMoney(ctx,userId,boughtMoney)
}

func (sc *MoneyContract) VerifyPaymentForDate(ctx contractapi.TransactionContextInterface, pop int, startDate time.Time, endDate time.Time) error {

  userId,_ := sc.GetUserId(ctx)

  existing, err := ctx.GetStub().GetState(userId)

  if err != nil {
      return errors.New("Unable to interact with world state")
  }

  if existing == nil {
      return fmt.Errorf("Cannot verify payment with userId %s. It doesn't exists", userId)
  }

  if endDate.Before(startDate) || endDate.Equal(startDate) {
    return errors.New("endDate must be after startDate!!!")
  }

  // TODO properly check for proof of payment
  if pop != 1 {
    return errors.New("Proof of payment is not valid")
  }

	return sc.updateDates(ctx,userId,startDate,endDate)
}

func (sc *MoneyContract) HasAccess(ctx contractapi.TransactionContextInterface, userId string, currentTime time.Time) error {

  err := sc.checkCaller(ctx,"HasAccess")

  if err != nil {
    return err
  }

  existing, err := ctx.GetStub().GetState(userId)

  if err != nil {
      return errors.New("Unable to interact with world state")
  }

  if existing == nil {
      return fmt.Errorf("Cannot verify access with userId %s. It doesn't exists", userId)
  }

  ma := new(MoneyAccount)

  err = json.Unmarshal(existing, ma)

  if err != nil {
    return fmt.Errorf("Data retrieved from world state for userId %s was not of type MoneyAccount", userId)
  }

  if currentTime.Before(ma.StartDate){
    return fmt.Errorf("userId %s has not access to the network in this period of time", userId)
  }

  if currentTime.After(ma.EndDate) || currentTime.Equal(ma.EndDate) {
    return fmt.Errorf("userId %s has not access to the network in this period of time", userId)
  }

	return nil
}

func (sc *MoneyContract) CheckAdmin(ctx contractapi.TransactionContextInterface) (string,error) {

  stub := ctx.GetStub()

  mspid, err := cid.GetMSPID(stub)
  if err != nil {
      return "", fmt.Errorf("Unable to get the MSPID")
  }


  found, err := cid.HasOUValue(stub, "admin")
  if err != nil {
      return "", fmt.Errorf("error retriving OU")
     // Return an error
  }
  if !found {
    return "", fmt.Errorf("Requires to be admin to perform this action")
     // The client identity is not part of the Organizational Unit admin
  }

  return mspid,nil

}

func (sc *MoneyContract) checkCaller(ctx contractapi.TransactionContextInterface, find string) (error) {

  stub := ctx.GetStub()

  proposal,err := stub.GetSignedProposal()

  if err != nil {
    return fmt.Errorf("Impossible to retrive the signed proposal")
  }

  str := fmt.Sprintf("%s",proposal)

  res := strings.Contains(str,find)

  if res{
    return fmt.Errorf("You are not allowed to directly call this chaincode")
  }
  return nil

}
