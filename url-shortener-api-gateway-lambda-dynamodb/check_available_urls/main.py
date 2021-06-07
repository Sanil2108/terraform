import json
import uuid
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
    "ProjectionExpression": "shortUrl",
    "FilterExpression": Key("shortUrl").eq(shortUrl)
  }
  response_items = []
  while True:
    response = table.scan(**scanKwargs)
    response_items += response["Items"]
    start_key = response.get('LastEvaluatedKey', None)
    if start_key is None:
      break
  return {
    "code": 200,
    "available": len(response_items) is 0
  }
