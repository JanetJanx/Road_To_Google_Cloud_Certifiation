## Task 1. Create a project jumphost instance
1. Go to Compute Engine > VM Instance > CREATE INSTANCE
2. In the Create function dialog, considr the following values:
    - Name for the VM instance : <given instance name>
    - Region : leave Default Region
    - Zone : leave Default Zone
    - Machine Type : f1-micro (N1 Series)
    - Boot Disk : use the default image type (Debian/Linux)
3. Create.

## Task 2: Create a Kubernetes service cluster

### Using the Google Cloud shell
1. Activate the shell
2. gcloud config set compute/zone <given lab zone>
3. gcloud container clusters create <cluster name of your choice>
4. gcloud container clusters get-credentials <name of created bucket>
5. kubectl create deployment hello-app --image=gcr.io/google-samples/hello-app:2.0
6. kubectl expose deployment hello-app --type=LoadBalancer --port 8080
7. kubectl get service 

## Task 3: Setup an HTTP load balancer
1. Create the startup.sh using the command below:-

```

cat << EOF > startup.sh
#! /bin/bash
apt-get update
apt-get install -y nginx
service nginx start
sed -i -- 's/nginx/Google Cloud Platform - '"\$HOSTNAME"'/' /var/www/html/index.nginx-debian.html
EOF

```

2. Create an instance template:

```

gcloud compute instance-templates create nginx-template \
--metadata-from-file startup-script=startup.sh

```

3. Create a target pool:

```

gcloud compute target-pools create nginx-pool

```

4. Create a managed instance group:

```

gcloud compute instance-groups managed create nginx-group --base-instance-name nginx --size 2 --region <given_region_name>  --template nginx-template --target-pool nginx-pool
gcloud compute instances list

```
5. Create a firewall rule to allow traffic (80/tcp):

```
gcloud compute firewall-rules create grant-tcp-rule-560 --allow tcp:80
gcloud compute forwarding-rules create nginx-lb --region us-west4 --ports=80 --target-pool nginx-pool
gcloud compute forwarding-rules list

```

6. Create a health check:

```
gcloud compute http-health-checks create http-basic-check
gcloud compute instance-groups managed set-named-ports nginx-group --region=<given_region_name> --named-ports http:80

```
7. Create a backend service and attach the manged instance group:

```

gcloud compute backend-services create nginx-backend \
--protocol HTTP --http-health-checks http-basic-check --global
gcloud compute backend-services add-backend nginx-backend \
--instance-group nginx-group \
--instance-group-region <given_region_name> \
--global

```

8. Create a URL map and target HTTP proxy to route requests to your URL map:

```

gcloud compute url-maps create web-map \
--default-service nginx-backend
gcloud compute target-http-proxies create http-lb-proxy \
--url-map web-map

```

9. Create a forwarding rule:

```

gcloud compute forwarding-rules create http-content-rule \
--global \
--target-http-proxy http-lb-proxy \
--ports 80
gcloud compute forwarding-rules list

```

## NB: Click Check my progress to verify the objective.