#!/bin/bash -e

. ./lib/set_env.sh

./start.sh $1

if [ "$?" -ne 0 ]; then
    exit 1
fi

if [ !  -d ./node_modules ]; then
    npm install
fi


. ./tests.sh
