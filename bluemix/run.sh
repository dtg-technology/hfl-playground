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
./deploy-distributors.sh
kubectl apply  -f tracelabel/service-cli.yml

echo "${msg}===> Nodes started.${reset}"



kubectl get pods -L org -L app
. ./lib/set_bluemix_env.sh

sleep 30

. ./deploy-application.sh