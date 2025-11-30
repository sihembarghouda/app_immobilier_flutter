# Dockerfile pour le backend Node.js
FROM node:18-alpine

# Définir le répertoire de travail
WORKDIR /app

# Copier package.json et package-lock.json
COPY package*.json ./

# Installer les dépendances
RUN npm ci --only=production

# Copier le reste des fichiers
COPY . .

# Créer le dossier uploads
RUN mkdir -p uploads/profiles uploads/properties

# Exposer le port
EXPOSE 3000

# Variable d'environnement pour la production
ENV NODE_ENV=production

# Démarrer l'application
CMD ["node", "server.js"]
