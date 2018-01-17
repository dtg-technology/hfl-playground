#!/bin/bash -e

CLUSTER=lite
output=$(bx cs workers lite)
export CLUSTER_PUBLIC_IP=$(echo "$output" | gawk -e 'BEGIN { FS = " "; } /^kube-/ { print $2; }')
export CLUSTER_PRIVATE_IP=$(echo "$output" | gawk -e 'BEGIN { FS = " "; } /^kube-/ { print $3; }')

echo cluster public  IP: $CLUSTER_PUBLIC_IP
echo cluster private IP: $CLUSTER_PRIVATE_IP


output=$(kubectl get svc -l org=tracelabel | grep orderer)
ORDERER_IP=$(echo "$output" | gawk -e 'BEGIN { FS = " "; } { print  $3 ; }')
ORDERER_PORT=$(echo "$output" | gawk -e 'BEGIN { FS = " "; } { print  $5 ; }' | sed -ne "s/^\(.*\):.*$/\1/p")
ORDERER=$ORDERER_IP:$ORDERER_PORT
export ORDERER=orderer:$ORDERER_PORT
echo orderer: $ORDERER

CLI_POD=$(kubectl get pods -l org=tracelabel -o=custom-columns=:.metadata.name | grep cli )
