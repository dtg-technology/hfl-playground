#!/bin/bash -e

CLUSTER=lite
output=$(bx cs workers lite)
CLUSTER_PUBLIC_IP=$(echo "$output" | gawk -e 'BEGIN { FS = " "; } /^kube-/ { print $2; }')
CLUSTER_PRIVATE_IP=$(echo "$output" | gawk -e 'BEGIN { FS = " "; } /^kube-/ { print $3; }')

echo cluster public  IP: $CLUSTER_PUBLIC_IP
echo cluster private IP: $CLUSTER_PRIVATE_IP


output=$(kubectl get svc -l org=tracelabel | grep orderer)
ORDERER_IP=$(echo "$output" | gawk -e 'BEGIN { FS = " "; } { print  $2 ; }')
ORDERER_PORT=$(echo "$output" | gawk -e 'BEGIN { FS = " "; } { print  $4 ; }' | sed -ne "s/^\(.*\):.*$/\1/p")
ORDERER=$ORDERER_IP:$ORDERER_PORT
ORDERER=orderer:$ORDERER_PORT
echo orderer: $ORDERER
