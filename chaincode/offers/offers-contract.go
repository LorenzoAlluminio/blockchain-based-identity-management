package main

import (
  "time"
  "fmt"
  "strconv"
  "encoding/json"

  "github.com/hyperledger/fabric-contract-api-go/contractapi"
  "github.com/hyperledger/fabric/common/util"
  "github.com/hyperledger/fabric-chaincode-go/pkg/cid"
)

type OffersContract struct {
  contractapi.Contract
}

// This struct contains the fields used to uniquely identify each entry
// in the offers world state.
// UserID:    User ID which identifies the seller on the blockchain
// SubID:     Unique identifier of a specific subscription
// StartTime: Beginning of time window to access the subscription
// TODO UserID might be the hash of the user's certificate on the
//      blockchain
// TODO SubID is unique for all providers, possibly use higher bits to
//      identify the provider? In this case would not need the 
//      ProviderID field in OfferData anymore...
type OfferKey struct {
  UserID      string      `json:"UserID"`
  SubID       string      `json:"SubID"`
  StartTime   time.Time   `json:"StartTime"`
}

// This struct contains the other fields which define an offer in the
// world state
// ProviderID:   The name of the service provider to which pertains the
//            subscription
// EndTime:   End of the time window to access the subscription
// Price:     Cost of the offer in HyperCoins
type OfferData struct {
  ProviderID    string      `json:"ProviderID"`
  EndTime       time.Time   `json:"EndTime"`
  Price         uint        `json:"Price"`
}

type QueryResult struct {
  Key   *OfferKey           `json:"Key"`
  Data  *OfferData          `json:"Data"`
}

func (s *OffersContract) GetUserId(ctx contractapi.TransactionContextInterface) (string,error) {
  mspid, err := ctx.GetClientIdentity().GetMSPID()
  if err != nil {
      return "", fmt.Errorf("Unable to get the MSPID")
  }
  id, err := ctx.GetClientIdentity().GetID()
  if err != nil {
      return "", fmt.Errorf("Unable to get the ID")
  }

  userId := mspid+id
  return userId,nil
}


// Generate a new offer for user identified by UserID. Notice that 
// SplitSubscription is invoked when the offer is generated, which means
// that until he decides to remove the offer the seller will not have
// access to the subscription over the specified time interval even if
// no one has bought it. If the user does not actually own the specified
// subscription over the given time interval, an error is returned.
// TODO:  UserID should be recovered via getCreator() in order to make sure 
//        that access control is correctly performed.
// TODO:  how to handle offers involving intervals which have already 
//        expired?
// TODO:  parameter check should also take into account time granularity,
//        time boundaries, max duration, min StartTime distance...
func (s *OffersContract) NewOffer(ctx contractapi.TransactionContextInterface, SubID string, ProviderID string, StartTime time.Time, EndTime time.Time, Price uint) error {
  // Check if user has the right to access the blockchain
  UserID, _ := s.GetUserId(ctx)

  now := time.Now()
  invokeArgs := util.ToChaincodeArgs("HasAccess", UserID, now.Format("2006-01-02T15:04:05Z"))
  resp := ctx.GetStub().InvokeChaincode("money", invokeArgs, ctx.GetStub().GetChannelID())

  if (resp.GetStatus() != 200) {
    return fmt.Errorf("You have currently no access to the blockchain. Please subscribe.\n")
  }

  // Check on correctness of parameters
  if (!EndTime.After(StartTime)) {
    return fmt.Errorf("The specified offer interval is malformed.\n")
  }

  // Check if the offer's interval is included within the duration of the
  // user's subscription to the blockchain
  invokeArgs = util.ToChaincodeArgs("HasAccess", UserID, EndTime.Format("2006-01-02T15:04:05Z"))
  resp = ctx.GetStub().InvokeChaincode("money", invokeArgs, ctx.GetStub().GetChannelID())

  if (resp.GetStatus() != 200) {
    return fmt.Errorf("You must be subscribed to the blockchain for the entire duration of your offer.\n")
  }

  // Invoke the subscription chaincode
  invokeArgs = util.ToChaincodeArgs("SplitSubscription", UserID, SubID, ProviderID, StartTime.Format("2006-01-02T15:04:05Z"), EndTime.Format("2006-01-02T15:04:05Z"))
  resp = ctx.GetStub().InvokeChaincode("subscriptions", invokeArgs, ctx.GetStub().GetChannelID())

  status := resp.GetStatus()

  // Arbitrarily set to be able to test even if subscriptions does 
  // not work correctly
  //status = 200

  if (status != 200) {
    return fmt.Errorf("It was not possible to create the offer. Do you own the subscription over that interval?\n")
  }

  // Create the key and value objects and write to the ledger

  keyObj := OfferKey{
    UserID:     UserID,
    SubID:      SubID,
    StartTime:  StartTime,
  }

  valueObj := OfferData{
    ProviderID: ProviderID,
    EndTime:    EndTime,
    Price:      Price,
  }

  key, _ := json.Marshal(keyObj)
  value, _ := json.Marshal(valueObj)

  ctx.GetStub().PutState(string(key), value)

  return nil
}

