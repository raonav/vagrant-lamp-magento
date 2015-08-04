#!/bin/bash

apt-get update

# install needed software
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
apt-get install -y apache2 php5 php5-curl php5-mcrypt mysql-server php5-xdebug

# configurations
php5enmod mcrypt
a2enmod rewrite
service apache2 reload
service apache2 restart

# download magento
wget http://www.magentocommerce.com/downloads/assets/1.9.0.1/magento-1.9.0.1.tar.gz
