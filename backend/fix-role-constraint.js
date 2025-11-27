// Script pour corriger la contrainte CHECK sur la colonne role
require('dotenv').config();
const { Pool } = require('pg');

const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
});

async function fixRoleConstraint() {
  const client = await pool.connect();
  
  try {
    console.log('🔧 Correction de la contrainte role...\n');

    // 1. Supprimer l'ancienne contrainte
    console.log('1️⃣  Suppression de l\'ancienne contrainte...');
    await client.query(`
      ALTER TABLE users 
      DROP CONSTRAINT IF EXISTS users_role_check;
    `);
    console.log('   ✅ Ancienne contrainte supprimée\n');

    // 2. Ajouter la nouvelle contrainte avec les bonnes valeurs
    console.log('2️⃣  Ajout de la nouvelle contrainte...');
    await client.query(`
      ALTER TABLE users 
      ADD CONSTRAINT users_role_check 
      CHECK (role IN ('visiteur', 'acheteur', 'vendeur'));
    `);
    console.log('   ✅ Nouvelle contrainte ajoutée\n');

    // 3. Vérifier la contrainte
    console.log('3️⃣  Vérification de la contrainte...');
    const result = await client.query(`
      SELECT conname, pg_get_constraintdef(oid) as definition
      FROM pg_constraint
      WHERE conrelid = 'users'::regclass
      AND conname = 'users_role_check';
    `);

    if (result.rows.length > 0) {
      console.log('   ✅ Contrainte actuelle:');
      console.log(`   ${result.rows[0].definition}\n`);
    }

    console.log('✅ Correction terminée avec succès!\n');

  } catch (error) {
    console.error('❌ Erreur:', error.message);
    throw error;
  } finally {
    client.release();
    await pool.end();
  }
}

fixRoleConstraint();
