package main

import (
    "errors"
    "fmt"
    "github.com/hyperledger/fabric/common/util"
    "encoding/json"
    "time"
    "strings"
    "github.com/hyperledger/fabric-contract-api-go/contractapi"
    "github.com/hyperledger/fabric-chaincode-go/pkg/cid"
)

type TimeSlot struct{
    StartTime time.Time `json:"StartTime"`
    EndTime time.Time `json:"EndTime"`
}

//struct that take care of the constraction of the key (User + Prvoider)
type Key struct{
  UserID string `json:"UserID"`
  ProviderID string `json:"ProviderID"`
}

//structure of the value stored in the DB (Sub + array of time slot)
type Subscription struct {
	SubID  string `json:"SubID"`
	TimeSlots []TimeSlot `json:"TimeSlots"`
}

// SubscriptionContract contract for handling writing and reading from the world state
type SubscriptionContract struct {
    contractapi.Contract
}

// handle the access to a service through the service blockchain
// return a time interval which represent the period in which the user has access
func (sc *SubscriptionContract) ServiceAccess(ctx contractapi.TransactionContextInterface, UserID string) (*TimeSlot,error) {

      ProviderID, err := sc.CheckAdmin(ctx)

      if err != nil{
        return nil,err
      }

      kStr := Key{
        UserID: UserID,
        ProviderID: ProviderID,
      }

      key, _ := json.Marshal(kStr)

      query_result, err := ctx.GetStub().GetState(string(key))

      if err != nil {
          return nil, errors.New("Unable to interact with world state")
      }

      if query_result == nil {
          return nil, fmt.Errorf("Cannot read world state pair with key %s. Does not exist", key)
      }

      now := time.Now() // getting the current time to use it as time interval check

      invokeArgs := util.ToChaincodeArgs("HasAccess", UserID, now.Format("2006-01-02T15:04:05Z"))
      resp := ctx.GetStub().InvokeChaincode("money", invokeArgs, ctx.GetStub().GetChannelID())

      if (resp.GetStatus() != 200) {
        return nil, fmt.Errorf("Impossible to login, user does not have access to the blockchain %d time: %s", resp.GetStatus(), now.Format("2006-01-02T15:04:05Z"))
      }

      // need to re-add expired time intervarls
      /*
      invokeArgs := util.ToChaincodeArgs("HasAccess", UserID, now)
      resp := ctx.GetStub().InvokeChaincode("subscriptions", invokeArgs, ctx.GetStub().GetChannelID())

      */


      value := Subscription{}

      _ = json.Unmarshal(query_result, &value)


      for _, it := range value.TimeSlots{

        if (now.After(it.StartTime) || now.Equal(it.StartTime)) && now.Before(it.EndTime){
            return &it, nil
        }

      }

      return nil, errors.New("The provided key does not have an active subscripton")

}
// Create or update the state of a subscription for a user (called only from the service provider)
func (sc *SubscriptionContract) IssueSubscription(ctx contractapi.TransactionContextInterface, UserID string, SubID string, StartTime time.Time, EndTime time.Time) error {

    ProviderID, err := sc.CheckAdmin(ctx)

    if err != nil{
      return err
    }

    if EndTime.Before(StartTime) {
      return errors.New("Error in time format")
    }

    kStr := Key{
      UserID: UserID,
      ProviderID: ProviderID,
    }

    key, _ := json.Marshal(kStr)

    query_result, err := ctx.GetStub().GetState(string(key))

    if err != nil {
      return errors.New("Unable to get info from world state")
    }

    if query_result != nil {

      value := Subscription{}

      _ = json.Unmarshal(query_result, &value)

      new := TimeSlot{
        StartTime: StartTime,
        EndTime: EndTime,
      }

      // possibiliti to merge with previous slots or owerride them in future

      value.TimeSlots  = append(value.TimeSlots,new)

      result, _ := json.Marshal(value)

      err = ctx.GetStub().PutState(string(key), result)

      if err != nil {
          return errors.New("Unable to update the world state")
      }

    } else {
      ts := TimeSlot{
        StartTime: StartTime,
        EndTime: EndTime,
      }

      timeSlot := make([]TimeSlot,10)
      timeSlot = append(timeSlot, ts)

      vStr := Subscription{
        SubID: SubID,
        TimeSlots: timeSlot,
        }

      value, _ := json.Marshal(vStr)

      err = ctx.GetStub().PutState(string(key), value)

      if err != nil {
          return errors.New("Unable to add a new element with world state")
      }
    }


    return nil
}

