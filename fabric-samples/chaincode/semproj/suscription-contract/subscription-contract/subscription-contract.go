package main

import (
    "errors"
    "fmt"
    "container/list"
    "encoding/json"
    "time"
    "github.com/hyperledger/fabric-contract-api-go/contractapi"
)

type TimeSlot struct{
    StartTime time.Time `json:"StartTime"`
    EndTime time.Time `json:"EndTime"`
}

type WorldState struct{
  UserID string `json:"UserID"`
  SubID string `json:"SubID"`
  ProviderID  string `json:"ProviderID"`
	TimeSlots list.List `json:"TimeSlots"`
}

type Key struct{
  UserID string `json:"UserID"`
  SubID string `json:"SubID"`
}

type Subscription struct {
	ProviderID  string `json:"ProviderID"`
	TimeSlots []TimeSlot `json:"TimeSlots"`
}

// SubscriptionContract contract for handling writing and reading from the world state
type SubscriptionContract struct {
    contractapi.Contract
}



// Create or update the state of a subscription for a user (called only from the service provider)
func (sc *SubscriptionContract) IssueSubscription(ctx contractapi.TransactionContextInterface, UserID string, SubID string, ProviderID string, StartTime time.Time, EndTime time.Time) error {

    if EndTime.Before(StartTime) {
      return errors.New("Error in time format")
    }

    kStr := Key{
      UserID: UserID,
      SubID: SubID,
    }

    key, _ := json.Marshal(kStr)

    query_result, err := ctx.GetStub().GetState(string(key))

    if err != nil {
      return errors.New("Unable to interact with world state")
    }

    if query_result != nil {

      value := Subscription{}

      _ = json.Unmarshal(query_result, value)

      new := TimeSlot{
        StartTime: StartTime,
        EndTime: EndTime,
      }

      // possibiliti to merge with previous slots or owerride them in future
      value.TimeSlots.PushBack(new)

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

      l := list.New()
      l.PushBack(ts)

      vStr := Subscription{
        ProviderID: ProviderID,
        TimeSlots: *l,
        }

      value, _ := json.Marshal(vStr)

      err = ctx.GetStub().PutState(string(key), value)

      if err != nil {
          return errors.New("Unable to interact with world state")
      }
    }


    return nil
}

// Create or update the state of a subscription for a user (called from offerts smartContract)
func (sc *SubscriptionContract) RentSubscription(ctx contractapi.TransactionContextInterface, UserID string, SubID string, ProviderID string, StartTime time.Time, EndTime time.Time) error {

    if EndTime.Before(StartTime) {
      return errors.New("Error in time format")
    }

    kStr := Key{
      UserID: UserID,
      SubID: SubID,
    }

    key, _ := json.Marshal(kStr)

    query_result, err := ctx.GetStub().GetState(string(key))

    if err != nil {
      return errors.New("Unable to interact with world state")
    }

    if query_result != nil {

      value := Subscription{}
      _ = json.Unmarshal(query_result, value)

      new := TimeSlot{
        StartTime: StartTime,
        EndTime: EndTime,
      }

      // possibiliti to merge with previous slots or owerride them in future
      value.TimeSlots.PushBack(new)

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

      l := list.New()
      l.PushBack(ts)

      vStr := Subscription{
        ProviderID: ProviderID,
        TimeSlots: *l,
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
func (sc *SubscriptionContract) SplitSub(ctx contractapi.TransactionContextInterface, UserID string, SubID string, ProviderID string, StartTime time.Time, EndTime time.Time) error {

    if EndTime.Before(StartTime) {
      return errors.New("Error in time format")
    }

    kStr := Key{
      UserID: UserID,
      SubID: SubID,
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

    _ = json.Unmarshal(query_result, value)

    l := value.TimeSlots

    now := time.Now()

    for it := l.Front(); it != nil ; it = it.Next(){

        //remove comment if want to clean the list from old Subscription
        /*if it.EndTime.Before(Now){
          l.Remove(it)
          continue
        }*/

        strc := TimeSlot{}

        strc = it.Value

        //case in which the renting slot is completly inside another slot
        if StartTime.After(strc.StartTime) && EndTime.Before(strc.EndTime) {

          new := TimeSlot{
            StartTime: EndTime,
            EndTime: strc.EndTime,
          }

          strc.EndTime = StartTime
          l.InsertAfter(new,it)

          break
        }

        //case in which the renting slot perfectly fits with one in the lsit
        if StartTime.Equal(strc.StartTime) && EndTime.Equal(strc.EndTime) {
          l.Remove(new,it)
          break
        }

        //case in which the rentig slot start at same time
        if StartTime.Equal(strc.StartTime) && EndTime.Before(strc.EndTime) {
          strc.StartTime = EndTime  //posticipate the start time of the element in the list
          break
        }

        //case in which bot slots end at the same time
        if StartTime.After(strc.StartTime) && EndTime.Equal(strc.EndTime) {
          strc.EndTime = StartTime //anticipate the EndTime of the slot in the listS
          break
        }

    }

    value.TimeSlots = l

    result, _ := json.Marshal(value)

    err = ctx.GetStub().PutState(string(key), result)

    if err != nil {
        return errors.New("Unable to interact with world state")
    }

    return nil
}


// Read returns the value at key in the world state
func (sc *SubscriptionContract) getInfoOwner(ctx contractapi.TransactionContextInterface, UserID string, SubID string) (*WorldState, error) {

    kStr := Key{
      UserID: UserID,
      SubID: SubID,
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

    _ = json.Unmarshal(query_result, value)

    ws := WorldState{
      UserID: UserID,
      SubID: SubID,
      ProviderID: value.ProviderID,
      TimeSlots: value.TimeSlots,
    }


    return &ws, nil
}
