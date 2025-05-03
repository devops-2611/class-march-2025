const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

// Database connection configuration
const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'store_user',
  password: process.env.DB_PASSWORD || 'store_password',
  database: process.env.DB_NAME || 'store_db',
  port: process.env.DB_PORT || 3306
};

// Create a connection pool
let pool;
async function initDb() {
  pool = mysql.createPool(dbConfig);
  try {
    const conn = await pool.getConnection();
    console.log('Connected to MySQL database');
    conn.release();
  } catch (err) {
    console.error('Database connection failed:', err);
    process.exit(1);
  }
}

// API Routes

// Get all items
app.get('/api/items', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM items');
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch items' });
  }
});

// Get single item
app.get('/api/items/:id', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM items WHERE id = ?', [req.params.id]);
    if (rows.length === 0) {
      return res.status(404).json({ error: 'Item not found' });
    }
    res.json(rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch item' });
  }
});

// Create new item
app.post('/api/items', async (req, res) => {
  const { name, description, price, quantity } = req.body;
  if (!name || !price || !quantity) {
    return res.status(400).json({ error: 'Name, price and quantity are required' });
  }

  try {
    const [result] = await pool.query(
      'INSERT INTO items (name, description, price, quantity) VALUES (?, ?, ?, ?)',
      [name, description, price, quantity]
    );
    const [newItem] = await pool.query('SELECT * FROM items WHERE id = ?', [result.insertId]);
    res.status(201).json(newItem[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to create item' });
  }
});

// Update item
app.put('/api/items/:id', async (req, res) => {
  const { name, description, price, quantity } = req.body;
  if (!name || !price || !quantity) {
    return res.status(400).json({ error: 'Name, price and quantity are required' });
  }

  try {
    await pool.query(
      'UPDATE items SET name = ?, description = ?, price = ?, quantity = ? WHERE id = ?',
      [name, description, price, quantity, req.params.id]
    );
    const [updatedItem] = await pool.query('SELECT * FROM items WHERE id = ?', [req.params.id]);
    if (updatedItem.length === 0) {
      return res.status(404).json({ error: 'Item not found' });
    }
    res.json(updatedItem[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to update item' });
  }
});

// Delete item
app.delete('/api/items/:id', async (req, res) => {
  try {
    const [result] = await pool.query('DELETE FROM items WHERE id = ?', [req.params.id]);
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Item not found' });
    }
    res.status(204).end();
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to delete item' });
  }
});

// Start server
const PORT = process.env.PORT || 5000;
initDb().then(() => {
  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });
});