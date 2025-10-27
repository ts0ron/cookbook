# Docker Compose Setup

This docker-compose configuration runs the Cookbook application stack locally using Docker.

## Services

The docker-compose file includes three services:

1. **MongoDB** - Database service with persistent volume
2. **Backend** - Express.js API server
3. **Frontend** - React frontend application

## Prerequisites

- Docker and Docker Compose installed
- Local code for backend and frontend in `./backend` and `./frontend` directories

## Quick Start

### Start all services (builds images automatically)
```bash
docker-compose up
```

This will automatically build the backend and frontend images from your local code before starting the services.

### Start services in the background
```bash
docker-compose up -d
```

### View logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f mongodb
```

### Stop all services
```bash
docker-compose down
```

### Stop and remove volumes (cleans up database data)
```bash
docker-compose down -v
```

## Access Points

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8014
- **MongoDB**: localhost:27017

## Image Building

The backend and frontend services are built from local Dockerfiles:

- **Backend**: Built from `./backend/Dockerfile` using multi-stage build
  - Builds TypeScript and installs production dependencies
  - Final image size optimized with Alpine Linux
  
- **Frontend**: Built from `./frontend/Dockerfile` using multi-stage build
  - Builds React app with Vite
  - Serves with Nginx in production mode

Images are automatically built when you run `docker-compose up` if they don't exist or if code has changed.

## Environment Variables

### Backend
- `PORT`: Server port (default: 8014)
- `NODE_ENV`: Environment (production)
- `MONGO_HOST`: MongoDB hostname
- `MONGO_PORT`: MongoDB port
- `MONGO_DATABASE`: Database name

### Frontend
- `VITE_API_URL`: Backend API URL

### MongoDB
- `MONGO_INITDB_ROOT_USERNAME`: Root username (admin)
- `MONGO_INITDB_ROOT_PASSWORD`: Root password
- `MONGO_INITDB_DATABASE`: Initial database

## MongoDB Credentials

### Root User
- Username: `admin`
- Password: `password123`
- Database: `cookbook`

### Application User
- Username: `cookbook-user`
- Password: `cookbookuserpass`
- Database: `cookbook`
- Role: `readWrite`

## Data Persistence

MongoDB data is persisted in a Docker volume named `mongo-data`. This ensures that your database data is retained between container restarts.

### To backup the database
```bash
docker exec cookbook-mongodb mongodump --out /tmp/backup
```

### To restore the database
```bash
docker exec cookbook-mongodb mongorestore /tmp/backup
```

## Resource Limits

Resource allocations are based on the Kubernetes configurations:

| Service | Memory Limit | CPU Limit | Memory Reserve | CPU Reserve |
|---------|-------------|-----------|----------------|-------------|
| MongoDB | 512M | 0.5 CPU | 256M | 0.1 CPU |
| Backend | 256M | 0.2 CPU | 128M | 0.1 CPU |
| Frontend | 128M | 0.1 CPU | 64M | 0.05 CPU |

## Health Checks

All services include health checks:
- **MongoDB**: Checks connectivity using `mongosh`
- **Backend**: Checks HTTP endpoint `/hello/world`
- **Frontend**: Checks HTTP endpoint `/`

## Troubleshooting

### Check service status
```bash
docker-compose ps
```

### Restart a specific service
```bash
docker-compose restart backend
```

### View service logs
```bash
docker-compose logs backend
```

### Access MongoDB shell
```bash
docker exec -it cookbook-mongodb mongosh -u admin -p password123
```

### Rebuild and start (if code changed)
```bash
docker-compose down
docker-compose up --build
```

Or rebuild a specific service:
```bash
docker-compose up --build backend
```

### Build images without starting
```bash
docker-compose build
```

## Connecting to MongoDB

### Using MongoDB Compass
```
Connection String: mongodb://admin:password123@localhost:27017/cookbook?authSource=admin
```

### Using mongosh (from host)
```bash
mongosh "mongodb://admin:password123@localhost:27017"
```

## Development vs Production

This docker-compose setup is designed to mirror the Kubernetes deployment for local development. The key differences:

- **Kubernetes**: Uses PVC for MongoDB data persistence
- **Docker Compose**: Uses named Docker volumes
- **Kubernetes**: Multiple replicas (2 for backend/frontend)
- **Docker Compose**: Single instance per service
- **Kubernetes**: ClusterIP/LoadBalancer services
- **Docker Compose**: Direct port mapping

