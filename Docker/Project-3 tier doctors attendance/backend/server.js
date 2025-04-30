import express from 'express';
import cors from 'cors';
import doctorRoutes from './routes/doctorRoutes.js';

const app = express();
const PORT = process.env.PORT || 5000;

// CORS setup for allowing requests from frontend
app.use(cors({
  origin: 'http://13.71.111.50:3000', // Frontend VM IP
  methods: ['GET', 'POST'],
  allowedHeaders: ['Content-Type'],
}));

// Middleware for parsing JSON data
app.use(express.json());

// Use doctor routes
app.use('/api', doctorRoutes);

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server is running on http://0.0.0.0:${PORT}`);
});
