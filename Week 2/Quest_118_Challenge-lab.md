# Perform Foundational Infrastructure Tasks in Google Cloud: Challenge Lab

## Task 1: Create a bucket
```
gsutil mb gs://<bucket_name>
```

## Task 2: Create a Pub/Sub topic
```
gcloud pubsub topics create <given_topic_name>
```

## Task 3: Create the thumbnail Cloud Function
Create a Cloud Function called memories-thumbnail-generator that executes every time an object is created in the bucket memories-bucket-36938 you created in task 1. The function is written in <given node.js function>.
Make sure you set the Entry point (Function to execute) to thumbnail and Trigger to Cloud Storage.
In line 15 of index.js replace the text REPLACE_WITH_YOUR_TOPIC ID with the <given_topic_name> you created in task 2.

1. Go to search and enter Cloud Function. In the Create function dialog, considr the following values:

    1. Name : [Given Lab Name]
    2. Trigger Type : Cloud Storage
    3. Event Type : On (finalizing/creating) file in the selected bucket
    4. Browse the bucket you have created and click Save.
    5. click Next
    6. Set Runtime as [given node.js function] #Note check the node.js function in the lab
    7. Entry point : thumbnail
    8. Following the lab instructions:-
        - replace code for index.js and package.json
        - replace the text REPLACE_WITH_YOUR_TOPIC ID with the topic you created in task 2 in the index.js.
    9. click Deploy

2. After deploying the function, upload an image in your bucket. Afterwards, click REFRESH to see a thumbnail image for the image you uploaded.

## Task 4: Remove the previous cloud engineer
1. Go to IAM & Admin -> IAM
2. Search for Username 2 and click "REMOVE ACCESS".
3. Click Check my progress to verify your performed task.
