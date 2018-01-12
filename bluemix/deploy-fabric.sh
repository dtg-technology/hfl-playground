#!/bin/bash -e

DIR=$PWD

cd ..
. ./lib/set_env.sh
cd $DIR


. ./lib/set_bluemix_env.sh

echo "${msg}===> Deploying Fabric configuration.${reset}"
echo $CHANNEL_1

. lib/deploy_consorcium.sh Consorcium-12 $CHAINCODE $CHANNEL_1  Brand1 Distributors
#. lib/deploy_consorcium.sh Consorcium-23 $CHAINCODE $CHANNEL_2 Brand2 Distributors

echo "${msg}===>  Deployed Fabric configuration.${reset}"