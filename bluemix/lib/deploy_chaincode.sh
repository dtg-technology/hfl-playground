#####################################################
# Deploy chaincode to the specified peer and channel
#####################################################
# parameters:
# $1 - chaincode
# $2 - org on behalf of which the cannel will be created

CHAINCODE=$1
ORG=$2

echo "${msg_sub}-----> Deploying chaincode '$CHAINCODE' to $ORG's peer0.${reset}"
DOMAIN=$ORG
if [ "$ORG" == "TraceLabel" ]; then
    DOMAIN=tracelabel
fi

if [ "$ORG" != "Distributors"  ] || [ -z "$TL_DEPLOYED" ]; then

    POD=$(kubectl get pod -l org=tracelabel | grep cli | gawk -e 'BEGIN { FS = " ";} { print $1; }')
    kubectl exec $POD -it -- bash -x << END
export CORE_PEER_ADDRESS=${DOMAIN,}-peer:7051
export CORE_PEER_LOCALMSPID=${ORG}MSP
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${DOMAIN,}.com/users/Admin@${DOMAIN,}.com/msp
peer chaincode install -n $CHAINCODE -v 1.0 -p github.com/$CHAINCODE
END
    if [ "$ORG" == "Distributors" ]; then
        TL_DEPLOYED=1
    fi
fi
