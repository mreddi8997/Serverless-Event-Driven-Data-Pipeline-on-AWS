import boto3
import json
import os
import logging
import botocore.exceptions

logger= logging.getLogger(__name__)
logger.setLevel(logging.INFO)

dynamodb = boto3.resource('dynamodb', region_name='us-east-2')  # Specify your desired region
table = dynamodb.Table(os.getenv('DYNAMODB_TABLE_NAME'))  # Use the environment variable or default to 'servicerequest'


def lambda_handler(event, context):
    #extract the request_id from the api request
    path_parameters = event.get('pathParameters') or {}
    request_id = path_parameters.get('request_id')
    if not request_id:
        logger.warning("Missing 'request_id' in the request.")
        return {
            'statusCode': 400,
            'body': json.dumps({'error': "Missing 'request_id' in the request."})
        }

    try:
        response = table.get_item(Key={'request_id': request_id})
        item = response.get('Item')
        if not item:
            logger.warning(f"Request with ID '{request_id}' not found.")
            return {
                'statusCode': 404,
                'body': json.dumps({'error': f"Request with ID '{request_id}' not found."})
            }

        logger.info(f"Request with ID '{request_id}' retrieved successfully.")
        return {
            'statusCode': 200,
            'body': json.dumps(item)
        }
    except botocore.exceptions.ClientError as e:
        logger.exception(f"Error retrieving request with ID '{request_id}': {e}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': "Internal server error."})
        }
        