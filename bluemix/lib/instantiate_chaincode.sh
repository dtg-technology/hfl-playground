########################################################
# Initiates chaincode on the specified peer and channel
########################################################
# parameters:
# $1 - chaincode
# $2 - channel
# $3 - org on behalf of which the cannel will be created
# $4 - endorsment policy

CHAINCODE=$1
CHANNEL=$2
ORG=$3
POLICY=$4

DOMAIN=$ORG
if [ "$DOMAIN" == "TraceLabel" ]; then
    DOMAIN=tracelabel
fi

echo "${msg_sub}-----> Initiating chaincode '$CHAINCODE' on channel '$CHANNEL' of $ORG's peer0 with policy: ${POLICY}.${reset}"

#POD=$(kubectl get pods -l org=tracelabel | grep cli | gawk -e 'BEGIN { FS = " ";} { print $1; }')

kubectl exec $CLI_POD -it -- bash -x << END
export CORE_PEER_ADDRESS=${DOMAIN,}-peer:7051
export CORE_PEER_LOCALMSPID=${ORG}MSP
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${DOMAIN,}.com/users/Admin@${DOMAIN,}.com/msp
peer chaincode instantiate -o $ORDERER -C $CHANNEL -n $CHAINCODE -v 1.0 -c '{"Args":[""]}' -P "${POLICY}"
END

echo "${msg_sub}-----> Waiting ${FABRIC_START_TIMEOUT} seconds for chaincode container to start.${reset}"

sleep ${FABRIC_START_TIMEOUT}
