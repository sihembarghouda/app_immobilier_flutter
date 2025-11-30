// Vérifier les rôles des utilisateurs
const { Pool } = require('pg');

const pool = new Pool({
  host: 'localhost',
  port: 5432,
  database: 'immobilier_db',
  user: 'postgres',
  password: process.env.DB_PASSWORD || 'postgres',
});

async function checkRoles() {
  try {
    const result = await pool.query('SELECT id, name, email, role FROM users ORDER BY id');
    
    console.log('\n📊 Utilisateurs et leurs rôles:');
    console.log('================================\n');
    
    result.rows.forEach(user => {
      console.log(`ID: ${user.id}`);
      console.log(`Nom: ${user.name}`);
      console.log(`Email: ${user.email}`);
      console.log(`Rôle: "${user.role}" (type: ${typeof user.role})`);
      console.log('---');
    });
    
    await pool.end();
  } catch (error) {
    console.error('❌ Erreur:', error.message);
    process.exit(1);
  }
}

checkRoles();
