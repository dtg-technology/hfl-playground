#!/bin/bash

. ./lib/set_env.sh

echo -e "\n${msg}===> Running examples.${reset}"
echo "${msg}===> Registering and enrolling users.${reset}"

echo -e "\n${msg_sub}-----> For 'Brand1'.${reset}"
node enrollAdmin.js brand1
node registerUser.js brand1

echo -e "\n${msg_sub}-----> For 'Brand2'.${reset}"
node enrollAdmin.js brand2
node registerUser.js brand2

echo -e "\n${msg_sub}-----> For 'TraceLabel'.${reset}"
node enrollAdmin.js tracelabel
node registerUser.js tracelabel

echo -e "\n${msg_sub}-----> For 'Distributors'.${reset}"
node enrollAdmin.js admin_distributors
node registerUser.js admin_distributors

echo -e "\n${msg_sub}-----> For 'Distributor 1'.${reset}"
node enrollAdmin.js distributor1
node registerUser.js distributor1

echo -e "\n${msg_sub}-----> For 'Distributor 2'.${reset}"
node enrollAdmin.js distributor2
node registerUser.js distributor2

echo -e "\n${msg}===> End of enrollemnt.${reset}"

echo "${msg}===> Making read-only queries.${reset}"
node query.js channel-1 brand1 brand1
node query.js channel-2 brand2 brand2
node query.js channel-1 admin_distributors admin_distributors

echo -e "\n${msg}===> Making inserts into blockchain.${reset}"
node invoke.js channel-1 brand1 brand1
node invoke.js channel-2 brand2 brand2

echo -e "\n${warn}===> Following two updates must complete with event subscription error.${reset}"
node invoke.js channel-2 distributor1 distributor1
echo      "${warn}===> Erorr is OK, it demonstrates how this works.${reset}"

node invoke.js channel-2 distributor2 distributor2
echo      "${warn}===> Erorr is OK, it demonstrates how this works.${reset}"
echo -e "\n${msg}===> End of examples.${reset}"
