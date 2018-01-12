###################################################
# Create the channels
###################################################
# parameters:
# $1 - name of the channel
# $2 - org on behalf of which the cannel will be created

CHANNEL=$1
ORG=$2

DOMAIN=$ORG
if [ "$DOMAIN" == "TraceLabel" ]; then
    DOMAIN=tracelabel
fi

echo "${msg_sub}-----> Creating channel '$CHANNEL'.${reset}"

POD=$(kubectl get pod -l org=${ORG,} | grep peer | gawk -e 'BEGIN { FS = " ";} { print $1; }')
kubectl exec $POD -i -- bash -x << END
CORE_PEER_LOCALMSPID=${ORG}MSP
CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/admin/msp
peer channel create -o $ORDERER -c $CHANNEL -f /etc/hyperledger/configtx/$CHANNEL.tx
END