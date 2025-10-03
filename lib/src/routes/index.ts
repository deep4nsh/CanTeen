import { Router } from 'express';
import authRoutes from './auth'; // Placeholder; create later
import orderRoutes from './orders'; // Placeholder; create later

const router = Router();

// Basic routes (add more as we build features)
router.get('/health', (req, res) => {
  res.json({ status: 'API routes active' });
});

// Uncomment and import when ready
// router.use('/auth', authRoutes);
// router.use('/orders', orderRoutes);

export default router;