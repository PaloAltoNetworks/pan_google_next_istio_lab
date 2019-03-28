# pan_google_next_istio_lab
This repo contains a lab which demonstrates the use of the Palo Alto Networks Security adapter for Istio.

# Instructions 

#### kubectl 

Please ensure that the `kubectl` tool in installed and available on your system. 

Instructions to install kubectl can be found at: ```https://kubernetes.io/docs/tasks/tools/install-kubectl/```

#### Install gcloud skd and tools 

Instructions to install the Google cloud SKD can be found at: ```https://cloud.google.com/sdk/install```


#### Download the kubernetes (GKE) credentials to your local system. 

 - You will need the GKE cluster name, the zone name and the project id 
 - Execute ``` gcloud container clusters get-credentials <cluster name> --zone <zone name> --project <project name> ```

#### Create a kubernetes cluster role binding 

Execute the following command:

```
kubectl create clusterrolebinding cluster-admin-binding \
    --clusterrole=cluster-admin \
    --user=$(gcloud config get-value core/account)
```

`Script link`: ``` https://github.com/vinayvenkat/gke_k8s_deployer/blob/master/cluster-role.sh ```

#### Download the Istio code base if you don't have Istio already installed

Execute the following command:

   ``` ./download_istio.sh ``` 


#### Setup and deploy the Istio Custom Resource Definitions 

   Note: It is assumed that the scripts will be executed from 
  		 the top level HOME directory. In other words 
		 ``` ~/$HOME/pan_google_next_istio_lab/``` directory. 

   Execute the following command: 
   ``` ./istio-cfg.sh install_istio ```

`Script link`: ``` https://github.com/PaloAltoNetworks/pan_google_next_istio_lab/blob/master/istio-cfg.sh ```

#### Verify the Istio installation 

 - Ensure that Istio and all its components have been successfully installed. 
 - Execute: ```kubectl get po -n istio-system```

   The output should resemble: 
   ```
    vinay@vv15-ubuntu18:~/go/src/$ kubectl get po -n istio-system
        NAME                                      READY   STATUS      RESTARTS   AGE
        grafana-9cfc9d4c9-dqp9f                   1/1     Running     0          20d
        istio-citadel-74df865579-9qd2s            1/1     Running     0          20d
        istio-cleanup-secrets-mjlhq               0/1     Completed   0          20d
        istio-egressgateway-96fb7964f-jdn6x       1/1     Running     0          20d
        istio-galley-8487989b9b-zhclr             1/1     Running     0          20d
        istio-grafana-post-install-2p6hw          0/1     Completed   0          20d
        istio-ingressgateway-75d6486b96-q762r     1/1     Running     0          20d
        istio-pilot-78776dd4bd-tkpsn              2/2     Running     0          20d
        istio-policy-67f87dd-zjnvp                2/2     Running     0          20d
        istio-security-post-install-j9wzc         0/1     Completed   0          20d
        istio-sidecar-injector-5cfcf6dd86-7bfd6   1/1     Running     0          20d
        istio-telemetry-9b566b9c7-c9phj           2/2     Running     0          20d
        istio-tracing-ff94688bb-5thvh             1/1     Running     0          20d
        prometheus-f556886b8-754zr                1/1     Running     0          20d
        servicegraph-55d57f69f5-k7vt2             1/1     Running     0          20d
   ```
#### Create a namespace for user applications to be deployed into. 

	Note: for the purposes of this lab, please name the namespace ```pan-gcp-lab```
	
	Execute the following command:

	``` ./istio-cfg.sh create_namespace pan-gcp-lab ```


## Install the Palo Alto Networks Security Policy Management Simulator

Note: 
	  (1) Ensure that your working directory is $HOME
		  Execute:
		  cd $HOME

#### Clone the Palo Alto Networks Policy Management Simulator repo

Execute:
	``` git clone https://github.com/vinayvenkat/pan_istio_policy_simulator.git ```	 

Ensure that the directory structure resembles: ``` $HOME/pan_istio_policy_simulator ```


#### Deploy the Palo Alto Networks Policy Management Simulator Service 

Execute: ``` cd $HOME/pan_istio_policy_simulator ```

Execute : ``` kubectl create configmap panw-security-policies --from-file sec_policy.json ```

Execute : ``` kubectl apply -f panw_policy.yaml ```

