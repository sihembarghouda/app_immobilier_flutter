#!/bin/bash

# Script de déploiement sur Google Cloud Run

# Variables à configurer
PROJECT_ID="votre-projet-id"
SERVICE_NAME="immobilier-api"
REGION="europe-west1"
IMAGE_NAME="gcr.io/$PROJECT_ID/$SERVICE_NAME"

echo "🚀 Déploiement du backend sur Google Cloud Run..."

# 1. Build l'image Docker
echo "📦 Construction de l'image Docker..."
docker build -t $IMAGE_NAME .

# 2. Push l'image vers Google Container Registry
echo "⬆️  Upload de l'image..."
docker push $IMAGE_NAME

# 3. Déployer sur Cloud Run
echo "🌐 Déploiement sur Cloud Run..."
gcloud run deploy $SERVICE_NAME \
  --image $IMAGE_NAME \
  --platform managed \
  --region $REGION \
  --allow-unauthenticated \
  --set-env-vars "NODE_ENV=production" \
  --set-env-vars "JWT_SECRET=$JWT_SECRET" \
  --set-env-vars "DB_HOST=$DB_HOST" \
  --set-env-vars "DB_PORT=$DB_PORT" \
  --set-env-vars "DB_NAME=$DB_NAME" \
  --set-env-vars "DB_USER=$DB_USER" \
  --set-env-vars "DB_PASSWORD=$DB_PASSWORD"

echo "✅ Déploiement terminé !"
echo "🔗 Votre API est accessible sur :"
gcloud run services describe $SERVICE_NAME --region $REGION --format 'value(status.url)'
