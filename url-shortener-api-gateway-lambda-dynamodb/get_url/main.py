import json
import uuid
import time
import boto3
from boto3.dynamodb.conditions import Key

dynamodb = boto3.resource("dynamodb")

table = dynamodb.Table("ShortURLs")

# Example
# {
#   "shortUrl": "testing2"
# }
def lambda_handler(event, context):
  shortUrl = event["shortUrl"]
  
  # Find out if the shortURL is available or not
  scanKwargs = {
    "AttributesToGet": ["shortUrl" , "url"],
    "ScanFilter": {
      "shortUrl": {
        "AttributeValueList": [shortUrl],
        "ComparisonOperator": "EQ"
      }
    }
  }
  response_items = []
  while True:
    response = table.scan(**scanKwargs)
    response_items += response["Items"]
    start_key = response.get('LastEvaluatedKey', None)
    if start_key is None:
      break
  if len(response_items) is 0:
    return {
      "code": 400,
      "message": "This short URL does not exist"
    }
  else:
    return {
      "code": 200,
      "url": response_items[0]["url"]
    }