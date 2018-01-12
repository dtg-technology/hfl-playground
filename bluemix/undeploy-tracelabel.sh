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

kubectl delete -f ${BRAND_SHORT}/service-peer.yml
kubectl delete -f ${BRAND_SHORT}/service-couchdb.yml
kubectl delete -f ${BRAND_SHORT}/service-orderer.yml
kubectl delete -f ${BRAND_SHORT}/service-ca.yml
kubectl delete -f ${BRAND_SHORT}/ca-volumes.yml
kubectl delete -f ${BRAND_SHORT}/db-volumes.yml
kubectl delete -f ${BRAND_SHORT}/service-cli.yml