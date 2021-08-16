FROM 	debian:buster

LABEL	maintainer="jwoo <jwoo@student.42seoul.kr>"

RUN		mkdir ft_server_srcs && \
			apt-get update && apt-get -y upgrade && \
			apt-get -y install \
			nginx \
			curl \
			openssl \
			vim \
			php-fpm \
			mariadb-server \
			php-mysql \
			php-mbstring \
			wget

COPY	./srcs/run.sh ./
COPY	./srcs/default ./ft_server_srcs
COPY	./srcs/wp-config.php ./ft_server_srcs
COPY	./srcs/config.inc.php ./ft_server_srcs
COPY	./srcs/phpMyAdmin-5.0.4-all-languages.tar.gz ./
COPY	./srcs/latest.tar.gz ./

RUN		tar -xvf phpMyAdmin-5.0.4-all-languages.tar.gz && tar -xvf latest.tar.gz && \
			mv phpMyAdmin-5.0.4-all-languages phpmyadmin &&	mv phpmyadmin ./var/www/html/ && \
			mv wordpress/ ./var/www/html/ && \
			cp -rp ./ft_server_srcs/default ./etc/nginx/sites-available/ && \
			cp -rp ./ft_server_srcs/config.inc.php ./var/www/html/phpmyadmin/ &&\
			cp -rp ./ft_server_srcs/wp-config.php ./var/www/html/wordpress/

EXPOSE	80 443

CMD		bash run.sh
