package main

import (
    "errors"
    "fmt"
    "encoding/json"
    "time"
    "github.com/hyperledger/fabric-contract-api-go/contractapi"
)

type TimeSlot struct{
    StartTime time.Time `json:"StartTime"`
    EndTime time.Time `json:"EndTime"`
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

      timeSlot := make([]TimeSlot,10)
      timeSlot = append(timeSlot, ts)

      vStr := Subscription{
        ProviderID: ProviderID,
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

        timeSlot := make([]TimeSlot,10)
        timeSlot = append(timeSlot, ts)

        vStr := Subscription{
          ProviderID: ProviderID,
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
            StartTime: EndTime,
            EndTime: it.EndTime,
          }

          it.EndTime = StartTime
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
          it.StartTime = EndTime  //posticipate the start time of the element in the list
          found = true
          break
        }

        //case in which bot slots end at the same time
        if StartTime.After(it.StartTime) && EndTime.Equal(it.EndTime) {
          it.EndTime = StartTime //anticipate the EndTime of the slot in the listS
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
func (sc *SubscriptionContract) getInfoOwner(ctx contractapi.TransactionContextInterface, UserID string, SubID string) (*Subscription, error) {

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

    return &value, nil
}
