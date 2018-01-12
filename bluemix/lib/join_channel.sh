###################################################
# Joins the channels
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
echo "${msg_sub}-----> Joining channel '$CHANNEL' by '$ORG's peer0.${reset}"

POD=$(kubectl get pod -l org=${ORG,} | grep peer | gawk -e 'BEGIN { FS = " ";} { print $1; }')


kubectl exec $POD -i -- bash -x << END
export CORE_PEER_LOCALMSPID=${ORG}MSP
export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/admin/msp
peer channel fetch config $CHANNEL.block -o $ORDERER -c $CHANNEL
peer channel join -b $CHANNEL.block
END

