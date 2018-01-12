#!/bin/bash


# load env
if [ -f ../.env ]; then
  . ../.env
else
  . ../.env_base
fi



BRAND=tracelabel
CONFIG=$BRAND
BRAND_SHORT=$BRAND

echo "${msg}===> Deploying ${BRAND} to Bluemix.${reset}"


CA_PRIVATE_KEY=$(ls -f1 ../crypto-config/ordererOrganizations/${BRAND_SHORT}.com/ca | grep _sk)
PEER_PRIVATE_KEY=$(ls -f1 ../crypto-config/peerOrganizations/${BRAND_SHORT}.com/peers/peer0.${BRAND_SHORT}.com/msp/keystore | grep _sk)
PEER_SIGN_CERT=$(ls -f1 ../crypto-config/peerOrganizations/${BRAND_SHORT}.com/peers/peer0.${BRAND_SHORT}.com/msp/signcerts | grep pem)


kubectl apply -f ${BRAND_SHORT}/ca-volumes.yml
kubectl apply -f ${BRAND_SHORT}/db-volumes.yml


#### Deploying CA
echo "${msg_sub}-----> Deploying CA${reset}"

# default-ca secret
RES_NAME=${BRAND}-default-ca
echo "--------> checking secret '${RES_NAME}'${reset}"
output=$(kubectl get secret ${RES_NAME} > /dev/null 2>&1 )
if [ $? -eq 1 ]; then
   echo "--------> creating secret '${RES_NAME}'${reset}"
   kubectl create secret generic ${RES_NAME} \
                                              --from-file=fabric-ca-server-config.yaml=../resource/bluemix-${BRAND_SHORT}-default-fabric-ca-server-config.yaml
else
   echo "--------> exists${reset}"
fi

## secret for ca1
RES_NAME=${BRAND}-ca1
echo "--------> checking secret '${RES_NAME}'${reset}"
output=$(kubectl get secret ${RES_NAME} > /dev/null 2>&1 )
if [ $? -eq 1 ]; then
   echo "--------> creating secret '${RES_NAME}'${reset}"
   kubectl create secret generic ${RES_NAME}  --from-file=ca-key.pem=../crypto-config/peerOrganizations/${BRAND_SHORT}.com/ca/$CA_PRIVATE_KEY \
                                              --from-file=ca-cert.pem=../crypto-config/peerOrganizations/${BRAND_SHORT}.com/ca/ca.${BRAND_SHORT}.com-cert.pem \
                                              --from-file=fabric-ca-config.yaml=../resource/bluemix-${BRAND_SHORT}-fabric-ca-server-config.yaml
else
   echo "--------> exists${reset}"
fi

## secret for ca2
RES_NAME=${BRAND}-ca2
echo "--------> checking secret '${RES_NAME}'${reset}"
output=$(kubectl get secret ${RES_NAME} > /dev/null 2>&1 )
if [ $? -eq 1 ]; then
   echo "--------> creating secret '${RES_NAME}'${reset}"
   kubectl create secret generic ${RES_NAME}  --from-file=ca-key.pem=../crypto-config/peerOrganizations/distr.tracelabel.com/ca/ca-key.pem \
                                              --from-file=ca-cert.pem=../crypto-config/peerOrganizations/distr.${BRAND_SHORT}.com/ca/ca.distr.${BRAND_SHORT}.com-cert.pem \
                                              --from-file=fabric-ca-config.yaml=../resource/bluemix-distr-fabric-ca-server-config.yaml
else
   echo "--------> exists${reset}"
fi

#### creating secret for CA's MSP
RES_NAME=${BRAND}-msp
echo "--------> checking secret '${RES_NAME}'${reset}"
$(kubectl get secret ${RES_NAME} > /dev/null 2>&1 )
if [ $? -eq 1 ]; then
  echo "--------> creating secret '${RES_NAME}'${reset}"
  kubectl create secret generic ${RES_NAME}  --from-file=admin-cert=../crypto-config/peerOrganizations/${BRAND_SHORT}.com/msp/admincerts/Admin@${BRAND_SHORT}.com-cert.pem \
                                             --from-file=ca-cert=../crypto-config/peerOrganizations/${BRAND_SHORT}.com/msp/cacerts/ca.${BRAND_SHORT}.com-cert.pem
else
   echo "--------> exists${reset}"
fi


#kubectl apply -f ${CONFIG}/volumes.yml

echo "--------> Creating service for CA ${reset}"
kubectl apply  -f ${CONFIG}/service-ca.yml

echo "${msg_sub}-----> CA service done${reset}"



#### Deploying orderer
echo "${msg_sub}-----> Deploying Orderer${reset}"
RES_NAME=${BRAND}-orderer-block
echo "--------> generating secret '${RES_NAME}'${reset}"
$(kubectl get secret ${RES_NAME} > /dev/null 2>&1 )
if [ $? -eq 1 ]; then
   echo "--------> creating secret '${RES_NAME}'${reset}"
   kubectl create secret generic ${RES_NAME}  --from-file=../config/genesis.block
else
   echo "--------> exists${reset}"
fi

