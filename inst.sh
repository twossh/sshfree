#!/bin/bash

function inst_base {
apt-get install apache2 -y > /dev/null 2>&1
apt-get install php libapache2-mod-php7.0 php7.0-mcrypt curl php-curl php7.0-mbstring -y > /dev/null 2>&1
systemctl restart apache2
apt-get install mariadb-server -y > /dev/null 2>&1
mysqladmin -u root password "$pwdroot"
mysql -u root -p"$pwdroot" -e "UPDATE mysql.user SET Password=PASSWORD('$pwdroot') WHERE User='root'"
mysql -u root -p"$pwdroot" -e "DELETE FROM mysql.user WHERE User=''"
mysql -u root -p"$pwdroot" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"
mysql -u root -p"$pwdroot" -e "FLUSH PRIVILEGES"
mysql -u root -p"$pwdroot" -e "CREATE USER 'sshfree'@'localhost';'"
mysql -u root -p"$pwdroot" -e "CREATE DATABASE sshfree;"
mysql -u root -p"$pwdroot" -e "GRANT ALL PRIVILEGES ON sshfree.* To 'sshfree'@'localhost' IDENTIFIED BY '$pwdroot';"
mysql -u root -p"$pwdroot" -e "FLUSH PRIVILEGES"
echo '[mysqld]
max_connections = 900' >> /etc/mysql/my.cnf
apt-get install php-mysql -y > /dev/null 2>&1
phpenmod mcrypt
systemctl restart apache2
ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin
apt-get install php-ssh2 -y > /dev/null 2>&1
php -m | grep ssh2 > /dev/null 2>&1
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
chmod +x /usr/local/bin/composer
cd /var/www/html
wget https://www.dropbox.com/s/w1vie4zjmb8y71g/site.zip > /dev/null 2>&1
apt-get install unzip > /dev/null 2>&1
unzip site.zip > /dev/null 2>&1
rm site.zip index.html > /dev/null 2>&1
composer install
composer require phpseclib/phpseclib:~2.0
systemctl restart mysql
}

function phpmadm {
cd /usr/share
wget https://files.phpmyadmin.net/phpMyAdmin/4.8.2/phpMyAdmin-4.8.2-all-languages.zip > /dev/null 2>&1
unzip phpMyAdmin-4.8.2-all-languages.zip > /dev/null 2>&1
mv phpMyAdmin-4.8.2-all-languages phpmyadmin
chmod -R 0755 phpmyadmin
ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin
service apache2 restart 
rm phpMyAdmin-4.8.2-all-languages.zip
cd /root
}

function pconf { 
sed "s/SENHA/$pwdroot/" /var/www/html/includes/config.php > /tmp/pass
mv /tmp/pass /var/www/html/includes/config.php

}
function inst_db { 
IP=$(wget -qO- ipv4.icanhazip.com)
curl $IP/create.php > /dev/null 2>&1
rm /var/www/html/create.php /var/www/html/sshfree.sql
}
 
echo "America/Sao_Paulo" > /etc/timezone
ln -fs /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime > /dev/null 2>&1
dpkg-reconfigure --frontend noninteractive tzdata > /dev/null 2>&1
clear
echo -e "\E[44;1;37m           PAINEL SSHFREE               \E[0m"
echo ""
read -p "Digite sua senha de root: " pwdroot
echo "root:$pwdroot" | chpasswd
echo "Prosseguindo..." 
echo "..."
echo "Isso vai levar alguns minutos... (3 a 10)."
sleep 2
inst_base
phpmadm
pconf
inst_db
clear
echo -e "\E[44;1;37m            PAINEL SSHFREE               \E[0m"
echo ""
echo -e "INSTALADO COM SUCESSO!"
echo ""
echo -e "Acesse o painel utilizando: \033[1;33mhttp://$IP/index.php\033[0m"
echo -e "Senha do Admin: \033[1;33madmin\033[0m"
echo ""
cat /dev/null > ~/.bash_history && history -c
rm inst.sh
