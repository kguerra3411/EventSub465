#!/bin/bash

#Install the amazon web service command line interface (awscli)
apt-get update
apt-get -y install awscli
apt-get -y install nano

#Modify the apache2 config file, wont serve files from network shares without modifications, gives http request errors
echo EnableSendfile Off >>/etc/apache2/apache2.conf
echo EnableMMAP Off >>/etc/apache2/apache2.conf

#set the S3 pull script to be executable
chmod -u+x /var/www/html/startup.sh

#Build symbolic links to Image folder and Elastic File Share mount
rm -R images
ln -sf /var/www/html/imagesLink /var/www/html/images