####
RES_NAME=${BRAND}-orderer-msp
echo "--------> checking secret '${RES_NAME}'${reset}"
$(kubectl get secret ${RES_NAME} > /dev/null 2>&1 )
if [ $? -eq 1 ]; then
   echo "--------> creating secret '${RES_NAME}'${reset}"
   ORDERER_SIGN_CERT=$(ls -f1 ../crypto-config/ordererOrganizations/${BRAND_SHORT}.com/orderers/orderer.${BRAND_SHORT}.com/msp/signcerts | grep pem)
   ORDERER_SIGN_KEY=$(ls -f1 ../crypto-config/ordererOrganizations/${BRAND_SHORT}.com/orderers/orderer.${BRAND_SHORT}.com/msp/keystore | grep _sk)

   kubectl create secret generic ${RES_NAME}    \
                                            --from-file=admin_cert=../crypto-config/ordererOrganizations/${BRAND_SHORT}.com/orderers/orderer.${BRAND_SHORT}.com/msp/admincerts/Admin@${BRAND_SHORT}.com-cert.pem \
                                            --from-file=../crypto-config/ordererOrganizations/${BRAND_SHORT}.com/orderers/orderer.${BRAND_SHORT}.com/msp/cacerts \
                                            --from-file=sign_key=../crypto-config/ordererOrganizations/${BRAND_SHORT}.com/orderers/orderer.${BRAND_SHORT}.com/msp/keystore/$ORDERER_SIGN_KEY \
                                            --from-file=sign_cert=../crypto-config/ordererOrganizations/${BRAND_SHORT}.com/orderers/orderer.${BRAND_SHORT}.com/msp/signcerts/$ORDERER_SIGN_CERT \
                                            --from-file=../crypto-config/ordererOrganizations/${BRAND_SHORT}.com/orderers/orderer.${BRAND_SHORT}.com/msp/tlscacerts
else
   echo "--------> exists${reset}"
fi

echo "--------> creating service for Orderer${reset}"
kubectl apply -f tracelabel/service-orderer.yml


# run peer
RES_NAME=${BRAND}-peer-db
echo "--------> checking secret '${RES_NAME}'${reset}"
$(kubectl get secret ${RES_NAME} > /dev/null 2>&1 )
if [ $? -eq 1 ]; then
   echo "--------> creating secret '${RES_NAME}'${reset}"
   kubectl create secret generic ${RES_NAME} --from-file=user=${CONFIG}/.db.username --from-file=password=${CONFIG}/.db.password
else
   echo "--------> exists${reset}"
fi

echo "${msg_sub}-----> Orderer service done${reset}"



echo "${msg_sub}-----> Deploying Peer0${reset}"
RES_NAME=${BRAND}-peer-msp
echo "--------> checking secret '${RES_NAME}'${reset}"
$(kubectl get secret ${RES_NAME} > /dev/null 2>&1 )
if [ $? -eq 1 ]; then
   echo "--------> creating secret '${RES_NAME}'${reset}"
   kubectl create secret generic ${RES_NAME}   \
                                            --from-file=admin_cert=../crypto-config/peerOrganizations/${BRAND_SHORT}.com/peers/peer0.${BRAND_SHORT}.com/msp/admincerts/Admin@${BRAND_SHORT}.com-cert.pem \
                                            --from-file=../crypto-config/peerOrganizations/${BRAND_SHORT}.com/peers/peer0.${BRAND_SHORT}.com/msp/cacerts \
                                            --from-file=../crypto-config/peerOrganizations/${BRAND_SHORT}.com/peers/peer0.${BRAND_SHORT}.com/msp/keystore \
                                            --from-file=../crypto-config/peerOrganizations/${BRAND_SHORT}.com/peers/peer0.${BRAND_SHORT}.com/msp/signcerts \
                                            --from-file=../crypto-config/peerOrganizations/${BRAND_SHORT}.com/peers/peer0.${BRAND_SHORT}.com/msp/tlscacerts
else
   echo "--------> exists${reset}"
fi

RES_NAME=${BRAND}-peer-users
echo "--------> checking secret '${RES_NAME}'${reset}"
$(kubectl get secret ${RES_NAME} > /dev/null 2>&1 )
if [ $? -eq 1 ]; then
   echo "--------> creating secret '${RES_NAME}'${reset}"
   kubectl create secret generic ${RES_NAME}   \
                                            --from-file=admin_cert=../crypto-config/peerOrganizations/tracelabel.com/users/Admin@tracelabel.com/msp/admincerts/Admin@${BRAND_SHORT}.com-cert.pem \
                                            --from-file=ca_cert=../crypto-config/peerOrganizations/${BRAND_SHORT}.com/users/Admin@${BRAND_SHORT}.com/msp/cacerts/ca.${BRAND_SHORT}.com-cert.pem
else
   echo "--------> exists${reset}"
fi


echo "--------> starting couchdb${reset}"
kubectl apply  -f ${CONFIG}/service-couchdb.yml
echo "--------> starting peer0${reset}"
kubectl apply  -f ${CONFIG}/service-peer.yml
echo "${msg_sub}-----> Peer0 service done${reset}"
kubectl apply  -f ${CONFIG}/service-cli.yml
echo "${msg}===> ${BRAND} deplyed to Bluemix.${reset}"

kubectl get pods -l org=tracelabel -L org