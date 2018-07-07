# iotcore-heartrate

This project contains the code necessary to setup either (1) a Raspberry Pi with a heart rate sensor or (2) a Google Cloud Compute Engine VM with a data simulation script in order to demonstrate how Google Cloud IoT Core works. The full instructions are contained this Codelab (URL TBD).

## Data Simulation Quickstart

NOTE: Replace PROJECT_ID with your project in the following commands

1. Login to Google Cloud. If desired, create a new project and select it once it is ready. Open a Cloud shell

2. Create a BigQuery dataset and table (replace PROJECT_ID with your project):

        $bq --location=US mk --dataset PROJECT_ID:heartRateData
        $bq mk --table PROJECT_ID:heartRateData.heartRateDataTable sensorID:STRING,uniqueID:STRING,timecollected:TIMESTAMP,heartrate:FLOAT

3. Create a PubSub topic:

        $gcloud beta pubsub topics create projects/PROJECT_ID/topics/heartratedata

4. Create a Dataflow process

        Calling Google-provided Dataflow templates from the command line is not yet supported. Follow the Codelab to do so via the Cloud Console.

4. Create a registry:

        $gcloud beta iot registries create heartrate \
            --project=PROJECT_ID \
            --region=us-central1 \
            --event-pubsub-topic=projects/PROJECT_ID/topics/heartratedata

5. Create a VM

        $gcloud compute instances create data-simulator-1 --zone us-central1-c

6. Use the Cloud Console to SSH to the newly created VM. From the command line, install the necessary software and create a security certificate.

        $sudo apt-get update
        $sudo apt-get install git
        $git clone https://github.com/googlecodelabs/iotcore-heartrate
        $cd iotcore-heartrate
        $chmod +x initialsoftware.sh
        $./initialsoftware.sh
        $chmod +x generate_keys.sh
        $./generate_keys.sh

7. Return to the Cloud shell and copy the public key that was just generated.

        $gcloud compute scp data-simulator-1:/home/[USER_NAME]/.ssh/ec_public.pem .

8. Register a device:

        $gcloud beta iot devices create myVM \
            --project=PROJECT_ID \
            --region=us-central1 \
            --registry=heartrate \
            --public-key path=ec_public.pem,type=es256

8. Return to the VM console. Send the mock data (data/SampleData.json) using the simulateData.py script. This publishes several hundred JSON-formatted messages to the device's MQTT topic one by one:

        $python simulateData.py --registry_id=heartrate --project_id=PROJECT_ID --device_id=myVM
