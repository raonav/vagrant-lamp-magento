#!/bin/bash

apt-get update

# install needed software
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
apt-get install -y build-essential binutils-doc git apache2 php5 php5-curl php5-mcrypt mysql-server php5-mysql php5-xdebug

# configurations
cat << EOF > /etc/apache2/sites-available/magento.conf
<VirtualHost *:80>
    DocumentRoot /var/www/magento

    ErrorLog /var/log/apache2/error.log

    <Directory /var/www/magento/>
        Options Indexes FollowSymLinks MultiViews
        AllowOverride All
    </Directory>
</VirtualHost>
EOF
rm -rf /var/www/html
mkdir /var/www/magento
a2dissite 000-default.conf
a2ensite magento.conf
php5enmod mcrypt
a2enmod rewrite
service apache2 reload
service apache2 restart
locale-gen en_NZ.UTF-8

# download magento
cd /var/www/
wget -q http://www.magentocommerce.com/downloads/assets/1.9.0.1/magento-1.9.0.1.tar.gz | tar xz

