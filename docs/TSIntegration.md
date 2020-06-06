# Integrating Hyperledger with Threshold Signatures

### The Problem

Given the idea behind our application, it is apparent that the end users of the Hyperledger Network do not logically belong to a specific Service Provider Organization, either because they can own more than a single Subscription for different Services or because they can use the Network without owning any subscription altogether, limiting themselves to only renting the Services from other users.

Unfortunately, this does not fit well with Hyperledger, which by design is able to easily model the interaction between different entities having each its own PKI and members, but does not as easily handle more nuanced situations such as this one. While it would be possible to simply assign each new user to one of the Organizations (with a Round Robin or alternative approach), this is not ideal and can lead to logistic issues, such as needing to replace the relevant user certificates in case one of the Organizations resigns from the Network. 

In order to avoid this sort of issues and gain more flexibility, we chose to adopt an approach based on the recent developments on ECDSA Threshold Signature schemes to define a common PKI between the Organizations while maintaining a distributed nature.

### Why Threshold Signatures?

When using a Threshold Signature scheme, multiple parties initially perform a Distributed Key Generation to derive a shared public key and the corresponding private shares. As the name implies, in this kind of scheme in order to obtain a valid message signature it is necessary that at least t parties (t being the threshold parameter specified during the DKG) join together to perform the distributed computation using each its own private share. Moreover, TS schemes imply the possibility of performing a reshare operation to redistribute the private shares among a possibly different number of participants, without needing to change the original shared public key. Verifying an ECDSA Threshold Signature is exactly the same operation as verifying a classic ECDSA signature, given the public key.

These properties are extremely desirable given our use case: 
- As Threshold Signatures need the participation of at least t parties, they can be used to ensure that the majority of Organizations is involved when enrolling a new user;
- The resharing operation means that within reasonable limits the removal of an Organization from the Network has no impact on the existing users (as the public key which is used to verify their certificates does not change).

The only negative aspect of TS is that for mathematical reasons it is not possible to reduce the value of t after the DKG (although it is theoretically possible to increase it); nevertheless, this is not a serious shortcoming because in any case we assume that events such as addition or removal of an Organization should be extremely uncommon and well-regulated, therefore if t is chosen wisely it should be able to remain stable for an extended period of time.

### How we use Threshold Signatures with Hyperledger
