import json
import os
import boto3
from datetime import datetime
from urllib.parse import unquote_plus

dynamodb = boto3.resource('dynamodb')
table_name = os.environ['DYNAMODB_TABLE_NAME']
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    """
    S3 Event-driven Lambda function to ingest file metadata into DynamoDB.
    Triggered by S3 ObjectCreated events.
    """
    print(f"Received event: {json.dumps(event)}")

    for record in event.get('Records', []):
        try:
            bucket_name = record['s3']['bucket']['name']
            object_key = unquote_plus(record['s3']['object']['key'])
            event_time = record['eventTime']
            event_name = record['eventName']

            # Get object metadata
            s3_client = boto3.client('s3')
            response = s3_client.head_object(Bucket=bucket_name, Key=object_key)

            file_size = response.get('ContentLength', 0)
            content_type = response.get('ContentType', 'unknown')

            # Create file ID (using object key as unique identifier)
            file_id = object_key.replace('/', '_').replace('.', '_')

            # Prepare metadata item
            item = {
                'file_id': file_id,
                'object_key': object_key,
                'bucket_name': bucket_name,
                'file_size': file_size,
                'content_type': content_type,
                'upload_timestamp': event_time,
                'event_type': event_name
            }

            # Store in DynamoDB
            table.put_item(Item=item)
            print(f"Stored metadata for {object_key}")

        except Exception as e:
            print(f"Error processing record: {str(e)}")
            raise

    return {
        'statusCode': 200,
        'body': json.dumps('Successfully processed S3 event')
    }