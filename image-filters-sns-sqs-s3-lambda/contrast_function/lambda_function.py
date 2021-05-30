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

  high_contrast_image = img.point(lambda c : 10 * (c - 128))

  img_byte_arr = io.BytesIO()
  high_contrast_image.save(img_byte_arr, format='PNG')
  file = img_byte_arr.getvalue()

  client = boto3.client('s3')
  client.put_object(Body=file, Bucket="sanil-khurana-image-filters-output-bucket", Key="%s-contrast.png" % message_id)

  return {
    'statusCode': 200,
    'body': json.dumps('Hello from Lambda!')
  }
