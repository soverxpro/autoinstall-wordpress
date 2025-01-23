### Описание проекта Auto Install WordPress + LAMP

Этот проект содержит набор скриптов и конфигурационных файлов для автоматической установки WordPress на сервере с установленным LAMP (Linux, Apache, MySQL, PHP). Ниже приведены описания каждого файла, их роли и инструкции по использованию.

#### 1. `.env`
**Роль:** Файл окружения для хранения конфиденциальных данных.
**Функция:** Содержит параметры базы данных, такие как имя базы данных, пользователь, пароль, а также пароль root для MySQL.
**Инструкция:**
   - Заполните значения переменных в этом файле перед запуском установки.

Пример содержимого:
```dotenv
WORDPRESS_DB_NAME=wordpress
WORDPRESS_DB_USER=wpuser
WORDPRESS_DB_PASSWORD=wppassword
MYSQL_ROOT_PASSWORD=rootpassword
```

#### 2. `README.md`
**Роль:** Документация проекта.
**Функция:** Предоставляет общее описание проекта и его цели.
**Инструкция:**
   - Откройте этот файл для получения общей информации о проекте.

Пример содержимого:
```markdown
# autoinstall-wordpress
Auto Install WordPress + LAMP
```

#### 3. `docker-compose.yml`
**Роль:** Конфигурационный файл для Docker Compose.
**Функция:** Определяет сервисы для Docker, включая WordPress и MariaDB, а также их настройки и связи.
**Инструкция:**
   - Запустите команду `docker-compose up -d`, чтобы развернуть контейнеры для WordPress и MariaDB.

Пример содержимого:
```yaml
services:
  wordpress:
    image: wordpress:latest
    restart: always
    ports:
      - "8080:80"
    environment:
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_USER: ${WORDPRESS_DB_USER}
      WORDPRESS_DB_PASSWORD: ${WORDPRESS_DB_PASSWORD}
      WORDPRESS_DB_NAME: ${WORDPRESS_DB_NAME}
    volumes:
      - ./wordpress_data:/var/www/html
      - ./php.ini:/usr/local/etc/php/php.ini

  db:
    image: mariadb:latest
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: ${WORDPRESS_DB_NAME}
      MYSQL_USER: ${WORDPRESS_DB_USER}
      MYSQL_PASSWORD: ${WORDPRESS_DB_PASSWORD}
    volumes:
      - ./db_data:/var/lib/mysql
      - ./my.cnf:/etc/mysql/my.cnf
    ports:
      - "3306:3306"
```

#### 4. `install.sh`
**Роль:** Скрипт установки.
**Функция:** Автоматизирует процесс установки и настройки LAMP и WordPress на сервере.
**Инструкция:**
   - Запустите этот скрипт с правами суперпользователя: `sudo ./install.sh`.

Пример содержимого:
```shell
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
```

#### 5. `my.cnf`
**Роль:** Конфигурационный файл для MariaDB.
**Функция:** Настраивает MariaDB для удаленного доступа.
**Инструкция:**
   - Этот файл используется в `docker-compose.yml` и `install.sh` для настройки MariaDB.

Пример содержимого:
```ini
[mysqld]
bind-address = 0.0.0.0
```

#### 6. `php.ini`
**Роль:** Конфигурационный файл для PHP.
**Функция:** Настраивает параметры PHP для оптимальной работы WordPress.
**Инструкция:**
   - Этот файл используется в `docker-compose.yml` для настройки PHP контейнера.

Пример содержимого:
```ini
upload_max_filesize = 64M
post_max_size = 64M
memory_limit = 256M
max_execution_time = 300
```

Эти файлы вместе обеспечивают полную автоматизацию процесса установки и настройки WordPress на сервере с LAMP.
