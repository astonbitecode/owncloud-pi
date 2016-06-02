#!/bin/bash

# Main PHP changes
sed -i 's/;extension=gd.so/extension=gd.so/g' /etc/php/php.ini
sed -i 's/;extension=iconv.so/extension=iconv.so/g' /etc/php/php.ini
sed -i 's/;extension=xmlrpc.so/extension=xmlrpc.so/g' /etc/php/php.ini
sed -i 's/;extension=zip.so/extension=zip.so/g' /etc/php/php.ini
# Changes needed after installation of php-intl and php-mcrypt
sed -i 's/;extension=bz2.so/extension=bz2.so/g' /etc/php/php.ini
sed -i 's/;extension=curl.so/extension=curl.so/g' /etc/php/php.ini
sed -i 's/;extension=intl.so/extension=intl.so/g' /etc/php/php.ini
sed -i 's/;extension=mcrypt.so/extension=mcrypt.so/g' /etc/php/php.ini

echo "PHP Configured"

# Configure PHP and DB
sed -i 's/;extension=pdo_sqlite.so/extension=pdo_sqlite.so/g' /etc/php/php.ini
sed -i 's/;extension=sqlite3.so/extension=sqlite3.so/g' /etc/php/php.ini
sed -i 's/;extension=pdo_pgsql.so/extension=pdo_pgsql.so/g' /etc/php/php.ini
sed -i 's/;extension=pgsql.so/extension=pgsql.so/g' /etc/php/php.ini

echo "SQLite and PosgreSQL extensions Configured"

# Enable APCu
APCU="extension=apcu.so \napc.ttl=7200 \napc.enable_cli=1"
sed -i 's,;extension=apcu.so,'"$APCU"',g' /etc/php/conf.d/apcu.ini

echo "APCu Enabled"

# Enable PHP opcache
sed -i 's/;zend_extension=opcache.so/zend_extension=opcache.so/g' /etc/php/php.ini
#sed -i 's/;opcache.enable=0/opcache.enable=1/g' /etc/php/php.ini
#sed -i 's/;opcache.enable_cli=0/opcache.enable_cli=1/g' /etc/php/php.ini

echo "OPCache enabled"

# Enable exif support
sed -i 's/;extension=exif.so/extension=exif.so/g' /etc/php/php.ini

echo "exif support enabled"

# Apache Configuration
cp /etc/webapps/owncloud/apache.example.conf /etc/httpd/conf/extra/owncloud.conf

# Append urandom
URANDOM_OLD="/srv/http/:/home/:/tmp/:/usr/share/pear/:/usr/share/webapps/"
URANDOM_NEW="${URANDOM_OLD}:/dev/urandom"
sed -i 's,'"$URANDOM_OLD"','"$URANDOM_NEW"',g' /etc/php/php.ini
URANDOM_OLD="/srv/http/:/home/:/tmp/:/usr/share/pear/:/usr/share/webapps/owncloud/:/etc/webapps/owncloud"
URANDOM_NEW="${URANDOM_OLD}:/dev/urandom"
sed -i 's,'"$URANDOM_OLD"','"$URANDOM_NEW"',g' /etc/httpd/conf/extra/owncloud.conf

echo "urandom enabled for PHP"

# Apache configuration
KEEPALIVE="KeepAlive On"
KEEPALIVE_TO="KeepAliveTimeout 100"
KEEPALIVE_REQS="MaxKeepAliveRequests 200"
LKP="HostnameLookups off"
PHP_MOD_LOAD="LoadModule php7_module modules/libphp7.so"
PHP_TYPE="AddType application/x-httpd-php .php"
PHP_MOD_INC="Include conf/extra/php7_module.conf"
OC_INC="Include conf/extra/owncloud.conf"
APACHE_OC="
$LKP
$KEEPALIVE
$KEEPALIVE_TO
$KEEPALIVE_REQS
$PHP_MOD_LOAD
$PHP_TYPE
$PHP_MOD_INC
$OC_INC"
# Delete if existing
sed -i 's,'"$LKP"',,g' /etc/httpd/conf/httpd.conf
sed -i 's,'"$KEEPALIVE"',,g' /etc/httpd/conf/httpd.conf
sed -i 's,'"$KEEPALIVE_TO"',,g' /etc/httpd/conf/httpd.conf
sed -i 's,'"$KEEPALIVE_REQS"',,g' /etc/httpd/conf/httpd.conf
sed -i 's,'"$PHP_MOD_LOAD"',,g' /etc/httpd/conf/httpd.conf
sed -i 's,'"$PHP_TYPE"',,g' /etc/httpd/conf/httpd.conf
sed -i 's,'"$PHP_MOD_INC"',,g' /etc/httpd/conf/httpd.conf
sed -i 's,'"$OC_INC"',,g' /etc/httpd/conf/httpd.conf
# Append at the end of the file
echo "$APACHE_OC" >> /etc/httpd/conf/httpd.conf
# Comment the LoadModule mpm_event_module modules/mod_mpm_event.so
sed -i 's,LoadModule mpm_event_module modules/mod_mpm_event.so,#LoadModule mpm_event_module modules/mod_mpm_event.so,g' /etc/httpd/conf/httpd.conf
# Uncomment the LoadModule mpm_prefork_module modules/mod_mpm_prefork.so
sed -i 's,#LoadModule mpm_prefork_module modules/mod_mpm_prefork.so,LoadModule mpm_prefork_module modules/mod_mpm_prefork.so,g' /etc/httpd/conf/httpd.conf

echo "Apache Configured"

# Generate SSL Key and Cert
openssl req \
	-new \
	-x509 \
	-nodes \
	-newkey rsa:4096 \
	-keyout /etc/httpd/conf/server.key \
	-out /etc/httpd/conf/server.crt \
	-subj "/C=US/ST=Temporary/L=Temporary/O=Temporary/CN=astonbitecode"

sed -i 's,#LoadModule ssl_module modules/mod_ssl.so,LoadModule ssl_module modules/mod_ssl.so,g' /etc/httpd/conf/httpd.conf
sed -i 's,#LoadModule socache_shmcb_module modules/mod_socache_shmcb.so,LoadModule socache_shmcb_module modules/mod_socache_shmcb.so,g' /etc/httpd/conf/httpd.conf
sed -i 's,#Include conf/extra/httpd-ssl.conf,Include conf/extra/httpd-ssl.conf,g' /etc/httpd/conf/httpd.conf

echo "Temporary SSL configured"

# Create Locale
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen

echo "Locale generated"

sh /tmp/perms.sh

echo "Permissions Set"

echo "Success"
