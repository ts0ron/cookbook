# Cookbook Frontend

Frontend application for the Cookbook project - a React application that connects to the backend API.

## Setup

### Install Dependencies

```bash
npm install
```

## Development

Start the development server:
```bash
npm run dev
```

The frontend will be available at `http://localhost:3000`.

**Important**: Make sure the backend server is running on port 8014 before using the app.

The development server uses Vite with hot module replacement for instant updates.

## Build

Build for production:
```bash
npm run build
```

The build output will be in the `dist` directory.

### Preview Production Build

```bash
npm run preview
```

### Lint

```bash
npm run lint
```

## Configuration

The frontend is configured to proxy API requests to the backend. See `vite.config.ts`:

```typescript
server: {
  port: 3000,
  proxy: {
    '/hello': {
      target: 'http://localhost:8014',
      changeOrigin: true,
    },
  },
}
```

## Docker

### Build Image

```bash
docker build -t cookbook-frontend .
```

### Run Container

```bash
docker run -p 3000:3000 cookbook-frontend
```

## Usage

1. Start the backend server (see [backend README](../backend/README.md))
2. Open the frontend in your browser
3. Enter a name in the input field
4. Click "Submit" to query the backend API
5. The response from the backend will be displayed below the form

## Technology Stack

- **Framework**: React 19
- **Build Tool**: Vite
- **Language**: TypeScript
- **Styling**: CSS
- **Dev Tools**: ESLint
