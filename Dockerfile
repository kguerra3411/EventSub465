FROM mediawiki:latest
WORKDIR /var/www/html/
ADD Image-mods-AWS.sh ./
ADD startup.sh ./
RUN bash /var/www/html/Image-mods-AWS.sh
ENTRYPOINT [ "/bin/bash", "/var/www/html/startup.sh" ]
CMD ["apache2-foreground"]
