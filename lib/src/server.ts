import express, { Application, Request, Response } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import dotenv from 'dotenv';
import { connectDB } from './config/db';
import routes from './routes';

// Load environment variables
dotenv.config();

const app: Application = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(helmet()); // Security headers
app.use(cors()); // Enable CORS for Flutter frontend
app.use(express.json({ limit: '10mb' })); // Parse JSON bodies (for images/orders)
app.use(express.urlencoded({ extended: true }));

// Basic health check route
app.get('/api/health', (req: Request, res: Response) => {
  res.status(200).json({ message: 'Backend is running!' });
});

// API routes (we'll add more later)
app.use('/api', routes);

// Global error handler (basic)
app.use((err: Error, req: Request, res: Response, next: Function) => {
  console.error(err.stack);
  res.status(500).json({ message: 'Something went wrong!' });
});

// Start server function
const startServer = async (): Promise<void> => {
  try {
    await connectDB();
    app.listen(PORT, () => {
      console.log(`Server running on port ${PORT}`);
    });
  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
};

// Start the server
startServer();