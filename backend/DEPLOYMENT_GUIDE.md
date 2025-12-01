# ImmoTunisie Backend - Guide de Déploiement

## 📋 Prérequis

- Node.js 16+ installé
- MySQL 8.0+ installé et en cours d'exécution
- Git (optionnel)

## 🚀 Installation Rapide

### 1. Configurer la Base de Données

```bash
# Se connecter à MySQL
mysql -u root -p

# Créer la base de données
CREATE DATABASE immobilier_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

# Créer un utilisateur (optionnel mais recommandé)
CREATE USER 'immobilier_user'@'localhost' IDENTIFIED BY 'votre_mot_de_passe';
GRANT ALL PRIVILEGES ON immobilier_db.* TO 'immobilier_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### 2. Configurer l'Environnement

```bash
# Copier le fichier d'exemple
cp .env.example .env

# Éditer .env avec vos configurations
nano .env  # ou vim, notepad, etc.
```

**Modifiez ces valeurs dans `.env`:**
```
DB_PASSWORD=votre_mot_de_passe_mysql
JWT_SECRET=un_secret_très_long_et_aléatoire_ici
```

### 3. Installer les Dépendances

```bash
npm install
```

### 4. Créer les Tables

```bash
npm run migrate
```

### 5. Ajouter des Données de Test (Optionnel)

```bash
npm run seed:properties
```

### 6. Démarrer le Serveur

**Mode développement:**
```bash
npm run dev
```

**Mode production:**
```bash
npm start
```

Le serveur sera accessible sur: `http://localhost:3000`

## 📝 Configuration de l'Application Flutter

Une fois le backend démarré, mettez à jour l'URL dans l'application Flutter:

**Fichier:** `frontend/lib/screens/utils/constants.dart`

```dart
// Pour un serveur local sur le même réseau
static const String apiBaseUrl = 'http://VOTRE_IP_LOCAL:3000/api';

// Pour un serveur déployé en production
static const String apiBaseUrl = 'https://votre-domaine.com/api';
```

**Comment trouver votre IP local:**
- Windows: `ipconfig` (cherchez "IPv4")
- Mac/Linux: `ifconfig` ou `ip addr`

## 🌐 Déploiement en Production

### Option 1: Render.com (Gratuit)

1. Créez un compte sur [render.com](https://render.com)
2. Créez un nouveau "Web Service"
3. Connectez votre repo GitHub ou uploadez le code
4. Configurez:
   - Build Command: `npm install`
   - Start Command: `npm start`
5. Ajoutez les variables d'environnement dans le dashboard
6. Créez une base de données MySQL sur Render
7. Copiez l'URL de votre service

### Option 2: VPS (DigitalOcean, AWS, etc.)

```bash
# Sur le serveur
git clone votre_repo
cd backend
npm install --production
npm run migrate

# Utiliser PM2 pour garder le serveur en vie
npm install -g pm2
pm2 start server.js --name immobilier-api
pm2 startup
pm2 save
```

### Option 3: Heroku (Payant)

```bash
heroku create immotunisie-api
heroku addons:create cleardb:ignite
heroku config:set JWT_SECRET=votre_secret
git push heroku main
heroku run npm run migrate
```

## 🔒 Sécurité - IMPORTANT!

Avant de déployer en production:

1. ✅ Changez `JWT_SECRET` dans `.env` (utilisez un générateur de clés)
2. ✅ Changez le mot de passe MySQL
3. ✅ Configurez `CORS_ORIGIN` avec votre domaine frontend
4. ✅ Activez HTTPS (obligatoire pour Play Store!)
5. ✅ Mettez `NODE_ENV=production`

## 📦 Structure du Projet

```
backend/
├── server.js              # Point d'entrée
├── package.json           # Dépendances
├── .env                   # Configuration (NE PAS COMMITTER!)
├── .env.example           # Template de configuration
├── src/
│   ├── config/
│   │   └── database.js    # Configuration MySQL
│   ├── database/
│   │   └── migrate.js     # Création des tables
│   ├── middleware/
│   │   └── auth.middleware.js
│   └── routes/
│       ├── auth.routes.js
│       ├── property.routes.js
│       ├── favorite.routes.js
│       ├── message.routes.js
│       └── upload.routes.js
└── uploads/               # Fichiers uploadés
```

## 🐛 Résolution de Problèmes

### Le serveur ne démarre pas
- Vérifiez que MySQL est en cours d'exécution
- Vérifiez les credentials dans `.env`
- Vérifiez que le port 3000 est libre: `netstat -ano | findstr :3000`

### Erreurs de connexion depuis l'app
- Vérifiez l'URL dans `constants.dart`
- Assurez-vous que le serveur est accessible depuis le réseau
- Vérifiez le pare-feu Windows

### Erreurs de base de données
- Exécutez `npm run migrate` pour créer les tables
- Vérifiez les permissions MySQL

## 📞 Support

Pour toute question, contactez: rayenchraiet2000@gmail.com

## 📄 License

ISC
