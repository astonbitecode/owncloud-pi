#!/bin/bash

# Init
cp /etc/webapps/owncloud/apache.example.conf /etc/httpd/conf/extra/owncloud.conf

# Main changes
sed -i 's/;extension=gd.so/extension=gd.so/g' /etc/php/php.ini
sed -i 's/;extension=iconv.so/extension=iconv.so/g' /etc/php/php.ini
sed -i 's/;extension=posix.so/extension=posix.so/g' /etc/php/php.ini
sed -i 's/;extension=xmlrpc.so/extension=xmlrpc.so/g' /etc/php/php.ini
sed -i 's/;extension=zip.so/extension=zip.so/g' /etc/php/php.ini
# Changes needed after installation of php-intl and php-mcrypt
sed -i 's/;extension=bz2.so/extension=bz2.so/g' /etc/php/php.ini
sed -i 's/;extension=curl.so/extension=curl.so/g' /etc/php/php.ini
sed -i 's/;extension=intl.so/extension=intl.so/g' /etc/php/php.ini
sed -i 's/;extension=mcrypt.so/extension=mcrypt.so/g' /etc/php/php.ini
sed -i 's/;extension=openssl.so/extension=openssl.so/g' /etc/php/php.ini

echo "PHP Configured"

# Enable PHP opcache
sed -i 's/;zend_extension=opcache.so/zend_extension=opcache.so/g' /etc/php/php.ini
sed -i 's/;opcache.enable=0/opcache.enable=1/g' /etc/php/php.ini
sed -i 's/;opcache.enable_cli=0/opcache.enable_cli=1/g' /etc/php/php.ini

# Enable apcu
APCU="extension=apcu.so \napc.enabled=1 \napc.shm_size=32M \napc.ttl=7200 \napc.enable_cli=1"
sed -i 's,;extension=apcu.so,'"$APCU"',g' /etc/php/conf.d/apcu.ini

echo "Cache enabled"

# Append urandom
URANDOM_OLD="/srv/http/:/home/:/tmp/:/usr/share/pear/:/usr/share/webapps/"
URANDOM_NEW="${URANDOM_OLD}:/dev/urandom"
sed -i 's,'"$URANDOM_OLD"','"$URANDOM_NEW"',g' /etc/php/php.ini
URANDOM_OLD="/srv/http/:/home/:/tmp/:/usr/share/pear/:/usr/share/webapps/owncloud/:/etc/webapps/owncloud"
URANDOM_NEW="${URANDOM_OLD}:/dev/urandom"
sed -i 's,'"$URANDOM_OLD"','"$URANDOM_NEW"',g' /etc/httpd/conf/extra/owncloud.conf

echo "urandom enabled for PHP"

# Enable exif support
sed -i 's/;extension=exif.so/extension=exif.so/g' /etc/php/php.ini

echo "exif support enabled"

# Apache configuration
PHP_MOD_LOAD="LoadModule php5_module modules/libphp5.so"
PHP_TYPE="AddType application/x-httpd-php .php"
PHP_MOD_INC="Include conf/extra/php5_module.conf"
OC_INC="Include conf/extra/owncloud.conf"
APACHE_OC="
$PHP_MOD_LOAD
$PHP_TYPE
$PHP_MOD_INC
$OC_INC"
# Delete if existing
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

# Configure DB
sed -i 's/;extension=pdo_sqlite.so/extension=pdo_sqlite.so/g' /etc/php/php.ini
sed -i 's/;extension=sqlite3.so/extension=sqlite3.so/g' /etc/php/php.ini
sed -i 's/;extension=pdo_pgsql.so/extension=pdo_pgsql.so/g' /etc/php/php.ini
sed -i 's/;extension=pgsql.so/extension=pgsql.so/g' /etc/php/php.ini

echo "SQLite and PosgreSQL extensions Configured"

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

# Change permissions where needed
ocpath='/usr/share/webapps/owncloud'
htuser='http'
htgroup='http'

#Create Needed Folders
mkdir --parents ${ocpath}
mkdir ${ocpath}/apps
mkdir ${ocpath}/config
mkdir ${ocpath}/data
mkdir ${ocpath}/themes

# Change the permissions
find ${ocpath}/ -type f -print0 | xargs -0 chmod 0640
find ${ocpath}/ -type d -print0 | xargs -0 chmod 0750
chown -R root:${htuser} ${ocpath}/
chown -R ${htuser}:${htgroup} ${ocpath}/apps/
chown -R ${htuser}:${htgroup} ${ocpath}/config/
chown -R ${htuser}:${htgroup} ${ocpath}/data/
chown -R ${htuser}:${htgroup} ${ocpath}/themes/
chown root:${htuser} ${ocpath}/.htaccess
chown root:${htuser} ${ocpath}/data/.htaccess
chmod 0644 ${ocpath}/.htaccess
chmod 0644 ${ocpath}/data/.htaccess

echo "Permissions Set"

# Create Locale
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen

echo "Locale generated"

echo "Success"
