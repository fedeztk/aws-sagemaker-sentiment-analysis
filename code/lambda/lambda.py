import logging
import os
import boto3
import json

logger = logging.getLogger()
logger.setLevel(logging.INFO)

ENDPOINT_NAME = os.environ["ENDPOINT_NAME"]
TABLE_NAME = os.environ["TABLE_NAME"]

dynamodb = boto3.resource('dynamodb') 
nlp_data_table = dynamodb.Table(TABLE_NAME)

runtime = boto3.client(service_name='sagemaker-runtime')


def lambda_handler(event, context):
    logger.info('Event: {}'.format(event))
    logger.info('Context: {}'.format(context))

    # check if the data is passed in the query string
    if not ('queryStringParameters' in event and 'data' in event['queryStringParameters']):
        return {
            'statusCode': 400,
            'body': json.dumps({'error': 'No data parameter in query string'})
        }
    
    # get the data from the query string
    data = json.dumps({"inputs": str(event['queryStringParameters']['data'])})

    data_dict = json.loads(data)

    response = runtime.invoke_endpoint(EndpointName=ENDPOINT_NAME, 
                                       ContentType='application/json', Body=data) 
    
    logger.info('Response: {}'.format(response))

    response_body = response['Body'] 
    response_str = response_body.read().decode('utf-8') 
    response_str = response_str.replace('[', '').replace(']', '') 
    response_dict = json.loads(response_str) 

 
    response_dict['data'] = data_dict['inputs'] 
    response_dict['id'] = context.aws_request_id 
    response_dict['score'] = str(response_dict['score']) 
    logger.info('Response Dict: {}'.format(response_dict))

    # send the response to dynamodb
    nlp_data_table.put_item(Item=response_dict) 
    
    return {
        'statusCode': 200,
        'body': json.dumps(response_dict)
    }