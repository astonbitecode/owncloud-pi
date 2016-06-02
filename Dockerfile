FROM mockersf/rpi2-archlinuxarm

MAINTAINER astonbitecode <astonbitecode@gmail.com>

# Install needed packages
RUN pacman -Syuv --noconfirm

RUN pacman -S --noconfirm --needed \
	procps-ng \
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
ADD resources/config/config.php /etc/webapps/owncloud/config/config.php

# Configure further
ADD resources/scripts/oc.sh /tmp/oc.sh
ADD resources/scripts/perms.sh /tmp/perms.sh
RUN sh /tmp/oc.sh

# Start the Apache
CMD httpd -D FOREGROUND
