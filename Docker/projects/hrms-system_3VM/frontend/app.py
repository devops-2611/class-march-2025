from flask import Flask, render_template, request, redirect, url_for
import requests
from configparser import ConfigParser

app = Flask(__name__)

# Load configuration
config = ConfigParser()
config.read('config.ini')
BACKEND_URL = f"http://{config['network']['backend_ip']}:5000/api"

@app.route('/')
def index():
    try:
        print("Fetching employee data from backend...")
        response = requests.get(f"{BACKEND_URL}/employees")
        print(f"Backend response status: {response.status_code}")
        if response.status_code == 200:
            employees = response.json()
            print("First employee data:", employees[0] if employees else "No employees")
            # Ensure salary is numeric
            for emp in employees:
                emp['salary'] = float(emp['salary'])
            return render_template('employees.html', employees=employees)
        return render_template('employees.html', employees=[])
    except Exception as e:
        print("Error fetching employee data:", str(e))
        return str(e), 500

@app.route('/add', methods=['GET', 'POST'])
def add_employee():
    if request.method == 'POST':
        data = {
            'first_name': request.form['first_name'],
            'last_name': request.form['last_name'],
            'email': request.form['email'],
            'department': request.form['department'],
            'position': request.form['position'],
            'salary': float(request.form['salary']),
            'hire_date': request.form['hire_date']
        }
        response = requests.post(f"{BACKEND_URL}/employees", json=data)
        if response.status_code == 201:
            return redirect(url_for('index'))
        return render_template('add_employee.html', error="Failed to add employee")
    return render_template('add_employee.html')

@app.route('/edit/<int:employee_id>', methods=['GET', 'POST'])
def edit_employee(employee_id):
    if request.method == 'POST':
        data = {
            'first_name': request.form['first_name'],
            'last_name': request.form['last_name'],
            'email': request.form['email'],
            'department': request.form['department'],
            'position': request.form['position'],
            'salary': float(request.form['salary']),
            'hire_date': request.form['hire_date']
        }
        response = requests.put(f"{BACKEND_URL}/employees/{employee_id}", json=data)
        if response.status_code == 200:
            return redirect(url_for('index'))
        return render_template('edit_employee.html', error="Failed to update employee", employee=data)
    
    response = requests.get(f"{BACKEND_URL}/employees/{employee_id}")
    if response.status_code == 200:
        return render_template('edit_employee.html', employee=response.json())
    return redirect(url_for('index'))

@app.route('/delete/<int:employee_id>', methods=['POST'])
def delete_employee(employee_id):
    response = requests.delete(f"{BACKEND_URL}/employees/{employee_id}")
    return redirect(url_for('index'))

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)