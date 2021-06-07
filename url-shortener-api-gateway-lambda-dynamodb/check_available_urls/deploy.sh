#!/bin/bash

# Ensure that you are logged in using this command
# aws ecr get-login-password --region ap-south-1 --profile aws_at_sanil_me | docker login --username AWS --password-stdin 067237244850.dkr.ecr.ap-south-1.amazonaws.com

ecr_url=067237244850.dkr.ecr.ap-south-1.amazonaws.com/url_shortening_repository_check:latest

docker build -t url-shortener-check .
# Test it locally using
# docker run -p 9000:8080 url-shortener-check
docker tag url-shortener-check:latest $ecr_url
docker push $ecr_url

