#!/bin/bash

# Обновляем пакеты и устанавливаем необходимые зависимости
sudo apt-get update
sudo apt-get install -y apache2 mariadb-server wget unzip software-properties-common

# Добавляем репозиторий для PHP 8.1
sudo add-apt-repository ppa:ondrej/php -y
sudo apt-get update
sudo apt-get install -y php8.1 php8.1-mysql

# Запуск и настройка MariaDB
sudo systemctl start mariadb
sudo mysql -e "CREATE DATABASE wordpress;"
sudo mysql -e "CREATE USER 'wpuser'@'localhost' IDENTIFIED BY 'wppassword';"
sudo mysql -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Настройка MariaDB для удаленного доступа
sudo tee -a /etc/mysql/mariadb.conf.d/50-server.cnf > /dev/null <<EOT
[mysqld]
bind-address = 0.0.0.0
EOT
sudo systemctl restart mariadb

# Установка WordPress
wget https://wordpress.org/latest.zip
unzip latest.zip
sudo mv wordpress/* /var/www/html

# Удаление страницы по умолчанию Apache
sudo rm /var/www/html/index.html

# Настройка прав доступа
sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 755 /var/www/html

# Создание wp-config.php
sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
sudo sed -i "s/database_name_here/wordpress/" /var/www/html/wp-config.php
sudo sed -i "s/username_here/wpuser/" /var/www/html/wp-config.php
sudo sed -i "s/password_here/wppassword/" /var/www/html/wp-config.php
sudo sed -i "s/localhost/127.0.0.1/" /var/www/html/wp-config.php

# Кастомный php.ini для PHP 8.1
sudo tee /etc/php/8.1/apache2/conf.d/custom.ini > /dev/null <<EOT
upload_max_filesize = 64M
post_max_size = 64M
memory_limit = 256M
max_execution_time = 300
EOT

# Перезапуск Apache
sudo systemctl restart apache2

# Получение IP-адреса сервера
IP=$(hostname -I | awk '{print $1}')

echo "Установка завершена! Откройте в браузере http://$IP, чтобы продолжить настройку WordPress."
