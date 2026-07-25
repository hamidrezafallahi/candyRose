#!/bin/bash

set -e

LOG_FILE="/var/log/shop-deploy.log"

# هم در GitHub Actions نمایش داده می‌شود و هم در فایل لاگ ذخیره می‌شود.
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=================================================="
echo "Deploy started at: $(date)"
echo "Service: $1"
echo "=================================================="

echo "Current directory:"
pwd

echo
echo "Files:"
ls -la

SERVICE=$1

cd /opt/shop

echo
echo "Working directory:"
pwd

echo
echo "Pull latest images..."

case "$SERVICE" in

frontend)
    docker compose -p shop -f docker-compose.prod.yml pull frontend
    docker compose -p shop -f docker-compose.prod.yml up -d --no-deps frontend
    ;;

backend)
    docker compose -p shop -f docker-compose.prod.yml pull backend
    docker compose -p shop -f docker-compose.prod.yml up -d --no-deps backend
    ;;

all)
    docker compose -p shop -f docker-compose.prod.yml pull frontend backend
    docker compose -p shop -f docker-compose.prod.yml up -d --no-deps frontend backend
    ;;

*)
    echo "Unknown service: $SERVICE"
    exit 1
    ;;
esac

echo
echo "Cleaning unused images..."
docker image prune -f

echo
echo "=================================================="
echo "Deploy finished successfully at: $(date)"
echo "=================================================="