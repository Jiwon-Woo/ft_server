#!/bin/bash

chmod 775 /run.sh
chown -R www-data:www-data /var/www/
chmod -R 755 /var/www/

openssl req -newkey rsa:4096 -days 365 -nodes -x509 -subj "/C=KR/ST=Seoul/L=Seoul/O=42Seoul/OU=42Seoul/CN=localhost" -keyout localhost.dev.key -out localhost.dev.crt
mv localhost.dev.crt etc/ssl/certs/
mv localhost.dev.key etc/ssl/private/
chmod 600 etc/ssl/certs/localhost.dev.crt etc/ssl/private/localhost.dev.key

service nginx start
service php7.3-fpm start
service mysql start

mysql < var/www/html/phpmyadmin/sql/create_tables.sql -u root --skip-password
mysql -u root -e "CREATE DATABASE IF NOT EXISTS wordpress;"
mysql -u root -e "CREATE USER IF NOT EXISTS 'jwoo'@'%' IDENTIFIED BY 'jwoo';"
mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'jwoo'@'%' IDENTIFIED BY 'jwoo' WITH GRANT OPTION;"

service nginx restart
service php7.3-fpm start
service mysql restart

bash
