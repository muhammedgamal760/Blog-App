# Blog Application

A full-stack blog application with user authentication, built with Node.js, React, and MySQL.

## Features

- **User Authentication**: Secure login and registration with JWT tokens
- **CRUD Operations**: Create, read, update, and delete blog posts
- **Protected Routes**: Only authenticated users can view and manage posts
- **Responsive UI**: Clean and modern interface built with React
- **RESTful API**: Well-structured backend with Express.js
- **MySQL Database**: Persistent data storage with relational database

## Technology Stack

### Backend
- **Node.js** - JavaScript runtime
- **Express.js** - Web framework
- **MySQL** - Relational database
- **JWT** - Token-based authentication
- **bcryptjs** - Password hashing

### Frontend
- **React** - UI library
- **React Router** - Client-side routing
- **Axios** - HTTP client

## Project Structure

```
blog-app/
├── backend/
│   ├── config/
│   │   └── database.js          # Database configuration
│   ├── middleware/
│   │   └── auth.js              # Authentication middleware
│   ├── routes/
│   │   ├── auth.js              # Authentication routes
│   │   └── posts.js             # Blog post routes
│   ├── .env.example             # Environment variables template
│   ├── server.js                # Main server file
│   ├── package.json
│   └── Dockerfile
├── frontend/
│   ├── public/
│   │   └── index.html
│   ├── src/
│   │   ├── components/
│   │   │   ├── Login.js         # Login/Register component
│   │   │   └── Blog.js          # Main blog component
│   │   ├── services/
│   │   │   └── api.js           # API service
│   │   ├── App.js               # Main app component
│   │   └── index.js             # Entry point
│   ├── package.json
│   ├── Dockerfile
│   └── nginx.conf
├── k8s/                         # Kubernetes manifests
├── helm/                        # Helm chart
├── docker-compose.yml
└── README.md
```

## Deployment Options

This application can be deployed in four different ways:

