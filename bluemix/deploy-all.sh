#!/bin/sh -e

./deploy-tracelabel.sh
./deploy-brand.sh brand-1
./deploy-brand.sh brand-2

kubectl get pods -L org
