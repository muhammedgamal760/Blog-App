#!/bin/bash

# Quick start script for local development

echo "🚀 Starting Blog Application Setup..."

# Check if MySQL is running
if ! command -v mysql &> /dev/null; then
    echo "❌ MySQL is not installed. Please install MySQL first."
    exit 1
fi

# Setup MySQL Database
echo "📦 Setting up MySQL database..."
mysql -u root -p <<EOF
CREATE DATABASE IF NOT EXISTS blog_db;
CREATE USER IF NOT EXISTS 'bloguser'@'localhost' IDENTIFIED BY 'blogpassword';
GRANT ALL PRIVILEGES ON blog_db.* TO 'bloguser'@'localhost';
FLUSH PRIVILEGES;
EOF

# Setup Backend
echo "🔧 Setting up backend..."
cd backend
if [ ! -f .env ]; then
    cp .env.example .env
    echo "✅ Created .env file from template"
fi

npm install
echo "✅ Backend dependencies installed"

# Start backend in background
npm start &
BACKEND_PID=$!
echo "✅ Backend started (PID: $BACKEND_PID)"

# Setup Frontend
echo "🎨 Setting up frontend..."
cd ../frontend
npm install
echo "✅ Frontend dependencies installed"

# Start frontend
echo "🌐 Starting frontend..."
npm start

# Cleanup function
cleanup() {
    echo "🛑 Stopping services..."
    kill $BACKEND_PID
    exit 0
}

trap cleanup EXIT
