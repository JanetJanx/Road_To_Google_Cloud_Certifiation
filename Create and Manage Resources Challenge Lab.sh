

Task 2: Create a Kubernetes service cluster - GUI

Activate the shell
gcloud config set compute/zone us-central1

gcloud container clusters create autopilot-cluster-1

gcloud container clusters get-credentials nucleus-cluster-1

kubectl create deployment hello-app --image=gcr.io/google-samples/hello-app:2.0

kubectl expose deployment hello-app --type=LoadBalancer --port 8080

kubectl get service 

Task 3:

nano startup.sh

cat << EOF > startup.sh
#! /bin/bash
apt-get update
apt-get install -y nginx
service nginx start
sed -i -- 's/nginx/Google Cloud Platform - '"\$HOSTNAME"'/' /var/www/html/index.nginx-debian.html
EOF

gcloud compute instance-templates create nginx-template \
--metadata-from-file startup-script=startup.sh

gcloud compute target-pools create nginx-pool

gcloud compute instance-groups managed create nginx-group --base-instance-name nginx --size 2 --region us-west4  --template nginx-template --target-pool nginx-pool

gcloud compute instances list


gcloud compute firewall-rules create grant-tcp-rule-560 --allow tcp:80

gcloud compute forwarding-rules create nginx-lb --region us-west4 --ports=80 --target-pool nginx-pool

gcloud compute forwarding-rules list


->>> Create a health check :

gcloud compute http-health-checks create http-basic-check
gcloud compute instance-groups managed set-named-ports nginx-group --region=us-west4 --named-ports http:80

Backend service
gcloud compute backend-services create nginx-backend \
--protocol HTTP --http-health-checks http-basic-check --global

-->Create a URL map and target HTTP proxy to route requests to your URL map :

gcloud compute url-maps create web-map \
--default-service nginx-backend

gcloud compute target-http-proxies create http-lb-proxy \
--url-map web-map

8 .Create a forwarding rule :

gcloud compute forwarding-rules create http-content-rule \
--global \
--target-http-proxy http-lb-proxy \
--ports 80

gcloud compute forwarding-rules list

