#!/bin/bash

MACHINE_NAME=$1

apt-get update

apt-get upgrade -y

# install needed software
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
apt-get install -y build-essential binutils-doc git apache2 php5 php5-curl php5-mcrypt mysql-server php5-mysql php5-xdebug php5-gd

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

# TODO: xdebug configuration
function phpconfiguration {
  # increase memory limit for php apache
  sed -i '/memory_limit = 128M/c memory_limit = 1024M' /etc/php5/apache2/php.ini
}

# installing additional tools
function installadditionaltools {
  cd /vagrant
  if [ ! -d /vagrant/downloads ]; then
      mkdir downloads
  fi
  cd downloads
  ## installing composer
  curl -sS https://getcomposer.org/installer | php
  mv composer.phar /usr/local/bin/composer
  ## installing n98-magerun
  wget http://files.magerun.net/n98-magerun-latest.phar
  chmod +x ./n98-magerun-latest.phar
  mv ./n98-magerun-latest.phar /usr/local/bin/n98-magerun
  cd /vagrant/
  if [ -d /vagrant/downloads ]; then
      rm -r /vagrant/downloads
  fi
}

# pretty self explanatory
function installmagento {
  # create a new database --user=magento --password=magento --dbname=magento
  mysql -u root -proot -e "CREATE DATABASE IF NOT EXISTS $1;"
  mysql -u root -proot -e "CREATE USER $1@localhost IDENTIFIED BY '$1';"
  mysql -u root -proot -e "GRANT ALL PRIVILEGES ON $1.* TO $1@localhost;"
  mysql -u root -proot -e "FLUSH PRIVILEGES;"

  cd /var/www

  # install magento with magerun
  # TODO: magerun yaml configuration
  sudo -u vagrant n98-magerun install --dbHost="localhost" --dbUser="$1" --dbPass="$1" --dbName="$1" --installSampleData=yes --useDefaultConfigParams=yes --magentoVersionByName="magento-mirror-1.9.2.1" --installationFolder="$1" --baseUrl="http://${MACHINE_NAME}/"
}

installadditionaltools

installmagento magento
