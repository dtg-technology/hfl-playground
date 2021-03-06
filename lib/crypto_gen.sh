#!/bin/bash -e

echo "${msg}===> Generating crypto material${reset}"
# generate crypto material
if [ ! -f ./crypto-config/ordererOrganizations/tracelabel.com/ca/ca.tracelabel.com-cert.pem ]; then
  cryptogen generate --config=./crypto-config.yaml
fi
if [ "$?" -ne 0 ]; then
  echo "${err}Failed to generate crypto material...${reset}"
  exit 1
fi

. ./lib/set_env.sh

# pepare cryptofiles for multi-ca server
cp ./crypto-config/ordererOrganizations/tracelabel.com/ca/*_sk ./crypto-config/ordererOrganizations/tracelabel.com/ca/ca-key.pem
cp ./crypto-config/peerOrganizations/distr.tracelabel.com/ca/*_sk ./crypto-config/peerOrganizations/distr.tracelabel.com/ca/ca-key.pem
rm -rf ./crypto-config/peerOrganizations/distributor1.com/msp
mkdir -p ./crypto-config/peerOrganizations/distributor1.com/msp
mkdir -p ./crypto-config/peerOrganizations/distributor2.com/msp
mkdir -p ./crypto-config/peerOrganizations/distributors.com/msp
mkdir -p ./crypto-config/peerOrganizations/distributors.com/peers/peer0.distributors.com/msp


#FABRIC_START_TIMEOUT=0
echo "${msg_sub}-----> Generating intermediate CA for distributors${reset}"
### Tracelabel ##########################################################################
#echo "${msg_sub}-----> Adding intermediate CA's to 'TraceLabelMSP'${reset}"
docker-compose up -d ca.tracelabel.com
#docker-compose up -d --force-recreate --no-deps ca.cli
echo "${msg_sub2}--------> Waiting for 'ca.tracelabel.com' to start${reset}"
sleep $FABRIC_START_TIMEOUT
docker-compose stop ca.cli
docker-compose up -d ca.distr.tracelabel.com ca.cli
echo "${msg_sub2}--------> Waiting for 'ca.distr.tracelabel.com' to start${reset}"
sleep $FABRIC_START_TIMEOUT
# #docker-compose exec ca.cli mkdir admin
# echo "${msg_sub2}--------> Enrolling admin${reset}"
# #docker-compose exec ca.cli export "FABRIC_CA_CLIENT_HOME=$PWD/admin"
# docker-compose exec ca.cli fabric-ca-client enroll -u http://admin:adminpw@ca.distr.tracelabel.com:7054
# echo "${msg_sub2}--------> Getting intermediate cert chain${reset}"
# docker-compose exec ca.cli fabric-ca-client getcacert -u http://admin:adminpw@ca.distr.tracelabel.com:7054 --caname ca.admin.distr.tracelabel.com -M ./tracelabel
# docker-compose exec ca.cli chmod -R a+rwx ./tracelabel

# copy TraceLabel to peers
# cp -r ./crypto-config/ordererOrganizations/tracelabel.com/msp/intermediatecerts ./crypto-config/ordererOrganizations/tracelabel.com/orderers/peer0.tracelabel.com/msp
# cp -r ./crypto-config/ordererOrganizations/tracelabel.com/msp/cacerts ./crypto-config/ordererOrganizations/tracelabel.com/orderers/peer0.tracelabel.com/msp
cp -r ./crypto-config/ordererOrganizations/tracelabel.com ./crypto-config/peerOrganizations/
mkdir -p ./crypto-config/peerOrganizations/tracelabel.com/peers
cp -r ./crypto-config/peerOrganizations/tracelabel.com/orderers/* ./crypto-config/peerOrganizations/tracelabel.com/peers/
rm -rf ./crypto-config/peerOrganizations/tracelabel.com/orderers
#echo "${msg_sub}-----> Done for 'TraceLabelMSP'${reset}"
### Distributor1 ##########################################################################
echo "${msg_sub}-----> Adding intermediate CA's to 'Distributor1MSP'${reset}"
echo "${msg_sub2}--------> Getting intermediate cert chain${reset}"
docker-compose exec ca.cli fabric-ca-client getcacert -u http://admin:adminpw@${DISTR_CA} --caname ca.distr1.distr.tracelabel.com -M ./distr1
echo "${msg_sub2}--------> Getting Admin certificate${reset}"
docker-compose exec ca.cli fabric-ca-client enroll -u http://admin:adminpw@${DISTR_CA} --caname ca.distr1.distr.tracelabel.com -M ./distr1/admin
docker-compose exec ca.cli chmod -R a+rwx ./distr1
docker-compose exec ca.cli mkdir ./distr1/admincerts
docker-compose exec ca.cli cp -r ./distr1/admin/signcerts/cert.pem ./distr1/admincerts/
rm -rf crypto-config/peerOrganizations/distributor1.com/msp/admin
echo "${msg_sub}-----> Done for 'Distributor1MSP'${reset}"
### Distributor2 ##########################################################################
echo "${msg_sub}-----> Adding intermediate CA's to 'Distributor2MSP'${reset}"
echo "${msg_sub2}--------> Getting intermediate cert chain${reset}"
docker-compose exec ca.cli fabric-ca-client getcacert -u http://admin:adminpw@${DISTR_CA} --caname ca.distr2.distr.tracelabel.com -M ./distr2
echo "${msg_sub2}--------> Getting Admin certificate${reset}"
docker-compose exec ca.cli fabric-ca-client enroll -u http://admin:adminpw@${DISTR_CA} --caname ca.distr2.distr.tracelabel.com -M ./distr2/admin
docker-compose exec ca.cli chmod -R a+rwx ./distr2
docker-compose exec ca.cli mkdir ./distr2/admincerts
docker-compose exec ca.cli cp -r ./distr2/admin/signcerts/cert.pem ./distr2/admincerts/
rm -rf crypto-config/peerOrganizations/distributor2.com/msp/admin
echo "${msg_sub}-----> Done for 'Distributor2MSP'${reset}"
### Distributors ##########################################################################
echo "${msg_sub}-----> Generating 'DistributorsMSP'${reset}"
# mkdir -p ./crypto-config/peerOrganizations/distributors.com
# cp -r ./crypto-config/peerOrganizations/tracelabel.com/msp ./crypto-config/peerOrganizations/distributors.com
# mv ./crypto-config/peerOrganizations/distributors.com/msp/admincerts/Admin@tracelabel.com-cert.pem ./crypto-config/peerOrganizations/distributors.com/Admin@distributors.com-cert.pem

echo "${msg_sub2}--------> Getting intermediate cert chains${reset}"
docker-compose exec ca.cli fabric-ca-client getcacert -u http://admin:adminpw@${DISTR_CA} --caname ca.admin.distr.tracelabel.com -M ./distributors
docker-compose exec ca.cli fabric-ca-client getcacert -u http://admin:adminpw@${DISTR_CA} --caname ca.distr1.distr.tracelabel.com -M ./distributors
docker-compose exec ca.cli fabric-ca-client getcacert -u http://admin:adminpw@${DISTR_CA} --caname ca.distr2.distr.tracelabel.com -M ./distributors
echo "${msg_sub2}--------> Getting Admin certificate${reset}"
docker-compose exec ca.cli fabric-ca-client enroll -u http://admin:adminpw@${DISTR_CA} --caname ca.admin.distr.tracelabel.com -M ./distributors/admin
docker-compose exec ca.cli chmod -R a+rwx ./distributors
docker-compose exec ca.cli mkdir -p ./distributors/admincerts
docker-compose exec ca.cli cp -r ./distributors/admin/signcerts/cert.pem ./distributors/admincerts/
# create admin msp for deployments
mkdir -p ./crypto-config/peerOrganizations/distributors.com/users/Admin@distributors.com/msp
mv ./crypto-config/peerOrganizations/distributors.com/msp/admin/* ./crypto-config/peerOrganizations/distributors.com/users/Admin@distributors.com/msp
mkdir -p ./crypto-config/peerOrganizations/distributors.com/users/Admin@distributors.com/msp/admincerts
cp -r ./crypto-config/peerOrganizations/distributors.com/users/Admin@distributors.com/msp/signcerts/* ./crypto-config/peerOrganizations/distributors.com/users/Admin@distributors.com/msp/admincerts/
echo "${msg_sub2}--------> Regesiter and enroll 'peer0.distributors.com' identity${reset}"
cp -r ./crypto-config/peerOrganizations/distributors.com/users/Admin@distributors.com/msp/* ./crypto-config/peerOrganizations/distributors.com/peers/peer0.distributors.com/msp/


PEER=peer0.distributors.com
echo "${msg_sub2}--------> Registring identity '$PEER' with Intermediate CA${reset}"
docker-compose exec ca.cli fabric-ca-client enroll -u http://admin:adminpw@${DISTR_CA} --caname ca.admin.distr.tracelabel.com
OUT_TEXT=$(docker-compose exec ca.cli fabric-ca-client register -u http://${DISTR_CA} --id.name $PEER --id.type peer --id.affiliation administration.default --caname ca.admin.distr.tracelabel.com)
echo  "$OUT_TEXT"
PASSWD=$(echo -e "$OUT_TEXT" | sed -ne 's/^.*Password: \(\w*\).*$/\1/p')
echo "${msg_sub2}--------> Enrolling '$PEER' with password '$PASSWD'"
docker-compose exec ca.cli fabric-ca-client enroll -u http://${PEER}:${PASSWD}@${DISTR_CA} -M ./$PEER --caname ca.admin.distr.tracelabel.com
echo "${msg_sub}-----> Done for 'DistributorsMSP'${reset}"
### Tracelabel ##########################################################################


# copy intermediate certs to peer


# exit
# #docker exec ca.cli chmod -R a+rw ./admin
# echo "${msg_sub2}--------> Registring peer0.tracelabel.com identity with Intermediate CA"
# OUT_TEXT=$(docker-compose exec ca.cli fabric-ca-client register -u http://${DISTR_CA} --id.name $PEER --id.type peer --id.affiliation distributors1)
# echo  "$OUT_TEXT"
#
# PASSWD=$(echo -e "$OUT_TEXT" | sed -ne 's/^.*Password: \(\w*\).*$/\1/p')
# echo "${msg_sub2}--------> Enrolling '$PEER' with password '$PASSWD'"
# docker-compose exec ca.cli fabric-ca-client enroll -u http://${PEER}:${PASSWD}@ca.distr.tracelabel.com:7054 -M ./$PEER
# # change mode to be able to copy on host
# docker-compose exec ca.cli chmod -R a+rwx ./
# # copy admin cert to new intermediate MSP
# mkdir -p $MSPDir/admincerts
# cp -r $CA_CLI_PATH/msp/signcerts/* $MSPDir/admincerts
# # copy peer's cryptodata
#
# cp -r $CA_CLI_PATH/$PEER/* $MSPDir
# # preapre additional admin's MSP for deployments
# ADMIN_MSP=./crypto-config/peerOrganizations/tracelabel.com/users/Admin@tracelabel.com
# mkdir -p $ADMIN_MSP
# cp -r $CA_CLI_PATH/msp $ADMIN_MSP
# mkdir $ADMIN_MSP/msp/admincerts
# cp -r $ADMIN_MSP/msp/signcerts/* $ADMIN_MSP/msp/admincerts/
#
# # prepare MSP for orderer.com
# ORDERER_MSP=./crypto-config/ordererOrganizations/tracelabel.com/orderers/orderer.tracelabel.com/msp
# cp -r $MSPDir/intermediatecerts $ORDERER_MSP

docker-compose stop ca.cli
