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

Given our decision to make use of ECDSA Threshold signatures, the [alice](https://github.com/getamis/alice) library came to our help to provide an implementation. This library actually implements a more general concept, called Hierarchical TS, which allows to assign different weights to each private share; in our use case this is not necessary but it is very simple to fall back to non-hierarchical TS by simply assigning the same rank to all shares.

Concerning how this library and scheme are actually used to solve the issues mentioned above:
- The companies initially run the DKG to retrieve the shared public key and their private shares;
- A "global" MSP is defined within the Hyperledger Network; its root certificate contains the shared public key from the DKG and is self-signed (therefore the signature is a TS computed in a distributed way by the Organizations using the private shares from the DKG);
- When a new user is enrolled, he/she is assigned to the global MSP and is provided with a certificate again signed with a TS using the Organizations' private shares.

Notice that our implementation is only meant for demonstrative purposes, therefore the DKG and signature computation are executed in the form of inter-process communication between different istances of alice on the local machine rather than in a really distributed way; nevertheless, this is not really a problem as the point we want to prove is that it is possible to configure Hyperledger to automatically handle MSPs whose certificates are signed using this kind of schemes.
