import React, { useState } from 'react';
import axios from 'axios';

const AttendanceForm = () => {
  const [name, setName] = useState('');
  const [attendance, setAttendance] = useState('');

  const handleSubmit = (e) => {
    e.preventDefault();
    axios.post('http://172.166.252.231:5000/api/doctors', { name, attendance })
      .then(() => {
        alert('Attendance submitted');
        setName('');
        setAttendance('');
      })
      .catch(error => console.error(error));
  };

  return (
    <form onSubmit={handleSubmit}>
      <input
        type="text"
        placeholder="Doctor Name"
        value={name}
        onChange={(e) => setName(e.target.value)}
        required
      />
      <select value={attendance} onChange={(e) => setAttendance(e.target.value)} required>
        <option value="">Select Attendance</option>
        <option value="Present">Present</option>
        <option value="Absent">Absent</option>
      </select>
      <button type="submit">Submit</button>
    </form>
  );
};

export default AttendanceForm;
