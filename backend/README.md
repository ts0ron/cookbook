# Cookbook Backend

Backend service for the Cookbook application - a simple Express.js server with TypeScript.

## Setup

### Install Dependencies

```bash
npm install
```

### Build

Compile TypeScript to JavaScript:
```bash
npm run build
```

## Running the Server

### Development Mode (with auto-reload)

Start the development server:
```bash
npm run dev
```

This uses `ts-node-dev` for hot-reload on code changes.

### Production Mode

```bash
npm start
```

This runs the compiled JavaScript from the `dist` directory.

The server will run on `http://localhost:8014` by default (or the port specified in the `PORT` environment variable).

## Environment Variables

- `PORT` - Server port (default: 8014)

```bash
PORT=8014 npm run dev
```

## Endpoints

### GET /hello/world

Returns "Hello World" greeting.

**Without parameter:**
```bash
curl http://localhost:8014/hello/world
# Response: Hello World
```

**With name parameter:**
```bash
curl http://localhost:8014/hello/world?name=John
# Response: Hello World John
```

### GET /health

Health check endpoint for monitoring and load balancers.

```bash
curl http://localhost:8014/health
# Response: {"status":"success"}
```

## Docker

### Build Image

```bash
docker build -t cookbook-backend .
```

### Run Container

```bash
docker run -p 8014:8014 cookbook-backend
```

## Technology Stack

- **Runtime**: Node.js
- **Framework**: Express.js
- **Language**: TypeScript
- **Development**: ts-node-dev for hot-reload