// This function allows the user identified by BuyerID to buy the offer 
// identified by SellerID, SubID and StartTime. If the offer does exist,
// an amount of HyperCash corresponding to its price is transferred from
// BuyerID's account to SellerID's account, and the rights over the given
// subscription in the given time interval are tranferred to BuyerID. If
// BuyerID does not own enough HyperCash currency, the transaction fails.
// TODO:  BuyerID should be recovered via getCreator() in order to make sure 
//        that access control is correctly performed.
func (s *OffersContract) AcceptOffer(ctx contractapi.TransactionContextInterface, SellerID string, SubID string, StartTime time.Time) error {
  // Check if BuyerID has the right to access the blockchain
  BuyerID, _ := s.GetUserId(ctx)

  now := time.Now()
  invokeArgs := util.ToChaincodeArgs("HasAccess", BuyerID, now.Format("2006-01-02T15:04:05Z"))
  resp := ctx.GetStub().InvokeChaincode("money", invokeArgs, ctx.GetStub().GetChannelID())

  if (resp.GetStatus() != 200) {
    return fmt.Errorf("You have currently no access to the blockchain. Please subscribe.\n")
  }

  // Extract offer data from the world state, if present, else return 
  // an error
  keyObj := OfferKey{
    UserID:     SellerID,
    SubID:      SubID,
    StartTime:  StartTime,
  }

  key, _ := json.Marshal(keyObj)

  result, err := ctx.GetStub().GetState(string(key))

  if err != nil {
    return fmt.Errorf("An error occurred while querying the world state.\n")
  }

  if result == nil {
    return fmt.Errorf("The specified offer does not exist.\n")
  }

  value := OfferData{}

  _ = json.Unmarshal(result, &value)

  // Remove the offer's price from BuyerID's balance, if possible, else
  // return an error
  invokeArgs = util.ToChaincodeArgs("TransferMoney", BuyerID, SellerID, strconv.FormatUint(uint64(value.Price), 10))
  resp = ctx.GetStub().InvokeChaincode("money", invokeArgs, ctx.GetStub().GetChannelID())

  if resp.GetStatus() != 200 {
    return fmt.Errorf("It was not possible to transfer HyperCash. Do you own enough HyperCash?\n")
  }

  // Transfer the rights to BuyerID
  invokeArgs = util.ToChaincodeArgs("RentSubscription", BuyerID, SubID, value.ProviderID, StartTime.Format("2006-01-02T15:04:05Z"), value.EndTime.Format("2006-01-02T15:04:05Z"))
  resp = ctx.GetStub().InvokeChaincode("subscriptions", invokeArgs, ctx.GetStub().GetChannelID())

  status := resp.GetStatus()

  // Arbitrarily set to be able to test even if subscriptions does not 
  // work correctly
  //status = 200

  if status != 200 {
    return fmt.Errorf("An error occurred while re-assigning the subscription.\n")
  }

  // Delete the accepted offer from the world state
  err = ctx.GetStub().DelState(string(key))

  if err != nil {
    return fmt.Errorf("Failed to delete the accepted offer from the world state.\n")
  }

  return nil
}

// Remove an offer posted by UserID from the world state.
// TODO:  UserID should be recovered via getCreator() in order to make sure
//        that access control is correctly performed.
func (s *OffersContract) RemoveOffer(ctx contractapi.TransactionContextInterface, SubID string, StartTime time.Time) error {
  // Check if user has the right to access the blockchain
  UserID, _ := s.GetUserId(ctx)

  now := time.Now()
  invokeArgs := util.ToChaincodeArgs("HasAccess", UserID, now.Format("2006-01-02T15:04:05Z"))
  resp := ctx.GetStub().InvokeChaincode("money", invokeArgs, ctx.GetStub().GetChannelID())

  if (resp.GetStatus() != 200) {
    return fmt.Errorf("You have currently no access to the blockchain. Please subscribe.\n")
  }

  keyObj := OfferKey{
    UserID:     UserID,
    SubID:      SubID,
    StartTime:  StartTime,
  }

  key, _ := json.Marshal(keyObj)

  err := ctx.GetStub().DelState(string(key))

  if err != nil {
    return fmt.Errorf("Failed to remove the offer.\n")
  }

  return nil
}

// Return the set of offers currently in the world state
// TODO:  attenzione al totalQueryLimit in core.yaml!
func (s *OffersContract) QueryAllOffers(ctx contractapi.TransactionContextInterface) ([]QueryResult, error) {
  resultsIterator, err := ctx.GetStub().GetStateByRange("", "")

  if err != nil {
    return nil, err
  }
  defer resultsIterator.Close()

  results := []QueryResult{}

  for resultsIterator.HasNext() {
    queryResponse, err := resultsIterator.Next()

    if err != nil {
      return nil, err
    }

    key := new(OfferKey)
    data := new(OfferData)

    _ = json.Unmarshal([]byte(queryResponse.Key), key)
    _ = json.Unmarshal(queryResponse.Value, data)

    queryResult := QueryResult{Key: key, Data: data}
    results = append(results, queryResult)
  }

  return results, nil
}

// TODO:  DeleteAllOffers function
func (s *OffersContract) PrintCert(ctx contractapi.TransactionContextInterface) (string, error) {
  mspid, err := cid.GetMSPID(ctx.GetStub())
  id, err := cid.GetID(ctx.GetStub())

  return mspid+id, err
}
