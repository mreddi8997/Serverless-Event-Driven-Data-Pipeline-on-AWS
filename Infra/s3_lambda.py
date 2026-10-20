import os

import boto3
import json
from urllib.parse import unquote_plus
from botocore.exceptions import ClientError
import logging

logging.basicConfig(level=logging.INFO)

s3 = boto3.client('s3', region_name='us-east-2')  # Specify your desired region
dynamodb = boto3.resource('dynamodb', region_name='us-east-2')  # Specify your desired region

table = dynamodb.Table(os.getenv('DYNAMODB_TABLE_NAME'))

def lambda_handler(event, context):
    

    #read the s3 event and get the bucket name and file name
    for record in event['Records']:
        bucket_name = record['s3']['bucket']['name']
        file_name = unquote_plus(record['s3']['object']['key'])
        logging.info(f"Bucket name: {bucket_name}")
        logging.info(f"File name: {file_name}")
        
        response = s3.get_object(Bucket=bucket_name, Key=file_name)
        response_body = response['Body'].read().decode('utf-8')
        request_data = json.loads(response_body)
        if not isinstance(request_data, dict):
            raise ValueError("Invalid request data. Expected a JSON object.")


        if request_data.get('request_id') and request_data.get('request_type'):
            request_id = request_data['request_id']
            request_type = request_data['request_type']
            logging.info(f"Request ID: {request_id}")
            logging.info(f"Request Type: {request_type}")
        else:
            raise ValueError("Invalid request data. 'request_id' and 'request_type' are required.")
        if isinstance(request_id, str) and isinstance(request_type, str):
            request_id = request_id.strip()
            request_type = request_type.strip()
            if not request_id or not request_type:
                raise ValueError("Invalid request data. 'request_id' and 'request_type' cannot be empty.") 
        else:
            raise ValueError("Invalid request data. 'request_id' and 'request_type' must be strings.")

        if request_type != "software_license":
            logging.error("Unsupported request type.")
            raise ValueError("unsupported request type.") 


        
        item = {
            'request_id': request_id,
            'request_type': request_type,
            'status': 'pending'
        }

        try:
            table.put_item(Item=item, ConditionExpression='attribute_not_exists(request_id)')
            logging.info(f"Request '{request_id}' saved successfully with status 'pending'.")
        except ClientError as e:
            error_code = e.response['Error']['Code']
            if error_code == 'ConditionalCheckFailedException':
                logging.info(f"Item with request_id '{request_id}' already exists in DynamoDB.")
            else:
                logging.error(f"Error occurred while putting item in DynamoDB: {error_code}")
                raise 
             