// Create or update the state of a subscription for a user (called from offerts smartContract)
func (sc *SubscriptionContract) RentSubscription(ctx contractapi.TransactionContextInterface, UserID string, SubID string, ProviderID string, StartTime time.Time, EndTime time.Time) error {

  err := sc.checkCaller(ctx,"RentSubscription")

  if err != nil {
    return err
  }


  if EndTime.Before(StartTime) {
    return errors.New("Error in time format")
  }

  kStr := Key{
    UserID: UserID,
    ProviderID: ProviderID,
  }

  key, _ := json.Marshal(kStr)

  query_result, err := ctx.GetStub().GetState(string(key))

  if err != nil {
    return errors.New("Unable to interact with world state")
  }

  if query_result != nil {

    value := Subscription{}

    _ = json.Unmarshal(query_result, &value)

    new := TimeSlot{
      StartTime: StartTime,
      EndTime: EndTime,
    }

    // possibiliti to merge with previous slots or owerride them in future

    value.TimeSlots  = append(value.TimeSlots,new)

    result, _ := json.Marshal(value)

    err = ctx.GetStub().PutState(string(key), result)

    if err != nil {
        return errors.New("Unable to interact with world state")
    }

  } else {
    ts := TimeSlot{
      StartTime: StartTime,
      EndTime: EndTime,
    }

    timeSlot := make([]TimeSlot,1)
    timeSlot = append(timeSlot, ts)

    vStr := Subscription{
      SubID: SubID,
      TimeSlots: timeSlot,
      }

    value, _ := json.Marshal(vStr)

    err = ctx.GetStub().PutState(string(key), value)

    if err != nil {
        return errors.New("Unable to interact with world state")
    }
  }
  return nil
  }

// Remove the time slot that has been added to the offer world state from the user
func (sc *SubscriptionContract) SplitSubscription(ctx contractapi.TransactionContextInterface, UserID string, SubID string, ProviderID string, StartTime time.Time, EndTime time.Time) error {

  err := sc.checkCaller(ctx,"SplitSubscription")

  if err != nil {
    return err
  }

  if EndTime.Before(StartTime) {
    return errors.New("Error in time format")
  }

  kStr := Key{
    UserID: UserID,
    ProviderID: ProviderID,
  }

  key, _ := json.Marshal(kStr)

  query_result, err := ctx.GetStub().GetState(string(key))

  if err != nil {
      return errors.New("Unable to interact with world state")
  }

  if query_result == nil {
      return fmt.Errorf("Cannot update world state pair with key %s. Does not exist", key)
  }

  value := Subscription{}

  _ = json.Unmarshal(query_result, &value)

  //now := time.Now() possible to add later to clean the slice

  found := false

  for i, it := range value.TimeSlots{

    //remove comment if want to clean the list from old Subscription
    /*if it.EndTime.Before(Now){
      l.Remove(it)
      continue
    }*/

    //case in which the renting slot is completly inside another slot
    if StartTime.After(it.StartTime) && EndTime.Before(it.EndTime) {

      new := TimeSlot{
        StartTime: EndTime.Add(time.Second * 1),
        EndTime: it.EndTime,
      }

      value.TimeSlots[i].EndTime = StartTime.Add(time.Second *(-1))
      value.TimeSlots  = append(value.TimeSlots,new)
      found = true
      break
    }

    //case in which the renting slot perfectly fits with one in the lsit
    if StartTime.Equal(it.StartTime) && EndTime.Equal(it.EndTime) {

      value.TimeSlots[i] = value.TimeSlots[len(value.TimeSlots)-1] // Copy last element to index i.
      value.TimeSlots[len(value.TimeSlots)-1] = TimeSlot{}  // Erase last element (write zero value).
      value.TimeSlots = value.TimeSlots[:len(value.TimeSlots)-1]   // Truncate slice.
      found = true
      break
    }

    //case in which the rentig slot start at same time
    if StartTime.Equal(it.StartTime) && EndTime.Before(it.EndTime) {
      value.TimeSlots[i].StartTime = EndTime.Add(time.Second *1)  //posticipate the start time of the element in the list
      found = true
      break
    }

    //case in which bot slots end at the same time
    if StartTime.After(it.StartTime) && EndTime.Equal(it.EndTime) {
      value.TimeSlots[i].EndTime = StartTime.Add(time.Second *(-1)) //anticipate the EndTime of the slot in the listS
      found = true
      break
    }

  }

  //add not IsNotFound
  if found == false{
    return errors.New("Interval not found")
  }

  result, _ := json.Marshal(value)

  err = ctx.GetStub().PutState(string(key), result)

  if err != nil {
      return errors.New("Unable to interact with world state")
  }

  return nil
}

// Read returns the value at key in the world state
func (sc *SubscriptionContract) GetInfoUser(ctx contractapi.TransactionContextInterface, UserID string, ProviderID string) (*Subscription, error) {

    kStr := Key{
      UserID: UserID,
      ProviderID: ProviderID,
    }

    key, _ := json.Marshal(kStr)

    query_result, err := ctx.GetStub().GetState(string(key))

    if err != nil {
        return nil, errors.New("Unable to interact with world state")
    }

    if query_result == nil {
        return nil, fmt.Errorf("Cannot read world state pair with key %s. Does not exist", key)
    }

    value := Subscription{}

    _ = json.Unmarshal(query_result, &value)

    return &value, nil
}

func (sc *SubscriptionContract) CheckAdmin(ctx contractapi.TransactionContextInterface) (string,error) {

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

func (sc *SubscriptionContract) checkCaller(ctx contractapi.TransactionContextInterface, find string) (error) {

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
