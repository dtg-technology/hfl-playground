#!/bin/sh

./undeploy-tracelabel.sh
./undeploy-brand.sh brand1
./undeploy-brand.sh brand2

kubectl delete rs $(kubectl get rs -o=custom-columns=:.metadata.name)
kubectl delete secret $(kubectl get secret -l app=tracelabel -L app -o=custom-columns=:.metadata.name)

kubectl get all -l app=tracelabel -L app,org

