import React, { useEffect, useState } from 'react';
import axios from 'axios';

const DoctorTable = () => {
  const [doctors, setDoctors] = useState([]);

  useEffect(() => {
    axios.get('http://172.166.252.231:5000/api/doctors')
      .then(response => setDoctors(response.data))
      .catch(error => console.error(error));
  }, []);

  return (
    <table>
      <thead>
        <tr>
          <th>Name</th>
          <th>Attendance</th>
        </tr>
      </thead>
      <tbody>
        {doctors.map(doctor => (
          <tr key={doctor.id}>
            <td>{doctor.name}</td>
            <td>{doctor.attendance}</td>
          </tr>
        ))}
      </tbody>
    </table>
  );
};

export default DoctorTable;
