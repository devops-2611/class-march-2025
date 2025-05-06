CREATE DATABASE IF NOT EXISTS store_db;
USE store_db;

CREATE TABLE IF NOT EXISTS items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    quantity INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Sample initial data
INSERT INTO items (name, description, price, quantity) VALUES
('Laptop', 'High performance laptop with 16GB RAM', 999.99, 10),
('Smartphone', 'Latest smartphone with 5G', 699.99, 25),
('Headphones', 'Noise cancelling wireless headphones', 199.99, 30);