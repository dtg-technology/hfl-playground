## This is an examples demonstrating working with Intermediate CA.

"TraceLabelMSP" has Intermediate CA configured. So, "peer0.tracelabel.com" is runnig with both "ca.tracelabel.com" root CA and "ca.distr.tracelabel.com's" (this is a root CA for passive partners) intermediate CA that is "ca.admin.distr.tracelabel.com". Also, one of the tests in "tests.sh" is making call on behaulf of user "admin_distributors", which is registered under this intermediate CA.

So, see at:
1. How CA servers configured, in particular, see "ca.tracelabel.com" and "ca.distr.tracelabel.com". Here we have multiple CA's on one server and multiple intermediate CA's on one server.
2. See "peer0.tracelabel.com" peer's MSP configuration.  
3. See, how it calls are working.
4. See how Intermediate CA are set up in "ca.distr.tracelabel.com".
5. See how intermediate CA cert chains are got with using `fabric-ca-client` for adding to MSP.


To run, use "./run.sh clean". This will create everything, starts and runs tests.

Lessons learned:
* If you have intermediate certificate chain, then, identity certificates can only be issued by leaf CAs. This is true for both peer, admin and users identities.
* If you have MSP with many root and intermediate CA's and peer's indentity is established with one among them, then users of any of this CA's can use peer.
* Intermediate CA should have already be added to MSP's before using `configtx` to build both genesis and channel blocks, otherwise, you will see authentication errors when using identities of these CAs.
* MSP management is not easy. Need to plan for some supporting tools for that.
* Configuration changes are not easy, if you need to add new members to channels of consoncium.
