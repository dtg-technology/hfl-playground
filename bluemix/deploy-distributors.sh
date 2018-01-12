#!/bin/bash



# load env
if [ -f ../.env ]; then
  . ../.env
else
  . ../.env_base
fi



ORG=Distributors
DOMAIN=${ORG,}
CONFIG=$DOMAIN

echo "${msg}===> Deploying ${ORG} to Bluemix.${reset}"

CA_CERT=$(ls -f1 ../crypto-config/peerOrganizations/${DOMAIN}.com/peers/peer0.${DOMAIN}.com/msp/cacerts | grep .pem)
CA_INTERMEDIATE_CERT=$(ls -f1 ../crypto-config/peerOrganizations/${DOMAIN}.com/peers/peer0.${DOMAIN}.com/msp/intermediatecerts | grep .pem)
PEER_PRIVATE_KEY=$(ls -f1 ../crypto-config/peerOrganizations/${DOMAIN}.com/peers/peer0.${DOMAIN}.com/msp/keystore | grep _sk)
PEER_SIGN_CERT=$(ls -f1 ../crypto-config/peerOrganizations/${DOMAIN}.com/peers/peer0.${DOMAIN}.com/msp/signcerts | grep pem)
ADMIN_PRIVATE_KEY=$(ls -f1 ../crypto-config/peerOrganizations/${DOMAIN}.com/users/Admin@${DOMAIN}.com/msp/keystore | grep _sk)
ADMIN_CERT=$(ls -f1 ../crypto-config/peerOrganizations/${DOMAIN}.com/users/Admin@${DOMAIN}.com/msp/signcerts | grep .pem)

#### Deploying peer
echo "${msg_sub}-----> deploying Peer0${reset}"
RES_NAME=${DOMAIN}-peer-db
echo "--------> checking secret '${RES_NAME}'${reset}"
$(kubectl get secret ${RES_NAME} > /dev/null 2>&1 )
if [ $? -eq 1 ]; then
   echo "--------> creating secret '${RES_NAME}'${reset}"
   kubectl create secret generic ${RES_NAME} --from-file=user=${CONFIG}/.db.username --from-file=password=${CONFIG}/.db.password
   kubectl label secret ${RES_NAME} app=tracelabel
else
   echo "--------> exists${reset}"
fi


RES_NAME=${DOMAIN}-peer-msp
echo "--------> checking secret '${RES_NAME}'${reset}"
$(kubectl get secret ${RES_NAME} > /dev/null 2>&1 )
if [ $? -eq 1 ]; then
   echo "--------> creating secret '${RES_NAME}'${reset}"
   kubectl create secret generic ${RES_NAME}   \
                                            --from-file=admin_cert=../crypto-config/peerOrganizations/${DOMAIN}.com/peers/peer0.${DOMAIN}.com/msp/admincerts/cert.pem \
                                            --from-file=ca_cert=../crypto-config/peerOrganizations/${DOMAIN}.com/peers/peer0.${DOMAIN}.com/msp/cacerts/$CA_CERT \
                                            --from-file=int_ca_cert=../crypto-config/peerOrganizations/${DOMAIN}.com/peers/peer0.${DOMAIN}.com/msp/intermediatecerts/$CA_INTERMEDIATE_CERT \
                                            --from-file=private_key=../crypto-config/peerOrganizations/${DOMAIN}.com/peers/peer0.${DOMAIN}.com/msp/keystore/$PEER_PRIVATE_KEY \
                                            --from-file=sign_cert=../crypto-config/peerOrganizations/${DOMAIN}.com/peers/peer0.${DOMAIN}.com/msp/signcerts/$PEER_SIGN_CERT
                                     #       --from-file=../crypto-config/peerOrganizations/${DOMAIN}.com/peers/peer0.${DOMAIN}.com/msp/tlscacerts
   kubectl label secret ${RES_NAME} app=tracelabel
else
   echo "--------> exists${reset}"
fi

RES_NAME=${DOMAIN}-peer-users
echo "--------> checking secret '${RES_NAME}'${reset}"
$(kubectl get secret ${RES_NAME} > /dev/null 2>&1 )
if [ $? -eq 1 ]; then
   echo "--------> creating secret '${RES_NAME}'${reset}"
   kubectl create secret generic ${RES_NAME}   \
                                            --from-file=admin_cert=../crypto-config/peerOrganizations/${DOMAIN}.com/users/Admin@${DOMAIN}.com/msp/admincerts/cert.pem \
                                            --from-file=ca_cert=../crypto-config/peerOrganizations/${DOMAIN}.com/users/Admin@${DOMAIN}.com/msp/cacerts/$CA_CERT \
                                            --from-file=int_ca_cert=../crypto-config/peerOrganizations/${DOMAIN}.com/users/Admin@${DOMAIN}.com/msp/intermediatecerts/$CA_INTERMEDIATE_CERT \
                                            --from-file=sign_cert=../crypto-config/peerOrganizations/${DOMAIN}.com/users/Admin@${DOMAIN}.com/msp/signcerts/cert.pem \
                                            --from-file=sign_key=../crypto-config/peerOrganizations/${DOMAIN}.com/users/Admin@${DOMAIN}.com/msp/keystore/$ADMIN_PRIVATE_KEY
   kubectl label secret ${RES_NAME} app=tracelabel
else
   echo "--------> exists${reset}"
fi

RES_NAME=fabric-config
echo "--------> checking secret '${RES_NAME}'${reset}"
$(kubectl get secret ${RES_NAME} > /dev/null 2>&1 )
if [ $? -eq 1 ]; then
   echo "--------> creating secret '${RES_NAME}'${reset}"
   kubectl create secret generic ${RES_NAME} --from-file=../config
   kubectl label secret ${RES_NAME} app=tracelabel
   echo "--------> exists${reset}"
fi

echo "--------> creating persistent volume for couchdb ${reset}"
kubectl apply -f ${CONFIG}/volumes.yml
echo "--------> creating couchdb service${reset}"
kubectl apply -f ${CONFIG}/service-couchdb.yml
echo "--------> creating peer service${reset}"
kubectl apply -f ${CONFIG}/service-peer.yml

echo "${msg}===> ${ORG} deployed to Bluemix.${reset}"

kubectl get pods -l org=${DOMAIN} -L org