import json
import numpy as np
import requests
from PIL import Image
import io

def lambda_handler(event, context):
  message =  json.loads(json.loads(event['Records'][0]['body'])['Message'])

  image_url = message['image_url']
  response = requests.get(image_url)
  img = Image.open(io.BytesIO(response.content))
  img_arr = np.asarray(img)

  black_and_white_image = img.convert('L')
  black_and_white_image_arr = np.asarray(black_and_white_image)

  print(black_and_white_image_arr)

  return {
    'statusCode': 200,
    'body': json.dumps('Hello from Lambda!')
  }
