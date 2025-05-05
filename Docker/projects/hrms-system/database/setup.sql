CREATE DATABASE IF NOT EXISTS hrms_db;

CREATE USER 'hrms_user'@'%' IDENTIFIED BY 'securepassword123';
GRANT ALL PRIVILEGES ON hrms_db.* TO 'hrms_user'@'%';
FLUSH PRIVILEGES;