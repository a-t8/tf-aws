#!/bin/bash
yum update -y
yum install httpd -y
yum install git -y
su - ec2-user -c "git clone https://github.com/gabrielecirulli/2048"
su - ec2-user -c "cd /var/www/html"
su - ec2-user -c "sudo cp -R /home/ec2-user/2048/* /var/www/html"
systemctl start httpd
systemctl enable httpd
