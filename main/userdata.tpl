#!/bin/bash
sleep 120
yum update -y 
yum install -y httpd
systemctl start httpd && systemctl enable httpd
cd /var/www/html
echo "<html><h1>This is running. Go check the health checks<h1></html>" > index.html
