# Dockerfile for MySQL
FROM mysql:8.0

# Set root password
ENV MYSQL_ROOT_PASSWORD=rootpassword

# Create database and user
ENV MYSQL_DATABASE=store_db
ENV MYSQL_USER=store_user
ENV MYSQL_PASSWORD=store_password

# Copy initialization script
COPY init.sql /docker-entrypoint-initdb.d/

EXPOSE 3306