# Walking Skeleton
The purpose of this walking skeleton is to de-risk the technical uncertainty around creating a new live service for HSCN.

# Setup

## Manual Steps
 
### Create S3 bucket to hold lambda code
This will become the bucket to hold the application code used in lambdas
1. Navigate to your S3 console 
2. Create a bucket named `prm-application-source` and keep all the default settings

### Upload BitBucket code to S3 bucket
1. Navigate to the BitBucket repo
2. Download the directory
3. Zip up the contents of the directory while ensuring there is no additional directory on root level
4. Rename the zip file to *latest.zip*
5. Navigate to S3 console and open the *prm-application-source* bucket
6. Upload the zipped file to the root level of the bucket
### Upload application code to S3 bucket
1. Navigate to the project directory
2. Run the command 
`cd lambda/ehr-extract-handler && zip ../../example main.js`
3. Navigate to S3 console, open the *prm-application-source* bucket and upload example.zip at root level
### Set event trigger in S3 bucket
Every time there is a change in the `prm-application-source` bucket, i.e. main.js is edited, a 'helper' lambda *(fileHasher)* will be triggered to update the code in EhrExtractHandler lambda by pulling the new resources from the `prm-application-source` bucket.
1. Navigate to S3 console
2. Select the **Properties** tab
3. Scroll down to **Advanced Settings**
4. Select **Events**
5. Click **Add Notification**
6. Under **Events** section, select **All object create events**
7. Under **Send to** select **Lambda Function**
8. In the dropdown, select *fileHasher*
9. Select **Save**

## Run Terragrunt commands
1. Run `terragrunt apply`
2. Type *yes* to build the infrastructure 

