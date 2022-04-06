#!/usr/bin/env bash

######################################################################
## LAMP
## RICARDO ARREDONDO RÍOS
######################################################################

echo -e "\n\n\n\n ======================="
echo -e " Actualizando el server."
echo -e "=========================\n\n\n\n"
sleep 5s
sudo apt-get -y update

echo -e "\n\n\n\n ========================"
echo -e " Instalando certificados."
echo -e "=========================\n\n\n\n"
sleep 5s

sudo apt-get -y install apt-transport-https lsb-release ca-certificates curl
sudo apt-get -y install software-properties-common dirmngr
sudo wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
sudo sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
sudo apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
sudo add-apt-repository 'deb [arch=amd64,arm64,ppc64el] http://nyc2.mirrors.digitalocean.com/mariadb/repo/10.5/debian buster main'

sleep 5s

echo -e "\n\n\n\n ============="
echo -e " Actualizando."
echo -e "==============\n\n\n\n"
sleep 5s
sudo apt-get -y update

echo -e "\n\n\n\n ============"
echo -e " Upgradeando."
echo -e "=============\n\n\n\n"
sleep 5s
sudo apt-get -y upgrade


echo -e "\n\n\n\n =================="
echo -e " Instalando Apache."
echo -e "===================\n\n\n\n"
sleep 5s
sudo apt-get -y install apache2
sudo systemctl enable apache2
sudo systemctl start apache2

echo -e "\n\n\n\n ====================================================="
echo -e " Instalando Mariadb y configurando root como password."
echo -e "=======================================================\n\n\n\n"
sleep 5s

#sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
#sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
sudo debconf-set-selections <<< 'mariadb-server-10.5 mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mariadb-server-10.5 mysql-server/root_password_again password root'
sudo apt-get -y install mariadb-server
sudo systemctl enable mariadb
sudo systemctl start mariadb


echo -e "\n\n\n\n ========================================================================"
echo -e " Actualizando configuración de mariadb para hacer accesible via via root."
echo -e "\ ESTO SOLO ES EN DESARROLLO!!!!!!!!!!!"
echo -e "=========================================================================\n\n\n\n"
sleep 5s

#Se permite la conexión a mariadb
#sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/mysql/mariadb.conf.d/mysqld.cnf
sudo sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf

ROOT_DB_PASSWORD="root"
#SQL="GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root' WITH GRANT OPTION; FLUSH PRIVILEGES;"
#sudo mysql -u root -p${ROOT_DB_PASSWORD} -e "${SQL}"
CREATE="CREATE USER 'vagrant'@'%' IDENTIFIED BY 'vagrant'; "
GRANT="GRANT ALL PRIVILEGES ON *.* TO 'vagrant'@'%' IDENTIFIED BY 'vagrant'; "
FLUSH="FLUSH PRIVILEGES;"
sudo mysql -u root -p${ROOT_DB_PASSWORD} -e "${CREATE}"
sudo mysql -u root -p${ROOT_DB_PASSWORD} -e "${GRANT}"
sudo mysql -u root -p${ROOT_DB_PASSWORD} -e "${FLUSH}"

## Modifica la zona horaria si es necesario
echo -e "\n\n\n\n ============================================="
echo -e " Cambiando Zona horaria a 'America/Mexico_City'. "
echo -e "================================================\n\n\n\n"
sleep 5s
#sudo sed -ri '/\[mysqld\]/ a\ default-time-zone = \x27America/Mexico_City\x27' /etc/mysql/mysql.conf.d/mysqld.cnf
mysql_tzinfo_to_sql /usr/share/zoneinfo
#sudo sed -ri '/\[mysqld\]/ a\ default-time-zone = \x27America/Mexico_City\x27' /etc/mysql/mariadb.conf.d/50-server.cnf

echo -e "\n\n\n\n ======================"
echo -e " Reiniciando servicios. "
echo -e "========================\n\n\n\n"
sleep 5s
sudo systemctl restart apache2
sudo systemctl restart mariadb


echo -e "\n\n\n\n ============================================"
echo -e "Configurar la zona horaria del server."
echo -e "============================================\n\n\n\n"
sleep 5s
sudo timedatectl set-timezone America/Mexico_City
# Instala ntp para mantener la zona horaria sincronizada
sudo apt-get install -y ntp

echo -e "\n\n\n\n ==============="
echo -e " Instalando Php."
echo -e "================\n\n\n\n"
sleep 5s
sudo apt-get -y install php8.0
sudo apt-get install -y php-pear
sudo apt-get install -y php8.0-curl
sudo apt-get install -y php8.0-dev
sudo apt-get install -y php8.0-gd
sudo apt-get install -y php8.0-mbstring
sudo apt-get install -y php8.0-zip
sudo apt-get install -y php8.0-mysql
sudo apt-get install -y php8.0-xml
sudo apt-get install -y php8.0-cli
sudo apt-get install -y php8.0-imagick
sudo apt-get install -y php8.0-gmp
sudo apt-get install -y php8.0-mcrypt
sudo apt-get install -y php8.0-odbc
sudo apt-get install -y php8.0-pgsql
sudo apt-get install -y php8.0-xsl
sudo apt-get install -y php8.0-bcmath
sudo apt-get install -y php-zip
sudo apt-get install unzip
sudo apt-get install -y openssl

sudo apt-get -y install libapache2-mod-php8.0
sudo a2enmod php8.0
sudo a2enmod rewrite
sudo systemctl restart apache2

echo -e "\n\n\n\n ======================"
echo -e " Instalando Git."
echo -e "========================\n\n\n\n"
sleep 5s
sudo apt-get -y install git


echo -e "\n\n\n\n ======================"
echo -e " Instalando Composer."
echo -e "========================\n\n\n\n"
sleep 5s

cd /tmp
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === '756890a4488ce9024fc62c56153228907f1545c228516cbf63f885e036d37e9a59d27d63f46af1d4d07ee0f76181c7d3') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"
sudo mkdir -p /usr/local/bin
sudo mv composer.phar /usr/local/bin/composer

sudo curl -fsSL https://deb.nodesource.com/setup_14.x | bash -
sudo apt-get install -y nodejs

echo -e "============================================ \n"
echo -e "Terminando el aprovisionamiento de vagrant.\n"
echo -e "============================================\n\n"
echo -e "\n\n"

