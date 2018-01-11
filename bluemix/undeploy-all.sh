#!/bin/sh

./undeploy-tracelabel.sh
./undeploy-brand.sh brand-1
./undeploy-brand.sh brand-2

kubectl delete rs $(kubectl get rs -o=custom-columns=:.metadata.name)


kubectl get pods -L org

