import express from 'express';
import { getDoctors, addDoctor } from '../controllers/doctorController.js';

const router = express.Router();

router.get('/doctors', getDoctors);
router.post('/doctors', addDoctor);

export default router;
