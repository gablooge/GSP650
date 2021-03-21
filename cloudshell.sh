#!/bin/bash
gcloud pubsub topics create new-lab-report

gcloud services enable run.googleapis.com

# Task 2
# git clone https://github.com/rosera/pet-theory.git

cd pet-theory/lab05/lab-service

npm install express
npm install body-parser
npm install @google-cloud/pubsub


chmod u+x deploy.sh
./deploy.sh


export LAB_REPORT_SERVICE_URL=$(gcloud run services describe lab-report-service --platform managed --region us-central1 --format="value(status.address.url)")
echo $LAB_REPORT_SERVICE_URL

chmod u+x post-reports.sh
./post-reports.sh


cd ~/GSP650/pet-theory/lab05/email-service

npm install express
npm install body-parser

chmod u+x deploy.sh
./deploy.sh

gcloud iam service-accounts create pubsub-cloud-run-invoker --display-name "PubSub Cloud Run Invoker"

gcloud run services add-iam-policy-binding email-service --member=serviceAccount:pubsub-cloud-run-invoker@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com --role=roles/run.invoker --region us-central1 --platform managed

PROJECT_NUMBER=$(gcloud projects list --filter="qwiklabs-gcp" --format='value(PROJECT_NUMBER)')

gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT --member=serviceAccount:service-$PROJECT_NUMBER@gcp-sa-pubsub.iam.gserviceaccount.com --role=roles/iam.serviceAccountTokenCreator

EMAIL_SERVICE_URL=$(gcloud run services describe email-service --platform managed --region us-central1 --format="value(status.address.url)")

echo $EMAIL_SERVICE_URL

gcloud pubsub subscriptions create email-service-sub --topic new-lab-report --push-endpoint=$EMAIL_SERVICE_URL --push-auth-service-account=pubsub-cloud-run-invoker@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com

~/pet-theory/lab05/lab-service/post-reports.sh


cd ~/GSP650/pet-theory/lab05/sms-service

npm install express
npm install body-parser