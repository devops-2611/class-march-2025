CREATE USER IF NOT EXISTS 'hrms_user'@'%' IDENTIFIED BY 'hrms_password';
GRANT ALL PRIVILEGES ON hrms_db.* TO 'hrms_user'@'%';
FLUSH PRIVILEGES;