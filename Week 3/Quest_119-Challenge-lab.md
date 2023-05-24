# Set Up and Configure a Cloud Environment in Google Cloud: Challenge Lab
As a cloud engineer in Jooli Inc. and recently trained with Google Cloud and Kubernetes you have been asked to help a new team (Griffin) set up their environment. The team has asked for your help and has done some work, but needs you to complete the work.

You are expected to have the skills and knowledge for these tasks so don’t expect step-by-step guides.
You need to complete the following tasks:
1. Create a development VPC with three subnets manually
2. Create a production VPC with three subnets manually
3. Create a bastion that is connected to both VPCs
4. Create a development Cloud SQL Instance and connect and prepare the WordPress environment
5. Create a Kubernetes cluster in the development VPC for WordPress
6. Prepare the Kubernetes cluster for the WordPress environment
7. Create a WordPress deployment using the supplied configuration
8. Enable monitoring of the cluster via stackdriver
9. Provide access for an additional engineer

## Task 1. Create development VPC manually
Create a VPC called griffin-dev-vpc with the following subnets only:
1. griffin-dev-wp
    - IP address block: 192.168.16.0/20
2. griffin-dev-mgmt
    - IP address block: 192.168.32.0/20

### Use the following commands:-
```
gcloud compute networks create griffin-dev-vpc --subnet-mode=custom
gcloud compute networks subnets create griffin-dev-wp --network=griffin-dev-vpc --region=us-east1 --range=192.168.16.0/20
gcloud compute networks subnets create griffin-dev-mgmt --network=griffin-dev-vpc --region=us-east1 --range=192.168.32.0/20
```

## Task 2. Create production VPC manually
Create a VPC called griffin-prod-vpc with the following subnets only:
1. griffin-prod-wp
    - IP address block: 192.168.48.0/20
2. griffin-prod-mgmt
    - IP address block: 192.168.64.0/20

### Use the following commands:-
```
gcloud compute networks create griffin-prod-vpc --subnet-mode=custom
gcloud compute networks subnets create griffin-prod-wp --network=griffin-prod-vpc --region=us-east1 --range=192.168.48.0/20
gcloud compute networks subnets create griffin-prod-mgmt --network=griffin-prod-vpc --region=us-east1  --range=192.168.64.0/20
```
## Task 3. Create bastion host
1. Go to Compute Engine > VM instances and click "CREATE INSTANCE".
2. Use the parameters below:-
    - Name:[Name of choice e.g griffin-bastion-host]
    - Region:us-east1
3. Click Create.
4. Create two firewall rules that permit tcp traffic via port 22 on the griffin-dev-vpc and griffin-dev-vpc respectively:
    - Firewall rule 1
        * Name:allow-griffin-bastion-host-ssh
        * Network:griffin-dev-vpc
        * Targets:bastion
        * Source IP ranges:192.168.32.0/20
        *  Protocols and ports: tcp: 22
        ```
        gcloud compute --project=<Project_ID> firewall-rules create allow-griffin-bastion-dev-ssh --description=allow-griffin-bastion-dev-ssh --direction=INGRESS --priority=1000 --network=griffin-dev-vpc --action=ALLOW --rules=tcp:22 --source-ranges=192.168.32.0/20 --target-tags=bastion
        ```
    - Firewall rule 2
        * Name:allow-griffin-bastion-prod-ssh
        * Network: griffin-prod-vpc
        * Targets:bastion
        * Source IP ranges:192.168.48.0/20 
        * Protocols and ports:tcp: 22
        ```
        gcloud compute --project=<Project_ID> firewall-rules create allow-griffin-bastion-prod-ssh --description=allow-griffin-bastion-prod-ssh --direction=INGRESS --priority=1000 --network=griffin-prod-vpc --action=ALLOW --rules=tcp:22 --source-ranges=192.168.48.0/20 --target-tags=bastion
        ```
## Task 4. Create and configure Cloud SQL Instance
1. Create a MySQL Cloud SQL Instance called griffin-dev-db in us-east1.
    - Go to SQL > CREATE INSTANCE > Choose MYSQL
    - Enter Instance name and set password of choice {'ydd/`9U$|XC:>KK} (Recommend use of the Generate option). Make sure you remember it.
    - Database version: 5.7 and above
    - Region us-east1
    - Leave the rest as defaults
    - Click on the created instance ```griffin-dev-db``` and go to "Connect to this instance" under "To connect using gcloud" and click on "OPEN CLOUD SHELL". By default, you will see the command below:
    ```
    gcloud sql connect griffin-dev-db --user=root --quiet
    ```
    - Run the command above and enter the saved instance password at creation
    - Run the command below:-
    ```
    CREATE DATABASE wordpress;
    CREATE USER "wp_user"@"%" IDENTIFIED BY "stormwind_rules";
    GRANT ALL PRIVILEGES ON wordpress.* TO "wp_user"@"%";
    FLUSH PRIVILEGES;
    ```


## Task 5. Create Kubernetes cluster
Create a 2 node cluster (n1-standard-4) called griffin-dev, in the griffin-dev-wp subnet, and in zone us-east1-b.
1. Go to Kubernetes Engine > Clusters and click "Create"
2. Enter the Cluster name and set the region as instructed in the lab
3. Set the network to griffin-dev-vpc and subnet as griffin-dev-wp
4. Leave the rest as defaukt and click "Create Cluster"


## Task 6. Prepare the Kubernetes cluster
1. Use Cloud Shell and copy all files from gs://cloud-training/gsp321/wp-k8s.
    ```
    gsutil cp -r gs://cloud-training/gsp321/wp-k8s ~/
    ```
2. Edit wp-k8s/wp-env.yaml and replace '```username_goes_here``` and ```password_goes_here``` to ```wp-user``` and ```stormwind_rules```,
    ```
    vi wp-k8s/wp-env.yaml
    ```
3. Connect to the Kubernetes cluster
    ```
    gcloud container clusters get-credentials griffin-dev --region us-east1 --project <Project_ID>
    ```
4. Deploy the configuration to the cluster using
    ```
    kubectl apply -f wp-k8s/wp-env.yaml
    ```
5. Create the key, and then add the key to the Kubernetes environment:
    ```
    gcloud iam service-accounts keys create key.json \
        --iam-account=cloud-sql-proxy@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com
    kubectl create secret generic cloudsql-instance-credentials \
        --from-file key.json
    ```
Task 7. Create a WordPress deployment

1. edit wp-deployment.yaml. and Replace YOUR_SQL_INSTANCE with griffin-dev-db's Instance connection name.
    ```
    vi wp-k8s/wp-deployment.yaml
    ```
2. Get the Instance connection name from your Cloud SQL instance.
    ```
    kubectl create -f wp-k8s/wp-deployment.yaml
    kubectl create -f wp-k8s/wp-service.yaml
    ```

## Task 8. Enable monitoring
Create an uptime check for your WordPress development site.
1. Go to Monitoring > Uptime checks and click CREATE UPTIME CHECK.
    - Title [Name of Choice]
    - Resource Type [URL]
    - Check Type [HTTP]
    - Hostname [Your WordPress Endpoint]
    - Path: [/]
