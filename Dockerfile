FROM oestrich/arch-pi

MAINTAINER astonbitecode <astonbitecode@gmail.com>

# Install needed packages
RUN pacman -Sy --noconfirm

RUN pacman -Syuv --noconfirm

RUN pacman -S --noconfirm --needed \
#	sudo \
	apache \
	owncloud \
	php-intl \
	php-mcrypt \
	php-apcu \
	exiv2 \
	php-sqlite \
	php-pgsql \
	php-apache

# Copy owncloud configuration
ADD resources/config/config.php /usr/share/webapps/owncloud/config/config.php

# Configure further
ADD resources/scripts/oc.sh /tmp/oc.sh
RUN sh /tmp/oc.sh

# Start the Apache
CMD httpd -D FOREGROUND
