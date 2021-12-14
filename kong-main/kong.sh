#!/bin/bash

kubectl get namespace kong > /dev/null 2>&1 || kubectl create namespace kong

kubectl label namespace kong mesh=$MESH_NAME/sidecarInjectorWebhook=enabled
   
kubectl apply -f manifests/ --validate=false

kubectl patch deploy -n kong kong-kong -p '{"spec":{"template":{"spec":{"containers":[{"name":"ingress-controller","securityContext":{"runAsUser": 1337}}]}}}}'