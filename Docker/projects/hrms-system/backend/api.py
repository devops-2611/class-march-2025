from flask import Flask, jsonify, request
from flask_cors import CORS
import mysql.connector
from configparser import ConfigParser
import os

app = Flask(__name__)
CORS(app)

# Load configuration
config = ConfigParser()
config.read('config.ini')

# Database configuration
db_config = {
    'host': config['database']['db_host'],
    'user': config['database']['db_user'],
    'password': config['database']['db_password'],
    'database': config['database']['db_name']
}

def get_db_connection():
    return mysql.connector.connect(**db_config)

@app.route('/api/employees', methods=['GET'])
def get_employees():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("""
        SELECT id, first_name, last_name, email, department, position, 
               CAST(salary AS DECIMAL(10,2)) as salary, hire_date 
        FROM employees
    """)
    employees = cursor.fetchall()
    cursor.close()
    conn.close()
    return jsonify(employees)

@app.route('/api/employees/<int:employee_id>', methods=['GET'])
def get_employee(employee_id):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM employees WHERE id = %s", (employee_id,))
    employee = cursor.fetchone()
    cursor.close()
    conn.close()
    if employee:
        return jsonify(employee)
    return jsonify({"error": "Employee not found"}), 404

@app.route('/api/employees', methods=['POST'])
def add_employee():
    data = request.get_json()
    required_fields = ['first_name', 'last_name', 'email', 'department', 'position', 'salary', 'hire_date']
    if not all(field in data for field in required_fields):
        return jsonify({"error": "Missing required fields"}), 400
    
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("""
            INSERT INTO employees (first_name, last_name, email, department, position, salary, hire_date)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """, (data['first_name'], data['last_name'], data['email'], data['department'], 
              data['position'], data['salary'], data['hire_date']))
        conn.commit()
        employee_id = cursor.lastrowid
        cursor.close()
        conn.close()
        return jsonify({"id": employee_id, "message": "Employee added successfully"}), 201
    except mysql.connector.Error as err:
        conn.rollback()
        cursor.close()
        conn.close()
        return jsonify({"error": str(err)}), 400

@app.route('/api/employees/<int:employee_id>', methods=['PUT'])
def update_employee(employee_id):
    data = request.get_json()
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("""
            UPDATE employees 
            SET first_name=%s, last_name=%s, email=%s, department=%s, position=%s, salary=%s, hire_date=%s
            WHERE id=%s
        """, (data['first_name'], data['last_name'], data['email'], data['department'], 
              data['position'], data['salary'], data['hire_date'], employee_id))
        conn.commit()
        affected_rows = cursor.rowcount
        cursor.close()
        conn.close()
        if affected_rows == 0:
            return jsonify({"error": "Employee not found"}), 404
        return jsonify({"message": "Employee updated successfully"})
    except mysql.connector.Error as err:
        conn.rollback()
        cursor.close()
        conn.close()
        return jsonify({"error": str(err)}), 400

@app.route('/api/employees/<int:employee_id>', methods=['DELETE'])
def delete_employee(employee_id):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM employees WHERE id = %s", (employee_id,))
    conn.commit()
    affected_rows = cursor.rowcount
    cursor.close()
    conn.close()
    if affected_rows == 0:
        return jsonify({"error": "Employee not found"}), 404
    return jsonify({"message": "Employee deleted successfully"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)