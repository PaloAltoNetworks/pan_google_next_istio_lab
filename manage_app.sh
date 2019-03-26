#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: manage_app.sh <create | delete>"
    exit $# 
fi
echo $#

if [ "$1" == "create" ]; then
	echo "Installing bookinfo application" 
	kubectl apply -f ./bookinfo.yaml
	echo "Define the Ingress Gateway Routing for the application"
	kubectl apply -f ./bookinfo-gateway.yaml

	echo "\n ######### INGRESS GATEWAY ############ \n"
	echo "Validate the ingress gateway configuration" 
	kubectl get svc istio-ingressgateway -n istio-system
	echo "\n ########## COMPLETE ############# \n"

	echo "Configure the environment variables to access various services" 

	INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}') 
	echo "export INGRESS_HOST=$INGRESS_HOST" > config.sh
	echo "Ingress host IP Address: $INGRESS_HOST"
	INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
	echo "export INGRESS_PORT=$INGRESS_PORT" >> config.sh
	echo "Ingress port: $INGRESS_PORT"
	SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].port}')
	echo "export SECURE_INGRESS_PORT=$SECURE_INGRESS_PORT" >> config.sh
	echo "Secure Ingress port: $SECURE_INGRESS_PORT"
	GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT
	echo "export GATEWAY_URL=$GATEWAY_URL" >> config.sh
	echo "Gateway URL: $GATEWAY_URL"

	echo " PLEASE NOTE: The next step is to execute \"source ./config.sh\""
	echo "EXECUTE: source ./config.sh"	
	echo "Once the \"source\" command has been executed, you can use the following
          curl command to access the application "
	echo 'CURL COMMAND: curl -o /dev/null -s -w "%{http_code}\n" http://${GATEWAY_URL}/productpage'
elif [ "$1" == "delete" ]; then
	echo "Delete the ingress gateway" 
	kubectl delete -f ./bookinfo-gateway.yaml

	echo "Delete the book info application" 
	kubectl delete -f ./bookinfo.yaml
    unset GATEWAY_URL
	unset SECURE_INGRESS_PORT
	unset INGRESS_PORT
	unset INGRESS_HOST
fi
