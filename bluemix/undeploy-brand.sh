#!/bin/bash

if [ $# -lt 1 ]; then
   echo -e "brand argument is not specified.\nexiting.\n"
   exit
elif [ "$1" != "brand-1" ] && [ "$1" != "brand-2" ]; then
   echo -e "argument must be \"brand-(1,2)\".\nexiting.\n"
   exit
fi

# load env
if [ -f ../.env ]; then
  . ../.env
else
  . ../.env_base
fi



BRAND=$1
CONFIG=$BRAND
BRAND_SHORT=$(echo $BRAND | tr -d "-")
kubectl delete -f ${BRAND}/service-peer.yml
kubectl delete -f ${BRAND}/service-couchdb.yml
kubectl delete -f ${BRAND}/service-ca.yml
#kubectl delete -f ${BRAND_SHORT}/ca-volumes.yml