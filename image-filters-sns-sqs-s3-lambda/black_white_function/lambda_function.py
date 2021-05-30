import json
import numpy as np
import requests
from PIL import Image
import io
import boto3

def lambda_handler(event, context):
  body = json.loads(event['Records'][0]['body'])

  message = json.loads(body['Message'])
  message_id = body['MessageId']

  image_url = message['image_url']
  response = requests.get(image_url)
  img = Image.open(io.BytesIO(response.content))
  img_arr = np.asarray(img)

  black_and_white_image = img.convert('L')
  # black_and_white_image_arr = np.asarray(black_and_white_image)

  img_byte_arr = io.BytesIO()
  black_and_white_image.save(img_byte_arr, format='PNG')
  file = img_byte_arr.getvalue()

  client = boto3.client('s3')
  client.put_object(Body=file, Bucket="sanil-khurana-image-filters-output-bucket", Key="%s-bw.png" % message_id)

  return {
    'statusCode': 200,
    'body': json.dumps('Hello from Lambda!')
  }
