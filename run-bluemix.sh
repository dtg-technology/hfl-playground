#!/bin/bash -e
echo -e "\n"
. ./lib/set_env.sh

cd bluemix
./run.sh

cd ..

./tests.sh

