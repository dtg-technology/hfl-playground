########################################################
# Init chaincode with inital data
########################################################
# parameters:
# $1 - chaincode
# $2 - channel
# $3 - org on behalf of which the cannel will be created

CHAINCODE=$1
CHANNEL=$2
ORG=$3

DOMAIN=$ORG
if [ "$DOMAIN" == "TraceLabel" ]; then
    DOMAIN=tracelabel
fi
echo "${msg_sub}-----> Invoking chaincode init fo '$CHAINCODE' in channel '$CHANNEL' of $ORG's peer0.${reset}"


kubectl exec $CLI_POD -it -- bash -x << END
export CORE_PEER_ADDRESS=${DOMAIN,}-peer:7051
export CORE_PEER_LOCALMSPID=${ORG}MSP
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${DOMAIN,}.com/users/Admin@${DOMAIN,}.com/msp
peer chaincode invoke -o $ORDERER -C $CHANNEL -n $CHAINCODE -c '{"function":"initLedger","Args":[""]}'
END
