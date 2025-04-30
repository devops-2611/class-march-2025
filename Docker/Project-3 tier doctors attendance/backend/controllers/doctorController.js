import db from '../models/db.js';

// doctorController.js

// Export the functions
export const getDoctors = async (req, res) => {
    try {
      const [rows] = await db.query('SELECT * FROM doctors');
      res.json(rows);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  };
  
  export const addDoctor = async (req, res) => {
    const { name, attendance } = req.body;
    try {
      await db.query('INSERT INTO doctors (name, attendance) VALUES (?, ?)', [name, attendance]);
      res.status(201).json({ message: 'Doctor added successfully' });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  };
  