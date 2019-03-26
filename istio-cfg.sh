#!/bin/bash

ISTIO_DIR=$HOME/gcp_next_labs/istio-1.1.1

if [ "$#" -eq 0 ]; then
    echo "Error. Please check usage. " \
         "Usage options: 
          istio-cfg install_istio 
          istio-cfg create_namespace <namespace name>"
   exit 1
fi

if [ "$1" = "install_istio" ]; then 
    echo "Deploying Istio on the Kubernetes Cluster"
	(cd $ISTIO_DIR && kubectl apply -f install/kubernetes/istio-demo-auth.yaml)
    exit
elif [ "$1" = "create_namespace" ]; then
    if [ "$#" -ne 2 ]; then
      echo "Usage: istio-cfg create_namespace <namespace name>"
      exit 1
    fi
    echo "Creating namespace $2 for user applications"
    kubectl create namespace $2 
    kubectl label namespace $2 istio-injection=enabled
else
    echo "Error. Please check usage. " \
         "Usage options: 
          istio-cfg install_istio 
          istio-cfg create_namespace <namespace name>"
fi
