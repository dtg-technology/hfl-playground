#!/bin/bash -e

DIR=$PWD

cd ..
. ./lib/set_env.sh
cd $DIR

ORDERER=orderer:7050

echo "${msg}===> Starting nodes on Bluemix.${reset}"
./deploy-tracelabel.sh
./deploy-brand.sh brand1
./deploy-brand.sh brand2
echo "${msg}===> Nodes started.${reset}"

kubectl get pods -L org -L org
. ./lib/set_bluemix_env.sh

sleep 30
echo "${msg}===> Deploying Fabric configuration.${reset}"

# lib/deploy_consorcium.sh Consorcium-12 $CHAINCODE $CHANNEL_1 brand1 Distributors
#. lib/deploy_consorcium.sh Consorcium-23 $CHAINCODE $CHANNEL_2 Brand2 Distributors

echo "${msg}===>  Deployed Fabric configuration.${reset}"