#### Validate that the policy simulator container and service are running 

To validate the service execute: ``` kubectl get svc panw-policy ```
You should see the panw-policy service listed. 

To validate the deployment of the container execute: ``` kubectl get deployment panw-policy ```
You should see the panw-policy deployment listed and running. 

## Important: Extract the podIP of the panw-policy simulator service 

Execute: ``` kubectl get po ``` 

Output should resemble: ```
NAME                           READY   STATUS    RESTARTS   AGE
curl-775f9567b5-8clc8          1/1     Running   1          53m
panw-policy-5ff6c586c7-44bvm   1/1     Running   0          7d
```
Copy the name of the panw-policy container in its entirety. 

Execute: ``` kubectl get panw-policy-5ff6c586c7-44bvm -o yaml | grep podIP ``` 

Output will resemble: ```
	podIP: 10.28.3.59
```

Note: You will need this IP when editing the yaml file pertaining to the Palo Alto Networks Security Adapter deployment config. 

## Install the Palo Alto Networks Security Adapter

Note: 
	  (1) Ensure that your working directory is $HOME
		  Execute:
		  cd $HOME

#### Clone the Palo Alto Networks Istio Security Adapter repo

Execute:
	``` git clone git@github.com:PaloAltoNetworks/istio.git ```	 

Ensure that the directory structure resembles: ``` $HOME/istio ```

#### Change directory into istio/GKE directory

Execute: ``` cd istio/GKE ```

#### Edit the file called ```pan-servicemesh-security-k8s.yaml``` in the ```operatorconfig``` directory.

Edit operatorconfig/pan-servicemesh-security-k8s.yaml file. 

Change the value for the ```SECURITY_POLICY_API_ENDPOINT``` variable. 
Example show below:

```
 - name: SECURITY_POLICY_API_ENDPOINT
   value: "http://<IP_ADDRESS>:9080"
``` 

Replace the IP Address obtained for the pod in place of the <IP_ADDRESS> field above. 

## Deploy the Palo Alto Networks Security Adapter

Execute: ```kubectl apply -f operatorconfig```

This will install all the components required to run the Palo Alto Networks 
Security adapter on the kubernetes cluster. 

### Verify the installation of the Palo Alto Networks Adapter 


   The output should resemble: 
   ``` 
	vinay@vv15-ubuntu18:~/go/src/$ kubectl get po -n istio-system
		NAME                                      READY   STATUS      RESTARTS   AGE
		grafana-9cfc9d4c9-dqp9f                   1/1     Running     0          20d
		istio-citadel-74df865579-9qd2s            1/1     Running     0          20d
		istio-cleanup-secrets-mjlhq               0/1     Completed   0          20d
		istio-egressgateway-96fb7964f-jdn6x       1/1     Running     0          20d
		istio-galley-8487989b9b-zhclr             1/1     Running     0          20d
		istio-grafana-post-install-2p6hw          0/1     Completed   0          20d
		istio-ingressgateway-75d6486b96-q762r     1/1     Running     0          20d
		istio-pilot-78776dd4bd-tkpsn              2/2     Running     0          20d
		istio-policy-67f87dd-zjnvp                2/2     Running     0          20d
		istio-security-post-install-j9wzc         0/1     Completed   0          20d
		istio-sidecar-injector-5cfcf6dd86-7bfd6   1/1     Running     0          20d
		istio-telemetry-9b566b9c7-c9phj           2/2     Running     0          20d
		istio-tracing-ff94688bb-5thvh             1/1     Running     0          20d
		pan-securityadapter-6789d7d88f-49tmk      1/1     Running     0          24s
		prometheus-f556886b8-754zr                1/1     Running     0          20d
		servicegraph-55d57f69f5-k7vt2             1/1     Running     0          20d
``` 

You will see the Palo Alto Networks security adapter's container. In this case it is: 
```pan-securityadapter-6789d7d88f-49tmk```

#### Install the application 

	Execute: 

	``` ./manage_app.sh create ```

	Note: Follow the instructions from the output of the script to validate that 
		  your application is installed and is accessible. 

### Verify that the application is deployed

Execute: ``` kubectl get po -n pan-gcp-lab ```


## Lab Clean up 

#### Delete the application 

	Execute:
	
	``` ./manage_app.sh delete ```
