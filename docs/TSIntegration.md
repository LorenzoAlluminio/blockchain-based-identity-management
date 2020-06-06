# Integrating Hyperledger with a Threshold Cryptosystem

### The Problem

Given the idea behind our application, it is apparent that the end users of the Hyperledger Network do not logically belong to a specific Service Provider Organization, either because they can own more than a single Subscription for different Services or because they can use the Network without owning any subscription althogether, limiting themselves instead to only renting the Services from other users.

Unfortunately, this does not sit well with Hyperledger, which by design is able to easily model the interaction between different entities having each its own PKI and members, but does not as easily handle more nuanced situations such as this one. While it would be possible to simply assign each new user to one of the Organizations (with a Round Robin or alternative approach), this is not ideal and can lead to logistic issues, such as needing to replace the relevant user certificates in case one of the Organizations resigns from the Network. 

In order to avoid this sort of issues and gain more flexibility, we chose to adopt an approach based on 
