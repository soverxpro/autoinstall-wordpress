### Описание проекта Auto Install WordPress + LAMP

Этот проект предоставляет инструменты для автоматической установки и настройки WordPress на сервере с использованием LAMP-стека (Linux, Apache, MySQL, PHP). Все необходимые файлы и скрипты собраны для упрощения развёртывания и сокращения времени на настройку.

---

### Состав проекта и инструкция

#### 1. `.env`
**Назначение:**  
Файл окружения для хранения конфиденциальных данных, таких как параметры базы данных.  

**Использование:**  
Перед запуском установки заполните переменные в этом файле.  

Пример содержимого:
```dotenv
WORDPRESS_DB_NAME=wordpress
WORDPRESS_DB_USER=wpuser
WORDPRESS_DB_PASSWORD=wppassword
MYSQL_ROOT_PASSWORD=rootpassword
```

---

#### 2. `docker-compose.yml`
**Назначение:**  
Конфигурация Docker Compose для автоматического развертывания сервисов (WordPress и MariaDB).  

**Использование:**  
1. Запустите команду:
   ```bash
   docker-compose up -d
   ```
2. После выполнения контейнеры будут работать в фоновом режиме.  

Пример содержимого:
```yaml
services:
  wordpress:
    image: wordpress:latest
    ports:
      - "8080:80"
    environment:
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_USER: ${WORDPRESS_DB_USER}
      WORDPRESS_DB_PASSWORD: ${WORDPRESS_DB_PASSWORD}
      WORDPRESS_DB_NAME: ${WORDPRESS_DB_NAME}
    volumes:
      - ./wordpress_data:/var/www/html

  db:
    image: mariadb:latest
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: ${WORDPRESS_DB_NAME}
      MYSQL_USER: ${WORDPRESS_DB_USER}
      MYSQL_PASSWORD: ${WORDPRESS_DB_PASSWORD}
    volumes:
      - ./db_data:/var/lib/mysql
```

---

#### 3. `install.sh`
**Назначение:**  
Скрипт для автоматической установки LAMP-стека и WordPress.  

**Использование:**  
1. Сделайте скрипт исполняемым:
   ```bash
   chmod +x install.sh
   ```
2. Запустите скрипт с правами администратора:
   ```bash
   sudo ./install.sh
   ```

Пример ключевых этапов скрипта:
- Установка LAMP-стека.
- Настройка базы данных и пользователя.
- Скачивание и настройка WordPress.
- Настройка прав доступа и PHP.

После завершения вы получите IP-адрес сервера, на котором WordPress доступен.

---

#### 4. `my.cnf`
**Назначение:**  
Конфигурация для MariaDB, позволяющая настроить удалённый доступ к базе данных.  

**Использование:**  
Файл автоматически применяется скриптом `install.sh` или через Docker.  

Пример содержимого:
```ini
[mysqld]
bind-address = 0.0.0.0
```

---

#### 5. `php.ini`
**Назначение:**  
Файл конфигурации PHP для оптимальной работы WordPress.  

**Использование:**  
Используется для настройки PHP через Docker или при ручной установке.  

Пример содержимого:
```ini
upload_max_filesize = 64M
post_max_size = 64M
memory_limit = 256M
max_execution_time = 300
```

---

### Как использовать проект?
1. Склонируйте репозиторий:
   ```bash
   git clone <URL>
   cd <папка_проекта>
   ```
2. Настройте файл `.env`, указав параметры базы данных.  
3. Если вы используете Docker, запустите:
   ```bash
   docker-compose up -d
   ```
4. Если вы хотите установить LAMP вручную, выполните скрипт:
   ```bash
   sudo ./install.sh
   ```
5. После завершения настройки откройте браузер и перейдите по адресу:
   ```
   http://<IP-адрес_сервера>
   ```
   для завершения установки WordPress через веб-интерфейс.

---

### Преимущества проекта
- **Простота использования:** Систематизированный процесс установки.
- **Гибкость:** Возможность использовать Docker или ручную установку.
- **Автоматизация:** Скрипт минимизирует необходимость ручной настройки.

