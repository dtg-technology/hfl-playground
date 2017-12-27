## Modeling inactive Distributors.

Here we check how "inactive" distributors can be modeled in Hyperledger Fabric. Inactive are those who participates in the system but is not interested in running own complete Fabric node.

The idea it that we model inactive distributors as separate organizations with their own CAs, but without peer. Instead, wer provide a peer for all such distributors.
See the following aspects:
1. Distributors are modeled as organizations _Distributor1_ and _Distributor2_ (see `configtx.yaml`) and have their own MSP.
1. Distributors have own CAs, which are intermediate udner dedicated Root CA _ca.distr.tracelabel.com_. It is root, although, it is named after tracelabel and is hosted on server _ca.tracelable.com_. Distributors have own CAs are _ca.distr1.distr.tracelabel.com_ and _ca.distr2.distr.tracelabel.com_ and they are hosted on _ca.distr.tracelable.com_ server. It is assumed, that both CA servers are _milti-CA_ and managed by us.
1. Inactive distributors work with a special peer _peer0.distributors.com_ managed, again, by us and playing role of an inactive partners gateway. The peers works under MSP `DistributorsMSP`, which is also under intermediate CA _ca.admin.distr.tracelabel.com_, which represent managing staff from _TraceLabel.com_. This is also represented by a special organization _Distributors_ (see `configtx.yaml`). So, the peers identity belongs to _Distributors_ organization (fake), and, at the same time, distributors can use it although they belong to different organizations (_Distributor1_ and _Distributor2_). This allows us:
  - individually control access of distibutor organizations to channels;
  - use the same peer node for all distributors, having different channel sets. To do this, peer's organization must have acces to a superset of all distributors' channels (see `configtx.yaml`).


### So, see at:
1. How CA servers configured, in particular, see "ca.tracelabel.com" and "ca.distr.tracelabel.com". Here we have multiple CA's on one server and multiple intermediate CA's on one server.
1. See "peer0.distributors.com" peer's MSP configuration.  
1. See, how calls are working.
1. See how intermediate CA cert chains are got with using `fabric-ca-client` for adding to MSP.
1. See that EventHub is not working in such configuration. Client and peer must be in the same organization for event hub to work.


To run, use "./run.sh clean". This will create everything, starts and runs tests.

### Lessons learned:
* If you have Intermediate CA, which requests own certificate from parent CA, then you can have a problem if parent CA is on the same CA server as it is not up yet at the moment of CSR request. So, to model such situations, host parent and child CAs on different server instances. If you already have child sertificate and not CSR is needed, then it is OK.
* Client may connect to any peer node within the channel needed for the client. But, `EventHub` will only allow subscription for events if client is from the _same organization as peer_. This is why it appears impossible or difficult to model inactive distributors as organizations and allow them to work through a special peer managed by us.
* We think, we should model all inactive distributors as one fake organization which also runs a gateway peer. This 
