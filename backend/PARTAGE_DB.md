# Guide de partage de la base de données

## Pour vous (exportation)

### Étape 1 : Exporter la base de données

**Méthode automatique** :
```bash
# Double-cliquez sur export_database.bat
```

**Méthode manuelle** :
```bash
pg_dump -U postgres -h localhost -p 5432 immobilier_db > database_backup.sql
```

Le mot de passe PostgreSQL vous sera demandé : `0000`

### Étape 2 : Partager les fichiers

Partagez avec votre collaborateur :
1. ✅ Le fichier SQL généré (`database_backup_YYYYMMDD.sql`)
2. ✅ Le dossier `backend/` complet
3. ✅ Le fichier `.env` (ou les informations de connexion)

**Options de partage** :
- Google Drive / Dropbox
- GitHub (attention : ne pas commit le .env !)
- WeTransfer
- USB

---

## Pour votre collaborateur (importation)

### Prérequis
1. Installer PostgreSQL : https://www.postgresql.org/download/
2. Installer Node.js : https://nodejs.org/
3. Créer un utilisateur PostgreSQL avec le même mot de passe

### Étape 1 : Configuration PostgreSQL

```bash
# Se connecter à PostgreSQL
psql -U postgres

# Créer la base de données
CREATE DATABASE immobilier_db;

# Quitter
\q
```

### Étape 2 : Importer la base de données

**Méthode automatique** :
```bash
# Double-cliquez sur import_database.bat
# Entrez le nom du fichier SQL reçu
```

**Méthode manuelle** :
```bash
psql -U postgres -h localhost -d immobilier_db < database_backup.sql
```

### Étape 3 : Configurer le backend

```bash
cd backend
npm install
```

Vérifiez le fichier `.env` :
```env
DB_HOST=localhost
DB_USER=postgres
DB_PASSWORD=0000
DB_NAME=immobilier_db
DB_PORT=5432
```

### Étape 4 : Lancer le backend

```bash
npm start
```

### Étape 5 : Tester l'API

```bash
curl http://localhost:3000/api/properties
```

---

## Alternative : Docker (Plus simple)

### Pour vous : Créer une image Docker

```bash
# Dans le dossier backend
docker-compose up -d
```

### Pour votre collaborateur

```bash
# Recevoir le fichier docker-compose.yml
docker-compose up -d
```

✅ Tout est configuré automatiquement !

---

## Vérification après import

### Vérifier les données

```bash
psql -U postgres -d immobilier_db

# Dans psql :
SELECT COUNT(*) FROM users;
SELECT COUNT(*) FROM properties;
SELECT COUNT(*) FROM messages;

# Quitter
\q
```

### Résultat attendu
- **users** : 3+ utilisateurs
- **properties** : 5+ propriétés
- **messages** : Quelques messages

---

## Problèmes courants

### Erreur : "role does not exist"
```bash
# Créer l'utilisateur
psql -U postgres
CREATE USER postgres WITH PASSWORD '0000';
ALTER USER postgres CREATEDB;
```

### Erreur : "database already exists"
```bash
# Supprimer et recréer
psql -U postgres
DROP DATABASE immobilier_db;
CREATE DATABASE immobilier_db;
\q
```

### Erreur : "pg_dump: command not found"
```bash
# Ajouter PostgreSQL au PATH
# Windows : Ajouter C:\Program Files\PostgreSQL\14\bin au PATH
```

---

## Synchronisation continue

Pour travailler ensemble en continu, utilisez :

### Option 1 : Base de données partagée (Cloud)
- **Supabase** (PostgreSQL gratuit) : https://supabase.com
- **ElephantSQL** : https://www.elephantsql.com
- **Heroku Postgres** : https://www.heroku.com/postgres

### Option 2 : GitHub + migrations
1. Commitez les migrations SQL
2. Chacun exécute les migrations localement
3. Ne commitez JAMAIS les données sensibles

---

## Contact

En cas de problème, vérifiez :
- ✅ PostgreSQL est installé et lancé
- ✅ Le mot de passe est correct
- ✅ Le port 5432 est disponible
- ✅ Le backend démarre sans erreur
