import express, { Request, Response, NextFunction } from 'express';

const app = express();
const PORT: number = parseInt(process.env.PORT || '3000', 10);

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

// Start the server
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
  console.log(`Visit http://localhost:${PORT}/hello/world`);
  console.log(`Or with a name: http://localhost:${PORT}/hello/world?name=John`);
});

