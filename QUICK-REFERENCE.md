# Blog Application - Quick Reference Guide

## 🚀 Quick Start Commands

### Local Development
```bash
# Option 1: Manual setup
cd backend && npm install && npm start
cd frontend && npm install && npm start

# Option 2: Use the script
./start-local.sh
```

### Docker Compose
```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### Kubernetes
```bash
# Deploy to K8s
./deploy-k8s.sh

# Or manually
kubectl apply -f k8s/

# Access application
kubectl port-forward service/frontend 3000:80
```

### Helm
```bash
# Install with Helm
./deploy-helm.sh my-blog

# Or manually
helm install my-blog helm/blog-app

# Upgrade
helm upgrade my-blog helm/blog-app

# Uninstall
helm uninstall my-blog
```

## 📁 Project Structure

```
blog-app/
├── backend/              # Node.js Express API
│   ├── config/          # Database config
│   ├── middleware/      # Auth middleware
│   ├── routes/          # API routes
│   └── server.js        # Entry point
├── frontend/            # React application
│   ├── src/
│   │   ├── components/  # React components
│   │   └── services/    # API services
│   └── public/          # Static files
├── k8s/                 # Kubernetes manifests
├── helm/                # Helm chart
└── docker-compose.yml   # Docker Compose config
```

## 🌐 Default Ports

- Frontend: `3000` (local) / `80` (Docker/K8s)
- Backend: `5000`
- MySQL: `3306`

## 🔑 Default Credentials

**Database:**
- User: `bloguser`
- Password: `blogpassword`
- Database: `blog_db`

**JWT Secret:** `your-secret-key-change-this-in-production`

⚠️ **IMPORTANT:** Change these in production!

## 📝 API Endpoints

| Method | Endpoint | Auth Required | Description |
|--------|----------|---------------|-------------|
| POST | `/api/auth/register` | No | Register new user |
| POST | `/api/auth/login` | No | Login user |
| GET | `/api/posts` | Yes | Get all posts |
| GET | `/api/posts/:id` | Yes | Get single post |
| POST | `/api/posts` | Yes | Create post |
| PUT | `/api/posts/:id` | Yes | Update post |
| DELETE | `/api/posts/:id` | Yes | Delete post |

## 🐳 Docker Commands

```bash
# Build images
docker build -t blog-backend ./backend
docker build -t blog-frontend ./frontend

# Run containers
docker-compose up -d

# View logs
docker-compose logs -f [service-name]

# Restart service
docker-compose restart [service-name]

# Stop and remove
docker-compose down -v
```

## ☸️ Kubernetes Commands

```bash
# Apply manifests
kubectl apply -f k8s/

# Get resources
kubectl get pods
kubectl get services
kubectl get pvc

# View logs
kubectl logs <pod-name> -f

# Port forward
kubectl port-forward service/frontend 3000:80

# Delete resources
kubectl delete -f k8s/
```

## 🎯 Helm Commands

```bash
# Install
helm install my-blog helm/blog-app

# Upgrade
helm upgrade my-blog helm/blog-app

# List releases
helm list

# Status
helm status my-blog

# Uninstall
helm uninstall my-blog

# Lint chart
helm lint helm/blog-app

# Dry run
helm install my-blog helm/blog-app --dry-run --debug
```

## 🔍 Troubleshooting

### Port Already in Use
```bash
# Linux/Mac
lsof -i :5000
kill -9 <PID>

# Windows
netstat -ano | findstr :5000
taskkill /PID <PID> /F
```

### Database Connection Failed
1. Check MySQL is running
2. Verify credentials in `.env`
3. Ensure database exists

### Docker Build Issues
```bash
# Clean Docker cache
docker system prune -a

# Rebuild without cache
docker-compose build --no-cache
```

### Kubernetes Pod Issues
```bash
# Describe pod
kubectl describe pod <pod-name>

# Check logs
kubectl logs <pod-name>

# Check events
kubectl get events
```

## 🛠️ Environment Variables

### Backend (.env)
```env
PORT=5000
DB_HOST=localhost
DB_USER=bloguser
DB_PASSWORD=blogpassword
DB_NAME=blog_db
JWT_SECRET=your-secret-key
```

### Frontend (.env)
```env
REACT_APP_API_URL=http://localhost:5000/api
```

## 📊 Health Checks

### Backend Health
```bash
curl http://localhost:5000/health
```

### Database Connection
```bash
mysql -h localhost -u bloguser -pblogpassword blog_db
```

## 🔒 Security Checklist

- [ ] Change default passwords
- [ ] Update JWT secret
- [ ] Enable HTTPS/TLS
- [ ] Configure CORS properly
- [ ] Add rate limiting
- [ ] Implement input validation
- [ ] Use secrets management
- [ ] Enable audit logging

## 📈 Scaling

### Kubernetes Horizontal Scaling
```bash
# Scale backend
kubectl scale deployment backend --replicas=5

# Autoscale
kubectl autoscale deployment backend --min=2 --max=10 --cpu-percent=70
```

### Docker Compose Scaling
```bash
docker-compose up -d --scale backend=3
```

## 🎓 Learning Resources

- **Express.js**: https://expressjs.com/
- **React**: https://react.dev/
- **Docker**: https://docs.docker.com/
- **Kubernetes**: https://kubernetes.io/docs/
- **Helm**: https://helm.sh/docs/

## 💡 Tips

1. Always use environment variables for secrets
2. Test locally before deploying to K8s
3. Use descriptive commit messages
4. Keep dependencies updated
5. Monitor logs regularly
6. Implement proper error handling
7. Use version tags for Docker images
8. Document API changes
9. Backup database regularly
10. Test in staging before production

## 🆘 Support

- Check the main README.md for detailed documentation
- Review AWS-EKS-DEPLOYMENT.md for EKS-specific instructions
- Create GitHub issues for bugs
- Check logs first when troubleshooting

## ⚡ Performance Tips

1. Use connection pooling for database
2. Enable caching (Redis)
3. Optimize Docker images (multi-stage builds)
4. Set resource limits in K8s
5. Use CDN for static assets
6. Enable gzip compression
7. Implement pagination for large datasets
8. Use indexes on database tables

## 🔄 CI/CD Integration

```yaml
# Example GitHub Actions workflow
name: Deploy
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Build images
        run: |
          docker build -t blog-backend ./backend
          docker build -t blog-frontend ./frontend
      - name: Deploy to K8s
        run: kubectl apply -f k8s/
```

---

**Remember:** This is a learning project. Always follow security best practices in production!
