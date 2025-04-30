import React from 'react';
import DoctorTable from './components/DoctorTable';
import AttendanceForm from './components/AttendanceForm';

const App = () => {
  return (
    <div>
      <h1>Doctor Attendance System</h1>
      <AttendanceForm />
      <DoctorTable />
    </div>
  );
};

export default App;
