#!/bin/bash

sudo apt-get update
sudo apt-get install -y nginx

sudo chmod =777 /var/www/html/index.nginx-debian.html
echo "<html>Hello from 2</html>" > /var/www/html/index.nginx-debian.html
sudo nginx -s reload