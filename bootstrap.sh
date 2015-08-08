#!/bin/bash

MACHINE_NAME=$1

apt-get update

# install needed software
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
apt-get install -y build-essential binutils-doc git apache2 php5 php5-curl php5-mcrypt mysql-server php5-mysql php5-xdebug

# configurations
cat << EOF > /etc/apache2/sites-available/magento.conf
<VirtualHost *:80>
    DocumentRoot /var/www/magento
    ServerName ${MACHINE_NAME} 
    ErrorLog /var/log/apache2/error.log

    <Directory /var/www/magento/>
        Options Indexes FollowSymLinks MultiViews
        AllowOverride All
    </Directory>
</VirtualHost>
EOF
rm -rf /var/www/html

if [ ! -d /var/www/magento ]; then
    mkdir /var/www/magento
fi

a2dissite 000-default.conf
a2ensite magento.conf
php5enmod mcrypt
a2enmod rewrite
service apache2 reload
service apache2 restart
locale-gen en_NZ.UTF-8

# installing additional tools
cd /vagrant
mkdir downloads
cd downloads
## installing composer
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
## installing n98-magerun
wget http://files.magerun.net/n98-magerun-latest.phar
chmod +x ./n98-magerun-latest.phar
cp ./n98-magerun-latest.phar /usr/local/bin/n98-magerun

# installing magento
mysql -u root -proot -e "CREATE TABLE IF NOT EXISTS magento;" 
mysql -u root -proot -e "CREATE USER magento@localhost IDENTIFIED BY 'magento';"
mysql -u root -proot -e "GRANT ALL PRIVILEGES ON magento.* TO magento@localhost;"
mysql -u root -proot -e "FLUSH PRIVILEGES;"


