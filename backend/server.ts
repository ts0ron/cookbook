import express, { Request, Response, NextFunction } from 'express';

const app = express();
const PORT: number = parseInt(process.env.BACKEND_PORT || process.env.PORT || '8014', 10);

// Enable CORS for all routes
app.use((req: Request, res: Response, next: NextFunction) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');
  next();
});

// Hello World endpoint
app.get('/hello/world', (req: Request, res: Response) => {
  const name = req.query.name as string | undefined;
  
  if (name) {
    res.send(`Hello World ${name}`);
  } else {
    res.send('Hello World');
  }
});

// Health check endpoint
app.get('/health', (req: Request, res: Response) => {
  res.status(200).json({ status: 'success' });
});

// Start the server
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
  console.log(`Visit http://localhost:${PORT}/hello/world`);
  console.log(`Or with a name: http://localhost:${PORT}/hello/world?name=John`);
});

