#!/bin/bash
# Docker deployment script - handles the complete setup process

set -e  # Exit on any error

echo "🚀 Transaction Risk - Docker Deployment"
echo "=" | tr '=' '='  | head -c 70; echo

# Step 1: Check if Docker is running
echo "1️⃣  Checking Docker..."
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker Desktop and try again."
    exit 1
fi
echo "✅ Docker is running"

# Step 2: Build images
echo ""
echo "2️⃣  Building Docker images..."
docker-compose build --progress=plain
echo "✅ Images built successfully"

# Step 3: Start services
echo ""
echo "3️⃣  Starting services..."
docker-compose up -d
echo "✅ Services started"

# Step 4: Wait for database to be ready
echo ""
echo "4️⃣  Waiting for database to be ready..."
timeout 60 bash -c 'until docker-compose exec -T postgres pg_isready -U frauduser -d frauddb; do sleep 2; done'
echo "✅ Database is ready"

# Step 5: Load Sparkov dataset (if not already loaded)
echo ""
echo "5️⃣  Checking if data needs to be loaded..."
RECORD_COUNT=$(docker-compose exec -T postgres psql -U frauduser -d frauddb -t -c "SELECT COUNT(*) FROM transactions;" 2>/dev/null || echo "0")
RECORD_COUNT=$(echo $RECORD_COUNT | tr -d ' ')

if [ "$RECORD_COUNT" -lt "1000" ]; then
    echo "📂 Loading Sparkov dataset..."
    docker-compose exec -T api python db/load_sparkov.py
    echo "✅ Data loaded successfully"
else
    echo "✅ Data already loaded ($RECORD_COUNT transactions)"
fi

# Step 6: Add indexes (if not exists)
echo ""
echo "6️⃣  Creating database indexes..."
docker-compose exec -T api python db/add_indexes.py
echo "✅ Indexes created"

# Step 7: Verify model files exist
echo ""
echo "7️⃣  Checking for trained model..."
if [ ! -f "./models/fraud_model_v1.pt" ]; then
    echo "⚠️  No trained model found!"
    echo "   Run this command to train:"
    echo "   docker-compose exec api python model/train.py"
else
    echo "✅ Model found: models/fraud_model_v1.pt"
fi

# Step 8: Show status
echo ""
echo "8️⃣  Service Status:"
docker-compose ps

echo ""
echo "=" | tr '=' '='  | head -c 70; echo
echo "🎉 Deployment complete!"
echo ""
echo "📍 API available at: http://localhost:8000"
echo "📍 Health check: http://localhost:8000/health"
echo "📍 Database: postgresql://frauduser:fraudpass@localhost:5432/frauddb"
echo ""
echo "📋 Useful commands:"
echo "   View logs: docker-compose logs -f api"
echo "   Stop services: docker-compose down"
echo "   Restart services: docker-compose restart"
echo "   Run training: docker-compose exec api python model/train.py"
echo ""
