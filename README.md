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

3. Add the service account `cloud-iot@system.gserviceaccount.com` with the role `Publisher` to that
PubSub topic from the [Cloud Developer Console](https://console.cloud.google.com). This service account will be used by IOT Core
to publish the data to the Cloud Pub/Sub topic created above.

4. Create a Dataflow process

        Calling Google-provided Dataflow templates from the command line is not yet supported

4. Create a registry:

        $gcloud beta iot registries create heartrate \
            --project=PROJECT_ID \
            --region=us-central1 \
            --event-pubsub-topic=projects/PROJECT_ID/topics/iot-data

5. Use the `generate_keys.sh` script to generate your signing keys. This script creates a ES256 Public/Private Key pair (ec_public.pem/ec_private.pem) and also retrieves the Google root certificate (roots.pem) in the current directory

        $./generate_keys.sh

6. Register a device:

        $gcloud beta iot devices create myVM \
            --project=PROJECT_ID \
            --region=us-central1 \
            --registry=heartrate \
            --public-key path=ec_public.pem,type=es256

7. Install the dependencies needed to run the python client:
    
        $sudo pip install -r requirements.txt

8. Send the mock data (data/SampleData.json) using the no_sensor_cloudiot_gen.py script. This publishes 1000 JSON-formatted messages to the device's MQTT topic one by one:

        $python simulateData.py --registry_id=heartrate --project_id=PROJECT_ID --device_id=myVM

    To see all the command line options the script accepts, use 'python no_sensor_cloudiot_gen.py -h'. If you need to generate different mock data, you can use the data/datagen.py script and then use the --json_data_file option to specify the json file which contains your new data.
    The script pushes JSON-formatted data as follows.

    	Publishing message #1: '{"count": 1, "scanid": "scan000001", "hub_device_id": "hub8", "timestamp": "2017-12-30T20:42:26.761338Z", "storeid": "chi-store-02", "upc": "A800000011", "latlong": "41.879301,-87.655319", "event": "Placed"}'    
    	Publishing message #2: '{"count": 1, "scanid": "scan000002", "hub_device_id": "hub3", "timestamp": "2018-01-03T20:43:57.077348Z", "storeid": "nyc-store-03", "upc": "A800000039", "latlong": "40.753001,-73.988931", "event": "Placed"}'    
    	...    
    	Publishing message #1000: '{"count": 1, "scanid": "scan001000", "hub_device_id": "hub7", "timestamp": "2017-12-30T20:44:33.667104Z", "storeid": "sfo-store-01", "upc": "A800000014", "latlong": "37.791660,-122.403788", "event": "Placed"}'   
    	Finished.

