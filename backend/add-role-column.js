// Script rapide pour ajouter la colonne role
const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'admin123',
  database: process.env.DB_NAME || 'immobilier_db'
});

async function addRoleColumn() {
  console.log('\n🔧 Ajout de la colonne role...\n');
  
  const client = await pool.connect();
  
  try {
    // Ajouter la colonne role
    await client.query(`
      ALTER TABLE users 
      ADD COLUMN IF NOT EXISTS role VARCHAR(20) DEFAULT 'visiteur'
    `);
    console.log('✅ Colonne role ajoutée');

    // Créer un index
    await client.query(`
      CREATE INDEX IF NOT EXISTS idx_users_role ON users(role)
    `);
    console.log('✅ Index créé sur la colonne role');

    // Vérifier la structure
    const result = await client.query(`
      SELECT column_name, data_type, column_default
      FROM information_schema.columns
      WHERE table_name = 'users'
      ORDER BY ordinal_position
    `);

    console.log('\n📋 Structure de la table users:');
    console.table(result.rows);

    // Compter les utilisateurs par rôle
    const counts = await client.query(`
      SELECT 
        COALESCE(role, 'NULL') as role,
        COUNT(*) as count
      FROM users
      GROUP BY role
    `);

    console.log('\n👥 Répartition des utilisateurs:');
    console.table(counts.rows);

    console.log('\n✅ Migration terminée avec succès!\n');

  } catch (error) {
    console.error('❌ Erreur:', error.message);
  } finally {
    client.release();
    await pool.end();
  }
}

addRoleColumn();
