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
#    docker exec -e "CORE_PEER_ADDRESS=peer0.${DOMAIN,}.com:7051" -e "CORE_PEER_LOCALMSPID=${ORG}MSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${DOMAIN,}.com/users/Admin@${DOMAIN,}.com/msp" cli peer chaincode install -n $CHAINCODE -v 1.0 -p github.com/$CHAINCODE

POD=$(kubectl get pod -l org=tracelabel | grep cli | gawk -e 'BEGIN { FS = " ";} { print $1; }')
echo $POD
kubectl exec $POD -it -- bash -x << END
CORE_PEER_ADDRESS=${DOMAIN,}-peer:7051
echo $CORE_PEER_ADDRESS
CORE_PEER_LOCALMSPID=${ORG}MSP
CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/admin/msp
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${DOMAIN,}.com/users/Admin@${DOMAIN,}.com/msp
peer chaincode install -n $CHAINCODE -v 1.0 -p github.com/$CHAINCODE
END
    if [ "$ORG" == "Distributors" ]; then
        TL_DEPLOYED=1
    fi
fi
