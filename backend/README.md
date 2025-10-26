# Hello World Express Server

A simple Express server that returns "Hello World" with optional name parameter.

## Setup

Install dependencies:
```bash
npm install
```

## Running the Server

Start the server:
```bash
npm start
```

For development with auto-reload:
```bash
npm run dev
```

The server will run on http://localhost:3000 by default.

## Endpoints

### GET /hello/world

Returns "Hello World" greeting.

**Without parameter:**
```bash
curl http://localhost:3000/hello/world
# Response: Hello World
```

**With name parameter:**
```bash
curl http://localhost:3000/hello/world?name=John
# Response: Hello World John
```

