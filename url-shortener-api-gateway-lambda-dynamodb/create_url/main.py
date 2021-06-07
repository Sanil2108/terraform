import json
import uuid
import time
import boto3
from boto3.dynamodb.conditions import Key

dynamodb = boto3.resource("dynamodb")

table = dynamodb.Table("ShortURLs")

# Example
# {
#   "url": "gmail.com",
#   "shortUrl": "testing2"
# }
def lambda_handler(event, context):
  if "url" not in event or event["url"] == "" or "shortUrl" not in event or event["shortUrl"] == "":
    return {
      "code": 400,
      "message": "You need to pass both short url and url"
    }

  shortUrl = event["shortUrl"]
  url = event["url"]

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
    print(start_key)
    if start_key == None:
      break
  if len(response_items) != 0:
    return {
      "code": 400,
      "message": "This short URL already exists"
    }

  # Create a unique key for dynamo db
  key = str(uuid.uuid4())

  # Store the mapping between shortURL and longURL in DynamoDB
  put_item_response = table.put_item(
    Item={"id": key, "shortUrl": shortUrl, "url": url, "timestamp": int(time.time())})

  return {
    "code": 200,
    "endpoint": shortUrl
  }
