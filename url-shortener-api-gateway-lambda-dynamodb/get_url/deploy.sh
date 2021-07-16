#!/bin/bash

# Ensure that you are logged in using this command
# aws ecr get-login-password --region ap-south-1 --profile aws_at_sanil_me | docker login --username AWS --password-stdin 067237244850.dkr.ecr.ap-south-1.amazonaws.com

ecr_url=067237244850.dkr.ecr.ap-south-1.amazonaws.com/url_shortening_repository_get:latest

docker build -t url-shortener-get .
docker tag url-shortener-get:latest $ecr_url
docker push $ecr_url
