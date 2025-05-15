USE hrms_db;

CREATE TABLE employees (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    department VARCHAR(50),
    position VARCHAR(50),
    salary DECIMAL(10, 2),
    hire_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

INSERT INTO employees (first_name, last_name, email, department, position, salary, hire_date)
VALUES 
    ('John', 'Doe', 'john.doe@example.com', 'IT', 'Software Engineer', 75000.00, '2020-01-15'),
    ('Jane', 'Smith', 'jane.smith@example.com', 'HR', 'HR Manager', 85000.00, '2019-05-20'),
    ('Robert', 'Johnson', 'robert.johnson@example.com', 'Finance', 'Accountant', 65000.00, '2021-03-10');