1. **[Local Development](#1-local-development)** - Run on your machine with Node.js and MySQL
2. **[Docker Compose](#2-docker-compose)** - Run as Docker containers
3. **[Kubernetes](#3-kubernetes-deployment)** - Deploy to Kubernetes cluster
4. **[Helm Chart](#4-helm-deployment)** - Deploy using Helm package manager

---

## 1. Local Development

### Prerequisites
- Node.js 18+ installed
- MySQL 8.0+ installed and running
- npm or yarn package manager

### Setup Steps

#### 1. Clone the repository and navigate to project directory

```bash
cd blog-app
```

#### 2. Setup MySQL Database

```bash
mysql -u root -p
```

```sql
CREATE DATABASE blog_db;
CREATE USER 'bloguser'@'localhost' IDENTIFIED BY 'blogpassword';
GRANT ALL PRIVILEGES ON blog_db.* TO 'bloguser'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

#### 3. Setup Backend

```bash
cd backend
npm install
cp .env.example .env
```

Edit `.env` file with your configuration:
```env
PORT=5000
DB_HOST=localhost
DB_USER=bloguser
DB_PASSWORD=blogpassword
DB_NAME=blog_db
JWT_SECRET=your-secret-key-change-this-in-production
```

Start the backend server:
```bash
npm start
```

Backend will run on `http://localhost:5000`

#### 4. Setup Frontend

Open a new terminal:
```bash
cd frontend
npm install
```

Start the frontend development server:
```bash
npm start
```

Frontend will run on `http://localhost:3000`

### Testing the Application

1. Open your browser and go to `http://localhost:3000`
2. Click "Register" to create a new account
3. Login with your credentials
4. Start creating blog posts!

---

## 2. Docker Compose

### Prerequisites
- Docker installed
- Docker Compose installed

### Setup Steps

#### 1. Build and run the containers

```bash
docker-compose up --build
```

This will:
- Build the backend and frontend images
- Pull the MySQL image
- Start all three containers
- Set up networking between containers

#### 2. Access the application

- Frontend: `http://localhost:3000`
- Backend API: `http://localhost:5000`
- MySQL: `localhost:3306`

#### 3. Stop the containers

```bash
docker-compose down
```

#### 4. Remove volumes (if you want to reset the database)

```bash
docker-compose down -v
```

### Docker Commands Reference

```bash
# View running containers
docker-compose ps

# View logs
docker-compose logs -f

# View logs for specific service
docker-compose logs -f backend

# Restart a service
docker-compose restart backend

# Rebuild a specific service
docker-compose up --build backend

# Execute commands in a container
docker-compose exec backend sh
```

---

## 3. Kubernetes Deployment

### Prerequisites
- Kubernetes cluster (local: minikube, kind, or cloud: EKS, GKE, AKS)
- kubectl configured
- Docker images built and pushed to a registry (or use local images)

### For Local Kubernetes (minikube/kind)

#### 1. Start your local cluster

**For minikube:**
```bash
minikube start
eval $(minikube docker-env)
```

**For kind:**
```bash
kind create cluster --name blog-cluster
```

#### 2. Build Docker images

```bash
# Build backend
cd backend
docker build -t blog-backend:latest .

# Build frontend
cd ../frontend
docker build -t blog-frontend:latest .
```

#### 3. Apply Kubernetes manifests

```bash
cd ..
kubectl apply -f k8s/mysql-deployment.yaml
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/frontend-deployment.yaml
```

#### 4. Check deployment status

```bash
kubectl get pods
kubectl get services
```

#### 5. Access the application

**For minikube:**
```bash
minikube service frontend
```

**For kind:**
```bash
kubectl port-forward service/frontend 3000:80
```

Then access: `http://localhost:3000`

### For AWS EKS

#### 1. Create ECR repositories

```bash
aws ecr create-repository --repository-name blog-backend
aws ecr create-repository --repository-name blog-frontend
```

#### 2. Authenticate Docker to ECR

```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com
```

#### 3. Tag and push images

```bash
# Tag images
docker tag blog-backend:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/blog-backend:latest
docker tag blog-frontend:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/blog-frontend:latest

# Push images
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/blog-backend:latest
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/blog-frontend:latest
```

#### 4. Update Kubernetes manifests

Edit `k8s/backend-deployment.yaml` and `k8s/frontend-deployment.yaml` to use your ECR image URLs:

```yaml
image: <account-id>.dkr.ecr.us-east-1.amazonaws.com/blog-backend:latest
```

#### 5. Create EKS cluster

```bash
eksctl create cluster --name blog-cluster --region us-east-1 --nodegroup-name standard-workers --node-type t3.medium --nodes 2
```

#### 6. Deploy to EKS

```bash
kubectl apply -f k8s/mysql-deployment.yaml
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/frontend-deployment.yaml
```

#### 7. Get LoadBalancer URL

```bash
kubectl get service frontend
```

Access the application using the EXTERNAL-IP (LoadBalancer URL)

### Kubernetes Commands Reference

```bash
# View all resources
kubectl get all

# Describe a pod
kubectl describe pod <pod-name>

# View logs
kubectl logs <pod-name>
kubectl logs -f <pod-name>  # Follow logs

# Execute commands in a pod
kubectl exec -it <pod-name> -- sh

# Delete all resources
kubectl delete -f k8s/

# Scale deployments
kubectl scale deployment backend --replicas=3

# View persistent volumes
kubectl get pv
kubectl get pvc
```

---

## 4. Helm Deployment

### Prerequisites
- Helm 3.x installed
- Kubernetes cluster running
- kubectl configured
- Docker images available in a registry

### Setup Steps

#### 1. Update values.yaml

Edit `helm/blog-app/values.yaml` with your image repositories:

```yaml
backend:
  image:
    repository: <your-registry>/blog-backend
    tag: "latest"

frontend:
  image:
    repository: <your-registry>/blog-frontend
    tag: "latest"
```

#### 2. Install the Helm chart

```bash
# Install with default values
helm install my-blog helm/blog-app

# Install with custom values
helm install my-blog helm/blog-app -f custom-values.yaml

# Install in a specific namespace
helm install my-blog helm/blog-app --namespace blog --create-namespace
```

#### 3. Check the deployment

```bash
helm list
kubectl get pods
kubectl get services
```

#### 4. Access the application

```bash
# Get the LoadBalancer IP
kubectl get service frontend

# Or use port-forward
kubectl port-forward service/frontend 3000:80
```

### Helm Commands Reference

```bash
# List installed releases
helm list

# Get release status
helm status my-blog

# Upgrade release
helm upgrade my-blog helm/blog-app

# Rollback to previous version
helm rollback my-blog

# Uninstall release
helm uninstall my-blog

# View generated manifests without installing
helm template my-blog helm/blog-app

# Validate chart
helm lint helm/blog-app

# Package chart
helm package helm/blog-app
```

### Customizing Helm Deployment

Create a custom `values.yaml`:

```yaml
mysql:
  persistence:
    size: 10Gi
  
backend:
  replicaCount: 3
  resources:
    limits:
      cpu: 1000m
      memory: 1Gi

frontend:
  replicaCount: 3

ingress:
  enabled: true
  className: "nginx"
  hosts:
    - host: blog.yourdomain.com
      paths:
        - path: /
          pathType: Prefix
```

Install with custom values:
```bash
helm install my-blog helm/blog-app -f custom-values.yaml
```

---

## API Documentation

### Authentication Endpoints

#### Register User
```http
POST /api/auth/register
Content-Type: application/json

{
  "username": "john_doe",
  "password": "securepassword"
}
```

#### Login
```http
POST /api/auth/login
Content-Type: application/json

{
  "username": "john_doe",
  "password": "securepassword"
}

Response:
{
  "message": "Login successful",
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "username": "john_doe"
}
```

### Blog Post Endpoints (Require Authentication)

#### Get All Posts
```http
GET /api/posts
Authorization: Bearer <token>
```

#### Get Single Post
```http
GET /api/posts/:id
Authorization: Bearer <token>
```

#### Create Post
```http
POST /api/posts
Authorization: Bearer <token>
Content-Type: application/json

{
  "title": "My First Blog Post",
  "content": "This is the content of my blog post..."
}
```

#### Update Post
```http
PUT /api/posts/:id
Authorization: Bearer <token>
Content-Type: application/json

{
  "title": "Updated Title",
  "content": "Updated content..."
}
```

#### Delete Post
```http
DELETE /api/posts/:id
Authorization: Bearer <token>
```

---

## Database Schema

### Users Table
```sql
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Posts Table
```sql
CREATE TABLE posts (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  content TEXT NOT NULL,
  author_id INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE CASCADE
);
```

---

## Security Considerations

1. **Change Default Passwords**: Always change default passwords in production
2. **Use Strong JWT Secret**: Generate a secure random string for JWT_SECRET
3. **Enable HTTPS**: Use TLS certificates in production
4. **Implement Rate Limiting**: Add rate limiting to prevent abuse
5. **Input Validation**: Validate and sanitize all user inputs
6. **SQL Injection Protection**: Use parameterized queries (already implemented)
7. **XSS Protection**: React provides built-in XSS protection
8. **CORS Configuration**: Configure CORS properly for production

---

## Troubleshooting

### Common Issues

#### Port Already in Use
```bash
# Find process using port
lsof -i :5000
lsof -i :3000

# Kill process
kill -9 <PID>
```

#### Database Connection Error
- Verify MySQL is running
- Check credentials in .env file
- Ensure database exists

#### Docker Build Fails
```bash
# Clean Docker cache
docker system prune -a

# Rebuild without cache
docker-compose build --no-cache
```

#### Kubernetes Pods Not Starting
```bash
# Check pod logs
kubectl logs <pod-name>

# Describe pod for events
kubectl describe pod <pod-name>

# Check if images are accessible
kubectl get pods -o wide
```

#### Helm Installation Fails
```bash
# Validate chart
helm lint helm/blog-app

# Debug installation
helm install my-blog helm/blog-app --debug --dry-run
```

---

## Environment Variables

### Backend (.env)
```env
PORT=5000                    # Backend port
DB_HOST=localhost            # Database host
DB_USER=bloguser             # Database username
DB_PASSWORD=blogpassword     # Database password
DB_NAME=blog_db              # Database name
JWT_SECRET=secret-key        # JWT signing secret
```

### Frontend (.env)
```env
REACT_APP_API_URL=http://localhost:5000/api
```

---

## Production Deployment Checklist

- [ ] Change all default passwords
- [ ] Generate secure JWT secret
- [ ] Configure environment variables
- [ ] Set up SSL/TLS certificates
- [ ] Configure proper CORS settings
- [ ] Enable rate limiting
- [ ] Set up monitoring and logging
- [ ] Configure backups for database
- [ ] Review and update resource limits
- [ ] Set up CI/CD pipeline
- [ ] Configure auto-scaling (for cloud deployments)
- [ ] Set up health checks
- [ ] Configure proper network policies
- [ ] Enable secret management (e.g., AWS Secrets Manager)

---

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

---

## License

MIT License - feel free to use this project for learning and development.

---

## Support

For issues and questions:
- Create an issue in the repository
- Check existing documentation
- Review troubleshooting section

---

## Acknowledgments

Built with:
- Node.js and Express.js
- React
- MySQL
- Docker
- Kubernetes
- Helm
